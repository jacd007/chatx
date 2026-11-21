import 'package:flutter/foundation.dart';

import '../material.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import '../models/voice_playback.dart';
import 'chat_builders.dart';

/// Builders that replace pieces of the default UI of `ChatView`.
///
/// Pass it as `ChatView.builders`.
@immutable
class ChatBuilders {
  /// Creates the builders of a `ChatView`.
  const ChatBuilders({
    this.bubbleBuilder,
    this.customMessageBuilder,
    this.customMessageBuilders = const {},
    this.systemMessageBuilder,
    this.avatarBuilder,
    this.inputBuilder,
    this.dateSeparatorBuilder,
    this.typingIndicatorBuilder,
    this.scrollToBottomBuilder,
    this.loadMoreIndicatorBuilder,
    this.emptyStateBuilder,
    this.imageProviderBuilder,
    this.locationMapBuilder,
  });

  /// Wraps or replaces message bubbles.
  final ChatBubbleBuilder? bubbleBuilder;

  /// Renders [CustomMessage]s inside a bubble when [customMessageBuilders]
  /// has no builder for their type.
  final ChatCustomMessageBuilder? customMessageBuilder;

  /// Renders [CustomMessage]s inside a bubble, by [CustomMessage.type].
  ///
  /// This is how you add message types: the set of built-in types is
  /// fixed, so a `switch` over `ChatMessage` stays exhaustive across
  /// versions.
  ///
  /// ```dart
  /// ChatBuilders(customMessageBuilders: {
  ///   'invoice': (context, message, details) => InvoiceCard(message.payload),
  /// })
  /// ```
  final Map<String, ChatCustomMessageBuilder> customMessageBuilders;

  /// Renders [SystemMessage]s.
  final ChatSystemMessageBuilder? systemMessageBuilder;

  /// Replaces avatars.
  final ChatAvatarBuilder? avatarBuilder;

  /// Replaces the input bar. See `ChatInput`.
  final ChatInputBuilder? inputBuilder;

  /// Replaces day labels.
  final ChatDateSeparatorBuilder? dateSeparatorBuilder;

  /// Replaces the typing indicator.
  final ChatTypingIndicatorBuilder? typingIndicatorBuilder;

  /// Replaces the scroll-to-bottom button.
  final ChatScrollToBottomBuilder? scrollToBottomBuilder;

  /// Replaces the progress indicator shown while `ChatView.onLoadMore` runs.
  final WidgetBuilder? loadMoreIndicatorBuilder;

  /// Shown when there are no messages.
  final WidgetBuilder? emptyStateBuilder;

  /// Turns an image URI ([ChatImage.uri], [ChatLinkPreview.imageUri]) into
  /// an [ImageProvider]. Defaults to [NetworkImage]. Use it for assets,
  /// files, caching or authenticated requests.
  final ImageProvider Function(String uri)? imageProviderBuilder;

  /// Draws the map of a [LocationMessage], for example with your maps SDK.
  final Widget Function(BuildContext context, LocationMessage message)?
      locationMapBuilder;
}

/// Controls for AI assistant answers in `ChatView`.
///
/// Pass it as `ChatView.ai`.
@immutable
class ChatAiOptions {
  /// Creates the ai of a `ChatView`.
  const ChatAiOptions({
    this.onRegenerate,
    this.onFeedback,
    this.onStopGenerating,
    this.onTranslate,
    this.onReasoningTap,
    this.onSourceTap,
    this.suggestedPrompts = const [],
  });

  /// Called when the user asks for a new answer to the newest message of a
  /// bot ([ChatUser.isBot]). Shows a regenerate button under it.
  final ValueChanged<TextMessage>? onRegenerate;

  /// Called when the user rates an answer of a bot. Shows thumbs up and down
  /// under bot answers.
  final ChatFeedbackCallback? onFeedback;

  /// Called when the user taps stop while the newest incoming message is
  /// streaming. The send button turns into a stop button meanwhile.
  final ValueChanged<TextMessage>? onStopGenerating;

  /// Translates a message. When set, the menu offers "Translate" and the
  /// bubble can switch between the translation and the original.
  final Future<String> Function(TextMessage message)? onTranslate;

  /// Called when the user expands or collapses a reasoning block. Optional;
  /// the block works without it.
  final ValueChanged<TextMessage>? onReasoningTap;

  /// Called when the user taps a source chip. Defaults to `ChatView.onLinkTap`
  /// with the source URL.
  final ValueChanged<ChatSource>? onSourceTap;

  /// Cards shown in the empty conversation. Tapping one sends its text.
  final List<ChatPrompt> suggestedPrompts;
}

/// Moderation tools of `ChatView`: read-only channels, slow mode, reports,
/// blocks and the word filter.
///
/// Pass it as `ChatView.moderation`.
@immutable
class ChatModerationOptions {
  /// Creates the moderation of a `ChatView`.
  const ChatModerationOptions({
    this.readOnly = false,
    this.readOnlyMessage,
    this.slowMode,
    this.onReportMessage,
    this.onBlockUser,
    this.wordFilter,
    this.onDeleteForEveryone,
  });

  /// Replaces the input with a banner, for channels where only some people
  /// can write.
  final bool readOnly;

