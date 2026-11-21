import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';
import 'demo_chat.dart';

const _leo = ChatUser(id: 'leo', name: 'Leo');
const _sam = ChatUser(id: 'sam', name: 'Sam');

final messagingFeatures = FeatureGroup('Messaging', [
  FeatureDemo(
    title: 'Text and markdown',
    description: 'Bold, italic, code, lists, quotes, links and spoilers.',
    icon: Icons.text_fields,
    builder: (_) => DemoChat(
      title: 'Text and markdown',
      hint: 'Tap the spoiler to reveal it. Select text in the input to '
          'format it.',
      seed: () => [
        text(
          'm1',
          '**Bold**, _italic_, ~~strike~~ and `inline code`.\n\n'
              '> A quote\n\n'
              '- A list\n- With items\n\n'
              'A link: https://pub.dev/packages/chatx\n\n'
              'And a ||spoiler||.',
          minutesAgo: 3,
        ),
        text('m2', 'Emoji only messages are big: 🎉', author: me),
        text('m3', '🎉', author: me, minutesAgo: 1),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        onLinkTap: (uri) => showLink(context, uri),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Delivery status and retry',
    description: 'Sending, sent, delivered, read and failed with retry.',
    icon: Icons.done_all,
    builder: (_) => DemoChat(
      title: 'Delivery status',
      hint: 'Send a message and watch its ticks. Tap the failed one to '
          'retry.',
      seed: () => [
        text('s1', 'Read', author: me, minutesAgo: 4),
        text('s2', 'Delivered', author: me, minutesAgo: 3)
            .copyWithMeta(status: MessageStatus.delivered),
        text('s3', 'This one failed', author: me, minutesAgo: 2)
            .copyWithMeta(status: MessageStatus.failed),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) {
          if (o is! OutgoingText) return;
          final id = newId();
          c.insert(
            TextMessage(
              id: id,
              author: me,
              createdAt: DateTime.now(),
              text: o.text,
              status: MessageStatus.sending,
            ),
          );
          unawaited(_deliver(c, id));
        },
        onRetry: (m) {
          c.updateStatus(m.id, MessageStatus.sending);
          unawaited(_deliver(c, m.id));
        },
      ),
    ),
  ),
  FeatureDemo(
    title: 'Replies',
    description: 'Swipe a bubble to reply; tap a quote to jump to it.',
    icon: Icons.reply,
    builder: (_) => DemoChat(
      title: 'Replies',
      hint: 'Swipe a bubble to the side to reply. Tap the quote to scroll '
          'to the original.',
      seed: () => [
        text('r1', 'Lunch at noon?', minutesAgo: 30),
        for (var i = 0; i < 8; i++)
          text('f$i', 'Message $i',
              author: i.isEven ? me : ana, minutesAgo: 29 - i),
        text('r2', 'Sure!', author: me, replyToId: 'r1', minutesAgo: 2),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Reactions',
    description: 'Quick reactions, emoji picker and reaction chips.',
    icon: Icons.add_reaction_outlined,
    builder: (_) => DemoChat(
      title: 'Reactions',
      hint: 'Long press a bubble to react. Tap the reactions under a '
          'bubble to see them all and add or remove yours.',
      seed: () => [
        text(
          'x1',
          'We shipped 0.2.0!',
          minutesAgo: 4,
          reactions: const [
            ChatReaction(emoji: '🎉', userIds: ['ana', 'leo']),
            ChatReaction(emoji: '❤️', userIds: ['sam']),
          ],
        ),
        text(
          'x2',
          'Long-press a message to **save** it for later 🔖',
          minutesAgo: 2,
          reactions: const [
            ChatReaction(emoji: '🥳', userIds: ['ana']),
            ChatReaction(emoji: '👍', userIds: ['ana', 'leo', 'sam']),
            ChatReaction(emoji: '❤️', userIds: ['leo', 'me']),
            ChatReaction(emoji: '🙏', userIds: ['sam']),
            ChatReaction(emoji: '😁', userIds: ['ana']),
            ChatReaction(emoji: '🖖', userIds: ['leo']),
            ChatReaction(emoji: '👏', userIds: ['sam']),
            ChatReaction(emoji: '🏎️', userIds: ['ana']),
          ],
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        onReactionSelected: (m, emoji) => c.toggleReaction(m.id, emoji, me.id),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Message menu',
    description: 'Popup menu with quick reactions and custom actions.',
    icon: Icons.more_horiz,
    builder: (_) => DemoChat(
      title: 'Message menu',
      hint: 'Long press a bubble. The last entry is a custom action.',
      seed: () => [
        text('a1', 'Long press me', minutesAgo: 3),
        text('a2', 'Me too', author: me, minutesAgo: 2),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        messageMenuStyle: ChatMessageMenuStyle.popup,
        onReactionSelected: (m, emoji) => c.toggleReaction(m.id, emoji, me.id),
        messageActionsBuilder: (context, message, defaults) => [
          ...defaults,
          ChatMessageAction(
            label: 'Share',
            icon: Icons.share_outlined,
            onSelected: (m) => toast(context, 'Share ${m.id}'),
          ),
        ],
      ),
    ),
  ),
  FeatureDemo(
    title: 'Edit and delete',
    description: 'Edit your messages, see edit history, delete.',
    icon: Icons.edit_outlined,
    builder: (_) => DemoChat(
      title: 'Edit and delete',
      hint: 'Long press your message and choose Edit or Delete. Tap '
          '"edited" to see the history. Up arrow edits the last one.',
      seed: () => [
        text('e1', 'Helo everyone', author: me, minutesAgo: 3),
      ],
      onReady: (c) => c.editText('e1', 'Hello everyone'),
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        sendFeatures: const {ChatSendFeature.edit},
        onDeleteMessage: (m) => c.remove(m.id),
        moderation: ChatModerationOptions(
          onDeleteForEveryone: (m) => c.markDeleted(m.id),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Typing indicator',
    description: 'Who is typing, with animated dots.',
    icon: Icons.more_horiz_rounded,
    builder: (_) => DemoChat(
      title: 'Typing indicator',
      hint: 'Ana and Leo start typing, then Ana answers.',
      seed: () => [text('t1', 'Anyone around?', author: me, minutesAgo: 1)],
      onReady: (c) async {
        c
          ..setTyping(ana, isTyping: true)
          ..setTyping(_leo, isTyping: true);
        await latency(2500);
        c
          ..setTyping(_leo, isTyping: false)
          ..setTyping(ana, isTyping: false)
          ..insert(text('t2', 'Yes, here!', minutesAgo: 0));
      },
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Unread separator and dates',
    description: '"New messages" line, day labels and jump to date.',
    icon: Icons.mark_chat_unread_outlined,
    builder: (_) => DemoChat(
      title: 'Unread and dates',
      hint: 'The view opens at the first unread message. Tap a date label '
          'to jump to a day.',
      seed: () => [
        for (var i = 0; i < 30; i++)
          text('u$i', 'Message $i',
              author: i % 3 == 0 ? me : ana, minutesAgo: (30 - i) * 60 * 5),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        firstUnreadMessageId: 'u22',
      ),
    ),
  ),
  FeatureDemo(
    title: 'Infinite history',
    description: 'Older pages load while you scroll up.',
    icon: Icons.history,
    builder: (_) {
      var page = 0;
      return DemoChat(
        title: 'Infinite history',
        hint: 'Scroll up: three more pages load, then the history ends.',
        seed: () => [
          for (var i = 0; i < 20; i++)
            text('p0_$i', 'Recent $i',
                author: i.isEven ? me : ana, minutesAgo: 20 - i),
        ],
        view: (context, c) => ChatView(
          controller: c,
          currentUser: me,
          onSend: (o) => sendText(c, o),
          onLoadMore: () async {
            await latency(800);
            page++;
            final oldest = c.messages.first.createdAt;
            c.insertAll([
              for (var i = 0; i < 20; i++)
                TextMessage(
                  id: 'p${page}_$i',
                  author: i.isEven ? ana : me,
                  createdAt: oldest.subtract(Duration(minutes: 20 - i)),
                  text: 'Page $page, message $i',
                ),
            ]);
            return page < 3;
          },
        ),
      );
    },
  ),
  FeatureDemo(
    title: 'Search',
    description: 'Find messages and move between results.',
    icon: Icons.search,
    builder: (_) => const _SearchDemo(),
  ),
  FeatureDemo(
    title: 'Selection and forwarding',
    description: 'Select several messages to copy, delete or forward.',
    icon: Icons.checklist,
    builder: (_) => DemoChat(
      title: 'Selection',
      hint: 'Long press and choose Select, then tap more bubbles.',
      seed: () => [
        for (var i = 0; i < 6; i++)
          text('s$i', 'Message $i',
              author: i.isEven ? me : ana, minutesAgo: 6 - i),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        enableSelection: true,
        onDeleteMessage: (m) => c.remove(m.id),
        onForwardMessages: (list) =>
            toast(context, 'Forward ${list.length} messages'),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Pinned and saved',
    description: 'Pin messages to a banner and bookmark others.',
    icon: Icons.push_pin_outlined,
    builder: (_) => DemoChat(
      title: 'Pinned and saved',
      hint: 'Tap the banner to jump to a pin. Long press to pin or save.',
      seed: () => [
        text('k1', 'Meeting moved to 5 pm', minutesAgo: 20),
        for (var i = 0; i < 10; i++)
          text('k${i + 2}', 'Chat $i',
              author: i.isEven ? me : ana, minutesAgo: 19 - i),
      ],
      onReady: (c) => c.pin('k1'),
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        onPinMessage: (m, pinned) => pinned ? c.pin(m.id) : c.unpin(m.id),
        onSaveMessage: (m, saved) => c.toggleSaved(m.id),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Mentions',
    description: 'Type @ to mention someone; jump to unread mentions.',
    icon: Icons.alternate_email,
    builder: (_) => DemoChat(
      title: 'Mentions',
      hint: 'Type @ in the input. Mentions of you are highlighted.',
      seed: () => [
        text('n1', 'Hi @You, can you review this?', minutesAgo: 2),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        mentionableUsers: const [ana, _leo, _sam],
        onMentionTap: (u) => toast(context, 'Profile of ${u.name}'),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Threads',
    description: 'Reply counts under messages that open a thread.',
    icon: Icons.forum_outlined,
    builder: (_) => DemoChat(
      title: 'Threads',
      hint: 'Tap "3 replies" to open the thread.',
      seed: () => [
        TextMessage(
          id: 'h1',
          author: ana,
          createdAt: ago(10),
          text: 'Ideas for the offsite?',
          thread: ChatThreadSummary(
            replyCount: 3,
            lastReplyAt: ago(2),
            participants: const [_leo, _sam],
          ),
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        onThreadTap: (root) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DemoChat(
              title: 'Thread',
              hint: 'The root stays on top. Replies go below.',
              seed: () => [
                text('t1', 'A cabin', author: _leo, minutesAgo: 8),
                text('t2', 'Beach!', author: _sam, minutesAgo: 6),
                text('t3', 'Both?', author: _leo, minutesAgo: 2),
              ],
              view: (context, tc) => ChatView(
                controller: tc,
                currentUser: me,
                threadRoot: root,
                onSend: (o) => sendText(tc, o),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Read receipts and forwarding',
    description: '"Seen by" avatars and the Forwarded label.',
    icon: Icons.visibility_outlined,
    builder: (_) => DemoChat(
      title: 'Receipts',
      hint: 'Long press your message and choose Info to see who read it.',
      seed: () => [
        TextMessage(
          id: 'w1',
          author: ana,
          createdAt: ago(5),
          text: 'Release notes are out',
          forwardedFrom: 'Leo',
        ),
        TextMessage(
          id: 'w2',
          author: me,
          createdAt: ago(3),
          text: 'Thanks, reading now',
          status: MessageStatus.read,
          receipts: [
            ChatReadReceipt(user: ana, readAt: ago(2)),
            ChatReadReceipt(user: _leo, readAt: ago(1)),
          ],
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Disappearing messages',
    description: 'Messages that remove themselves when they expire.',
    icon: Icons.timer_outlined,
    builder: (_) => DemoChat(
      title: 'Disappearing',
      hint: 'The second message disappears after 15 seconds.',
      seed: () => [
        text('d1', 'This one stays', minutesAgo: 1),
        TextMessage(
          id: 'd2',
          author: ana,
          createdAt: DateTime.now(),
          text: 'Code: 4821',
          expiresAt: DateTime.now().add(const Duration(seconds: 15)),
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Scheduled messages',
    description: 'Long press send to schedule; send it now from the menu.',
    icon: Icons.schedule_send_outlined,
    builder: (_) => DemoChat(
      title: 'Scheduled',
      hint: 'Type something and long press the send button.',
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        sendFeatures: const {
          ChatSendFeature.schedule,
          ChatSendFeature.sendScheduledNow,
          ChatSendFeature.edit,
        },
        onDeleteMessage: (m) => c.remove(m.id),
      ),
    ),
  ),
]);

Future<void> _deliver(ChatController c, String id) async {
  await latency(700);
  final failed = (c.messageById(id) as TextMessage?)
          ?.text
          .toLowerCase()
          .contains('fail') ??
      false;
  if (failed) {
    c.updateStatus(id, MessageStatus.failed);
    return;
  }
  c.updateStatus(id, MessageStatus.sent);
  await latency(500);
  c.updateStatus(id, MessageStatus.delivered);
  await latency(900);
  c.updateStatus(id, MessageStatus.read);
}

class _SearchDemo extends StatefulWidget {
  const _SearchDemo();

  @override
  State<_SearchDemo> createState() => _SearchDemoState();
}

class _SearchDemoState extends State<_SearchDemo> {
  final controller = ChatController(
    messages: [
      for (var i = 0; i < 40; i++)
        text(
          'q$i',
          i % 7 == 0 ? 'Pizza night on Friday?' : 'Message $i',
          author: i.isEven ? me : ana,
          minutesAgo: 40 - i,
        ),
    ],
  );
  late final search = ChatSearchController(chatController: controller);

  @override
  void dispose() {
    search.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ChatSearchBar(controller: search)),
      body: ChatView(
        controller: controller,
        currentUser: me,
        searchController: search,
        onSend: (o) => sendText(controller, o),
      ),
    );
  }
}
