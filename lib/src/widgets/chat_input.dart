import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../emoji/chat_emoji_picker.dart';
import '../l10n/chat_localizations.dart';
import '../material.dart';
import '../models/chat_message.dart';
import '../theme/chat_theme.dart';
import 'chat_builders.dart';

/// Message composer: a growing text field and a send button.
///
/// `ChatView` shows it by default. You can also place it yourself, for
/// example inside `ChatView.inputBuilder` to add [leading] or [trailing]
/// buttons:
///
/// ```dart
/// inputBuilder: (context, send) => ChatInput(
///   onSend: send,
///   leading: IconButton(
///     icon: const Icon(Icons.add),
///     onPressed: pickAttachment,
///   ),
/// ),
/// ```
///
/// On desktop and web, Enter sends and Shift+Enter inserts a new line.
/// Selected text can be formatted from the context menu or with
/// Ctrl/Cmd+B (bold), I (italic), Shift+X (strikethrough), E (code) and K
/// (link).
class ChatInput extends StatefulWidget {
  /// Creates a message composer.
  const ChatInput({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.hintText,
    this.onTypingChanged,
    this.typingTimeout = const Duration(seconds: 3),
    this.leading,
    this.trailing,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.maxLines = 6,
    this.maxLength,
    this.sendOnEnter,
    this.textCapitalization = TextCapitalization.sentences,
    this.sendIcon = Icons.arrow_upward_rounded,
    this.onRecordStart,
    this.onRecordEnd,
    this.showEmojiButton = false,
    this.onStop,
    this.onSchedule,
    this.stickerPacks = const [],
    this.onSticker,
    this.imageProviderBuilder,
    this.allowEmptySend = false,
    this.onArrowUp,
    this.onEscape,
    this.onContentInserted,
    this.enableFormatting = true,
  });

  /// Called with the trimmed text when the user sends a non-empty message.
  final ValueChanged<String> onSend;

  /// Whether the user can type and send.
  final bool enabled;

  /// Placeholder. Defaults to [ChatLocalizations.inputHint].
  final String? hintText;

  /// Called with `true` when the user starts typing and with `false` after
  /// [typingTimeout] of inactivity or when the message is sent. Use it to
  /// broadcast your own typing state.
  final ValueChanged<bool>? onTypingChanged;

  /// Inactivity delay after which [onTypingChanged] reports `false`.
  final Duration typingTimeout;

  /// Widget before the text field, such as an attachment button.
  final Widget? leading;

  /// Widget between the text field and the send button.
  final Widget? trailing;

  /// Controls the text. When `null`, the widget manages its own.
  final TextEditingController? controller;

  /// Focus of the text field. When `null`, the widget manages its own.
  final FocusNode? focusNode;

  /// Whether the text field takes focus when shown.
  final bool autofocus;

  /// Lines the field grows to before scrolling.
  final int maxLines;

  /// Optional character limit.
  final int? maxLength;

  /// Whether Enter sends the message. Defaults to `true` on web and desktop
  /// and `false` on mobile, where Enter inserts a new line.
  final bool? sendOnEnter;

  /// Capitalization of the on-screen keyboard.
  final TextCapitalization textCapitalization;

  /// Icon of the send button. `ChatView` switches it to a check mark while
  /// editing a message.
  final IconData sendIcon;

  /// Called when the user presses and holds the microphone button. When
  /// set, the send button turns into a microphone while the field is empty.
  ///
  /// Start your audio recorder here. chatx records nothing itself.
  final VoidCallback? onRecordStart;

  /// Called when the user releases the microphone button, or slides away to
  /// cancel. Stop your recorder and send or discard the audio.
  final ChatVoiceRecordEndCallback? onRecordEnd;

  /// Whether to show a button that swaps the keyboard for
  /// [ChatEmojiPicker]. `ChatView` turns it on by default.
  final bool showEmojiButton;

  /// When set, the send button becomes a stop button that calls this, for
  /// example while an AI answer streams.
  final VoidCallback? onStop;

