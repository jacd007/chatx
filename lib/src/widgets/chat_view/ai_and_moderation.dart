part of '../chat_view.dart';

/// State of the translation of one message.
@immutable
class _Translation {
  const _Translation(
      {this.text, this.failed = false, this.showOriginal = false});

  /// Translated text, or `null` while loading or after a failure.
  final String? text;
  final bool failed;
  final bool showOriginal;

  bool get loading => text == null && !failed;

  _Translation copyWith({bool? showOriginal}) => _Translation(
        text: text,
        failed: failed,
        showOriginal: showOriginal ?? this.showOriginal,
      );
}

extension _TranslationLogic on _ChatViewState {
  Future<void> _translate(TextMessage message) async {
    final onTranslate = widget.onTranslate;
    if (onTranslate == null) return;
    final current = _translations.value[message.id];
    if (current != null && current.text != null) {
      // Already translated: toggle between translation and original.
      _setTranslation(
        message.id,
        current.copyWith(showOriginal: !current.showOriginal),
      );
      return;
    }
    _setTranslation(message.id, const _Translation());
    try {
      final text = await onTranslate(message);
      if (!mounted) return;
      _setTranslation(message.id, _Translation(text: text));
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'chatx',
          context: ErrorDescription('while translating a message'),
        ),
      );
      if (mounted) {
        _setTranslation(message.id, const _Translation(failed: true));
      }
    }
  }

  void _setTranslation(String id, _Translation translation) {
    _translations.value = {..._translations.value, id: translation};
  }
}

/// Label under a translated message: "Translated · Show original".
class _TranslationBar extends StatelessWidget {
  const _TranslationBar({
    required this.translation,
    required this.color,
    required this.onToggle,
    required this.onRetry,
  });

  final _Translation translation;
  final Color color;
  final VoidCallback onToggle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        );
    final Widget content;
    if (translation.loading) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
          ),
          const SizedBox(width: 6),
          Text(l10n.translating, style: style),
        ],
      );
    } else if (translation.failed) {
      content = InkWell(
        onTap: onRetry,
        child: Text('${l10n.translationFailed} · ${l10n.retry}', style: style),
      );
    } else {
      content = InkWell(
        key: const Key('chatx_translation_toggle'),
        onTap: onToggle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate_rounded, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              translation.showOriginal
                  ? l10n.showTranslation
                  : '${l10n.translated} · ${l10n.showOriginal}',
              style: style,
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Semantics(liveRegion: true, child: content),
    );
  }
}

/// Copy, rate and regenerate under an AI answer.
class _AiActions extends StatelessWidget {
  const _AiActions({
    required this.state,
    required this.message,
    required this.canRegenerate,
  });

  final _ChatViewState state;
  final TextMessage message;
  final bool canRegenerate;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final color = ChatThemeData.of(context).typingIndicatorColor;
    final accent = ChatThemeData.of(context).outgoingBubbleColor;
    final feedback = message.feedback;
    final onFeedback = view.onFeedback;
    final onRegenerate = view.onRegenerate;

    Widget button({
      required Key key,
      required IconData icon,
      required String tooltip,
      required VoidCallback onPressed,
      bool selected = false,
    }) {
      return IconButton(
        key: key,
        tooltip: tooltip,
        isSelected: selected,
        iconSize: 18,
        color: selected ? accent : color,
        icon: Icon(icon),
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
      );
    }

