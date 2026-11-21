import 'package:flutter/foundation.dart';

import 'chat_reaction.dart';
import 'chat_user.dart';
import 'message_status.dart';

part 'message_parts.dart';

/// Base type of every item shown in a conversation.
///
/// The hierarchy is sealed, so a `switch` over a [ChatMessage] is
/// exhaustive. The set of types is fixed from 1.0: new kinds of content
/// arrive as [CustomMessage]s rendered by
/// `ChatBuilders.customMessageBuilders`, so your switches keep compiling.
///
/// Every message has an [id], an [author] and a [createdAt] time. The other
/// shared fields (delivery status, reply, reactions, thread, receipts,
/// forwarding, expiration, deletion, scheduling and metadata) are also
/// available together as [meta]. Change them with [copyWithMeta], or with
/// [withMeta] to keep the message type:
///
/// ```dart
/// final read = message.withMeta(
///   message.meta.copyWith(status: MessageStatus.read),
/// );
/// ```
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

  /// The shared fields of this message as one value.
  ChatMessageMeta get meta => ChatMessageMeta(
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
      );

  /// Returns a copy of this message, of the same type, with the shared
  /// fields of [meta].
  ChatMessage withMeta(ChatMessageMeta meta);

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
    bool clearReplyToId = false,
    bool clearForwardedFrom = false,
    bool clearMetadata = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) =>
      withMeta(
        meta.copyWith(
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
          clearReplyToId: clearReplyToId,
          clearForwardedFrom: clearForwardedFrom,
          clearMetadata: clearMetadata,
          clearThread: clearThread,
          clearExpiresAt: clearExpiresAt,
          clearDeletedAt: clearDeletedAt,
          clearScheduledFor: clearScheduledFor,
        ),
      );

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
      other.meta == meta;

  int get _baseHash => Object.hash(id, author, createdAt, meta);
}

