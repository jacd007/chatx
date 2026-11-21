import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

const leo = ChatUser(id: 'leo', name: 'Leo Martín');
const sam = ChatUser(id: 'sam', name: 'Sam');

/// A group chat: polls, a pinned countdown, mentions, search and
/// multi-selection. Messages span several days to show the floating date.
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  static final DateTime _now = DateTime.now();
  static DateTime _daysAgo(int days, int hour) =>
      DateTime(_now.year, _now.month, _now.day - days, hour);

  late final ChatController _controller = ChatController(
    messages: [
      for (var i = 0; i < 12; i++)
        TextMessage(
          id: 'old$i',
          author: [ana, leo, sam, me][i % 4],
          createdAt: _daysAgo(3 - i ~/ 4, 10 + i),
          text: [
            'Morning everyone ☀️',
            'Who is bringing the speakers?',
            'I can, no problem',
            'Great, thanks!',
          ][i % 4],
          status: i % 4 == 3 ? MessageStatus.read : null,
        ),
      CountdownMessage(
        id: 'launch',
        author: ana,
        createdAt: _daysAgo(0, 9),
        title: 'Community meetup 🎉',
        endsAt: _now.add(const Duration(days: 3, hours: 4, minutes: 12)),
        description: 'Rooftop at **Calle Mayor 12**. Bring a friend!',
      ),
      PollMessage(
        id: 'poll',
        author: leo,
        createdAt: _daysAgo(0, 10),
        question: 'What should we eat?',
        options: const [
          PollOption(id: 'pizza', text: 'Pizza 🍕', voterIds: ['ana', 'sam']),
          PollOption(id: 'tacos', text: 'Tacos 🌮', voterIds: ['leo']),
          PollOption(id: 'sushi', text: 'Sushi 🍣'),
        ],
      ),
      TextMessage(
        id: 'mention',
        author: sam,
        createdAt: _daysAgo(0, 11),
        text: '@Ana can you book the rooftop? @You are on drinks 🍹',
      ),
    ],
  )..pin('launch');

  late final ChatSearchController _search =
      ChatSearchController(chatController: _controller);
  bool _searching = false;

  @override
  void dispose() {
    _search.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? ChatSearchBar(
                controller: _search,
                onClose: () => setState(() => _searching = false),
              )
            : const Text('Weekend crew'),
        actions: [
          if (!_searching)
            IconButton(
              key: const Key('demo_search'),
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searching = true),
            ),
        ],
      ),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        onSendMessage: _send,
        searchController: _search,
        mentionableUsers: const [ana, leo, sam, me],
        onMentionTap: (user) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open profile of ${user.name}')),
        ),
        onPollVote: (poll, option) =>
            _controller.votePoll(poll.id, option, me.id),
        onPinMessage: (message, pinned) => pinned
            ? _controller.pin(message.id)
            : _controller.unpin(message.id),
        onDeleteMessage: (message) => _controller.remove(message.id),
        onReactionSelected: (m, emoji) =>
            _controller.toggleReaction(m.id, emoji, me.id),
      ),
    );
  }
}
