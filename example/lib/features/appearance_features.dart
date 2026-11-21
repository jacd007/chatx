import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';
import 'demo_chat.dart';

const _leo = ChatUser(id: 'leo', name: 'Leo');

List<ChatMessage> _conversation() => [
      text('c1', 'Did you see the new design?', minutesAgo: 12),
      text('c2', 'Yes! The colors are **so** much better.',
          author: me, minutesAgo: 10),
      text('c3', 'And the bubbles feel lighter ✨', minutesAgo: 8),
      text('c4', 'Ship it 🚀', author: me, minutesAgo: 6),
    ];

final appearanceFeatures = FeatureGroup('Appearance', [
  FeatureDemo(
    title: 'Dark mode',
    description: 'chatx follows the app theme, light or dark.',
    icon: Icons.dark_mode_outlined,
    builder: (_) => Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
      ),
      child: DemoChat(
        title: 'Dark mode',
        hint: 'This demo forces a dark theme, whatever the system uses.',
        seed: _conversation,
        view: (context, c) => ChatView(
          controller: c,
          currentUser: me,
          onSend: (o) => sendText(c, o),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Bubble styles',
    description: 'Tail at the bottom, at the top or none, and the radius.',
    icon: Icons.chat_bubble_outline,
    builder: (_) => const _BubbleStylesDemo(),
  ),
  FeatureDemo(
    title: 'Custom colors and fonts',
    description: 'Override colors and text styles with ChatTheme.',
    icon: Icons.palette_outlined,
    builder: (_) => DemoChat(
      title: 'Custom theme',
      hint: 'Warm bubbles, a serif body font and a custom send button.',
      seed: _conversation,
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        theme: const ChatTheme(
          backgroundColor: Color(0xFFFFF8F0),
          outgoingBubbleColor: Color(0xFFD9480F),
          incomingBubbleColor: Color(0xFFFFE8CC),
          outgoingTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'serif',
            fontSize: 16,
          ),
          incomingTextStyle: TextStyle(
            color: Color(0xFF5C2B00),
            fontFamily: 'serif',
            fontSize: 16,
          ),
          userNameTextStyle: TextStyle(
            color: Color(0xFFD9480F),
            fontWeight: FontWeight.w700,
          ),
          timestampTextStyle: TextStyle(
            color: Color(0xFF8A6A50),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
          inputBackgroundColor: Color(0xFFFFF8F0),
          inputFieldColor: Color(0xFFFFE8CC),
          sendButtonColor: Color(0xFFD9480F),
          sendButtonIconColor: Colors.white,
          readStatusColor: Color(0xFFFFD8A8),
          bubbleRadius: 14,
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Builders',
    description: 'Replace avatars, day labels, typing, scroll button, empty.',
    icon: Icons.widgets_outlined,
    builder: (_) {
      ChatController? chat;
      return DemoChat(
        title: 'Builders',
        hint: 'Square avatars, pill day labels and a custom typing line. '
            'Scroll up for the custom button; clear the chat for the empty '
            'state.',
        actions: [
          IconButton(
            key: const Key('demo_clear'),
            tooltip: 'Clear chat',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => chat?.clear(),
          ),
        ],
        seed: () => [
          for (var i = 0; i < 24; i++)
            text('b$i', 'Message $i',
                author: i.isEven ? ana : (i % 3 == 0 ? _leo : me),
                minutesAgo: (24 - i) * 90),
        ],
        onReady: (c) {
          chat = c;
          c.setTyping(ana, isTyping: true);
        },
        view: (context, c) => ChatView(
          controller: c,
          currentUser: me,
          onSend: (o) => sendText(c, o),
          builders: ChatBuilders(
            avatarBuilder: (context, user) => _SquareAvatar(user: user),
            dateSeparatorBuilder: (context, day) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Chip(
                  avatar: const Icon(Icons.calendar_today, size: 14),
                  label: Text('${day.day}/${day.month}/${day.year}'),
                ),
              ),
            ),
            typingIndicatorBuilder: (context, users) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                '✍️ ${users.map((u) => u.name ?? 'Someone').join(', ')} '
                '${users.length == 1 ? 'is' : 'are'} writing…',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            scrollToBottomBuilder: (context, unread, scrollToBottom) =>
                FloatingActionButton.extended(
              heroTag: null,
              onPressed: scrollToBottom,
              icon: const Icon(Icons.arrow_downward),
              label: Text(unread > 0 ? '$unread new' : 'Latest'),
            ),
            emptyStateBuilder: (context) => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.forum_outlined, size: 64),
                  SizedBox(height: 12),
                  Text('Nothing here yet. Start the conversation!'),
                ],
              ),
            ),
          ),
        ),
      );
    },
  ),
  FeatureDemo(
    title: 'Languages',
    description: 'Built-in English, Spanish, Portuguese, French, German.',
    icon: Icons.translate,
    builder: (_) => const _LanguagesDemo(),
  ),
  FeatureDemo(
    title: 'Large text',
    description: 'Layouts that hold up at 200% font size.',
    icon: Icons.format_size,
    builder: (_) => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(2),
        ),
        child: DemoChat(
          title: 'Large text',
          hint: 'Text is scaled to 200%, like the largest system setting.',
          seed: _conversation,
          view: (context, c) => ChatView(
            controller: c,
            currentUser: me,
            onSend: (o) => sendText(c, o),
          ),
        ),
      ),
    ),
  ),
]);

