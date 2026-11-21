import 'package:flutter/widgets.dart';

import '../chat_scope.dart';

/// Formats the "is typing" label for the given display names.
typedef ChatTypingLabel = String Function(List<String> names);

/// Formats a label that depends on a count.
typedef ChatCountLabel = String Function(int count);

/// Formats a label that includes a user's display name.
typedef ChatNameLabel = String Function(String name);

/// Formats the accessibility label of a reaction chip.
typedef ChatReactionLabel = String Function(
  String emoji,
  int count, {
  required bool includesYou,
});

/// User-facing strings of chatx.
///
/// English ([en]) and Spanish ([es]) ship with the package. chatx picks one
/// from the ambient [Locale] and falls back to English. Dates and times use
/// your app's `MaterialLocalizations`, so they follow every locale your app
/// supports.
///
/// Override some strings:
///
/// ```dart
/// ChatView(
///   localizations: ChatLocalizations.en.copyWith(inputHint: 'Say hi'),
///   // ...
/// )
/// ```
///
/// Add a language by creating a full instance and passing it through
/// `ChatView.localizations`.
@immutable
class ChatLocalizations {
  /// Creates a full set of strings.
  const ChatLocalizations({
    required this.inputHint,
    required this.sendButton,
    required this.today,
    required this.yesterday,
    required this.edited,
    required this.you,
    required this.someone,
    required this.typing,
    required this.copy,
    required this.retry,
    required this.failedToSend,
    required this.loadMoreFailed,
    required this.scrollToBottom,
    required this.unreadMessages,
    required this.emptyState,
    required this.unsupportedMessage,
    required this.statusSending,
    required this.statusSent,
    required this.statusDelivered,
    required this.statusRead,
    required this.statusFailed,
    required this.reply,
    required this.edit,
    required this.delete,
    required this.cancel,
    required this.replyingTo,
    required this.editingMessage,
    required this.unreadSeparator,
    required this.quoteUnavailable,
    required this.addReaction,
    required this.reactionLabel,
  });

  /// Placeholder of the message input.
  final String inputHint;

  /// Accessibility label of the send button.
  final String sendButton;

  /// Day separator label for today.
  final String today;

  /// Day separator label for yesterday.
  final String yesterday;

  /// Label shown next to the time of edited messages.
  final String edited;

  /// Name used for the current user in accessibility labels.
  final String you;

  /// Name used for users without a display name.
  final String someone;

  /// Label of the typing indicator.
  final ChatTypingLabel typing;

  /// Label of the "copy text" action.
  final String copy;

  /// Label of retry buttons.
  final String retry;

  /// Shown under a message that failed to send.
  final String failedToSend;

  /// Shown when loading older messages failed.
  final String loadMoreFailed;

  /// Accessibility label of the scroll-to-bottom button.
  final String scrollToBottom;

  /// Accessibility label of the unread counter.
  final ChatCountLabel unreadMessages;

  /// Shown when the conversation has no messages.
  final String emptyState;

  /// Shown for a `CustomMessage` without a `customMessageBuilder`.
  final String unsupportedMessage;

  /// Accessibility label for `MessageStatus.sending`.
  final String statusSending;

  /// Accessibility label for `MessageStatus.sent`.
  final String statusSent;

  /// Accessibility label for `MessageStatus.delivered`.
  final String statusDelivered;

  /// Accessibility label for `MessageStatus.read`.
  final String statusRead;

  /// Accessibility label for `MessageStatus.failed`.
  final String statusFailed;

  /// Label of the "reply" action.
  final String reply;

  /// Label of the "edit" action.
  final String edit;

  /// Label of the "delete" action.
  final String delete;

  /// Accessibility label of buttons that cancel a reply or an edit.
  final String cancel;

  /// Title of the reply banner above the input.
  final ChatNameLabel replyingTo;

  /// Title of the edit banner above the input.
  final String editingMessage;

  /// Label of the separator above the first unread message.
  final String unreadSeparator;

  /// Shown in a reply quote when the original message is not loaded or was deleted.
  final String quoteUnavailable;

  /// Accessibility label of the quick reaction row.
  final String addReaction;

  /// Accessibility label of a reaction chip.
  final ChatReactionLabel reactionLabel;

  /// English strings.
  static const ChatLocalizations en = ChatLocalizations(
    inputHint: 'Message',
    sendButton: 'Send',
    today: 'Today',
    yesterday: 'Yesterday',
    edited: 'edited',
    you: 'You',
    someone: 'Someone',
    typing: _typingEn,
    copy: 'Copy text',
    retry: 'Retry',
    failedToSend: 'Not sent. Tap to retry.',
    loadMoreFailed: 'Could not load older messages.',
    scrollToBottom: 'Scroll to latest messages',
    unreadMessages: _unreadEn,
    emptyState: 'No messages yet. Say hello!',
    unsupportedMessage: 'This message type is not supported.',
    statusSending: 'Sending',
    statusSent: 'Sent',
    statusDelivered: 'Delivered',
    statusRead: 'Read',
    statusFailed: 'Failed to send',
    reply: 'Reply',
    edit: 'Edit',
    delete: 'Delete',
    cancel: 'Cancel',
    replyingTo: _replyingToEn,
    editingMessage: 'Editing message',
    unreadSeparator: 'New messages',
    quoteUnavailable: 'Original message not available',
    addReaction: 'Add reaction',
    reactionLabel: _reactionEn,
  );

