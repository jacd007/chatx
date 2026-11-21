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
Here is a quick summary of **chatx**:

1. Zero dependencies
2. Backend agnostic
3. Streaming-friendly

```dart
controller.appendText(id, token);
```

> Tip: call `completeStream` when the response ends.

Read more at https://github.com/jacd007/chatx''';

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _send(String text) {
    _controller.insert(
      TextMessage(
        id: newId(),
        author: me,
        createdAt: DateTime.now(),
        text: text,
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

    _subscription = _fakeTokens(_answer).listen(
      (token) => _controller.appendText(answerId, token),
      onDone: () => _controller.completeStream(answerId),
    );
  }

  /// Emits the text in small chunks after a "thinking" pause.
  Stream<String> _fakeTokens(String text) async* {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final tokens = RegExp(r'\S+\s*|\s+').allMatches(text);
    for (final token in tokens) {
      await Future<void>.delayed(const Duration(milliseconds: 35));
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
        onLinkTap: (uri) => showLink(context, uri),
        emptyStateBuilder: (context) => const Center(
          child: Text('Ask me anything ✨'),
        ),
      ),
    );
  }
}