class _SquareAvatar extends StatelessWidget {
  const _SquareAvatar({required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = user.name ?? '';
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        name.isEmpty ? '?' : name.characters.first,
        style: TextStyle(
          color: scheme.onTertiaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BubbleStylesDemo extends StatefulWidget {
  const _BubbleStylesDemo();

  @override
  State<_BubbleStylesDemo> createState() => _BubbleStylesDemoState();
}

class _BubbleStylesDemoState extends State<_BubbleStylesDemo> {
  ChatBubbleTail _tail = ChatBubbleTail.bottom;
  double _radius = 18;

  @override
  Widget build(BuildContext context) {
    return DemoChat(
      title: 'Bubble styles',
      hint: 'Pick a tail and drag the slider to change the radius.',
      seed: _conversation,
      view: (context, c) => Column(
        children: [
          Expanded(
            child: ChatView(
              controller: c,
              currentUser: me,
              onSend: (o) => sendText(c, o),
              theme: ChatTheme(
                bubbleTail: _tail,
                bubbleRadius: _radius,
                bubbleGroupedRadius: _radius / 3,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<ChatBubbleTail>(
                    key: const Key('demo_tail'),
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
                          key: const Key('demo_radius'),
                          value: _radius,
                          min: 4,
                          max: 28,
                          label: _radius.round().toString(),
                          divisions: 24,
                          onChanged: (v) => setState(() => _radius = v),
                        ),
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

/// A partial translation: every string not given here falls back to
/// English.
const _italian = ChatLocalizations(
  inputHint: 'Messaggio',
  sendButton: 'Invia',
  today: 'Oggi',
  yesterday: 'Ieri',
  edited: 'modificato',
  you: 'Tu',
);

const _languages = {
  'English': ChatLocalizations.en,
  'Español': ChatLocalizations.es,
  'Português': ChatLocalizations.pt,
  'Français': ChatLocalizations.fr,
  'Deutsch': ChatLocalizations.de,
  'Italiano (partial)': _italian,
};

class _LanguagesDemo extends StatefulWidget {
  const _LanguagesDemo();

  @override
  State<_LanguagesDemo> createState() => _LanguagesDemoState();
}

class _LanguagesDemoState extends State<_LanguagesDemo> {
  String _language = 'Español';

  @override
  Widget build(BuildContext context) {
    return DemoChat(
      title: 'Languages',
      hint: 'Pick a language in the top bar. Italian only translates a few '
          'strings; the rest falls back to English. Long press a bubble to '
          'see the menu.',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: DropdownButton<String>(
            key: const Key('demo_language'),
            value: _language,
            underline: const SizedBox.shrink(),
            items: [
              for (final name in _languages.keys)
                DropdownMenuItem(value: name, child: Text(name)),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _language = v);
            },
          ),
        ),
      ],
      seed: () => [
        text('l1', 'Hola! Bonjour! Hallo!', minutesAgo: 60 * 26),
        text('l2', 'Olá!', author: me, minutesAgo: 3),
      ],
      onReady: (c) => c.setTyping(ana, isTyping: true),
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        localizations: _languages[_language],
      ),
    );
  }
}
