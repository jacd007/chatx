import 'package:flutter/foundation.dart';

import 'chat_reaction.dart';
import 'chat_user.dart';
import 'message_status.dart';

part 'message_parts.dart';

/// Base type of every item shown in a conversation.
///
/// The hierarchy is sealed, so a `switch` over a [ChatMessage] is
/// exhaustive. Use [CustomMessage] for content chatx does not render out of
/// the box.
///
/// Every message shares the fields below: author, time, delivery status,
/// replies, reactions, thread summary, read receipts, forwarding and
/// expiration.
@immutable
sealed class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.createdAt,
    this.status,
    this.replyToId,
    this.reactions = const [],
    this.thread,
    this.receipts = const [],
    this.forwardedFrom,
    this.expiresAt,
    this.deletedAt,
    this.scheduledFor,
    this.metadata,
  });

  /// Unique identifier of the message inside its conversation.
  final String id;

  /// The user who wrote the message.
  final ChatUser author;

  /// When the message was created. Messages are ordered by this value.
  final DateTime createdAt;

  /// Delivery state. Usually only set for messages of the current user.
  final MessageStatus? status;

  /// ID of the message this one replies to. The bubble shows a quote of it.
  final String? replyToId;

  /// Emoji reactions, in the order they were first added.
  final List<ChatReaction> reactions;

  /// Summary of the thread started from this message. The bubble shows the
  /// reply count and `ChatView.onThreadTap` opens it.
  final ChatThreadSummary? thread;

  /// Who read the message and when. Shown as "Seen by" avatars in group
  /// chats and in the message info sheet.
  final List<ChatReadReceipt> receipts;

  /// Name of the original author when the message was forwarded. Shows a
  /// "Forwarded" label.
  final String? forwardedFrom;

  /// When the message disappears. The bubble shows the time left and the
  /// controller removes the message when it expires.
  final DateTime? expiresAt;

  /// When the message was deleted for everyone. The bubble shows a
  /// "message deleted" placeholder instead of the content.
  final DateTime? deletedAt;

  /// When a scheduled message will be sent. The bubble is dimmed and shows
  /// the scheduled time instead of the delivery status.
  final DateTime? scheduledFor;

  /// Arbitrary data you want to carry with the message. Never read by chatx.
  final Map<String, Object?>? metadata;

  /// Returns a copy with any of the shared fields replaced. Pass `true` to a
  /// `clear*` flag to set that field to `null`.
  ChatMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  });

  /// Returns a copy of this message with [status] replaced.
  ChatMessage withStatus(MessageStatus? status) =>
      copyWithMeta(status: status, clearStatus: status == null);

  /// Returns a copy of this message with [reactions] replaced.
  ChatMessage withReactions(List<ChatReaction> reactions) =>
      copyWithMeta(reactions: reactions);

  bool _baseEquals(ChatMessage other) =>
      other.id == id &&
      other.author == author &&
      other.createdAt == createdAt &&
      other.status == status &&
      other.replyToId == replyToId &&
      listEquals(other.reactions, reactions) &&
      other.thread == thread &&
      listEquals(other.receipts, receipts) &&
      other.forwardedFrom == forwardedFrom &&
      other.expiresAt == expiresAt &&
      other.deletedAt == deletedAt &&
      other.scheduledFor == scheduledFor &&
      mapEquals(other.metadata, metadata);

  int get _baseHash => Object.hashAll([
        id,
        author,
        createdAt,
        status,
        replyToId,
        Object.hashAll(reactions),
        thread,
        Object.hashAll(receipts),
        forwardedFrom,
        expiresAt,
        deletedAt,
        scheduledFor,
      ]);
}

