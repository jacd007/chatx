import 'dart:async';

import '../controller/chat_search_controller.dart';
import '../l10n/chat_localizations.dart';
import '../material.dart';

/// Search field with a result counter and buttons to move between results.
///
/// Designed for `AppBar.title`. Typing searches after a short pause.
class ChatSearchBar extends StatefulWidget {
  /// Creates a search bar.
  const ChatSearchBar({
    super.key,
    required this.controller,
    this.autofocus = true,
    this.onClose,
    this.debounce = const Duration(milliseconds: 250),
  });

  /// The search to drive.
  final ChatSearchController controller;

  /// Whether the field takes focus when shown.
  final bool autofocus;

  /// Called by the close button. When `null`, no close button is shown.
  final VoidCallback? onClose;

  /// Delay between the last keystroke and the search.
  final Duration debounce;

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar> {
  late final TextEditingController _text =
      TextEditingController(text: widget.controller.query);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () => widget.controller.search(value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final search = widget.controller;
        final total = search.results.length;
        final String counter;
        if (!search.isActive) {
          counter = '';
        } else if (total == 0) {
          counter = l10n.searchNoResults;
        } else {
          counter = '${search.currentIndex + 1}/$total';
        }
        return Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('chatx_search_field'),
                controller: _text,
                autofocus: widget.autofocus,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                onSubmitted: (_) => search.next(),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            Semantics(
              liveRegion: true,
              child: Text(
                counter,
                key: const Key('chatx_search_counter'),
                style: theme.textTheme.labelMedium,
              ),
            ),
            IconButton(
              key: const Key('chatx_search_older'),
              tooltip: l10n.searchPrevious,
              icon: const Icon(Icons.keyboard_arrow_up_rounded),
              onPressed: search.currentIndex < total - 1 ? search.next : null,
            ),
            IconButton(
              key: const Key('chatx_search_newer'),
              tooltip: l10n.searchNext,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              onPressed: search.currentIndex > 0 ? search.previous : null,
            ),
            if (widget.onClose != null)
              IconButton(
                key: const Key('chatx_search_close'),
                tooltip: l10n.close,
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  search.clear();
                  widget.onClose!();
                },
              ),
          ],
        );
      },
    );
  }
}
