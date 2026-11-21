import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../l10n/chat_localizations.dart';
import '../material.dart';
import '../theme/chat_theme.dart';

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

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  final ValueNotifier<bool> _canSend = ValueNotifier(false);
  Timer? _typingTimer;
  bool _isTyping = false;

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
              child: Focus(
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
              builder: (context, canSend, _) => _SendButton(
                enabled: widget.enabled && canSend,
                color: theme.sendButtonColor,
                iconColor: theme.sendButtonIconColor,
                label: l10n.sendButton,
                onPressed: _send,
              ),
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
    required this.onPressed,
  });

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
                child: Icon(Icons.arrow_upward_rounded, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