/// A message whose [text] is rendered with chatx's markdown subset.
///
/// Set [isStreaming] to `true` while the text is still being produced, for
/// example by an LLM. The bubble then shows a caret, and
/// `ChatController.appendText` updates only this bubble.
///
/// Bots can attach [buttons] inside the bubble and [quickReplies] that appear
/// above the input while this is the newest message.
final class TextMessage extends ChatMessage {
  /// Creates a text message.
  const TextMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.text,
    this.isStreaming = false,
    this.editedAt,
    this.linkPreview,
    this.buttons = const [],
    this.quickReplies = const [],
    this.feedback,
    this.editHistory = const [],
  });

  /// Message body. Supports **bold**, _italic_, ~~strike~~, `code`, fenced
  /// code blocks, quotes, lists, headings, links and `||spoilers||`.
  final String text;

  /// Whether more text is still expected for this message.
  final bool isStreaming;

  /// When the message was last edited. Shows an "edited" label when set.
  final DateTime? editedAt;

  /// Card shown under the text with a preview of a link.
  final ChatLinkPreview? linkPreview;

  /// Buttons shown inside the bubble, under the text.
  final List<ChatMessageButton> buttons;

  /// Suggested answers shown above the input while this is the newest
  /// message.
  final List<ChatQuickReply> quickReplies;

  /// Rating the current user gave to this answer, for AI assistants.
  final ChatFeedback? feedback;

  /// Previous versions, oldest first. Tapping "edited" shows them.
  /// `ChatController.editText` records them for you.
  final List<ChatEdit> editHistory;

  /// Returns a copy of this message with the given fields replaced.
  TextMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? text,
    bool? isStreaming,
    DateTime? editedAt,
    ChatLinkPreview? linkPreview,
    List<ChatMessageButton>? buttons,
    List<ChatQuickReply>? quickReplies,
    ChatFeedback? feedback,
    List<ChatEdit>? editHistory,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
    bool clearEditedAt = false,
    bool clearLinkPreview = false,
    bool clearFeedback = false,
  }) {
    return TextMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      text: text ?? this.text,
      isStreaming: isStreaming ?? this.isStreaming,
      editedAt: clearEditedAt ? null : editedAt ?? this.editedAt,
      linkPreview: clearLinkPreview ? null : linkPreview ?? this.linkPreview,
      buttons: buttons ?? this.buttons,
      quickReplies: quickReplies ?? this.quickReplies,
      feedback: clearFeedback ? null : feedback ?? this.feedback,
      editHistory: editHistory ?? this.editHistory,
    );
  }

  @override
  TextMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMessage &&
          _baseEquals(other) &&
          other.text == text &&
          other.isStreaming == isStreaming &&
          other.editedAt == editedAt &&
          other.linkPreview == linkPreview &&
          listEquals(other.buttons, buttons) &&
          listEquals(other.quickReplies, quickReplies) &&
          other.feedback == feedback &&
          listEquals(other.editHistory, editHistory);

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        text,
        isStreaming,
        editedAt,
        linkPreview,
        Object.hashAll(buttons),
        Object.hashAll(quickReplies),
        feedback,
        Object.hashAll(editHistory),
      ]);

  @override
  String toString() => 'TextMessage(id: $id, author: ${author.id})';
}

/// A centered, author-less notice such as "Ana joined the group".
///
/// System messages never group with other messages, have no bubble and
/// ignore replies, reactions and receipts.
final class SystemMessage extends ChatMessage {
  /// Creates a system notice.
  const SystemMessage({
    required super.id,
    super.author = systemUser,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.text,
  });

  /// Default author of system messages.
  static const ChatUser systemUser = ChatUser(id: 'chatx.system');

  /// Plain text of the notice. Markdown is not applied.
  final String text;

  /// Returns a copy of this message with the given fields replaced.
  SystemMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? text,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return SystemMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      text: text ?? this.text,
    );
  }

  @override
  SystemMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  SystemMessage withStatus(MessageStatus? status) => this;

  @override
  SystemMessage withReactions(List<ChatReaction> reactions) => this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMessage && _baseEquals(other) && other.text == text;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        text,
      ]);

  @override
  String toString() => 'SystemMessage(id: $id, author: ${author.id})';
}

/// A message rendered by your own `customMessageBuilder`.
///
/// Use [type] to tell your kinds apart (for example `'location'` or
/// `'contact'`) and [payload] to carry their data.
final class CustomMessage extends ChatMessage {
  /// Creates a custom message.
  const CustomMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.type,
    this.payload,
  });

  /// Your discriminator for this kind of message.
  final String type;

  /// Data your builder needs to render the message.
  final Object? payload;

  /// Returns a copy of this message with the given fields replaced.
  CustomMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? type,
    Object? payload,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return CustomMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      type: type ?? this.type,
      payload: payload ?? this.payload,
    );
  }

  @override
  CustomMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomMessage &&
          _baseEquals(other) &&
          other.type == type &&
          other.payload == payload;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        type,
        payload,
      ]);

  @override
  String toString() => 'CustomMessage(id: $id, author: ${author.id})';
}

