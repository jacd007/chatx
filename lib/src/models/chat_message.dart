import 'package:flutter/foundation.dart';

import 'chat_reaction.dart';
import 'chat_user.dart';
import 'message_status.dart';

part 'rich_messages.dart';

/// Base type of every item shown in a conversation.
///
/// The hierarchy is sealed, so a `switch` over a [ChatMessage] is exhaustive:
///
/// ```dart
/// final preview = switch (message) {
///   TextMessage(:final text) => text,
///   SystemMessage(:final text) => text,
///   CustomMessage(:final type) => '[$type]',
///   _ => '…', // ImageMessage, FileMessage, VoiceMessage, PollMessage, ...
/// };
/// ```
///
/// Use [CustomMessage] for content chatx does not render out of the box, such
/// as images, polls or locations.
@immutable
sealed class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.createdAt,
    this.status,
    this.replyToId,
    this.reactions = const [],
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

  /// Arbitrary data you want to carry with the message. Never read by chatx.
  final Map<String, Object?>? metadata;

  /// Returns a copy of this message with [status] replaced.
  ChatMessage withStatus(MessageStatus? status);

  /// Returns a copy of this message with [reactions] replaced.
  ChatMessage withReactions(List<ChatReaction> reactions);

  bool _baseEquals(ChatMessage other) =>
      other.id == id &&
      other.author == author &&
      other.createdAt == createdAt &&
      other.status == status &&
      other.replyToId == replyToId &&
      listEquals(other.reactions, reactions) &&
      mapEquals(other.metadata, metadata);

  int get _baseHash => Object.hash(
        id,
        author,
        createdAt,
        status,
        replyToId,
        Object.hashAll(reactions),
      );
}

/// A message whose [text] is rendered with chatx's markdown subset.
///
/// Set [isStreaming] to `true` while the text is still being produced, for
/// example by an LLM. The bubble then shows a caret, and
/// `ChatController.appendText` updates only this bubble.
final class TextMessage extends ChatMessage {
  /// Creates a text message.
  const TextMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    required this.text,
    this.isStreaming = false,
    this.editedAt,
    this.linkPreview,
    super.status,
    super.replyToId,
    super.reactions,
    super.metadata,
  });

  /// Message body. Supports **bold**, _italic_, ~~strike~~, `code`, fenced
  /// code blocks, quotes, lists, headings and links.
  final String text;

  /// Whether more text is still expected for this message.
  final bool isStreaming;

  /// When the message was last edited. Shows an "edited" label when set.
  final DateTime? editedAt;

  /// Card shown under the text with a preview of a link.
  final ChatLinkPreview? linkPreview;

  /// Returns a copy of this message with the given fields replaced.
  TextMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    String? text,
    bool? isStreaming,
    DateTime? editedAt,
    ChatLinkPreview? linkPreview,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    Map<String, Object?>? metadata,
  }) {
    return TextMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      text: text ?? this.text,
      isStreaming: isStreaming ?? this.isStreaming,
      editedAt: editedAt ?? this.editedAt,
      linkPreview: linkPreview ?? this.linkPreview,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  TextMessage withStatus(MessageStatus? status) => TextMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        text: text,
        isStreaming: isStreaming,
        editedAt: editedAt,
        linkPreview: linkPreview,
        status: status,
        replyToId: replyToId,
        reactions: reactions,
        metadata: metadata,
      );

  @override
  TextMessage withReactions(List<ChatReaction> reactions) =>
      copyWith(reactions: reactions);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMessage &&
          _baseEquals(other) &&
          other.text == text &&
          other.isStreaming == isStreaming &&
          other.editedAt == editedAt &&
          other.linkPreview == linkPreview;

  @override
  int get hashCode =>
      Object.hash(_baseHash, text, isStreaming, editedAt, linkPreview);

  @override
  String toString() => 'TextMessage(id: $id, author: ${author.id}, '
      'status: $status, isStreaming: $isStreaming)';
}

/// A centered, author-less notice such as "Ana joined the group".
///
/// System messages never group with other messages, have no bubble and
/// ignore replies and reactions.
final class SystemMessage extends ChatMessage {
  /// Creates a system notice.
  const SystemMessage({
    required super.id,
    required super.createdAt,
    required this.text,
    super.author = systemUser,
    super.metadata,
  });

  /// Default author of system messages.
  static const ChatUser systemUser = ChatUser(id: 'chatx.system');

  /// Plain text of the notice. Markdown is not applied.
  final String text;

  @override
  SystemMessage withStatus(MessageStatus? status) => this;

  @override
  SystemMessage withReactions(List<ChatReaction> reactions) => this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMessage && _baseEquals(other) && other.text == text;

  @override
  int get hashCode => Object.hash(_baseHash, text);

  @override
  String toString() => 'SystemMessage(id: $id)';
}

/// A message rendered by your own `customMessageBuilder`.
///
/// Use [type] to tell your kinds apart (for example `'image'` or `'poll'`) and
/// [payload] to carry their data.
final class CustomMessage extends ChatMessage {
  /// Creates a custom message.
  const CustomMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    required this.type,
    this.payload,
    super.status,
    super.replyToId,
    super.reactions,
    super.metadata,
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
    String? type,
    Object? payload,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    Map<String, Object?>? metadata,
  }) {
    return CustomMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  CustomMessage withStatus(MessageStatus? status) => CustomMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        type: type,
        payload: payload,
        status: status,
        replyToId: replyToId,
        reactions: reactions,
        metadata: metadata,
      );

  @override
  CustomMessage withReactions(List<ChatReaction> reactions) =>
      copyWith(reactions: reactions);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomMessage &&
          _baseEquals(other) &&
          other.type == type &&
          other.payload == payload;

  @override
  int get hashCode => Object.hash(_baseHash, type, payload);

  @override
  String toString() => 'CustomMessage(id: $id, type: $type)';
}
