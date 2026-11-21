import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../chat_scope.dart';
import '../controller/chat_controller.dart';
import '../l10n/chat_localizations.dart';
import '../markdown/chat_link_policy.dart';
import '../markdown/chat_text.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import '../models/message_status.dart';
import '../theme/chat_theme.dart';
import 'chat_avatar.dart';
import 'chat_builders.dart';
import 'chat_input.dart';
import 'message_status_icon.dart';
import 'typing_indicator.dart';

/// A complete conversation screen: message list plus input bar.
///
/// ```dart
/// final controller = ChatController();
///
/// ChatView(
///   controller: controller,
///   currentUser: const ChatUser(id: 'me'),
///   onSendMessage: (text) {
///     controller.insert(TextMessage(
///       id: uuid(),
///       author: const ChatUser(id: 'me'),
///       createdAt: DateTime.now(),
///       text: text,
///       status: MessageStatus.sending,
///     ));
///     // Send `text` to your backend here.
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
    this.onLoadMore,
    this.loadMoreThreshold = 400,
    this.onMessageTap,
    this.onMessageLongPress,
    this.messageActionsBuilder,
    this.onRetry,
    this.onLinkTap,
    this.linkPolicy = const ChatLinkPolicy(),
    this.onAvatarTap,
    this.onTypingChanged,
    this.theme,
    this.localizations,
    this.scrollController,
    this.showAvatars = true,
    this.showUserNames = true,
    this.showDateSeparators = true,
    this.enableMarkdown = true,
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
  });

  /// Source of messages and typing state.
  final ChatController controller;

  /// The user of this device. Their messages are shown as outgoing.
  final ChatUser currentUser;

  /// Called with the trimmed text when the user sends a message.
  ///
  /// chatx does not add the message to [controller] for you. Insert it
  /// yourself (usually with [MessageStatus.sending]) for an optimistic UI.
  final ValueChanged<String> onSendMessage;

  /// Loads older messages when the user scrolls near the top.
  ///
  /// Insert the loaded messages with [ChatController.insertAll] and return
  /// whether even older messages exist. If the future throws, a retry button
  /// is shown and the error is reported to [FlutterError.onError].
  final Future<bool> Function()? onLoadMore;

  /// Distance from the top, in logical pixels, at which [onLoadMore] runs.
  final double loadMoreThreshold;

  /// Called when a message bubble is tapped.
  final ValueChanged<ChatMessage>? onMessageTap;

  /// Called when a message bubble is long-pressed. When set, replaces the
  /// built-in actions menu.
  final ValueChanged<ChatMessage>? onMessageLongPress;

  /// Entries of the built-in long-press menu. Defaults to "copy text" for
  /// [TextMessage]s. See [ChatMessageAction.copyText].
  final ChatMessageActionsBuilder? messageActionsBuilder;

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

  /// Called when the avatar of another user is tapped.
  final ValueChanged<ChatUser>? onAvatarTap;

  /// Reports whether the current user is typing. Forward it to your backend
  /// to show a typing indicator to other participants.
  final ValueChanged<bool>? onTypingChanged;

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

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  static const double _scrollButtonOffset = 240;

  ScrollController? _ownScrollController;
  final ValueNotifier<bool> _showScrollButton = ValueNotifier(false);
  final ValueNotifier<int> _unreadCount = ValueNotifier(0);

  List<_Entry> _entries = const [];
  Map<Key, int> _indexByKey = const {};
  final Set<String> _knownIds = {};
  final Set<String> _animatedIds = {};
  String? _newestId;

  bool _loadingMore = false;
  bool _hasMore = true;
  bool _loadFailed = false;

  ScrollController get _scrollController =>
      widget.scrollController ?? (_ownScrollController ??= ScrollController());

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onMessagesChanged);
    _scrollController.addListener(_onScroll);
    _resetKnownMessages();
    _rebuildEntries();
    _scheduleLoadMoreCheck();
  }

  @override
  void didUpdateWidget(ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onMessagesChanged);
      widget.controller.addListener(_onMessagesChanged);
      _resetKnownMessages();
      _hasMore = true;
      _loadFailed = false;
    }
    if (oldWidget.scrollController != widget.scrollController) {
      (oldWidget.scrollController ?? _ownScrollController)
          ?.removeListener(_onScroll);
      _scrollController.addListener(_onScroll);
    }
    _rebuildEntries();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onMessagesChanged);
    _scrollController.removeListener(_onScroll);
    _ownScrollController?.dispose();
    _showScrollButton.dispose();
    _unreadCount.dispose();
    super.dispose();
  }

  void _resetKnownMessages() {
    final messages = widget.controller.messages;
    _knownIds
      ..clear()
      ..addAll(messages.map((m) => m.id));
    _newestId = messages.isEmpty ? null : messages.last.id;
  }

  bool get _isAwayFromBottom =>
      _scrollController.hasClients &&
      _scrollController.offset > _scrollButtonOffset;

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
      final sentByMe = arrived.any((m) => _isOutgoing(m));
      if (sentByMe) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else if (_isAwayFromBottom) {
        _unreadCount.value += arrived.where((m) => m is! SystemMessage).length;
      }
    }

    _resetKnownMessages();
    setState(_rebuildEntries);
    _scheduleLoadMoreCheck();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    _showScrollButton.value = offset > _scrollButtonOffset;
    if (offset < 40) _unreadCount.value = 0;
  }

  bool _isOutgoing(ChatMessage message) =>
      message is! SystemMessage && message.author.id == widget.currentUser.id;

  void _rebuildEntries() {
    final messages = widget.controller.messages;
    final entries = <_Entry>[const _TypingEntry()];
    for (var i = messages.length - 1; i >= 0; i--) {
      final message = messages[i];
      final older = i > 0 ? messages[i - 1] : null;
      final newer = i < messages.length - 1 ? messages[i + 1] : null;
      entries.add(
        _MessageEntry(
          message.id,
          isFirstInGroup: older == null || !_sameGroup(older, message),
          isLastInGroup: newer == null || !_sameGroup(message, newer),
        ),
      );
      if (widget.showDateSeparators &&
          (older == null ||
              !DateUtils.isSameDay(
                older.createdAt.toLocal(),
                message.createdAt.toLocal(),
              ))) {
        entries
            .add(_DateEntry(DateUtils.dateOnly(message.createdAt.toLocal())));
      }
    }
    if (widget.onLoadMore != null) entries.add(const _LoaderEntry());
    _entries = entries;
    _indexByKey = {
      for (var i = 0; i < entries.length; i++) entries[i].key: i,
    };
  }

  bool _sameGroup(ChatMessage older, ChatMessage newer) {
    if (older is SystemMessage || newer is SystemMessage) return false;
    if (older.author.id != newer.author.id) return false;
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
    final distance = _scrollController.offset;
    if (distance <= 0) return;
    if (MediaQuery.disableAnimationsOf(context) || distance > 4000) {
      _scrollController.jumpTo(0);
    } else {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleSend(String text) {
    widget.onSendMessage(text);
    _scrollToBottom();
  }

  Future<void> _handleLongPress(ChatMessage message) async {
    unawaited(HapticFeedback.mediumImpact());
    final onLongPress = widget.onMessageLongPress;
    if (onLongPress != null) {
      onLongPress(message);
      return;
    }
    final l10n = widget.localizations ??
        ChatLocalizations.forLocale(Localizations.maybeLocaleOf(context));
    final actions = widget.messageActionsBuilder?.call(context, message) ??
        [
          if (message is TextMessage)
            ChatMessageAction.copyText(
              label: l10n.copy,
              icon: Icons.copy_rounded,
            ),
        ];
    if (actions.isEmpty) return;

    final selected = await showModalBottomSheet<ChatMessageAction>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final error = Theme.of(sheetContext).colorScheme.error;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final action in actions)
                ListTile(
                  leading: action.icon == null
                      ? null
                      : Icon(
                          action.icon,
                          color: action.isDestructive ? error : null,
                        ),
                  title: Text(
                    action.label,
                    style:
                        action.isDestructive ? TextStyle(color: error) : null,
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(action),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) selected.onSelected(message);
  }

  @override
  Widget build(BuildContext context) {
    final material = Theme.of(context);
    final theme = ChatThemeData.fallback(material)
        .merge(material.extension<ChatTheme>())
        .merge(widget.theme);
    final l10n = widget.localizations ??
        ChatLocalizations.forLocale(Localizations.maybeLocaleOf(context));

    final input = widget.inputBuilder?.call(context, _handleSend) ??
        ChatInput(
          onSend: _handleSend,
          enabled: widget.inputEnabled,
          onTypingChanged: widget.onTypingChanged,
        );

    return ChatScope(
      theme: theme,
      localizations: l10n,
      child: ColoredBox(
        color: theme.backgroundColor,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _buildList(theme)),
                  if (widget.controller.isEmpty && !_loadingMore)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Builder(
                          builder: (context) =>
                              widget.emptyStateBuilder?.call(context) ??
                              _EmptyState(text: l10n.emptyState),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    end: 12,
                    bottom: 12,
                    child: _buildScrollButton(),
                  ),
                ],
              ),
            ),
            ColoredBox(
              color: theme.inputBackgroundColor,
              child: SafeArea(top: false, child: input),
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
        return NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            itemCount: _entries.length,
            findChildIndexCallback: (key) => _indexByKey[key],
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return KeyedSubtree(
                key: entry.key,
                child: _buildEntry(context, entry, theme, maxBubbleWidth),
              );
            },
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
        return ValueListenableBuilder<List<ChatUser>>(
          valueListenable: widget.controller.typingUsers,
          builder: (context, users, _) {
            final others = [
              for (final u in users)
                if (u.id != widget.currentUser.id) u,
            ];
            final indent = widget.showAvatars ? theme.avatarSize + 8 : 0.0;
            return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
              child: others.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: EdgeInsetsDirectional.only(
                        top: 10,
                        start: indent,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: widget.typingIndicatorBuilder
                                ?.call(context, others) ??
                            TypingIndicator(users: others),
                      ),
                    ),
            );
          },
        );
      case _DateEntry(:final day):
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: widget.dateSeparatorBuilder?.call(context, day) ??
                _DateChip(day: day),
          ),
        );
      case _LoaderEntry():
        return _buildLoader(context);
      case _MessageEntry(
          :final id,
          :final isFirstInGroup,
          :final isLastInGroup
        ):
        return _MessageItem(
          view: widget,
          listenable: widget.controller.watch(id),
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
          maxBubbleWidth: maxBubbleWidth,
          animate: _animatedIds.remove(id),
          onLongPress: _handleLongPress,
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

enum _Slot { typing, loader }

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

class _MessageItem extends StatelessWidget {
  const _MessageItem({
    required this.view,
    required this.listenable,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.maxBubbleWidth,
    required this.animate,
    required this.onLongPress,
  });

  final ChatView view;
  final ValueListenable<ChatMessage> listenable;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final double maxBubbleWidth;
  final bool animate;
  final ValueChanged<ChatMessage> onLongPress;

  @override
  Widget build(BuildContext context) {
    final initial = listenable.value;
    final isOutgoing =
        initial is! SystemMessage && initial.author.id == view.currentUser.id;
    return _Entrance(
      animate: animate,
      alignment: isOutgoing
          ? AlignmentDirectional.bottomEnd
          : AlignmentDirectional.bottomStart,
      child: Padding(
        padding: EdgeInsets.only(top: isFirstInGroup ? 10 : 2),
        child: ValueListenableBuilder<ChatMessage>(
          valueListenable: listenable,
          builder: (context, message, _) {
            final details = ChatMessageDetails(
              message: message,
              isOutgoing: isOutgoing,
              isFirstInGroup: isFirstInGroup,
              isLastInGroup: isLastInGroup,
            );
            return _buildRow(context, details);
          },
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, ChatMessageDetails details) {
    final message = details.message;
    final theme = ChatThemeData.of(context);
    if (message is SystemMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: view.systemMessageBuilder?.call(context, message) ??
              Text(
                message.text,
                textAlign: TextAlign.center,
                style: theme.systemMessageTextStyle,
              ),
        ),
      );
    }

    final bubble = _Bubble(
      view: view,
      details: details,
      maxWidth: maxBubbleWidth,
      onLongPress: onLongPress,
    );
    final l10n = ChatLocalizations.of(context);
    final name = message.author.name;
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: details.isOutgoing
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!details.isOutgoing &&
            details.isFirstInGroup &&
            view.showUserNames &&
            name != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, bottom: 3),
            child: ExcludeSemantics(
              child: Text(name, style: theme.userNameTextStyle),
            ),
          ),
        view.bubbleBuilder?.call(context, details, bubble) ?? bubble,
        if (details.isOutgoing && message.status == MessageStatus.failed)
          _FailedLabel(
            message: message,
            onRetry: view.onRetry,
            color: theme.errorColor,
            label: l10n.failedToSend,
            style: theme.timestampTextStyle,
          ),
      ],
    );

    if (details.isOutgoing) {
      return Align(alignment: AlignmentDirectional.centerEnd, child: column);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (view.showAvatars) ...[
          SizedBox(
            width: theme.avatarSize,
            child: details.isLastInGroup
                ? view.avatarBuilder?.call(context, message.author) ??
                    ChatAvatar(
                      user: message.author,
                      onTap: view.onAvatarTap == null
                          ? null
                          : () => view.onAvatarTap!(message.author),
                    )
                : null,
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: column,
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.view,
    required this.details,
    required this.maxWidth,
    required this.onLongPress,
  });

  final ChatView view;
  final ChatMessageDetails details;
  final double maxWidth;
  final ValueChanged<ChatMessage> onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final message = details.message;
    final outgoing = details.isOutgoing;
    final textStyle = theme.bubbleTextStyle(isOutgoing: outgoing);
    final textColor =
        textStyle.color ?? Theme.of(context).colorScheme.onSurface;

    final round = Radius.circular(theme.bubbleRadius);
    final tight = Radius.circular(theme.bubbleGroupedRadius);
    // The corners on the author's side tighten inside a group and at the
    // bottom of the last bubble, which reads as a tail.
    final authorTop = details.isFirstInGroup ? round : tight;
    final radius = outgoing
        ? BorderRadiusDirectional.only(
            topStart: round,
            bottomStart: round,
            topEnd: authorTop,
            bottomEnd: tight,
          )
        : BorderRadiusDirectional.only(
            topStart: authorTop,
            bottomStart: tight,
            topEnd: round,
            bottomEnd: round,
          );

    final footer = _Footer(
      message: message,
      showStatus: outgoing,
      color: textColor.withValues(alpha: 0.72),
      style: theme.timestampTextStyle,
    );

    final Widget body;
    switch (message) {
      case TextMessage():
        body = IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _textContent(message, theme, textStyle, textColor),
              const SizedBox(height: 3),
              Align(alignment: AlignmentDirectional.centerEnd, child: footer),
            ],
          ),
        );
      case CustomMessage():
        body = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            view.customMessageBuilder?.call(context, message, details) ??
                Text(
                  l10n.unsupportedMessage,
                  style: textStyle.copyWith(fontStyle: FontStyle.italic),
                ),
            const SizedBox(height: 3),
            footer,
          ],
        );
      case SystemMessage():
        return const SizedBox.shrink();
    }

    final author = outgoing ? l10n.you : (message.author.name ?? l10n.someone);
    final onTap = view.onMessageTap;
    return Semantics(
      container: true,
      label: '$author,',
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          key: Key('chatx_bubble_${message.id}'),
          color: theme.bubbleColor(isOutgoing: outgoing),
          shape: RoundedRectangleBorder(borderRadius: radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap == null ? null : () => onTap(message),
            onLongPress: () => onLongPress(message),
            child: Padding(
              padding: theme.bubblePadding,
              child: DefaultTextStyle.merge(style: textStyle, child: body),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textContent(
    TextMessage message,
    ChatThemeData theme,
    TextStyle textStyle,
    Color textColor,
  ) {
    if (message.isStreaming && message.text.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TypingDots(color: textColor.withValues(alpha: 0.8)),
        ),
      );
    }
    return ChatText(
      message.text,
      style: textStyle,
      linkStyle: theme.linkStyle,
      codeStyle: theme.codeTextStyle,
      onLinkTap: view.onLinkTap,
      linkPolicy: view.linkPolicy,
      enableMarkdown: view.enableMarkdown,
      trailing: message.isStreaming
          ? WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _StreamingCaret(color: textColor),
            )
          : null,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.message,
    required this.showStatus,
    required this.color,
    required this.style,
  });

  final ChatMessage message;
  final bool showStatus;
  final Color color;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    final l10n = ChatLocalizations.of(context);
    final localizations = MaterialLocalizations.of(context);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(message.createdAt.toLocal()),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final edited = message is TextMessage && message.editedAt != null;
    final status = message.status;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          edited ? '${l10n.edited} · $time' : time,
          style: style.copyWith(color: style.color ?? color),
        ),
        if (showStatus && status != null) ...[
          const SizedBox(width: 4),
          MessageStatusIcon(status: status, color: color),
        ],
      ],
    );
  }
}

