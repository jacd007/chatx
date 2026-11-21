import 'package:flutter/foundation.dart';

import 'chat_message.dart' show ChatRole;

/// A participant in a conversation.
///
/// Two users are considered the same author when their [id]s match. The
/// [name] and [avatarUrl] are only used for display.
@immutable
class ChatUser {
  /// Creates a chat participant.
  const ChatUser({
    required this.id,
    this.name,
    this.avatarUrl,
    this.isBot = false,
    this.role,
    this.metadata,
  });

  /// Stable, unique identifier of the user (for example, your backend user ID).
  final String id;

  /// Display name. When `null`, the UI falls back to [initials] derived from
  /// [id] and hides the name label.
  final String? name;

  /// Network URL of the avatar image. When `null` or when the image fails to
  /// load, the avatar shows [initials].
  final String? avatarUrl;

  /// Whether the user is a bot or AI assistant. Its answers get the AI
  /// actions (copy, rate, regenerate) when `ChatView` enables them.
  final bool isBot;

  /// Role in a group, shown as a badge next to the name.
  final ChatRole? role;

  /// Arbitrary data you want to carry with the user. Never read by chatx.
  final Map<String, Object?>? metadata;

  /// Up to two uppercase initials taken from [name], or from [id] when the
  /// name is missing.
  String get initials {
    final source = (name?.trim().isNotEmpty ?? false) ? name!.trim() : id;
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final first = String.fromCharCodes(parts.first.runes.take(1));
    if (parts.length == 1) return first.toUpperCase();
    final last = String.fromCharCodes(parts.last.runes.take(1));
    return '$first$last'.toUpperCase();
  }

  /// Returns a copy of this user with the given fields replaced.
  ChatUser copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isBot,
    ChatRole? role,
    bool clearRole = false,
    Map<String, Object?>? metadata,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isBot: isBot ?? this.isBot,
      role: clearRole ? null : role ?? this.role,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatUser &&
          other.id == id &&
          other.name == name &&
          other.avatarUrl == avatarUrl &&
          other.isBot == isBot &&
          other.role == role &&
          mapEquals(other.metadata, metadata);

  @override
  int get hashCode => Object.hash(id, name, avatarUrl, isBot, role);

  @override
  String toString() => 'ChatUser(id: $id, name: $name)';
}