/// One to many images, shown as a grid, with an optional caption.
///
/// Tapping an image opens a full-screen viewer with zoom. Set
/// [uploadProgress] while your app uploads the images, and [isSpoiler] to
/// blur them until the user taps.
final class ImageMessage extends ChatMessage {
  /// Creates an image message.
  const ImageMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.images,
    this.caption,
    this.uploadProgress,
    this.isSpoiler = false,
  }) : assert(images.length > 0, 'An ImageMessage needs at least one image');

  /// The images. The grid shows up to four and a "+N" counter for the rest.
  final List<ChatImage> images;

  /// Optional text under the images. Supports markdown.
  final String? caption;

  /// Upload progress from 0 to 1, or `null` when there is no upload.
  final double? uploadProgress;

  /// Whether the images stay blurred until the user taps them.
  final bool isSpoiler;

  /// Returns a copy of this message with the given fields replaced.
  ImageMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    List<ChatImage>? images,
    String? caption,
    double? uploadProgress,
    bool? isSpoiler,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
    bool clearUploadProgress = false,
  }) {
    return ImageMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      images: images ?? this.images,
      caption: caption ?? this.caption,
      uploadProgress:
          clearUploadProgress ? null : uploadProgress ?? this.uploadProgress,
      isSpoiler: isSpoiler ?? this.isSpoiler,
    );
  }

  @override
  ImageMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageMessage &&
          _baseEquals(other) &&
          listEquals(other.images, images) &&
          other.caption == caption &&
          other.uploadProgress == uploadProgress &&
          other.isSpoiler == isSpoiler;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        Object.hashAll(images),
        caption,
        uploadProgress,
        isSpoiler,
      ]);

  @override
  String toString() => 'ImageMessage(id: $id, author: ${author.id})';
}

/// A file attachment: icon, name, size and optional upload progress.
///
/// chatx does not download or open files. Handle taps with
/// `ChatView.onFileTap`.
final class FileMessage extends ChatMessage {
  /// Creates a file message.
  const FileMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.name,
    this.uri,
    this.sizeBytes,
    this.mimeType,
    this.uploadProgress,
  });

  /// File name shown to the user, including the extension.
  final String name;

  /// Where the file lives. Passed back to your tap handler.
  final String? uri;

  /// Size in bytes. Shown as "2.4 MB".
  final int? sizeBytes;

  /// MIME type, used to pick the icon when the extension is not enough.
  final String? mimeType;

  /// Upload progress from 0 to 1, or `null` when there is no upload.
  final double? uploadProgress;

  /// Lowercase extension without the dot, or an empty string.
  String get extension {
    final dot = name.lastIndexOf('.');
    return dot <= 0 || dot == name.length - 1
        ? ''
        : name.substring(dot + 1).toLowerCase();
  }

  /// Returns a copy of this message with the given fields replaced.
  FileMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? name,
    String? uri,
    int? sizeBytes,
    String? mimeType,
    double? uploadProgress,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
    bool clearUploadProgress = false,
  }) {
    return FileMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      name: name ?? this.name,
      uri: uri ?? this.uri,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mimeType: mimeType ?? this.mimeType,
      uploadProgress:
          clearUploadProgress ? null : uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  FileMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileMessage &&
          _baseEquals(other) &&
          other.name == name &&
          other.uri == uri &&
          other.sizeBytes == sizeBytes &&
          other.mimeType == mimeType &&
          other.uploadProgress == uploadProgress;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        name,
        uri,
        sizeBytes,
        mimeType,
        uploadProgress,
      ]);

  @override
  String toString() => 'FileMessage(id: $id, author: ${author.id})';
}

