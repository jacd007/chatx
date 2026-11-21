part of '../chat_view.dart';

/// A listenable that never changes, for messages that are not in the
/// controller (the root of a thread).
class _ConstListenable<T> implements ValueListenable<T> {
  const _ConstListenable(this.value);

  @override
  final T value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

/// "Forwarded from Ana" label at the top of a bubble.
class _ForwardedLabel extends StatelessWidget {
  const _ForwardedLabel({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color.withValues(alpha: 0.75),
          fontStyle: FontStyle.italic,
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shortcut_rounded, size: 14, color: style?.color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              ChatLocalizations.of(context).forwardedFrom(name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

/// Time left before a disappearing message is removed, for the footer.
class _ExpiryBadge extends StatefulWidget {
  const _ExpiryBadge({required this.expiresAt, required this.color});

  final DateTime expiresAt;
  final Color color;

  @override
  State<_ExpiryBadge> createState() => _ExpiryBadgeState();
}

class _ExpiryBadgeState extends State<_ExpiryBadge> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static String _compact(Duration left) {
    if (left.inDays > 0) return '${left.inDays}d';
    if (left.inHours > 0) return '${left.inHours}h';
    if (left.inMinutes > 0) return '${left.inMinutes}m';
    return '${math.max(0, left.inSeconds)}s';
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.expiresAt.difference(DateTime.now());
    final label = _compact(left);
    final l10n = ChatLocalizations.of(context);
    return Semantics(
      label: l10n.expiresIn(label),
      excludeSemantics: true,
      child: Row(
        key: const Key('chatx_expiry'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 12, color: widget.color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: widget.color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

/// Bot buttons under the text of a message.
class _MessageButtons extends StatelessWidget {
  const _MessageButtons({
    required this.state,
    required this.message,
    required this.textColor,
    required this.accent,
  });

  final _ChatViewState state;
  final TextMessage message;
  final Color textColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final onPressed = state.widget.onMessageButton;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, button) in message.buttons.indexed) ...[
            if (i > 0) const SizedBox(height: 6),
            _button(button, onPressed),
          ],
        ],
      ),
    );
  }

  Widget _button(
    ChatMessageButton button,
    void Function(ChatMessage, ChatMessageButton)? onPressed,
  ) {
    final primary = button.style == ChatButtonStyle.primary;
    final callback = onPressed == null
        ? null
        : () {
            HapticFeedback.selectionClick();
            onPressed(message, button);
          };
    final foreground = primary ? _onAccent(accent) : accent;
    return Material(
      key: Key('chatx_button_${message.id}_${button.id}'),
      color: primary ? accent : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: primary
            ? BorderSide.none
            : BorderSide(color: accent.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: callback,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                button.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Color _onAccent(Color color) =>
      color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

/// Suggested answers above the input, from the newest message.
class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.state});

  final _ChatViewState state;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final controller = view.controller;
    final messages = controller.messages;
    final newest = messages.isEmpty ? null : messages.last;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    Widget chips(ChatMessage? message) {
      if (message is! TextMessage ||
          message.quickReplies.isEmpty ||
          state._isOutgoing(message) ||
          state._editingMessage != null) {
        return const SizedBox(width: double.infinity);
      }
      final theme = ChatThemeData.of(context);
      final accent = theme.outgoingBubbleColor;
      return SizedBox(
        key: const Key('chatx_quick_replies'),
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          itemCount: message.quickReplies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final reply = message.quickReplies[i];
            return _Entrance(
              animate: !reduceMotion,
              alignment: AlignmentDirectional.bottomStart,
              child: Material(
                key: Key('chatx_quick_reply_$i'),
                color: accent.withValues(alpha: 0.08),
                shape: StadiumBorder(
                  side: BorderSide(color: accent.withValues(alpha: 0.5)),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    final onQuickReply = view.onQuickReply;
                    if (onQuickReply != null) {
                      onQuickReply(reply, message);
                    } else {
                      state._handleSend(reply.text);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Center(
                      child: Text(
                        reply.label,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return AnimatedSize(
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
      alignment: Alignment.bottomCenter,
      child: newest == null
          ? chips(null)
          : ValueListenableBuilder<ChatMessage>(
              valueListenable: controller.watch(newest.id),
              builder: (context, message, _) => chips(message),
            ),
    );
  }
}

/// "3 replies" with participant avatars under a message with a thread.
class _ThreadSummaryRow extends StatelessWidget {
  const _ThreadSummaryRow({
    required this.message,
    required this.summary,
    required this.onTap,
  });

  final ChatMessage message;
  final ChatThreadSummary summary;
  final ValueChanged<ChatMessage>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final accent = theme.userNameTextStyle.color ?? theme.outgoingBubbleColor;
    final participants = summary.participants.take(3).toList();
    final last = summary.lastReplyAt;
    final when = last == null ? null : ChatHeader.relativeTime(context, last);
    return Semantics(
      button: onTap != null,
      child: InkWell(
        key: Key('chatx_thread_${message.id}'),
        onTap: onTap == null ? null : () => onTap!(message),
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (participants.isNotEmpty) ...[
                  SizedBox(
                    width: 20.0 + (participants.length - 1) * 12,
                    height: 20,
                    child: Stack(
                      children: [
                        for (final (i, user) in participants.indexed)
                          PositionedDirectional(
                            start: i * 12.0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.backgroundColor,
                                  width: 1.5,
                                ),
                              ),
                              child: ChatAvatar(user: user, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  l10n.threadReplies(summary.replyCount),
                  style: theme.userNameTextStyle.copyWith(color: accent),
                ),
                if (when != null)
                  Text(' · $when', style: theme.systemMessageTextStyle),
                Icon(Icons.chevron_right_rounded, size: 18, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small avatars of who read the newest outgoing message.
class _SeenBy extends StatelessWidget {
  const _SeenBy({required this.receipts});

  final List<ChatReadReceipt> receipts;

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final shown = receipts.take(4).toList();
    final extra = receipts.length - shown.length;
    return Semantics(
      label: l10n.seenBy([
        for (final r in receipts) r.user.name ?? l10n.someone,
      ]),
      excludeSemantics: true,
      child: Padding(
        key: const Key('chatx_seen_by'),
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final receipt in shown)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 2),
                child: ChatAvatar(user: receipt.user, size: 16),
              ),
            if (extra > 0)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4),
                child: Text('+$extra', style: theme.systemMessageTextStyle),
              ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with delivery details and who read a message.
Future<void> _showMessageInfo(
  BuildContext context,
  ChatMessage message,
  ChatLocalizations l10n,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
    ),
    builder: (sheetContext) {
      final textTheme = Theme.of(sheetContext).textTheme;
      return SafeArea(
        child: ListView(
          key: const Key('chatx_message_info'),
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(l10n.messageInfo, style: textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                _messagePreview(message, l10n),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(l10n.readBy, style: textTheme.titleSmall),
            ),
            for (final receipt in message.receipts)
              ListTile(
                leading: ChatAvatar(user: receipt.user, size: 36),
                title: Text(receipt.user.name ?? l10n.someone),
                trailing: Text(
                  ChatHeader.relativeTime(sheetContext, receipt.readAt),
                  style: textTheme.bodySmall,
                ),
              ),
          ],
        ),
      );
    },
  );
}
