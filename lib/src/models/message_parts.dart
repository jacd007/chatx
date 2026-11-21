part of 'chat_message.dart';

/// One image of an [ImageMessage].
@immutable
class ChatImage {
  /// Creates an image reference.
  const ChatImage({required this.uri, this.width, this.height});

  /// Where the image lives. By default chatx loads it with
  /// `Image.network`. Use `ChatView.imageProviderBuilder` for files, assets
  /// or authenticated URLs.
  final String uri;

  /// Original width in pixels. With [height], lets chatx reserve the right
  /// space before the image loads, so the list does not jump.
  final int? width;

  /// Original height in pixels.
  final int? height;

  /// Width divided by height, or `null` when unknown.
  double? get aspectRatio {
    final w = width;
    final h = height;
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return w / h;
  }

  @override
  bool operator ==(Object other) =>
      other is ChatImage &&
      other.uri == uri &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(uri, width, height);
}

/// One answer of a [PollMessage].
@immutable
class PollOption {
  /// Creates a poll option.
  const PollOption({
    required this.id,
    required this.text,
    this.voterIds = const [],
  });

  /// Identifier of the option inside its poll.
  final String id;

  /// Text of the option.
  final String text;

  /// IDs of the users who chose this option.
  final List<String> voterIds;

  /// Number of votes.
  int get votes => voterIds.length;

  /// Returns a copy with [voterIds] replaced.
  PollOption withVoters(List<String> voterIds) =>
      PollOption(id: id, text: text, voterIds: voterIds);

  @override
  bool operator ==(Object other) =>
      other is PollOption &&
      other.id == id &&
      other.text == text &&
      listEquals(other.voterIds, voterIds);

  @override
  int get hashCode => Object.hash(id, text, Object.hashAll(voterIds));
}

/// Metadata of a link shown as a card under a [TextMessage].
///
/// chatx never fetches anything: your app or backend fills these fields
/// (for example from Open Graph tags) and sets [TextMessage.linkPreview].
@immutable
class ChatLinkPreview {
  /// Creates link preview data.
  const ChatLinkPreview({
    required this.url,
    this.title,
    this.description,
    this.imageUri,
    this.siteName,
  });

  /// The link. Tapping the card calls `ChatView.onLinkTap` with it, if the
  /// link policy allows it.
  final String url;

  /// Page title.
  final String? title;

  /// Short description.
  final String? description;

  /// Preview image, loaded like [ChatImage.uri].
  final String? imageUri;

  /// Site name, for example "GitHub". Defaults to the host of [url].
  final String? siteName;

  @override
  bool operator ==(Object other) =>
      other is ChatLinkPreview &&
      other.url == url &&
      other.title == title &&
      other.description == description &&
      other.imageUri == imageUri &&
      other.siteName == siteName;

  @override
  int get hashCode => Object.hash(url, title, description, imageUri, siteName);
}

/// Summary of the thread started from a message.
@immutable
class ChatThreadSummary {
  /// Creates a thread summary.
  const ChatThreadSummary({
    required this.replyCount,
    this.participants = const [],
    this.lastReplyAt,
  });

  /// Number of replies in the thread.
  final int replyCount;

  /// Some of the users who replied. Up to three avatars are shown.
  final List<ChatUser> participants;

  /// When the latest reply was sent.
  final DateTime? lastReplyAt;

  @override
  bool operator ==(Object other) =>
      other is ChatThreadSummary &&
      other.replyCount == replyCount &&
      listEquals(other.participants, participants) &&
      other.lastReplyAt == lastReplyAt;

  @override
  int get hashCode =>
      Object.hash(replyCount, Object.hashAll(participants), lastReplyAt);
}

/// A user who read a message, and when.
@immutable
class ChatReadReceipt {
  /// Creates a read receipt.
  const ChatReadReceipt({required this.user, required this.readAt});

  /// The reader.
  final ChatUser user;

  /// When they read the message.
  final DateTime readAt;

  @override
  bool operator ==(Object other) =>
      other is ChatReadReceipt && other.user == user && other.readAt == readAt;