/// A voice note: play button, waveform and duration.
///
/// chatx draws the UI only. Your app plays the audio and reports progress
/// through `ChatView.voicePlayback`.
final class VoiceMessage extends ChatMessage {
  /// Creates a voice note.
  const VoiceMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.uri,
    required this.duration,
    this.waveform = const [],
  });

  /// Where the audio lives. Passed back to your playback callbacks.
  final String uri;

  /// Length of the recording.
  final Duration duration;

  /// Amplitude samples between 0 and 1. chatx resamples them to fit the
  /// bubble. When empty, a flat waveform is shown.
  final List<double> waveform;

  /// Returns a copy of this message with the given fields replaced.
  VoiceMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? uri,
    Duration? duration,
    List<double>? waveform,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return VoiceMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      uri: uri ?? this.uri,
      duration: duration ?? this.duration,
      waveform: waveform ?? this.waveform,
    );
  }

  @override
  VoiceMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceMessage &&
          _baseEquals(other) &&
          other.uri == uri &&
          other.duration == duration &&
          listEquals(other.waveform, waveform);

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        uri,
        duration,
        Object.hashAll(waveform),
      ]);

  @override
  String toString() => 'VoiceMessage(id: $id, author: ${author.id})';
}

/// A quick vote: one question with closed options to decide something now.
///
/// Results appear with animated bars once the current user votes or the poll
/// is closed. Votes go through `ChatView.onPollVote`; update the message with
/// `ChatController.votePoll`. For questionnaires with several questions, use
/// [SurveyMessage].
final class PollMessage extends ChatMessage {
  /// Creates a poll.
  const PollMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.question,
    required this.options,
    this.allowsMultipleAnswers = false,
    this.isClosed = false,
  });

  /// The question.
  final String question;

  /// The answers, in display order.
  final List<PollOption> options;

  /// Whether a user may choose more than one option.
  final bool allowsMultipleAnswers;

  /// Whether voting has ended. Closed polls show results to everyone.
  final bool isClosed;

  /// Total votes across options.
  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes);

  /// Whether [userId] voted for any option.
  bool hasVoted(String userId) =>
      options.any((o) => o.voterIds.contains(userId));

  /// Returns a copy of this message with the given fields replaced.
  PollMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? question,
    List<PollOption>? options,
    bool? allowsMultipleAnswers,
    bool? isClosed,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return PollMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      question: question ?? this.question,
      options: options ?? this.options,
      allowsMultipleAnswers:
          allowsMultipleAnswers ?? this.allowsMultipleAnswers,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  @override
  PollMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollMessage &&
          _baseEquals(other) &&
          other.question == question &&
          listEquals(other.options, options) &&
          other.allowsMultipleAnswers == allowsMultipleAnswers &&
          other.isClosed == isClosed;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        question,
        Object.hashAll(options),
        allowsMultipleAnswers,
        isClosed,
      ]);

  @override
  String toString() => 'PollMessage(id: $id, author: ${author.id})';
}

/// An announcement with a live countdown to [endsAt].
///
/// Shows days, hours, minutes and seconds left, and a "started" label once
/// the moment arrives.
final class CountdownMessage extends ChatMessage {
  /// Creates a countdown announcement.
  const CountdownMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.title,
    required this.endsAt,
    this.description,
    this.completedLabel,
  });

  /// What is coming, for example "Product launch".
  final String title;

  /// When the countdown reaches zero.
  final DateTime endsAt;

  /// Optional details. Supports markdown.
  final String? description;

  /// Text shown after [endsAt]. Defaults to the localized "It's time!".
  final String? completedLabel;

  /// Returns a copy of this message with the given fields replaced.
  CountdownMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? title,
    DateTime? endsAt,
    String? description,
    String? completedLabel,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return CountdownMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      title: title ?? this.title,
      endsAt: endsAt ?? this.endsAt,
      description: description ?? this.description,
      completedLabel: completedLabel ?? this.completedLabel,
    );
  }

  @override
  CountdownMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountdownMessage &&
          _baseEquals(other) &&
          other.title == title &&
          other.endsAt == endsAt &&
          other.description == description &&
          other.completedLabel == completedLabel;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        title,
        endsAt,
        description,
        completedLabel,
      ]);

  @override
  String toString() => 'CountdownMessage(id: $id, author: ${author.id})';
}

