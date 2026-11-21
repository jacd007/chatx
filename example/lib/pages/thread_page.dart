import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';
import 'community_page.dart';

/// A thread: another ChatView with the root message on top.
class ThreadPage extends StatefulWidget {
  const ThreadPage({super.key, required this.root});

  final ChatMessage root;

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  late final ChatController _controller = ChatController(
    messages: [
      TextMessage(
        id: 't1',
        author: sam,
        createdAt: widget.root.createdAt.add(const Duration(minutes: 3)),
        text: 'I have a portable one 🔊',
      ),
      TextMessage(
        id: 't2',
        author: leo,
        createdAt: widget.root.createdAt.add(const Duration(minutes: 7)),
        text: 'Perfect, bring the cable too',
        reactions: const [
          ChatReaction(emoji: '👍', userIds: ['sam']),
        ],
      ),
      TextMessage(
        id: 't3',
        author: me,
        createdAt: widget.root.createdAt.add(const Duration(minutes: 9)),
        text: 'I can bring a backup 🎧',
        status: MessageStatus.read,
      ),
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thread')),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        threadRoot: widget.root,
        onSendMessage: (text, replyTo) => _controller.insert(
          TextMessage(
            id: newId(),
            author: me,
            createdAt: DateTime.now(),
            text: text,
            status: MessageStatus.sent,
          ),
        ),
      ),
    );
  }
}
