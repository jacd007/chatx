import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../markdown/markdown_parser.dart';
import '../models/chat_message.dart';
import '../models/chat_reaction.dart';
import '../models/chat_user.dart';
import '../models/message_status.dart';

/// Holds the messages and typing state of one conversation.
///
/// chatx never talks to a backend. Your code feeds the controller from any
/// source (REST, WebSocket, Firebase, Supabase, a local database...) and the
/// `ChatView` reacts.
///
/// Messages are kept sorted by [ChatMessage.createdAt], oldest first.
/// Messages with the same timestamp keep their insertion order.
///
/// ## Two kinds of notifications
///
/// To keep large conversations smooth, the controller separates changes into:
///
/// * **Structural changes** (insert, remove, reorder, replace all). These call
///   the listeners registered with [addListener] and rebuild the list.
/// * **Content changes** of a single message (new status, edited or streamed
///   text). These only notify the listenable returned by [watch] for that
///   message, so only its bubble rebuilds.
///
/// Call [dispose] when the conversation is no longer shown.
class ChatController extends ChangeNotifier {
  /// Creates a controller, optionally pre-filled with [messages].
  ///
  /// Throws an [ArgumentError] if two messages share an ID.
  ChatController({
    Iterable<ChatMessage> messages = const [],
    String initialDraft = '',
    this.removeExpiredMessages = true,
  }) : _draft = ValueNotifier<String>(initialDraft) {
    _addAllSorted(messages);
    _messages.forEach(_scheduleExpiry);
  }

  /// Whether messages are removed automatically when their
  /// [ChatMessage.expiresAt] passes.
  final bool removeExpiredMessages;

  final ValueNotifier<String> _draft;
  final Map<String, Timer> _expiryTimers = {};
  final Set<String> _ids = {};
  int _structureRevision = 0;

  /// Changes whenever messages are inserted anywhere but at the end,
  /// removed or reordered. Appending newer messages keeps it unchanged.
  ///
  /// `ChatView` uses it to update long conversations incrementally.
  int get structureRevision => _structureRevision;

  final List<ChatMessage> _messages = [];
  late final UnmodifiableListView<ChatMessage> _messagesView =
      UnmodifiableListView(_messages);
  final Map<String, ValueNotifier<ChatMessage>> _watchers = {};
  final ValueNotifier<List<ChatUser>> _typingUsers =
      ValueNotifier<List<ChatUser>>(const []);
  final ValueNotifier<ChatMessage?> _replyingTo = ValueNotifier(null);
  final ValueNotifier<ChatMessage?> _editing = ValueNotifier(null);
  final ValueNotifier<List<String>> _pinnedIds =
      ValueNotifier<List<String>>(const []);
  final ValueNotifier<Set<String>> _selectedIds =
      ValueNotifier<Set<String>>(const {});
  final StreamController<ChatScrollRequest> _scrollRequests =
      StreamController<ChatScrollRequest>.broadcast();

  /// All messages, oldest first. The list is a read-only live view.
  List<ChatMessage> get messages => _messagesView;

  /// Whether the conversation has no messages.
  bool get isEmpty => _messages.isEmpty;

  /// Number of messages in the conversation.
  int get length => _messages.length;

  /// Users that are currently typing, in the order they started.
  ValueListenable<List<ChatUser>> get typingUsers => _typingUsers;

  /// The message the user is replying to, or `null`.
  ///
  /// While set, `ChatView` shows a reply banner above the input and passes the
  /// message to `onSendMessage`. Set it with [startReply].
  ValueListenable<ChatMessage?> get replyingTo => _replyingTo;

  /// The message the user is editing, or `null`.
  ///
  /// While set, `ChatView` fills the input with the message text and sends
  /// the result to `onEditMessage`. Set it with [startEditing].
  ValueListenable<ChatMessage?> get editing => _editing;

  /// IDs of pinned messages, oldest pin first. `ChatView` shows a banner for
  /// them at the top of the list.
  ValueListenable<List<String>> get pinnedIds => _pinnedIds;

  /// IDs of the messages selected in selection mode.
  ValueListenable<Set<String>> get selectedIds => _selectedIds;