class _FailedLabel extends StatelessWidget {
  const _FailedLabel({
    required this.message,
    required this.onRetry,
    required this.color,
    required this.label,
    required this.style,
  });

  final ChatMessage message;
  final ValueChanged<ChatMessage>? onRetry;
  final Color color;
  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    if (retry == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, right: 4),
        child: Text(label, style: style.copyWith(color: color)),
      );
    }
    return TextButton.icon(
      key: Key('chatx_retry_${message.id}'),
      onPressed: () => retry(message),
      icon: const Icon(Icons.refresh_rounded, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: color,
        textStyle: style,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final localizations = MaterialLocalizations.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final String label;
    if (day == today) {
      label = l10n.today;
    } else if (day == yesterday) {
      label = l10n.yesterday;
    } else if (day.year == today.year) {
      label = localizations.formatMediumDate(day);
    } else {
      label = localizations.formatFullDate(day);
    }
    return Semantics(
      header: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.dateSeparatorColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Text(label, style: theme.dateSeparatorTextStyle),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.systemMessageTextStyle,
        ),
      ),
    );
  }
}

class _ScrollToBottomButton extends StatelessWidget {
  const _ScrollToBottomButton({
    required this.unreadCount,
    required this.onPressed,
  });

  final int unreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final label = unreadCount > 0
        ? '${l10n.scrollToBottom}, ${l10n.unreadMessages(unreadCount)}'
        : l10n.scrollToBottom;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            key: const Key('chatx_scroll_to_bottom'),
            color: theme.scrollButtonColor,
            shape: const CircleBorder(),
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: 48,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.scrollButtonIconColor,
                ),
              ),
            ),
          ),
          if (unreadCount > 0)
            PositionedDirectional(
              top: -4,
              end: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 22),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.unreadBadgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.unreadBadgeTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Plays a spring-driven entrance for newly arrived messages.
class _Entrance extends StatefulWidget {
  const _Entrance({
    required this.animate,
    required this.alignment,
    required this.child,
  });

  final bool animate;
  final AlignmentGeometry alignment;
  final Widget child;

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance>
    with SingleTickerProviderStateMixin {
  static final SpringDescription _spring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 420,
    ratio: 0.72,
  );

  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null || !widget.animate) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    _controller = AnimationController.unbounded(vsync: this, value: 0)
      ..animateWith(SpringSimulation(_spring, 0, 1, 0));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return widget.child;
    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (context, child) {
        final t = controller.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: Transform.scale(
              scale: 0.9 + 0.1 * t,
              alignment: widget.alignment.resolve(Directionality.of(context)),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _StreamingCaret extends StatefulWidget {
  const _StreamingCaret({required this.color});

  final Color color;

  @override
  State<_StreamingCaret> createState() => _StreamingCaretState();
}

class _StreamingCaretState extends State<_StreamingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final CurvedAnimation _opacity =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      unawaited(_controller.repeat(reverse: true));
    }
  }

  @override
  void dispose() {
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          width: 7,
          height: 15,
          margin: const EdgeInsetsDirectional.only(start: 3),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
