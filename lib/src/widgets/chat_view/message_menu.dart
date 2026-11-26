part of '../chat_view.dart';

/// Result of the menu when the user picks a reaction.
class _ReactionChoice {
  const _ReactionChoice(this.emoji);
  final String emoji;
}

/// Bubbles taller than this share of the screen are not lifted into
/// focus: there would be little room left for the menu.
const double _maxFocusedBubbleShare = 0.4;

/// Shows the message menu.
///
/// The chat behind blurs. When the bubble is small enough to stay on
/// screen with the menu, it is shown sharp above the blur, and the menu
/// sits next to it with a small pointer toward it. When the menu does not
/// fit above or below the bubble, the bubble moves to make room, so it is
/// never hidden by its own menu.
///
/// Taller bubbles stay in place, blurred like the rest, and the menu opens
/// at the bottom with a preview of the message, so the user still knows
/// which message it is about.
///
/// With [ChatMessageMenuStyle.popup] the menu is a card next to the bubble;
/// with [ChatMessageMenuStyle.bottomSheet] it is a panel at the bottom and
/// the bubble rises above it.
///
/// [focusedId] holds the ID of a lifted bubble, so the list hides its
/// original meanwhile. Returns a [ChatMessageAction], a [_ReactionChoice]
/// or `null`.
Future<Object?> _showFocusedMenu(
  BuildContext anchor, {
  required ChatMessageMenuStyle style,
  required List<ChatMessageAction> actions,
  required List<String> emojis,
  required ChatMessage message,
  required String currentUserId,
  required ChatLocalizations l10n,
  required bool showMore,
  required ValueNotifier<String?> focusedId,
  String Function(String text)? textSanitizer,
}) {
  final navigator = Navigator.of(anchor);
  final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
  final box = anchor.findRenderObject()! as RenderBox;
  final bubbleRect =
      box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
  final bubble = anchor.findAncestorWidgetOfExactType<_Bubble>();
  final scope = ChatScope.maybeOf(anchor);
  final theme = scope?.theme ?? ChatThemeData.of(anchor);
  final padding = MediaQuery.paddingOf(anchor);
  final usableHeight = overlay.size.height - padding.vertical;

  // Validate the size first: only bubbles that leave room for the menu are
  // lifted into focus.
  final focused = bubble != null &&
      scope != null &&
      bubbleRect.height <= usableHeight * _maxFocusedBubbleShare;
  if (focused) focusedId.value = message.id;

  return navigator.push<Object>(
    _FocusedMenuRoute(
      // A large bubble cannot sit next to a card: use the bottom panel.
      style: focused ? style : ChatMessageMenuStyle.bottomSheet,
      bubbleRect: bubbleRect,
      isOutgoing: bubble?.details.isOutgoing ?? false,
      barrierLabel: MaterialLocalizations.of(anchor).modalBarrierDismissLabel,
      bubble: focused
          ? ChatScope(
              theme: scope.theme,
              localizations: scope.localizations,
              child: _Bubble(
                state: bubble.state,
                details: bubble.details,
                maxWidth: bubbleRect.width,
                isMenuCopy: true,
              ),
            )
          : null,
      menu: ChatScope(
        theme: theme,
        localizations: scope?.localizations ?? l10n,
        child: _MenuPanel(
          style: focused ? style : ChatMessageMenuStyle.bottomSheet,
          actions: actions,
          emojis: emojis,
          message: message,
          currentUserId: currentUserId,
          l10n: l10n,
          showMore: showMore,
          showPreview: !focused,
          textSanitizer: textSanitizer,
        ),
      ),
    ),
  );
}

class _FocusedMenuRoute extends PopupRoute<Object> {
  _FocusedMenuRoute({
    required this.style,
    required this.bubbleRect,
    required this.isOutgoing,
    required this.bubble,
    required this.menu,
    required this.barrierLabel,
  });

