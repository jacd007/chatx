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

/// One to many images, shown as a grid, with an optional caption.
///
/// Tapping an image opens a full-screen viewer with zoom. Set
/// [uploadProgress] while your app uploads the images, and [isSpoiler] to
/// blur them until the user taps.
final class ImageMessage extends ChatMessage {
  /// Creates an image message.
  const ImageMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    required this.images,
    this.caption,
    this.uploadProgress,
    this.isSpoiler = false,
    super.status,
    super.replyToId,
    super.reactions,
    super.metadata,
  }) : assert(images.length > 0, 'An ImageMessage needs at least one image');

  /// The images. The grid shows up to four and a "+N" counter for the rest.
  final List<ChatImage> images;

  /// Optional text under the images. Supports markdown.
  final String? caption;

  /// Upload progress from 0 to 1, or `null` when there is no upload.
  final double? uploadProgress;

  /// Whether the images stay blurred until the user taps them.
  final bool isSpoiler;

  /// Returns a copy of this message with the given fields replaced.
  ImageMessage copyWith({
    List<ChatImage>? images,
    String? caption,
    double? uploadProgress,
    bool clearUploadProgress = false,
    bool? isSpoiler,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    Map<String, Object?>? metadata,
  }) {
    return ImageMessage(
      id: id,
      author: author,
      createdAt: createdAt,
      images: images ?? this.images,
      caption: caption ?? this.caption,
      uploadProgress:
          clearUploadProgress ? null : uploadProgress ?? this.uploadProgress,
      isSpoiler: isSpoiler ?? this.isSpoiler,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  ImageMessage withStatus(MessageStatus? status) => ImageMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        images: images,
        caption: caption,
        uploadProgress: uploadProgress,
        isSpoiler: isSpoiler,
        status: status,
        replyToId: replyToId,
        reactions: reactions,
        metadata: metadata,
      );

  @override
  ImageMessage withReactions(List<ChatReaction> reactions) =>
      copyWith(reactions: reactions);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageMessage &&
          _baseEquals(other) &&
          listEquals(other.images, images) &&
          other.caption == caption &&
          other.uploadProgress == uploadProgress &&
          other.isSpoiler == isSpoiler;

  @override
  int get hashCode => Object.hash(
        _baseHash,
        Object.hashAll(images),
        caption,
        uploadProgress,
        isSpoiler,
      );
}

/// A file attachment: icon, name, size and optional upload progress.
///
/// chatx does not download or open files. Handle taps with
/// `ChatView.onFileTap`.
final class FileMessage extends ChatMessage {
  /// Creates a file message.
  const FileMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    required this.name,
    this.uri,
    this.sizeBytes,
    this.mimeType,
    this.uploadProgress,
    super.status,
    super.replyToId,
    super.reactions,
    super.metadata,
  });

  /// File name shown to the user, including the extension.
  final String name;

  /// Where the file lives. Passed back to your tap handler.
  final String? uri;

  /// Size in bytes. Shown as "2.4 MB".
  final int? sizeBytes;

  /// MIME type, used to pick the icon when the extension is not enough.
  final String? mimeType;

  /// Upload progress from 0 to 1, or `null` when there is no upload.
  final double? uploadProgress;

  /// Lowercase extension without the dot, or an empty string.
  String get extension {
    final dot = name.lastIndexOf('.');
    return dot <= 0 || dot == name.length - 1
        ? ''
        : name.substring(dot + 1).toLowerCase();
  }

  /// Returns a copy of this message with the given fields replaced.
  FileMessage copyWith({
    String? name,
    String? uri,
    int? sizeBytes,
    String? mimeType,
    double? uploadProgress,
    bool clearUploadProgress = false,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    Map<String, Object?>? metadata,
  }) {
    return FileMessage(
      id: id,
      author: author,
      createdAt: createdAt,
      name: name ?? this.name,
      uri: uri ?? this.uri,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mimeType: mimeType ?? this.mimeType,
      uploadProgress:
          clearUploadProgress ? null : uploadProgress ?? this.uploadProgress,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  FileMessage withStatus(MessageStatus? status) => FileMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        name: name,
        uri: uri,
        sizeBytes: sizeBytes,
        mimeType: mimeType,
        uploadProgress: uploadProgress,
        status: status,
        replyToId: replyToId,
        reactions: reactions,
        metadata: metadata,
      );

  @override
  FileMessage withReactions(List<ChatReaction> reactions) =>
      copyWith(reactions: reactions);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileMessage &&
          _baseEquals(other) &&
          other.name == name &&
          other.uri == uri &&
          other.sizeBytes == sizeBytes &&
          other.mimeType == mimeType &&
          other.uploadProgress == uploadProgress;

  @override
  int get hashCode => Object.hash(
        _baseHash,
        name,
        uri,
        sizeBytes,
        mimeType,
        uploadProgress,
      );
}

