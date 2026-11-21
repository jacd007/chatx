part of '../chat_view.dart';

/// Survey card inside a bubble.
class _SurveyContent extends StatelessWidget {
  const _SurveyContent({
    required this.state,
    required this.message,
    required this.textColor,
    required this.accent,
    required this.textStyle,
  });

  final _ChatViewState state;
  final SurveyMessage message;
  final Color textColor;
  final Color accent;
  final TextStyle textStyle;

  Future<void> _open(BuildContext context) async {
    final view = state.widget;
    final response = await Navigator.of(context).push<ChatSurveyResponse>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _SurveyFlow(survey: message),
      ),
    );
    if (response != null) {
      view._contentCallbacks.onSurveySubmit?.call(message, response);
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final answered = message.hasResponded(view.currentUser.id);
    final canAnswer = !answered &&
        !message.isClosed &&
        view._contentCallbacks.onSurveySubmit != null;
    final subtle = textColor.withValues(alpha: 0.7);
    final onAccent =
        accent.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    final String buttonLabel;
    final IconData buttonIcon;
    if (answered) {
      buttonLabel = l10n.surveyAnswered;
      buttonIcon = Icons.check_circle_rounded;
    } else if (message.isClosed) {
      buttonLabel = l10n.surveyClosed;
      buttonIcon = Icons.lock_outline_rounded;
    } else {
      buttonLabel = l10n.surveyAnswer;
      buttonIcon = Icons.edit_note_rounded;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_outlined, size: 18, color: accent),
            const SizedBox(width: 6),
            Text(
              l10n.survey.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          message.title,
          style: textStyle.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: (textStyle.fontSize ?? 16) * 1.1,
          ),
        ),
        if (message.description != null) ...[
          const SizedBox(height: 4),
          Text(message.description!, style: textStyle),
        ],
        const SizedBox(height: 8),
        Text(
          '${l10n.surveyQuestions(message.questions.length)} · '
          '${l10n.surveyResponses(message.respondentIds.length)}',
          style: textTheme.bodySmall?.copyWith(color: subtle),
        ),
        const SizedBox(height: 10),
        Material(
          key: Key('chatx_survey_${message.id}'),
          color: canAnswer ? accent : textColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: canAnswer ? () => _open(context) : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    buttonIcon,
                    size: 18,
                    color: canAnswer ? onAccent : subtle,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    buttonLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: canAnswer ? onAccent : subtle,
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

/// Full-screen, step-by-step survey form. Pops with a [ChatSurveyResponse].
class _SurveyFlow extends StatefulWidget {
  const _SurveyFlow({required this.survey});

  final SurveyMessage survey;

  @override
  State<_SurveyFlow> createState() => _SurveyFlowState();
}

class _SurveyFlowState extends State<_SurveyFlow> {
  final PageController _pages = PageController();
  final Map<String, Object> _answers = {};
  int _index = 0;

  List<SurveyQuestion> get _questions => widget.survey.questions;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  bool _isAnswered(SurveyQuestion question) {
    final answer = _answers[question.id];
    return switch (answer) {
      null => false,
      final List<String> choices => choices.isNotEmpty,
      final String text => text.trim().isNotEmpty,
      _ => true,
    };
  }

  void _go(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _index = index);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _pages.jumpToPage(index);
    } else {
      _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    final answers = <String, Object>{
      for (final question in _questions)
        if (_isAnswered(question))
          question.id: switch (_answers[question.id]!) {
            final String text => text.trim(),
            final other => other,
          },
    };
    Navigator.of(context).pop(
      ChatSurveyResponse(surveyId: widget.survey.id, answers: answers),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final question = _questions[_index];
    final last = _index == _questions.length - 1;
    final canContinue = !question.isRequired || _isAnswered(question);

    return Scaffold(
      key: const Key('chatx_survey_flow'),
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.survey.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: (_index + 1) / _questions.length),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, i) => _QuestionPage(
                  question: _questions[i],
                  step: l10n.surveyStep(i + 1, _questions.length),
                  answer: _answers[_questions[i].id],
                  onChanged: (value) => setState(() {
                    if (value == null) {
                      _answers.remove(_questions[i].id);
                    } else {
                      _answers[_questions[i].id] = value;
                    }
                  }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  if (_index > 0)
                    TextButton.icon(
                      key: const Key('chatx_survey_back'),
                      onPressed: () => _go(_index - 1),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(l10n.surveyBack),
                    ),
                  const Spacer(),
                  FilledButton.icon(
                    key: const Key('chatx_survey_next'),
                    onPressed: canContinue
                        ? (last ? _submit : () => _go(_index + 1))
                        : null,
                    icon: Icon(
                      last ? Icons.send_rounded : Icons.arrow_forward_rounded,
                    ),
                    label: Text(last ? l10n.surveySubmit : l10n.surveyNext),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.question,
    required this.step,
    required this.answer,
    required this.onChanged,
  });

  final SurveyQuestion question;
  final String step;
  final Object? answer;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final question = this.question;
    final l10n = ChatLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text(
          question.isRequired ? step : '$step · ${l10n.surveyOptional}',
          style: textTheme.labelLarge?.copyWith(color: scheme.primary),
        ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(question.title, style: textTheme.headlineSmall),
        ),
        if (question.description != null) ...[
          const SizedBox(height: 6),
          Text(
            question.description!,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 24),
        switch (question) {
          ChoiceQuestion() => _ChoiceInput(
              question: question,
              selected: (answer as List<String>?) ?? const [],
              onChanged: onChanged,
            ),
          RatingQuestion() => _RatingInput(
              question: question,
              value: answer as int?,
              onChanged: onChanged,
            ),
          NpsQuestion() => _NpsInput(
              question: question,
              value: answer as int?,
              onChanged: onChanged,
            ),
          TextQuestion() => _TextInput(
              question: question,
              value: answer as String?,
              onChanged: onChanged,
            ),
        },
      ],
    );
  }
}

