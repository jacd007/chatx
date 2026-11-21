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
