import '../chat_scope.dart';
import '../controller/chat_controller.dart';
import '../l10n/chat_localizations.dart';
import '../markdown/chat_link_policy.dart';
import '../material.dart';
import '../models/chat_message.dart';
import '../theme/chat_theme.dart';
import '../utils/display_name.dart';

/// Every photo, video, file and link shared in a conversation, in three
/// tabs. Newest first.
///
/// ```dart
/// IconButton(
///   icon: const Icon(Icons.perm_media_outlined),
///   onPressed: () => ChatMediaGallery.show(context, controller: controller),
/// )
/// ```
class ChatMediaGallery extends StatelessWidget {
  /// Creates a media gallery.
  const ChatMediaGallery({
    super.key,
    required this.controller,
    this.onOpen,
    this.imageProviderBuilder,
    this.linkPolicy = const ChatLinkPolicy(),
  });

  /// The conversation.
  final ChatController controller;

  /// Called when an item is tapped. Defaults to
  /// `ChatController.scrollToMessage`.
  final ValueChanged<ChatMessage>? onOpen;

  /// Loads images. Defaults to [NetworkImage].
  final ImageProvider Function(String uri)? imageProviderBuilder;

  /// Decides which links are listed.
  final ChatLinkPolicy linkPolicy;

  /// Shows the gallery in a tall bottom sheet. Tapping an item closes the
  /// sheet and calls [onOpen].
  static Future<void> show(
    BuildContext context, {
    required ChatController controller,
    ValueChanged<ChatMessage>? onOpen,
    ImageProvider Function(String uri)? imageProviderBuilder,
    ChatLinkPolicy linkPolicy = const ChatLinkPolicy(),
  }) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => ChatScope(
        theme: theme,
        localizations: l10n,
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.85,
          child: ChatMediaGallery(
            controller: controller,
            imageProviderBuilder: imageProviderBuilder,
            linkPolicy: linkPolicy,
            onOpen: (message) {
              Navigator.of(sheetContext).pop();
              (onOpen ?? (m) => controller.scrollToMessage(m.id))(message);
            },
          ),
        ),
      ),
    );
  }

  static final RegExp _url = RegExp(r'''(https?://|www\.)[^\s<>()\[\]'"]+''');

  ImageProvider _image(String uri) =>
      imageProviderBuilder?.call(uri) ?? NetworkImage(uri);

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final material = MaterialLocalizations.of(context);
    final open = onOpen ?? (ChatMessage m) => controller.scrollToMessage(m.id);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final messages = controller.messages.reversed
            .where((m) => m.deletedAt == null)
            .toList();
        final media = <(ChatMessage, String?, bool)>[
          for (final m in messages)
            if (m is ImageMessage)
              for (final image in m.images) (m, image.uri, false)
            else if (m is VideoMessage)
              (m, m.thumbnailUri, true),
        ];
        final files = [
          for (final m in messages)
            if (m is FileMessage) m,
        ];
        final links = <(ChatMessage, Uri, String?)>[];
        final seen = <String>{};
        for (final m in messages) {
          if (m is! TextMessage) continue;
          final preview = m.linkPreview;
          if (preview != null) {
            final uri = linkPolicy.resolve(preview.url);
            if (uri != null && seen.add(uri.toString())) {
              links.add((m, uri, preview.title));
            }
          }
          for (final match in _url.allMatches(m.text)) {
            final uri = linkPolicy.resolve(match.group(0)!);
            if (uri != null && seen.add(uri.toString())) {
              links.add((m, uri, null));
            }
          }
        }

        Widget empty() => Center(
              child: Text(
                l10n.galleryEmpty,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            );

        final mediaTab = media.isEmpty
            ? empty()
            : GridView.builder(
                key: const Key('chatx_gallery_media'),
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 130,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: media.length,
                itemBuilder: (context, index) {
                  final (message, uri, video) = media[index];
                  final pixels =
                      (130 * MediaQuery.devicePixelRatioOf(context)).round();
                  return Semantics(
                    button: true,
                    label: video ? l10n.video : l10n.photo,
                    excludeSemantics: true,
                    child: InkWell(
                      key: Key('chatx_gallery_item_$index'),
                      onTap: () => open(message),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(color: scheme.surfaceContainerHighest),
                          if (uri != null)
                            Image(
                              image: ResizeImage.resizeIfNeeded(
                                pixels,
                                null,
                                _image(uri),
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, __) =>
                                  const SizedBox.shrink(),
                            ),
                          if (video)
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );

        final filesTab = files.isEmpty
            ? empty()
            : ListView.builder(
                key: const Key('chatx_gallery_files'),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return ListTile(
                    onTap: () => open(file),
                    leading: CircleAvatar(
                      backgroundColor: scheme.secondaryContainer,
                      foregroundColor: scheme.onSecondaryContainer,
                      child: const Icon(Icons.insert_drive_file_outlined),
                    ),
                    title: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${file.author.displayName ?? ''} · '
                      '${material.formatMediumDate(file.createdAt.toLocal())}',
                    ),
                  );
                },
              );

        final linksTab = links.isEmpty
            ? empty()
            : ListView.builder(
                key: const Key('chatx_gallery_links'),
                itemCount: links.length,
                itemBuilder: (context, index) {
                  final (message, uri, title) = links[index];
                  return ListTile(
                    onTap: () => open(message),
                    leading: CircleAvatar(
                      backgroundColor: scheme.tertiaryContainer,
                      foregroundColor: scheme.onTertiaryContainer,
                      child: const Icon(Icons.link_rounded),
                    ),
                    title: Text(
                      title ?? uri.host,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      uri.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              );

        return DefaultTabController(
          length: 3,
          child: Column(
            key: const Key('chatx_media_gallery'),
            children: [
              TabBar(
                tabs: [
                  Tab(text: '${l10n.media} · ${media.length}'),
                  Tab(text: '${l10n.files} · ${files.length}'),
                  Tab(text: '${l10n.links} · ${links.length}'),
                ],
              ),
              Expanded(
                child: TabBarView(children: [mediaTab, filesTab, linksTab]),
              ),
            ],
          ),
        );
      },
    );
  }
}