class _ChoiceInput extends StatelessWidget {
  const _ChoiceInput({
    required this.question,
    required this.selected,
    required this.onChanged,
  });

  final ChoiceQuestion question;
  final List<String> selected;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final choice in question.choices)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Builder(
              builder: (context) {
                final isSelected = selected.contains(choice.id);
                return Material(
                  key: Key('chatx_survey_choice_${choice.id}'),
                  color: isSelected
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (question.allowsMultipleAnswers) {
                        final next = isSelected
                            ? [
                                for (final id in selected)
                                  if (id != choice.id) id,
                              ]
                            : [...selected, choice.id];
                        onChanged(next);
                      } else {
                        onChanged([choice.id]);
                      }
                    },
                    child: Semantics(
                      selected: isSelected,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 52),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Icon(
                                question.allowsMultipleAnswers
                                    ? (isSelected
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank)
                                    : (isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_unchecked_rounded),
                                color: isSelected
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(choice.text)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _RatingInput extends StatelessWidget {
  const _RatingInput({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final RatingQuestion question;
  final int? value;
  final ValueChanged<Object?> onChanged;

  static const _faces = ['😞', '🙁', '😐', '🙂', '😄'];

  String _face(int rating) {
    final index =
        ((rating - 1) * (_faces.length - 1) / (question.max - 1)).round();
    return _faces[index];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        for (var rating = 1; rating <= question.max; rating++)
          Semantics(
            button: true,
            selected: value == rating,
            label: '$rating / ${question.max}',
            excludeSemantics: true,
            child: InkResponse(
              key: Key('chatx_survey_rating_$rating'),
              radius: 28,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(rating);
              },
              child: SizedBox.square(
                dimension: 52,
                child: Center(
                  child: AnimatedScale(
                    scale: value == rating ? 1.25 : 1,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: question.style == RatingStyle.emoji
                        ? Opacity(
                            opacity: value == null || value == rating ? 1 : 0.4,
                            child: Text(
                              _face(rating),
                              style: const TextStyle(fontSize: 34),
                            ),
                          )
                        : Icon(
                            value != null && rating <= value!
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 40,
                            color: value != null && rating <= value!
                                ? const Color(0xFFF5A623)
                                : scheme.outline,
                          ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NpsInput extends StatelessWidget {
  const _NpsInput({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final NpsQuestion question;
  final int? value;
  final ValueChanged<Object?> onChanged;

  // Detractors (0-6), passives (7-8) and promoters (9-10).
  static Color _color(int score) {
    if (score <= 6) return const Color(0xFFE5484D);
    if (score <= 8) return const Color(0xFFF5A623);
    return const Color(0xFF2EB67D);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        );
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var score = 0; score <= 10; score++)
              Semantics(
                button: true,
                selected: value == score,
                label: '$score',
                excludeSemantics: true,
                child: Material(
                  key: Key('chatx_survey_nps_$score'),
                  color: value == score
                      ? _color(score)
                      : _color(score).withValues(alpha: 0.12),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onChanged(score);
                    },
                    child: SizedBox.square(
                      dimension: 48,
                      child: Center(
                        child: Text(
                          '$score',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color:
                                value == score ? Colors.white : _color(score),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(question.lowLabel ?? l10n.npsLow, style: small),
            Text(question.highLabel ?? l10n.npsHigh, style: small),
          ],
        ),
      ],
    );
  }
}

class _TextInput extends StatefulWidget {
  const _TextInput({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final TextQuestion question;
  final String? value;
  final ValueChanged<Object?> onChanged;

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final TextEditingController _text =
      TextEditingController(text: widget.value);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    return TextField(
      key: const Key('chatx_survey_text'),
      controller: _text,
      minLines: 4,
      maxLines: 8,
      maxLength: widget.question.maxLength,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (value) => widget.onChanged(value.isEmpty ? null : value),
      decoration: InputDecoration(
        hintText: widget.question.hint ?? l10n.surveyTextHint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