  /// Spanish strings.
  static const ChatLocalizations es = ChatLocalizations(
    inputHint: 'Mensaje',
    sendButton: 'Enviar',
    today: 'Hoy',
    yesterday: 'Ayer',
    edited: 'editado',
    you: 'Tú',
    someone: 'Alguien',
    typing: _typingEs,
    copy: 'Copiar texto',
    retry: 'Reintentar',
    failedToSend: 'No enviado. Toca para reintentar.',
    loadMoreFailed: 'No se pudieron cargar mensajes anteriores.',
    scrollToBottom: 'Ir a los mensajes más recientes',
    unreadMessages: _unreadEs,
    emptyState: 'Aún no hay mensajes. ¡Saluda!',
    unsupportedMessage: 'Este tipo de mensaje no es compatible.',
    statusSending: 'Enviando',
    statusSent: 'Enviado',
    statusDelivered: 'Entregado',
    statusRead: 'Leído',
    statusFailed: 'Error al enviar',
    reply: 'Responder',
    edit: 'Editar',
    delete: 'Eliminar',
    cancel: 'Cancelar',
    replyingTo: _replyingToEs,
    editingMessage: 'Editando mensaje',
    unreadSeparator: 'Mensajes nuevos',
    quoteUnavailable: 'Mensaje original no disponible',
    addReaction: 'Agregar reacción',
    reactionLabel: _reactionEs,
  );

  /// Built-in strings by language code.
  static const Map<String, ChatLocalizations> builtIn = {'en': en, 'es': es};

  /// Returns the built-in strings for [locale], or [en] if the language is
  /// not bundled.
  static ChatLocalizations forLocale(Locale? locale) =>
      builtIn[locale?.languageCode] ?? en;

  /// Resolves the strings for [context].
  ///
  /// Inside a `ChatView`, returns the strings the view uses. Elsewhere,
  /// returns [forLocale] of the ambient locale.
  static ChatLocalizations of(BuildContext context) {
    final scope = ChatScope.maybeOf(context);
    if (scope != null) return scope.localizations;
    return forLocale(Localizations.maybeLocaleOf(context));
  }

  static String _typingEn(List<String> names) => switch (names.length) {
        0 => '',
        1 => '${names[0]} is typing…',
        2 => '${names[0]} and ${names[1]} are typing…',
        _ => '${names[0]} and ${names.length - 1} others are typing…',
      };

  static String _typingEs(List<String> names) => switch (names.length) {
        0 => '',
        1 => '${names[0]} está escribiendo…',
        2 => '${names[0]} y ${names[1]} están escribiendo…',
        _ => '${names[0]} y ${names.length - 1} más están escribiendo…',
      };

  static String _replyingToEn(String name) => 'Replying to $name';

  static String _replyingToEs(String name) => 'Respondiendo a $name';

  static String _reactionEn(
    String emoji,
    int count, {
    required bool includesYou,
  }) =>
      includesYou ? '$emoji $count, including you' : '$emoji $count';

  static String _reactionEs(
    String emoji,
    int count, {
    required bool includesYou,
  }) =>
      includesYou ? '$emoji $count, incluido tú' : '$emoji $count';

  static String _unreadEn(int count) =>
      count == 1 ? '1 new message' : '$count new messages';

  static String _unreadEs(int count) =>
      count == 1 ? '1 mensaje nuevo' : '$count mensajes nuevos';

  /// Returns a copy with the given strings replaced.
  ChatLocalizations copyWith({
    String? inputHint,
    String? sendButton,
    String? today,
    String? yesterday,
    String? edited,
    String? you,
    String? someone,
    ChatTypingLabel? typing,
    String? copy,
    String? retry,
    String? failedToSend,
    String? loadMoreFailed,
    String? scrollToBottom,
    ChatCountLabel? unreadMessages,
    String? emptyState,
    String? unsupportedMessage,
    String? statusSending,
    String? statusSent,
    String? statusDelivered,
    String? statusRead,
    String? statusFailed,
    String? reply,
    String? edit,
    String? delete,
    String? cancel,
    ChatNameLabel? replyingTo,
    String? editingMessage,
    String? unreadSeparator,
    String? quoteUnavailable,
    String? addReaction,
    ChatReactionLabel? reactionLabel,
  }) {
    return ChatLocalizations(
      inputHint: inputHint ?? this.inputHint,
      sendButton: sendButton ?? this.sendButton,
      today: today ?? this.today,
      yesterday: yesterday ?? this.yesterday,
      edited: edited ?? this.edited,
      you: you ?? this.you,
      someone: someone ?? this.someone,
      typing: typing ?? this.typing,
      copy: copy ?? this.copy,
      retry: retry ?? this.retry,
      failedToSend: failedToSend ?? this.failedToSend,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      scrollToBottom: scrollToBottom ?? this.scrollToBottom,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      emptyState: emptyState ?? this.emptyState,
      unsupportedMessage: unsupportedMessage ?? this.unsupportedMessage,
      statusSending: statusSending ?? this.statusSending,
      statusSent: statusSent ?? this.statusSent,
      statusDelivered: statusDelivered ?? this.statusDelivered,
      statusRead: statusRead ?? this.statusRead,
      statusFailed: statusFailed ?? this.statusFailed,
      reply: reply ?? this.reply,
      edit: edit ?? this.edit,
      delete: delete ?? this.delete,
      cancel: cancel ?? this.cancel,
      replyingTo: replyingTo ?? this.replyingTo,
      editingMessage: editingMessage ?? this.editingMessage,
      unreadSeparator: unreadSeparator ?? this.unreadSeparator,
      quoteUnavailable: quoteUnavailable ?? this.quoteUnavailable,
      addReaction: addReaction ?? this.addReaction,
      reactionLabel: reactionLabel ?? this.reactionLabel,
    );
  }
}
