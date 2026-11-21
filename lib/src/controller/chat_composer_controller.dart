part of 'chat_controller.dart';

/// State of the input bar of one conversation: the draft, the message being
/// replied to or edited, and the attachments waiting to be sent.
///
/// Every `ChatController` owns one, as `ChatController.composer`. `ChatView`
/// reads and updates it as the user types, so you only call it to drive the
/// input from your code, for example to restore a saved draft or to add the
/// files your picker returned.
///
/// Replying and editing exclude each other: starting one cancels the other.
///
/// After [dispose], every method does nothing.
class ChatComposerController {
  /// Creates a composer with an optional [initialDraft].
  ChatComposerController({String initialDraft = ''})
      : _draft = ValueNotifier<String>(initialDraft);

  final ValueNotifier<String> _draft;
  final ValueNotifier<ChatMessage?> _replyingTo = ValueNotifier(null);
  final ValueNotifier<TextMessage?> _editing = ValueNotifier(null);
  final ValueNotifier<List<ChatAttachment>> _attachments =
      ValueNotifier<List<ChatAttachment>>(const []);
  bool _disposed = false;

  /// Unsent text of the input. `ChatView` restores it when it is built
  /// again, so keeping the controller alive keeps the draft. Listen to it to
  /// persist drafts across app restarts.
  ValueListenable<String> get draft => _draft;

  /// The message being replied to, or `null`. `ChatView` shows it above the
  /// input and passes it with the next message.
  ValueListenable<ChatMessage?> get replyingTo => _replyingTo;

  /// The message being edited, or `null`. `ChatView` puts its text in the
  /// input and sends the result as an edit.
  ValueListenable<TextMessage?> get editing => _editing;

  /// Files waiting in the input tray, in the order they were added.
  ValueListenable<List<ChatAttachment>> get attachments => _attachments;

  /// Replaces the draft. `ChatView` calls this as the user types.
  void setDraft(String text) {
    if (!_disposed) _draft.value = text;
  }

  /// Starts replying to [message]. Cancels any edit in progress.
  void startReply(ChatMessage message) {
    if (_disposed) return;
    _editing.value = null;
    _replyingTo.value = message;
  }

  /// Stops replying without sending.
  void cancelReply() {
    if (!_disposed) _replyingTo.value = null;
  }

  /// Starts editing [message]. Cancels any reply in progress.
  void startEditing(TextMessage message) {
    if (_disposed) return;
    _replyingTo.value = null;
    _editing.value = message;
  }

  /// Stops editing without saving.
  void cancelEditing() {
    if (!_disposed) _editing.value = null;
  }

  /// Adds files to the input tray, for example after your file picker
  /// returns.
  void addAttachments(Iterable<ChatAttachment> attachments) {
    if (_disposed || attachments.isEmpty) return;
    _attachments.value =
        List.unmodifiable([..._attachments.value, ...attachments]);
  }

  /// Removes the attachment with [id] from the input tray.
  void removeAttachment(String id) {
    if (_disposed) return;
    final rest = _attachments.value.where((a) => a.id != id).toList();
    if (rest.length != _attachments.value.length) {
      _attachments.value = List.unmodifiable(rest);
    }
  }

  /// Empties the input tray.
  void clearAttachments() {
    if (!_disposed && _attachments.value.isNotEmpty) {
      _attachments.value = const [];
    }
  }

  /// Clears the draft, the reply, the edit and the attachments.
  void reset() {
    if (_disposed) return;
    _replyingTo.value = null;
    _editing.value = null;
    _attachments.value = const [];
    _draft.value = '';
  }

  // Called by ChatController when messages change. The reply follows new
  // versions of its message; the edit keeps the version the user started
  // from, so their changes are not overwritten. Both end when the message
  // is gone.
  void _sync(ChatMessage? Function(String id) lookup) {
    if (_disposed) return;
    final replying = _replyingTo.value;
    if (replying != null) _replyingTo.value = lookup(replying.id);
    final editing = _editing.value;
    if (editing != null && lookup(editing.id) is! TextMessage) {
      _editing.value = null;
    }
  }

  /// Releases the listenables. `ChatController.dispose` calls it.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _draft.dispose();
    _replyingTo.dispose();
    _editing.dispose();
    _attachments.dispose();
  }
}