  @override
  int get hashCode => Object.hash(user, readAt);
}

/// Visual weight of a [ChatMessageButton].
enum ChatButtonStyle {
  /// Filled button for the main action.
  primary,

  /// Outlined button for other actions.
  secondary,
}

/// A button inside a [TextMessage], typically sent by a bot.
@immutable
class ChatMessageButton {
  /// Creates a message button.
  const ChatMessageButton({
    required this.id,
    required this.label,
    this.style = ChatButtonStyle.secondary,
    this.payload,
  });

  /// Identifier you use to handle the tap.
  final String id;

  /// Text of the button.
  final String label;

  /// Filled or outlined.
  final ChatButtonStyle style;

  /// Data your handler needs, for example a URL or a command.
  final Object? payload;

  @override
  bool operator ==(Object other) =>
      other is ChatMessageButton &&
      other.id == id &&
      other.label == label &&
      other.style == style &&
      other.payload == payload;

  @override
  int get hashCode => Object.hash(id, label, style, payload);
}

/// A suggested answer shown as a chip above the input.
@immutable
class ChatQuickReply {
  /// Creates a quick reply.
  const ChatQuickReply({required this.label, this.value});

  /// Text of the chip.
  final String label;

  /// Text sent when tapped. Defaults to [label].
  final String? value;

  /// The text sent for this reply.
  String get text => value ?? label;

  @override
  bool operator ==(Object other) =>
      other is ChatQuickReply && other.label == label && other.value == value;

  @override
  int get hashCode => Object.hash(label, value);
}

/// One question of a [SurveyMessage].
@immutable
sealed class SurveyQuestion {
  const SurveyQuestion({
    required this.id,
    required this.title,
    this.description,
    this.isRequired = true,
  });

  /// Identifier used as the key in [ChatSurveyResponse.answers].
  final String id;

  /// The question.
  final String title;

  /// Optional help text under the question.
  final String? description;

  /// Whether the user must answer before continuing.
  final bool isRequired;

  bool _same(SurveyQuestion other) =>
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.isRequired == isRequired;
}

/// An option of a [ChoiceQuestion].
@immutable
class SurveyChoice {
  /// Creates a choice.
  const SurveyChoice({required this.id, required this.text});

  /// Identifier stored in the answer.
  final String id;

  /// Text shown to the user.
  final String text;

  @override
  bool operator ==(Object other) =>
      other is SurveyChoice && other.id == id && other.text == text;

  @override
  int get hashCode => Object.hash(id, text);
}

/// Pick one (or several) options. The answer is a `List<String>` of choice
/// IDs.
final class ChoiceQuestion extends SurveyQuestion {
  /// Creates a choice question.
  const ChoiceQuestion({
    required super.id,
    required super.title,
    required this.choices,
    this.allowsMultipleAnswers = false,
    super.description,
    super.isRequired,
  });

  /// The options.
  final List<SurveyChoice> choices;

  /// Whether several options may be chosen.
  final bool allowsMultipleAnswers;

  @override
  bool operator ==(Object other) =>
      other is ChoiceQuestion &&
      _same(other) &&
      listEquals(other.choices, choices) &&
      other.allowsMultipleAnswers == allowsMultipleAnswers;

  @override
  int get hashCode =>
      Object.hash(id, title, Object.hashAll(choices), allowsMultipleAnswers);
}

/// How a [RatingQuestion] is drawn.
enum RatingStyle {
  /// Stars.
  stars,

  /// Faces from unhappy to happy. Works best with five steps.
  emoji,
}

/// Rate from 1 to [max]. The answer is an `int`.
final class RatingQuestion extends SurveyQuestion {
  /// Creates a rating question.
  const RatingQuestion({
    required super.id,
    required super.title,
    this.max = 5,
    this.style = RatingStyle.stars,
    super.description,
    super.isRequired,
  }) : assert(max >= 2 && max <= 10, 'max must be between 2 and 10');

  /// Highest rating.
  final int max;

  /// Stars or faces.
  final RatingStyle style;

  @override
  bool operator ==(Object other) =>
      other is RatingQuestion &&
      _same(other) &&
      other.max == max &&
      other.style == style;

