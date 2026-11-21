import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

/// A support bot: buttons inside messages, quick replies above the input
/// and a disappearing verification code.
class SupportBotPage extends StatefulWidget {
  const SupportBotPage({super.key});

  @override
  State<SupportBotPage> createState() => _SupportBotPageState();
}

class _SupportBotPageState extends State<SupportBotPage> {
  late final ChatController _controller = ChatController(
    messages: [_welcome()],
  );
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }

  static TextMessage _welcome() => TextMessage(
        id: newId(),
        author: bot,
        createdAt: DateTime.now(),
        text: 'Hi! I am **Assistant**. How can I help you today?',
        buttons: const [
          ChatMessageButton(
            id: 'track',
            label: '📦 Track my order',
            style: ChatButtonStyle.primary,
          ),
          ChatMessageButton(id: 'return', label: '↩️ Start a return'),
        ],
        quickReplies: const [
          ChatQuickReply(label: 'Billing'),
          ChatQuickReply(label: 'Shipping'),
          ChatQuickReply(label: 'Talk to a human'),
        ],
      );

  void _userSays(String text) {
    _controller.insert(
      TextMessage(
        id: newId(),
        author: me,
        createdAt: DateTime.now(),
        text: text,
        status: MessageStatus.read,
      ),
    );
    unawaited(_answer(text));
  }

  Future<void> _answer(String text) async {
    _controller.setTyping(bot, isTyping: true);
    await latency(600);
    if (_disposed) return;
    _controller.setTyping(bot, isTyping: false);
    final lower = text.toLowerCase();
    if (lower.contains('track')) {
      _controller.insert(
        TextMessage(
          id: newId(),
          author: bot,
          createdAt: DateTime.now(),
          text: 'Your order **#4821** is on its way 🚚 and arrives '
              '*tomorrow*. To confirm it is you, use this code:',
        ),
      );
      _controller.insert(
        TextMessage(
          id: newId(),
          author: bot,
          createdAt: DateTime.now(),
          text: '🔐 **739 102**',
          expiresAt: DateTime.now().add(const Duration(minutes: 2)),
          quickReplies: const [
            ChatQuickReply(label: 'Thanks! 🙏', value: 'Thanks!'),
            ChatQuickReply(label: 'Change address'),
          ],
        ),
      );
    } else if (lower.contains('human')) {
      _controller.insert(
        SystemMessage(
          id: newId(),
          createdAt: DateTime.now(),
          text: 'Ana from support joined the conversation',
        ),
      );
    } else {
      _controller.insert(
        TextMessage(
          id: newId(),
          author: bot,
          createdAt: DateTime.now(),
          text: 'Got it: _${text}_. Anything else?',
          quickReplies: const [
            ChatQuickReply(label: 'Track my order'),
            ChatQuickReply(label: 'Talk to a human'),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ChatHeader(
          user: bot,
          isOnline: true,
          controller: _controller,
        ),
      ),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        showUserNames: false,
        onSendMessage: (text, _) => _userSays(text),
        onMessageButton: (message, button) => _userSays(button.label),
      ),
    );
  }
}