  /// Whether selection mode is active (at least one message selected).
  bool get isSelecting => _selectedIds.value.isNotEmpty;

  /// Requests from [scrollToMessage]. `ChatView` listens to this stream.
  Stream<ChatScrollRequest> get scrollRequests => _scrollRequests.stream;

  /// Unsent text of the input. `ChatView` restores it when it is built
  /// again with this controller, so keeping the controller alive keeps the
  /// draft. Listen to it to persist drafts across app restarts.
  ValueListenable<String> get draft => _draft;

  /// Replaces the draft. `ChatView` calls this as the user types.
  void setDraft(String text) => _draft.value = text;

  /// Returns the message with [id], or `null` if there is none.
  ChatMessage? messageById(String id) {
    final index = _indexOf(id);
    return index == -1 ? null : _messages[index];
  }

  /// Whether a message with [id] exists.
  bool contains(String id) => _indexOf(id) != -1;

  /// Adds [message] at the position given by its [ChatMessage.createdAt].
  ///
  /// Throws an [ArgumentError] if a message with the same ID already exists.
  /// Use [upsert] when the message may already be present, for example when
  /// your backend echoes back a message you inserted optimistically.
  void insert(ChatMessage message) {
    _ensureNew(message.id);
    _insertSorted(message);
    _scheduleExpiry(message);
    notifyListeners();
  }

  /// Adds several messages at once, for example a page of older history.
  ///
  /// Notifies listeners a single time. Throws an [ArgumentError] if any ID is
  /// already present or repeated.
  void insertAll(Iterable<ChatMessage> messages) {
    final list = messages.toList(growable: false);
    if (list.isEmpty) return;
    _addAllSorted(list);
    list.forEach(_scheduleExpiry);
    notifyListeners();
  }

  /// Inserts [message], or replaces the existing message with the same ID.
  ///
  /// Returns `true` when the message was inserted, `false` when it replaced
  /// an existing one.
  bool upsert(ChatMessage message) {
    if (update(message)) return false;
    _insertSorted(message);
    _scheduleExpiry(message);
    notifyListeners();
    return true;
  }

  /// Replaces the message that has the same ID as [message].
  ///
  /// Returns `false` and does nothing if no such message exists.
  ///
  /// When only the content changes (text, status, metadata), only the
  /// bubble of this message rebuilds. When the author, the type or
  /// [ChatMessage.createdAt] changes, the list is rebuilt and reordered.
  bool update(ChatMessage message) {
    final index = _indexOf(message.id);
    if (index == -1) return false;
    final old = _messages[index];
    if (old == message) return true;

    final structural = old.runtimeType != message.runtimeType ||
        old.author.id != message.author.id ||
        old.createdAt != message.createdAt;
    if (structural) {
      _messages.removeAt(index);
      _ids.remove(message.id);
      _insertSorted(message);
      _structureRevision++;
    } else {
      _messages[index] = message;
    }
    _watchers[message.id]?.value = message;
    if (old.expiresAt != message.expiresAt) _scheduleExpiry(message);
    if (structural) notifyListeners();
    return true;
  }

  /// Sets the [MessageStatus] of the message with [id].
  ///
  /// Returns `false` if the message does not exist.
  bool updateStatus(String id, MessageStatus? status) {
    final message = messageById(id);
    if (message == null) return false;
    return update(message.withStatus(status));
  }

  /// Appends [delta] to the text of the [TextMessage] with [id].
  ///
  /// Designed for streamed responses: only that bubble rebuilds. Returns
  /// `false` if the message does not exist or is not a [TextMessage].
  bool appendText(String id, String delta) {
    final message = messageById(id);
    if (message is! TextMessage) return false;
    if (delta.isEmpty) return true;
    return update(message.copyWith(text: message.text + delta));
  }

  /// Marks the streamed [TextMessage] with [id] as complete.
  ///
  /// Optionally sets its [status] and replaces its whole [text], which is
  /// useful when the server sends a final, normalized version.
  bool completeStream(String id, {MessageStatus? status, String? text}) {
    final message = messageById(id);
    if (message is! TextMessage) return false;
    return update(
      message.copyWith(isStreaming: false, status: status, text: text),
    );
  }