/// The fields every [ChatMessage] shares besides its ID, author and time:
/// delivery status, reply, reactions, thread, receipts, forwarding,
/// expiration, deletion, scheduling and your metadata.
///
/// Read it with [ChatMessage.meta] and apply it with [ChatMessage.withMeta],
/// or change single fields with [ChatMessage.copyWithMeta].
@immutable
class ChatMessageMeta {
  /// Creates shared message fields.
  const ChatMessageMeta({
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

  /// See [ChatMessage.status].
  final MessageStatus? status;

  /// See [ChatMessage.replyToId].
  final String? replyToId;

  /// See [ChatMessage.reactions].
  final List<ChatReaction> reactions;

  /// See [ChatMessage.thread].
  final ChatThreadSummary? thread;

  /// See [ChatMessage.receipts].
  final List<ChatReadReceipt> receipts;

  /// See [ChatMessage.forwardedFrom].
  final String? forwardedFrom;

  /// See [ChatMessage.expiresAt].
  final DateTime? expiresAt;

  /// See [ChatMessage.deletedAt].
  final DateTime? deletedAt;

  /// See [ChatMessage.scheduledFor].
  final DateTime? scheduledFor;

  /// See [ChatMessage.metadata].
  final Map<String, Object?>? metadata;

  /// Returns a copy with the given fields replaced. Pass `true` to a
  /// `clear*` flag to set that field to `null`.
  ChatMessageMeta copyWith({
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
    bool clearReplyToId = false,
    bool clearForwardedFrom = false,
    bool clearMetadata = false,
    bool clearThread = false,
    bool clearExpiresAt = false,
    bool clearDeletedAt = false,
    bool clearScheduledFor = false,
  }) {
    return ChatMessageMeta(
      status: clearStatus ? null : status ?? this.status,
      replyToId: clearReplyToId ? null : replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      thread: clearThread ? null : thread ?? this.thread,
      receipts: receipts ?? this.receipts,
      forwardedFrom:
          clearForwardedFrom ? null : forwardedFrom ?? this.forwardedFrom,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      scheduledFor:
          clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
      metadata: clearMetadata ? null : metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageMeta &&
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

  @override
  int get hashCode => Object.hash(
        status,
        replyToId,
        Object.hashAll(reactions),
        thread,
        Object.hashAll(receipts),
        forwardedFrom,
        expiresAt,
        deletedAt,
        scheduledFor,
      );
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
    this.reasoning,
    this.toolCalls = const [],
    this.sources = const [],
    this.versions = const [],
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

  /// What an AI model thought before answering. Shown as a collapsible
  /// "Thought for 12s" block above the text.
  final ChatReasoning? reasoning;

  /// Tools an AI model used, such as a web search. Shown as cards above
  /// the text.
  final List<ChatToolCall> toolCalls;

  /// Sources the answer cites, shown as numbered chips under the text.
  final List<ChatSource> sources;

  /// Earlier answers, oldest first, kept when the answer was regenerated.
  /// The bubble shows "‹ 2/3 ›" to browse them, each with its own
  /// reasoning, tools and sources. `ChatController.startRegeneration`
  /// records them for you.
  final List<ChatAnswerVersion> versions;

  /// Returns a copy of this message with the given fields replaced.
  TextMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    ChatMessageMeta? meta,
    String? text,
    bool? isStreaming,
    DateTime? editedAt,
    ChatLinkPreview? linkPreview,
    List<ChatMessageButton>? buttons,
    List<ChatQuickReply>? quickReplies,
    ChatFeedback? feedback,
    List<ChatEdit>? editHistory,
    ChatReasoning? reasoning,
    List<ChatToolCall>? toolCalls,
    List<ChatSource>? sources,
    List<ChatAnswerVersion>? versions,
    bool clearEditedAt = false,
    bool clearLinkPreview = false,
    bool clearFeedback = false,
    bool clearReasoning = false,
  }) {
    final m = meta ?? this.meta;
    return TextMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      text: text ?? this.text,
      isStreaming: isStreaming ?? this.isStreaming,
      editedAt: clearEditedAt ? null : editedAt ?? this.editedAt,
      linkPreview: clearLinkPreview ? null : linkPreview ?? this.linkPreview,
      buttons: buttons ?? this.buttons,
      quickReplies: quickReplies ?? this.quickReplies,
      feedback: clearFeedback ? null : feedback ?? this.feedback,
      editHistory: editHistory ?? this.editHistory,
      reasoning: clearReasoning ? null : reasoning ?? this.reasoning,
      toolCalls: toolCalls ?? this.toolCalls,
      sources: sources ?? this.sources,
      versions: versions ?? this.versions,
    );
  }

  @override
  TextMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
          listEquals(other.editHistory, editHistory) &&
          other.reasoning == reasoning &&
          listEquals(other.toolCalls, toolCalls) &&
          listEquals(other.sources, sources) &&
          listEquals(other.versions, versions);

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
        reasoning,
        Object.hashAll(toolCalls),
        Object.hashAll(sources),
        Object.hashAll(versions),
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
    ChatMessageMeta? meta,
    String? text,
  }) {
    final m = meta ?? this.meta;
    return SystemMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      text: text ?? this.text,
    );
  }

  @override
  SystemMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
    ChatMessageMeta? meta,
    String? type,
    Object? payload,
  }) {
    final m = meta ?? this.meta;
    return CustomMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      type: type ?? this.type,
      payload: payload ?? this.payload,
    );
  }

  @override
  CustomMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
    ChatMessageMeta? meta,
    List<ChatImage>? images,
    String? caption,
    double? uploadProgress,
    bool? isSpoiler,
    bool clearUploadProgress = false,
  }) {
    final m = meta ?? this.meta;
    return ImageMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      images: images ?? this.images,
      caption: caption ?? this.caption,
      uploadProgress:
          clearUploadProgress ? null : uploadProgress ?? this.uploadProgress,
      isSpoiler: isSpoiler ?? this.isSpoiler,
    );
  }

  @override
  ImageMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
    ChatMessageMeta? meta,
    String? name,
    String? uri,
    int? sizeBytes,
    String? mimeType,
    double? uploadProgress,
    bool clearUploadProgress = false,
  }) {
    final m = meta ?? this.meta;
    return FileMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      name: name ?? this.name,
      uri: uri ?? this.uri,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mimeType: mimeType ?? this.mimeType,
      uploadProgress:
          clearUploadProgress ? null : uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  FileMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
    this.transcript,
  });

  /// Where the audio lives. Passed back to your playback callbacks.
  final String uri;

  /// Length of the recording.
  final Duration duration;

  /// Amplitude samples between 0 and 1. chatx resamples them to fit the
  /// bubble. When empty, a flat waveform is shown.
  final List<double> waveform;

  /// Text of the recording, produced by your app. Shown under the
  /// waveform.
  final String? transcript;

  /// Returns a copy of this message with the given fields replaced.
  VoiceMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    ChatMessageMeta? meta,
    String? uri,
    Duration? duration,
    List<double>? waveform,
    String? transcript,
  }) {
    final m = meta ?? this.meta;
    return VoiceMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      uri: uri ?? this.uri,
      duration: duration ?? this.duration,
      waveform: waveform ?? this.waveform,
      transcript: transcript ?? this.transcript,
    );
  }

  @override
  VoiceMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceMessage &&
          _baseEquals(other) &&
          other.uri == uri &&
          other.duration == duration &&
          listEquals(other.waveform, waveform) &&
          other.transcript == transcript;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        uri,
        duration,
        Object.hashAll(waveform),
        transcript,
      ]);

  @override
  String toString() => 'VoiceMessage(id: $id, author: ${author.id})';
}

