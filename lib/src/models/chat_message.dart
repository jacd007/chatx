import 'package:flutter/foundation.dart';

import 'chat_user.dart';
import 'message_status.dart';

/// Base type of every item shown in a conversation.
///
/// The hierarchy is sealed, so a `switch` over a [ChatMessage] is exhaustive:
///
/// ```dart
/// final preview = switch (message) {
///   TextMessage(:final text) => text,
///   SystemMessage(:final text) => text,
///   CustomMessage(:final type) => '[$type]',
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

  /// Arbitrary data you want to carry with the message. Never read by chatx.
  final Map<String, Object?>? metadata;

  /// Returns a copy of this message with [status] replaced.
  ChatMessage withStatus(MessageStatus? status);
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
    super.status,
    super.metadata,
  });

  /// Message body. Supports **bold**, _italic_, ~~strike~~, `code`, fenced
  /// code blocks, quotes, lists, headings and links.
  final String text;

  /// Whether more text is still expected for this message.
  final bool isStreaming;

  /// When the message was last edited. Shows an "edited" label when set.
  final DateTime? editedAt;

  /// Returns a copy of this message with the given fields replaced.
  TextMessage copyWith({
    String? id,
    ChatUser? author,
    DateTime? createdAt,
    String? text,
    bool? isStreaming,
    DateTime? editedAt,
    MessageStatus? status,
    Map<String, Object?>? metadata,
  }) {
    return TextMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      text: text ?? this.text,
      isStreaming: isStreaming ?? this.isStreaming,
      editedAt: editedAt ?? this.editedAt,
      status: status ?? this.status,
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
        status: status,
        metadata: metadata,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMessage &&
          other.id == id &&
          other.author == author &&
          other.createdAt == createdAt &&
          other.status == status &&
          other.text == text &&
          other.isStreaming == isStreaming &&
          other.editedAt == editedAt &&
          mapEquals(other.metadata, metadata);

  @override
  int get hashCode => Object.hash(
        id,
        author,
        createdAt,
        status,
        text,
        isStreaming,
        editedAt,
      );

  @override
  String toString() => 'TextMessage(id: $id, author: ${author.id}, '
      'status: $status, isStreaming: $isStreaming)';
}

/// A centered, author-less notice such as "Ana joined the group".
///
/// System messages never group with other messages and have no bubble.
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMessage &&
          other.id == id &&
          other.author == author &&
          other.createdAt == createdAt &&
          other.text == text &&
          mapEquals(other.metadata, metadata);

  @override
  int get hashCode => Object.hash(id, author, createdAt, text);

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
    super.metadata,
  });

  /// Your discriminator for this kind of message.
  final String type;

  /// Data your builder needs to render the message.
  final Object? payload;

  @override
  CustomMessage withStatus(MessageStatus? status) => CustomMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        type: type,
        payload: payload,
        status: status,
        metadata: metadata,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomMessage &&
          other.id == id &&
          other.author == author &&
          other.createdAt == createdAt &&
          other.status == status &&
          other.type == type &&
          other.payload == payload &&
          mapEquals(other.metadata, metadata);

  @override
  int get hashCode => Object.hash(id, author, createdAt, status, type, payload);

  @override
  String toString() => 'CustomMessage(id: $id, type: $type)';
}
