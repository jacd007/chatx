part of '../chat_view.dart';

/// Banner above the input that shows the reply or edit in progress.
class _ComposerBanner extends StatelessWidget {
  const _ComposerBanner({
    required this.controller,
    required this.currentUser,
    this.textSanitizer,
  });

  final ChatController controller;
  final ChatUser currentUser;
  final String Function(String text)? textSanitizer;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: Listenable.merge(
          [controller.composer.replyingTo, controller.composer.editing]),
      builder: (context, _) {
        final editing = controller.composer.editing.value;
        final replying = controller.composer.replyingTo.value;
        final Widget content;
        if (editing != null) {
          content = _bannerContent(
            context,
            key: const Key('chatx_edit_banner'),
            cancelKey: const Key('chatx_cancel_edit'),
            icon: Icons.edit_outlined,
            title: ChatLocalizations.of(context).editingMessage,
            message: editing,
            onCancel: controller.composer.cancelEditing,
          );
        } else if (replying != null) {
          final l10n = ChatLocalizations.of(context);
          final name = replying.author.id == currentUser.id
              ? l10n.you
              : replying.author.displayName ?? l10n.someone;
          content = _bannerContent(
            context,
            key: const Key('chatx_reply_banner'),
            cancelKey: const Key('chatx_cancel_reply'),
            icon: Icons.reply_rounded,
            title: l10n.replyingTo(name),
            message: replying,
            onCancel: controller.composer.cancelReply,
          );
        } else {
          content = const SizedBox(width: double.infinity);
        }
        return AnimatedSize(
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomCenter,
          child: content,
        );
      },
    );
  }

  Widget _bannerContent(
    BuildContext context, {
    required Key key,
    required Key cancelKey,
    required IconData icon,
    required String title,
    required ChatMessage message,
    required VoidCallback onCancel,
  }) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final accent = theme.outgoingBubbleColor;
    return Semantics(
      key: key,
      liveRegion: true,
      container: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 4, 0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(width: 12),
            Container(width: 3, height: 36, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.userNameTextStyle.copyWith(color: accent),
                  ),
                  Text(
                    _messagePreview(message, l10n, sanitize: textSanitizer),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.systemMessageTextStyle,
                  ),
                ],
              ),
            ),
            IconButton(
              key: cancelKey,
              tooltip: l10n.cancel,
              icon: const Icon(Icons.close_rounded),
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
