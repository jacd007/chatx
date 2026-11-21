part of '../chat_view.dart';

/// One message: avatar, name, swipeable bubble, reactions and failure label.
class _MessageRow extends StatefulWidget {
  const _MessageRow({
    required this.state,
    required this.listenable,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.maxBubbleWidth,
    required this.animate,
  });

  final _ChatViewState state;
  final ValueListenable<ChatMessage> listenable;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final double maxBubbleWidth;
  final bool animate;

  @override
  State<_MessageRow> createState() => _MessageRowState();
}

class _MessageRowState extends State<_MessageRow> {
  String? _registeredId;

  @override
  void initState() {
    super.initState();
    _register();
  }

  @override
  void didUpdateWidget(_MessageRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) _register();
  }

  @override
  void dispose() {
    final contexts = widget.state._rowContexts;
    if (identical(contexts[_registeredId], context)) {
      contexts.remove(_registeredId);
    }
    super.dispose();
  }

  void _register() {
    final contexts = widget.state._rowContexts;
    if (_registeredId != null && identical(contexts[_registeredId], context)) {
      contexts.remove(_registeredId);
    }
    _registeredId = widget.listenable.value.id;
    contexts[_registeredId!] = context;
  }

  @override
  Widget build(BuildContext context) {
    final view = widget.state.widget;
    final initial = widget.listenable.value;
    final isOutgoing = widget.state._isOutgoing(initial);
    return _Entrance(
      animate: widget.animate,
      alignment: isOutgoing
          ? AlignmentDirectional.bottomEnd
          : AlignmentDirectional.bottomStart,
      child: Padding(
        padding: EdgeInsets.only(top: widget.isFirstInGroup ? 10 : 2),
        child: ValueListenableBuilder<ChatMessage>(
          valueListenable: widget.listenable,
          builder: (context, message, _) {
            final details = ChatMessageDetails(
              message: message,
              isOutgoing: isOutgoing,
              isFirstInGroup: widget.isFirstInGroup,
              isLastInGroup: widget.isLastInGroup,
            );
            final row = _buildRow(context, details);
            final swipe = view.swipeAction;
            final streaming = message is TextMessage && message.isStreaming;
            return _Highlight(
              id: message.id,
              highlighted: widget.state._highlightedId,
              child: swipe == null || message is SystemMessage || streaming
                  ? row
                  : _SwipeToAction(
                      icon: swipe.icon,
                      label: swipe.label ?? ChatLocalizations.of(context).reply,
                      onTriggered: () => widget.state._onSwipe(message),
                      child: row,
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, ChatMessageDetails details) {
    final view = widget.state.widget;
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

    final l10n = ChatLocalizations.of(context);
    final outgoing = details.isOutgoing;
    final bubble = _Bubble(
      state: widget.state,
      details: details,
      maxWidth: widget.maxBubbleWidth,
    );
    final name = message.author.name;
    final tailInset =
        theme.bubbleTail == ChatBubbleTail.none ? 0.0 : theme.bubbleTailWidth;
    final avatarInset =
        !outgoing && view.showAvatars ? theme.avatarSize + 8 : 0.0;

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          outgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!outgoing &&
            details.isFirstInGroup &&
            view.showUserNames &&
            name != null)
          Padding(
            padding:
                EdgeInsetsDirectional.only(start: 12 + tailInset, bottom: 3),
            child: ExcludeSemantics(
              child: Text(name, style: theme.userNameTextStyle),
            ),
          ),
        view.bubbleBuilder?.call(context, details, bubble) ?? bubble,
      ],
    );

    final Widget row;
    if (outgoing) {
      row = Align(alignment: AlignmentDirectional.centerEnd, child: column);
    } else {
      row = Row(
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

    final hasReactions = message.reactions.isNotEmpty;
    final failed = outgoing && message.status == MessageStatus.failed;
    if (!hasReactions && !failed) return row;

    final sideInset = EdgeInsetsDirectional.only(
      start: outgoing ? 0 : avatarInset + tailInset + 6,
      end: outgoing ? tailInset + 6 : 0,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          outgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        row,
        if (hasReactions)
          Padding(
            padding: sideInset,
            child: _Reactions(
              message: message,
              currentUserId: view.currentUser.id,
              onTap: view.onReactionSelected,
            ),
          ),
        if (failed)
          _FailedLabel(
            message: message,
            onRetry: view.onRetry,
            color: theme.errorColor,
            label: l10n.failedToSend,
            style: theme.timestampTextStyle,
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.state,
    required this.details,
    required this.maxWidth,
  });

  final _ChatViewState state;
  final ChatMessageDetails details;
  final double maxWidth;

  ChatView get view => state.widget;

  bool _isJumbo(ChatMessage message) =>
      view.enableJumboEmoji &&
      message is TextMessage &&
      !message.isStreaming &&
      message.replyToId == null &&
      (EmojiUtils.countIfOnlyEmoji(message.text) ?? 99) <= 3;

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final message = details.message;
    final outgoing = details.isOutgoing;
    final jumbo = _isJumbo(message);
    final bubbleStyle = theme.bubbleTextStyle(isOutgoing: outgoing);
    // Jumbo emoji have no bubble, so text uses the colors of the list.
    final textStyle = jumbo ? theme.incomingTextStyle : bubbleStyle;
    final textColor =
        textStyle.color ?? Theme.of(context).colorScheme.onSurface;

    final round = Radius.circular(theme.bubbleRadius);
    final tight = Radius.circular(theme.bubbleGroupedRadius);
    final tail = jumbo ? ChatBubbleTail.none : theme.bubbleTail;
    // Inside a group, corners on the author's side tighten so consecutive
    // bubbles read as one block.
    final authorTop = details.isFirstInGroup ? round : tight;
    final authorBottom =
        details.isLastInGroup && tail != ChatBubbleTail.none ? round : tight;
    final radius = outgoing
        ? BorderRadiusDirectional.only(
            topStart: round,
            bottomStart: round,
            topEnd: authorTop,
            bottomEnd: authorBottom,
          )
        : BorderRadiusDirectional.only(
            topStart: authorTop,
            bottomStart: authorBottom,
            topEnd: round,
            bottomEnd: round,
          );
    final shape = ChatBubbleBorder(
      side: jumbo
          ? BorderSide.none
          : theme.bubbleBorderSide(isOutgoing: outgoing),
      borderRadius: radius,
      tail: tail,
      showTail: switch (tail) {
        ChatBubbleTail.bottom => details.isLastInGroup,
        ChatBubbleTail.top => details.isFirstInGroup,
        ChatBubbleTail.none => false,
      },
      tailAtEnd: outgoing,
      tailWidth: theme.bubbleTailWidth,
      tailHeight: theme.bubbleTailHeight,
    );

    final footer = _Footer(
      message: message,
      showStatus: outgoing,
      color: textColor.withValues(alpha: 0.72),
      style: theme.timestampTextStyle,
    );

    final replyToId = message.replyToId;
    final quote = replyToId == null
        ? null
        : _ReplyQuote(
            original: view.controller.messageById(replyToId),
            replyToId: replyToId,
            messageId: message.id,
            textColor: textColor,
            accentColor: outgoing
                ? textColor
                : theme.userNameTextStyle.color ?? textColor,
            currentUserId: view.currentUser.id,
            onTap: () => state._scrollToMessage(replyToId),
          );

    final Widget body;
    switch (message) {
      case TextMessage():
        body = IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (quote != null) ...[quote, const SizedBox(height: 6)],
              if (jumbo)
                Text(
                  message.text.trim(),
                  textAlign: TextAlign.center,
                  style: textStyle.copyWith(
                    fontSize: (textStyle.fontSize ?? 16) * 2.6,
                    height: 1.15,
                  ),
                )
              else
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
            if (quote != null) ...[quote, const SizedBox(height: 6)],
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
    final padding = jumbo
        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
        : theme.bubblePadding.add(shape.contentInsets);

    return Semantics(
      container: true,
      label: '$author,',
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Builder(
          builder: (anchor) => Material(
            key: Key('chatx_bubble_${message.id}'),
            color: jumbo
                ? Colors.transparent
                : theme.bubbleColor(isOutgoing: outgoing),
            shape: shape,
            elevation: jumbo ? 0 : theme.bubbleElevation,
            shadowColor: theme.bubbleShadowColor,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: shape,
              onTap: () => state._handleTap(message, anchor),
              onLongPress: () => state._handleLongPress(message, anchor),
              child: Padding(
                padding: padding,
                child: DefaultTextStyle.merge(style: textStyle, child: body),
              ),
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

/// Compact preview of the message being replied to, inside a bubble.
class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({
    required this.original,
    required this.replyToId,
    required this.messageId,
    required this.textColor,
    required this.accentColor,
    required this.currentUserId,
    required this.onTap,
  });

  final ChatMessage? original;
  final String replyToId;
  final String messageId;
  final Color textColor;
  final Color accentColor;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final theme = ChatThemeData.of(context);
    final original = this.original;
    final name = original == null
        ? null
        : original.author.id == currentUserId
            ? l10n.you
            : original.author.name ?? l10n.someone;
    final preview =
        original == null ? l10n.quoteUnavailable : _messagePreview(original);

    return Semantics(
      button: original != null,
      child: Material(
        key: Key('chatx_quote_$messageId'),
        color: textColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: original == null ? null : onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: accentColor),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 10, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (name != null)
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.userNameTextStyle.copyWith(
                              color: accentColor,
                            ),
                          ),
                        Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.systemMessageTextStyle.copyWith(
                            color: textColor.withValues(alpha: 0.8),
                            fontStyle:
                                original == null ? FontStyle.italic : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One-line, markdown-free summary of [message].
String _messagePreview(ChatMessage message) => switch (message) {
      TextMessage(:final text) => MarkdownParser.toPlainText(text),
      SystemMessage(:final text) => text,
      CustomMessage(:final type) => '📎 $type',
    };

/// Reaction chips under a bubble.
class _Reactions extends StatelessWidget {
  const _Reactions({
    required this.message,
    required this.currentUserId,
    required this.onTap,
  });

  final ChatMessage message;
  final String currentUserId;
  final ChatReactionCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final textStyle = Theme.of(context).textTheme.labelMedium;
    final scheme = Theme.of(context).colorScheme;
    // Pull the chips up so they overlap the bubble edge, like a sticker.
    return Transform.translate(
      offset: const Offset(0, -6),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final reaction in message.reactions)
            _ReactionChip(
              key: Key('chatx_reaction_${message.id}_${reaction.emoji}'),
              reaction: reaction,
              selected: reaction.hasUser(currentUserId),
              color: theme.reactionChipColor,
              selectedColor: theme.reactionChipSelectedColor,
              outlineColor: theme.backgroundColor,
              textStyle: textStyle?.copyWith(color: scheme.onSurface),
              semanticLabel: l10n.reactionLabel(
                reaction.emoji,
                reaction.count,
                includesYou: reaction.hasUser(currentUserId),
              ),
              onTap: onTap == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onTap!(message, reaction.emoji);
                    },
            ),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    super.key,
    required this.reaction,
    required this.selected,
    required this.color,
    required this.selectedColor,
    required this.outlineColor,
    required this.textStyle,
    required this.semanticLabel,
    required this.onTap,
  });

  final ChatReaction reaction;
  final bool selected;
  final Color color;
  final Color selectedColor;
  final Color outlineColor;
  final TextStyle? textStyle;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: ShapeDecoration(
        color: selected ? selectedColor : color,
        shape: StadiumBorder(side: BorderSide(color: outlineColor, width: 2)),
      ),
      child: Text(
        reaction.count > 1
            ? '${reaction.emoji} ${reaction.count}'
            : reaction.emoji,
        style: textStyle,
      ),
    );
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: chip,
      ),
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

/// Briefly tints a row after jumping to it from a reply.
class _Highlight extends StatelessWidget {
  const _Highlight({
    required this.id,
    required this.highlighted,
    required this.child,
  });

  final String id;
  final ValueListenable<String?> highlighted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = ChatThemeData.of(context).highlightColor;
    return ValueListenableBuilder<String?>(
      valueListenable: highlighted,
      child: child,
      builder: (context, current, child) => AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: current == id ? color : color.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