/// A questionnaire with several questions to learn what people think.
///
/// The bubble shows a card with the title and a button. Answering opens a
/// step-by-step form; the answers go to `ChatView.onSurveySubmit`. Record
/// who answered with `ChatController.recordSurveyResponse`. For a single
/// quick decision, use [PollMessage].
final class SurveyMessage extends ChatMessage {
  /// Creates a survey.
  const SurveyMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.title,
    required this.questions,
    this.description,
    this.respondentIds = const [],
    this.isClosed = false,
  }) : assert(questions.length > 0,
            'A SurveyMessage needs at least one question');

  /// Title of the survey.
  final String title;

  /// The questions, asked in order.
  final List<SurveyQuestion> questions;

  /// Short explanation shown on the card and the first step.
  final String? description;

  /// IDs of the users who already answered.
  final List<String> respondentIds;

  /// Whether the survey no longer accepts answers.
  final bool isClosed;

  /// Whether [userId] already answered.
  bool hasResponded(String userId) => respondentIds.contains(userId);

  /// Returns a copy of this message with the given fields replaced.
  SurveyMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? title,
    List<SurveyQuestion>? questions,
    String? description,
    List<String>? respondentIds,
    bool? isClosed,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return SurveyMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      title: title ?? this.title,
      questions: questions ?? this.questions,
      description: description ?? this.description,
      respondentIds: respondentIds ?? this.respondentIds,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  @override
  SurveyMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyMessage &&
          _baseEquals(other) &&
          other.title == title &&
          listEquals(other.questions, questions) &&
          other.description == description &&
          listEquals(other.respondentIds, respondentIds) &&
          other.isClosed == isClosed;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        title,
        Object.hashAll(questions),
        description,
        Object.hashAll(respondentIds),
        isClosed,
      ]);

  @override
  String toString() => 'SurveyMessage(id: $id, author: ${author.id})';
}

/// A place on a map, or the live location of the author.
///
/// chatx does not draw real maps. Provide an image with [mapImageUri] (for
/// example from a static maps API) or a widget with
/// `ChatView.locationMapBuilder`; otherwise a stylized placeholder is shown.
final class LocationMessage extends ChatMessage {
  /// Creates a location message.
  const LocationMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.latitude,
    required this.longitude,
    this.title,
    this.address,
    this.mapImageUri,
    this.liveUntil,
  });

  /// Latitude in degrees.
  final double latitude;

  /// Longitude in degrees.
  final double longitude;

  /// Name of the place, for example "Café Central".
  final String? title;

  /// Street address shown under the title.
  final String? address;

  /// Static map image, loaded like `ChatImage.uri`.
  final String? mapImageUri;

  /// When set, the author shares a live location until this time.
  final DateTime? liveUntil;

  /// Returns a copy of this message with the given fields replaced.
  LocationMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    double? latitude,
    double? longitude,
    String? title,
    String? address,
    String? mapImageUri,
    DateTime? liveUntil,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
    bool clearLiveUntil = false,
  }) {
    return LocationMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      address: address ?? this.address,
      mapImageUri: mapImageUri ?? this.mapImageUri,
      liveUntil: clearLiveUntil ? null : liveUntil ?? this.liveUntil,
    );
  }

  @override
  LocationMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationMessage &&
          _baseEquals(other) &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.title == title &&
          other.address == address &&
          other.mapImageUri == mapImageUri &&
          other.liveUntil == liveUntil;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        latitude,
        longitude,
        title,
        address,
        mapImageUri,
        liveUntil,
      ]);

  @override
  String toString() => 'LocationMessage(id: $id, author: ${author.id})';
}

