import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';
import 'demo_chat.dart';

final aiFeatures = FeatureGroup('AI assistants', [
  FeatureDemo(
    title: 'Streaming answer',
    description: 'The answer streams token by token with a caret.',
    icon: Icons.stream,
    builder: (_) => DemoChat(
      title: 'Streaming answer',
      hint: 'Ask anything and watch the answer stream in.',
      view: (context, c) => _AiChat(
        controller: c,
        reply: (chat, prompt) async {
          final id = chat.startAnswer();
          await chat.stream(
            id,
            'You asked: _"$prompt"_.\n\n'
            'This answer arrives in small chunks, the way LLM APIs send '
            'tokens. Each chunk goes through `appendText`, which rebuilds '
            'only this bubble, and `completeStream` hides the caret at the '
            'end.',
          );
        },
      ),
    ),
  ),
  FeatureDemo(
    title: 'Stop generating',
    description: 'Stop a long answer while it streams.',
    icon: Icons.stop_circle_outlined,
    builder: (_) => DemoChat(
      title: 'Stop generating',
      hint: 'Send a message, then tap the stop button that replaces send.',
      view: (context, c) => _AiChat(
        controller: c,
        reply: (chat, prompt) async {
          final id = chat.startAnswer();
          await chat.stream(id, _longAnswer, tokenDelayMs: 60);
        },
        ai: (context, chat) => ChatAiOptions(
          onStopGenerating: (m) {
            chat.stop(m.id);
            toast(context, 'Generation stopped');
          },
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Reasoning, tools and sources',
    description: 'Thinking block, tool calls and source chips.',
    icon: Icons.psychology_outlined,
    builder: (_) => DemoChat(
      title: 'Reasoning and tools',
      hint: 'Send a message. Tap the reasoning block to expand it and a '
          'source chip to open it.',
      view: (context, c) => _AiChat(
        controller: c,
        reply: _answerWithSteps,
        ai: (context, chat) => ChatAiOptions(
          onSourceTap: (s) => toast(context, 'Open ${s.url}'),
          onStopGenerating: (m) => chat.stop(m.id),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Regenerate and versions',
    description: 'Ask for a new answer and page through the versions.',
    icon: Icons.refresh,
    builder: (_) => DemoChat(
      title: 'Regenerate',
      hint: 'Tap regenerate under the answer, then use ‹ 1/2 › to compare '
          'versions. Each keeps its own sources.',
      seed: () => [
        text('g1', 'How do I keep a Flutter list fast?', author: me),
        TextMessage(
          id: 'g2',
          author: bot,
          createdAt: ago(4),
          text: _versions[0].text,
          sources: _versions[0].sources,
        ),
      ],
      view: (context, c) => _AiChat(
        controller: c,
        reply: (chat, prompt) async {
          final id = chat.startAnswer();
          await chat.stream(id, _versions[0].text);
          chat.edit(id, (m) => m.copyWith(sources: _versions[0].sources));
        },
        ai: (context, chat) => ChatAiOptions(
          onStopGenerating: (m) => chat.stop(m.id),
          onRegenerate: (m) async {
            final next = _versions[(m.versions.length + 1) % _versions.length];
            chat.controller.startRegeneration(m.id);
            final done = await chat.stream(m.id, next.text);
            if (done) {
              chat.edit(m.id, (msg) => msg.copyWith(sources: next.sources));
            }
          },
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Rate answers',
    description: 'Thumbs up and down under bot answers.',
    icon: Icons.thumb_up_alt_outlined,
    builder: (_) => DemoChat(
      title: 'Rate answers',
      hint: 'Tap thumbs up or down. Tap it again to clear your rating.',
      seed: () => [
        text('f1', 'Give me a name for a coffee shop.', author: me),
        text('f2', 'How about **Bean There**?', author: bot, minutesAgo: 4),
      ],
      view: (context, c) => _AiChat(
        controller: c,
        reply: (chat, prompt) async {
          final id = chat.startAnswer();
          await chat.stream(id, 'Another idea: **Brew Haven**.');
        },
        ai: (context, chat) => ChatAiOptions(
          onFeedback: (m, feedback) {
            c.update(
              m.copyWith(feedback: feedback, clearFeedback: feedback == null),
            );
            toast(
              context,
              switch (feedback) {
                ChatFeedback.positive => 'Thanks for the feedback!',
                ChatFeedback.negative => 'Sorry, we will do better.',
                null => 'Rating cleared',
              },
            );
          },
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Suggested prompts',
    description: 'Prompt cards in an empty conversation.',
    icon: Icons.tips_and_updates_outlined,
    builder: (_) => DemoChat(
      title: 'Suggested prompts',
      hint: 'Tap a card to send it. The cards hide once the chat starts.',
      view: (context, c) => _AiChat(
        controller: c,
        reply: (chat, prompt) async {
          final id = chat.startAnswer();
          await chat.stream(id, _promptAnswers[prompt] ?? _fallbackAnswer);
        },
        ai: (context, chat) => ChatAiOptions(
          onStopGenerating: (m) => chat.stop(m.id),
          suggestedPrompts: const [
            ChatPrompt(
              title: 'Plan a trip',
              subtitle: 'to Lisbon in spring',
              icon: Icons.flight_takeoff,
            ),
            ChatPrompt(
              title: 'Write a haiku',
              subtitle: 'about Flutter',
              icon: Icons.edit_note,
            ),
            ChatPrompt(
              title: 'Explain streams',
              subtitle: 'like I am five',
              icon: Icons.school_outlined,
            ),
          ],
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Translation',
    description: 'Translate a message and switch back to the original.',
    icon: Icons.translate,
    builder: (_) => DemoChat(
      title: 'Translation',
      hint: 'Long press a message and choose Translate. Tap the label to '
          'see the original again.',
      seed: () => [
        text('l1', 'Where is the train station?', author: me, minutesAgo: 3),
        text(
          'l2',
          'Walk two blocks north and turn left at the bakery.',
          author: bot,
          minutesAgo: 2,
        ),
        text('l3', 'Thank you very much!', author: me, minutesAgo: 1),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        ai: ChatAiOptions(
          onTranslate: (m) async {
            await latency();
            return _spanish[m.text] ?? '(ES) ${m.text}';
          },
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Code and tables',
    description: 'Highlighted code blocks, tables and quotes.',
    icon: Icons.code,
    builder: (_) => DemoChat(
      title: 'Code and tables',
      hint: 'Tap the copy button on the code block. Scroll the table '
          'sideways if it is wide.',
      seed: () => [
        text('c1', 'Show me a debounce in Dart.', author: me, minutesAgo: 3),
        text('c2', _codeAnswer, author: bot, minutesAgo: 2),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        showUserNames: false,
        onLinkTap: (uri) => showLink(context, uri),
      ),
    ),
  ),
]);

/// What the fake model does with a prompt of the user.
typedef _Reply = Future<void> Function(_AiChatState chat, String prompt);

/// A [ChatView] with a fake model. Owns the running token stream and the
/// timers, so everything stops when the demo closes.
class _AiChat extends StatefulWidget {
  const _AiChat({required this.controller, required this.reply, this.ai});

  final ChatController controller;
  final _Reply reply;
  final ChatAiOptions Function(BuildContext context, _AiChatState chat)? ai;

  @override
  State<_AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<_AiChat> {
  StreamSubscription<String>? _subscription;
  Completer<bool>? _streaming;
  final Set<String> _stopped = {};

  ChatController get controller => widget.controller;

  @override
  void dispose() {
    _cancelStream();
    super.dispose();
  }

  /// Inserts an empty, streaming answer of the bot and returns its id.
  String startAnswer() {
    final id = newId();
    controller.insert(
      TextMessage(
        id: id,
        author: bot,
        createdAt: DateTime.now(),
        text: '',
        isStreaming: true,
      ),
    );
    return id;
  }

  /// Whether work on the answer [id] should go on.
  bool alive(String id) => mounted && !_stopped.contains(id);

  /// Waits [ms] and returns [alive].
  Future<bool> pause(String id, int ms) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    return alive(id);
  }

  /// Applies [change] to the text message [id], if it still exists.
  void edit(String id, TextMessage Function(TextMessage m) change) {
    if (!mounted) return;
    final message = controller.messageById(id);
    if (message is TextMessage) controller.update(change(message));
  }

  /// Streams [text] into the answer [id] and completes it. Returns false
  /// when the stream was stopped or the demo closed.
  Future<bool> stream(String id, String text, {int tokenDelayMs = 25}) {
    _cancelStream();
    _stopped.remove(id);
    final done = _streaming = Completer<bool>();
    _subscription = _fakeTokens(text, tokenDelayMs).listen(
      (token) => controller.appendText(id, token),
      onDone: () {
        controller.completeStream(id);
        if (!done.isCompleted) done.complete(true);
      },
    );
    return done.future;
  }

  /// Stops the answer [id] where it is.
  void stop(String id) {
    _stopped.add(id);
    _cancelStream();
    controller.completeStream(id);
  }

  void _cancelStream() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    final streaming = _streaming;
    if (streaming != null && !streaming.isCompleted) streaming.complete(false);
    _streaming = null;
  }

  @override
  Widget build(BuildContext context) {
    return ChatView(
      controller: controller,
      currentUser: me,
      showUserNames: false,
      onSend: (o) {
        sendText(controller, o);
        if (o is OutgoingText && o.scheduledFor == null) {
          unawaited(widget.reply(this, o.text));
        }
      },
      ai: widget.ai?.call(context, this) ??
          ChatAiOptions(onStopGenerating: (m) => stop(m.id)),
    );
  }
}

/// Emits [text] in word sized chunks after a short pause.
Stream<String> _fakeTokens(String text, int delayMs) async* {
  await Future<void>.delayed(const Duration(milliseconds: 300));
  for (final token in RegExp(r'\S+\s*|\s+').allMatches(text)) {
    await Future<void>.delayed(Duration(milliseconds: delayMs));
    yield token.group(0)!;
  }
}

/// Thinks, runs a tool, answers and cites sources.
Future<void> _answerWithSteps(_AiChatState chat, String prompt) async {
  final id = chat.startAnswer();
  final started = DateTime.now();
  const thoughts = 'The user asks about the weather in Lisbon. I should '
      'check a forecast service and summarize the next days.';
  var reasoning = '';
  for (final word in thoughts.split(' ')) {
    if (!await chat.pause(id, 60)) return;
    reasoning += '$word ';
    chat.edit(
      id,
      (m) => m.copyWith(
        reasoning: ChatReasoning(text: reasoning.trim(), isActive: true),
      ),
    );
  }
  chat.edit(
    id,
    (m) => m.copyWith(
      reasoning: ChatReasoning(
        text: reasoning.trim(),
        duration: DateTime.now().difference(started),
      ),
      toolCalls: const [
        ChatToolCall(
          id: 'weather',
          name: 'Checking the forecast',
          status: ChatToolStatus.running,
        ),
      ],
    ),
  );
  if (!await chat.pause(id, 1200)) return;
  chat.edit(
    id,
    (m) => m.copyWith(
      toolCalls: const [
        ChatToolCall(
          id: 'weather',
          name: 'Checked the forecast',
          detail: 'Found **3** days of data for Lisbon.',
        ),
      ],
    ),
  );
  final done = await chat.stream(
    id,
    'Lisbon looks **sunny** for the next three days, between 18 and 23 °C. '
    'Pack a light jacket for the evenings by the river.',
  );
  if (done) {
    chat.edit(
      id,
      (m) => m.copyWith(
        sources: const [
          ChatSource(
            title: 'Lisbon forecast',
            url: 'https://weather.example.com/lisbon',
            snippet: 'Sunny, 18 to 23 °C.',
          ),
          ChatSource(
            title: 'Visit Lisboa',
            url: 'https://visitlisboa.example.com',
          ),
        ],
      ),
    );
  }
}

const _longAnswer = 'Here is a long story so you have time to stop it. '
    'Once upon a time, a small widget lived at the bottom of a very tall '
    'tree. Every frame it rebuilt itself, carefully and quietly, hoping '
    'nobody would notice. One day a controller arrived and offered to '
    'update only the parts that changed. The widget was skeptical, but it '
    'tried, and the whole app suddenly ran at sixty frames per second. '
    'News spread through the tree. Soon every list used keys, every '
    'stream was cancelled on dispose and every animation used springs. '
    'The widget became famous, and it was asked to give talks at '
    'conferences all over the world, where it explained, again and again, '
    'that the secret was simply to do less work. The end.';

typedef _Version = ({String text, List<ChatSource> sources});

const List<_Version> _versions = [
  (
    text: 'Use `ListView.builder` so only visible rows are built, give rows '
        'a fixed `itemExtent` when you can and keep row widgets `const`.',
    sources: [
      ChatSource(
        title: 'ListView.builder',
        url: 'https://api.flutter.dev/flutter/widgets/ListView-class.html',
      ),
    ],
  ),
  (
    text: 'Profile first. Then:\n\n'
        '1. Build rows lazily.\n'
        '2. Cache and downsample images to the row size.\n'
        '3. Avoid `setState` high in the tree while scrolling.',
    sources: [
      ChatSource(
        title: 'Performance best practices',
        url: 'https://docs.flutter.dev/perf/best-practices',
      ),
      ChatSource(
        title: 'DevTools performance view',
        url: 'https://docs.flutter.dev/tools/devtools/performance',
      ),
    ],
  ),
  (
    text: 'In one line: lazy builders, `const` rows and small images.',
    sources: [
      ChatSource(
        title: 'Flutter performance FAQ',
        url: 'https://docs.flutter.dev/perf/faq',
      ),
    ],
  ),
];

const _promptAnswers = {
  'Plan a trip to Lisbon in spring': '**Day 1:** Alfama and the castle.\n'
      '**Day 2:** Belém and pastéis de nata.\n'
      '**Day 3:** A train to Sintra.',
  'Write a haiku about Flutter': '_Widgets in a tree_\n'
      '_one frame paints a thousand leaves_\n'
      '_hot reload, spring rain_',
  'Explain streams like I am five': 'A stream is like a water slide for '
      'data: things come down one at a time, and you wait at the bottom to '
      'catch each one.',
};

const _fallbackAnswer = 'Good question! This demo only knows the three '
    'suggested prompts, but a real model would answer anything.';

const _spanish = {
  'Where is the train station?': '¿Dónde está la estación de tren?',
  'Walk two blocks north and turn left at the bakery.':
      'Camina dos cuadras al norte y gira a la izquierda en la panadería.',
  'Thank you very much!': '¡Muchas gracias!',
};

const _codeAnswer = '''
Here is a small debouncer:

```dart
import 'dart:async';

class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}
```

| Delay | Good for |
|:--|--:|
| 150 ms | Search as you type |
| 300 ms | Form validation |
| 1000 ms | Autosave |

> Remember to call `dispose` when the widget goes away.''';