  /// Replaces the text of the [TextMessage] with [id] and marks it as edited.
  ///
  /// Returns `false` if the message does not exist or is not a [TextMessage].
  bool editText(String id, String text, {DateTime? editedAt}) {
    final message = messageById(id);
    if (message is! TextMessage) return false;
    if (message.text == text) return true;
    return update(
      message.copyWith(text: text, editedAt: editedAt ?? DateTime.now()),
    );
  }

  /// Adds the reaction [emoji] of [userId] to the message with [id], or
  /// removes it if that user already reacted with it.
  ///
  /// Returns `false` if the message does not exist.
  bool toggleReaction(String id, String emoji, String userId) {
    final message = messageById(id);
    if (message == null) return false;
    final reactions = [...message.reactions];
    final index = reactions.indexWhere((r) => r.emoji == emoji);
    if (index == -1) {
      reactions.add(ChatReaction(emoji: emoji, userIds: [userId]));
    } else {
      final current = reactions[index];
      final userIds = current.hasUser(userId)
          ? [
              for (final u in current.userIds)
                if (u != userId) u
            ]
          : [...current.userIds, userId];
      if (userIds.isEmpty) {
        reactions.removeAt(index);
      } else {
        reactions[index] = ChatReaction(emoji: emoji, userIds: userIds);
      }
    }
    return update(message.withReactions(List.unmodifiable(reactions)));
  }

  /// Records the vote of [userId] for [optionId] in the [PollMessage] with
  /// [id], or removes it if that user already chose the option.
  ///
  /// In single-answer polls, a new vote replaces the previous one. Returns
  /// `false` if the message is not an open poll or the option does not
  /// exist.
  bool votePoll(String id, String optionId, String userId) {
    final poll = messageById(id);
    if (poll is! PollMessage || poll.isClosed) return false;
    if (!poll.options.any((o) => o.id == optionId)) return false;
    final options = [
      for (final option in poll.options)
        if (option.id == optionId)
          option.withVoters(
            option.voterIds.contains(userId)
                ? [
                    for (final v in option.voterIds)
                      if (v != userId) v
                  ]
                : [...option.voterIds, userId],
          )
        else if (!poll.allowsMultipleAnswers &&
            option.voterIds.contains(userId))
          option.withVoters(
            [
              for (final v in option.voterIds)
                if (v != userId) v
            ],
          )
        else
          option,
    ];
    return update(poll.copyWith(options: List.unmodifiable(options)));
  }

  /// Records that [userId] answered the [SurveyMessage] with [id].
  ///
  /// Returns `false` if the message is not a survey.
  bool recordSurveyResponse(String id, String userId) {
    final survey = messageById(id);
    if (survey is! SurveyMessage) return false;
    if (survey.hasResponded(userId)) return true;
    return update(
      survey.copyWith(
        respondentIds: List.unmodifiable([...survey.respondentIds, userId]),
      ),
    );
  }

  /// Pins the message with [id]. Returns `false` if it does not exist.
  bool pin(String id) {
    if (!contains(id)) return false;
    if (!_pinnedIds.value.contains(id)) {
      _pinnedIds.value = List.unmodifiable([..._pinnedIds.value, id]);
    }
    return true;
  }

  /// Unpins the message with [id].
  void unpin(String id) {
    if (!_pinnedIds.value.contains(id)) return;
    _pinnedIds.value = List.unmodifiable([..._pinnedIds.value]..remove(id));
  }

  /// Whether the message with [id] is pinned.
  bool isPinned(String id) => _pinnedIds.value.contains(id);

  /// Adds the message with [id] to the selection, or removes it if it is
  /// already selected. Selecting the first message enters selection mode.
  void toggleSelection(String id) {
    if (!contains(id)) return;
    final selected = {..._selectedIds.value};
    if (!selected.remove(id)) selected.add(id);
    _selectedIds.value = Set.unmodifiable(selected);
  }

