import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

/// The recommended integration pattern:
///
/// 1. Insert the message right away with `MessageStatus.sending`.
/// 2. Send it to the backend.
/// 3. Update its status when the backend answers.
class BasicChatPage extends StatefulWidget {
  const BasicChatPage({super.key});

  @override
  State<BasicChatPage> createState() => _BasicChatPageState();
}

class _BasicChatPageState extends State<BasicChatPage> {
  late final ChatController _controller = ChatController(
    messages: [
      SystemMessage(
        id: 'welcome',
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        text: 'Ana joined the conversation',
      ),
      TextMessage(
        id: 'hello',
        author: ana,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        text: 'Hi! Send me anything and I will answer. '
            'Messages containing **fail** will not be delivered.',
      ),
    ],
  );

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }

  void _send(String text) {
    final message = TextMessage(
      id: newId(),
      author: me,
      createdAt: DateTime.now(),
      text: text,
      status: MessageStatus.sending,
    );
    _controller.insert(message);
    unawaited(_deliver(message));
  }

  Future<void> _deliver(TextMessage message) async {
    await latency();
    if (_disposed) return;
    if (message.text.toLowerCase().contains('fail')) {
      _controller.updateStatus(message.id, MessageStatus.failed);
      return;
    }
    _controller.updateStatus(message.id, MessageStatus.sent);
    await latency(400);
    if (_disposed) return;
    _controller.updateStatus(message.id, MessageStatus.delivered);
    unawaited(_reply(message));
  }

  Future<void> _reply(TextMessage message) async {
    await latency(500);
    if (_disposed) return;
    _controller
      ..updateStatus(message.id, MessageStatus.read)
      ..setTyping(ana, isTyping: true);
    await latency(1200);
    if (_disposed) return;
    _controller
      ..setTyping(ana, isTyping: false)
      ..insert(
        TextMessage(
          id: newId(),
          author: ana,
          createdAt: DateTime.now(),
          text: 'You said: _${message.text}_',
        ),
      );
  }

  void _retry(ChatMessage message) {
    if (message is! TextMessage) return;
    final retried = message.copyWith(
      text: message.text.replaceAll(RegExp('fail', caseSensitive: false), ''),
      status: MessageStatus.sending,
    );
    _controller.update(retried);
    unawaited(_deliver(retried));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana')),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        onSendMessage: _send,
        onRetry: _retry,
        onLinkTap: (uri) => showLink(context, uri),
      ),
    );
  }
}