/// A video with a thumbnail, duration and play button.
///
/// chatx does not play videos. Handle taps with `ChatView.onVideoTap`, for
/// example with the `video_player` package.
final class VideoMessage extends ChatMessage {
  /// Creates a video message.
  const VideoMessage({
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
    this.thumbnailUri,
    this.duration,
    this.width,
    this.height,
    this.caption,
    this.uploadProgress,
  });

  /// Where the video lives. Passed back to your tap handler.
  final String uri;

  /// Preview image, loaded like `ChatImage.uri`.
  final String? thumbnailUri;

  /// Length of the video.
  final Duration? duration;

  /// Width in pixels, used for the aspect ratio.
  final double? width;

  /// Height in pixels, used for the aspect ratio.
  final double? height;

  /// Optional text under the video. Supports markdown.
  final String? caption;

  /// Upload progress from 0 to 1, or `null` when there is no upload.
  final double? uploadProgress;

  /// Returns a copy of this message with the given fields replaced.
  VideoMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    ChatMessageMeta? meta,
    String? uri,
    String? thumbnailUri,
    Duration? duration,
    double? width,
    double? height,
    String? caption,
    double? uploadProgress,
    bool clearUploadProgress = false,
  }) {
    final m = meta ?? this.meta;
    return VideoMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      uri: uri ?? this.uri,
      thumbnailUri: thumbnailUri ?? this.thumbnailUri,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      caption: caption ?? this.caption,
      uploadProgress:
          clearUploadProgress ? null : uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  VideoMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoMessage &&
          _baseEquals(other) &&
          other.uri == uri &&
          other.thumbnailUri == thumbnailUri &&
          other.duration == duration &&
          other.width == width &&
          other.height == height &&
          other.caption == caption &&
          other.uploadProgress == uploadProgress;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        uri,
        thumbnailUri,
        duration,
        width,
        height,
        caption,
        uploadProgress,
      ]);

  @override
  String toString() => 'VideoMessage(id: $id, author: ${author.id})';
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
    ChatMessageMeta? meta,
    String? question,
    List<PollOption>? options,
    bool? allowsMultipleAnswers,
    bool? isClosed,
  }) {
    final m = meta ?? this.meta;
    return PollMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      question: question ?? this.question,
      options: options ?? this.options,
      allowsMultipleAnswers:
          allowsMultipleAnswers ?? this.allowsMultipleAnswers,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  @override
  PollMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
    ChatMessageMeta? meta,
    String? title,
    DateTime? endsAt,
    String? description,
    String? completedLabel,
  }) {
    final m = meta ?? this.meta;
    return CountdownMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      title: title ?? this.title,
      endsAt: endsAt ?? this.endsAt,
      description: description ?? this.description,
      completedLabel: completedLabel ?? this.completedLabel,
    );
  }

  @override
  CountdownMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
    ChatMessageMeta? meta,
    String? title,
    List<SurveyQuestion>? questions,
    String? description,
    List<String>? respondentIds,
    bool? isClosed,
  }) {
    final m = meta ?? this.meta;
    return SurveyMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      title: title ?? this.title,
      questions: questions ?? this.questions,
      description: description ?? this.description,
      respondentIds: respondentIds ?? this.respondentIds,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  @override
  SurveyMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
    ChatMessageMeta? meta,
    double? latitude,
    double? longitude,
    String? title,
    String? address,
    String? mapImageUri,
    DateTime? liveUntil,
    bool clearLiveUntil = false,
  }) {
    final m = meta ?? this.meta;
    return LocationMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      address: address ?? this.address,
      mapImageUri: mapImageUri ?? this.mapImageUri,
      liveUntil: clearLiveUntil ? null : liveUntil ?? this.liveUntil,
    );
  }

  @override
  LocationMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
    ChatMessageMeta? meta,
    String? title,
    DateTime? startsAt,
    DateTime? endsAt,
    String? location,
    String? description,
    Map<String, ChatRsvp>? rsvps,
  }) {
    final m = meta ?? this.meta;
    return EventMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      title: title ?? this.title,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      location: location ?? this.location,
      description: description ?? this.description,
      rsvps: rsvps ?? this.rsvps,
    );
  }

  @override
  EventMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
    ChatMessageMeta? meta,
    String? name,
    String? phone,
    String? email,
    String? organization,
    String? avatarUrl,
  }) {
    final m = meta ?? this.meta;
    return ContactMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      organization: organization ?? this.organization,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  ContactMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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

/// A shared to-do list that everyone in the chat can check.
///
/// Taps go to `ChatView.onChecklistToggle`; record them with
/// `ChatController.toggleChecklistItem`.
final class ChecklistMessage extends ChatMessage {
  /// Creates a checklist.
  const ChecklistMessage({
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
    required this.items,
  });

  /// Title of the list.
  final String title;

  /// The items, in display order.
  final List<ChecklistItem> items;

  /// Number of checked items.
  int get doneCount => items.where((i) => i.isDone).length;

  /// Returns a copy of this message with the given fields replaced.
  ChecklistMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    ChatMessageMeta? meta,
    String? title,
    List<ChecklistItem>? items,
  }) {
    final m = meta ?? this.meta;
    return ChecklistMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      title: title ?? this.title,
      items: items ?? this.items,
    );
  }

  @override
  ChecklistMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistMessage &&
          _baseEquals(other) &&
          other.title == title &&
          listEquals(other.items, items);

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        title,
        Object.hashAll(items),
      ]);

  @override
  String toString() => 'ChecklistMessage(id: $id, author: ${author.id})';
}

