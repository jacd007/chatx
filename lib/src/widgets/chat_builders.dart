import 'package:flutter/services.dart';

import '../material.dart';
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

/// An entry of the message menu.
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
  /// The default menu already includes it. Use it when you build the menu
  /// from scratch. Pass the label from `ChatLocalizations.of(context).copy`.
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

/// How the message menu is shown.
enum ChatMessageMenuStyle {
  /// A modal bottom sheet, easy to reach with the thumb.
  bottomSheet,

  /// A popup menu anchored to the bubble.
  popup,
}

/// Which gesture opens the message menu.
enum ChatMessageMenuTrigger {
  /// Long press on the bubble. A tap calls `ChatView.onMessageTap`.
  longPress,

  /// Tap on the bubble. `ChatView.onMessageTap` is not called.
  tap,
}

/// Action performed when the user swipes a message bubble sideways.
///
/// The bubble follows the finger, an icon appears behind it, and the action
/// runs with haptic feedback when the swipe passes a threshold. Screen reader
/// users get the same action as a custom accessibility action.
@immutable
class ChatSwipeAction {
  /// Creates a custom swipe action.
  const ChatSwipeAction({
    required this.icon,
    required ValueChanged<ChatMessage> this.onTriggered,
    this.label,
  });

  /// Swipe to reply: starts a reply through `ChatController.startReply`.
  const ChatSwipeAction.reply({this.icon = Icons.reply_rounded, this.label})
      : onTriggered = null;

  /// Icon shown behind the bubble while swiping.
  final IconData icon;

  /// Called with the message when the swipe completes. `null` for
  /// [ChatSwipeAction.reply].
  final ValueChanged<ChatMessage>? onTriggered;

  /// Accessibility label. Defaults to the localized "Reply".
  final String? label;
}

/// Called when the user sends a message.
///
/// [replyTo] is the message being replied to, or `null`.
typedef ChatSendCallback = void Function(String text, ChatMessage? replyTo);

/// Called when the user saves an edited message.
typedef ChatEditCallback = void Function(TextMessage message, String newText);

/// Called when the user picks or taps a reaction.
typedef ChatReactionCallback = void Function(ChatMessage message, String emoji);

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

/// Builds the input bar.
///
/// Call [send] with the text to send. Use [textController] for your text
/// field so that editing a message can fill it in.
typedef ChatInputBuilder = Widget Function(
  BuildContext context,
  ValueChanged<String> send,
  TextEditingController textController,
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

/// Returns the menu entries for [message].
///
/// [defaults] holds the built-in entries that apply to this message (reply,
/// copy, edit, delete). Return them, a modified copy, or your own list. An
/// empty list disables the menu for that message.
typedef ChatMessageActionsBuilder = List<ChatMessageAction> Function(
  BuildContext context,
  ChatMessage message,
  List<ChatMessageAction> defaults,
);