  /// Text of the read-only banner. Defaults to the localized "Only admins
  /// can send messages".
  final String? readOnlyMessage;

  /// Minimum time between two messages of the current user. The input is
  /// disabled with a countdown in between.
  final Duration? slowMode;

  /// Called when the user reports a message of someone else.
  final ValueChanged<ChatMessage>? onReportMessage;

  /// Called when the user blocks the author of a message.
  final ValueChanged<ChatUser>? onBlockUser;

  /// Masks offensive words in messages.
  final ChatWordFilter? wordFilter;

  /// Called when the user deletes their message for everyone. Offered in
  /// the menu when set; usually calls `ChatController.markDeleted`.
  final ValueChanged<ChatMessage>? onDeleteForEveryone;
}

/// Callbacks of images, files, video and voice notes in `ChatView`.
///
/// Pass it as `ChatView.media`.
@immutable
class ChatMediaOptions {
  /// Creates the media of a `ChatView`.
  const ChatMediaOptions({
    this.onImageTap,
    this.onFileTap,
    this.voicePlayback,
    this.onVoicePlay,
    this.onVoicePause,
    this.onVoiceSeek,
    this.onVoiceRecordStart,
    this.onVoiceRecordEnd,
    this.onVideoTap,
    this.onTranscribe,
  });

  /// Called when an image is tapped. When `null`, chatx opens a full-screen
  /// viewer with zoom and swipe-down to close.
  final ChatImageTapCallback? onImageTap;

  /// Called when a [FileMessage] is tapped. Open or download the file here.
  final ValueChanged<FileMessage>? onFileTap;

  /// What your audio player is doing. Drives play buttons and progress of
  /// [VoiceMessage]s.
  final ValueListenable<ChatVoicePlayback?>? voicePlayback;

  /// Called when the user taps play on a voice note.
  final ValueChanged<VoiceMessage>? onVoicePlay;

  /// Called when the user taps pause on a voice note.
  final ValueChanged<VoiceMessage>? onVoicePause;

  /// Called when the user taps the waveform to jump to a position.
  final void Function(VoiceMessage message, Duration position)? onVoiceSeek;

  /// Called when the user starts holding the microphone button. When set,
  /// the send button turns into a microphone while the input is empty.
  final VoidCallback? onVoiceRecordStart;

  /// Called when the user releases the microphone button or slides to
  /// cancel.
  final ChatVoiceRecordEndCallback? onVoiceRecordEnd;

  /// Called when the user taps a [VideoMessage]. Play the video here.
  final ValueChanged<VideoMessage>? onVideoTap;

  /// Called when the user asks for the transcript of a voice note. Produce
  /// it and update the message with `VoiceMessage.transcript`. While the
  /// future runs, the bubble shows "Transcribing…".
  final Future<void> Function(VoiceMessage message)? onTranscribe;
}

/// Callbacks of the rich content `ChatView` renders: polls, surveys, bot
/// buttons, quick replies, locations, events, contacts, checklists, products,
/// payments and calls.
///
/// Pass it as `ChatView.contentCallbacks`.
@immutable
class ChatContentCallbacks {
  /// Creates the contentCallbacks of a `ChatView`.
  const ChatContentCallbacks({
    this.onPollVote,
    this.onSurveySubmit,
    this.onMessageButton,
    this.onQuickReply,
    this.onLocationTap,
    this.onRsvp,
    this.onContactAction,
    this.onChecklistToggle,
    this.onProductTap,
    this.onPaymentAction,
    this.onCallBack,
  });

  /// Called when the user votes in a [PollMessage]. Typically calls
  /// `ChatController.votePoll` and your backend. When `null`, polls are
  /// read-only.
  final ChatPollVoteCallback? onPollVote;

  /// Called with the answers when the user completes a [SurveyMessage].
  /// When `null`, surveys cannot be answered.
  final void Function(SurveyMessage survey, ChatSurveyResponse response)?
      onSurveySubmit;

  /// Called when the user taps a [ChatMessageButton] of a [TextMessage].
  final void Function(ChatMessage message, ChatMessageButton button)?
      onMessageButton;

  /// Called when the user taps a quick reply. When `null`, the reply text is
  /// sent through `ChatView.onSend`.
  final void Function(ChatQuickReply reply, ChatMessage message)? onQuickReply;

  /// Called when a location card is tapped, for example to open a maps app.
  final ValueChanged<LocationMessage>? onLocationTap;

  /// Called when the user answers an [EventMessage].
  final ChatRsvpCallback? onRsvp;

  /// Called when the user taps a button of a [ContactMessage].
  final void Function(ContactMessage message, ChatContactAction action)?
      onContactAction;

  /// Called when the user checks or unchecks an item of a
  /// [ChecklistMessage]. Record it with `ChatController.toggleChecklistItem`.
  final void Function(ChecklistMessage message, ChecklistItem item)?
      onChecklistToggle;

  /// Called when the user taps a product of a [ProductMessage].
  final void Function(ProductMessage message, ChatProduct product)?
      onProductTap;

  /// Called when the user pays or declines a [PaymentMessage].
  final void Function(PaymentMessage message, ChatPaymentAction action)?
      onPaymentAction;

  /// Called when the user taps "Call back" on a [CallMessage].
  final ValueChanged<CallMessage>? onCallBack;
}
