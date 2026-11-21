import '../l10n/chat_localizations.dart';
import '../material.dart';
import '../models/message_status.dart';
import '../theme/chat_theme.dart';

/// Small icon that represents a [MessageStatus].
///
/// Changes between states cross-fade. The icon carries an accessibility
/// label from [ChatLocalizations].
class MessageStatusIcon extends StatelessWidget {
  /// Creates a status icon.
  const MessageStatusIcon({
    super.key,
    required this.status,
    this.color,
    this.size = 15,
  });

  /// The status to show.
  final MessageStatus status;

  /// Color of every state except `read` and `failed`. Defaults to the
  /// ambient icon color.
  final Color? color;

  /// Icon size.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final base = color ?? IconTheme.of(context).color;
    final (icon, iconColor, label) = switch (status) {
      MessageStatus.queued => (
          Icons.cloud_off_rounded,
          base,
          l10n.statusQueued
        ),
      MessageStatus.sending => (
          Icons.schedule_rounded,
          base,
          l10n.statusSending
        ),
      MessageStatus.sent => (Icons.done_rounded, base, l10n.statusSent),
      MessageStatus.delivered => (
          Icons.done_all_rounded,
          base,
          l10n.statusDelivered
        ),
      MessageStatus.read => (
          Icons.done_all_rounded,
          theme.readStatusColor,
          l10n.statusRead
        ),
      MessageStatus.failed => (
          Icons.error_outline_rounded,
          theme.errorColor,
          l10n.statusFailed
        ),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: Icon(
        icon,
        key: ValueKey(status),
        size: size,
        color: iconColor,
        semanticLabel: label,
      ),
    );
  }
}