/// One product card, or a carousel when there are several products.
final class ProductMessage extends ChatMessage {
  /// Creates a product message.
  const ProductMessage({
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
    required this.products,
    this.text,
  }) : assert(
            products.length > 0, 'A ProductMessage needs at least one product');

  /// The products. More than one shows a horizontal carousel.
  final List<ChatProduct> products;

  /// Optional text above the products. Supports markdown.
  final String? text;

  /// Returns a copy of this message with the given fields replaced.
  ProductMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    ChatMessageMeta? meta,
    List<ChatProduct>? products,
    String? text,
  }) {
    final m = meta ?? this.meta;
    return ProductMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      products: products ?? this.products,
      text: text ?? this.text,
    );
  }

  @override
  ProductMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductMessage &&
          _baseEquals(other) &&
          listEquals(other.products, products) &&
          other.text == text;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        Object.hashAll(products),
        text,
      ]);

  @override
  String toString() => 'ProductMessage(id: $id, author: ${author.id})';
}

/// A request for money, or a payment the author sent.
///
/// While [status] is pending, the other people see Pay and Decline buttons
/// that call `ChatView.onPaymentAction`. chatx never handles money.
final class PaymentMessage extends ChatMessage {
  /// Creates a payment message.
  const PaymentMessage({
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
    required this.amount,
    this.isRequest = true,
    this.note,
    this.paymentStatus = ChatPaymentStatus.pending,
  });

