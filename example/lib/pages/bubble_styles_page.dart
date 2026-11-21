import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

/// Live playground for the bubble shape: tail, radius, shadow and outline.
class BubbleStylesPage extends StatefulWidget {
  const BubbleStylesPage({super.key});

  @override
  State<BubbleStylesPage> createState() => _BubbleStylesPageState();
}

class _BubbleStylesPageState extends State<BubbleStylesPage> {
  ChatBubbleTail _tail = ChatBubbleTail.bottom;
  double _radius = 20;
  bool _shadow = false;
  bool _outline = false;

  late final ChatController _controller = ChatController(
    messages: [
      for (final (i, (author, text)) in const [
        (ana, 'Bubbles can have a tail at the bottom…'),
        (ana, '…or a nip at the top, or none at all.'),
        (me, 'And the radius, shadow and outline are all theme values.'),
        (me, 'Grouped bubbles keep their alignment ✨'),
        (ana, 'Try the controls below!'),
      ].indexed)
        TextMessage(
          id: 'b$i',
          author: author,
          createdAt: DateTime.now().add(Duration(seconds: i)),
          text: text,
          status: author == me ? MessageStatus.read : null,
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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Bubble styles')),
      body: Column(
        children: [
          Expanded(
            child: ChatView(
              controller: _controller,
              currentUser: me,
              inputEnabled: false,
              onSendMessage: (_, __) {},
              theme: ChatTheme(
                bubbleTail: _tail,
                bubbleRadius: _radius,
                bubbleGroupedRadius: _radius / 3,
                bubbleElevation: _shadow ? 2 : 0,
                incomingBubbleColor:
                    _shadow ? scheme.surfaceContainerLowest : null,
                incomingBubbleBorderSide: _outline
                    ? BorderSide(color: scheme.outlineVariant)
                    : BorderSide.none,
              ),
              inputBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<ChatBubbleTail>(
                    segments: const [
                      ButtonSegment(
                        value: ChatBubbleTail.bottom,
                        label: Text('Bottom'),
                      ),
                      ButtonSegment(
                        value: ChatBubbleTail.top,
                        label: Text('Top'),
                      ),
                      ButtonSegment(
                        value: ChatBubbleTail.none,
                        label: Text('None'),
                      ),
                    ],
                    selected: {_tail},
                    onSelectionChanged: (value) =>
                        setState(() => _tail = value.single),
                  ),
                  Row(
                    children: [
                      const Text('Radius'),
                      Expanded(
                        child: Slider(
                          value: _radius,
                          min: 4,
                          max: 28,
                          onChanged: (v) => setState(() => _radius = v),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Shadow'),
                        selected: _shadow,
                        onSelected: (v) => setState(() => _shadow = v),
                      ),
                      FilterChip(
                        label: const Text('Outline'),
                        selected: _outline,
                        onSelected: (v) => setState(() => _outline = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