  @override
  int get hashCode => Object.hash(id, title, max, style);
}

/// Net Promoter Score: "How likely are you to recommend us?" from 0 to 10.
/// The answer is an `int`.
final class NpsQuestion extends SurveyQuestion {
  /// Creates an NPS question.
  const NpsQuestion({
    required super.id,
    required super.title,
    this.lowLabel,
    this.highLabel,
    super.description,
    super.isRequired,
  });

  /// Label under 0. Defaults to the localized "Not likely".
  final String? lowLabel;

  /// Label under 10. Defaults to the localized "Very likely".
  final String? highLabel;

  @override
  bool operator ==(Object other) =>
      other is NpsQuestion &&
      _same(other) &&
      other.lowLabel == lowLabel &&
      other.highLabel == highLabel;

  @override
  int get hashCode => Object.hash(id, title, lowLabel, highLabel);
}

/// Free-text answer. The answer is a `String`.
final class TextQuestion extends SurveyQuestion {
  /// Creates a text question.
  const TextQuestion({
    required super.id,
    required super.title,
    this.hint,
    this.maxLength,
    super.description,
    super.isRequired,
  });

  /// Placeholder of the field.
  final String? hint;

  /// Optional character limit.
  final int? maxLength;

  @override
  bool operator ==(Object other) =>
      other is TextQuestion &&
      _same(other) &&
      other.hint == hint &&
      other.maxLength == maxLength;

  @override
  int get hashCode => Object.hash(id, title, hint, maxLength);
}

/// Answers to a [SurveyMessage], keyed by [SurveyQuestion.id].
@immutable
class ChatSurveyResponse {
  /// Creates a survey response.
  const ChatSurveyResponse({required this.surveyId, required this.answers});

  /// ID of the survey message.
  final String surveyId;

  /// Answers by question ID. Unanswered optional questions are absent.
  /// Values are `List<String>` (choices), `int` (rating, NPS) or `String`.
  final Map<String, Object> answers;

  /// Chosen option IDs of a [ChoiceQuestion].
  List<String> choices(String questionId) =>
      (answers[questionId] as List<String>?) ?? const [];

  /// Value of a [RatingQuestion] or [NpsQuestion].
  int? rating(String questionId) => answers[questionId] as int?;

  /// Text of a [TextQuestion].
  String? text(String questionId) => answers[questionId] as String?;

  @override
  bool operator ==(Object other) =>
      other is ChatSurveyResponse &&
      other.surveyId == surveyId &&
      mapEquals(other.answers, answers);

  @override
  int get hashCode => Object.hash(surveyId, answers.length);
}

/// Rating of an AI answer.
enum ChatFeedback {
  /// Thumbs up.
  positive,

  /// Thumbs down.
  negative,
}

/// A previous version of an edited [TextMessage].
@immutable
class ChatEdit {
  /// Creates an edit record.
  const ChatEdit({required this.text, required this.at});

  /// The text before the edit.
  final String text;

  /// When this version was written.
  final DateTime at;

  @override
  bool operator ==(Object other) =>
      other is ChatEdit && other.text == text && other.at == at;

  @override
  int get hashCode => Object.hash(text, at);
}

/// Answer to an [EventMessage].
enum ChatRsvp {
  /// Will attend.
  going,

  /// Might attend.
  maybe,

  /// Will not attend.
  notGoing,
}

/// A sticker that can be sent from the picker.
@immutable
class ChatSticker {
  /// Creates a sticker.
  const ChatSticker({required this.id, required this.uri, this.label});

  /// Identifier of the sticker.
  final String id;

  /// Image of the sticker, loaded like `ChatImage.uri`.
  final String uri;

  /// Description for screen readers.
  final String? label;

  @override
  bool operator ==(Object other) =>
      other is ChatSticker &&
      other.id == id &&
      other.uri == uri &&
      other.label == label;

  @override
  int get hashCode => Object.hash(id, uri, label);
}

/// A group of stickers shown as a tab in `ChatEmojiPicker`.
@immutable
class ChatStickerPack {
  /// Creates a sticker pack.
  const ChatStickerPack({
    required this.id,
    required this.name,
    required this.stickers,
  });

