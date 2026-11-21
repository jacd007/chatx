part of '../chat_view.dart';

/// Pinned messages banner above the list. Tapping jumps to the shown pin
/// and then cycles to the previous one.
class _PinnedBanner extends StatefulWidget {
  const _PinnedBanner({required this.state});

  final _ChatViewState state;

  @override
  State<_PinnedBanner> createState() => _PinnedBannerState();
}

class _PinnedBannerState extends State<_PinnedBanner> {
  /// Index from the newest pin backwards.
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.state.widget.controller;
    return ListenableBuilder(
      listenable: Listenable.merge([controller.pinnedIds, controller]),
      builder: (context, _) {
        final pins = controller.pinnedIds.value;
        final Widget content;
        if (pins.isEmpty) {
          content = const SizedBox(width: double.infinity);
        } else {
          final position = pins.length - 1 - (_offset % pins.length);
          final message = controller.messageById(pins[position]);
          content = message == null
              ? const SizedBox(width: double.infinity)
              : _banner(context, message, position, pins.length);
        }
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: content,
        );
      },
    );
  }

  Widget _banner(
    BuildContext context,
    ChatMessage message,
    int position,
    int count,
  ) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final accent = theme.outgoingBubbleColor;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      key: const Key('chatx_pinned_banner'),
      color: theme.inputBackgroundColor,
      child: InkWell(
        onTap: () {
          widget.state.widget.controller.scrollToMessage(message.id);
          if (count > 1) setState(() => _offset++);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 16, 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: scheme.outlineVariant, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // One segment per pin; the active one is solid.
              SizedBox(
                width: 3,
                height: 38,
                child: Column(
                  children: [
                    for (var i = 0; i < math.min(count, 4); i++) ...[
                      if (i > 0) const SizedBox(height: 2),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: accent.withValues(
                              alpha: i == position % 4 ? 1 : 0.3,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count > 1
                          ? '${l10n.pinnedMessage} #${position + 1}'
                          : l10n.pinnedMessage,
                      style: theme.userNameTextStyle.copyWith(color: accent),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _messagePreview(message, l10n),
                        key: ValueKey(message.id),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.systemMessageTextStyle.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.push_pin_outlined, size: 20, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

/// Date chip that floats at the top of the list while scrolling.
class _FloatingDate extends StatelessWidget {
  const _FloatingDate({required this.date, this.onTap});

  final ValueListenable<DateTime?> date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: date,
      builder: (context, day, _) => IgnorePointer(
        ignoring: day == null,
        child: AnimatedOpacity(
          opacity: day == null ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          child: Center(
            child: day == null
                ? const SizedBox.shrink()
                : Material(
                    key: const Key('chatx_floating_date'),
                    elevation: 2,
                    color: Colors.transparent,
                    shape: const StadiumBorder(),
                    child: _DateChip(day: day, onTap: onTap),
                  ),
          ),
        ),
      ),
    );
  }
}

extension _FloatingDateLogic on _ChatViewState {
  /// Shows the date of the topmost visible message while the user scrolls,
  /// and hides it shortly after scrolling stops.
  void _updateFloatingDate(ScrollNotification notification) {
    // Only user scrolling shows the date. Programmatic jumps, such as
    // sticking to the newest message, do not.
    if (!_userScrolling) return;
    if (notification is ScrollEndNotification) {
      _floatingDateTimer?.cancel();
      // Long enough to tap the chip and jump to another date.
      _floatingDateTimer = Timer(const Duration(milliseconds: 1600), () {
        if (mounted) _floatingDate.value = null;
      });
      return;
    }
    if (notification is! ScrollUpdateNotification) return;
    final list = _listKey.currentContext?.findRenderObject();
    if (list is! RenderBox || !list.hasSize) return;
    final top = list.localToGlobal(Offset.zero).dy;

    String? topmostId;
    var topmostY = double.infinity;
    for (final MapEntry(key: id, value: rowContext) in _rowContexts.entries) {
      if (!rowContext.mounted) continue;
      final box = rowContext.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final y = box.localToGlobal(Offset.zero).dy;
      if (y + box.size.height <= top + 8) continue;
      if (y < topmostY) {
        topmostY = y;
        topmostId = id;
      }
    }
    final message =
        topmostId == null ? null : widget.controller.messageById(topmostId);
    if (message == null) return;
    _floatingDateTimer?.cancel();
    _floatingDate.value = DateUtils.dateOnly(message.createdAt.toLocal());
  }
}

/// Replaces the input while messages are selected.
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({super.key, required this.state});

  final _ChatViewState state;

  List<ChatSelectionAction> _defaults(
    List<ChatMessage> selected,
    ChatLocalizations l10n,
  ) {
    final view = state.widget;
    final texts = [
      for (final m in selected)
        if (m is TextMessage) m.text,
    ];
    final allMine = selected.every(state._isOutgoing);
    return [
      if (texts.isNotEmpty)
        ChatSelectionAction(
          label: l10n.copy,
          icon: Icons.copy_rounded,
          onSelected: (_) =>
              Clipboard.setData(ClipboardData(text: texts.join('\n\n'))),
        ),
      if (view.onForwardMessages != null)
        ChatSelectionAction(
          label: l10n.forward,
          icon: Icons.shortcut_rounded,
          onSelected: view.onForwardMessages!,
        ),
      if (allMine && view.onDeleteMessage != null)
        ChatSelectionAction(
          label: l10n.delete,
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onSelected: (messages) => messages.forEach(view.onDeleteMessage!),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final controller = view.controller;
    final l10n = ChatLocalizations.of(context);
    final selected = controller.selectedMessages;
    final defaults = _defaults(selected, l10n);
    final actions =
        view.selectionActionsBuilder?.call(context, selected, defaults) ??
            defaults;
    final error = Theme.of(context).colorScheme.error;
    return Semantics(
      key: const Key('chatx_selection_bar'),
      container: true,
      liveRegion: true,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            const SizedBox(width: 4),
            IconButton(
              key: const Key('chatx_selection_close'),
              tooltip: l10n.cancel,
              icon: const Icon(Icons.close_rounded),
              onPressed: controller.clearSelection,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  l10n.selectedCount(selected.length),
                  key: ValueKey(selected.length),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            for (final (i, action) in actions.indexed)
              IconButton(
                key: Key('chatx_selection_action_$i'),
                tooltip: action.label,
                color: action.isDestructive ? error : null,
                icon: Icon(action.icon),
                onPressed: () {
                  action.onSelected(controller.selectedMessages);
                  controller.clearSelection();
                },
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

/// The `@query` being typed and the users that match it.
class _MentionQuery {
  const _MentionQuery({
    required this.start,
    required this.end,
    required this.users,
  });

  final int start;
  final int end;
  final List<ChatUser> users;
}

extension _MentionLogic on _ChatViewState {
  void _onComposerTextChanged() {
    if (widget.mentionableUsers.isEmpty) return;
    final value = _textController.value;
    final cursor = value.selection.baseOffset;
    if (!value.selection.isCollapsed || cursor < 0) {
      _mentionQuery.value = null;
      return;
    }
    final before = value.text.substring(0, cursor);
    final at = before.lastIndexOf('@');
    final query = at == -1 ? null : before.substring(at + 1);
    final validStart = at == 0 || (at > 0 && before[at - 1].trim().isEmpty);
    if (query == null ||
        !validStart ||
        query.contains('\n') ||
        query.length > 30) {
      _mentionQuery.value = null;
      return;
    }
    final needle = query.toLowerCase();
    final users = [
      for (final user in widget.mentionableUsers)
        if (user.id != widget.currentUser.id &&
            (user.name ?? '').isNotEmpty &&
            (user.name!.toLowerCase().startsWith(needle) ||
                user.name!.toLowerCase().contains(' $needle')))
          user,
    ];
    _mentionQuery.value = users.isEmpty
        ? null
        : _MentionQuery(start: at, end: cursor, users: users.take(5).toList());
  }

  void _insertMention(ChatUser user) {
    final query = _mentionQuery.value;
    if (query == null) return;
    final text = _textController.text;
    final insert = '@${user.name} ';
    final updated = text.replaceRange(query.start, query.end, insert);
    _textController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: query.start + insert.length),
    );
    _mentionQuery.value = null;
    _focusNode.requestFocus();
  }
}

/// Suggestions shown above the input while typing `@name`.
class _MentionSuggestions extends StatelessWidget {
  const _MentionSuggestions({required this.state});

  final _ChatViewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    return ValueListenableBuilder<_MentionQuery?>(
      valueListenable: state._mentionQuery,
      builder: (context, query, _) => AnimatedSize(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomCenter,
        child: query == null
            ? const SizedBox(width: double.infinity)
            : Semantics(
                key: const Key('chatx_mention_suggestions'),
                container: true,
                label: l10n.mentionSuggestions,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 1),
                    for (final user in query.users)
                      ListTile(
                        key: Key('chatx_mention_${user.id}'),
                        dense: true,
                        leading: ChatAvatar(user: user, size: 32),
                        title: Text(user.name!),
                        onTap: () => state._insertMention(user),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
