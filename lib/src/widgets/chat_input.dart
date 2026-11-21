import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../l10n/chat_localizations.dart';
import '../material.dart';
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
    _controller.addListener(_onTextChanged);
    _canSend.value = _controller.text.trim().isNotEmpty;
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onTextChanged);
      _controller.addListener(_onTextChanged);
      _onTextChanged();
    }
  }

  @override
  void dispose() {
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
    _canSend.value = hasText;
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
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    widget.onSend(text);
    _controller.clear();
    _setTyping(false);
    _focusNode.requestFocus();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!_sendOnEnter || event is! KeyDownEvent) return KeyEventResult.ignored;
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
    return Material(
      color: theme.inputBackgroundColor,
      child: Padding(
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
                        decoration: InputDecoration(
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
                if (!canSend && widget.onRecordStart != null) {
                  return _RecordButton(
                    recording: _recording,
                    enabled: widget.enabled,
                    color:
                        _recording ? theme.errorColor : theme.sendButtonColor,
                    iconColor: theme.sendButtonIconColor,
                    label: l10n.holdToRecord,
                    onStart: _startRecording,
                    onMove: _onRecordMove,
                    onEnd: () => _stopRecording(cancelled: false),
                  );
                }
                return _SendButton(
                  enabled: widget.enabled && canSend,
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
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.enabled,
    required this.color,
    required this.iconColor,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
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