  /// When set, long-pressing the send button calls this with the text, so
  /// the app can offer to schedule the message.
  final ValueChanged<String>? onSchedule;

  /// Sticker packs shown as extra tabs in the emoji picker.
  final List<ChatStickerPack> stickerPacks;

  /// Called when the user picks a sticker.
  final ValueChanged<ChatSticker>? onSticker;

  /// Loads sticker images. Defaults to [NetworkImage].
  final ImageProvider Function(String uri)? imageProviderBuilder;

  /// Whether the send button works with an empty field, for example while
  /// attachments wait to be sent. [onSend] then receives an empty string.
  final bool allowEmptySend;

  /// Called when the user presses the up arrow in an empty field. `ChatView`
  /// uses it to edit the last message.
  final VoidCallback? onArrowUp;

  /// Called when the user presses Escape, for example to cancel a reply.
  final VoidCallback? onEscape;

  /// Called when the keyboard inserts an image or GIF, for example from
  /// Gboard. When `null`, such keyboards do not offer images.
  final ValueChanged<KeyboardInsertedContent>? onContentInserted;

  /// Whether selected text can be formatted with markdown from the context
  /// menu and keyboard shortcuts.
  final bool enableFormatting;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  final ValueNotifier<bool> _canSend = ValueNotifier(false);
  Timer? _typingTimer;
  bool _isTyping = false;

