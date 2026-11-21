import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

/// The recommended integration pattern, plus every conversation feature:
///
/// * Optimistic sending: insert with `MessageStatus.sending`, then update.
/// * Swipe a bubble to reply. Tap a bubble to open the popup menu.
/// * Reactions, editing and deleting from the menu.
/// * "New messages" separator and large emoji-only messages.
class BasicChatPage extends StatefulWidget {
  const BasicChatPage({super.key});

  @override
  State<BasicChatPage> createState() => _BasicChatPageState();
}

class _BasicChatPageState extends State<BasicChatPage> {
  static final DateTime _start =
      DateTime.now().subtract(const Duration(minutes: 30));

  late final ChatController _controller = ChatController(
    messages: [
      SystemMessage(
        id: 'welcome',
        createdAt: _start,
        text: 'Ana joined the conversation',
      ),
      TextMessage(
        id: 'm1',
        author: ana,
        createdAt: _start.add(const Duration(minutes: 1)),
        text: 'Hey! Are we still on for **Friday**? 🍕',
        reactions: const [
          ChatReaction(emoji: '🔥', userIds: ['me']),
        ],
      ),
      TextMessage(
        id: 'm2',
        author: me,
        createdAt: _start.add(const Duration(minutes: 3)),
        text: 'Of course! I booked a table at 8.',
        replyToId: 'm1',
        status: MessageStatus.read,
      ),
      TextMessage(
        id: 'm3',
        author: ana,
        createdAt: _start.add(const Duration(minutes: 20)),
        text: '🎉🥳',
      ),
      TextMessage(
        id: 'm4',
        author: ana,
        createdAt: _start.add(const Duration(minutes: 21)),
        text: 'Tip: **swipe** a bubble to reply, **tap** it for the menu. '
            'Messages containing "fail" are not delivered.',
        reactions: const [
          ChatReaction(emoji: '👍', userIds: ['ana', 'me']),
        ],
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

  void _send(String text, ChatMessage? replyTo) {
    final message = TextMessage(
      id: newId(),
      author: me,
      createdAt: DateTime.now(),
      text: text,
      replyToId: replyTo?.id,
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
      ..toggleReaction(message.id, '❤️', ana.id)
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
          text: 'Got it 👌',
          replyToId: message.id,
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
      appBar: AppBar(
        title: const Row(
          children: [
            ChatAvatar(user: ana, size: 36),
            SizedBox(width: 12),
            Text('Ana'),
          ],
        ),
      ),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        onSendMessage: _send,
        onRetry: _retry,
        onLinkTap: (uri) => showLink(context, uri),
        firstUnreadMessageId: 'm3',
        // Tap a bubble to open a popup menu anchored to it.
        messageMenuTrigger: ChatMessageMenuTrigger.tap,
        messageMenuStyle: ChatMessageMenuStyle.popup,
        // Swipe to reply is the default; shown here for clarity.
        swipeAction: const ChatSwipeAction.reply(),
        onReactionSelected: (message, emoji) =>
            _controller.toggleReaction(message.id, emoji, me.id),
        onEditMessage: (message, text) =>
            _controller.editText(message.id, text),
        onDeleteMessage: (message) => _controller.remove(message.id),
      ),
    );
  }
}
