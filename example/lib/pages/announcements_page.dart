import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

/// A read-only channel: only admins post, everyone else reads, reacts and
/// saves messages.
class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  static const _team = ChatUser(id: 'team', name: 'chatx team');
  static final DateTime _start =
      DateTime.now().subtract(const Duration(hours: 3));

  late final ChatController _controller = ChatController(
    messages: [
      TextMessage(
        id: 'a1',
        author: _team,
        createdAt: _start,
        text: '# chatx 0.1 is here 🎉\nReplies, reactions, surveys, '
            'threads, voice notes and more.',
        reactions: const [
          ChatReaction(emoji: '🎉', userIds: ['ana', 'leo', 'sam']),
          ChatReaction(emoji: '❤️', userIds: ['me']),
        ],
      ),
      TextMessage(
        id: 'a2',
        author: _team,
        createdAt: _start.add(const Duration(hours: 1)),
        text: '**Maintenance window** tonight from 23:00 to 23:30.',
      ),
      TextMessage(
        id: 'a3',
        author: _team,
        createdAt: _start.add(const Duration(hours: 2)),
        text: 'Long-press a message to **save** it for later 🔖',
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
      appBar: AppBar(
        title: const ChatHeader(
          user: _team,
          title: 'Announcements',
          subtitle: 'Channel · 1,204 members',
        ),
      ),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        readOnly: true,
        showAvatars: false,
        onSendMessage: (_, __) {},
        enableSelection: false,
        onReactionSelected: (m, emoji) =>
            _controller.toggleReaction(m.id, emoji, me.id),
        onSaveMessage: (message, saved) => _controller.toggleSaved(message.id),
      ),
    );
  }
}
