import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';
import 'thread_page.dart';

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
          thread: i == 9
              ? ChatThreadSummary(
                  replyCount: 3,
                  participants: const [sam, leo, me],
                  lastReplyAt: _daysAgo(1, 21),
                )
              : null,
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
      TextMessage(
        id: 'forwarded',
        author: leo,
        createdAt: _daysAgo(0, 11).add(const Duration(minutes: 20)),
        text: 'Rooftop rules: no glass bottles, music until 11 PM.',
        forwardedFrom: 'Building manager',
      ),
      TextMessage(
        id: 'drinks',
        author: me,
        createdAt: _daysAgo(0, 11).add(const Duration(minutes: 30)),
        text: 'Drinks are on me 🍹',
        status: MessageStatus.read,
        receipts: [
          ChatReadReceipt(user: ana, readAt: _daysAgo(0, 11)),
          ChatReadReceipt(user: leo, readAt: _daysAgo(0, 11)),
          ChatReadReceipt(user: sam, readAt: _daysAgo(0, 11)),
        ],
      ),
      EventMessage(
        id: 'event',
        author: leo,
        createdAt: _daysAgo(0, 11).add(const Duration(minutes: 40)),
        title: 'Rooftop meetup',
        startsAt: _now.add(const Duration(days: 3, hours: 4)),
        endsAt: _now.add(const Duration(days: 3, hours: 7)),
        location: 'Calle Mayor 12',
        rsvps: const {
          'ana': ChatRsvp.going,
          'leo': ChatRsvp.going,
          'sam': ChatRsvp.maybe,
        },
      ),
      TextMessage(
        id: 'pt',
        author: sam,
        createdAt: _daysAgo(0, 11).add(const Duration(minutes: 45)),
        text: 'Alguém pode levar gelo? Eu levo os copos 🧊',
      ),
      TextMessage(
        id: 'edited',
        author: me,
        createdAt: _daysAgo(0, 11).add(const Duration(minutes: 50)),
        text: 'I will bring **two** speakers 🔊',
        editedAt: _daysAgo(0, 11).add(const Duration(minutes: 52)),
        editHistory: [
          ChatEdit(
            text: 'I will bring a speaker',
            at: _daysAgo(0, 11).add(const Duration(minutes: 50)),
          ),
        ],
        status: MessageStatus.read,
      ),
      TextMessage(
        id: 'deleted',
        author: leo,
        createdAt: _daysAgo(0, 11).add(const Duration(minutes: 55)),
        text: 'removed',
        deletedAt: _daysAgo(0, 11).add(const Duration(minutes: 56)),
      ),
      SurveyMessage(
        id: 'survey',
        author: ana,
        createdAt: _daysAgo(0, 12),
        title: 'How was our last meetup?',
        description: 'Help us plan the next one. Takes 1 minute.',
        respondentIds: const ['leo', 'sam'],
        questions: const [
          RatingQuestion(id: 'overall', title: 'How did you like it?'),
          ChoiceQuestion(
            id: 'best',
            title: 'What did you enjoy most?',
            allowsMultipleAnswers: true,
            choices: [
              SurveyChoice(id: 'food', text: 'Food'),
              SurveyChoice(id: 'music', text: 'Music'),
              SurveyChoice(id: 'people', text: 'Meeting people'),
              SurveyChoice(id: 'venue', text: 'The venue'),
            ],
          ),
          NpsQuestion(
            id: 'nps',
            title: 'How likely are you to invite a friend?',
          ),
          TextQuestion(
            id: 'ideas',
            title: 'Ideas for next time?',
            isRequired: false,
          ),
        ],
      ),
      TextMessage(
        id: 'scheduled',
        author: me,
        createdAt: _daysAgo(0, 12).add(const Duration(minutes: 5)),
        text: 'Reminder: meetup starts in one hour! ⏰',
        scheduledFor: _now.add(const Duration(days: 3, hours: 3)),
      ),
    ],
  )..pin('launch');

  static const _translations = {
    'pt': 'Can someone bring ice? I will bring the cups 🧊',
  };

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
            : ChatHeader(
                user: const ChatUser(id: 'crew', name: 'Weekend crew'),
                memberCount: 4,
                controller: _controller,
              ),
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
        onDeleteForEveryone: (message) => _controller.markDeleted(message.id),
        onEditMessage: (message, text) =>
            _controller.editText(message.id, text),
        onRsvp: (event, rsvp) => _controller.setRsvp(event.id, me.id, rsvp),
        onTranslate: (message) async {
          await latency(500);
          return _translations[message.id] ?? '(translated) ${message.text}';
        },
        onSaveMessage: (message, saved) => _controller.toggleSaved(message.id),
        onReportMessage: (message) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Reported. Thanks!'))),
        onBlockUser: (user) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} blocked')),
        ),
        wordFilter: ChatWordFilter({'darn'}),
        onScheduleMessage: (text, at, replyTo) => _controller.insert(
          TextMessage(
            id: newId(),
            author: me,
            createdAt: DateTime.now(),
            text: text,
            replyToId: replyTo?.id,
            scheduledFor: at,
          ),
        ),
        onSendScheduledNow: (message) => _controller.update(
          message.copyWithMeta(
            clearScheduledFor: true,
            status: MessageStatus.sent,
          ),
        ),
        onThreadTap: (message) => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ThreadPage(root: message)),
        ),
        onSurveySubmit: (survey, response) {
          _controller.recordSurveyResponse(survey.id, me.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Thanks! ${response.answers.length} answers sent',
              ),
            ),
          );
        },
        onForwardMessages: (messages) =>
            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pick a chat to forward ${messages.length}'),
          ),
        ),
        onReactionSelected: (m, emoji) =>
            _controller.toggleReaction(m.id, emoji, me.id),
      ),
    );
  }
}
