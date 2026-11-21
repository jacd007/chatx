import 'package:flutter/services.dart';

import '../l10n/chat_localizations.dart';
import '../material.dart';
import '../models/chat_message.dart';
import '../theme/chat_theme.dart';
import 'emoji_data.dart';

/// Emoji keyboard with categories, search and recently used emoji.
///
/// `ChatInput` shows it when the user taps the emoji button, and the
/// reaction menu opens it from its "+" button. You can also place it
/// anywhere:
///
/// ```dart
/// ChatEmojiPicker(onSelected: (emoji) => insert(emoji))
/// ```
class ChatEmojiPicker extends StatefulWidget {
  /// Creates an emoji picker.
  const ChatEmojiPicker({
    super.key,
    required this.onSelected,
    this.height = 300,
    this.showSearch = true,
    this.stickerPacks = const [],
    this.onStickerSelected,
    this.imageProviderBuilder,
  });

  /// Called with the chosen emoji.
  final ValueChanged<String> onSelected;

  /// Total height of the picker.
  final double height;

  /// Whether to show the search field.
  final bool showSearch;

  /// Sticker packs shown as extra tabs after the emoji.
  final List<ChatStickerPack> stickerPacks;

  /// Called when the user picks a sticker. Sticker tabs are hidden when
  /// `null`.
  final ValueChanged<ChatSticker>? onStickerSelected;

  /// Loads sticker images. Defaults to [NetworkImage].
  final ImageProvider Function(String uri)? imageProviderBuilder;

  /// Recently used emoji, most recent first, shared by every picker while
  /// the app runs. Persist and restore it yourself if you want it to
  /// survive restarts.
  static final List<String> recent = [];

  static const int _maxRecent = 32;

  @override
  State<ChatEmojiPicker> createState() => _ChatEmojiPickerState();
}

class _ChatEmojiPickerState extends State<ChatEmojiPicker>
    with SingleTickerProviderStateMixin {
  static const _icons = [
    Icons.access_time_rounded,
    Icons.emoji_emotions_outlined,
    Icons.emoji_people_rounded,
    Icons.pets_rounded,
    Icons.fastfood_outlined,
    Icons.sports_soccer_rounded,
    Icons.flight_rounded,
    Icons.lightbulb_outline_rounded,
    Icons.favorite_border_rounded,
    Icons.flag_outlined,
  ];

  late TabController _tabs = _createTabs();

  List<ChatStickerPack> get _packs => widget.onStickerSelected == null
      ? const []
      : widget.stickerPacks.where((p) => p.stickers.isNotEmpty).toList();

  TabController _createTabs() => TabController(
        length: emojiCategoryIds.length + 1 + _packs.length,
        vsync: this,
        // Open on "recent" only when there is something in it.
        initialIndex: ChatEmojiPicker.recent.isEmpty ? 1 : 0,
      );

  @override
  void didUpdateWidget(ChatEmojiPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tabs.length != emojiCategoryIds.length + 1 + _packs.length) {
      _tabs.dispose();
      _tabs = _createTabs();
    }
  }

  ImageProvider _image(String uri) =>
      widget.imageProviderBuilder?.call(uri) ?? NetworkImage(uri);

  Widget _stickerGrid(ChatStickerPack pack) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 88,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: pack.stickers.length,
      itemBuilder: (context, i) {
        final sticker = pack.stickers[i];
        final pixels = (88 * MediaQuery.devicePixelRatioOf(context)).round();
        return Semantics(
          button: true,
          label: sticker.label ?? pack.name,
          excludeSemantics: true,
          child: InkWell(
            key: Key('chatx_sticker_${sticker.id}'),
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onStickerSelected?.call(sticker);
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image(
                image: ResizeImage.resizeIfNeeded(
                  pixels,
                  null,
                  _image(sticker.uri),
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  void _select(String emoji) {
    HapticFeedback.selectionClick();
    final recent = ChatEmojiPicker.recent
      ..remove(emoji)
      ..insert(0, emoji);
    if (recent.length > ChatEmojiPicker._maxRecent) recent.removeLast();
    widget.onSelected(emoji);
  }

  List<(String, String)> _matches(String query) {
    final needle = query.trim().toLowerCase();
    return [
      for (final list in emojiCatalog.values)
        for (final entry in list)
          if (entry.$2.split(' ').any((word) => word.startsWith(needle))) entry,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final names = l10n.emojiCategories;

    Widget grid(List<(String, String)> entries) {
      if (entries.isEmpty) {
        return Center(
          child: Text(
            l10n.searchNoResults,
            style: theme.systemMessageTextStyle,
          ),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 48,
        ),
        itemCount: entries.length,
        itemBuilder: (context, i) {
          final (emoji, keywords) = entries[i];
          return Semantics(
            button: true,
            label: keywords.split(' ').first,
            excludeSemantics: true,
            child: InkResponse(
              key: Key('chatx_emoji_$emoji'),
              radius: 24,
              onTap: () => _select(emoji),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
          );
        },
      );
    }

    final searching = _query.trim().isNotEmpty;
    return Material(
      key: const Key('chatx_emoji_picker'),
      color: theme.inputBackgroundColor,
      child: SizedBox(
        height: widget.height,
        child: Column(
          children: [
            if (widget.showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: TextField(
                  key: const Key('chatx_emoji_search'),
                  controller: _search,
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchEmoji,
                    prefixIcon: const Icon(Icons.search_rounded),
                    isDense: true,
                    filled: true,
                    fillColor: theme.inputFieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            if (!searching)
              TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: scheme.outlineVariant,
                tabs: [
                  for (var i = 0; i < _icons.length; i++)
                    Tab(
                      height: 40,
                      child: Tooltip(
                        message: i < names.length ? names[i] : '',
                        child: Icon(_icons[i], size: 20),
                      ),
                    ),
                  for (final pack in _packs)
                    Tab(
                      key: Key('chatx_sticker_pack_${pack.id}'),
                      height: 40,
                      child: Tooltip(
                        message: pack.name,
                        child: Image(
                          image: _image(pack.stickers.first.uri),
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                ],
              ),
            Expanded(
              child: searching
                  ? grid(_matches(_query))
                  : TabBarView(
                      controller: _tabs,
                      children: [
                        grid([
                          for (final emoji in ChatEmojiPicker.recent)
                            (emoji, emoji),
                        ]),
                        for (final id in emojiCategoryIds)
                          grid(emojiCatalog[id]!),
                        for (final pack in _packs) _stickerGrid(pack),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
