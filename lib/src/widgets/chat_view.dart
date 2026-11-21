import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show FontFeature, ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../chat_scope.dart';
import '../controller/chat_controller.dart';
import '../controller/chat_search_controller.dart';
import '../emoji/chat_emoji_picker.dart';
import '../l10n/chat_localizations.dart';
import '../markdown/chat_link_policy.dart';
import '../markdown/chat_text.dart';
import '../markdown/markdown_parser.dart';
import '../material.dart';
import '../models/chat_message.dart';
import '../models/chat_reaction.dart';
import '../models/chat_user.dart';
import '../models/message_status.dart';
import '../models/voice_playback.dart';
import '../theme/chat_bubble_border.dart';
import '../theme/chat_theme.dart';
import '../utils/emoji.dart';
import 'chat_avatar.dart';
import 'chat_builders.dart';
import 'chat_header.dart';
import 'chat_input.dart';
import 'chat_people.dart';
import 'message_status_icon.dart';
import 'typing_indicator.dart';

part 'chat_view/ai_and_moderation.dart';
part 'chat_view/composer_banner.dart';
part 'chat_view/content_cards.dart';
part 'chat_view/conversation_chrome.dart';
part 'chat_view/conversation_extras.dart';
part 'chat_view/decorations.dart';
part 'chat_view/message_menu.dart';
part 'chat_view/message_row.dart';
part 'chat_view/power_content.dart';
part 'chat_view/rich_content.dart';
part 'chat_view/survey.dart';
part 'chat_view/swipe_to_action.dart';

/// A complete conversation screen: message list plus input bar.
///
/// ```dart
/// final controller = ChatController();
///
/// ChatView(
///   controller: controller,
///   currentUser: me,
///   onSendMessage: (text, replyTo) {
///     controller.insert(TextMessage(
///       id: uuid(),
///       author: me,
///       createdAt: DateTime.now(),
///       text: text,
///       replyToId: replyTo?.id,
///       status: MessageStatus.sending,
///     ));
///     // Send the message to your backend here.
///   },
/// )
/// ```
///
/// [ChatView] does not include a `Scaffold`. Place it in one (or any
/// widget that gives it bounded height) so the input bar moves above the
/// keyboard.
///
/// Every visual piece can be replaced with a builder, and colors, shapes and
/// text styles come from [ChatTheme].
class ChatView extends StatefulWidget {
  /// Creates a conversation view.
  const ChatView({
    super.key,
    required this.controller,
    required this.currentUser,
    required this.onSendMessage,
    this.onEditMessage,
    this.onDeleteMessage,
    this.onReactionSelected,
    this.reactionEmojis = defaultReactionEmojis,
    this.onLoadMore,
    this.loadMoreThreshold = 400,
    this.onMessageTap,
    this.onMessageLongPress,
    this.messageActionsBuilder,
    this.messageMenuStyle = ChatMessageMenuStyle.bottomSheet,
    this.messageMenuTrigger = ChatMessageMenuTrigger.longPress,
    this.swipeAction = const ChatSwipeAction.reply(),
    this.onRetry,
    this.onLinkTap,
    this.linkPolicy = const ChatLinkPolicy(),
    this.onAvatarTap,
    this.onTypingChanged,
    this.firstUnreadMessageId,
    this.theme,
    this.localizations,
    this.scrollController,
    this.showAvatars = true,
    this.showUserNames = true,
    this.showDateSeparators = true,
    this.enableMarkdown = true,
    this.enableJumboEmoji = true,
    this.groupingInterval = const Duration(minutes: 5),
    this.inputEnabled = true,
    this.bubbleBuilder,
    this.customMessageBuilder,
    this.systemMessageBuilder,
    this.avatarBuilder,
    this.inputBuilder,
    this.dateSeparatorBuilder,
    this.typingIndicatorBuilder,
    this.scrollToBottomBuilder,
    this.loadMoreIndicatorBuilder,
    this.emptyStateBuilder,
    this.imageProviderBuilder,
    this.onImageTap,
    this.onFileTap,
    this.voicePlayback,
    this.onVoicePlay,
    this.onVoicePause,
    this.onVoiceSeek,
    this.onVoiceRecordStart,
    this.onVoiceRecordEnd,
    this.onPollVote,
    this.mentionableUsers = const [],
    this.onMentionTap,
    this.onPinMessage,
    this.searchController,
    this.enableSelection = true,
    this.selectionActionsBuilder,
    this.showFloatingDate = true,
    this.onSurveySubmit,
    this.onMessageButton,
    this.onQuickReply,
    this.onThreadTap,
    this.threadRoot,
    this.onForwardMessages,
    this.showReadReceipts = true,
    this.enableEmojiPicker = true,
    this.onRegenerate,
    this.onFeedback,
    this.onStopGenerating,
    this.onTranslate,
    this.locationMapBuilder,
    this.onLocationTap,
    this.onRsvp,
    this.onContactAction,
    this.stickerPacks = const [],
    this.onSendSticker,
    this.onDeleteForEveryone,
    this.onScheduleMessage,
    this.onSendScheduledNow,
    this.readOnly = false,
    this.readOnlyMessage,
    this.slowMode,
    this.onReportMessage,
    this.onBlockUser,
    this.onSaveMessage,
    this.wordFilter,
    this.onReasoningTap,
    this.onSourceTap,
    this.onVideoTap,
    this.onTranscribe,
    this.onChecklistToggle,
    this.onProductTap,
    this.onPaymentAction,
    this.onCallBack,
    this.onAttach,
    this.onSendAttachments,
    this.connectionState = ChatConnectionState.online,
    this.onSendQueued,
    this.suggestedPrompts = const [],
    this.showHoverActions = true,
  });

