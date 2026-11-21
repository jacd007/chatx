import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

/// Streams an answer chunk by chunk, the way LLM APIs deliver tokens.
///
/// `appendText` only rebuilds the bubble being streamed, so long answers stay
/// smooth even in long conversations.
class AiStreamingPage extends StatefulWidget {
  const AiStreamingPage({super.key});

  @override
  State<AiStreamingPage> createState() => _AiStreamingPageState();
}

class _AiStreamingPageState extends State<AiStreamingPage> {
  final ChatController _controller = ChatController();
  StreamSubscription<String>? _subscription;
  final Set<String> _stopped = {};

  static const _answer = '''
Here is how to stream an answer with **chatx**:

```dart
final id = uuid();
controller.insert(TextMessage(
  id: id,
  author: assistant,
  createdAt: DateTime.now(),
  text: '',
  isStreaming: true,
));
await for (final token in llm.stream(prompt)) {
  controller.appendText(id, token); // 60 fps
}
controller.completeStream(id);
```

| Feature | Cost |
|:--|--:|
| Zero dependencies | 0 KB |
| Rebuilds per token | 1 bubble |

> Tip: rate the answer or regenerate it below.''';

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // A shorter answer for "Regenerate", so the versions differ.
  static const _shortAnswer =
      'In short: insert an empty `TextMessage` with `isStreaming: true`, '
      'call `appendText` for every token and `completeStream` at the end. '
      'Only that bubble rebuilds.';

  static const _shortSources = [
    ChatSource(
      title: 'Streaming answers',
      url: 'https://pub.dev/packages/chatx',
    ),
  ];

  static const _sources = [
    ChatSource(
      title: 'ChatController API',
      url: 'https://pub.dev/documentation/chatx/latest/',
      snippet: 'appendText updates only the streaming bubble.',
    ),
    ChatSource(
      title: 'Streaming in Flutter',
      url: 'https://docs.flutter.dev/cookbook',
    ),
  ];

  void _send(String text, ChatMessage? replyTo) {
    _controller.insert(
      TextMessage(
        id: newId(),
        author: me,
        createdAt: DateTime.now(),
        text: text,
        replyToId: replyTo?.id,
        status: MessageStatus.sent,
      ),
    );
    final answerId = newId();
    _controller.insert(
      TextMessage(
        id: answerId,
        author: bot,
        createdAt: DateTime.now(),
        text: '',
        isStreaming: true,
      ),
    );
    unawaited(_answerWithSteps(answerId));
  }

  /// Simulates a model that thinks, searches the docs, then answers.
  Future<void> _answerWithSteps(String id) async {
    unawaited(_subscription?.cancel());
    TextMessage current() => _controller.messageById(id)! as TextMessage;
    final started = DateTime.now();
    const thoughts = 'The user wants a summary. I should show how to '
        'stream tokens and mention that only one bubble rebuilds.';
    var reasoning = '';
    for (final word in thoughts.split(' ')) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted || _stopped.contains(id)) return;
      reasoning += '$word ';
      _controller.update(
        current().copyWith(
          reasoning: ChatReasoning(text: reasoning.trim(), isActive: true),
        ),
      );
    }
    _controller.update(
      current().copyWith(
        reasoning: ChatReasoning(
          text: reasoning.trim(),
          duration:
              DateTime.now().difference(started) + const Duration(seconds: 3),
        ),
        toolCalls: const [
          ChatToolCall(
            id: 'docs',
            name: 'Searching the chatx docs',
            status: ChatToolStatus.running,
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted || _stopped.contains(id)) return;
    _controller.update(
      current().copyWith(
        toolCalls: const [
          ChatToolCall(
            id: 'docs',
            name: 'Searched the chatx docs',
            detail: 'Found **2** relevant pages.',
          ),
        ],
      ),
    );
    _stream(id);
  }

  void _stream(
    String id, {
    String text = _answer,
    List<ChatSource> sources = _sources,
  }) {
    unawaited(_subscription?.cancel());
    _subscription = _fakeTokens(text).listen(
      (token) => _controller.appendText(id, token),
      onDone: () {
        final message = _controller.messageById(id);
        if (message is TextMessage) {
          _controller.update(message.copyWith(sources: sources));
        }
        _controller.completeStream(id);
      },
    );
  }

  /// Keeps the old answer, with its reasoning, tools and sources, as a
  /// version and streams a new one.
  void _regenerate(TextMessage message) {
    _controller.startRegeneration(message.id);
    _stream(message.id, text: _shortAnswer, sources: _shortSources);
  }

  void _stop(TextMessage message) {
    _stopped.add(message.id);
    unawaited(_subscription?.cancel());
    _controller.completeStream(message.id);
  }

  /// Emits the text in small chunks after a short pause.
  Stream<String> _fakeTokens(String text) async* {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final tokens = RegExp(r'\S+\s*|\s+').allMatches(text);
    for (final token in tokens) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      yield token.group(0)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant')),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        onSend: (outgoing) {
          if (outgoing case OutgoingText(:final text, :final replyTo)) {
            _send(text, replyTo);
          }
        },
        showUserNames: false,
        onLinkTap: (uri) => showLink(context, uri),
        ai: ChatAiOptions(
          onRegenerate: _regenerate,
          onStopGenerating: _stop,
          onFeedback: (message, feedback) => _controller.update(
            message.copyWith(
              feedback: feedback,
              clearFeedback: feedback == null,
            ),
          ),
          suggestedPrompts: const [
            ChatPrompt(
              title: 'Summarize chatx',
              subtitle: 'in a few lines',
              icon: Icons.auto_awesome_outlined,
            ),
            ChatPrompt(
              title: 'Write Dart code',
              subtitle: 'to stream an answer',
              icon: Icons.code_rounded,
            ),
            ChatPrompt(
              title: 'Compare plans',
              subtitle: 'in a table',
              icon: Icons.table_chart_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
