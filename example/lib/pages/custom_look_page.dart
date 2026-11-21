import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

/// Shows how far chatx can be customized without forking it.
class CustomLookPage extends StatefulWidget {
  const CustomLookPage({super.key});

  @override
  State<CustomLookPage> createState() => _CustomLookPageState();
}

class _CustomLookPageState extends State<CustomLookPage> {
  late final ChatController _controller = ChatController(
    messages: [
      TextMessage(
        id: '1',
        author: ana,
        createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
        text: 'Look at this place 👇',
      ),
      CustomMessage(
        id: '2',
        author: ana,
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        type: 'location',
        payload: 'Lisbon, Portugal',
      ),
      TextMessage(
        id: '3',
        author: me,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        text: 'Wow! Long-press any message to see custom actions.',
        status: MessageStatus.read,
      ),
    ],
  );

  @override
  void dispose() {
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
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = ChatLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Custom look')),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        onSend: (outgoing) {
          if (outgoing case OutgoingText(:final text, :final replyTo)) {
            _send(text, replyTo);
          }
        },
        onLinkTap: (uri) => showLink(context, uri),
        // 1. Theme overrides. Unset values still follow the app theme.
        theme: ChatTheme(
          backgroundColor: scheme.surfaceContainerLowest,
          outgoingBubbleColor: scheme.tertiary,
          outgoingTextStyle: TextStyle(color: scheme.onTertiary),
          bubbleRadius: 8,
          bubbleGroupedRadius: 8,
          bubbleTail: ChatBubbleTail.top,
        ),
        // 2. Strings: change only what you need.
        localizations: l10n.copyWith(inputHint: 'Write something nice…'),
        builders: ChatBuilders(
          // 3. Render your own message types.
          customMessageBuilder: (context, message, details) => _LocationCard(
            place: message.payload! as String,
          ),
          // 4. Decorate the default bubble.
          bubbleBuilder: (context, details, bubble) {
            final message = details.message;
            if (message is TextMessage && message.text.contains('Wow')) {
              return Badge(label: const Text('★'), child: bubble);
            }
            return bubble;
          },
          // 5. Replace the input bar while reusing ChatInput.
          inputBuilder: (context, send, textController) => ChatInput(
            onSend: send,
            controller: textController,
            leading: IconButton(
              tooltip: 'Attach',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open your file picker here')),
              ),
            ),
          ),
        ),
        // 6. Long-press menu: keep the defaults and add your own entry.
        onDeleteMessage: (message) => _controller.remove(message.id),
        messageActionsBuilder: (context, message, defaults) => [
          ...defaults,
          ChatMessageAction(
            label: 'Pin',
            icon: Icons.push_pin_outlined,
            onSelected: (message) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pinned (demo)')),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.place});

  final String place;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.location_on,
                size: 40,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(place, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
