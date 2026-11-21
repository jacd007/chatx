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
  final ValueNotifier<bool> _hovered = ValueNotifier(false);
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
    _hovered.dispose();
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
            final controller = view.controller;
            final selecting = controller.isSelecting;
            Widget content = swipe == null ||
                    message is SystemMessage ||
                    streaming ||
                    selecting ||
                    message.deletedAt != null ||
                    message.scheduledFor != null
                ? row
                : _SwipeToAction(
                    icon: swipe.icon,
                    label: swipe.label ?? ChatLocalizations.of(context).reply,
                    onTriggered: () => widget.state._onSwipe(message),
                    child: row,
                  );
            if (selecting && message is! SystemMessage) {
              content = _SelectionFrame(
                selected: controller.selectedIds.value.contains(message.id),
                onTap: () => widget.state._toggleSelection(message),
                child: content,
              );
            }
            if (message.scheduledFor != null) {
              content = Opacity(opacity: 0.7, child: content);
            }
            return _Highlight(
              id: message.id,
              highlighted: widget.state._highlightedId,
              child: content,
            );
          },
        ),
      ),
    );
  }

  /// Adds Reply, React and More buttons beside the bubble while a mouse
  /// hovers the row. Touch devices never trigger it.
  Widget _withHoverActions(Widget bubble, ChatMessage message, bool outgoing) {
    final view = widget.state.widget;
    if (!view.showHoverActions ||
        message.deletedAt != null ||
        view.controller.isSelecting) {
      return bubble;
    }
    return MouseRegion(
      onEnter: (_) => _hovered.value = true,
      onExit: (_) => _hovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _hovered,
        builder: (context, hovered, child) {
          if (!hovered) return child!;
          final actions = _HoverActions(state: widget.state, message: message);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: outgoing
                ? [actions, Flexible(child: child!)]
                : [Flexible(child: child!), actions],
          );
        },
        child: bubble,
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
          child: view.builders.systemMessageBuilder?.call(context, message) ??
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(name, style: theme.userNameTextStyle)),
                  if (message.author.role case final role?) ...[
                    const SizedBox(width: 6),
                    ChatRoleBadge(role: role),
                  ],
                ],
              ),
            ),
          ),
        _withHoverActions(
          view.builders.bubbleBuilder?.call(context, details, bubble) ?? bubble,
          message,
          outgoing,
        ),
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
                  ? view.builders.avatarBuilder
                          ?.call(context, message.author) ??
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

    final deleted = message.deletedAt != null;
    final hasReactions = !deleted && message.reactions.isNotEmpty;
    final aiActions = !deleted &&
        message is TextMessage &&
        message.author.isBot &&
        !message.isStreaming &&
        (view.ai.onFeedback != null ||
            view.ai.onRegenerate != null ||
            message.versions.isNotEmpty);
    final failed = outgoing && message.status == MessageStatus.failed;
    // The root of an open thread does not link to itself.
    final thread = message.id == view.threadRoot?.id ? null : message.thread;
    final seenBy = outgoing &&
        view.showReadReceipts &&
        message.receipts.isNotEmpty &&
        message.id == widget.state._lastOutgoingId;
    if (!hasReactions && !failed && thread == null && !seenBy && !aiActions) {
      return row;
    }

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
        if (aiActions)
          Padding(
            padding: sideInset,
            child: _AiActions(
              state: widget.state,
              message: message,
              canRegenerate: message.id == view.controller.messages.last.id,
            ),
          ),
        if (thread != null && thread.replyCount > 0)
          Padding(
            padding: sideInset,
            child: _ThreadSummaryRow(
              message: message,
              summary: thread,
              onTap: view.onThreadTap,
            ),
          ),
        if (seenBy)
          Padding(
            padding: sideInset,
            child: _SeenBy(receipts: message.receipts),
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
      message is StickerMessage && message.deletedAt == null ||
      view.enableJumboEmoji &&
          message.deletedAt == null &&
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
      saved: view.controller.savedIds,
    );

    final replyToId = message.replyToId;
    Widget replyQuote(ChatMessage? original) => _ReplyQuote(
          original: original,
          replyToId: replyToId!,
          messageId: message.id,
          textColor: textColor,
          accentColor:
              outgoing ? textColor : theme.userNameTextStyle.color ?? textColor,
          currentUserId: view.currentUser.id,
          onTap: () => state._scrollToMessage(replyToId),
        );
    // Watch the original so the quote follows its edits and deletion.
    final quote = replyToId == null
        ? null
        : view.controller.contains(replyToId)
            ? ValueListenableBuilder<ChatMessage>(
                valueListenable: view.controller.watch(replyToId),
                builder: (context, original, _) => replyQuote(original),
              )
            : replyQuote(null);

    final accent =
        outgoing ? textColor : theme.userNameTextStyle.color ?? textColor;
    final direction = Directionality.of(context);
    final basePadding = jumbo
        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
        : theme.bubblePadding.resolve(direction);
    final tailPadding = shape.contentInsets.resolve(direction);
    // Width available to the content of fixed-width messages.
    final innerWidth =
        maxWidth - basePadding.horizontal - tailPadding.horizontal;

    Widget withQuote(List<Widget> children, {bool stretch = false}) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.end,
        children: [
          if (message.forwardedFrom != null)
            _ForwardedLabel(name: message.forwardedFrom!, color: textColor),
          if (quote != null) ...[quote, const SizedBox(height: 6)],
          ...children,
        ],
      );
    }

    EdgeInsetsGeometry padding = basePadding.add(tailPadding);
    final Widget body;
    if (message.deletedAt != null) {
      body = IntrinsicWidth(
        child: withQuote(stretch: true, [
          _DeletedContent(color: textColor.withValues(alpha: 0.75)),
          const SizedBox(height: 3),
          Align(alignment: AlignmentDirectional.centerEnd, child: footer),
        ]),
      );
    } else {
      switch (message) {
        case TextMessage(:final linkPreview):
          final reasoning = message.reasoning;
          final hasAiExtras = reasoning != null ||
              message.toolCalls.isNotEmpty ||
              message.sources.isNotEmpty;
          Widget subtleText(String text, TextStyle style) =>
              _richText(text, textStyle.merge(style), theme);
          final content = IntrinsicWidth(
            child: withQuote(stretch: true, [
              if (reasoning != null)
                _ReasoningBlock(
                  state: state,
                  message: message,
                  reasoning: reasoning,
                  textColor: textColor,
                  richText: subtleText,
                ),
              if (message.toolCalls.isNotEmpty)
                _ToolCalls(
                  calls: message.toolCalls,
                  textColor: textColor,
                  richText: subtleText,
                ),
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
              if (message.sources.isNotEmpty && !message.isStreaming)
                _SourceChips(
                  state: state,
                  message: message,
                  textColor: textColor,
                ),
              if (message.buttons.isNotEmpty)
                _MessageButtons(
                  state: state,
                  message: message,
                  textColor: textColor,
                  accent: accent,
                ),
              if (linkPreview != null) ...[
                const SizedBox(height: 8),
                _LinkPreviewCard(
                  state: state,
                  preview: linkPreview,
                  textColor: textColor,
                  accent: accent,
                  maxWidth: innerWidth,
                ),
              ],
              const SizedBox(height: 3),
              Align(alignment: AlignmentDirectional.centerEnd, child: footer),
            ]),
          );
          // AI answers with reasoning or tools use the full width, so the
          // collapsible blocks do not resize the bubble.
          body = hasAiExtras
              ? SizedBox(width: innerWidth, child: content)
              : content;
        case ImageMessage(:final caption):
          // Images go almost edge to edge; the caption keeps normal padding.
          const inset = 3.0;
          padding = const EdgeInsets.all(inset).add(tailPadding);
          final gridWidth = maxWidth - inset * 2 - tailPadding.horizontal;
          final grid = _ImageGrid(
            state: state,
            message: message,
            width: gridWidth,
            radius: math.max(0.0, theme.bubbleRadius - inset),
          );
          body = SizedBox(
            width: gridWidth,
            child: withQuote(stretch: true, [
              if (caption == null)
                Stack(
                  children: [
                    grid,
                    PositionedDirectional(
                      end: 8,
                      bottom: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: _Footer(
                            message: message,
                            showStatus: outgoing,
                            color: Colors.white,
                            style: theme.timestampTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                grid,
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    math.max(0, basePadding.left - inset),
                    6,
                    math.max(0, basePadding.right - inset),
                    math.max(0, basePadding.bottom - inset),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _richText(caption, textStyle, theme),
                      const SizedBox(height: 3),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: footer,
                      ),
                    ],
                  ),
                ),
              ],
            ]),
          );
        case FileMessage():
          body = withQuote([
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: innerWidth),
              child: _FileContent(message: message, textColor: textColor),
            ),
            const SizedBox(height: 3),
            footer,
          ]);
        case VoiceMessage():
          body = SizedBox(
            width: math.min(innerWidth, 280),
            child: withQuote([
              _VoiceContent(
                state: state,
                message: message,
                textColor: textColor,
                accent: accent,
              ),
              _VoiceTranscript(
                state: state,
                message: message,
                textColor: textColor,
                accent: accent,
              ),
              footer,
            ]),
          );
        case PollMessage():
          body = SizedBox(
            width: math.min(innerWidth, 320),
            child: withQuote([
              _PollContent(
                state: state,
                message: message,
                textColor: textColor,
                accent: accent,
              ),
              footer,
            ]),
          );
        case CountdownMessage():
          body = SizedBox(
            width: math.min(innerWidth, 320),
            child: withQuote([
              _CountdownContent(
                message: message,
                textColor: textColor,
                accent: accent,
                textStyle: textStyle,
                richText: (text) => _richText(text, textStyle, theme),
              ),
              const SizedBox(height: 3),
              footer,
            ]),
          );
        case SurveyMessage():
          body = SizedBox(
            width: math.min(innerWidth, 320),
            child: withQuote([
              _SurveyContent(
                state: state,
                message: message,
                textColor: textColor,
                accent: accent,
                textStyle: textStyle,
              ),
              const SizedBox(height: 3),
              footer,
            ]),
          );
        case CustomMessage():
          body = withQuote([
            (view.builders.customMessageBuilders[message.type] ??
                        view.builders.customMessageBuilder)
                    ?.call(context, message, details) ??
                Text(
                  l10n.unsupportedMessage,
                  style: textStyle.copyWith(fontStyle: FontStyle.italic),
                ),
            const SizedBox(height: 3),
            footer,
          ]);
        case LocationMessage():
          final width = math.min(innerWidth, 300.0);
          body = SizedBox(
            width: width,
            child: withQuote([
              _LocationContent(
                state: state,
                message: message,
                width: width,
                textColor: textColor,
                accent: accent,
              ),
              const SizedBox(height: 3),
              footer,
            ]),
          );
        case EventMessage():
          body = SizedBox(
            width: math.min(innerWidth, 320),
            child: withQuote([
              _EventContent(
                state: state,
                message: message,
                textColor: textColor,
                accent: accent,
                textStyle: textStyle,
              ),
              const SizedBox(height: 3),
              footer,
            ]),
          );
        case ContactMessage():
          body = SizedBox(
            width: math.min(innerWidth, 300),
            child: withQuote([
              _ContactContent(
                state: state,
                message: message,
                textColor: textColor,
                accent: accent,
              ),
              footer,
            ]),
          );
        case StickerMessage(:final uri, :final label):
          final pixels = (150 * MediaQuery.devicePixelRatioOf(context)).round();
          body = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Semantics(
                image: true,
                label: label ?? l10n.sticker,
                child: Image(
                  key: Key('chatx_sticker_message_${message.id}'),
                  image: ResizeImage.resizeIfNeeded(
                    pixels,
                    null,
                    view.builders.imageProviderBuilder?.call(uri) ??
                        NetworkImage(uri),
                  ),
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                  errorBuilder: (context, _, __) =>
                      const SizedBox.square(dimension: 150),
                ),
              ),
              footer,
            ],
          );
        case VideoMessage(:final caption):
          const inset = 3.0;
          padding = const EdgeInsets.all(inset).add(tailPadding);
          final videoWidth = math.min(
            maxWidth - inset * 2 - tailPadding.horizontal,
            320.0,
          );
          final video = _VideoContent(
            state: state,
            message: message,
            width: videoWidth,
            radius: math.max(0.0, theme.bubbleRadius - inset),
          );
          body = SizedBox(
            width: videoWidth,
            child: withQuote(stretch: true, [
              if (caption == null)
                Stack(
                  children: [
                    video,
                    PositionedDirectional(
                      end: 8,
                      bottom: 6,
                      child: _Footer(
                        message: message,
                        showStatus: outgoing,
                        color: Colors.white,
                        style: theme.timestampTextStyle,
                      ),
                    ),
                  ],
                )
              else ...[
                video,
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    math.max(0, basePadding.left - inset),
                    6,
                    math.max(0, basePadding.right - inset),
                    math.max(0, basePadding.bottom - inset),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _richText(caption, textStyle, theme),
                      const SizedBox(height: 3),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: footer,
                      ),
                    ],
                  ),
                ),
              ],
            ]),
          );
        case ChecklistMessage():
          body = SizedBox(
            width: math.min(innerWidth, 320),
            child: withQuote([
              _ChecklistContent(
                state: state,
                message: message,
                textColor: textColor,
                accent: accent,
              ),
              const SizedBox(height: 3),
              footer,
            ]),
          );
        case ProductMessage(:final text):
          body = SizedBox(
            width: message.products.length > 1
                ? innerWidth
                : math.min(innerWidth, 260),
            child: withQuote(stretch: true, [
              if (text != null) ...[
                _richText(text, textStyle, theme),
                const SizedBox(height: 8),
              ],
              _ProductContent(
                state: state,
                message: message,
                textColor: textColor,
                accent: accent,
                width: message.products.length > 1
                    ? innerWidth
                    : math.min(innerWidth, 260),
              ),
              const SizedBox(height: 3),
              Align(alignment: AlignmentDirectional.centerEnd, child: footer),
            ]),
          );
        case PaymentMessage():
          body = SizedBox(
            width: math.min(innerWidth, 280),
            child: withQuote([
              _PaymentContent(
                state: state,
                message: message,
                outgoing: outgoing,
                textColor: textColor,
                accent: accent,
              ),
              const SizedBox(height: 3),
              footer,
            ]),
          );
        case CallMessage():
          body = SizedBox(
            width: math.min(innerWidth, 260),
            child: withQuote([
              _CallContent(
                state: state,
                message: message,
                outgoing: outgoing,
                textColor: textColor,
              ),
              footer,
            ]),
          );
        case SystemMessage():
          return const SizedBox.shrink();
      }
    }

    final author = outgoing ? l10n.you : (message.author.name ?? l10n.someone);

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
              onSecondaryTap: () => state._handleLongPress(message, anchor),
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
    // A regenerated answer shows the version picked with "‹ 2/3 ›".
    if (message.versions.isNotEmpty && !message.isStreaming) {
      return ValueListenableBuilder<Map<String, int>>(
        valueListenable: state._versionIndex,
        builder: (context, indexes, _) {
          final index = indexes[message.id];
          if (index == null || index >= message.versions.length) {
            return _currentText(message, theme, textStyle, textColor);
          }
          return _richText(message.versions[index], textStyle, theme);
        },
      );
    }
    return _currentText(message, theme, textStyle, textColor);
  }

  Widget _currentText(
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
    if (view.ai.onTranslate != null) {
      return ValueListenableBuilder<Map<String, _Translation>>(
        valueListenable: state._translations,
        builder: (context, translations, _) {
          final translation = translations[message.id];
          final translated = translation?.text;
          final showTranslated =
              translated != null && !translation!.showOriginal;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _richText(
                showTranslated ? translated : message.text,
                textStyle,
                theme,
              ),
              if (translation != null)
                _TranslationBar(
                  translation: translation,
                  color: textColor.withValues(alpha: 0.7),
                  onToggle: () => state._translate(message),
                  onRetry: () {
                    state._translations.value = {
                      ...state._translations.value,
                    }..remove(message.id);
                    state._translate(message);
                  },
                ),
            ],
          );
        },
      );
    }
    return _richText(
      message.text,
      textStyle,
      theme,
      trailing: message.isStreaming
          ? WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _StreamingCaret(color: textColor),
            )
          : null,
    );
  }

  /// Markdown text with links, mentions and search highlights.
  Widget _richText(
    String text,
    TextStyle textStyle,
    ChatThemeData theme, {
    InlineSpan? trailing,
  }) {
    final filtered = view.moderation.wordFilter?.apply(text) ?? text;
    Widget build(String? query) => ChatText(
          filtered,
          style: textStyle,
          linkStyle: theme.linkStyle,
          codeStyle: theme.codeTextStyle,
          onLinkTap: view.onLinkTap,
          linkPolicy: view.linkPolicy,
          enableMarkdown: view.enableMarkdown,
          trailing: trailing,
          mentionableUsers: view.mentionableUsers,
          onMentionTap: view.onMentionTap,
          currentUserId: view.currentUser.id,
          highlight: query,
        );
    final search = view.searchController;
    if (search == null) return build(null);
    return ListenableBuilder(
      listenable: search,
      builder: (context, _) => build(search.isActive ? search.query : null),
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
    final preview = original == null
        ? l10n.quoteUnavailable
        : _messagePreview(original, l10n);

    return Semantics(
      button: original != null,
      child: Material(
        key: Key('chatx_quote_$messageId'),
        color: textColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: original == null ? null : onTap,
          child: ConstrainedBox(
            // A comfortable touch target even for one-line quotes.
            constraints: const BoxConstraints(minHeight: 48),
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
      ),
    );
  }
}

/// One-line, markdown-free summary of [message].
String _messagePreview(ChatMessage message, ChatLocalizations l10n) =>
    switch (message) {
      _ when message.deletedAt != null => l10n.messageDeleted,
      TextMessage(:final text) => MarkdownParser.toPlainText(text),
      SystemMessage(:final text) => text,
      ImageMessage(:final caption, :final images) => caption != null
          ? '📷 ${MarkdownParser.toPlainText(caption)}'
          : images.length > 1
              ? '📷 ${l10n.photo} ×${images.length}'
              : '📷 ${l10n.photo}',
      FileMessage(:final name) => '📄 $name',
      VoiceMessage(:final duration) =>
        '🎤 ${l10n.voiceMessage} (${_formatDuration(duration)})',
      PollMessage(:final question) => '📊 $question',
      CountdownMessage(:final title) => '⏳ $title',
      SurveyMessage(:final title) => '📋 $title',
      LocationMessage(:final title) => '📍 ${title ?? l10n.location}',
      EventMessage(:final title) => '📅 $title',
      ContactMessage(:final name) => '👤 $name',
      StickerMessage(:final label) => label ?? l10n.sticker,
      VideoMessage(:final caption, :final duration) => caption != null
          ? '🎬 ${MarkdownParser.toPlainText(caption)}'
          : duration != null
              ? '🎬 ${l10n.video} (${_formatDuration(duration)})'
              : '🎬 ${l10n.video}',
      ChecklistMessage(:final title) => '☑️ $title',
      ProductMessage(:final products) => '🛍️ ${products.first.title}',
      PaymentMessage(:final amount, :final isRequest) =>
        '💸 ${isRequest ? l10n.paymentRequest : l10n.paymentSent}: $amount',
      CallMessage(:final kind) => kind == ChatCallKind.video
          ? '📹 ${l10n.videoCall}'
          : '📞 ${l10n.voiceCall}',
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
    return Transform.translate(
      // Pull the chips up so they overlap the bubble edge, and the 48 dp
      // touch targets do not push the next message away.
      offset: const Offset(0, -16),
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
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // The chip looks small, but the touch target is 48 dp tall.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Center(widthFactor: 1, child: chip),
        ),
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
    this.saved,
  });

  final ChatMessage message;
  final bool showStatus;
  final Color color;
  final TextStyle style;
  final ValueListenable<Set<String>>? saved;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    final l10n = ChatLocalizations.of(context);
    final textStyle = style.copyWith(color: style.color ?? color);
    final scheduledFor = message.scheduledFor;
    final time = _clock(context, message.createdAt);
    final edited = message is TextMessage &&
        message.editedAt != null &&
        message.deletedAt == null;
    final status = message.status;
    final expiresAt = message.expiresAt;

    final Widget label;
    if (scheduledFor != null) {
      label = Row(
        key: const Key('chatx_scheduled'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_send_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            l10n.scheduledFor(
              '${MaterialLocalizations.of(context).formatShortMonthDay(scheduledFor.toLocal())}'
              ' ${_clock(context, scheduledFor)}',
            ),
            style: textStyle,
          ),
        ],
      );
    } else if (edited) {
      label = GestureDetector(
        key: Key('chatx_edited_${message.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: message.editHistory.isEmpty
            ? null
            : () => _showEditHistory(context, message),
        child: Text(
          '${l10n.edited} · $time',
          style: message.editHistory.isEmpty
              ? textStyle
              : textStyle.copyWith(decoration: TextDecoration.underline),
        ),
      );
    } else {
      label = Text(time, style: textStyle);
    }

    final saved = this.saved;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (saved != null)
          ValueListenableBuilder<Set<String>>(
            valueListenable: saved,
            builder: (context, ids, _) => ids.contains(message.id)
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(end: 4),
                    child: Icon(
                      Icons.bookmark_rounded,
                      key: const Key('chatx_saved_icon'),
                      size: 13,
                      color: color,
                      semanticLabel: l10n.saved,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        if (expiresAt != null) _ExpiryBadge(expiresAt: expiresAt, color: color),
        label,
        if (showStatus && status != null && scheduledFor == null) ...[
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

/// Check circle and tint shown on every row in selection mode.
class _SelectionFrame extends StatelessWidget {
  const _SelectionFrame({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final accent = theme.outgoingBubbleColor;
    return Semantics(
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? theme.highlightColor : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4, end: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? accent : null,
                    border: Border.all(
                      color: selected
                          ? accent
                          : theme.typingIndicatorColor.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: theme.outgoingTextStyle.color,
                        )
                      : null,
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