  /// Identifier of the pack.
  final String id;

  /// Name shown as the tab tooltip.
  final String name;

  /// The stickers. The first one is used as the tab icon.
  final List<ChatSticker> stickers;

  @override
  bool operator ==(Object other) =>
      other is ChatStickerPack &&
      other.id == id &&
      other.name == name &&
      listEquals(other.stickers, stickers);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(stickers));
}

/// The reasoning an AI model showed before its answer.
@immutable
class ChatReasoning {
  /// Creates a reasoning block.
  const ChatReasoning({
    required this.text,
    this.duration,
    this.isActive = false,
  });

  /// The reasoning text. Supports markdown.
  final String text;

  /// How long the model thought. Shown as "Thought for 12s".
  final Duration? duration;

  /// Whether the model is still thinking. Shows "Thinking…" with a shimmer.
  final bool isActive;

  /// Returns a copy with the given fields replaced.
  ChatReasoning copyWith({String? text, Duration? duration, bool? isActive}) =>
      ChatReasoning(
        text: text ?? this.text,
        duration: duration ?? this.duration,
        isActive: isActive ?? this.isActive,
      );

  @override
  bool operator ==(Object other) =>
      other is ChatReasoning &&
      other.text == text &&
      other.duration == duration &&
      other.isActive == isActive;

  @override
  int get hashCode => Object.hash(text, duration, isActive);
}

/// State of a [ChatToolCall].
enum ChatToolStatus {
  /// The tool is running.
  running,

  /// The tool finished.
  done,

  /// The tool failed.
  failed,
}

/// A tool an AI model used while answering, such as a web search.
@immutable
class ChatToolCall {
  /// Creates a tool call.
  const ChatToolCall({
    required this.id,
    required this.name,
    this.status = ChatToolStatus.done,
    this.detail,
  });

  /// Identifier of the call.
  final String id;

  /// What the tool did, for example "Searched the web".
  final String name;

  /// Whether the tool is running, done or failed.
  final ChatToolStatus status;

  /// Input or result shown when the card is expanded. Supports markdown.
  final String? detail;

  @override
  bool operator ==(Object other) =>
      other is ChatToolCall &&
      other.id == id &&
      other.name == name &&
      other.status == status &&
      other.detail == detail;

  @override
  int get hashCode => Object.hash(id, name, status, detail);
}

/// A source an AI answer cites. Shown as a numbered chip under the answer.
@immutable
class ChatSource {
  /// Creates a source.
  const ChatSource({required this.title, required this.url, this.snippet});

  /// Title of the page or document.
  final String title;

  /// Link to the source. Opened through `ChatView.onLinkTap`.
  final String url;

  /// Short excerpt shown in the source sheet.
  final String? snippet;

  /// Host name of [url], without `www.`.
  String get host {
    final host = Uri.tryParse(url)?.host ?? '';
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  @override
  bool operator ==(Object other) =>
      other is ChatSource &&
      other.title == title &&
      other.url == url &&
      other.snippet == snippet;

  @override
  int get hashCode => Object.hash(title, url, snippet);
}

/// An earlier answer of a regenerated [TextMessage], with everything the
/// model produced for it.
@immutable
class ChatAnswerVersion {
  /// Creates an answer version.
  const ChatAnswerVersion({
    required this.text,
    this.reasoning,
    this.toolCalls = const [],
    this.sources = const [],
  });

  /// Creates a version from the current answer of [message].
  ChatAnswerVersion.of(TextMessage message)
      : text = message.text,
        reasoning = message.reasoning,
        toolCalls = message.toolCalls,
        sources = message.sources;

  /// The answer text.
  final String text;

  /// What the model thought before this answer.
  final ChatReasoning? reasoning;

  /// Tools the model used for this answer.
  final List<ChatToolCall> toolCalls;

  /// Sources this answer cites.
  final List<ChatSource> sources;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatAnswerVersion &&
          other.text == text &&
          other.reasoning == reasoning &&
          listEquals(other.toolCalls, toolCalls) &&
          listEquals(other.sources, sources);