  /// Leaves selection mode.
  void clearSelection() {
    if (_selectedIds.value.isNotEmpty) _selectedIds.value = const {};
  }

  /// The selected messages, oldest first.
  List<ChatMessage> get selectedMessages {
    final ids = _selectedIds.value;
    return [
      for (final m in _messages)
        if (ids.contains(m.id)) m
    ];
  }

  /// Asks `ChatView` to scroll to the message with [id] and, when
  /// [highlight] is `true`, to flash it.
  void scrollToMessage(String id, {bool highlight = true}) {
    if (!contains(id)) return;
    _scrollRequests.add(ChatScrollRequest(id, highlight: highlight));
  }

  /// IDs of messages whose text contains [query], ignoring case and
  /// markdown, newest first. Looks at text, captions, file names, poll
  /// questions and options, and countdown titles.
  List<String> search(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    return [
      for (var i = _messages.length - 1; i >= 0; i--)
        if (searchableText(_messages[i]).toLowerCase().contains(needle))
          _messages[i].id,
    ];
  }

  /// Plain text of [message] used by [search].
  static String searchableText(ChatMessage message) => switch (message) {
        TextMessage(:final text) => MarkdownParser.toPlainText(text),
        SystemMessage(:final text) => text,
        ImageMessage(:final caption) =>
          caption == null ? '' : MarkdownParser.toPlainText(caption),
        FileMessage(:final name) => name,
        PollMessage(:final question, :final options) =>
          [question, ...options.map((o) => o.text)].join(' '),
        CountdownMessage(:final title, :final description) =>
          '$title ${description ?? ''}',
        SurveyMessage(:final title, :final description, :final questions) => [
            title,
            description ?? '',
            ...questions.map((q) => q.title)
          ].join(' '),
        VoiceMessage() || CustomMessage() => '',
      };

  /// Starts replying to [message]. Cancels any edit in progress.
  void startReply(ChatMessage message) {
    _editing.value = null;
    _replyingTo.value = message;
  }

  /// Stops replying without sending.
  void cancelReply() => _replyingTo.value = null;

  /// Starts editing [message]. Cancels any reply in progress.
  void startEditing(TextMessage message) {
    _replyingTo.value = null;
    _editing.value = message;
  }

  /// Stops editing without saving.
  void cancelEditing() => _editing.value = null;

  /// Removes the message with [id]. Returns `false` if it did not exist.
  bool remove(String id) {
    final index = _indexOf(id);
    if (index == -1) return false;
    _messages.removeAt(index);
    _ids.remove(id);
    _structureRevision++;
    _watchers.remove(id)?.dispose();
    _expiryTimers.remove(id)?.cancel();
    if (_replyingTo.value?.id == id) _replyingTo.value = null;
    if (_editing.value?.id == id) _editing.value = null;
    _forget({id});
    notifyListeners();
    return true;
  }

  /// Replaces every message, for example when switching conversations.
  ///
  /// Throws an [ArgumentError] if two messages share an ID.
  void setMessages(Iterable<ChatMessage> messages) {
    final previous = List<ChatMessage>.of(_messages);
    _messages.clear();
    _ids.clear();
    _structureRevision++;
    try {
      _addAllSorted(messages);
    } on ArgumentError {
      _messages
        ..clear()
        ..addAll(previous);
      _ids
        ..clear()
        ..addAll(previous.map((m) => m.id));
      rethrow;
    }
    final ids = {for (final m in _messages) m.id};
    for (final timer in _expiryTimers.values) {
      timer.cancel();
    }
    _expiryTimers.clear();
    _messages.forEach(_scheduleExpiry);
    _watchers.removeWhere((id, watcher) {
      if (ids.contains(id)) return false;
      watcher.dispose();
      return true;
    });
    for (final message in _messages) {
      _watchers[message.id]?.value = message;
    }
    _forget({
      ..._pinnedIds.value,
      ..._selectedIds.value,
    }.where((id) => !ids.contains(id)).toSet());
    notifyListeners();
  }

  /// Removes every message.
  void clear() => setMessages(const []);

