part of '../chat_view.dart';

/// Bottom slot of the list that grows when other users are typing.
class _TypingSlot extends StatelessWidget {
  const _TypingSlot({
    required this.typingUsers,
    required this.currentUser,
    required this.indent,
    required this.builder,
  });

  final ValueListenable<List<ChatUser>> typingUsers;
  final ChatUser currentUser;
  final double indent;
  final ChatTypingIndicatorBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ChatUser>>(
      valueListenable: typingUsers,
      builder: (context, users, _) {
        final others = [
          for (final u in users)
            if (u.id != currentUser.id) u,
        ];
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomCenter,
          child: others.isEmpty
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: EdgeInsetsDirectional.only(top: 10, start: indent),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: builder?.call(context, others) ??
                        TypingIndicator(users: others),
                  ),
                ),
        );
      },
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

/// "New messages" line above the first unread message.
class _UnreadSeparator extends StatelessWidget {
  const _UnreadSeparator();

  @override
  Widget build(BuildContext context) {
    final theme = ChatThemeData.of(context);
    final color = theme.unreadSeparatorColor;
    final line = Expanded(
      child: Container(height: 1, color: color.withValues(alpha: 0.5)),
    );
    return Semantics(
      key: const Key('chatx_unread_separator'),
      header: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            line,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                ChatLocalizations.of(context).unreadSeparator,
                style: theme.dateSeparatorTextStyle.copyWith(color: color),
              ),
            ),
            line,
          ],
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
