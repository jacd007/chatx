import 'package:flutter/foundation.dart';

import 'chat_message.dart';

/// Something the user asked to send from the input bar, passed to
/// `ChatView.onSend`.
///
/// The hierarchy is sealed, so a `switch` over a [ChatOutgoing] is
/// exhaustive:
///
/// ```dart
/// ChatView(
///   onSend: (outgoing) => switch (outgoing) {
///     OutgoingText(:final text, :final replyTo) => backend.send(text, replyTo),
///     OutgoingAttachments(:final attachments) => backend.upload(attachments),
///     OutgoingSticker(:final sticker) => backend.sendSticker(sticker),
///     OutgoingEdit(:final message, :final text) => backend.edit(message, text),
///     OutgoingScheduledNow(:final message) => backend.sendNow(message),
///   },
///   sendFeatures: const {ChatSendFeature.edit, ChatSendFeature.stickers},
/// )
/// ```
///
/// chatx never adds the message to the controller for you. Insert it
/// yourself, usually with `MessageStatus.sending`, for an optimistic UI.
@immutable
sealed class ChatOutgoing {
  const ChatOutgoing({this.replyTo});

  /// The message being replied to, or `null`. Use `replyTo?.id` as the
  /// `replyToId` of the message you insert.
  final ChatMessage? replyTo;
}

/// Text typed in the input, a suggested prompt or a quick reply.
final class OutgoingText extends ChatOutgoing {
  /// Creates an outgoing text.
  const OutgoingText(this.text, {super.replyTo, this.scheduledFor});

  /// The text, with chatx's markdown subset.
  final String text;

  /// When the user scheduled the message for, or `null` to send it now.
  /// Requires [ChatSendFeature.schedule].
  final DateTime? scheduledFor;

  @override
  bool operator ==(Object other) =>
      other is OutgoingText &&
      other.text == text &&
      other.replyTo == replyTo &&
      other.scheduledFor == scheduledFor;

  @override
  int get hashCode => Object.hash(text, replyTo, scheduledFor);

  @override
  String toString() => 'OutgoingText($text)';
}

/// Files of the input tray, with the text of the field as a caption.
/// Requires [ChatSendFeature.attachments].
final class OutgoingAttachments extends ChatOutgoing {
  /// Creates outgoing attachments.
  const OutgoingAttachments(
    this.attachments, {
    this.caption = '',
    super.replyTo,
  });

  /// The files, in the order they were added.
  final List<ChatAttachment> attachments;

  /// Text of the input field. May be empty.
  final String caption;

  @override
  bool operator ==(Object other) =>
      other is OutgoingAttachments &&
      listEquals(other.attachments, attachments) &&
      other.caption == caption &&
      other.replyTo == replyTo;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(attachments), caption, replyTo);

  @override
  String toString() => 'OutgoingAttachments(${attachments.length})';
}

/// A sticker picked in the emoji picker. Requires
/// [ChatSendFeature.stickers] and `ChatView.stickerPacks`.
final class OutgoingSticker extends ChatOutgoing {
  /// Creates an outgoing sticker.
  const OutgoingSticker(this.sticker, {super.replyTo});

  /// The sticker.
  final ChatSticker sticker;

  @override
  bool operator ==(Object other) =>
      other is OutgoingSticker &&
      other.sticker == sticker &&
      other.replyTo == replyTo;

  @override
  int get hashCode => Object.hash(sticker, replyTo);

  @override
  String toString() => 'OutgoingSticker(${sticker.id})';
}

/// New text for a message the user edited. Requires [ChatSendFeature.edit].
///
/// Apply it with `ChatController.editText` and your backend.
final class OutgoingEdit extends ChatOutgoing {
  /// Creates an outgoing edit.
  const OutgoingEdit(this.message, this.text);

  /// The message as it was when the user started editing.
  final TextMessage message;

  /// The new text.
  final String text;

  @override
  bool operator ==(Object other) =>
      other is OutgoingEdit && other.message == message && other.text == text;

  @override
  int get hashCode => Object.hash(message, text);

  @override
  String toString() => 'OutgoingEdit(${message.id})';
}

/// "Send now" chosen on a scheduled message. Requires
/// [ChatSendFeature.sendScheduledNow].
final class OutgoingScheduledNow extends ChatOutgoing {
  /// Creates a request to send a scheduled message now.
  const OutgoingScheduledNow(this.message);

  /// The scheduled message.
  final ChatMessage message;

  @override
  bool operator ==(Object other) =>
      other is OutgoingScheduledNow && other.message == message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'OutgoingScheduledNow(${message.id})';
}

/// Input features that `ChatView.onSend` handles, beyond plain text.
///
/// Each one shows its part of the UI: the "Edit" action, the attachment
/// tray, scheduling by long-pressing send, the sticker tabs and "Send now"
/// on scheduled messages.
enum ChatSendFeature {
  /// "Edit" on the current user's text messages; sends [OutgoingEdit].
  edit,

  /// The attachment tray and pasted images; sends [OutgoingAttachments].
  attachments,

  /// Long-press send to schedule; sends [OutgoingText.scheduledFor].
  schedule,

  /// Sticker tabs in the emoji picker; sends [OutgoingSticker].
  stickers,

  /// "Send now" on scheduled messages; sends [OutgoingScheduledNow].
  sendScheduledNow,
}

/// Called with everything the user sends from the input bar.
typedef ChatOutgoingCallback = void Function(ChatOutgoing outgoing);
