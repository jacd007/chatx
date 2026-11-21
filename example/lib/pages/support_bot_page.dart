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
          ChatQuickReply(label: 'Shop'),
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
    } else if (text == 'Shop') {
      _controller.insert(
        ProductMessage(
          id: newId(),
          author: bot,
          createdAt: DateTime.now(),
          text: 'Our **best sellers** this week:',
          products: const [
            ChatProduct(
              id: 'mug',
              title: 'Ocean mug',
              subtitle: 'Ceramic, 350 ml',
              price: '€14.90',
              imageUri: 'asset:ocean',
              actionLabel: 'Add to cart',
            ),
            ChatProduct(
              id: 'print',
              title: 'Forest print',
              subtitle: 'A3, matte paper',
              price: '€24.00',
              imageUri: 'asset:forest',
              actionLabel: 'Add to cart',
            ),
            ChatProduct(
              id: 'card',
              title: 'Gift card',
              subtitle: 'Any amount',
              price: 'from €10',
              imageUri: 'asset:card',
            ),
          ],
        ),
      );
      _controller.insert(
        TextMessage(
          id: newId(),
          author: bot,
          createdAt: DateTime.now(),
          text: 'Ready to check out?',
          quickReplies: const [
            ChatQuickReply(label: 'Billing'),
            ChatQuickReply(label: 'Keep browsing'),
          ],
        ),
      );
    } else if (text == 'Billing') {
      _controller.insert(
        PaymentMessage(
          id: newId(),
          author: bot,
          createdAt: DateTime.now(),
          amount: '€38.90',
          note: 'Order #4821 · 2 items',
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
        // One message every 5 seconds, to show slow mode.
        moderation: const ChatModerationOptions(
          slowMode: Duration(seconds: 5),
        ),
        onSend: (outgoing) {
          if (outgoing case OutgoingText(:final text)) _userSays(text);
        },
        builders: const ChatBuilders(imageProviderBuilder: demoImage),
        contentCallbacks: ChatContentCallbacks(
          onMessageButton: (message, button) => _userSays(button.label),
          onProductTap: (message, product) =>
              ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.title} added to cart')),
          ),
          onPaymentAction: (message, action) => _controller.update(
            message.copyWith(
              paymentStatus: action == ChatPaymentAction.pay
                  ? ChatPaymentStatus.paid
                  : ChatPaymentStatus.declined,
            ),
          ),
        ),
      ),
    );
  }
}