  /// Shows or hides the typing indicator for [user].
  void setTyping(ChatUser user, {required bool isTyping}) {
    final current = _typingUsers.value;
    final index = current.indexWhere((u) => u.id == user.id);
    if (isTyping && index == -1) {
      _typingUsers.value = List.unmodifiable([...current, user]);
    } else if (!isTyping && index != -1) {
      _typingUsers.value = List.unmodifiable([...current]..removeAt(index));
    }
  }

  /// Returns a listenable that always holds the latest version of the
  /// message with [id].
  ///
  /// Use it to build widgets that react to content changes of one message.
  /// Throws an [ArgumentError] if the message does not exist.
  ValueListenable<ChatMessage> watch(String id) {
    final existing = _watchers[id];
    if (existing != null) return existing;
    final message = messageById(id);
    if (message == null) {
      throw ArgumentError.value(id, 'id', 'No message with this ID');
    }
    return _watchers[id] = ValueNotifier<ChatMessage>(message);
  }

  @override
  void dispose() {
    for (final watcher in _watchers.values) {
      watcher.dispose();
    }
    _watchers.clear();
    _typingUsers.dispose();
    _replyingTo.dispose();
    _editing.dispose();
    _pinnedIds.dispose();
    _selectedIds.dispose();
    _scrollRequests.close();
    _draft.dispose();
    for (final timer in _expiryTimers.values) {
      timer.cancel();
    }
    _expiryTimers.clear();
    super.dispose();
  }

  // Removes the message when its expiresAt passes.
  void _scheduleExpiry(ChatMessage message) {
    _expiryTimers.remove(message.id)?.cancel();
    final expiresAt = message.expiresAt;
    if (!removeExpiredMessages || expiresAt == null) return;
    final delay = expiresAt.difference(DateTime.now());
    _expiryTimers[message.id] = Timer(
      delay.isNegative ? Duration.zero : delay,
      () {
        _expiryTimers.remove(message.id);
        remove(message.id);
      },
    );
  }

  // Drops pins and selection of messages that no longer exist.
  void _forget(Set<String> ids) {
    if (ids.isEmpty) return;
    if (_pinnedIds.value.any(ids.contains)) {
      _pinnedIds.value = List.unmodifiable(
        _pinnedIds.value.where((id) => !ids.contains(id)),
      );
    }
    if (_selectedIds.value.any(ids.contains)) {
      _selectedIds.value = Set.unmodifiable(
        _selectedIds.value.where((id) => !ids.contains(id)),
      );
    }
  }

  // Searches from the end: most lookups target recent messages.
  int _indexOf(String id) {
    if (!_ids.contains(id)) return -1;
    for (var i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].id == id) return i;
    }
    return -1;
  }

  void _ensureNew(String id) {
    if (_indexOf(id) != -1) {
      throw ArgumentError.value(
        id,
        'message.id',
        'A message with this ID already exists. Use upsert() instead',
      );
    }
  }

  void _addAllSorted(Iterable<ChatMessage> messages) {
    final ids = <String>{};
    for (final message in messages) {
      if (!ids.add(message.id)) {
        throw ArgumentError.value(message.id, 'messages', 'Duplicate ID');
      }
      _ensureNew(message.id);
    }
    for (final message in messages) {
      _insertSorted(message);
    }
  }

  // Binary search for the upper bound keeps equal timestamps in insertion
  // order. The fast path covers the common "new message at the end" case.
  void _insertSorted(ChatMessage message) {
    _ids.add(message.id);
    final time = message.createdAt;
    if (_messages.isEmpty || !_messages.last.createdAt.isAfter(time)) {
      _messages.add(message);
      return;
    }
    _structureRevision++;
    var low = 0;
    var high = _messages.length;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (_messages[mid].createdAt.isAfter(time)) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }
    _messages.insert(low, message);
  }
}

/// A request to scroll to a message, sent by
/// [ChatController.scrollToMessage].
@immutable
class ChatScrollRequest {
  /// Creates a scroll request.
  const ChatScrollRequest(this.messageId, {this.highlight = true});

  /// The message to reveal.
  final String messageId;

  /// Whether to flash the message after scrolling.
  final bool highlight;
}