/// A voice note: play button, waveform and duration.
///
/// chatx draws the UI only. Your app plays the audio and reports progress
/// through `ChatView.voicePlayback`.
final class VoiceMessage extends ChatMessage {
  /// Creates a voice note.
  const VoiceMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    required this.uri,
    required this.duration,
    this.waveform = const [],
    super.status,
    super.replyToId,
    super.reactions,
    super.metadata,
  });

  /// Where the audio lives. Passed back to your playback callbacks.
  final String uri;

  /// Length of the recording.
  final Duration duration;

  /// Amplitude samples between 0 and 1. chatx resamples them to fit the
  /// bubble. When empty, a flat waveform is shown.
  final List<double> waveform;

  @override
  VoiceMessage withStatus(MessageStatus? status) => VoiceMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        uri: uri,
        duration: duration,
        waveform: waveform,
        status: status,
        replyToId: replyToId,
        reactions: reactions,
        metadata: metadata,
      );

  @override
  VoiceMessage withReactions(List<ChatReaction> reactions) => VoiceMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        uri: uri,
        duration: duration,
        waveform: waveform,
        status: status,
        replyToId: replyToId,
        reactions: reactions,
        metadata: metadata,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceMessage &&
          _baseEquals(other) &&
          other.uri == uri &&
          other.duration == duration &&
          listEquals(other.waveform, waveform);

  @override
  int get hashCode =>
      Object.hash(_baseHash, uri, duration, Object.hashAll(waveform));
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

/// A question with options that participants vote on.
///
/// Results appear with animated bars once the current user votes or the poll
/// is closed. Votes go through `ChatView.onPollVote`; update the message with
/// `ChatController.votePoll`.
final class PollMessage extends ChatMessage {
  /// Creates a poll.
  const PollMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    required this.question,
    required this.options,
    this.allowsMultipleAnswers = false,
    this.isClosed = false,
    super.status,
    super.replyToId,
    super.reactions,
    super.metadata,
  });

  /// The question.
  final String question;

  /// The answers, in display order.
  final List<PollOption> options;

  /// Whether a user may choose more than one option.
  final bool allowsMultipleAnswers;

  /// Whether voting has ended. Closed polls show results to everyone.
  final bool isClosed;

  /// Total votes across options.
  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes);

  /// Whether [userId] voted for any option.
  bool hasVoted(String userId) =>
      options.any((o) => o.voterIds.contains(userId));

  /// Returns a copy of this poll with the given fields replaced.
  PollMessage copyWith({
    String? question,
    List<PollOption>? options,
    bool? allowsMultipleAnswers,
    bool? isClosed,
    MessageStatus? status,
    String? replyToId,
    List<ChatReaction>? reactions,
    Map<String, Object?>? metadata,
  }) {
    return PollMessage(
      id: id,
      author: author,
      createdAt: createdAt,
      question: question ?? this.question,
      options: options ?? this.options,
      allowsMultipleAnswers:
          allowsMultipleAnswers ?? this.allowsMultipleAnswers,
      isClosed: isClosed ?? this.isClosed,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  PollMessage withStatus(MessageStatus? status) => PollMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        question: question,
        options: options,
        allowsMultipleAnswers: allowsMultipleAnswers,
        isClosed: isClosed,
        status: status,
        replyToId: replyToId,
        reactions: reactions,
        metadata: metadata,
      );

  @override
  PollMessage withReactions(List<ChatReaction> reactions) =>
      copyWith(reactions: reactions);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollMessage &&
          _baseEquals(other) &&
          other.question == question &&
          listEquals(other.options, options) &&
          other.allowsMultipleAnswers == allowsMultipleAnswers &&
          other.isClosed == isClosed;

  @override
  int get hashCode => Object.hash(
        _baseHash,
        question,
        Object.hashAll(options),
        allowsMultipleAnswers,
        isClosed,
      );
}

/// An announcement with a live countdown to [endsAt].
///
/// Shows days, hours, minutes and seconds left, and a "started" label once
/// the moment arrives.
final class CountdownMessage extends ChatMessage {
  /// Creates a countdown announcement.
  const CountdownMessage({
    required super.id,
    required super.author,
    required super.createdAt,
    required this.title,
    required this.endsAt,
    this.description,
    this.completedLabel,
    super.status,
    super.replyToId,
    super.reactions,
    super.metadata,
  });

  /// What is coming, for example "Product launch".
  final String title;

  /// When the countdown reaches zero.
  final DateTime endsAt;

  /// Optional details. Supports markdown.
  final String? description;

  /// Text shown after [endsAt]. Defaults to the localized "It's time!".
  final String? completedLabel;

  @override
  CountdownMessage withStatus(MessageStatus? status) => CountdownMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        title: title,
        endsAt: endsAt,
        description: description,
        completedLabel: completedLabel,
        status: status,
        replyToId: replyToId,
        reactions: reactions,
        metadata: metadata,
      );

  @override
  CountdownMessage withReactions(List<ChatReaction> reactions) =>
      CountdownMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        title: title,
        endsAt: endsAt,
        description: description,
        completedLabel: completedLabel,
        status: status,
        replyToId: replyToId,
        reactions: reactions,
        metadata: metadata,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountdownMessage &&
          _baseEquals(other) &&
          other.title == title &&
          other.endsAt == endsAt &&
          other.description == description &&
          other.completedLabel == completedLabel;

  @override
  int get hashCode =>
      Object.hash(_baseHash, title, endsAt, description, completedLabel);
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