  final ChatMessageMenuStyle style;
  final Rect bubbleRect;
  final bool isOutgoing;
  final Widget? bubble;
  final Widget menu;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 220);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final bubble = this.bubble;
    final popup = bubble != null && style == ChatMessageMenuStyle.popup;
    final menuColor = _MenuPanel.colorOf(scheme, style);
    return Stack(
      children: [
        // Blurs and slightly dims the chat; tapping it closes the menu.
        Positioned.fill(
          child: GestureDetector(
            key: const Key('chatx_menu_scrim'),
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: AnimatedBuilder(
              animation: curved,
              builder: (context, _) => BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 8 * curved.value,
                  sigmaY: 8 * curved.value,
                ),
                child: ColoredBox(
                  color: scheme.scrim.withValues(alpha: 0.25 * curved.value),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomMultiChildLayout(
            delegate: _FocusedMenuLayout(
              style: style,
              bubbleRect: bubbleRect,
              isOutgoing: isOutgoing,
              hasBubble: bubble != null,
              padding: MediaQuery.paddingOf(context) +
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            children: [
              if (bubble != null)
                LayoutId(
                  id: _MenuSlot.bubble,
                  // The copy is drawn as is, sharp over the blur. It leaves
                  // at once on close, when the original shows again.
                  child: IgnorePointer(
                    child: _HideWhenClosing(
                      animation: animation,
                      child: KeyedSubtree(
                        key: const Key('chatx_menu_focus'),
                        // Very tall bubbles are clipped to the room left.
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: bubble,
                        ),
                      ),
                    ),
                  ),
                ),
              // Drawn before the menu, so only the half outside the menu
              // shows: a small triangle pointing at the bubble.
              if (popup)
                LayoutId(
                  id: _MenuSlot.pointer,
                  child: FadeTransition(
                    opacity: curved,
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: ColoredBox(
                        key: const Key('chatx_menu_pointer'),
                        color: menuColor,
                      ),
                    ),
                  ),
                ),
              LayoutId(
                id: _MenuSlot.menu,
                child: FadeTransition(
                  opacity: curved,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
                    alignment: style == ChatMessageMenuStyle.bottomSheet
                        ? Alignment.bottomCenter
                        : isOutgoing
                            ? Alignment.topRight
                            : Alignment.topLeft,
                    child: menu,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _MenuSlot { bubble, pointer, menu }

class _HideWhenClosing extends AnimatedWidget {
  const _HideWhenClosing({
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final status = (listenable as Animation<double>).status;
    final closing = status == AnimationStatus.reverse ||
        status == AnimationStatus.dismissed;
    return closing ? const SizedBox.shrink() : child;
  }
}

/// Places the bubble copy where the bubble is, the menu next to it and the
/// pointer between them. When both do not fit, the bubble moves so that
/// the menu fits.
class _FocusedMenuLayout extends MultiChildLayoutDelegate {
  _FocusedMenuLayout({
    required this.style,
    required this.bubbleRect,
    required this.isOutgoing,
    required this.hasBubble,
    required this.padding,
  });

  static const double _gap = 10;
  static const double _pointer = 12;

  final ChatMessageMenuStyle style;
  final Rect bubbleRect;
  final bool isOutgoing;
  final bool hasBubble;
  final EdgeInsets padding;

  @override
  void performLayout(Size size) {
    final top = padding.top;
    final bottom = size.height - padding.bottom;
    final sheet = style == ChatMessageMenuStyle.bottomSheet;

    final menu = layoutChild(
      _MenuSlot.menu,
      BoxConstraints(
        maxWidth: sheet ? size.width : size.width - padding.horizontal,
        maxHeight: (bottom - top) * 0.6,
      ),
    );

    var bubble = Size.zero;
    if (hasChild(_MenuSlot.bubble)) {
      bubble = layoutChild(
        _MenuSlot.bubble,
        BoxConstraints(
          minWidth: bubbleRect.width,
          maxWidth: bubbleRect.width,
          maxHeight: math.max(0, bottom - top - menu.height - _gap),
        ),
      );
    }
    var bubbleTop = bubbleRect.top;

    final double menuTop;
    var menuBelow = true;
    if (sheet) {
      menuTop = size.height - menu.height;
      // The bubble rises above the panel when the panel would cover it.
      bubbleTop = math.max(
        top,
        math.min(bubbleTop, menuTop - _gap - bubble.height),
      );
    } else {
      final below = bubbleTop + bubble.height + _gap;
      final above = bubbleTop - _gap - menu.height;
      if (below + menu.height <= bottom) {
        menuTop = below;
      } else if (above >= top) {
        menuTop = above;
        menuBelow = false;
      } else {
        // Neither side has room: move the bubble up so the menu fits under.
        bubbleTop = math.max(top, bottom - menu.height - _gap - bubble.height);
        menuTop = bubbleTop + bubble.height + _gap;
      }
    }

    if (hasChild(_MenuSlot.bubble)) {
      positionChild(_MenuSlot.bubble, Offset(bubbleRect.left, bubbleTop));
    }

    final double menuLeft;
    if (sheet) {
      menuLeft = (size.width - menu.width) / 2;
    } else {
      // On the author's side, like the bubble, kept on screen.
      final preferred =
          isOutgoing ? bubbleRect.right - menu.width : bubbleRect.left;
      menuLeft = preferred.clamp(
        padding.left,
        math.max(padding.left, size.width - padding.right - menu.width),
      );
    }
    positionChild(_MenuSlot.menu, Offset(menuLeft, menuTop));

    if (hasChild(_MenuSlot.pointer)) {
      layoutChild(
        _MenuSlot.pointer,
        BoxConstraints.tight(const Size.square(_pointer)),
      );
      // Under the middle of the bubble, but on the menu's straight edge.
      final x = bubbleRect.center.dx.clamp(
        menuLeft + 24,
        math.max(menuLeft + 24, menuLeft + menu.width - 24),
      );
      final y = menuBelow ? menuTop : menuTop + menu.height;
      positionChild(
        _MenuSlot.pointer,
        Offset(x - _pointer / 2, y - _pointer / 2),
      );
    }
  }

  @override
  bool shouldRelayout(_FocusedMenuLayout old) =>
      old.style != style ||
      old.bubbleRect != bubbleRect ||
      old.isOutgoing != isOutgoing ||
      old.hasBubble != hasBubble ||
      old.padding != padding;
}

/// Quick reactions and actions of the menu.
class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.style,
    required this.actions,
    required this.emojis,
    required this.message,
    required this.currentUserId,
    required this.l10n,
    required this.showMore,
    this.showPreview = false,
    this.textSanitizer,
  });

  /// Background of the menu, shared with its pointer.
  static Color colorOf(ColorScheme scheme, ChatMessageMenuStyle style) =>
      style == ChatMessageMenuStyle.bottomSheet
          ? scheme.surfaceContainerLow
          : scheme.surfaceContainer;

  /// Whether to show which message the menu is about, for bubbles too
  /// large to be lifted into focus.
  final bool showPreview;
  final ChatMessageMenuStyle style;
  final List<ChatMessageAction> actions;
  final List<String> emojis;
  final ChatMessage message;
  final String currentUserId;
  final ChatLocalizations l10n;
  final bool showMore;
  final String Function(String text)? textSanitizer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sheet = style == ChatMessageMenuStyle.bottomSheet;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sheet)
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        if (showPreview)
          Padding(
            key: const Key('chatx_menu_preview'),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.author.id == currentUserId
                            ? l10n.you
                            : message.author.displayName ?? l10n.someone,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: scheme.primary),
                      ),
                      Text(
                        _messagePreview(
                          message,
                          l10n,
                          sanitize: textSanitizer,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (emojis.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: _ReactionPicker(
              emojis: emojis,
              message: message,
              currentUserId: currentUserId,
              label: l10n.addReaction,
              showMore: showMore,
            ),
          ),
          if (actions.isNotEmpty) const Divider(height: 8),
        ],
        for (final action in actions)
          _MenuItem(
            action: action,
            dense: !sheet,
            onTap: () => Navigator.of(context).pop(action),
          ),
        if (sheet) SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
      ],
    );

    return Material(
      key: const Key('chatx_message_menu'),
      color: colorOf(scheme, style),
      elevation: 6,
      shadowColor: Colors.black54,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: sheet
            ? const BorderRadius.vertical(top: Radius.circular(28))
            : BorderRadius.circular(16),
      ),
      child: sheet
          ? SingleChildScrollView(child: content)
          : ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 200,
                maxWidth: math.max(280, emojis.length * 48.0 + 24),
              ),
              child: IntrinsicWidth(
                child: SingleChildScrollView(child: content),
              ),
            ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.action,
    required this.dense,
    required this.onTap,
  });

  final ChatMessageAction action;
  final bool dense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    final color = action.isDestructive ? error : null;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: dense ? 48 : 56),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dense ? 16 : 24),
          child: Row(
            children: [
              if (action.icon != null) ...[
                Icon(action.icon, size: dense ? 20 : 24, color: color),
                SizedBox(width: dense ? 12 : 20),
              ],
              Flexible(
                child: Text(
                  action.label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row of quick reactions. Pops the enclosing route with a
/// [_ReactionChoice].
class _ReactionPicker extends StatelessWidget {
  const _ReactionPicker({
    required this.emojis,
    required this.message,
    required this.currentUserId,
    required this.label,
    required this.showMore,
  });

  final bool showMore;
  final List<String> emojis;
  final ChatMessage message;
  final String currentUserId;
  final String label;

  @override
  Widget build(BuildContext context) {
    final selectedColor = ChatThemeData.of(context).reactionChipSelectedColor;
    return Semantics(
      label: label,
      container: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final emoji in emojis)
              _EmojiButton(
                key: Key('chatx_react_$emoji'),
                emoji: emoji,
                selected: message.reactions
                    .any((r) => r.emoji == emoji && r.hasUser(currentUserId)),
                selectedColor: selectedColor,
                onTap: () => Navigator.of(context).pop(_ReactionChoice(emoji)),
              ),
            if (showMore)
              Semantics(
                button: true,
                label: ChatLocalizations.of(context).moreReactions,
                excludeSemantics: true,
                child: InkResponse(
                  key: const Key('chatx_react_more'),
                  radius: 24,
                  onTap: () async {
                    final emoji = await showModalBottomSheet<String>(
                      context: context,
                      useSafeArea: true,
                      builder: (sheetContext) => SafeArea(
                        child: ChatEmojiPicker(
                          onSelected: (e) => Navigator.of(sheetContext).pop(e),
                        ),
                      ),
                    );
                    if (emoji != null && context.mounted) {
                      Navigator.of(context).pop(_ReactionChoice(emoji));
                    }
                  },
                  child: const SizedBox.square(
                    dimension: 48,
                    child: Icon(Icons.add_reaction_outlined),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmojiButton extends StatefulWidget {
  const _EmojiButton({
    super.key,
    required this.emoji,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  State<_EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<_EmojiButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.emoji,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 1.35 : 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.selected ? widget.selectedColor : null,
            ),
            child: Text(widget.emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }
}