  /// Amount, already formatted by your app, for example "\$25.00".
  final String amount;

  /// Whether the author asks for money (`true`) or sent it (`false`).
  final bool isRequest;

  /// What the payment is for.
  final String? note;

  /// Whether the payment is pending, paid, declined or cancelled.
  final ChatPaymentStatus paymentStatus;

  /// Returns a copy of this message with the given fields replaced.
  PaymentMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    ChatMessageMeta? meta,
    String? amount,
    bool? isRequest,
    String? note,
    ChatPaymentStatus? paymentStatus,
  }) {
    final m = meta ?? this.meta;
    return PaymentMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      amount: amount ?? this.amount,
      isRequest: isRequest ?? this.isRequest,
      note: note ?? this.note,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  @override
  PaymentMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMessage &&
          _baseEquals(other) &&
          other.amount == amount &&
          other.isRequest == isRequest &&
          other.note == note &&
          other.paymentStatus == paymentStatus;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        amount,
        isRequest,
        note,
        paymentStatus,
      ]);

  @override
  String toString() => 'PaymentMessage(id: $id, author: ${author.id})';
}

/// An entry of the call log: a voice or video call and how it ended.
final class CallMessage extends ChatMessage {
  /// Creates a call log entry.
  const CallMessage({
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
    this.kind = ChatCallKind.voice,
    this.outcome = ChatCallOutcome.completed,
    this.duration,
  });

  /// Voice or video call.
  final ChatCallKind kind;

  /// Whether the call happened, was missed or was declined.
  final ChatCallOutcome outcome;

  /// Length of a completed call.
  final Duration? duration;

  /// Returns a copy of this message with the given fields replaced.
  CallMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    ChatMessageMeta? meta,
    ChatCallKind? kind,
    ChatCallOutcome? outcome,
    Duration? duration,
  }) {
    final m = meta ?? this.meta;
    return CallMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      kind: kind ?? this.kind,
      outcome: outcome ?? this.outcome,
      duration: duration ?? this.duration,
    );
  }

  @override
  CallMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallMessage &&
          _baseEquals(other) &&
          other.kind == kind &&
          other.outcome == outcome &&
          other.duration == duration;

  @override
  int get hashCode => Object.hashAll([
        _baseHash,
        kind,
        outcome,
        duration,
      ]);

  @override
  String toString() => 'CallMessage(id: $id, author: ${author.id})';
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
    ChatMessageMeta? meta,
    String? uri,
    String? label,
  }) {
    final m = meta ?? this.meta;
    return StickerMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      status: m.status,
      replyToId: m.replyToId,
      reactions: m.reactions,
      thread: m.thread,
      receipts: m.receipts,
      forwardedFrom: m.forwardedFrom,
      expiresAt: m.expiresAt,
      deletedAt: m.deletedAt,
      scheduledFor: m.scheduledFor,
      metadata: m.metadata,
      uri: uri ?? this.uri,
      label: label ?? this.label,
    );
  }

  @override
  StickerMessage withMeta(ChatMessageMeta meta) => copyWith(meta: meta);

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