/// An event invitation with RSVP: going, maybe or not going.
///
/// Answers go to `ChatView.onRsvp`; record them with
/// `ChatController.setRsvp`.
final class EventMessage extends ChatMessage {
  /// Creates an event invitation.
  const EventMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.title,
    required this.startsAt,
    this.endsAt,
    this.location,
    this.description,
    this.rsvps = const {},
  });

  /// Name of the event.
  final String title;

  /// When the event starts.
  final DateTime startsAt;

  /// When the event ends.
  final DateTime? endsAt;

  /// Where it happens.
  final String? location;

  /// Details. Supports markdown.
  final String? description;

  /// Answers by user ID.
  final Map<String, ChatRsvp> rsvps;

  /// IDs of users who answered [rsvp].
  List<String> usersWith(ChatRsvp rsvp) => [
        for (final entry in rsvps.entries)
          if (entry.value == rsvp) entry.key,
      ];

  /// Returns a copy of this message with the given fields replaced.
  EventMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? title,
    DateTime? startsAt,
    DateTime? endsAt,
    String? location,
    String? description,
    Map<String, ChatRsvp>? rsvps,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return EventMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      title: title ?? this.title,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      location: location ?? this.location,
      description: description ?? this.description,
      rsvps: rsvps ?? this.rsvps,
    );
  }

  @override
  EventMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventMessage &&
          _baseEquals(other) &&
          other.title == title &&
          other.startsAt == startsAt &&
          other.endsAt == endsAt &&
          other.location == location &&
          other.description == description &&
          mapEquals(other.rsvps, rsvps);

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        title,
        startsAt,
        endsAt,
        location,
        description,
        Object.hashAllUnordered(
            rsvps.entries.map((e) => Object.hash(e.key, e.value))),
      ]);

  @override
  String toString() => 'EventMessage(id: $id, author: ${author.id})';
}

/// A shared contact card.
final class ContactMessage extends ChatMessage {
  /// Creates a contact card.
  const ContactMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.name,
    this.phone,
    this.email,
    this.organization,
    this.avatarUrl,
  });

  /// Full name of the contact.
  final String name;

  /// Phone number.
  final String? phone;

  /// Email address.
  final String? email;

  /// Company or organization.
  final String? organization;

  /// Photo of the contact.
  final String? avatarUrl;

  /// Returns a copy of this message with the given fields replaced.
  ContactMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? name,
    String? phone,
    String? email,
    String? organization,
    String? avatarUrl,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return ContactMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      organization: organization ?? this.organization,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  ContactMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactMessage &&
          _baseEquals(other) &&
          other.name == name &&
          other.phone == phone &&
          other.email == email &&
          other.organization == organization &&
          other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        name,
        phone,
        email,
        organization,
        avatarUrl,
      ]);

  @override
  String toString() => 'ContactMessage(id: $id, author: ${author.id})';
}

/// A sticker or GIF, shown large and without a bubble.
final class StickerMessage extends ChatMessage {
  /// Creates a sticker message.
  const StickerMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    super.status,
    super.replyToId,
    super.reactions,
    super.thread,
    super.receipts,
    super.forwardedFrom,
    super.expiresAt,
    super.deletedAt,
    super.scheduledFor,
    super.metadata,
    required this.uri,
    this.label,
  });

  /// Image of the sticker, loaded like `ChatImage.uri`. Animated GIF and WebP
  /// files play automatically.
  final String uri;

  /// Description read by screen readers, for example "Cat waving".
  final String? label;

  /// Returns a copy of this message with the given fields replaced.
  StickerMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    String? uri,
    String? label,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return StickerMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: metadata ?? this.metadata,
      uri: uri ?? this.uri,
      label: label ?? this.label,
    );
  }

  @override
  StickerMessage copyWithMeta({
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    ChatThreadSummary? thread,
    List<ChatReadReceipt>? receipts,
    String? forwardedFrom,
    DateTime? expiresAt,
    DateTime? deletedAt,
    DateTime? scheduledFor,
    Map<String, Object?>? metadata,
    bool clearStatus = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return copyWith(
      status: status,
      replyToId: replyToId,
      reactions: reactions,
      thread: thread,
      receipts: receipts,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      deletedAt: deletedAt,
      scheduledFor: scheduledFor,
      metadata: metadata,
      clearStatus: clearStatus,
      clearThread: clearThread,
      clearExpiresAt: clearExpiresAt,
      clearDeletedAt: clearDeletedAt,
      clearScheduledFor: clearScheduledFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickerMessage &&
          _baseEquals(other) &&
          other.uri == uri &&
          other.label == label;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        uri,
        label,
      ]);

  @override
  String toString() => 'StickerMessage(id: $id, author: ${author.id})';
}
