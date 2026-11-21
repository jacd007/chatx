import 'package:flutter/foundation.dart';

import 'chat_controller.dart';

/// Searches a conversation and moves between the results.
///
/// Pass it to `ChatView.searchController` to highlight matches, and to a
/// [ChatSearchController]-driven UI such as `ChatSearchBar`:
///
/// ```dart
/// final search = ChatSearchController(chatController: controller);
///
/// AppBar(title: ChatSearchBar(controller: search));
/// ChatView(controller: controller, searchController: search, ...);
/// ```
///
/// Results are ordered newest first. [next] moves to older results and
/// [previous] to newer ones. Each move scrolls the chat to the result.
class ChatSearchController extends ChangeNotifier {
  /// Creates a search controller for [chatController].
  ChatSearchController({required this.chatController}) {
    chatController
      ..addListener(_onMessagesChanged)
      ..contentChanges.addListener(_onMessagesChanged);
  }

  /// The conversation being searched.
  final ChatController chatController;

  String _query = '';
  List<String> _results = const [];
  int _index = -1;

  /// The current search text.
  String get query => _query;

  /// IDs of matching messages, newest first.
  List<String> get results => _results;

  /// Position of the current result in [results], or -1 when there is none.
  int get currentIndex => _index;

  /// ID of the current result, or `null`.
  String? get currentId => _index < 0 ? null : _results[_index];

  /// Whether [query] is not empty.
  bool get isActive => _query.trim().isNotEmpty;

  /// Searches for [query] and jumps to the newest result.
  void search(String query) {
    _query = query;
    _results = chatController.search(query);
    _index = _results.isEmpty ? -1 : 0;
    notifyListeners();
    _reveal();
  }

  /// Moves to the next older result, if any.
  void next() {
    if (_index < 0 || _index >= _results.length - 1) return;
    _index++;
    notifyListeners();
    _reveal();
  }

  /// Moves to the next newer result, if any.
  void previous() {
    if (_index <= 0) return;
    _index--;
    notifyListeners();
    _reveal();
  }

  /// Clears the query and the results.
  void clear() {
    if (_query.isEmpty && _results.isEmpty) return;
    _query = '';
    _results = const [];
    _index = -1;
    notifyListeners();
  }

  void _reveal() {
    final id = currentId;
    if (id != null) chatController.scrollToMessage(id);
  }

  // Keeps results in sync with new, edited, streamed or deleted messages, staying on
  // the same message when it still matches.
  void _onMessagesChanged() {
    if (!isActive) return;
    final current = currentId;
    final results = chatController.search(_query);
    // Streamed text changes often: only notify when the results did.
    if (listEquals(results, _results)) return;
    _results = results;
    final index = current == null ? -1 : _results.indexOf(current);
    _index = index != -1 ? index : (_results.isEmpty ? -1 : 0);
    notifyListeners();
  }

  @override
  void dispose() {
    chatController
      ..removeListener(_onMessagesChanged)
      ..contentChanges.removeListener(_onMessagesChanged);
    super.dispose();
  }
}
