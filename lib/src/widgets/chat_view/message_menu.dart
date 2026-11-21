part of '../chat_view.dart';

/// Result of the menu when the user picks a reaction.
class _ReactionChoice {
  const _ReactionChoice(this.emoji);
  final String emoji;
}

/// Shows the menu as a bottom sheet. Returns a [ChatMessageAction], a
/// [_ReactionChoice] or `null`.
Future<Object?> _showSheetMenu(
  BuildContext context, {
  required List<ChatMessageAction> actions,
  required List<String> emojis,
  required ChatMessage message,
  required String currentUserId,
  required ChatLocalizations l10n,
}) {
  return showModalBottomSheet<Object>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final error = Theme.of(sheetContext).colorScheme.error;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emojis.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _ReactionPicker(
                  emojis: emojis,
                  message: message,
                  currentUserId: currentUserId,
                  label: l10n.addReaction,
                ),
              ),
              if (actions.isNotEmpty) const Divider(height: 16),
            ],
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
                  style: action.isDestructive ? TextStyle(color: error) : null,
                ),
                onTap: () => Navigator.of(sheetContext).pop(action),
              ),
          ],
        ),
      );
    },
  );
}

/// Shows the menu as a popup anchored under the bubble of [anchor].
Future<Object?> _showPopupMenu(
  BuildContext anchor, {
  required List<ChatMessageAction> actions,
  required List<String> emojis,
  required ChatMessage message,
  required String currentUserId,
  required ChatLocalizations l10n,
}) {
  final box = anchor.findRenderObject()! as RenderBox;
  final overlay =
      Navigator.of(anchor).overlay!.context.findRenderObject()! as RenderBox;
  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final bubble = topLeft & box.size;
  // Open from the bottom edge of the bubble, on the author's side.
  final position = RelativeRect.fromRect(
    Rect.fromLTWH(bubble.left, bubble.bottom, bubble.width, 0),
    Offset.zero & overlay.size,
  );
  final error = Theme.of(anchor).colorScheme.error;

  return showMenu<Object>(
    context: anchor,
    position: position,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    // Wide enough for the reaction row; the default caps menus at 280.
    constraints: BoxConstraints(
      minWidth: 200,
      maxWidth: math.max(280, emojis.length * 48.0 + 24),
    ),
    items: [
      if (emojis.isNotEmpty)
        _ReactionMenuEntry(
          emojis: emojis,
          message: message,
          currentUserId: currentUserId,
          label: l10n.addReaction,
        ),
      if (emojis.isNotEmpty && actions.isNotEmpty) const PopupMenuDivider(),
      for (final action in actions)
        PopupMenuItem<Object>(
          value: action,
          child: Row(
            children: [
              if (action.icon != null) ...[
                Icon(
                  action.icon,
                  size: 20,
                  color: action.isDestructive ? error : null,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                action.label,
                style: action.isDestructive ? TextStyle(color: error) : null,
              ),
            ],
          ),
        ),
    ],
  );
}

class _ReactionMenuEntry extends PopupMenuEntry<Object> {
  const _ReactionMenuEntry({
    required this.emojis,
    required this.message,
    required this.currentUserId,
    required this.label,
  });

  final List<String> emojis;
  final ChatMessage message;
  final String currentUserId;
  final String label;

  @override
  double get height => 52;

  @override
  bool represents(Object? value) => false;

  @override
  State<_ReactionMenuEntry> createState() => _ReactionMenuEntryState();
}

class _ReactionMenuEntryState extends State<_ReactionMenuEntry> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: _ReactionPicker(
        emojis: widget.emojis,
        message: widget.message,
        currentUserId: widget.currentUserId,
        label: widget.label,
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
  });

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
