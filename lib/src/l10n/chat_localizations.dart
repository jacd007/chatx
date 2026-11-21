import 'package:flutter/widgets.dart';

import '../chat_scope.dart';

/// Formats the "is typing" label for the given display names.
typedef ChatTypingLabel = String Function(List<String> names);

/// Formats a label that depends on a count.
typedef ChatCountLabel = String Function(int count);

/// Formats a label that includes a user's display name.
typedef ChatNameLabel = String Function(String name);

/// Formats a step label such as "Question 2 of 5".
typedef ChatStepLabel = String Function(int current, int total);

/// Formats the RSVP counters of an event.
typedef ChatRsvpLabel = String Function(int going, int maybe);

/// Formats the accessibility label of a reaction chip.
typedef ChatReactionLabel = String Function(
  String emoji,
  int count, {
  required bool includesYou,
});

/// User-facing strings of chatx.
///
/// English ([en]), Spanish ([es]), Portuguese ([pt]), French ([fr]) and
/// German ([de]) ship with the package. chatx picks one
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
    required this.spoiler,
    required this.photo,
    required this.file,
    required this.voiceMessage,
    required this.poll,
    required this.pollVotes,
    required this.pollSelectOne,
    required this.pollSelectMany,
    required this.pollClosed,
    required this.countdownCompleted,
    required this.countdownDays,
    required this.countdownHours,
    required this.countdownMinutes,
    required this.countdownSeconds,
    required this.pinnedMessage,
    required this.pin,
    required this.unpin,
    required this.select,
    required this.selectedCount,
    required this.searchHint,
    required this.searchNoResults,
    required this.searchPrevious,
    required this.searchNext,
    required this.holdToRecord,
    required this.slideToCancel,
    required this.play,
    required this.pause,
    required this.uploading,
    required this.close,
    required this.mentionSuggestions,
    required this.survey,
    required this.surveyQuestions,
    required this.surveyResponses,
    required this.surveyAnswer,
    required this.surveyAnswered,
    required this.surveyClosed,
    required this.surveyStep,
    required this.surveyNext,
    required this.surveyBack,
    required this.surveySubmit,
    required this.surveyOptional,
    required this.surveyTextHint,
    required this.npsLow,
    required this.npsHigh,
    required this.threadReplies,
    required this.seenBy,
    required this.messageInfo,
    required this.readBy,
    required this.forward,
    required this.forwardedFrom,
    required this.expiresIn,
    required this.online,
    required this.lastSeen,
    required this.justNow,
    required this.minutesAgo,
    required this.todayAt,
    required this.yesterdayAt,
    required this.members,
    required this.emoji,
    required this.keyboard,
    required this.searchEmoji,
    required this.emojiCategories,
    required this.moreReactions,
    required this.typingShort,
    required this.regenerate,
    required this.goodResponse,
    required this.badResponse,
    required this.stopGenerating,
    required this.copyCode,
    required this.copied,
    required this.translate,
    required this.translated,
    required this.showOriginal,
    required this.showTranslation,
    required this.translating,
    required this.translationFailed,
    required this.location,
    required this.liveLocation,
    required this.liveUntil,
    required this.event,
    required this.rsvpGoing,
    required this.rsvpMaybe,
    required this.rsvpNotGoing,
    required this.rsvpSummary,
    required this.contact,
    required this.call,
    required this.sendEmail,
    required this.addContact,
    required this.sticker,
    required this.deleteForEveryone,
    required this.messageDeleted,
    required this.editHistory,
    required this.currentVersion,
    required this.scheduledFor,
    required this.scheduleMessage,
    required this.sendNow,
    required this.inOneHour,
    required this.tonight,
    required this.tomorrowMorning,
    required this.pickDateTime,
    required this.readOnly,
    required this.slowModeWait,
    required this.report,
    required this.block,
    required this.save,
    required this.unsave,
    required this.saved,
    required this.statusQueued,
    required this.offline,
    required this.connecting,
    required this.attach,
    required this.removeAttachment,
    required this.addCaption,
    required this.bold,
    required this.italic,
    required this.strikethrough,
    required this.code,
    required this.link,
    required this.thinking,
    required this.reasoning,
    required this.sources,
    required this.previousVersion,
    required this.nextVersion,
    required this.video,
    required this.playVideo,
    required this.transcribe,
    required this.transcribing,
    required this.checklist,
    required this.view,
    required this.paymentRequest,
    required this.paymentSent,
    required this.pay,
    required this.decline,
    required this.paymentPending,
    required this.paymentPaid,
    required this.paymentDeclined,
    required this.paymentCancelled,
    required this.voiceCall,
    required this.videoCall,
    required this.missedCall,
    required this.declinedCall,
    required this.callBack,
    required this.roleOwner,
    required this.roleAdmin,
    required this.roleModerator,
    required this.sendMessage,
    required this.membersTitle,
    required this.media,
    required this.files,
    required this.links,
    required this.galleryEmpty,
    required this.jumpToDate,
    required this.moreActions,
    required this.thoughtFor,
    required this.checklistProgress,
    required this.unreadMentions,
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

  /// Accessibility label of hidden spoiler text.
  final String spoiler;

  /// Preview label of image messages.
  final String photo;

  /// Preview label of file messages.
  final String file;

  /// Preview and accessibility label of voice notes.
  final String voiceMessage;

  /// Preview label of polls.
  final String poll;

  /// Vote counter of polls.
  final ChatCountLabel pollVotes;

  /// Hint of single-answer polls.
  final String pollSelectOne;

  /// Hint of multiple-answer polls.
  final String pollSelectMany;

  /// Label of closed polls.
  final String pollClosed;

  /// Default label of countdowns that reached zero.
  final String countdownCompleted;

  /// Unit label for days in countdowns.
  final String countdownDays;

  /// Unit label for hours in countdowns.
  final String countdownHours;

  /// Unit label for minutes in countdowns.
  final String countdownMinutes;

  /// Unit label for seconds in countdowns.
  final String countdownSeconds;

  /// Title of the pinned message banner.
  final String pinnedMessage;

  /// Label of the "pin" action.
  final String pin;

  /// Label of the "unpin" action.
  final String unpin;

  /// Label of the "select" action.
  final String select;

  /// Title of the selection bar.
  final ChatCountLabel selectedCount;

  /// Placeholder of the search field.
  final String searchHint;

  /// Shown when a search has no results.
  final String searchNoResults;

  /// Accessibility label of the "older result" button.
  final String searchPrevious;

  /// Accessibility label of the "newer result" button.
  final String searchNext;

  /// Accessibility label of the record button.
  final String holdToRecord;

  /// Hint shown while recording.
  final String slideToCancel;

  /// Accessibility label of the play button.
  final String play;

  /// Accessibility label of the pause button.
  final String pause;

  /// Accessibility label of upload progress.
  final String uploading;

  /// Accessibility label of close buttons.
  final String close;

  /// Accessibility label of the mention suggestions list.
  final String mentionSuggestions;

  /// Label of survey messages.
  final String survey;

  /// Question counter of surveys.
  final ChatCountLabel surveyQuestions;

  /// Response counter of surveys.
  final ChatCountLabel surveyResponses;

  /// Button that opens a survey.
  final String surveyAnswer;

  /// Shown on surveys the user already answered.
  final String surveyAnswered;

  /// Shown on closed surveys.
  final String surveyClosed;

  /// Progress label inside a survey.
  final ChatStepLabel surveyStep;

  /// Button to go to the next question.
  final String surveyNext;

  /// Button to go to the previous question.
  final String surveyBack;

  /// Button that sends the survey.
  final String surveySubmit;

  /// Marks optional questions.
  final String surveyOptional;

  /// Placeholder of text answers.
  final String surveyTextHint;

  /// Label under 0 in NPS questions.
  final String npsLow;

  /// Label under 10 in NPS questions.
  final String npsHigh;

  /// Reply counter under messages with a thread.
  final ChatCountLabel threadReplies;

  /// "Seen by" label in group chats.
  final ChatTypingLabel seenBy;

  /// Label of the "info" action and title of the info sheet.
  final String messageInfo;

  /// Section title of the info sheet.
  final String readBy;

  /// Label of the "forward" action.
  final String forward;

  /// Label of forwarded messages.
  final ChatNameLabel forwardedFrom;

  /// Accessibility label of disappearing messages.
  final ChatNameLabel expiresIn;

  /// Presence label in `ChatHeader`.
  final String online;

  /// "Last seen" label in `ChatHeader`.
  final ChatNameLabel lastSeen;

  /// Relative time for less than a minute ago.
  final String justNow;

  /// Relative time in minutes.
  final ChatCountLabel minutesAgo;

  /// Relative time earlier today.
  final ChatNameLabel todayAt;

  /// Relative time yesterday.
  final ChatNameLabel yesterdayAt;

  /// Member counter in `ChatHeader`.
  final ChatCountLabel members;

  /// Accessibility label of the emoji button.
  final String emoji;

  /// Accessibility label of the button that returns to the keyboard.
  final String keyboard;

  /// Placeholder of the emoji search field.
  final String searchEmoji;

  /// Names of the emoji categories: recent, smileys, people, nature, food,
  /// activities, travel, objects, symbols and flags.
  final List<String> emojiCategories;

  /// Accessibility label of the button that opens all emoji for reactions.
  final String moreReactions;

  /// Typing label of one-to-one chats in `ChatHeader`.
  final String typingShort;

  /// Action that asks the assistant for a new answer.
  final String regenerate;

  /// Thumbs-up button of AI answers.
  final String goodResponse;

  /// Thumbs-down button of AI answers.
  final String badResponse;

  /// Button that stops a streamed answer.
  final String stopGenerating;

  /// Button on code blocks.
  final String copyCode;

  /// Confirmation after copying.
  final String copied;

  /// Action that translates a message.
  final String translate;

  /// Label of translated messages.
  final String translated;

  /// Shows the original text of a translated message.
  final String showOriginal;

  /// Shows the translation again.
  final String showTranslation;

  /// Shown while a translation loads.
  final String translating;

  /// Shown when a translation fails.
  final String translationFailed;

  /// Label of location messages.
  final String location;

  /// Label of live locations.
  final String liveLocation;

  /// End time of a live location.
  final ChatNameLabel liveUntil;

  /// Label of event messages.
  final String event;

  /// RSVP: will attend.
  final String rsvpGoing;

  /// RSVP: might attend.
  final String rsvpMaybe;

  /// RSVP: will not attend.
  final String rsvpNotGoing;

  /// Counters under an event.
  final ChatRsvpLabel rsvpSummary;

  /// Label of contact cards.
  final String contact;

  /// Button that calls a contact.
  final String call;

  /// Button that emails a contact.
  final String sendEmail;

  /// Button that saves a contact.
  final String addContact;

  /// Preview label of stickers.
  final String sticker;

  /// Action that deletes a message for everyone.
  final String deleteForEveryone;

  /// Placeholder of deleted messages.
  final String messageDeleted;

  /// Title of the edit history sheet.
  final String editHistory;

  /// Marks the current version in the edit history.
  final String currentVersion;

  /// Label of scheduled messages.
  final ChatNameLabel scheduledFor;

  /// Title of the schedule sheet.
  final String scheduleMessage;

  /// Sends a scheduled message right away.
  final String sendNow;

  /// Schedule option.
  final String inOneHour;

  /// Schedule option: today at 8 PM.
  final String tonight;

  /// Schedule option: tomorrow at 9 AM.
  final String tomorrowMorning;

  /// Schedule option that opens date and time pickers.
  final String pickDateTime;

  /// Default banner when only admins can write.
  final String readOnly;

  /// Shown while slow mode blocks the input.
  final ChatNameLabel slowModeWait;

  /// Action that reports a message.
  final String report;

  /// Action that blocks the author.
  final ChatNameLabel block;

  /// Action that saves a message.
  final String save;

  /// Action that removes a message from saved.
  final String unsave;

  /// Accessibility label of the saved icon.
  final String saved;

  /// Status label of a message waiting for the network.
  final String statusQueued;

  /// Banner shown while the device is offline.
  final String offline;

  /// Banner shown while the connection is coming back.
  final String connecting;

  /// Tooltip of the attach button.
  final String attach;

  /// Tooltip of the button that removes an attachment from the tray.
  final String removeAttachment;

  /// Placeholder of the input while attachments are waiting.
  final String addCaption;

  /// Formatting action.
  final String bold;

  /// Formatting action.
  final String italic;

  /// Formatting action.
  final String strikethrough;

  /// Formatting action.
  final String code;

  /// Formatting action.
  final String link;

  /// Label while an AI model is thinking.
  final String thinking;

  /// Label of a reasoning block without a duration.
  final String reasoning;

  /// Title of the sources of an AI answer.
  final String sources;

  /// Button that shows the previous version of an AI answer.
  final String previousVersion;

  /// Button that shows the next version of an AI answer.
  final String nextVersion;

  /// Preview of a video message.
  final String video;

  /// Accessibility label of the play button of a video.
  final String playVideo;

  /// Button that asks for the transcript of a voice note.
  final String transcribe;

  /// Label while a voice note is transcribed.
  final String transcribing;

  /// Preview of a checklist message.
  final String checklist;

  /// Default label of product buttons.
  final String view;

  /// Title of a payment request.
  final String paymentRequest;

  /// Title of a sent payment.
  final String paymentSent;

  /// Button that pays a request.
  final String pay;

  /// Button that declines a payment request.
  final String decline;

  /// Status of a pending payment.
  final String paymentPending;

  /// Status of a paid request.
  final String paymentPaid;

  /// Status of a declined request.
  final String paymentDeclined;

  /// Status of a cancelled request.
  final String paymentCancelled;

  /// Title of a voice call entry.
  final String voiceCall;

  /// Title of a video call entry.
  final String videoCall;

  /// Label of a missed call.
  final String missedCall;

  /// Label of a declined call.
  final String declinedCall;

  /// Button that calls back.
  final String callBack;

  /// Badge of the group owner.
  final String roleOwner;

  /// Badge of an administrator.
  final String roleAdmin;

  /// Badge of a moderator.
  final String roleModerator;

  /// Action of the profile sheet.
  final String sendMessage;

  /// Title of the member list.
  final String membersTitle;

  /// Tab of the media gallery.
  final String media;

  /// Tab of the media gallery.
  final String files;

  /// Tab of the media gallery.
  final String links;

  /// Empty state of a gallery tab.
  final String galleryEmpty;

  /// Action that opens a date picker to jump in the history.
  final String jumpToDate;

  /// Tooltip of the button that opens the message menu.
  final String moreActions;

  /// Label of a finished reasoning block. The count is in seconds.
  final ChatCountLabel thoughtFor;

  /// Progress of a checklist.
  final ChatStepLabel checklistProgress;

  /// Accessibility label of the button that jumps to unread mentions.
  final ChatCountLabel unreadMentions;

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
    spoiler: 'Spoiler. Double tap to reveal.',
    photo: 'Photo',
    file: 'File',
    voiceMessage: 'Voice message',
    poll: 'Poll',
    pollVotes: _votesEn,
    pollSelectOne: 'Select one',
    pollSelectMany: 'Select one or more',
    pollClosed: 'Final results',
    countdownCompleted: "It's time!",
    countdownDays: 'days',
    countdownHours: 'hours',
    countdownMinutes: 'min',
    countdownSeconds: 'sec',
    pinnedMessage: 'Pinned message',
    pin: 'Pin',
    unpin: 'Unpin',
    select: 'Select',
    selectedCount: _selectedEn,
    searchHint: 'Search',
    searchNoResults: 'No results',
    searchPrevious: 'Previous result',
    searchNext: 'Next result',
    holdToRecord: 'Hold to record a voice message',
    slideToCancel: 'Slide to cancel',
    play: 'Play',
    pause: 'Pause',
    uploading: 'Uploading',
    close: 'Close',
    mentionSuggestions: 'Mention suggestions',
    survey: 'Survey',
    surveyQuestions: _questionsEn,
    surveyResponses: _responsesEn,
    surveyAnswer: 'Answer',
    surveyAnswered: 'Answered',
    surveyClosed: 'Closed',
    surveyStep: _stepEn,
    surveyNext: 'Next',
    surveyBack: 'Back',
    surveySubmit: 'Submit',
    surveyOptional: 'Optional',
    surveyTextHint: 'Your answer',
    npsLow: 'Not likely',
    npsHigh: 'Very likely',
    threadReplies: _repliesEn,
    seenBy: _seenByEn,
    messageInfo: 'Info',
    readBy: 'Read by',
    forward: 'Forward',
    forwardedFrom: _forwardedEn,
    expiresIn: _expiresEn,
    online: 'online',
    lastSeen: _lastSeenEn,
    justNow: 'just now',
    minutesAgo: _minutesAgoEn,
    todayAt: _todayAtEn,
    yesterdayAt: _yesterdayAtEn,
    members: _membersEn,
    emoji: 'Emoji',
    keyboard: 'Keyboard',
    searchEmoji: 'Search emoji',
    emojiCategories: _emojiCategoriesEn,
    moreReactions: 'More reactions',
    typingShort: 'typing…',
    regenerate: 'Regenerate',
    goodResponse: 'Good response',
    badResponse: 'Bad response',
    stopGenerating: 'Stop generating',
    copyCode: 'Copy code',
    copied: 'Copied',
    translate: 'Translate',
    translated: 'Translated',
    showOriginal: 'Show original',
    showTranslation: 'Show translation',
    translating: 'Translating…',
    translationFailed: "Couldn't translate",
    location: 'Location',
    liveLocation: 'Live location',
    liveUntil: _liveUntilEn,
    event: 'Event',
    rsvpGoing: 'Going',
    rsvpMaybe: 'Maybe',
    rsvpNotGoing: "Can't go",
    rsvpSummary: _rsvpEn,
    contact: 'Contact',
    call: 'Call',
    sendEmail: 'Email',
    addContact: 'Add contact',
    sticker: 'Sticker',
    deleteForEveryone: 'Delete for everyone',
    messageDeleted: 'This message was deleted',
    editHistory: 'Edit history',
    currentVersion: 'Current',
    scheduledFor: _scheduledEn,
    scheduleMessage: 'Schedule message',
    sendNow: 'Send now',
    inOneHour: 'In 1 hour',
    tonight: 'Tonight',
    tomorrowMorning: 'Tomorrow morning',
    pickDateTime: 'Pick date and time',
    readOnly: 'Only admins can send messages',
    slowModeWait: _slowEn,
    report: 'Report',
    block: _blockEn,
    save: 'Save',
    unsave: 'Remove from saved',
    saved: 'Saved',
    statusQueued: 'Waiting for network',
    offline: 'Waiting for network…',
    connecting: 'Connecting…',
    attach: 'Attach',
    removeAttachment: 'Remove',
    addCaption: 'Add a caption…',
    bold: 'Bold',
    italic: 'Italic',
    strikethrough: 'Strikethrough',
    code: 'Code',
    link: 'Link',
    thinking: 'Thinking…',
    reasoning: 'Reasoning',
    sources: 'Sources',
    previousVersion: 'Previous version',
    nextVersion: 'Next version',
    video: 'Video',
    playVideo: 'Play video',
    transcribe: 'Transcribe',
    transcribing: 'Transcribing…',
    checklist: 'Checklist',
    view: 'View',
    paymentRequest: 'Payment request',
    paymentSent: 'Payment sent',
    pay: 'Pay',
    decline: 'Decline',
    paymentPending: 'Pending',
    paymentPaid: 'Paid',
    paymentDeclined: 'Declined',
    paymentCancelled: 'Cancelled',
    voiceCall: 'Voice call',
    videoCall: 'Video call',
    missedCall: 'Missed',
    declinedCall: 'Declined',
    callBack: 'Call back',
    roleOwner: 'Owner',
    roleAdmin: 'Admin',
    roleModerator: 'Mod',
    sendMessage: 'Message',
    membersTitle: 'Members',
    media: 'Media',
    files: 'Files',
    links: 'Links',
    galleryEmpty: 'Nothing here yet',
    jumpToDate: 'Jump to date',
    moreActions: 'More actions',
    thoughtFor: _thoughtForEn,
    checklistProgress: _checklistProgressEn,
    unreadMentions: _unreadMentionsEn,
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
    spoiler: 'Spoiler. Toca dos veces para mostrar.',
    photo: 'Foto',
    file: 'Archivo',
    voiceMessage: 'Mensaje de voz',
    poll: 'Votación',
    pollVotes: _votesEs,
    pollSelectOne: 'Elige una',
    pollSelectMany: 'Elige una o más',
    pollClosed: 'Resultados finales',
    countdownCompleted: '¡Llegó el momento!',
    countdownDays: 'días',
    countdownHours: 'horas',
    countdownMinutes: 'min',
    countdownSeconds: 'seg',
    pinnedMessage: 'Mensaje fijado',
    pin: 'Fijar',
    unpin: 'Desfijar',
    select: 'Seleccionar',
    selectedCount: _selectedEs,
    searchHint: 'Buscar',
    searchNoResults: 'Sin resultados',
    searchPrevious: 'Resultado anterior',
    searchNext: 'Resultado siguiente',
    holdToRecord: 'Mantén presionado para grabar',
    slideToCancel: 'Desliza para cancelar',
    play: 'Reproducir',
    pause: 'Pausar',
    uploading: 'Subiendo',
    close: 'Cerrar',
    mentionSuggestions: 'Sugerencias de menciones',
    survey: 'Encuesta',
    surveyQuestions: _questionsEs,
    surveyResponses: _responsesEs,
    surveyAnswer: 'Responder',
    surveyAnswered: 'Respondida',
    surveyClosed: 'Cerrada',
    surveyStep: _stepEs,
    surveyNext: 'Siguiente',
    surveyBack: 'Atrás',
    surveySubmit: 'Enviar',
    surveyOptional: 'Opcional',
    surveyTextHint: 'Tu respuesta',
    npsLow: 'Poco probable',
    npsHigh: 'Muy probable',
    threadReplies: _repliesEs,
    seenBy: _seenByEs,
    messageInfo: 'Info',
    readBy: 'Leído por',
    forward: 'Reenviar',
    forwardedFrom: _forwardedEs,
    expiresIn: _expiresEs,
    online: 'en línea',
    lastSeen: _lastSeenEs,
    justNow: 'hace un momento',
    minutesAgo: _minutesAgoEs,
    todayAt: _todayAtEs,
    yesterdayAt: _yesterdayAtEs,
    members: _membersEs,
    emoji: 'Emoji',
    keyboard: 'Teclado',
    searchEmoji: 'Buscar emoji',
    emojiCategories: _emojiCategoriesEs,
    moreReactions: 'Más reacciones',
    typingShort: 'escribiendo…',
    regenerate: 'Regenerar',
    goodResponse: 'Buena respuesta',
    badResponse: 'Mala respuesta',
    stopGenerating: 'Detener',
    copyCode: 'Copiar código',
    copied: 'Copiado',
    translate: 'Traducir',
    translated: 'Traducido',
    showOriginal: 'Ver original',
    showTranslation: 'Ver traducción',
    translating: 'Traduciendo…',
    translationFailed: 'No se pudo traducir',
    location: 'Ubicación',
    liveLocation: 'Ubicación en vivo',
    liveUntil: _liveUntilEs,
    event: 'Evento',
    rsvpGoing: 'Asistiré',
    rsvpMaybe: 'Tal vez',
    rsvpNotGoing: 'No puedo',
    rsvpSummary: _rsvpEs,
    contact: 'Contacto',
    call: 'Llamar',
    sendEmail: 'Correo',
    addContact: 'Agregar',
    sticker: 'Sticker',
    deleteForEveryone: 'Eliminar para todos',
    messageDeleted: 'Este mensaje fue eliminado',
    editHistory: 'Historial de ediciones',
    currentVersion: 'Actual',
    scheduledFor: _scheduledEs,
    scheduleMessage: 'Programar mensaje',
    sendNow: 'Enviar ahora',
    inOneHour: 'En 1 hora',
    tonight: 'Esta noche',
    tomorrowMorning: 'Mañana por la mañana',
    pickDateTime: 'Elegir fecha y hora',
    readOnly: 'Solo los administradores pueden enviar mensajes',
    slowModeWait: _slowEs,
    report: 'Reportar',
    block: _blockEs,
    save: 'Guardar',
    unsave: 'Quitar de guardados',
    saved: 'Guardado',
    statusQueued: 'Esperando conexión',
    offline: 'Esperando conexión…',
    connecting: 'Conectando…',
    attach: 'Adjuntar',
    removeAttachment: 'Quitar',
    addCaption: 'Añade un comentario…',
    bold: 'Negrita',
    italic: 'Cursiva',
    strikethrough: 'Tachado',
    code: 'Código',
    link: 'Enlace',
    thinking: 'Pensando…',
    reasoning: 'Razonamiento',
    sources: 'Fuentes',
    previousVersion: 'Versión anterior',
    nextVersion: 'Versión siguiente',
    video: 'Video',
    playVideo: 'Reproducir video',
    transcribe: 'Transcribir',
    transcribing: 'Transcribiendo…',
    checklist: 'Lista de tareas',
    view: 'Ver',
    paymentRequest: 'Solicitud de pago',
    paymentSent: 'Pago enviado',
    pay: 'Pagar',
    decline: 'Rechazar',
    paymentPending: 'Pendiente',
    paymentPaid: 'Pagado',
    paymentDeclined: 'Rechazado',
    paymentCancelled: 'Cancelado',
    voiceCall: 'Llamada de voz',
    videoCall: 'Videollamada',
    missedCall: 'Perdida',
    declinedCall: 'Rechazada',
    callBack: 'Devolver llamada',
    roleOwner: 'Propietario',
    roleAdmin: 'Admin',
    roleModerator: 'Mod',
    sendMessage: 'Mensaje',
    membersTitle: 'Miembros',
    media: 'Multimedia',
    files: 'Archivos',
    links: 'Enlaces',
    galleryEmpty: 'Aún no hay nada',
    jumpToDate: 'Ir a una fecha',
    moreActions: 'Más acciones',
    thoughtFor: _thoughtForEs,
    checklistProgress: _checklistProgressEs,
    unreadMentions: _unreadMentionsEs,
  );

  /// Portuguese strings.
  static const ChatLocalizations pt = ChatLocalizations(
    inputHint: 'Mensagem',
    sendButton: 'Enviar',
    today: 'Hoje',
    yesterday: 'Ontem',
    edited: 'editada',
    you: 'Você',
    someone: 'Alguém',
    typing: _typingPt,
    copy: 'Copiar texto',
    retry: 'Tentar novamente',
    failedToSend: 'Não enviada. Toque para tentar novamente.',
    loadMoreFailed: 'Não foi possível carregar mensagens antigas.',
    scrollToBottom: 'Ir para as mensagens mais recentes',
    unreadMessages: _unreadMessagesPt,
    emptyState: 'Ainda não há mensagens. Diga olá!',
    unsupportedMessage: 'Este tipo de mensagem não é compatível.',
    statusSending: 'Enviando',
    statusSent: 'Enviada',
    statusDelivered: 'Entregue',
    statusRead: 'Lida',
    statusFailed: 'Falha no envio',
    reply: 'Responder',
    edit: 'Editar',
    delete: 'Excluir',
    cancel: 'Cancelar',
    replyingTo: _replyingToPt,
    editingMessage: 'Editando mensagem',
    unreadSeparator: 'Novas mensagens',
    quoteUnavailable: 'Mensagem original indisponível',
    addReaction: 'Adicionar reação',
    reactionLabel: _reactionLabelPt,
    spoiler: 'Spoiler. Toque duas vezes para revelar.',
    photo: 'Foto',
    file: 'Arquivo',
    voiceMessage: 'Mensagem de voz',
    poll: 'Votação',
    pollVotes: _pollVotesPt,
    pollSelectOne: 'Escolha uma',
    pollSelectMany: 'Escolha uma ou mais',
    pollClosed: 'Resultados finais',
    countdownCompleted: 'Chegou a hora!',
    countdownDays: 'dias',
    countdownHours: 'horas',
    countdownMinutes: 'min',
    countdownSeconds: 'seg',
    pinnedMessage: 'Mensagem fixada',
    pin: 'Fixar',
    unpin: 'Desafixar',
    select: 'Selecionar',
    selectedCount: _selectedCountPt,
    searchHint: 'Pesquisar',
    searchNoResults: 'Nenhum resultado',
    searchPrevious: 'Resultado anterior',
    searchNext: 'Próximo resultado',
    holdToRecord: 'Mantenha pressionado para gravar',
    slideToCancel: 'Deslize para cancelar',
    play: 'Reproduzir',
    pause: 'Pausar',
    uploading: 'Enviando',
    close: 'Fechar',
    mentionSuggestions: 'Sugestões de menção',
    survey: 'Pesquisa',
    surveyQuestions: _surveyQuestionsPt,
    surveyResponses: _surveyResponsesPt,
    surveyAnswer: 'Responder',
    surveyAnswered: 'Respondida',
    surveyClosed: 'Encerrada',
    surveyStep: _surveyStepPt,
    surveyNext: 'Próxima',
    surveyBack: 'Voltar',
    surveySubmit: 'Enviar',
    surveyOptional: 'Opcional',
    surveyTextHint: 'Sua resposta',
    npsLow: 'Pouco provável',
    npsHigh: 'Muito provável',
    threadReplies: _threadRepliesPt,
    seenBy: _seenByPt,
    messageInfo: 'Informações',
    readBy: 'Lida por',
    forward: 'Encaminhar',
    forwardedFrom: _forwardedFromPt,
    expiresIn: _expiresInPt,
    online: 'online',
    lastSeen: _lastSeenPt,
    justNow: 'agora mesmo',
    minutesAgo: _minutesAgoPt,
    todayAt: _todayAtPt,
    yesterdayAt: _yesterdayAtPt,
    members: _membersPt,
    emoji: 'Emoji',
    keyboard: 'Teclado',
    searchEmoji: 'Pesquisar emoji',
    emojiCategories: _emojiCategoriesPt,
    moreReactions: 'Mais reações',
    typingShort: 'digitando…',
    regenerate: 'Gerar novamente',
    goodResponse: 'Boa resposta',
    badResponse: 'Resposta ruim',
    stopGenerating: 'Parar',
    copyCode: 'Copiar código',
    copied: 'Copiado',
    translate: 'Traduzir',
    translated: 'Traduzida',
    showOriginal: 'Ver original',
    showTranslation: 'Ver tradução',
    translating: 'Traduzindo…',
    translationFailed: 'Não foi possível traduzir',
    location: 'Localização',
    liveLocation: 'Localização em tempo real',
    liveUntil: _liveUntilPt,
    event: 'Evento',
    rsvpGoing: 'Vou',
    rsvpMaybe: 'Talvez',
    rsvpNotGoing: 'Não vou',
    rsvpSummary: _rsvpSummaryPt,
    contact: 'Contato',
    call: 'Ligar',
    sendEmail: 'E-mail',
    addContact: 'Adicionar',
    sticker: 'Figurinha',
    deleteForEveryone: 'Excluir para todos',
    messageDeleted: 'Esta mensagem foi excluída',
    editHistory: 'Histórico de edições',
    currentVersion: 'Atual',
    scheduledFor: _scheduledForPt,
    scheduleMessage: 'Agendar mensagem',
    sendNow: 'Enviar agora',
    inOneHour: 'Em 1 hora',
    tonight: 'Hoje à noite',
    tomorrowMorning: 'Amanhã de manhã',
    pickDateTime: 'Escolher data e hora',
    readOnly: 'Somente administradores podem enviar mensagens',
    slowModeWait: _slowModeWaitPt,
    report: 'Denunciar',
    block: _blockPt,
    save: 'Salvar',
    unsave: 'Remover dos salvos',
    saved: 'Salva',
    statusQueued: 'Aguardando conexão',
    offline: 'Aguardando conexão…',
    connecting: 'Conectando…',
    attach: 'Anexar',
    removeAttachment: 'Remover',
    addCaption: 'Adicione uma legenda…',
    bold: 'Negrito',
    italic: 'Itálico',
    strikethrough: 'Tachado',
    code: 'Código',
    link: 'Link',
    thinking: 'Pensando…',
    reasoning: 'Raciocínio',
    sources: 'Fontes',
    previousVersion: 'Versão anterior',
    nextVersion: 'Próxima versão',
    video: 'Vídeo',
    playVideo: 'Reproduzir vídeo',
    transcribe: 'Transcrever',
    transcribing: 'Transcrevendo…',
    checklist: 'Lista de tarefas',
    view: 'Ver',
    paymentRequest: 'Pedido de pagamento',
    paymentSent: 'Pagamento enviado',
    pay: 'Pagar',
    decline: 'Recusar',
    paymentPending: 'Pendente',
    paymentPaid: 'Pago',
    paymentDeclined: 'Recusado',
    paymentCancelled: 'Cancelado',
    voiceCall: 'Chamada de voz',
    videoCall: 'Chamada de vídeo',
    missedCall: 'Perdida',
    declinedCall: 'Recusada',
    callBack: 'Retornar',
    roleOwner: 'Proprietário',
    roleAdmin: 'Admin',
    roleModerator: 'Mod',
    sendMessage: 'Mensagem',
    membersTitle: 'Membros',
    media: 'Mídia',
    files: 'Arquivos',
    links: 'Links',
    galleryEmpty: 'Nada aqui ainda',
    jumpToDate: 'Ir para data',
    moreActions: 'Mais ações',
    thoughtFor: _thoughtForPt,
    checklistProgress: _checklistProgressPt,
    unreadMentions: _unreadMentionsPt,
  );

  /// French strings.
  static const ChatLocalizations fr = ChatLocalizations(
    inputHint: 'Message',
    sendButton: 'Envoyer',
    today: "Aujourd'hui",
    yesterday: 'Hier',
    edited: 'modifié',
    you: 'Vous',
    someone: 'Quelqu’un',
    typing: _typingFr,
    copy: 'Copier le texte',
    retry: 'Réessayer',
    failedToSend: 'Non envoyé. Touchez pour réessayer.',
    loadMoreFailed: 'Impossible de charger les anciens messages.',
    scrollToBottom: 'Aller aux derniers messages',
    unreadMessages: _unreadMessagesFr,
    emptyState: 'Pas encore de messages. Dites bonjour !',
    unsupportedMessage: 'Ce type de message n’est pas pris en charge.',
    statusSending: 'Envoi en cours',
    statusSent: 'Envoyé',
    statusDelivered: 'Distribué',
    statusRead: 'Lu',
    statusFailed: 'Échec de l’envoi',
    reply: 'Répondre',
    edit: 'Modifier',
    delete: 'Supprimer',
    cancel: 'Annuler',
    replyingTo: _replyingToFr,
    editingMessage: 'Modification du message',
    unreadSeparator: 'Nouveaux messages',
    quoteUnavailable: 'Message d’origine indisponible',
    addReaction: 'Ajouter une réaction',
    reactionLabel: _reactionLabelFr,
    spoiler: 'Spoiler. Touchez deux fois pour afficher.',
    photo: 'Photo',
    file: 'Fichier',
    voiceMessage: 'Message vocal',
    poll: 'Vote',
    pollVotes: _pollVotesFr,
    pollSelectOne: 'Choisissez-en une',
    pollSelectMany: 'Choisissez-en une ou plusieurs',
    pollClosed: 'Résultats finaux',
    countdownCompleted: 'C’est l’heure !',
    countdownDays: 'jours',
    countdownHours: 'heures',
    countdownMinutes: 'min',
    countdownSeconds: 's',
    pinnedMessage: 'Message épinglé',
    pin: 'Épingler',
    unpin: 'Désépingler',
    select: 'Sélectionner',
    selectedCount: _selectedCountFr,
    searchHint: 'Rechercher',
    searchNoResults: 'Aucun résultat',
    searchPrevious: 'Résultat précédent',
    searchNext: 'Résultat suivant',
    holdToRecord: 'Maintenez pour enregistrer',
    slideToCancel: 'Glissez pour annuler',
    play: 'Lire',
    pause: 'Pause',
    uploading: 'Téléversement',
    close: 'Fermer',
    mentionSuggestions: 'Suggestions de mention',
    survey: 'Sondage',
    surveyQuestions: _surveyQuestionsFr,
    surveyResponses: _surveyResponsesFr,
    surveyAnswer: 'Répondre',
    surveyAnswered: 'Répondu',
    surveyClosed: 'Fermé',
    surveyStep: _surveyStepFr,
    surveyNext: 'Suivant',
    surveyBack: 'Retour',
    surveySubmit: 'Envoyer',
    surveyOptional: 'Facultatif',
    surveyTextHint: 'Votre réponse',
    npsLow: 'Peu probable',
    npsHigh: 'Très probable',
    threadReplies: _threadRepliesFr,
    seenBy: _seenByFr,
    messageInfo: 'Infos',
    readBy: 'Lu par',
    forward: 'Transférer',
    forwardedFrom: _forwardedFromFr,
    expiresIn: _expiresInFr,
    online: 'en ligne',
    lastSeen: _lastSeenFr,
    justNow: 'à l’instant',
    minutesAgo: _minutesAgoFr,
    todayAt: _todayAtFr,
    yesterdayAt: _yesterdayAtFr,
    members: _membersFr,
    emoji: 'Emoji',
    keyboard: 'Clavier',
    searchEmoji: 'Rechercher un emoji',
    emojiCategories: _emojiCategoriesFr,
    moreReactions: 'Plus de réactions',
    typingShort: 'écrit…',
    regenerate: 'Régénérer',
    goodResponse: 'Bonne réponse',
    badResponse: 'Mauvaise réponse',
    stopGenerating: 'Arrêter',
    copyCode: 'Copier le code',
    copied: 'Copié',
    translate: 'Traduire',
    translated: 'Traduit',
    showOriginal: 'Voir l’original',
    showTranslation: 'Voir la traduction',
    translating: 'Traduction…',
    translationFailed: 'Traduction impossible',
    location: 'Position',
    liveLocation: 'Position en direct',
    liveUntil: _liveUntilFr,
    event: 'Événement',
    rsvpGoing: 'J’y vais',
    rsvpMaybe: 'Peut-être',
    rsvpNotGoing: 'Je n’y vais pas',
    rsvpSummary: _rsvpSummaryFr,
    contact: 'Contact',
    call: 'Appeler',
    sendEmail: 'E-mail',
    addContact: 'Ajouter',
    sticker: 'Autocollant',
    deleteForEveryone: 'Supprimer pour tous',
    messageDeleted: 'Ce message a été supprimé',
    editHistory: 'Historique des modifications',
    currentVersion: 'Actuelle',
    scheduledFor: _scheduledForFr,
    scheduleMessage: 'Programmer le message',
    sendNow: 'Envoyer maintenant',
    inOneHour: 'Dans 1 heure',
    tonight: 'Ce soir',
    tomorrowMorning: 'Demain matin',
    pickDateTime: 'Choisir la date et l’heure',
    readOnly: 'Seuls les administrateurs peuvent envoyer des messages',
    slowModeWait: _slowModeWaitFr,
    report: 'Signaler',
    block: _blockFr,
    save: 'Enregistrer',
    unsave: 'Retirer des enregistrés',
    saved: 'Enregistré',
    statusQueued: 'En attente de réseau',
    offline: 'En attente de réseau…',
    connecting: 'Connexion…',
    attach: 'Joindre',
    removeAttachment: 'Retirer',
    addCaption: 'Ajouter une légende…',
    bold: 'Gras',
    italic: 'Italique',
    strikethrough: 'Barré',
    code: 'Code',
    link: 'Lien',
    thinking: 'Réflexion…',
    reasoning: 'Raisonnement',
    sources: 'Sources',
    previousVersion: 'Version précédente',
    nextVersion: 'Version suivante',
    video: 'Vidéo',
    playVideo: 'Lire la vidéo',
    transcribe: 'Transcrire',
    transcribing: 'Transcription…',
    checklist: 'Liste de tâches',
    view: 'Voir',
    paymentRequest: 'Demande de paiement',
    paymentSent: 'Paiement envoyé',
    pay: 'Payer',
    decline: 'Refuser',
    paymentPending: 'En attente',
    paymentPaid: 'Payé',
    paymentDeclined: 'Refusé',
    paymentCancelled: 'Annulé',
    voiceCall: 'Appel vocal',
    videoCall: 'Appel vidéo',
    missedCall: 'Manqué',
    declinedCall: 'Refusé',
    callBack: 'Rappeler',
    roleOwner: 'Propriétaire',
    roleAdmin: 'Admin',
    roleModerator: 'Modo',
    sendMessage: 'Message',
    membersTitle: 'Membres',
    media: 'Médias',
    files: 'Fichiers',
    links: 'Liens',
    galleryEmpty: 'Rien pour l’instant',
    jumpToDate: 'Aller à une date',
    moreActions: 'Plus d’actions',
    thoughtFor: _thoughtForFr,
    checklistProgress: _checklistProgressFr,
    unreadMentions: _unreadMentionsFr,
  );

  /// German strings.
  static const ChatLocalizations de = ChatLocalizations(
    inputHint: 'Nachricht',
    sendButton: 'Senden',
    today: 'Heute',
    yesterday: 'Gestern',
    edited: 'bearbeitet',
    you: 'Du',
    someone: 'Jemand',
    typing: _typingDe,
    copy: 'Text kopieren',
    retry: 'Erneut versuchen',
    failedToSend: 'Nicht gesendet. Tippen, um es erneut zu versuchen.',
    loadMoreFailed: 'Ältere Nachrichten konnten nicht geladen werden.',
    scrollToBottom: 'Zu den neuesten Nachrichten',
    unreadMessages: _unreadMessagesDe,
    emptyState: 'Noch keine Nachrichten. Sag Hallo!',
    unsupportedMessage: 'Dieser Nachrichtentyp wird nicht unterstützt.',
    statusSending: 'Wird gesendet',
    statusSent: 'Gesendet',
    statusDelivered: 'Zugestellt',
    statusRead: 'Gelesen',
    statusFailed: 'Senden fehlgeschlagen',
    reply: 'Antworten',
    edit: 'Bearbeiten',
    delete: 'Löschen',
    cancel: 'Abbrechen',
    replyingTo: _replyingToDe,
    editingMessage: 'Nachricht bearbeiten',
    unreadSeparator: 'Neue Nachrichten',
    quoteUnavailable: 'Ursprüngliche Nachricht nicht verfügbar',
    addReaction: 'Reaktion hinzufügen',
    reactionLabel: _reactionLabelDe,
    spoiler: 'Spoiler. Zum Anzeigen doppelt tippen.',
    photo: 'Foto',
    file: 'Datei',
    voiceMessage: 'Sprachnachricht',
    poll: 'Abstimmung',
    pollVotes: _pollVotesDe,
    pollSelectOne: 'Wähle eine Option',
    pollSelectMany: 'Wähle eine oder mehrere',
    pollClosed: 'Endergebnis',
    countdownCompleted: 'Es ist so weit!',
    countdownDays: 'Tage',
    countdownHours: 'Std.',
    countdownMinutes: 'Min.',
    countdownSeconds: 'Sek.',
    pinnedMessage: 'Angeheftete Nachricht',
    pin: 'Anheften',
    unpin: 'Lösen',
    select: 'Auswählen',
    selectedCount: _selectedCountDe,
    searchHint: 'Suchen',
    searchNoResults: 'Keine Ergebnisse',
    searchPrevious: 'Vorheriges Ergebnis',
    searchNext: 'Nächstes Ergebnis',
    holdToRecord: 'Gedrückt halten zum Aufnehmen',
    slideToCancel: 'Zum Abbrechen wischen',
    play: 'Abspielen',
    pause: 'Pause',
    uploading: 'Wird hochgeladen',
    close: 'Schließen',
    mentionSuggestions: 'Erwähnungsvorschläge',
    survey: 'Umfrage',
    surveyQuestions: _surveyQuestionsDe,
    surveyResponses: _surveyResponsesDe,
    surveyAnswer: 'Teilnehmen',
    surveyAnswered: 'Beantwortet',
    surveyClosed: 'Beendet',
    surveyStep: _surveyStepDe,
    surveyNext: 'Weiter',
    surveyBack: 'Zurück',
    surveySubmit: 'Absenden',
    surveyOptional: 'Optional',
    surveyTextHint: 'Deine Antwort',
    npsLow: 'Unwahrscheinlich',
    npsHigh: 'Sehr wahrscheinlich',
    threadReplies: _threadRepliesDe,
    seenBy: _seenByDe,
    messageInfo: 'Info',
    readBy: 'Gelesen von',
    forward: 'Weiterleiten',
    forwardedFrom: _forwardedFromDe,
    expiresIn: _expiresInDe,
    online: 'online',
    lastSeen: _lastSeenDe,
    justNow: 'gerade eben',
    minutesAgo: _minutesAgoDe,
    todayAt: _todayAtDe,
    yesterdayAt: _yesterdayAtDe,
    members: _membersDe,
    emoji: 'Emoji',
    keyboard: 'Tastatur',
    searchEmoji: 'Emoji suchen',
    emojiCategories: _emojiCategoriesDe,
    moreReactions: 'Weitere Reaktionen',
    typingShort: 'schreibt…',
    regenerate: 'Neu generieren',
    goodResponse: 'Gute Antwort',
    badResponse: 'Schlechte Antwort',
    stopGenerating: 'Stoppen',
    copyCode: 'Code kopieren',
    copied: 'Kopiert',
    translate: 'Übersetzen',
    translated: 'Übersetzt',
    showOriginal: 'Original anzeigen',
    showTranslation: 'Übersetzung anzeigen',
    translating: 'Wird übersetzt…',
    translationFailed: 'Übersetzung fehlgeschlagen',
    location: 'Standort',
    liveLocation: 'Live-Standort',
    liveUntil: _liveUntilDe,
    event: 'Ereignis',
    rsvpGoing: 'Ich komme',
    rsvpMaybe: 'Vielleicht',
    rsvpNotGoing: 'Ich komme nicht',
    rsvpSummary: _rsvpSummaryDe,
    contact: 'Kontakt',
    call: 'Anrufen',
    sendEmail: 'E-Mail',
    addContact: 'Hinzufügen',
    sticker: 'Sticker',
    deleteForEveryone: 'Für alle löschen',
    messageDeleted: 'Diese Nachricht wurde gelöscht',
    editHistory: 'Bearbeitungsverlauf',
    currentVersion: 'Aktuell',
    scheduledFor: _scheduledForDe,
    scheduleMessage: 'Nachricht planen',
    sendNow: 'Jetzt senden',
    inOneHour: 'In 1 Stunde',
    tonight: 'Heute Abend',
    tomorrowMorning: 'Morgen früh',
    pickDateTime: 'Datum und Uhrzeit wählen',
    readOnly: 'Nur Admins können Nachrichten senden',
    slowModeWait: _slowModeWaitDe,
    report: 'Melden',
    block: _blockDe,
    save: 'Speichern',
    unsave: 'Aus Gespeichert entfernen',
    saved: 'Gespeichert',
    statusQueued: 'Wartet auf Netzwerk',
    offline: 'Warte auf Netzwerk…',
    connecting: 'Verbinde…',
    attach: 'Anhängen',
    removeAttachment: 'Entfernen',
    addCaption: 'Bildunterschrift hinzufügen…',
    bold: 'Fett',
    italic: 'Kursiv',
    strikethrough: 'Durchgestrichen',
    code: 'Code',
    link: 'Link',
    thinking: 'Denkt nach…',
    reasoning: 'Überlegungen',
    sources: 'Quellen',
    previousVersion: 'Vorherige Version',
    nextVersion: 'Nächste Version',
    video: 'Video',
    playVideo: 'Video abspielen',
    transcribe: 'Transkribieren',
    transcribing: 'Wird transkribiert…',
    checklist: 'Checkliste',
    view: 'Ansehen',
    paymentRequest: 'Zahlungsanforderung',
    paymentSent: 'Zahlung gesendet',
    pay: 'Bezahlen',
    decline: 'Ablehnen',
    paymentPending: 'Ausstehend',
    paymentPaid: 'Bezahlt',
    paymentDeclined: 'Abgelehnt',
    paymentCancelled: 'Storniert',
    voiceCall: 'Sprachanruf',
    videoCall: 'Videoanruf',
    missedCall: 'Verpasst',
    declinedCall: 'Abgelehnt',
    callBack: 'Zurückrufen',
    roleOwner: 'Inhaber',
    roleAdmin: 'Admin',
    roleModerator: 'Mod',
    sendMessage: 'Nachricht',
    membersTitle: 'Mitglieder',
    media: 'Medien',
    files: 'Dateien',
    links: 'Links',
    galleryEmpty: 'Noch nichts hier',
    jumpToDate: 'Zu Datum springen',
    moreActions: 'Weitere Aktionen',
    thoughtFor: _thoughtForDe,
    checklistProgress: _checklistProgressDe,
    unreadMentions: _unreadMentionsDe,
  );

  /// Built-in strings by language code.
  static const Map<String, ChatLocalizations> builtIn = {
    'en': en,
    'es': es,
    'pt': pt,
    'fr': fr,
    'de': de,
  };

  static String _typingPt(List<String> names) => switch (names.length) {
        0 => '',
        1 => '${names[0]} está digitando…',
        2 => '${names[0]} e ${names[1]} estão digitando…',
        _ => '${names[0]} e mais ${names.length - 1} estão digitando…',
      };

  static String _unreadMessagesPt(int count) =>
      count == 1 ? '1 nova mensagem' : '$count novas mensagens';

  static String _replyingToPt(String name) => 'Respondendo a $name';

  static String _reactionLabelPt(String emoji, int count,
          {required bool includesYou}) =>
      includesYou ? '$emoji $count, incluindo você' : '$emoji $count';

  static String _pollVotesPt(int count) =>
      count == 1 ? '1 voto' : '$count votos';

  static String _selectedCountPt(int count) =>
      count == 1 ? '1 selecionada' : '$count selecionadas';

  static String _surveyQuestionsPt(int count) =>
      count == 1 ? '1 pergunta' : '$count perguntas';

  static String _surveyResponsesPt(int count) =>
      count == 1 ? '1 resposta' : '$count respostas';

  static String _surveyStepPt(int current, int total) =>
      'Pergunta $current de $total';

  static String _threadRepliesPt(int count) =>
      count == 1 ? '1 resposta' : '$count respostas';

  static String _seenByPt(List<String> names) => names.length <= 3
      ? 'Vista por ${names.join(', ')}'
      : 'Vista por ${names.take(2).join(', ')} e mais ${names.length - 2}';

  static String _forwardedFromPt(String name) => 'Encaminhada de $name';

  static String _expiresInPt(String name) => 'Desaparece em $name';

  static String _lastSeenPt(String name) => 'visto $name';

  static String _minutesAgoPt(int count) => 'há $count min';

  static String _todayAtPt(String name) => 'hoje às $name';

  static String _yesterdayAtPt(String name) => 'ontem às $name';

  static String _membersPt(int count) =>
      count == 1 ? '1 membro' : '$count membros';

  static String _liveUntilPt(String name) => 'até $name';

  static String _rsvpSummaryPt(int going, int maybe) =>
      maybe == 0 ? '$going vão' : '$going vão · $maybe talvez';

  static String _scheduledForPt(String name) => 'Agendada para $name';

  static String _slowModeWaitPt(String name) => 'Modo lento: aguarde $name';

  static String _blockPt(String name) => 'Bloquear $name';

  static const _emojiCategoriesPt = [
    'Recentes',
    'Carinhas',
    'Pessoas',
    'Natureza',
    'Comida',
    'Atividades',
    'Viagens',
    'Objetos',
    'Símbolos',
    'Bandeiras',
  ];

  static String _typingFr(List<String> names) => switch (names.length) {
        0 => '',
        1 => '${names[0]} écrit…',
        2 => '${names[0]} et ${names[1]} écrivent…',
        _ => '${names[0]} et ${names.length - 1} autres écrivent…',
      };

  static String _unreadMessagesFr(int count) =>
      count == 1 ? '1 nouveau message' : '$count nouveaux messages';

  static String _replyingToFr(String name) => 'Réponse à $name';

  static String _reactionLabelFr(String emoji, int count,
          {required bool includesYou}) =>
      includesYou ? '$emoji $count, dont vous' : '$emoji $count';

  static String _pollVotesFr(int count) =>
      count == 1 ? '1 vote' : '$count votes';

  static String _selectedCountFr(int count) =>
      count == 1 ? '1 sélectionné' : '$count sélectionnés';

  static String _surveyQuestionsFr(int count) =>
      count == 1 ? '1 question' : '$count questions';

  static String _surveyResponsesFr(int count) =>
      count == 1 ? '1 réponse' : '$count réponses';

  static String _surveyStepFr(int current, int total) =>
      'Question $current sur $total';

  static String _threadRepliesFr(int count) =>
      count == 1 ? '1 réponse' : '$count réponses';

  static String _seenByFr(List<String> names) => names.length <= 3
      ? 'Vu par ${names.join(', ')}'
      : 'Vu par ${names.take(2).join(', ')} et ${names.length - 2} autres';

  static String _forwardedFromFr(String name) => 'Transféré de $name';

  static String _expiresInFr(String name) => 'Disparaît dans $name';

  static String _lastSeenFr(String name) => 'vu $name';

  static String _minutesAgoFr(int count) => 'il y a $count min';

  static String _todayAtFr(String name) => 'aujourd’hui à $name';

  static String _yesterdayAtFr(String name) => 'hier à $name';

  static String _membersFr(int count) =>
      count == 1 ? '1 membre' : '$count membres';

  static String _liveUntilFr(String name) => 'jusqu’à $name';

  static String _rsvpSummaryFr(int going, int maybe) =>
      maybe == 0 ? '$going y vont' : '$going y vont · $maybe peut-être';

  static String _scheduledForFr(String name) => 'Programmé pour $name';

  static String _slowModeWaitFr(String name) => 'Mode lent : attendez $name';

  static String _blockFr(String name) => 'Bloquer $name';

  static const _emojiCategoriesFr = [
    'Récents',
    'Smileys',
    'Personnes',
    'Nature',
    'Nourriture',
    'Activités',
    'Voyages',
    'Objets',
    'Symboles',
    'Drapeaux',
  ];

  static String _typingDe(List<String> names) => switch (names.length) {
        0 => '',
        1 => '${names[0]} schreibt…',
        2 => '${names[0]} und ${names[1]} schreiben…',
        _ => '${names[0]} und ${names.length - 1} weitere schreiben…',
      };

  static String _unreadMessagesDe(int count) =>
      count == 1 ? '1 neue Nachricht' : '$count neue Nachrichten';

  static String _replyingToDe(String name) => 'Antwort an $name';

  static String _reactionLabelDe(String emoji, int count,
          {required bool includesYou}) =>
      includesYou ? '$emoji $count, inklusive dir' : '$emoji $count';

  static String _pollVotesDe(int count) =>
      count == 1 ? '1 Stimme' : '$count Stimmen';

  static String _selectedCountDe(int count) => '$count ausgewählt';

  static String _surveyQuestionsDe(int count) =>
      count == 1 ? '1 Frage' : '$count Fragen';

  static String _surveyResponsesDe(int count) =>
      count == 1 ? '1 Antwort' : '$count Antworten';

  static String _surveyStepDe(int current, int total) =>
      'Frage $current von $total';

  static String _threadRepliesDe(int count) =>
      count == 1 ? '1 Antwort' : '$count Antworten';

  static String _seenByDe(List<String> names) => names.length <= 3
      ? 'Gesehen von ${names.join(', ')}'
      : 'Gesehen von ${names.take(2).join(', ')} und ${names.length - 2} weiteren';

  static String _forwardedFromDe(String name) => 'Weitergeleitet von $name';

  static String _expiresInDe(String name) => 'Verschwindet in $name';

  static String _lastSeenDe(String name) => 'zuletzt online $name';

  static String _minutesAgoDe(int count) => 'vor $count Min.';

  static String _todayAtDe(String name) => 'heute um $name';

  static String _yesterdayAtDe(String name) => 'gestern um $name';

  static String _membersDe(int count) =>
      count == 1 ? '1 Mitglied' : '$count Mitglieder';

  static String _liveUntilDe(String name) => 'bis $name';

  static String _rsvpSummaryDe(int going, int maybe) =>
      maybe == 0 ? '$going kommen' : '$going kommen · $maybe vielleicht';

  static String _scheduledForDe(String name) => 'Geplant für $name';

  static String _slowModeWaitDe(String name) => 'Langsamer Modus: warte $name';

  static String _blockDe(String name) => '$name blockieren';

  static const _emojiCategoriesDe = [
    'Zuletzt',
    'Smileys',
    'Personen',
    'Natur',
    'Essen',
    'Aktivitäten',
    'Reisen',
    'Objekte',
    'Symbole',
    'Flaggen',
  ];

  static String _thoughtForEn(int count) => 'Thought for ${count}s';

  static String _thoughtForEs(int count) => 'Pensó durante $count s';

  static String _thoughtForPt(int count) => 'Pensou por $count s';

  static String _thoughtForFr(int count) => 'Réflexion : $count s';

  static String _thoughtForDe(int count) => '$count s nachgedacht';

  static String _checklistProgressEn(int current, int total) =>
      '$current of $total done';

  static String _checklistProgressEs(int current, int total) =>
      '$current de $total hechas';

  static String _checklistProgressPt(int current, int total) =>
      '$current de $total feitas';

  static String _checklistProgressFr(int current, int total) =>
      '$current sur $total faites';

  static String _checklistProgressDe(int current, int total) =>
      '$current von $total erledigt';

  static String _unreadMentionsEn(int count) =>
      count == 1 ? '1 unread mention' : '$count unread mentions';

  static String _unreadMentionsEs(int count) =>
      count == 1 ? '1 mención sin leer' : '$count menciones sin leer';

  static String _unreadMentionsPt(int count) =>
      count == 1 ? '1 menção não lida' : '$count menções não lidas';

  static String _unreadMentionsFr(int count) =>
      count == 1 ? '1 mention non lue' : '$count mentions non lues';

  static String _unreadMentionsDe(int count) =>
      count == 1 ? '1 ungelesene Erwähnung' : '$count ungelesene Erwähnungen';

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

  static String _questionsEn(int n) => n == 1 ? '1 question' : '$n questions';
  static String _questionsEs(int n) => n == 1 ? '1 pregunta' : '$n preguntas';
  static String _responsesEn(int n) => n == 1 ? '1 response' : '$n responses';
  static String _responsesEs(int n) => n == 1 ? '1 respuesta' : '$n respuestas';
  static String _stepEn(int current, int total) =>
      'Question $current of $total';
  static String _stepEs(int current, int total) =>
      'Pregunta $current de $total';
  static String _repliesEn(int n) => n == 1 ? '1 reply' : '$n replies';
  static String _repliesEs(int n) => n == 1 ? '1 respuesta' : '$n respuestas';
  static String _seenByEn(List<String> names) => names.length <= 3
      ? 'Seen by ${names.join(', ')}'
      : 'Seen by ${names.take(2).join(', ')} and ${names.length - 2} others';
  static String _seenByEs(List<String> names) => names.length <= 3
      ? 'Visto por ${names.join(', ')}'
      : 'Visto por ${names.take(2).join(', ')} y ${names.length - 2} más';
  static String _forwardedEn(String name) => 'Forwarded from $name';
  static String _forwardedEs(String name) => 'Reenviado de $name';
  static String _expiresEn(String time) => 'Disappears in $time';
  static String _expiresEs(String time) => 'Desaparece en $time';
  static String _lastSeenEn(String when) => 'last seen $when';
  static String _lastSeenEs(String when) => 'visto $when';
  static String _minutesAgoEn(int n) => '$n min ago';
  static String _minutesAgoEs(int n) => 'hace $n min';
  static String _todayAtEn(String time) => 'today at $time';
  static String _todayAtEs(String time) => 'hoy a las $time';
  static String _yesterdayAtEn(String time) => 'yesterday at $time';
  static String _yesterdayAtEs(String time) => 'ayer a las $time';
  static String _membersEn(int n) => n == 1 ? '1 member' : '$n members';
  static String _membersEs(int n) => n == 1 ? '1 miembro' : '$n miembros';
  static const _emojiCategoriesEn = [
    'Recent',
    'Smileys',
    'People',
    'Nature',
    'Food',
    'Activities',
    'Travel',
    'Objects',
    'Symbols',
    'Flags',
  ];
  static const _emojiCategoriesEs = [
    'Recientes',
    'Caritas',
    'Personas',
    'Naturaleza',
    'Comida',
    'Actividades',
    'Viajes',
    'Objetos',
    'Símbolos',
    'Banderas',
  ];

  static String _liveUntilEn(String time) => 'until $time';
  static String _liveUntilEs(String time) => 'hasta las $time';
  static String _rsvpEn(int going, int maybe) =>
      maybe == 0 ? '$going going' : '$going going · $maybe maybe';
  static String _rsvpEs(int going, int maybe) =>
      maybe == 0 ? '$going asistirán' : '$going asistirán · $maybe tal vez';
  static String _scheduledEn(String time) => 'Scheduled for $time';
  static String _scheduledEs(String time) => 'Programado para $time';
  static String _slowEn(String time) => 'Slow mode: wait $time';
  static String _slowEs(String time) => 'Modo lento: espera $time';
  static String _blockEn(String name) => 'Block $name';
  static String _blockEs(String name) => 'Bloquear a $name';

  static String _votesEn(int count) => count == 1 ? '1 vote' : '$count votes';

  static String _votesEs(int count) => count == 1 ? '1 voto' : '$count votos';

  static String _selectedEn(int count) => '$count selected';

  static String _selectedEs(int count) =>
      count == 1 ? '1 seleccionado' : '$count seleccionados';

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
    String? spoiler,
    String? photo,
    String? file,
    String? voiceMessage,
    String? poll,
    ChatCountLabel? pollVotes,
    String? pollSelectOne,
    String? pollSelectMany,
    String? pollClosed,
    String? countdownCompleted,
    String? countdownDays,
    String? countdownHours,
    String? countdownMinutes,
    String? countdownSeconds,
    String? pinnedMessage,
    String? pin,
    String? unpin,
    String? select,
    ChatCountLabel? selectedCount,
    String? searchHint,
    String? searchNoResults,
    String? searchPrevious,
    String? searchNext,
    String? holdToRecord,
    String? slideToCancel,
    String? play,
    String? pause,
    String? uploading,
    String? close,
    String? mentionSuggestions,
    String? survey,
    ChatCountLabel? surveyQuestions,
    ChatCountLabel? surveyResponses,
    String? surveyAnswer,
    String? surveyAnswered,
    String? surveyClosed,
    ChatStepLabel? surveyStep,
    String? surveyNext,
    String? surveyBack,
    String? surveySubmit,
    String? surveyOptional,
    String? surveyTextHint,
    String? npsLow,
    String? npsHigh,
    ChatCountLabel? threadReplies,
    ChatTypingLabel? seenBy,
    String? messageInfo,
    String? readBy,
    String? forward,
    ChatNameLabel? forwardedFrom,
    ChatNameLabel? expiresIn,
    String? online,
    ChatNameLabel? lastSeen,
    String? justNow,
    ChatCountLabel? minutesAgo,
    ChatNameLabel? todayAt,
    ChatNameLabel? yesterdayAt,
    ChatCountLabel? members,
    String? emoji,
    String? keyboard,
    String? searchEmoji,
    List<String>? emojiCategories,
    String? moreReactions,
    String? typingShort,
    String? regenerate,
    String? goodResponse,
    String? badResponse,
    String? stopGenerating,
    String? copyCode,
    String? copied,
    String? translate,
    String? translated,
    String? showOriginal,
    String? showTranslation,
    String? translating,
    String? translationFailed,
    String? location,
    String? liveLocation,
    ChatNameLabel? liveUntil,
    String? event,
    String? rsvpGoing,
    String? rsvpMaybe,
    String? rsvpNotGoing,
    ChatRsvpLabel? rsvpSummary,
    String? contact,
    String? call,
    String? sendEmail,
    String? addContact,
    String? sticker,
    String? deleteForEveryone,
    String? messageDeleted,
    String? editHistory,
    String? currentVersion,
    ChatNameLabel? scheduledFor,
    String? scheduleMessage,
    String? sendNow,
    String? inOneHour,
    String? tonight,
    String? tomorrowMorning,
    String? pickDateTime,
    String? readOnly,
    ChatNameLabel? slowModeWait,
    String? report,
    ChatNameLabel? block,
    String? save,
    String? unsave,
    String? saved,
    String? statusQueued,
    String? offline,
    String? connecting,
    String? attach,
    String? removeAttachment,
    String? addCaption,
    String? bold,
    String? italic,
    String? strikethrough,
    String? code,
    String? link,
    String? thinking,
    String? reasoning,
    String? sources,
    String? previousVersion,
    String? nextVersion,
    String? video,
    String? playVideo,
    String? transcribe,
    String? transcribing,
    String? checklist,
    String? view,
    String? paymentRequest,
    String? paymentSent,
    String? pay,
    String? decline,
    String? paymentPending,
    String? paymentPaid,
    String? paymentDeclined,
    String? paymentCancelled,
    String? voiceCall,
    String? videoCall,
    String? missedCall,
    String? declinedCall,
    String? callBack,
    String? roleOwner,
    String? roleAdmin,
    String? roleModerator,
    String? sendMessage,
    String? membersTitle,
    String? media,
    String? files,
    String? links,
    String? galleryEmpty,
    String? jumpToDate,
    String? moreActions,
    ChatCountLabel? thoughtFor,
    ChatStepLabel? checklistProgress,
    ChatCountLabel? unreadMentions,
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
      spoiler: spoiler ?? this.spoiler,
      photo: photo ?? this.photo,
      file: file ?? this.file,
      voiceMessage: voiceMessage ?? this.voiceMessage,
      poll: poll ?? this.poll,
      pollVotes: pollVotes ?? this.pollVotes,
      pollSelectOne: pollSelectOne ?? this.pollSelectOne,
      pollSelectMany: pollSelectMany ?? this.pollSelectMany,
      pollClosed: pollClosed ?? this.pollClosed,
      countdownCompleted: countdownCompleted ?? this.countdownCompleted,
      countdownDays: countdownDays ?? this.countdownDays,
      countdownHours: countdownHours ?? this.countdownHours,
      countdownMinutes: countdownMinutes ?? this.countdownMinutes,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      pinnedMessage: pinnedMessage ?? this.pinnedMessage,
      pin: pin ?? this.pin,
      unpin: unpin ?? this.unpin,
      select: select ?? this.select,
      selectedCount: selectedCount ?? this.selectedCount,
      searchHint: searchHint ?? this.searchHint,
      searchNoResults: searchNoResults ?? this.searchNoResults,
      searchPrevious: searchPrevious ?? this.searchPrevious,
      searchNext: searchNext ?? this.searchNext,
      holdToRecord: holdToRecord ?? this.holdToRecord,
      slideToCancel: slideToCancel ?? this.slideToCancel,
      play: play ?? this.play,
      pause: pause ?? this.pause,
      uploading: uploading ?? this.uploading,
      close: close ?? this.close,
      mentionSuggestions: mentionSuggestions ?? this.mentionSuggestions,
      survey: survey ?? this.survey,
      surveyQuestions: surveyQuestions ?? this.surveyQuestions,
      surveyResponses: surveyResponses ?? this.surveyResponses,
      surveyAnswer: surveyAnswer ?? this.surveyAnswer,
      surveyAnswered: surveyAnswered ?? this.surveyAnswered,
      surveyClosed: surveyClosed ?? this.surveyClosed,
      surveyStep: surveyStep ?? this.surveyStep,
      surveyNext: surveyNext ?? this.surveyNext,
      surveyBack: surveyBack ?? this.surveyBack,
      surveySubmit: surveySubmit ?? this.surveySubmit,
      surveyOptional: surveyOptional ?? this.surveyOptional,
      surveyTextHint: surveyTextHint ?? this.surveyTextHint,
      npsLow: npsLow ?? this.npsLow,
      npsHigh: npsHigh ?? this.npsHigh,
      threadReplies: threadReplies ?? this.threadReplies,
      seenBy: seenBy ?? this.seenBy,
      messageInfo: messageInfo ?? this.messageInfo,
      readBy: readBy ?? this.readBy,
      forward: forward ?? this.forward,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      expiresIn: expiresIn ?? this.expiresIn,
      online: online ?? this.online,
      lastSeen: lastSeen ?? this.lastSeen,
      justNow: justNow ?? this.justNow,
      minutesAgo: minutesAgo ?? this.minutesAgo,
      todayAt: todayAt ?? this.todayAt,
      yesterdayAt: yesterdayAt ?? this.yesterdayAt,
      members: members ?? this.members,
      emoji: emoji ?? this.emoji,
      keyboard: keyboard ?? this.keyboard,
      searchEmoji: searchEmoji ?? this.searchEmoji,
      emojiCategories: emojiCategories ?? this.emojiCategories,
      moreReactions: moreReactions ?? this.moreReactions,
      typingShort: typingShort ?? this.typingShort,
      regenerate: regenerate ?? this.regenerate,
      goodResponse: goodResponse ?? this.goodResponse,
      badResponse: badResponse ?? this.badResponse,
      stopGenerating: stopGenerating ?? this.stopGenerating,
      copyCode: copyCode ?? this.copyCode,
      copied: copied ?? this.copied,
      translate: translate ?? this.translate,
      translated: translated ?? this.translated,
      showOriginal: showOriginal ?? this.showOriginal,
      showTranslation: showTranslation ?? this.showTranslation,
      translating: translating ?? this.translating,
      translationFailed: translationFailed ?? this.translationFailed,
      location: location ?? this.location,
      liveLocation: liveLocation ?? this.liveLocation,
      liveUntil: liveUntil ?? this.liveUntil,
      event: event ?? this.event,
      rsvpGoing: rsvpGoing ?? this.rsvpGoing,
      rsvpMaybe: rsvpMaybe ?? this.rsvpMaybe,
      rsvpNotGoing: rsvpNotGoing ?? this.rsvpNotGoing,
      rsvpSummary: rsvpSummary ?? this.rsvpSummary,
      contact: contact ?? this.contact,
      call: call ?? this.call,
      sendEmail: sendEmail ?? this.sendEmail,
      addContact: addContact ?? this.addContact,
      sticker: sticker ?? this.sticker,
      deleteForEveryone: deleteForEveryone ?? this.deleteForEveryone,
      messageDeleted: messageDeleted ?? this.messageDeleted,
      editHistory: editHistory ?? this.editHistory,
      currentVersion: currentVersion ?? this.currentVersion,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      scheduleMessage: scheduleMessage ?? this.scheduleMessage,
      sendNow: sendNow ?? this.sendNow,
      inOneHour: inOneHour ?? this.inOneHour,
      tonight: tonight ?? this.tonight,
      tomorrowMorning: tomorrowMorning ?? this.tomorrowMorning,
      pickDateTime: pickDateTime ?? this.pickDateTime,
      readOnly: readOnly ?? this.readOnly,
      slowModeWait: slowModeWait ?? this.slowModeWait,
      report: report ?? this.report,
      block: block ?? this.block,
      save: save ?? this.save,
      unsave: unsave ?? this.unsave,
      saved: saved ?? this.saved,
      statusQueued: statusQueued ?? this.statusQueued,
      offline: offline ?? this.offline,
      connecting: connecting ?? this.connecting,
      attach: attach ?? this.attach,
      removeAttachment: removeAttachment ?? this.removeAttachment,
      addCaption: addCaption ?? this.addCaption,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      strikethrough: strikethrough ?? this.strikethrough,
      code: code ?? this.code,
      link: link ?? this.link,
      thinking: thinking ?? this.thinking,
      reasoning: reasoning ?? this.reasoning,
      sources: sources ?? this.sources,
      previousVersion: previousVersion ?? this.previousVersion,
      nextVersion: nextVersion ?? this.nextVersion,
      video: video ?? this.video,
      playVideo: playVideo ?? this.playVideo,
      transcribe: transcribe ?? this.transcribe,
      transcribing: transcribing ?? this.transcribing,
      checklist: checklist ?? this.checklist,
      view: view ?? this.view,
      paymentRequest: paymentRequest ?? this.paymentRequest,
      paymentSent: paymentSent ?? this.paymentSent,
      pay: pay ?? this.pay,
      decline: decline ?? this.decline,
      paymentPending: paymentPending ?? this.paymentPending,
      paymentPaid: paymentPaid ?? this.paymentPaid,
      paymentDeclined: paymentDeclined ?? this.paymentDeclined,
      paymentCancelled: paymentCancelled ?? this.paymentCancelled,
      voiceCall: voiceCall ?? this.voiceCall,
      videoCall: videoCall ?? this.videoCall,
      missedCall: missedCall ?? this.missedCall,
      declinedCall: declinedCall ?? this.declinedCall,
      callBack: callBack ?? this.callBack,
      roleOwner: roleOwner ?? this.roleOwner,
      roleAdmin: roleAdmin ?? this.roleAdmin,
      roleModerator: roleModerator ?? this.roleModerator,
      sendMessage: sendMessage ?? this.sendMessage,
      membersTitle: membersTitle ?? this.membersTitle,
      media: media ?? this.media,
      files: files ?? this.files,
      links: links ?? this.links,
      galleryEmpty: galleryEmpty ?? this.galleryEmpty,
      jumpToDate: jumpToDate ?? this.jumpToDate,
      moreActions: moreActions ?? this.moreActions,
      thoughtFor: thoughtFor ?? this.thoughtFor,
      checklistProgress: checklistProgress ?? this.checklistProgress,
      unreadMentions: unreadMentions ?? this.unreadMentions,
    );
  }
}
