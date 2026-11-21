part of '../chat_view.dart';

/// Collapsible "Thinking…" / "Thought for 12s" block of an AI answer.
class _ReasoningBlock extends StatefulWidget {
  const _ReasoningBlock({
    required this.state,
    required this.message,
    required this.reasoning,
    required this.textColor,
    required this.richText,
  });

  final _ChatViewState state;
  final TextMessage message;
  final ChatReasoning reasoning;
  final Color textColor;
  final Widget Function(String text, TextStyle style) richText;

  @override
  State<_ReasoningBlock> createState() => _ReasoningBlockState();
}

class _ReasoningBlockState extends State<_ReasoningBlock>
    with SingleTickerProviderStateMixin {
  // Open while the model thinks, so the user sees progress.
  late bool _open = widget.reasoning.isActive;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(_ReasoningBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Collapse automatically when thinking ends.
    if (oldWidget.reasoning.isActive && !widget.reasoning.isActive) {
      _open = false;
    }
    _syncPulse();
  }

  void _syncPulse() {
    if (widget.reasoning.isActive) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final reasoning = widget.reasoning;
    final subtle = widget.textColor.withValues(alpha: 0.72);
    final seconds = reasoning.duration?.inSeconds;
    final label = reasoning.isActive
        ? l10n.thinking
        : seconds == null
            ? l10n.reasoning
            : l10n.thoughtFor(seconds);
    final labelStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: subtle, fontWeight: FontWeight.w600);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            child: InkWell(
              key: Key('chatx_reasoning_${widget.message.id}'),
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _open = !_open);
                widget.state.widget.onReasoningTap?.call(widget.message);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    FadeTransition(
                      opacity: reduceMotion
                          ? const AlwaysStoppedAnimation(1)
                          : Tween(begin: 0.35, end: 1.0).animate(_pulse),
                      child: Icon(
                        Icons.psychology_outlined,
                        size: 18,
                        color: subtle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(child: Text(label, style: labelStyle)),
                    Icon(
                      _open
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 18,
                      color: subtle,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_open || reasoning.text.isEmpty
                ? const SizedBox(width: double.infinity)
                : Container(
                    width: double.infinity,
                    margin: const EdgeInsetsDirectional.only(start: 8),
                    padding: const EdgeInsetsDirectional.only(start: 10),
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(
                          color: widget.textColor.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                    ),
                    child: widget.richText(
                      reasoning.text,
                      TextStyle(
                        color: subtle,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Cards for the tools an AI model used.
class _ToolCalls extends StatelessWidget {
  const _ToolCalls({
    required this.calls,
    required this.textColor,
    required this.richText,
  });

  final List<ChatToolCall> calls;
  final Color textColor;
  final Widget Function(String text, TextStyle style) richText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final call in calls)
            _ToolCallCard(call: call, textColor: textColor, richText: richText),
        ],
      ),
    );
  }
}

class _ToolCallCard extends StatefulWidget {
  const _ToolCallCard({
    required this.call,
    required this.textColor,
    required this.richText,
  });

  final ChatToolCall call;
  final Color textColor;
  final Widget Function(String text, TextStyle style) richText;

  @override
  State<_ToolCallCard> createState() => _ToolCallCardState();
}

class _ToolCallCardState extends State<_ToolCallCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final call = widget.call;
    final theme = ChatThemeData.of(context);
    final subtle = widget.textColor.withValues(alpha: 0.75);
    final detail = call.detail;
    final Widget status = switch (call.status) {
      ChatToolStatus.running => SizedBox.square(
          dimension: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: subtle),
        ),
      ChatToolStatus.done =>
        Icon(Icons.check_circle_rounded, size: 16, color: subtle),
      ChatToolStatus.failed =>
        Icon(Icons.error_rounded, size: 16, color: theme.errorColor),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        key: Key('chatx_tool_${call.id}'),
        color: widget.textColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: detail == null ? null : () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: Row(
                    children: [
                      status,
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          call.name,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (detail != null)
                        Icon(
                          _open
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 18,
                          color: subtle,
                        ),
                    ],
                  ),
                ),
                if (_open && detail != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: widget.richText(
                      detail,
                      TextStyle(color: subtle, fontSize: 13, height: 1.4),
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

/// Numbered source chips under an AI answer.
class _SourceChips extends StatelessWidget {
  const _SourceChips({
    required this.state,
    required this.message,
    required this.textColor,
  });

  final _ChatViewState state;
  final TextMessage message;
  final Color textColor;

  void _open(ChatSource source) {
    final view = state.widget;
    if (view.onSourceTap != null) {
      view.onSourceTap!(source);
      return;
    }
    final uri = view.linkPolicy.resolve(source.url);
    if (uri != null) view.onLinkTap?.call(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    return Semantics(
      container: true,
      label: l10n.sources,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 6,
          children: [
            for (final (index, source) in message.sources.indexed)
              Semantics(
                button: true,
                label: '${index + 1}. ${source.title}, ${source.host}',
                excludeSemantics: true,
                child: InkWell(
                  key: Key('chatx_source_${message.id}_$index'),
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => _open(source),
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    textColor.withValues(alpha: 0.16),
                                child: Text(
                                  '${index + 1}',
                                  style: labelStyle?.copyWith(
                                    color: textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 140),
                                child: Text(
                                  source.host.isEmpty
                                      ? source.title
                                      : source.host,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: labelStyle?.copyWith(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "‹ 2/3 ›" to browse the versions of a regenerated answer.
class _VersionSwitcher extends StatelessWidget {
  const _VersionSwitcher({
    required this.state,
    required this.message,
    required this.color,
  });

  final _ChatViewState state;
  final TextMessage message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final total = message.versions.length + 1;
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: state._versionIndex,
      builder: (context, indexes, _) {
        final current = indexes[message.id] ?? total - 1;
        void go(int index) {
          HapticFeedback.selectionClick();
          state._versionIndex.value = {
            ...state._versionIndex.value,
            message.id: index,
          };
        }

        return Row(
          key: Key('chatx_versions_${message.id}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: Key('chatx_version_previous_${message.id}'),
              tooltip: l10n.previousVersion,
              iconSize: 18,
              color: color,
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: current == 0 ? null : () => go(current - 1),
            ),
            Text(
              '${current + 1}/$total',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: color),
            ),
            IconButton(
              key: Key('chatx_version_next_${message.id}'),
              tooltip: l10n.nextVersion,
              iconSize: 18,
              color: color,
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: current >= total - 1 ? null : () => go(current + 1),
            ),
          ],
        );
      },
    );
  }
}

/// Thumbnail, play button and duration of a [VideoMessage].
class _VideoContent extends StatelessWidget {
  const _VideoContent({
    required this.state,
    required this.message,
    required this.width,
    required this.radius,
  });

  final _ChatViewState state;
  final VideoMessage message;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final w = message.width;
    final h = message.height;
    final aspect = w != null && h != null && w > 0 && h > 0
        ? (w / h).clamp(0.6, 1.9)
        : 16 / 9;
    final thumbnail = message.thumbnailUri;
    final progress = message.uploadProgress;
    final pixels = (width * MediaQuery.devicePixelRatioOf(context)).round();
    final duration = message.duration;
    return Semantics(
      button: true,
      label: duration == null
          ? l10n.playVideo
          : '${l10n.playVideo}, ${_formatDuration(duration)}',
      excludeSemantics: true,
      child: GestureDetector(
        key: Key('chatx_video_${message.id}'),
        onTap: view.onVideoTap == null || progress != null
            ? null
            : () => view.onVideoTap!(message),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: width,
            height: width / aspect,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xFF1E2626)),
                if (thumbnail != null)
                  Image(
                    image: ResizeImage.resizeIfNeeded(
                      pixels,
                      null,
                      view.imageProviderBuilder?.call(thumbnail) ??
                          NetworkImage(thumbnail),
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => const SizedBox.shrink(),
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black38],
                      stops: [0.55, 1],
                    ),
                  ),
                ),
                Center(
                  child: progress != null
                      ? SizedBox.square(
                          dimension: 48,
                          child: CircularProgressIndicator(
                            value: progress,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                          ),
                        )
                      : const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                ),
                if (duration != null)
                  PositionedDirectional(
                    start: 10,
                    bottom: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.videocam_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
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

/// Transcript under a voice note, or a button that asks for it.
class _VoiceTranscript extends StatefulWidget {
  const _VoiceTranscript({
    required this.state,
    required this.message,
    required this.textColor,
    required this.accent,
  });

  final _ChatViewState state;
  final VoiceMessage message;
  final Color textColor;
  final Color accent;

  @override
  State<_VoiceTranscript> createState() => _VoiceTranscriptState();
}

class _VoiceTranscriptState extends State<_VoiceTranscript> {
  bool _loading = false;

  Future<void> _transcribe() async {
    final onTranscribe = widget.state.widget.onTranscribe;
    if (onTranscribe == null || _loading) return;
    setState(() => _loading = true);
    try {
      await onTranscribe(widget.message);
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'chatx',
          context: ErrorDescription('while transcribing a voice note'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final transcript = widget.message.transcript;
    final subtle = widget.textColor.withValues(alpha: 0.85);
    if (transcript != null) {
      return Padding(
        key: Key('chatx_transcript_${widget.message.id}'),
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          transcript,
          style: TextStyle(color: subtle, fontSize: 14, height: 1.35),
        ),
      );
    }
    if (widget.state.widget.onTranscribe == null) {
      return const SizedBox.shrink();
    }
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: widget.accent,
          fontWeight: FontWeight.w600,
        );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: InkWell(
        key: Key('chatx_transcribe_${widget.message.id}'),
        borderRadius: BorderRadius.circular(8),
        onTap: _loading ? null : _transcribe,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loading)
                SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.accent,
                  ),
                )
              else
                Icon(Icons.subject_rounded, size: 18, color: widget.accent),
              const SizedBox(width: 6),
              Text(
                _loading ? l10n.transcribing : l10n.transcribe,
                style: style,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A shared checklist with progress.
class _ChecklistContent extends StatelessWidget {
  const _ChecklistContent({
    required this.state,
    required this.message,
    required this.textColor,
    required this.accent,
  });

  final _ChatViewState state;
  final ChecklistMessage message;
  final Color textColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final done = message.doneCount;
    final total = message.items.length;
    final onToggle = view.onChecklistToggle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.checklist_rounded, size: 18, color: accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                message.title,
                style: textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : done / total,
            minHeight: 6,
            color: accent,
            backgroundColor: textColor.withValues(alpha: 0.12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.checklistProgress(done, total),
          style: textTheme.labelMedium?.copyWith(
            color: textColor.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 4),
        for (final item in message.items)
          Semantics(
            checked: item.isDone,
            label: item.text,
            excludeSemantics: true,
            onTap: onToggle == null ? null : () => onToggle(message, item),
            child: InkWell(
              key: Key('chatx_check_${message.id}_${item.id}'),
              borderRadius: BorderRadius.circular(8),
              onTap: onToggle == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onToggle(message, item);
                    },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        item.isDone
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        key: ValueKey(item.isDone),
                        size: 22,
                        color: item.isDone
                            ? accent
                            : textColor.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.text,
                        style: TextStyle(
                          // Struck through, but still readable (WCAG AA).
                          color: item.isDone
                              ? textColor.withValues(alpha: 0.78)
                              : textColor,
                          decoration:
                              item.isDone ? TextDecoration.lineThrough : null,
                          decorationColor: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// One product card, or a carousel of them.
class _ProductContent extends StatelessWidget {
  const _ProductContent({
    required this.state,
    required this.message,
    required this.textColor,
    required this.accent,
    required this.width,
  });

  final _ChatViewState state;
  final ProductMessage message;
  final Color textColor;
  final Color accent;
  final double width;

  Widget _card(BuildContext context, ChatProduct product, double cardWidth) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final image = product.imageUri;
    final onTap = view.onProductTap == null
        ? null
        : () => view.onProductTap!(message, product);
    final onAccent =
        accent.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final pixels = (cardWidth * MediaQuery.devicePixelRatioOf(context)).round();
    return SizedBox(
      width: cardWidth,
      child: Material(
        key: Key('chatx_product_${message.id}_${product.id}'),
        color: textColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: image == null
                    ? ColoredBox(
                        color: textColor.withValues(alpha: 0.08),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 40,
                          color: textColor.withValues(alpha: 0.4),
                        ),
                      )
                    : Image(
                        image: ResizeImage.resizeIfNeeded(
                          pixels,
                          null,
                          view.imageProviderBuilder?.call(image) ??
                              NetworkImage(image),
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) => ColoredBox(
                          color: textColor.withValues(alpha: 0.08),
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.subtitle != null)
                        Text(
                          product.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: textColor.withValues(alpha: 0.75),
                          ),
                        ),
                      const Spacer(),
                      const SizedBox(height: 6),
                      Text(
                        product.price,
                        style: textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: onAccent,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(product.actionLabel ?? l10n.view),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = message.products;
    if (products.length == 1) {
      return IntrinsicHeight(child: _card(context, products.single, width));
    }
    final cardWidth = math.min(200.0, width * 0.78);
    return SingleChildScrollView(
      key: Key('chatx_products_${message.id}'),
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, product) in products.indexed) ...[
              if (index > 0) const SizedBox(width: 8),
              _card(context, product, cardWidth),
            ],
          ],
        ),
      ),
    );
  }
}

/// A payment request or a sent payment.
class _PaymentContent extends StatelessWidget {
  const _PaymentContent({
    required this.state,
    required this.message,
    required this.outgoing,
    required this.textColor,
    required this.accent,
  });

  final _ChatViewState state;
  final PaymentMessage message;
  final bool outgoing;
  final Color textColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final theme = ChatThemeData.of(context);
    final textTheme = Theme.of(context).textTheme;
    final status = message.paymentStatus;
    final (statusLabel, statusIcon, statusColor) = switch (status) {
      ChatPaymentStatus.pending => (
          l10n.paymentPending,
          Icons.schedule_rounded,
          textColor.withValues(alpha: 0.75),
        ),
      ChatPaymentStatus.paid => (
          l10n.paymentPaid,
          Icons.check_circle_rounded,
          accent,
        ),
      ChatPaymentStatus.declined => (
          l10n.paymentDeclined,
          Icons.cancel_rounded,
          outgoing ? textColor : theme.errorColor,
        ),
      ChatPaymentStatus.cancelled => (
          l10n.paymentCancelled,
          Icons.block_rounded,
          textColor.withValues(alpha: 0.75),
        ),
    };
    final onAction = view.onPaymentAction;
    final canAnswer = onAction != null &&
        !outgoing &&
        message.isRequest &&
        status == ChatPaymentStatus.pending;
    final onAccent =
        accent.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              message.isRequest
                  ? Icons.request_quote_outlined
                  : Icons.payments_outlined,
              size: 18,
              color: accent,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                (message.isRequest ? l10n.paymentRequest : l10n.paymentSent)
                    .toUpperCase(),
                style: textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          message.amount,
          style: textTheme.headlineMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (message.note != null)
          Text(
            message.note!,
            style: TextStyle(color: textColor.withValues(alpha: 0.85)),
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(statusIcon, size: 16, color: statusColor),
            const SizedBox(width: 4),
            Text(
              statusLabel,
              style: textTheme.labelMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (canAnswer) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: Key('chatx_decline_${message.id}'),
                  onPressed: () => onAction(message, ChatPaymentAction.decline),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: textColor.withValues(alpha: 0.3)),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.decline),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  key: Key('chatx_pay_${message.id}'),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onAction(message, ChatPaymentAction.pay);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: onAccent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.pay),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// An entry of the call log.
class _CallContent extends StatelessWidget {
  const _CallContent({
    required this.state,
    required this.message,
    required this.outgoing,
    required this.textColor,
  });

  final _ChatViewState state;
  final CallMessage message;
  final bool outgoing;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final theme = ChatThemeData.of(context);
    final video = message.kind == ChatCallKind.video;
    final completed = message.outcome == ChatCallOutcome.completed;
    final alert = !completed && !outgoing;
    final iconColor = alert ? theme.errorColor : textColor;
    final duration = message.duration;
    final detail = switch (message.outcome) {
      ChatCallOutcome.missed => l10n.missedCall,
      ChatCallOutcome.declined => l10n.declinedCall,
      ChatCallOutcome.completed =>
        duration == null ? null : _formatDuration(duration),
    };
    final arrow = switch ((outgoing, completed)) {
      (true, _) => Icons.call_made_rounded,
      (false, true) => Icons.call_received_rounded,
      (false, false) => Icons.call_missed_rounded,
    };
    final onCallBack = view.onCallBack;
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              video ? Icons.videocam_rounded : Icons.call_rounded,
              size: 20,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video ? l10n.videoCall : l10n.voiceCall,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (detail != null)
                Row(
                  children: [
                    Icon(arrow, size: 14, color: iconColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        detail,
                        style: TextStyle(
                          color: alert
                              ? theme.errorColor
                              : textColor.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (onCallBack != null)
          IconButton(
            key: Key('chatx_call_back_${message.id}'),
            tooltip: l10n.callBack,
            color: textColor,
            icon: Icon(video ? Icons.videocam_outlined : Icons.call_outlined),
            onPressed: () => onCallBack(message),
          ),
      ],
    );
  }
}

/// Banner shown while offline or reconnecting.
class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({required this.connection});

  final ChatConnectionState connection;

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final offline = connection == ChatConnectionState.offline;
    return AnimatedSize(
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: connection == ChatConnectionState.online
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              child: Material(
                key: const Key('chatx_connection_banner'),
                color: offline
                    ? scheme.surfaceContainerHighest
                    : scheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (offline)
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        )
                      else
                        SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          offline ? l10n.offline : l10n.connecting,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: offline
                                        ? scheme.onSurfaceVariant
                                        : scheme.onSecondaryContainer,
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

/// Thumbnails of the files waiting in the input.
class _AttachmentTray extends StatelessWidget {
  const _AttachmentTray({required this.state});

  final _ChatViewState state;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    if (view.onSendAttachments == null) return const SizedBox.shrink();
    final l10n = ChatLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<List<ChatAttachment>>(
      valueListenable: view.controller.attachments,
      builder: (context, attachments, _) {
        if (attachments.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          key: const Key('chatx_attachment_tray'),
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
            itemCount: attachments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              final ImageProvider? image = switch (attachment) {
                ChatAttachment(kind: ChatAttachmentKind.image, :final bytes?) =>
                  MemoryImage(bytes),
                ChatAttachment(kind: ChatAttachmentKind.image, :final uri?) =>
                  view.imageProviderBuilder?.call(uri) ?? NetworkImage(uri),
                _ => null,
              };
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: scheme.surfaceContainerHighest,
                      child: image != null
                          ? Image(
                              image: ResizeImage.resizeIfNeeded(
                                (80 * MediaQuery.devicePixelRatioOf(context))
                                    .round(),
                                null,
                                image,
                              ),
                              fit: BoxFit.cover,
                              semanticLabel: attachment.name,
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    attachment.kind == ChatAttachmentKind.video
                                        ? Icons.movie_outlined
                                        : Icons.insert_drive_file_outlined,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    attachment.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  PositionedDirectional(
                    top: -14,
                    end: -14,
                    child: IconButton(
                      key: Key('chatx_remove_attachment_${attachment.id}'),
                      tooltip: '${l10n.removeAttachment} ${attachment.name}',
                      onPressed: () =>
                          view.controller.removeAttachment(attachment.id),
                      icon: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.inverseSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: scheme.onInverseSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Suggested prompts in an empty conversation.
class _PromptSuggestions extends StatelessWidget {
  const _PromptSuggestions({required this.state, required this.title});

  final _ChatViewState state;
  final String title;

  @override
  Widget build(BuildContext context) {
    final prompts = state.widget.suggestedPrompts;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final theme = ChatThemeData.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.systemMessageTextStyle,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 420 ? 2 : 1;
                  final width =
                      (constraints.maxWidth - 8 * (columns - 1)) / columns;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (index, prompt) in prompts.indexed)
                        SizedBox(
                          width: width,
                          child: Material(
                            key: Key('chatx_prompt_$index'),
                            color: scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(14),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => state._sendPrompt(prompt),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    if (prompt.icon != null) ...[
                                      Icon(
                                        prompt.icon,
                                        color: theme.outgoingBubbleColor,
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prompt.title,
                                            style: textTheme.titleSmall,
                                          ),
                                          if (prompt.subtitle != null)
                                            Text(
                                              prompt.subtitle!,
                                              style:
                                                  textTheme.bodySmall?.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Buttons shown next to a bubble while a mouse hovers it.
class _HoverActions extends StatelessWidget {
  const _HoverActions({required this.state, required this.message});

  final _ChatViewState state;
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final canReply = view.swipeAction != null && message.scheduledFor == null;
    Widget button(Key key, IconData icon, String tooltip, VoidCallback onTap) {
      return IconButton(
        key: key,
        tooltip: tooltip,
        iconSize: 18,
        visualDensity: VisualDensity.compact,
        color: scheme.onSurfaceVariant,
        icon: Icon(icon),
        onPressed: onTap,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        key: Key('chatx_hover_${message.id}'),
        color: scheme.surfaceContainerHigh,
        elevation: 1,
        borderRadius: BorderRadius.circular(999),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (view.onReactionSelected != null)
              Builder(
                builder: (anchor) => button(
                  Key('chatx_hover_react_${message.id}'),
                  Icons.add_reaction_outlined,
                  l10n.addReaction,
                  () => state._handleLongPress(message, anchor),
                ),
              ),
            if (canReply)
              button(
                Key('chatx_hover_reply_${message.id}'),
                Icons.reply_rounded,
                l10n.reply,
                () => state._startReply(message),
              ),
            Builder(
              builder: (anchor) => button(
                Key('chatx_hover_more_${message.id}'),
                Icons.more_horiz_rounded,
                l10n.moreActions,
                () => state._handleLongPress(message, anchor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "@" button that jumps to unread mentions of the current user.
class _MentionsButton extends StatelessWidget {
  const _MentionsButton({required this.state});

  final _ChatViewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final theme = ChatThemeData.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<List<String>>(
      valueListenable: state._pendingMentions,
      builder: (context, pending, _) {
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        return AnimatedScale(
          scale: pending.isEmpty ? 0 : 1,
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          child: pending.isEmpty
              ? const SizedBox(width: 48, height: 48)
              : Semantics(
                  button: true,
                  label: l10n.unreadMentions(pending.length),
                  excludeSemantics: true,
                  child: Badge(
                    label: Text('${pending.length}'),
                    backgroundColor: theme.outgoingBubbleColor,
                    textColor: theme.bubbleTextStyle(isOutgoing: true).color,
                    child: Material(
                      key: const Key('chatx_mentions_button'),
                      color: scheme.surfaceContainerHigh,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: state._jumpToMention,
                        child: SizedBox.square(
                          dimension: 48,
                          child: Icon(
                            Icons.alternate_email_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