  static const double _cancelDistance = 110;
  final ValueNotifier<Duration> _recordElapsed = ValueNotifier(Duration.zero);
  final ValueNotifier<double> _recordSlide = ValueNotifier(0);
  Stopwatch? _recordWatch;
  Timer? _recordTicker;
  bool get _recording => _recordWatch != null;
  bool _emojiOpen = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  bool get _sendOnEnter =>
      widget.sendOnEnter ??
      (kIsWeb ||
          switch (defaultTargetPlatform) {
            TargetPlatform.macOS ||
            TargetPlatform.windows ||
            TargetPlatform.linux =>
              true,
            _ => false,
          });

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
    _canSend.value =
        _controller.text.trim().isNotEmpty || widget.allowEmptySend;
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
    if (oldWidget.allowEmptySend != widget.allowEmptySend) {
      _canSend.value =
          _controller.text.trim().isNotEmpty || widget.allowEmptySend;
    }
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onTextChanged);
      _controller.addListener(_onTextChanged);
      _onTextChanged();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _recordTicker?.cancel();
    if (_recording) widget.onRecordEnd?.call(Duration.zero, cancelled: true);
    _recordElapsed.dispose();
    _recordSlide.dispose();
    _typingTimer?.cancel();
    if (_isTyping) widget.onTypingChanged?.call(false);
    _controller.removeListener(_onTextChanged);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    _canSend.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    _canSend.value = hasText || widget.allowEmptySend;
    if (widget.onTypingChanged == null) return;
    if (!hasText) {
      _setTyping(false);
      return;
    }
    _setTyping(true);
    _typingTimer?.cancel();
    _typingTimer = Timer(widget.typingTimeout, () => _setTyping(false));
  }

  void _setTyping(bool value) {
    if (_isTyping == value) return;
    _isTyping = value;
    if (!value) _typingTimer?.cancel();
    widget.onTypingChanged?.call(value);
  }

  // Typing again closes the emoji picker, like system keyboards do.
  void _onFocusChanged() {
    if (_focusNode.hasFocus && _emojiOpen) setState(() => _emojiOpen = false);
  }

  void _toggleEmoji() {
    if (_emojiOpen) {
      setState(() => _emojiOpen = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _emojiOpen = true);
    }
  }

  void _insertEmoji(String emoji) {
    final value = _controller.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    final text = value.text.replaceRange(start, end, emoji);
    // The picker bypasses the text field, so it enforces maxLength here.
    final maxLength = widget.maxLength;
    if (maxLength != null &&
        maxLength > 0 &&
        text.characters.length > maxLength) {
      return;
    }
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  void _startRecording() {
    if (_recording || !widget.enabled) return;
    HapticFeedback.mediumImpact();
    widget.onRecordStart?.call();
    setState(() {
      _recordWatch = Stopwatch()..start();
      _recordSlide.value = 0;
      _recordElapsed.value = Duration.zero;
    });
    _recordTicker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _recordElapsed.value = _recordWatch?.elapsed ?? Duration.zero;
    });
  }

  void _stopRecording({required bool cancelled}) {
    final watch = _recordWatch;
    if (watch == null) return;
    _recordTicker?.cancel();
    watch.stop();
    setState(() => _recordWatch = null);
    HapticFeedback.lightImpact();
    widget.onRecordEnd?.call(watch.elapsed, cancelled: cancelled);
  }

  void _onRecordMove(PointerMoveEvent event) {
    if (!_recording) return;
    final direction =
        Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;
    final slide =
        math.min(0.0, _recordSlide.value + event.delta.dx * direction);
    _recordSlide.value = slide;
    if (slide <= -_cancelDistance) _stopRecording(cancelled: true);
  }

  void _send() {
    if (!widget.enabled) return;
    final text = _controller.text.trim();
    if (text.isEmpty && !widget.allowEmptySend) return;
    HapticFeedback.lightImpact();
    widget.onSend(text);
    _controller.clear();
    _setTyping(false);
    _focusNode.requestFocus();
  }

  /// Wraps the selection in [before] and [after], or inserts both around
  /// the cursor. With [placeholder], selects it afterwards (for links).
  void _wrapSelection(String before, String after, {String? placeholder}) {
    final value = _controller.value;
    var selection = value.selection;
    if (!selection.isValid) {
      selection = TextSelection.collapsed(offset: value.text.length);
    }
    final selected = selection.textInside(value.text);
    final replacement = placeholder == null
        ? '$before$selected$after'
        : '[$selected]($placeholder)';
    final text = value.text.replaceRange(
      selection.start,
      selection.end,
      replacement,
    );
    final TextSelection next;
    if (placeholder != null) {
      final start = selection.start + selected.length + 3;
      next = TextSelection(
        baseOffset: start,
        extentOffset: start + placeholder.length,
      );
    } else if (selected.isEmpty) {
      next = TextSelection.collapsed(offset: selection.start + before.length);
    } else {
      next = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.start + replacement.length,
      );
    }
    _controller.value = TextEditingValue(text: text, selection: next);
  }

  void _format(_Format format) => switch (format) {
        _Format.bold => _wrapSelection('**', '**'),
        _Format.italic => _wrapSelection('_', '_'),
        _Format.strike => _wrapSelection('~~', '~~'),
        _Format.code => _wrapSelection('`', '`'),
        _Format.link => _wrapSelection('', '', placeholder: 'https://'),
      };

  _Format? _formatFor(KeyEvent event) {
    final keyboard = HardwareKeyboard.instance;
    final mac = defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (!(mac ? keyboard.isMetaPressed : keyboard.isControlPressed)) {
      return null;
    }
    final key = event.logicalKey;
    if (keyboard.isShiftPressed) {
      return key == LogicalKeyboardKey.keyX ? _Format.strike : null;
    }
    return switch (key) {
      LogicalKeyboardKey.keyB => _Format.bold,
      LogicalKeyboardKey.keyI => _Format.italic,
      LogicalKeyboardKey.keyE => _Format.code,
      LogicalKeyboardKey.keyK => _Format.link,
      _ => null,
    };
  }

  Widget _contextMenu(BuildContext context, EditableTextState editable) {
    final l10n = ChatLocalizations.of(context);
    final items = editable.contextMenuButtonItems;
    final hasSelection = !editable.textEditingValue.selection.isCollapsed;
    if (widget.enableFormatting && hasSelection) {
      ContextMenuButtonItem item(String label, _Format format) =>
          ContextMenuButtonItem(
            label: label,
            onPressed: () {
              ContextMenuController.removeAny();
              _format(format);
            },
          );
      // After Cut, Copy and Paste, so they stay on the first page of the
      // iOS menu.
      final at = items.length < 3 ? items.length : 3;
      items.insertAll(at, [
        item(l10n.bold, _Format.bold),
        item(l10n.italic, _Format.italic),
        item(l10n.strikethrough, _Format.strike),
        item(l10n.code, _Format.code),
        item(l10n.link, _Format.link),
      ]);
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editable.contextMenuAnchors,
      buttonItems: items,
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (widget.enableFormatting) {
      final format = _formatFor(event);
      if (format != null) {
        _format(format);
        return KeyEventResult.handled;
      }
    }
    if (key == LogicalKeyboardKey.escape && widget.onEscape != null) {
      widget.onEscape!();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp &&
        widget.onArrowUp != null &&
        _controller.text.isEmpty) {
      widget.onArrowUp!();
      return KeyEventResult.handled;
    }
    if (!_sendOnEnter) return KeyEventResult.ignored;
    final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter || HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    // Let input methods (for example Chinese or Japanese) confirm a
    // composition with Enter.
    if (_controller.value.composing.isValid) return KeyEventResult.ignored;
    _send();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final radius = BorderRadius.circular(24);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    );

    // Material (not ColoredBox) so the text field works even without a
    // Material ancestor, for example inside `material_ui` apps.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Material(
      color: theme.inputBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.leading != null) widget.leading!,
                Expanded(
                  child: _recording
                      ? _RecordingIndicator(
                          elapsed: _recordElapsed,
                          slide: _recordSlide,
                          cancelDistance: _cancelDistance,
                          color: theme.errorColor,
                          hintStyle: theme.inputHintStyle,
                          label: l10n.slideToCancel,
                        )
                      : Focus(
                          canRequestFocus: false,
                          skipTraversal: true,
                          onKeyEvent: _onKeyEvent,
                          child: TextField(
                            key: const Key('chatx_input_field'),
                            controller: _controller,
                            focusNode: _focusNode,
                            enabled: widget.enabled,
                            autofocus: widget.autofocus,
                            minLines: 1,
                            maxLines: widget.maxLines,
                            maxLength: widget.maxLength,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            textCapitalization: widget.textCapitalization,
                            style: theme.inputTextStyle,
                            contextMenuBuilder: _contextMenu,
                            contentInsertionConfiguration:
                                widget.onContentInserted == null
                                    ? null
                                    : ContentInsertionConfiguration(
                                        onContentInserted:
                                            widget.onContentInserted!,
                                      ),
                            decoration: InputDecoration(
                              prefixIcon: widget.showEmojiButton
                                  ? IconButton(
                                      key: const Key('chatx_emoji_button'),
                                      tooltip: _emojiOpen
                                          ? l10n.keyboard
                                          : l10n.emoji,
                                      icon: Icon(
                                        _emojiOpen
                                            ? Icons.keyboard_alt_outlined
                                            : Icons.emoji_emotions_outlined,
                                      ),
                                      onPressed: _toggleEmoji,
                                    )
                                  : null,
                              hintText: widget.hintText ?? l10n.inputHint,
                              hintStyle: theme.inputHintStyle,
                              filled: true,
                              fillColor: theme.inputFieldColor,
                              isDense: true,
                              counterText: '',
                              // Keeps the field a 48dp touch target at any font size.
                              constraints: const BoxConstraints(minHeight: 48),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              border: border,
                              enabledBorder: border,
                              disabledBorder: border,
                              focusedBorder: border,
                            ),
                          ),
                        ),
                ),
                if (widget.trailing != null) widget.trailing!,
                const SizedBox(width: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: _canSend,
                  builder: (context, canSend, _) {
                    final onStop = widget.onStop;
                    if (onStop != null) {
                      return _SendButton(
                        key: const Key('chatx_stop_button'),
                        enabled: true,
                        color: theme.sendButtonColor,
                        iconColor: theme.sendButtonIconColor,
                        label: l10n.stopGenerating,
                        icon: Icons.stop_rounded,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          onStop();
                        },
                      );
                    }
                    if (!canSend && widget.onRecordStart != null) {
                      return _RecordButton(
                        recording: _recording,
                        enabled: widget.enabled,
                        color: _recording
                            ? theme.errorColor
                            : theme.sendButtonColor,
                        iconColor: theme.sendButtonIconColor,
                        label: l10n.holdToRecord,
                        onStart: _startRecording,
                        onMove: _onRecordMove,
                        onEnd: () => _stopRecording(cancelled: false),
                      );
                    }
                    return _SendButton(
                      enabled: widget.enabled && canSend,
                      onLongPress: widget.onSchedule == null
                          ? null
                          : () {
                              final text = _controller.text.trim();
                              if (text.isEmpty) return;
                              HapticFeedback.mediumImpact();
                              widget.onSchedule!(text);
                            },
                      color: theme.sendButtonColor,
                      iconColor: theme.sendButtonIconColor,
                      label: l10n.sendButton,
                      icon: widget.sendIcon,
                      onPressed: _send,
                    );
                  },
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _emojiOpen
                ? ChatEmojiPicker(
                    onSelected: _insertEmoji,
                    stickerPacks: widget.stickerPacks,
                    onStickerSelected: widget.onSticker,
                    imageProviderBuilder: widget.imageProviderBuilder,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    super.key,
    this.onLongPress,
    required this.enabled,
    required this.color,
    required this.iconColor,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onLongPress;
  final bool enabled;
  final Color color;
  final Color iconColor;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 220);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: enabled ? 1 : 0.86,
        duration: duration,
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.45,
          duration: duration,
          child: Material(
            key: const Key('chatx_send_button'),
            color: color,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              onLongPress: enabled ? onLongPress : null,
              child: SizedBox.square(
                dimension: 48,
                child: AnimatedSwitcher(
                  duration: duration,
                  child: Icon(icon, key: ValueKey(icon), color: iconColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Microphone button: press and hold to record, release to send.
class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.recording,
    required this.enabled,
    required this.color,
    required this.iconColor,
    required this.label,
    required this.onStart,
    required this.onMove,
    required this.onEnd,
  });

  final bool recording;
  final bool enabled;
  final Color color;
  final Color iconColor;
  final String label;
  final VoidCallback onStart;
  final ValueChanged<PointerMoveEvent> onMove;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      // Screen readers cannot hold: a tap starts, a second tap sends.
      onTap: enabled ? (recording ? onEnd : onStart) : null,
      child: Listener(
        key: const Key('chatx_record_button'),
        onPointerDown: enabled ? (_) => onStart() : null,
        onPointerMove: onMove,
        onPointerUp: (_) => onEnd(),
        onPointerCancel: (_) => onEnd(),
        child: AnimatedScale(
          scale: recording ? 1.25 : 1,
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Material(
            color: color,
            shape: const CircleBorder(),
            child: SizedBox.square(
              dimension: 48,
              child: Icon(Icons.mic_rounded, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// Replaces the text field while recording: timer and "slide to cancel".
class _RecordingIndicator extends StatefulWidget {
  const _RecordingIndicator({
    required this.elapsed,
    required this.slide,
    required this.cancelDistance,
    required this.color,
    required this.hintStyle,
    required this.label,
  });

  final ValueListenable<Duration> elapsed;
  final ValueListenable<double> slide;
  final double cancelDistance;
  final Color color;
  final TextStyle hintStyle;
  final String label;

  @override
  State<_RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<_RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.value = 1;
    } else if (!_pulse.isAnimating) {
      unawaited(_pulse.repeat(reverse: true));
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('chatx_recording_indicator'),
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FadeTransition(
            opacity: _pulse,
            child: Icon(Icons.circle, size: 12, color: widget.color),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<Duration>(
            valueListenable: widget.elapsed,
            builder: (context, elapsed, _) => Text(
              '${elapsed.inMinutes}:'
              '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
              style: widget.hintStyle.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<double>(
            valueListenable: widget.slide,
            builder: (context, slide, child) => Opacity(
              opacity: (1 + slide / widget.cancelDistance).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(slide, 0),
                child: child,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chevron_left_rounded,
                  color: widget.hintStyle.color,
                ),
                Text(widget.label, style: widget.hintStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _Format { bold, italic, strike, code, link }