  /// Reactions offered in the message menu by default.
  static const List<String> defaultReactionEmojis = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
  ];

  /// Source of messages, typing state, replies and edits.
  final ChatController controller;

  /// The user of this device. Their messages are shown as outgoing.
  final ChatUser currentUser;

  /// Called with the trimmed text when the user sends a message, and the
  /// message being replied to, if any.
  ///
  /// chatx does not add the message to [controller] for you. Insert it
  /// yourself (usually with [MessageStatus.sending] and
  /// `replyToId: replyTo?.id`) for an optimistic UI. The reply banner closes
  /// automatically.
  final ChatSendCallback onSendMessage;

  /// Called when the user saves an edited message. When set, the menu offers
  /// "Edit" on the current user's text messages.
  ///
  /// Update the message with [ChatController.editText] and your backend.
  final ChatEditCallback? onEditMessage;

  /// Called when the user chooses "Delete". When set, the menu offers it on
  /// the current user's messages.
  final ValueChanged<ChatMessage>? onDeleteMessage;

  /// Called when the user picks a reaction in the menu or taps a reaction
  /// chip. When set, the menu shows [reactionEmojis] and chips are tappable.
  ///
  /// Typically calls [ChatController.toggleReaction] and your backend.
  final ChatReactionCallback? onReactionSelected;

  /// Quick reactions shown in the message menu.
  final List<String> reactionEmojis;

  /// Loads older messages when the user scrolls near the top.
  ///
  /// Insert the loaded messages with [ChatController.insertAll] and return
  /// whether even older messages exist. If the future throws, a retry button
  /// is shown and the error is reported to [FlutterError.onError].
  final Future<bool> Function()? onLoadMore;

  /// Distance from the top, in logical pixels, at which [onLoadMore] runs.
  final double loadMoreThreshold;

  /// Called when a message bubble is tapped, unless [messageMenuTrigger] is
  /// [ChatMessageMenuTrigger.tap].
  final ValueChanged<ChatMessage>? onMessageTap;

  /// Called on long press. When set, replaces the built-in menu for long
  /// presses.
  final ValueChanged<ChatMessage>? onMessageLongPress;

  /// Customizes the menu entries. See [ChatMessageActionsBuilder].
  final ChatMessageActionsBuilder? messageActionsBuilder;

  /// Whether the menu is a bottom sheet or a popup anchored to the bubble.
  final ChatMessageMenuStyle messageMenuStyle;

  /// Whether a tap or a long press opens the menu.
  final ChatMessageMenuTrigger messageMenuTrigger;

  /// What happens when the user swipes a bubble sideways. Defaults to
  /// swipe-to-reply. Set to `null` to disable swiping.
  final ChatSwipeAction? swipeAction;

  /// Called when the user taps "retry" on a message with
  /// [MessageStatus.failed]. When `null`, no retry button is shown.
  final ValueChanged<ChatMessage>? onRetry;

  /// Called when the user taps a link allowed by [linkPolicy].
  ///
  /// chatx has no dependencies, so it does not open links itself. Use, for
  /// example, the `url_launcher` package here. When `null`, links are styled
  /// but not tappable.
  final ValueChanged<Uri>? onLinkTap;

  /// Which links are tappable. Defaults to `http`, `https` and `mailto`.
  final ChatLinkPolicy linkPolicy;

  /// Called when the avatar of another user is tapped, for example to open
  /// `ChatUserProfile.show`.
  final ValueChanged<ChatUser>? onAvatarTap;

  /// Reports whether the current user is typing. Forward it to your backend
  /// to show a typing indicator to other participants.
  final ValueChanged<bool>? onTypingChanged;

  /// ID of the oldest message the user has not read. Shows a "New messages"
  /// separator above it and scrolls there when the view opens.
  final String? firstUnreadMessageId;

  /// Visual overrides for this view. Merged on top of the [ChatTheme]
  /// extension of the ambient [ThemeData].
  final ChatTheme? theme;

  /// Strings. Defaults to the built-in strings for the ambient locale.
  final ChatLocalizations? localizations;

  /// Controller of the message list. The list is reversed, so offset `0` is
  /// the newest message.
  final ScrollController? scrollController;

  /// Whether to show avatars next to messages of other users.
  final bool showAvatars;

  /// Whether to show author names above groups of other users' messages.
  final bool showUserNames;

  /// Whether to show day labels between messages of different days.
  final bool showDateSeparators;

  /// Whether to render markdown in [TextMessage]s. Links are always detected.
  final bool enableMarkdown;

  /// Whether messages with only one to three emoji are shown large, without
  /// a bubble.
  final bool enableJumboEmoji;

  /// Consecutive messages of one author closer than this are grouped.
  final Duration groupingInterval;

  /// Whether the default input bar accepts text.
  final bool inputEnabled;

  /// Wraps or replaces message bubbles.
  final ChatBubbleBuilder? bubbleBuilder;

  /// Renders [CustomMessage]s inside a bubble.
  final ChatCustomMessageBuilder? customMessageBuilder;

  /// Renders [SystemMessage]s.
  final ChatSystemMessageBuilder? systemMessageBuilder;

  /// Replaces avatars.
  final ChatAvatarBuilder? avatarBuilder;

  /// Replaces the input bar. See [ChatInput].
  final ChatInputBuilder? inputBuilder;

  /// Replaces day labels.
  final ChatDateSeparatorBuilder? dateSeparatorBuilder;

  /// Replaces the typing indicator.
  final ChatTypingIndicatorBuilder? typingIndicatorBuilder;

  /// Replaces the scroll-to-bottom button.
  final ChatScrollToBottomBuilder? scrollToBottomBuilder;

  /// Replaces the progress indicator shown while [onLoadMore] runs.
  final WidgetBuilder? loadMoreIndicatorBuilder;

  /// Shown when there are no messages.
  final WidgetBuilder? emptyStateBuilder;

  /// Turns an image URI ([ChatImage.uri], [ChatLinkPreview.imageUri]) into
  /// an [ImageProvider]. Defaults to [NetworkImage]. Use it for assets,
  /// files, caching or authenticated requests.
  final ImageProvider Function(String uri)? imageProviderBuilder;

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

  /// Called when the user votes in a [PollMessage]. Typically calls
  /// [ChatController.votePoll] and your backend. When `null`, polls are
  /// read-only.
  final ChatPollVoteCallback? onPollVote;

  /// Users that can be mentioned. Typing `@` in the input suggests them, and
  /// `@Name` in messages is highlighted.
  final List<ChatUser> mentionableUsers;

  /// Called when the user taps a mention in a message.
  final ValueChanged<ChatUser>? onMentionTap;

  /// Called when the user picks "Pin" or "Unpin" in the menu. When set, the
  /// menu offers those entries. Update [ChatController.pin] and your backend.
  final ChatPinCallback? onPinMessage;

  /// Highlights search matches and follows the current result. See
  /// [ChatSearchController] and `ChatSearchBar`.
  final ChatSearchController? searchController;

  /// Whether the menu offers "Select" to enter multi-selection mode.
  final bool enableSelection;

  /// Customizes the buttons of the selection bar.
  final ChatSelectionActionsBuilder? selectionActionsBuilder;

  /// Whether a date chip floats at the top while scrolling.
  final bool showFloatingDate;

  /// Called with the answers when the user completes a [SurveyMessage].
  /// When `null`, surveys cannot be answered.
  final void Function(SurveyMessage survey, ChatSurveyResponse response)?
      onSurveySubmit;

  /// Called when the user taps a [ChatMessageButton] of a [TextMessage].
  final void Function(ChatMessage message, ChatMessageButton button)?
      onMessageButton;

  /// Called when the user taps a quick reply. When `null`, the reply text is
  /// sent through [onSendMessage].
  final void Function(ChatQuickReply reply, ChatMessage message)? onQuickReply;

  /// Called when the user taps the thread summary of a message. Open a
  /// screen with another [ChatView] and [threadRoot] set.
  final ValueChanged<ChatMessage>? onThreadTap;

  /// When this view shows a thread, the message that started it. It is
  /// shown at the top, followed by the reply count.
  final ChatMessage? threadRoot;

  /// Called when the user forwards messages from the menu or the selection
  /// bar. Let the user pick a destination here. When set, "Forward" is
  /// offered.
  final ValueChanged<List<ChatMessage>>? onForwardMessages;

  /// Whether to show "Seen by" avatars under the newest outgoing message
  /// and the "Info" menu entry. Uses [ChatMessage.receipts].
  final bool showReadReceipts;

  /// Whether the input has an emoji button and reactions offer the full
  /// emoji picker.
  final bool enableEmojiPicker;

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

  /// Draws the map of a [LocationMessage], for example with your maps SDK.
  final Widget Function(BuildContext context, LocationMessage message)?
      locationMapBuilder;

  /// Called when a location card is tapped, for example to open a maps app.
  final ValueChanged<LocationMessage>? onLocationTap;

  /// Called when the user answers an [EventMessage].
  final ChatRsvpCallback? onRsvp;

  /// Called when the user taps a button of a [ContactMessage].
  final void Function(ContactMessage message, ChatContactAction action)?
      onContactAction;

  /// Sticker packs shown as tabs in the emoji picker. Requires
  /// [onSendSticker].
  final List<ChatStickerPack> stickerPacks;

  /// Called when the user picks a sticker. Insert a [StickerMessage].
  final ValueChanged<ChatSticker>? onSendSticker;

  /// Called when the user deletes their message for everyone. Offered in
  /// the menu when set; usually calls [ChatController.markDeleted].
  final ValueChanged<ChatMessage>? onDeleteForEveryone;

  /// Called when the user schedules a message by long-pressing send.
  final ChatScheduleCallback? onScheduleMessage;

  /// Called when the user chooses "Send now" on a scheduled message.
  final ValueChanged<ChatMessage>? onSendScheduledNow;

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

  /// Called when the user saves or unsaves a message. Usually calls
  /// [ChatController.toggleSaved].
  final void Function(ChatMessage message, bool saved)? onSaveMessage;

  /// Masks offensive words in messages.
  final ChatWordFilter? wordFilter;

  /// Called when the user expands or collapses a reasoning block. Optional;
  /// the block works without it.
  final ValueChanged<TextMessage>? onReasoningTap;

  /// Called when the user taps a source chip. Defaults to [onLinkTap] with
  /// the source URL.
  final ValueChanged<ChatSource>? onSourceTap;

  /// Called when the user taps a [VideoMessage]. Play the video here.
  final ValueChanged<VideoMessage>? onVideoTap;

  /// Called when the user asks for the transcript of a voice note. Produce
  /// it and update the message with `VoiceMessage.transcript`. While the
  /// future runs, the bubble shows "Transcribing…".
  final Future<void> Function(VoiceMessage message)? onTranscribe;

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

  /// When set, the input shows an attach button that calls this. Open your
  /// file picker and add the files with `ChatController.addAttachments`.
  final VoidCallback? onAttach;

  /// Called when the user sends the files waiting in the input. Required to
  /// show the attachment tray.
  final ChatAttachmentsCallback? onSendAttachments;

  /// Network state. Anything but [ChatConnectionState.online] shows a banner
  /// at the top of the list.
  final ChatConnectionState connectionState;

  /// Called with the messages whose status is `MessageStatus.queued` when
  /// [connectionState] changes back to online. Send them here.
  final ValueChanged<List<ChatMessage>>? onSendQueued;

  /// Cards shown in the empty conversation. Tapping one sends its text.
  final List<ChatPrompt> suggestedPrompts;

  /// Whether a mouse hovering a message shows Reply, React and More
  /// buttons next to it.
  final bool showHoverActions;

  @override
  State<ChatView> createState() => _ChatViewState();
}