  @override
  int get hashCode => Object.hash(
        text,
        reasoning,
        Object.hashAll(toolCalls),
        Object.hashAll(sources),
      );
}

/// An item of a [ChecklistMessage].
@immutable
class ChecklistItem {
  /// Creates a checklist item.
  const ChecklistItem({required this.id, required this.text, this.doneBy});

  /// Identifier of the item.
  final String id;

  /// What needs to be done.
  final String text;

  /// ID of the user who checked the item, or `null` when it is open.
  final String? doneBy;

  /// Whether the item is checked.
  bool get isDone => doneBy != null;

  @override
  bool operator ==(Object other) =>
      other is ChecklistItem &&
      other.id == id &&
      other.text == text &&
      other.doneBy == doneBy;

  @override
  int get hashCode => Object.hash(id, text, doneBy);
}

/// A product shown in a [ProductMessage].
@immutable
class ChatProduct {
  /// Creates a product.
  const ChatProduct({
    required this.id,
    required this.title,
    required this.price,
    this.subtitle,
    this.imageUri,
    this.actionLabel,
  });

  /// Identifier of the product.
  final String id;

  /// Name of the product.
  final String title;

  /// Price, already formatted by your app, for example "€24.90".
  final String price;

  /// Short description.
  final String? subtitle;

  /// Product photo, loaded like `ChatImage.uri`.
  final String? imageUri;

  /// Label of the button. Defaults to the localized "View".
  final String? actionLabel;

  @override
  bool operator ==(Object other) =>
      other is ChatProduct &&
      other.id == id &&
      other.title == title &&
      other.price == price &&
      other.subtitle == subtitle &&
      other.imageUri == imageUri &&
      other.actionLabel == actionLabel;

  @override
  int get hashCode =>
      Object.hash(id, title, price, subtitle, imageUri, actionLabel);
}

/// State of a [PaymentMessage].
enum ChatPaymentStatus {
  /// Waiting for the other person.
  pending,

  /// Paid.
  paid,

  /// Declined by the other person.
  declined,

  /// Cancelled by the author.
  cancelled,
}

/// Kind of call in a [CallMessage].
enum ChatCallKind {
  /// Voice call.
  voice,

  /// Video call.
  video,
}

/// How a call ended.
enum ChatCallOutcome {
  /// The call happened. `CallMessage.duration` says how long.
  completed,

  /// Nobody answered.
  missed,

  /// The other person declined.
  declined,
}

/// Role of a user in a group, shown as a badge next to the name.
enum ChatRole {
  /// Owner of the group.
  owner,

  /// Administrator.
  admin,

  /// Moderator.
  moderator,
}

/// Kind of a [ChatAttachment].
enum ChatAttachmentKind {
  /// A photo.
  image,

  /// A video.
  video,

  /// Any other file.
  file,
}

/// A file the user picked, waiting in the input until it is sent.
@immutable
class ChatAttachment {
  /// Creates an attachment.
  const ChatAttachment({
    required this.id,
    required this.name,
    this.kind = ChatAttachmentKind.file,
    this.uri,
    this.bytes,
    this.sizeBytes,
    this.mimeType,
  });

  /// Identifier of the attachment.
  final String id;

  /// File name, including the extension.
  final String name;

  /// Whether this is an image, a video or another file.
  final ChatAttachmentKind kind;

  /// Where the file lives, for example a local path. Images are loaded with
  /// `ChatView.imageProviderBuilder`.
  final String? uri;

  /// File content, for example from a keyboard that inserts an image.
  /// Images with bytes are shown with `MemoryImage`.
  final Uint8List? bytes;

  /// Size in bytes.
  final int? sizeBytes;

  /// MIME type.
  final String? mimeType;

  @override
  bool operator ==(Object other) =>
      other is ChatAttachment &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.uri == uri &&
      identical(other.bytes, bytes) &&
      other.sizeBytes == sizeBytes &&
      other.mimeType == mimeType;

  @override
  int get hashCode => Object.hash(id, name, kind, uri, sizeBytes, mimeType);
}
