import 'package:flutter/foundation.dart';

/// One emoji reaction on a message, with the users who chose it.
@immutable
class ChatReaction {
  /// Creates a reaction.
  const ChatReaction({required this.emoji, required this.userIds});

  /// The emoji, for example `'👍'`.
  final String emoji;

  /// IDs of the users who reacted with [emoji], in the order they reacted.
  final List<String> userIds;

  /// Number of users who reacted with [emoji].
  int get count => userIds.length;

  /// Whether the user with [userId] reacted with [emoji].
  bool hasUser(String userId) => userIds.contains(userId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatReaction &&
          other.emoji == emoji &&
          listEquals(other.userIds, userIds);

  @override
  int get hashCode => Object.hash(emoji, Object.hashAll(userIds));

  @override
  String toString() => 'ChatReaction($emoji × $count)';
}