/// Controllers whose queued messages were handed out during this frame.
final Expando<bool> _flushingQueued = Expando('chatx queued flush');

class _ChatViewState extends State<ChatView> {
  static const double _scrollButtonOffset = 240;

  ScrollController? _ownScrollController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'chatx input');
  final ValueNotifier<bool> _showScrollButton = ValueNotifier(false);
  final ValueNotifier<int> _unreadCount = ValueNotifier(0);
  final ValueNotifier<String?> _highlightedId = ValueNotifier(null);
  Timer? _highlightTimer;

  /// Contexts of the message rows currently built, used to jump to them.
  final Map<String, BuildContext> _rowContexts = {};

  // The list is split at an anchor message. Messages up to the anchor live
  // in the center sliver and grow upward; messages that arrive later live
  // in a sliver below it and grow downward, so they never push the content
  // the user is reading.
  String? _anchorId;
  final Key _centerKey = UniqueKey();
  List<_Entry> _entries = const [];
  Map<Key, int> _indexByKey = const {};
  List<_Entry> _newerEntries = const [_TypingEntry()];
  Map<Key, int> _newerIndexByKey = const {};
  bool _atBottom = true;
  // State of the last full rebuild, to take the cheap path when messages
  // were only appended.
  int _builtRevision = -1;
  int _builtAnchorIndex = -1;
  ChatController? _builtFor;
  final Set<String> _knownIds = {};
  final Set<String> _animatedIds = {};
  String? _newestId;
  ChatMessage? _editingMessage;
  String _draftBeforeEdit = '';
  String? _lastOutgoingId;

  bool _loadingMore = false;
  bool _hasMore = true;
  bool _loadFailed = false;

  StreamSubscription<ChatScrollRequest>? _scrollRequests;
  final ValueNotifier<DateTime?> _floatingDate = ValueNotifier(null);
  Timer? _floatingDateTimer;
  bool _userScrolling = false;
  final GlobalKey _listKey = GlobalKey();
  final ValueNotifier<_MentionQuery?> _mentionQuery = ValueNotifier(null);
  final ValueNotifier<Map<String, _Translation>> _translations =
      ValueNotifier(const {});
  Duration? _slowRemaining;
  Timer? _slowTimer;
  final ValueNotifier<Map<String, int>> _versionIndex = ValueNotifier(const {});
  final ValueNotifier<List<String>> _pendingMentions = ValueNotifier(const []);

  ScrollController get _scrollController =>
      widget.scrollController ?? (_ownScrollController ??= ScrollController());

  ChatLocalizations get _l10n =>
      widget.localizations ??
      ChatLocalizations.forLocale(Localizations.maybeLocaleOf(context));

  @override
  void initState() {
    super.initState();
    _textController.text = widget.controller.draft.value;
    _textController.addListener(_onComposerTextChanged);
    _textController.addListener(_saveDraft);
    _attachController(widget.controller);
    _scrollController.addListener(_onScroll);
    _resetKnownMessages();
    _rebuildEntries();
    _scheduleLoadMoreCheck();
    final unread = widget.firstUnreadMessageId;
    if (unread != null) {
      final messages = widget.controller.messages;
      final start = messages.indexWhere((m) => m.id == unread);
      if (start != -1) {
        _pendingMentions.value = [
          for (final m in messages.skip(start))
            if (_mentionsMe(m)) m.id,
        ];
      }
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToMessage(unread, highlight: false, alignment: 0.8),
      );
    }
  }

  @override
  void didUpdateWidget(ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController(oldWidget.controller);
      _attachController(widget.controller);
      _anchorId = null;
      _resetKnownMessages();
      _hasMore = true;
      _loadFailed = false;
    }
    if (oldWidget.scrollController != widget.scrollController) {
      (oldWidget.scrollController ?? _ownScrollController)
          ?.removeListener(_onScroll);
      _scrollController.addListener(_onScroll);
    }
    if (oldWidget.connectionState != ChatConnectionState.online &&
        widget.connectionState == ChatConnectionState.online) {
      _flushQueued();
    }
    _builtRevision = -1; // Settings may have changed: rebuild everything.
    _rebuildEntries();
  }

  @override
  void dispose() {
    _detachController(widget.controller);
    _scrollController.removeListener(_onScroll);
    _ownScrollController?.dispose();
    _textController
      ..removeListener(_saveDraft)
      ..dispose();
    _focusNode.dispose();
    _showScrollButton.dispose();
    _unreadCount.dispose();
    _highlightedId.dispose();
    _highlightTimer?.cancel();
    _floatingDate.dispose();
    _floatingDateTimer?.cancel();
    _mentionQuery.dispose();
    _translations.dispose();
    _versionIndex.dispose();
    _pendingMentions.dispose();
    _slowTimer?.cancel();
    super.dispose();
  }

  // Hands the queued messages to onSendQueued once per reconnection, even
  // when several views (a chat and its thread) share the controller.
  void _flushQueued() {
    final onSendQueued = widget.onSendQueued;
    final controller = widget.controller;
    if (onSendQueued == null || _flushingQueued[controller] != null) return;
    final queued = controller.queuedMessages;
    if (queued.isEmpty) return;
    _flushingQueued[controller] = true;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _flushingQueued[controller] = null,
    );
    onSendQueued(queued);
  }

  void _attachController(ChatController controller) {
    controller
      ..addListener(_onMessagesChanged)
      ..editing.addListener(_onEditingChanged)
      ..replyingTo.addListener(_onReplyingChanged)
      ..selectedIds.addListener(_onSelectionChanged)
      ..draft.addListener(_onDraftChanged);
    _scrollRequests = controller.scrollRequests.listen(
      (request) => _scrollToMessage(
        request.messageId,
        highlight: request.highlight,
      ),
    );
  }

  void _detachController(ChatController controller) {
    controller
      ..removeListener(_onMessagesChanged)
      ..editing.removeListener(_onEditingChanged)
      ..replyingTo.removeListener(_onReplyingChanged)
      ..selectedIds.removeListener(_onSelectionChanged)
      ..draft.removeListener(_onDraftChanged);
    _scrollRequests?.cancel();
    _scrollRequests = null;
  }

  void _onSelectionChanged() => setState(() {});

  void _onEditingChanged() {
    final editing = widget.controller.editing.value;
    final previous = _editingMessage;
    _editingMessage = editing;
    if (editing is TextMessage) {
      if (previous == null) _draftBeforeEdit = _textController.text;
      _textController.value = TextEditingValue(
        text: editing.text,
        selection: TextSelection.collapsed(offset: editing.text.length),
      );
      _focusNode.requestFocus();
    } else if (previous != null) {
      // Leaving edit mode brings back what the user was typing before.
      _textController.text = _draftBeforeEdit;
    }
    setState(() {});
  }

  void _saveDraft() {
    if (_editingMessage != null) return;
    final text = _textController.text;
    if (widget.controller.draft.value != text) {
      widget.controller.setDraft(text);
    }
  }

  // Shows a draft set from outside, for example cleared by
  // `setMessages(newConversation: true)`.
  void _onDraftChanged() {
    if (_editingMessage != null) return;
    final draft = widget.controller.draft.value;
    if (_textController.text != draft) _textController.text = draft;
  }

  void _onReplyingChanged() {
    if (widget.controller.replyingTo.value != null) _focusNode.requestFocus();
  }

  void _resetKnownMessages() {
    final messages = widget.controller.messages;
    _knownIds
      ..clear()
      ..addAll(messages.map((m) => m.id));
    _newestId = messages.isEmpty ? null : messages.last.id;
  }

  /// Distance from the newest message, in pixels.
  double get _distanceFromBottom {
    if (!_scrollController.hasClients) return 0;
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return 0;
    return position.pixels - position.minScrollExtent;
  }

  bool get _isAwayFromBottom => _distanceFromBottom > _scrollButtonOffset;

  void _onMessagesChanged() {
    final messages = widget.controller.messages;
    final hadMessages = _knownIds.isNotEmpty;

    // New messages at the bottom, newest first.
    final arrived = <ChatMessage>[];
    for (var i = messages.length - 1; i >= 0; i--) {
      final message = messages[i];
      if (message.id == _newestId || _knownIds.contains(message.id)) break;
      arrived.add(message);
    }

    if (arrived.isNotEmpty && (hadMessages || arrived.length == 1)) {
      if (arrived.length <= 3) {
        _animatedIds.addAll(arrived.map((m) => m.id));
      }
      if (arrived.any(_isOutgoing)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else if (_isAwayFromBottom) {
        _unreadCount.value += arrived.where((m) => m is! SystemMessage).length;
        final mentions = [
          for (final m in arrived.reversed)
            if (_mentionsMe(m)) m.id,
        ];
        if (mentions.isNotEmpty) {
          _pendingMentions.value = [..._pendingMentions.value, ...mentions];
        }
      }
    }

    _knownIds.addAll(arrived.map((m) => m.id));
    _newestId = messages.isEmpty ? null : messages.last.id;
    setState(_rebuildEntries);
    _scheduleLoadMoreCheck();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final distance = _distanceFromBottom;
    _showScrollButton.value = distance > _scrollButtonOffset;
    if (distance < 40) _unreadCount.value = 0;
    // Only the user's own scrolling marks mentions as seen, not jumps.
    if (_userScrolling) _markVisibleMentions();
    _atBottom = distance <= 4;
  }

  // Keeps the newest message in view while the user is at the bottom, as
  // new messages or the typing indicator extend the list downward.
  bool _onMetricsChanged(ScrollMetricsNotification notification) {
    if (notification.depth != 0 || !_atBottom) return false;
    final position = _scrollController.position;
    if (position.pixels != position.minScrollExtent) {
      position.jumpTo(position.minScrollExtent);
    }
    return false;
  }

  bool _isOutgoing(ChatMessage message) =>
      message is! SystemMessage && message.author.id == widget.currentUser.id;

  void _rebuildEntries() {
    final messages = widget.controller.messages;
    if (_canAppendOnly(messages)) {
      _rebuildNewer(messages, _builtAnchorIndex);
      return;
    }
    _lastOutgoingId = null;
    for (var i = messages.length - 1; i >= 0; i--) {
      if (_isOutgoing(messages[i])) {
        _lastOutgoingId = messages[i].id;
        break;
      }
    }

    var anchorIndex = -1;
    if (_anchorId != null) {
      for (var i = messages.length - 1; i >= 0; i--) {
        if (messages[i].id == _anchorId) {
          anchorIndex = i;
          break;
        }
      }
    }
    if (anchorIndex == -1) {
      anchorIndex = messages.length - 1;
      _anchorId = messages.isEmpty ? null : messages.last.id;
    }

    _MessageEntry entryAt(int i) {
      final message = messages[i];
      final older = i > 0 ? messages[i - 1] : null;
      final newer = i < messages.length - 1 ? messages[i + 1] : null;
      return _MessageEntry(
        message.id,
        isFirstInGroup: older == null || !_sameGroup(older, message),
        isLastInGroup: newer == null || !_sameGroup(message, newer),
      );
    }

    bool startsDay(int i) =>
        widget.showDateSeparators &&
        (i == 0 ||
            !DateUtils.isSameDay(
              messages[i - 1].createdAt.toLocal(),
              messages[i].createdAt.toLocal(),
            ));

    // Center sliver, bottom to top: newest anchored message first.
    final entries = <_Entry>[];
    for (var i = anchorIndex; i >= 0; i--) {
      entries.add(entryAt(i));
      if (messages[i].id == widget.firstUnreadMessageId) {
        entries.add(const _UnreadEntry());
      }
      if (startsDay(i)) {
        entries.add(
          _DateEntry(DateUtils.dateOnly(messages[i].createdAt.toLocal())),
        );
      }
    }
    if (widget.threadRoot != null) entries.add(const _ThreadRootEntry());
    if (widget.onLoadMore != null) entries.add(const _LoaderEntry());

    // Sliver below the anchor, top to bottom: oldest new message first.
    final newer = <_Entry>[];
    for (var i = anchorIndex + 1; i < messages.length; i++) {
      if (startsDay(i)) {
        newer.add(
          _DateEntry(DateUtils.dateOnly(messages[i].createdAt.toLocal())),
        );
      }
      if (messages[i].id == widget.firstUnreadMessageId) {
        newer.add(const _UnreadEntry());
      }
      newer.add(entryAt(i));
    }
    newer.add(const _TypingEntry());

    _entries = entries;
    _indexByKey = {
      for (var i = 0; i < entries.length; i++) entries[i].key: i,
    };
    _newerEntries = newer;
    _newerIndexByKey = {
      for (var i = 0; i < newer.length; i++) newer[i].key: i,
    };
    _builtRevision = widget.controller.structureRevision;
    _builtAnchorIndex = anchorIndex;
    _builtFor = widget.controller;
  }

  /// Whether only messages after the anchor changed since the last full
  /// rebuild, so the history part of the list can be kept as is.
  bool _canAppendOnly(List<ChatMessage> messages) =>
      identical(_builtFor, widget.controller) &&
      _builtRevision == widget.controller.structureRevision &&
      _builtAnchorIndex >= 0 &&
      _builtAnchorIndex < messages.length &&
      messages[_builtAnchorIndex].id == _anchorId;

  /// Rebuilds the entries below the anchor and refreshes the anchor itself,
  /// whose grouping depends on the message after it. O(new messages).
  void _rebuildNewer(List<ChatMessage> messages, int anchorIndex) {
    final last = messages.last;
    if (_isOutgoing(last)) _lastOutgoingId = last.id;

    _MessageEntry entryAt(int i) {
      final message = messages[i];
      final older = i > 0 ? messages[i - 1] : null;
      final newer = i < messages.length - 1 ? messages[i + 1] : null;
      return _MessageEntry(
        message.id,
        isFirstInGroup: older == null || !_sameGroup(older, message),
        isLastInGroup: newer == null || !_sameGroup(message, newer),
      );
    }

    final entries = List<_Entry>.of(_entries);
    entries[0] = entryAt(anchorIndex);
    _entries = entries;

    final newer = <_Entry>[];
    for (var i = anchorIndex + 1; i < messages.length; i++) {
      if (widget.showDateSeparators &&
          !DateUtils.isSameDay(
            messages[i - 1].createdAt.toLocal(),
            messages[i].createdAt.toLocal(),
          )) {
        newer.add(
          _DateEntry(DateUtils.dateOnly(messages[i].createdAt.toLocal())),
        );
      }
      if (messages[i].id == widget.firstUnreadMessageId) {
        newer.add(const _UnreadEntry());
      }
      newer.add(entryAt(i));
    }
    newer.add(const _TypingEntry());
    _newerEntries = newer;
    _newerIndexByKey = {
      for (var i = 0; i < newer.length; i++) newer[i].key: i,
    };
  }

  bool _sameGroup(ChatMessage older, ChatMessage newer) {
    if (older is SystemMessage || newer is SystemMessage) return false;
    if (older.author.id != newer.author.id) return false;
    if (newer.id == widget.firstUnreadMessageId) return false;
    final a = older.createdAt.toLocal();
    final b = newer.createdAt.toLocal();
    return DateUtils.isSameDay(a, b) &&
        b.difference(a).abs() <= widget.groupingInterval;
  }

  void _scheduleLoadMoreCheck() {
    if (widget.onLoadMore == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.hasContentDimensions &&
          position.extentAfter < widget.loadMoreThreshold) {
        _loadMore();
      }
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is ScrollStartNotification) {
        _userScrolling = notification.dragDetails != null;
      }
      if (widget.showFloatingDate) _updateFloatingDate(notification);
      if (notification is ScrollEndNotification) {
        if (_userScrolling) _markVisibleMentions();
        _userScrolling = false;
      }
    }
    if (notification.depth == 0 &&
        notification.metrics.extentAfter < widget.loadMoreThreshold) {
      _loadMore();
    }
    return false;
  }

  Future<void> _loadMore() async {
    final onLoadMore = widget.onLoadMore;
    if (onLoadMore == null || _loadingMore || !_hasMore || _loadFailed) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final hasMore = await onLoadMore();
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        _hasMore = hasMore;
      });
      if (hasMore) _scheduleLoadMoreCheck();
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'chatx',
          context: ErrorDescription('while loading older messages'),
        ),
      );
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        _loadFailed = true;
      });
    }
  }

  void _retryLoadMore() {
    setState(() => _loadFailed = false);
    unawaited(_loadMore());
  }

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;
    _unreadCount.value = 0;
    final distance = _distanceFromBottom;
    if (distance <= 0) return;
    final bottom = _scrollController.position.minScrollExtent;
    if (MediaQuery.disableAnimationsOf(context) || distance > 4000) {
      _scrollController.jumpTo(bottom);
    } else {
      _scrollController.animateTo(
        bottom,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Scrolls until the message with [id] is visible, then optionally flashes
  /// it. Works for messages that are not built yet by estimating their
  /// position first.
  Future<void> _scrollToMessage(
    String id, {
    bool highlight = true,
    double alignment = 0.5,
  }) async {
    final key = ValueKey<String>(id);
    final index = _indexByKey[key];
    final isNewer = _newerIndexByKey.containsKey(key);
    if ((index == null && !isNewer) || !_scrollController.hasClients) return;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    for (var attempt = 0; attempt < 10 && mounted; attempt++) {
      final rowContext = _rowContexts[id];
      if (rowContext != null && rowContext.mounted) {
        await Scrollable.ensureVisible(
          rowContext,
          alignment: alignment,
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
        if (highlight && mounted) _flash(id);
        return;
      }
      final position = _scrollController.position;
      if (isNewer) {
        // Messages below the anchor are close to the bottom.
        _scrollController.jumpTo(position.minScrollExtent);
      } else {
        final averageExtent =
            (position.maxScrollExtent + position.viewportDimension) /
                math.max(1, _entries.length);
        final target = (index! * averageExtent - position.viewportDimension / 2)
            .clamp(position.minScrollExtent, position.maxScrollExtent);
        _scrollController.jumpTo(target);
      }
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  void _flash(String id) {
    _highlightTimer?.cancel();
    _highlightedId.value = id;
    _highlightTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) _highlightedId.value = null;
    });
  }

  void _handleSend(String text) {
    final controller = widget.controller;
    final editing = controller.editing.value;
    if (editing is TextMessage) {
      widget.onEditMessage?.call(editing, text);
      controller.cancelEditing();
      return;
    }
    // Slow mode also applies to quick replies and prompts.
    if (_slowRemaining != null) return;
    final replyTo = controller.replyingTo.value;
    final attachments = controller.attachments.value;
    final onSendAttachments = widget.onSendAttachments;
    if (attachments.isNotEmpty && onSendAttachments != null) {
      onSendAttachments(attachments, text, replyTo);
      controller.clearAttachments();
    } else if (text.isNotEmpty) {
      widget.onSendMessage(text, replyTo);
    } else {
      return;
    }
    controller.cancelReply();
    _startSlowMode();
    _scrollToBottom();
  }

  void _startSlowMode() {
    final slowMode = widget.slowMode;
    if (slowMode == null || slowMode <= Duration.zero) return;
    _slowTimer?.cancel();
    setState(() => _slowRemaining = slowMode);
    _slowTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      final left = _slowRemaining! - const Duration(seconds: 1);
      if (left <= Duration.zero) timer.cancel();
      setState(() => _slowRemaining = left <= Duration.zero ? null : left);
    });
  }

  /// Whether [message] mentions the current user with `@Name`.
  bool _mentionsMe(ChatMessage message) {
    final name = widget.currentUser.name;
    if (name == null ||
        name.isEmpty ||
        _isOutgoing(message) ||
        message is! TextMessage) {
      return false;
    }
    return RegExp(
      '(^|[^\\w])@${RegExp.escape(name)}(?![\\w])',
      caseSensitive: false,
    ).hasMatch(message.text);
  }

  /// Removes the mentions whose rows are on screen: the user saw them.
  void _markVisibleMentions() {
    final pending = _pendingMentions.value;
    if (pending.isEmpty) return;
    final list = _listKey.currentContext?.findRenderObject();
    if (list is! RenderBox || !list.hasSize) return;
    final viewport = list.localToGlobal(Offset.zero) & list.size;
    final unseen = [
      for (final id in pending)
        if (!_isOnScreen(id, viewport)) id,
    ];
    if (unseen.length != pending.length) _pendingMentions.value = unseen;
  }

  bool _isOnScreen(String id, Rect viewport) {
    final rowContext = _rowContexts[id];
    if (rowContext == null || !rowContext.mounted) return false;
    final box = rowContext.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return false;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    return rect.overlaps(viewport);
  }

  void _jumpToMention() {
    final pending = _pendingMentions.value;
    if (pending.isEmpty) return;
    HapticFeedback.selectionClick();
    _scrollToMessage(pending.first);
    _pendingMentions.value = pending.sublist(1);
  }

  Future<void> _pickDateAndJump() async {
    final messages = widget.controller.messages;
    if (messages.isEmpty) return;
    final first = DateUtils.dateOnly(messages.first.createdAt.toLocal());
    final last = DateUtils.dateOnly(messages.last.createdAt.toLocal());
    final date = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: _floatingDate.value ?? last,
      helpText: _l10n.jumpToDate,
    );
    if (date == null || !mounted) return;
    widget.controller.scrollToDate(date);
  }

  void _sendPrompt(ChatPrompt prompt) {
    HapticFeedback.selectionClick();
    widget.onSendMessage(prompt.message, null);
    _scrollToBottom();
  }

  /// Edits the newest text message of the current user (up arrow).
  void _editLastMessage() {
    if (widget.onEditMessage == null) return;
    final messages = widget.controller.messages;
    for (var i = messages.length - 1; i >= 0; i--) {
      final message = messages[i];
      if (_isOutgoing(message) &&
          message is TextMessage &&
          message.deletedAt == null) {
        widget.controller.startEditing(message);
        return;
      }
    }
  }

  void _onEscape() {
    final controller = widget.controller;
    if (controller.editing.value != null) {
      controller.cancelEditing();
    } else if (controller.replyingTo.value != null) {
      controller.cancelReply();
    } else {
      controller.clearAttachments();
    }
  }

  void _onContentInserted(KeyboardInsertedContent content) {
    final data = content.data;
    if (data == null || widget.onSendAttachments == null) return;
    final name = Uri.tryParse(content.uri)?.pathSegments.lastOrNull ?? 'image';
    widget.controller.addAttachments([
      ChatAttachment(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        kind: content.mimeType.startsWith('image/')
            ? ChatAttachmentKind.image
            : ChatAttachmentKind.file,
        bytes: data,
        sizeBytes: data.length,
        mimeType: content.mimeType,
      ),
    ]);
  }

  Future<void> _schedule(String text) async {
    final onSchedule = widget.onScheduleMessage;
    if (onSchedule == null) return;
    final at = await _pickScheduleTime(context);
    if (at == null || !mounted) return;
    onSchedule(text, at, widget.controller.replyingTo.value);
    widget.controller.cancelReply();
    _textController.clear();
  }

  void _startReply(ChatMessage message) {
    widget.controller.startReply(message);
  }

  void _onSwipe(ChatMessage message) {
    final action = widget.swipeAction;
    if (action == null) return;
    final onTriggered = action.onTriggered;
    if (onTriggered != null) {
      onTriggered(message);
    } else {
      _startReply(message);
    }
  }

  List<ChatMessageAction> _defaultActions(ChatMessage message) {
    final l10n = _l10n;
    final mine = _isOutgoing(message);
    final streaming = message is TextMessage && message.isStreaming;
    if (message.deletedAt != null) return const [];
    if (message.scheduledFor != null) {
      return [
        if (widget.onSendScheduledNow != null)
          ChatMessageAction(
            label: l10n.sendNow,
            icon: Icons.send_rounded,
            onSelected: widget.onSendScheduledNow!,
          ),
        if (message is TextMessage && widget.onEditMessage != null)
          ChatMessageAction(
            label: l10n.edit,
            icon: Icons.edit_outlined,
            onSelected: (m) => widget.controller.startEditing(m as TextMessage),
          ),
        if (widget.onDeleteMessage != null)
          ChatMessageAction(
            label: l10n.delete,
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onSelected: widget.onDeleteMessage!,
          ),
      ];
    }
    final saved = widget.controller.isSaved(message.id);
    return [
      if (!streaming)
        ChatMessageAction(
          label: l10n.reply,
          icon: Icons.reply_rounded,
          onSelected: _startReply,
        ),
      if (message is TextMessage)
        ChatMessageAction.copyText(label: l10n.copy, icon: Icons.copy_rounded),
      if (message is TextMessage && !streaming && widget.onTranslate != null)
        ChatMessageAction(
          label: l10n.translate,
          icon: Icons.translate_rounded,
          onSelected: (m) => _translate(m as TextMessage),
        ),
      if (mine &&
          !streaming &&
          message is TextMessage &&
          widget.onEditMessage != null)
        ChatMessageAction(
          label: l10n.edit,
          icon: Icons.edit_outlined,
          onSelected: (m) => widget.controller.startEditing(m as TextMessage),
        ),
      if (widget.onPinMessage != null)
        widget.controller.isPinned(message.id)
            ? ChatMessageAction(
                label: l10n.unpin,
                icon: Icons.push_pin_rounded,
                onSelected: (m) => widget.onPinMessage!(m, false),
              )
            : ChatMessageAction(
                label: l10n.pin,
                icon: Icons.push_pin_outlined,
                onSelected: (m) => widget.onPinMessage!(m, true),
              ),
      if (widget.onForwardMessages != null && !streaming)
        ChatMessageAction(
          label: l10n.forward,
          icon: Icons.shortcut_rounded,
          onSelected: (m) => widget.onForwardMessages!([m]),
        ),
      if (mine && widget.showReadReceipts && message.receipts.isNotEmpty)
        ChatMessageAction(
          label: l10n.messageInfo,
          icon: Icons.info_outline_rounded,
          onSelected: (m) => _showMessageInfo(context, m, l10n),
        ),
      if (widget.onSaveMessage != null)
        ChatMessageAction(
          label: saved ? l10n.unsave : l10n.save,
          icon: saved
              ? Icons.bookmark_remove_outlined
              : Icons.bookmark_add_outlined,
          onSelected: (m) => widget.onSaveMessage!(m, !saved),
        ),
      if (widget.enableSelection)
        ChatMessageAction(
          label: l10n.select,
          icon: Icons.check_circle_outline_rounded,
          onSelected: (m) => widget.controller.toggleSelection(m.id),
        ),
      if (!mine && widget.onReportMessage != null)
        ChatMessageAction(
          label: l10n.report,
          icon: Icons.flag_outlined,
          isDestructive: true,
          onSelected: widget.onReportMessage!,
        ),
      if (!mine && widget.onBlockUser != null)
        ChatMessageAction(
          label: l10n.block(message.author.name ?? l10n.someone),
          icon: Icons.block_rounded,
          isDestructive: true,
          onSelected: (m) => widget.onBlockUser!(m.author),
        ),
      if (mine && widget.onDeleteMessage != null)
        ChatMessageAction(
          label: l10n.delete,
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onSelected: widget.onDeleteMessage!,
        ),
      if (mine && widget.onDeleteForEveryone != null)
        ChatMessageAction(
          label: l10n.deleteForEveryone,
          icon: Icons.delete_forever_outlined,
          isDestructive: true,
          onSelected: widget.onDeleteForEveryone!,
        ),
    ];
  }

  Future<void> _handleLongPress(ChatMessage message, BuildContext anchor) {
    if (widget.controller.isSelecting) {
      _toggleSelection(message);
      return Future.value();
    }
    final onLongPress = widget.onMessageLongPress;
    if (onLongPress != null) {
      unawaited(HapticFeedback.mediumImpact());
      onLongPress(message);
      return Future.value();
    }
    if (widget.messageMenuTrigger != ChatMessageMenuTrigger.longPress) {
      return Future.value();
    }
    return _openMenu(message, anchor);
  }

  void _toggleSelection(ChatMessage message) {
    if (message is SystemMessage) return;
    HapticFeedback.selectionClick();
    widget.controller.toggleSelection(message.id);
  }

  void _handleTap(ChatMessage message, BuildContext anchor) {
    if (widget.controller.isSelecting) {
      _toggleSelection(message);
      return;
    }
    if (message is FileMessage && widget.onFileTap != null) {
      widget.onFileTap!(message);
      return;
    }
    if (message is LocationMessage && widget.onLocationTap != null) {
      widget.onLocationTap!(message);
      return;
    }
    if (widget.messageMenuTrigger == ChatMessageMenuTrigger.tap) {
      unawaited(_openMenu(message, anchor));
    } else {
      widget.onMessageTap?.call(message);
    }
  }

  Future<void> _openMenu(ChatMessage message, BuildContext anchor) async {
    if (message is SystemMessage) return;
    final defaults = _defaultActions(message);
    final actions =
        widget.messageActionsBuilder?.call(context, message, defaults) ??
            defaults;
    final streaming = message is TextMessage && message.isStreaming;
    final emojis = widget.onReactionSelected == null || streaming
        ? const <String>[]
        : widget.reactionEmojis;
    if (actions.isEmpty && emojis.isEmpty) return;

    unawaited(HapticFeedback.mediumImpact());
    final l10n = _l10n;
    final Future<Object?> menu = switch (widget.messageMenuStyle) {
      ChatMessageMenuStyle.bottomSheet => _showSheetMenu(
          context,
          actions: actions,
          emojis: emojis,
          message: message,
          currentUserId: widget.currentUser.id,
          l10n: l10n,
          showMore: widget.enableEmojiPicker,
        ),
      ChatMessageMenuStyle.popup => _showPopupMenu(
          anchor,
          actions: actions,
          emojis: emojis,
          message: message,
          currentUserId: widget.currentUser.id,
          l10n: l10n,
          showMore: widget.enableEmojiPicker,
        ),
    };
    final selection = await menu;
    if (!mounted) return;
    switch (selection) {
      case _ReactionChoice(:final emoji):
        widget.onReactionSelected?.call(message, emoji);
      case ChatMessageAction(:final onSelected):
        onSelected(message);
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final material = Theme.of(context);
    final theme = ChatThemeData.fallback(material)
        .merge(material.extension<ChatTheme>())
        .merge(widget.theme);
    final l10n = _l10n;
    final editing = _editingMessage != null;

    final messages = widget.controller.messages;
    final newest = messages.isEmpty ? null : messages.last;
    final slowLeft = _slowRemaining;
    final slowed = slowLeft != null;

    Widget buildInput(ChatMessage? latest) {
      final generating = latest is TextMessage &&
          latest.isStreaming &&
          !_isOutgoing(latest) &&
          widget.onStopGenerating != null;
      final hasAttachments = widget.onSendAttachments != null &&
          widget.controller.attachments.value.isNotEmpty;
      return widget.inputBuilder?.call(context, _handleSend, _textController) ??
          ChatInput(
            onSend: _handleSend,
            controller: _textController,
            focusNode: _focusNode,
            enabled: widget.inputEnabled && !slowed,
            hintText: slowed
                ? l10n.slowModeWait(
                    _formatDuration(slowLeft),
                  )
                : hasAttachments
                    ? l10n.addCaption
                    : null,
            allowEmptySend: hasAttachments && !editing,
            leading: widget.onAttach == null || editing
                ? null
                : IconButton(
                    key: const Key('chatx_attach_button'),
                    tooltip: l10n.attach,
                    icon: const Icon(Icons.attach_file_rounded),
                    onPressed:
                        widget.inputEnabled && !slowed ? widget.onAttach : null,
                  ),
            onArrowUp: widget.onEditMessage == null ? null : _editLastMessage,
            onEscape: _onEscape,
            onContentInserted:
                widget.onSendAttachments == null ? null : _onContentInserted,
            onTypingChanged: widget.onTypingChanged,
            sendIcon:
                editing ? Icons.check_rounded : Icons.arrow_upward_rounded,
            onRecordStart: editing ? null : widget.onVoiceRecordStart,
            onRecordEnd: widget.onVoiceRecordEnd,
            showEmojiButton: widget.enableEmojiPicker,
            onStop: generating ? () => widget.onStopGenerating!(latest) : null,
            onSchedule:
                widget.onScheduleMessage == null || editing ? null : _schedule,
            stickerPacks: widget.stickerPacks,
            onSticker: widget.onSendSticker,
            imageProviderBuilder: widget.imageProviderBuilder,
          );
    }

    final Widget input;
    if (widget.readOnly) {
      input = Padding(
        key: const Key('chatx_read_only'),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 18, color: theme.typingIndicatorColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.readOnlyMessage ?? l10n.readOnly,
                textAlign: TextAlign.center,
                style: theme.systemMessageTextStyle,
              ),
            ),
          ],
        ),
      );
    } else {
      // Rebuilt when attachments change, to switch the send button and
      // the placeholder.
      input = ValueListenableBuilder<List<ChatAttachment>>(
        valueListenable: widget.controller.attachments,
        builder: (context, _, __) => newest == null
            ? buildInput(null)
            : ValueListenableBuilder<ChatMessage>(
                valueListenable: widget.controller.watch(newest.id),
                builder: (context, latest, _) => buildInput(latest),
              ),
      );
    }
    final selecting = widget.controller.isSelecting;

    return ChatScope(
      theme: theme,
      localizations: l10n,
      // A Material ancestor for text fields and ink effects, also when the
      // app is built on `material_ui` (see README).
      child: Material(
        color: theme.backgroundColor,
        child: Column(
          children: [
            _ConnectionBanner(connection: widget.connectionState),
            _PinnedBanner(state: this),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _buildList(theme)),
                  if (widget.showFloatingDate)
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: _FloatingDate(
                        date: _floatingDate,
                        onTap: _pickDateAndJump,
                      ),
                    ),
                  if (widget.controller.isEmpty && !_loadingMore)
                    Positioned.fill(
                      child: widget.emptyStateBuilder != null
                          ? IgnorePointer(
                              child: Builder(
                                builder: widget.emptyStateBuilder!,
                              ),
                            )
                          : widget.suggestedPrompts.isNotEmpty &&
                                  !widget.readOnly
                              ? _PromptSuggestions(
                                  state: this,
                                  title: l10n.emptyState,
                                )
                              : IgnorePointer(
                                  child: _EmptyState(text: l10n.emptyState),
                                ),
                    ),
                  PositionedDirectional(
                    end: 12,
                    bottom: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MentionsButton(state: this),
                        const SizedBox(height: 8),
                        _buildScrollButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: theme.inputBackgroundColor,
              child: SafeArea(
                top: false,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: selecting
                      ? _SelectionBar(key: const Key('selection'), state: this)
                      : Column(
                          key: const Key('composer'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QuickReplies(state: this),
                            _MentionSuggestions(state: this),
                            _ComposerBanner(
                              controller: widget.controller,
                              currentUser: widget.currentUser,
                            ),
                            _AttachmentTray(state: this),
                            input,
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ChatThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 12.0;
        final available = constraints.maxWidth - horizontalPadding * 2;
        final maxBubbleWidth = math.max(
          0.0,
          math.min(
            theme.maxBubbleWidth,
            available * theme.maxBubbleWidthFactor,
          ),
        );
        Widget item(BuildContext context, _Entry entry) => KeyedSubtree(
              key: entry.key,
              child: _buildEntry(context, entry, theme, maxBubbleWidth),
            );
        return NotificationListener<ScrollMetricsNotification>(
          onNotification: _onMetricsChanged,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: CustomScrollView(
              key: _listKey,
              controller: _scrollController,
              reverse: true,
              center: _centerKey,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                // Laid out downward from the anchor: newer messages.
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => item(context, _newerEntries[index]),
                      childCount: _newerEntries.length,
                      findChildIndexCallback: (key) => _newerIndexByKey[key],
                    ),
                  ),
                ),
                // The anchor: history grows upward from here.
                SliverPadding(
                  key: _centerKey,
                  padding: const EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => item(context, _entries[index]),
                      childCount: _entries.length,
                      findChildIndexCallback: (key) => _indexByKey[key],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEntry(
    BuildContext context,
    _Entry entry,
    ChatThemeData theme,
    double maxBubbleWidth,
  ) {
    switch (entry) {
      case _TypingEntry():
        return _TypingSlot(
          typingUsers: widget.controller.typingUsers,
          currentUser: widget.currentUser,
          indent: widget.showAvatars ? theme.avatarSize + 8 : 0,
          builder: widget.typingIndicatorBuilder,
        );
      case _DateEntry(:final day):
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: widget.dateSeparatorBuilder?.call(context, day) ??
                _DateChip(day: day, onTap: _pickDateAndJump),
          ),
        );
      case _UnreadEntry():
        return const _UnreadSeparator();
      case _LoaderEntry():
        return _buildLoader(context);
      case _ThreadRootEntry():
        final root = widget.threadRoot!;
        final l10n = ChatLocalizations.of(context);
        return Column(
          key: const Key('chatx_thread_header'),
          children: [
            _MessageRow(
              state: this,
              listenable: _ConstListenable<ChatMessage>(root),
              isFirstInGroup: true,
              isLastInGroup: true,
              maxBubbleWidth: maxBubbleWidth,
              animate: false,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n.threadReplies(widget.controller.length),
                      style: theme.dateSeparatorTextStyle,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
          ],
        );
      case _MessageEntry(
          :final id,
          :final isFirstInGroup,
          :final isLastInGroup
        ):
        return _MessageRow(
          state: this,
          listenable: widget.controller.watch(id),
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
          maxBubbleWidth: maxBubbleWidth,
          animate: _animatedIds.remove(id),
        );
    }
  }

  Widget _buildLoader(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    if (_loadFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: TextButton.icon(
            key: const Key('chatx_load_more_retry'),
            onPressed: _retryLoadMore,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('${l10n.loadMoreFailed} ${l10n.retry}'),
          ),
        ),
      );
    }
    if (!_loadingMore) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: widget.loadMoreIndicatorBuilder?.call(context) ??
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
      ),
    );
  }

  Widget _buildScrollButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showScrollButton,
      builder: (context, show, _) {
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        return IgnorePointer(
          ignoring: !show,
          child: AnimatedScale(
            scale: show ? 1 : 0,
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 260),
            curve: show ? Curves.easeOutBack : Curves.easeInCubic,
            child: ExcludeSemantics(
              excluding: !show,
              child: ValueListenableBuilder<int>(
                valueListenable: _unreadCount,
                builder: (context, unread, _) =>
                    widget.scrollToBottomBuilder
                        ?.call(context, unread, _scrollToBottom) ??
                    _ScrollToBottomButton(
                      unreadCount: unread,
                      onPressed: _scrollToBottom,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// List entries, in reversed order: index 0 is the bottom of the screen.

sealed class _Entry {
  const _Entry();
  Key get key;
}

enum _Slot { typing, loader, unread, threadRoot }

final class _TypingEntry extends _Entry {
  const _TypingEntry();
  @override
  Key get key => const ValueKey<_Slot>(_Slot.typing);
}

final class _LoaderEntry extends _Entry {
  const _LoaderEntry();
  @override
  Key get key => const ValueKey<_Slot>(_Slot.loader);
}

final class _ThreadRootEntry extends _Entry {
  const _ThreadRootEntry();
  @override
  Key get key => const ValueKey<_Slot>(_Slot.threadRoot);
}

final class _UnreadEntry extends _Entry {
  const _UnreadEntry();
  @override
  Key get key => const ValueKey<_Slot>(_Slot.unread);
}

final class _DateEntry extends _Entry {
  const _DateEntry(this.day);
  final DateTime day;
  @override
  Key get key => ValueKey<DateTime>(day);
}

final class _MessageEntry extends _Entry {
  const _MessageEntry(
    this.id, {
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });
  final String id;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  @override
  Key get key => ValueKey<String>(id);
}
