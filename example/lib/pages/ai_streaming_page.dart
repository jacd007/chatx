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
    unawaited(_subscription?.cancel());

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

    _stream(answerId);
  }

  void _stream(String id) {
    unawaited(_subscription?.cancel());
    _subscription = _fakeTokens(_answer).listen(
      (token) => _controller.appendText(id, token),
      onDone: () => _controller.completeStream(id),
    );
  }

  /// Replaces the answer with a fresh, empty stream.
  void _regenerate(TextMessage message) {
    _controller.update(
      message.copyWith(text: '', isStreaming: true, clearFeedback: true),
    );
    _stream(message.id);
  }

  void _stop(TextMessage message) {
    unawaited(_subscription?.cancel());
    _controller.completeStream(message.id);
  }

  /// Emits the text in small chunks after a "thinking" pause.
  Stream<String> _fakeTokens(String text) async* {
    await Future<void>.delayed(const Duration(milliseconds: 900));
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
        onSendMessage: _send,
        showUserNames: false,
        onRegenerate: _regenerate,
        onStopGenerating: _stop,
        onFeedback: (message, feedback) => _controller.update(
          message.copyWith(feedback: feedback, clearFeedback: feedback == null),
        ),
        onLinkTap: (uri) => showLink(context, uri),
        emptyStateBuilder: (context) => const Center(
          child: Text('Ask me anything ✨'),
        ),
      ),
    );
  }
}
