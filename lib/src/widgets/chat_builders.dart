import 'package:flutter/foundation.dart';
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

  /// Swipe to reply: starts a reply through `ChatComposerController.startReply`.
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

/// An action of the selection bar, applied to every selected message.
@immutable
class ChatSelectionAction {
  /// Creates a selection action.
  const ChatSelectionAction({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.isDestructive = false,
  });

  /// Tooltip and accessibility label.
  final String label;

  /// Icon of the button.
  final IconData icon;

  /// Shows the button in the error color.
  final bool isDestructive;

  /// Called with the selected messages, oldest first. Selection mode ends
  /// afterwards.
  final ValueChanged<List<ChatMessage>> onSelected;
}

/// Returns the buttons of the selection bar for [selected] messages.
///
/// [defaults] holds the built-in actions (copy, delete) that apply.
typedef ChatSelectionActionsBuilder = List<ChatSelectionAction> Function(
  BuildContext context,
  List<ChatMessage> selected,
  List<ChatSelectionAction> defaults,
);

/// Called when the user votes in a poll.
typedef ChatPollVoteCallback = void Function(
  PollMessage message,
  String optionId,
);

/// Called when the user taps an image of an [ImageMessage].
typedef ChatImageTapCallback = void Function(ImageMessage message, int index);

/// Called when a voice recording ends. [cancelled] is `true` when the user
/// slid away to discard it.
typedef ChatVoiceRecordEndCallback = void Function(
  Duration duration, {
  required bool cancelled,
});

/// Called when the user pins or unpins a message.
typedef ChatPinCallback = void Function(ChatMessage message, bool pinned);

/// What the user chose on a contact card.
enum ChatContactAction {
  /// Call the phone number.
  call,

  /// Write to the email address.
  email,

  /// Save the contact to the device.
  save,
}

/// Called when the user answers an event invitation. `null` removes the
/// answer.
typedef ChatRsvpCallback = void Function(EventMessage message, ChatRsvp? rsvp);

/// Called when the user rates an AI answer. `null` removes the rating.
typedef ChatFeedbackCallback = void Function(
  TextMessage message,
  ChatFeedback? feedback,
);

/// Hides offensive words by replacing their letters with asterisks.
///
/// chatx ships no word list: provide the words for your audience and
/// languages. Matching ignores case and only affects whole words.
///
/// ```dart
/// ChatView(wordFilter: ChatWordFilter({'darn', 'heck'}), ...)
/// ```
@immutable
class ChatWordFilter {
  /// Creates a filter for [words].
  ChatWordFilter(Set<String> words, {this.mask = '*'})
      : words = Set.unmodifiable({
          for (final w in words)
            if (w.trim().isNotEmpty) w.trim().toLowerCase(),
        });

  /// Lowercase words to hide.
  final Set<String> words;

  /// Character that replaces each hidden letter.
  final String mask;

  late final RegExp? _pattern = words.isEmpty
      ? null
      : RegExp(
          '(?<![\\p{L}\\p{N}_])(${words.map(RegExp.escape).join('|')})'
          '(?![\\p{L}\\p{N}_])',
          caseSensitive: false,
          unicode: true,
        );

  /// Returns [text] with filtered words masked. The first letter stays, so
  /// readers still get the tone: "d***".
  String apply(String text) {
    final pattern = _pattern;
    if (pattern == null) return text;
    return text.replaceAllMapped(pattern, (m) {
      final word = m[0]!;
      final runes = word.runes.toList();
      return String.fromCharCode(runes.first) + mask * (runes.length - 1);
    });
  }

  @override
  bool operator ==(Object other) =>
      other is ChatWordFilter &&
      setEquals(other.words, words) &&
      other.mask == mask;

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(words), mask);
}

/// What the user did with a [PaymentMessage].
enum ChatPaymentAction {
  /// The user wants to pay the request.
  pay,

  /// The user declined the request.
  decline,
}

/// Network state shown by `ChatView.connectionState`.
enum ChatConnectionState {
  /// Connected. No banner.
  online,

  /// Reconnecting. Shows "Connecting…".
  connecting,

  /// No network. Shows "Waiting for network…".
  offline,
}

/// A suggested prompt shown in the empty state of AI chats.
@immutable
class ChatPrompt {
  /// Creates a suggested prompt.
  const ChatPrompt({required this.title, this.subtitle, this.text, this.icon});

  /// Main line of the card, for example "Plan a trip".
  final String title;

  /// Second line of the card, for example "to Lisbon in spring".
  final String? subtitle;

  /// Text sent when the card is tapped. Defaults to [title] and [subtitle]
  /// joined by a space.
  final String? text;

  /// Optional icon of the card.
  final IconData? icon;

  /// The text that is sent.
  String get message =>
      text ?? [title, if (subtitle != null) subtitle].join(' ');
}
