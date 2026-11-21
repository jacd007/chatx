import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/chat_message.dart';
import '../models/chat_user.dart';

/// Layout information about one message in the list.
@immutable
class ChatMessageDetails {
  /// Creates message details.
  const ChatMessageDetails({
    required this.message,
    required this.isOutgoing,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });

  /// The message, in its latest version.
  final ChatMessage message;

  /// Whether the current user wrote the message.
  final bool isOutgoing;

  /// Whether this is the top (oldest) message of a group of consecutive
  /// messages by the same author.
  final bool isFirstInGroup;

  /// Whether this is the bottom (newest) message of its group.
  final bool isLastInGroup;

  @override
  bool operator ==(Object other) =>
      other is ChatMessageDetails &&
      other.message == message &&
      other.isOutgoing == isOutgoing &&
      other.isFirstInGroup == isFirstInGroup &&
      other.isLastInGroup == isLastInGroup;

  @override
  int get hashCode =>
      Object.hash(message, isOutgoing, isFirstInGroup, isLastInGroup);
}

/// An entry of the long-press menu of a message.
@immutable
class ChatMessageAction {
  /// Creates a menu action.
  const ChatMessageAction({
    required this.label,
    required this.onSelected,
    this.icon,
    this.isDestructive = false,
  });

  /// Text of the menu entry.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Shows the entry in the error color, for actions such as "Delete".
  final bool isDestructive;

  /// Called with the message after the menu closes.
  final ValueChanged<ChatMessage> onSelected;

  /// Action that copies the text of a [TextMessage] to the clipboard.
  ///
  /// Use it to keep the default "copy" entry when you provide your own
  /// actions. Pass the label from `ChatLocalizations.of(context).copy`.
  static ChatMessageAction copyText({
    required String label,
    IconData? icon,
  }) {
    return ChatMessageAction(
      label: label,
      icon: icon,
      onSelected: (message) {
        if (message is TextMessage) {
          Clipboard.setData(ClipboardData(text: message.text));
        }
      },
    );
  }
}

/// Wraps or replaces the default bubble of a message.
///
/// [defaultBubble] is the bubble chatx would render. Return it wrapped to
/// decorate it, or ignore it to draw your own.
typedef ChatBubbleBuilder = Widget Function(
  BuildContext context,
  ChatMessageDetails details,
  Widget defaultBubble,
);

/// Builds the content of a `CustomMessage`. The result is placed inside the
/// regular bubble.
typedef ChatCustomMessageBuilder = Widget Function(
  BuildContext context,
  CustomMessage message,
  ChatMessageDetails details,
);

/// Builds a `SystemMessage`.
typedef ChatSystemMessageBuilder = Widget Function(
  BuildContext context,
  SystemMessage message,
);

/// Builds the avatar of [user].
typedef ChatAvatarBuilder = Widget Function(
  BuildContext context,
  ChatUser user,
);

/// Builds the input bar. Call [send] with the text to send.
typedef ChatInputBuilder = Widget Function(
  BuildContext context,
  ValueChanged<String> send,
);

/// Builds the label between messages of different days. [day] is the local
/// date at midnight.
typedef ChatDateSeparatorBuilder = Widget Function(
  BuildContext context,
  DateTime day,
);

/// Builds the typing indicator for a non-empty list of [users].
typedef ChatTypingIndicatorBuilder = Widget Function(
  BuildContext context,
  List<ChatUser> users,
);

/// Builds the scroll-to-bottom button.
typedef ChatScrollToBottomBuilder = Widget Function(
  BuildContext context,
  int unreadCount,
  VoidCallback scrollToBottom,
);

/// Returns the long-press menu entries for [message]. Return an empty list
/// to disable the menu for that message.
typedef ChatMessageActionsBuilder = List<ChatMessageAction> Function(
  BuildContext context,
  ChatMessage message,
);