    return Row(
      key: Key('chatx_ai_actions_${message.id}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.versions.isNotEmpty)
          _VersionSwitcher(state: state, message: message, color: color),
        button(
          key: Key('chatx_ai_copy_${message.id}'),
          icon: Icons.copy_rounded,
          tooltip: l10n.copy,
          onPressed: () {
            // Copies the version on screen.
            final index = state._versionIndex.value[message.id];
            final text = index != null && index < message.versions.length
                ? message.versions[index]
                : message.text;
            Clipboard.setData(ClipboardData(text: text));
          },
        ),
        if (onFeedback != null) ...[
          button(
            key: Key('chatx_ai_good_${message.id}'),
            icon: feedback == ChatFeedback.positive
                ? Icons.thumb_up_rounded
                : Icons.thumb_up_outlined,
            tooltip: l10n.goodResponse,
            selected: feedback == ChatFeedback.positive,
            onPressed: () => onFeedback(
              message,
              feedback == ChatFeedback.positive ? null : ChatFeedback.positive,
            ),
          ),
          button(
            key: Key('chatx_ai_bad_${message.id}'),
            icon: feedback == ChatFeedback.negative
                ? Icons.thumb_down_rounded
                : Icons.thumb_down_outlined,
            tooltip: l10n.badResponse,
            selected: feedback == ChatFeedback.negative,
            onPressed: () => onFeedback(
              message,
              feedback == ChatFeedback.negative ? null : ChatFeedback.negative,
            ),
          ),
        ],
        if (onRegenerate != null && canRegenerate)
          button(
            key: Key('chatx_ai_regenerate_${message.id}'),
            icon: Icons.refresh_rounded,
            tooltip: l10n.regenerate,
            onPressed: () => onRegenerate(message),
          ),
      ],
    );
  }
}

/// Placeholder content of a message deleted for everyone.
class _DeletedContent extends StatelessWidget {
  const _DeletedContent({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    return Row(
      key: const Key('chatx_deleted'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.block_rounded, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            l10n.messageDeleted,
            style: TextStyle(color: color, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}

/// Sheet with the current text and every previous version.
Future<void> _showEditHistory(BuildContext context, TextMessage message) {
  final l10n = ChatLocalizations.of(context);
  final material = MaterialLocalizations.of(context);
  String when(DateTime time) =>
      '${material.formatMediumDate(time.toLocal())} · ${_clock(context, time)}';
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
    ),
    builder: (sheetContext) {
      final textTheme = Theme.of(sheetContext).textTheme;
      final scheme = Theme.of(sheetContext).colorScheme;
      Widget version(String text, String label, {bool current = false}) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                current ? scheme.primaryContainer : scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelSmall),
              const SizedBox(height: 4),
              ChatText(text),
            ],
          ),
        );
      }

      return SafeArea(
        child: ListView(
          key: const Key('chatx_edit_history'),
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(l10n.editHistory, style: textTheme.titleLarge),
            ),
            version(
              message.text,
              '${l10n.currentVersion} · ${when(message.editedAt ?? message.createdAt)}',
              current: true,
            ),
            for (final edit in message.editHistory.reversed)
              version(edit.text, when(edit.at)),
          ],
        ),
      );
    },
  );
}

/// Sheet with quick scheduling options. Returns the chosen time.
Future<DateTime?> _pickScheduleTime(BuildContext context) async {
  final l10n = ChatLocalizations.of(context);
  final now = DateTime.now();
  final today = DateUtils.dateOnly(now);
  var tonight = today.add(const Duration(hours: 20));
  if (!tonight.isAfter(now)) tonight = tonight.add(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1, hours: 9));
  final options = [
    (l10n.inOneHour, now.add(const Duration(hours: 1)), Icons.timelapse),
    (l10n.tonight, tonight, Icons.nights_stay_outlined),
    (l10n.tomorrowMorning, tomorrow, Icons.wb_sunny_outlined),
  ];
  final choice = await showModalBottomSheet<Object>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.8,
    ),
    builder: (sheetContext) => SafeArea(
      child: ListView(
        key: const Key('chatx_schedule_sheet'),
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              l10n.scheduleMessage,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          for (final (label, time, icon) in options)
            ListTile(
              leading: Icon(icon),
              title: Text(label),
              subtitle: Text(
                '${MaterialLocalizations.of(sheetContext).formatMediumDate(time)}'
                ' · ${_clock(sheetContext, time)}',
              ),
              onTap: () => Navigator.of(sheetContext).pop(time),
            ),
          ListTile(
            key: const Key('chatx_schedule_custom'),
            leading: const Icon(Icons.edit_calendar_outlined),
            title: Text(l10n.pickDateTime),
            onTap: () => Navigator.of(sheetContext).pop('custom'),
          ),
        ],
      ),
    ),
  );
  if (choice is DateTime) return choice;
  if (choice != 'custom' || !context.mounted) return null;
  final date = await showDatePicker(
    context: context,
    firstDate: today,
    lastDate: today.add(const Duration(days: 365)),
    initialDate: today,
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
