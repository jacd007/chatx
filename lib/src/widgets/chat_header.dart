import 'dart:async';

import '../controller/chat_controller.dart';
import '../l10n/chat_localizations.dart';
import '../material.dart';
import '../models/chat_user.dart';
import 'chat_avatar.dart';
import 'typing_indicator.dart';

/// Title for an `AppBar` with avatar, name and live status.
///
/// The subtitle shows, in order of priority: who is typing (from
/// [controller]), "online", "last seen …", or the member count of a group.
///
/// ```dart
/// AppBar(
///   title: ChatHeader(
///     user: ana,
///     isOnline: presence.isOnline,
///     lastSeenAt: presence.lastSeen,
///     controller: controller,
///   ),
/// )
/// ```
class ChatHeader extends StatefulWidget {
  /// Creates a chat header.
  const ChatHeader({
    super.key,
    required this.user,
    this.title,
    this.subtitle,
    this.isOnline = false,
    this.lastSeenAt,
    this.memberCount,
    this.controller,
    this.onTap,
  });

  /// The other person, or the group (its name and avatar are shown).
  final ChatUser user;

  /// Title. Defaults to [ChatUser.name].
  final String? title;

  /// Fixed subtitle. Overrides presence and member count, but not typing.
  final String? subtitle;

  /// Shows a green dot and "online".
  final bool isOnline;

  /// When the user was last active. Shown as "last seen 5 min ago" when not
  /// online.
  final DateTime? lastSeenAt;

  /// Number of members of a group chat.
  final int? memberCount;

  /// Source of typing users. When set, typing replaces the subtitle.
  final ChatController? controller;

  /// Called when the header is tapped, for example to open a profile.
  final VoidCallback? onTap;

  /// Formats [time] relative to [now]: "just now", "5 min ago", "today at
  /// 10:42", "yesterday at 18:03" or a date.
  static String relativeTime(
    BuildContext context,
    DateTime time, {
    DateTime? now,
  }) {
    final l10n = ChatLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final current = now ?? DateTime.now();
    final local = time.toLocal();
    final difference = current.difference(local);
    if (difference.inMinutes < 1) return l10n.justNow;
    if (difference.inMinutes < 60) return l10n.minutesAgo(difference.inMinutes);
    final clock = material.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final today = DateUtils.dateOnly(current);
    final day = DateUtils.dateOnly(local);
    if (day == today) return l10n.todayAt(clock);
    if (day == DateTime(today.year, today.month, today.day - 1)) {
      return l10n.yesterdayAt(clock);
    }
    return material.formatMediumDate(local);
  }

  @override
  State<ChatHeader> createState() => _ChatHeaderState();
}

class _ChatHeaderState extends State<ChatHeader> {
  // Refreshes "last seen 5 min ago" while the header is visible.
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && !widget.isOnline && widget.lastSeenAt != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String? _status(ChatLocalizations l10n) {
    if (widget.subtitle != null) return widget.subtitle;
    if (widget.isOnline) return l10n.online;
    final lastSeen = widget.lastSeenAt;
    if (lastSeen != null) {
      return l10n.lastSeen(ChatHeader.relativeTime(context, lastSeen));
    }
    final members = widget.memberCount;
    if (members != null) return l10n.members(members);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = widget.title ?? widget.user.name ?? widget.user.id;
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    Widget subtitle(List<ChatUser> typing) {
      if (typing.isNotEmpty) {
        final names = [for (final u in typing) u.name ?? l10n.someone];
        // In one-to-one chats, "typing…" is enough.
        final label = widget.memberCount == null && typing.length == 1
            ? l10n.typingShort
            : l10n.typing(names);
        return Row(
          key: const ValueKey('typing'),
          mainAxisSize: MainAxisSize.min,
          children: [
            TypingDots(color: scheme.primary, dotSize: 4),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subtitleStyle?.copyWith(color: scheme.primary),
              ),
            ),
          ],
        );
      }
      final status = _status(l10n);
      return status == null
          ? const SizedBox.shrink(key: ValueKey('none'))
          : Text(
              status,
              key: ValueKey(status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: widget.isOnline
                  ? subtitleStyle?.copyWith(color: scheme.primary)
                  : subtitleStyle,
            );
    }

    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        ChatAvatar(user: widget.user, size: 40),
        PositionedDirectional(
          end: -1,
          bottom: -1,
          child: AnimatedScale(
            scale: widget.isOnline ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFF2EB67D),
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 2),
              ),
            ),
          ),
        ),
      ],
    );

    final controller = widget.controller;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: controller == null
                    ? subtitle(const [])
                    : ValueListenableBuilder<List<ChatUser>>(
                        valueListenable: controller.typingUsers,
                        builder: (context, typing, _) => subtitle(typing),
                      ),
              ),
            ],
          ),
        ),
      ],
    );

    return Semantics(
      key: const Key('chatx_header'),
      button: widget.onTap != null,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      ),
    );
  }
}
