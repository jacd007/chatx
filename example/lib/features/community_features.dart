import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';
import 'demo_chat.dart';

const _leo = ChatUser(id: 'leo', name: 'Leo');
const _omar = ChatUser(id: 'omar', name: 'Omar', role: ChatRole.owner);
const _kai = ChatUser(id: 'kai', name: 'Kai', role: ChatRole.admin);
const _bea = ChatUser(id: 'bea', name: 'Bea', role: ChatRole.moderator);
const _lu = ChatUser(id: 'lu', name: 'Lu');
const _members = [_omar, _kai, _bea, _lu, me];

final communityFeatures = FeatureGroup('Groups and moderation', [
  FeatureDemo(
    title: 'Read-only channel',
    description: 'Only admins post; everyone else sees a banner.',
    icon: Icons.campaign_outlined,
    builder: (_) => DemoChat(
      title: 'Announcements',
      hint: 'The input is replaced by a banner. Reactions still work.',
      seed: () => [
        text('a1', 'Welcome to the announcements channel 👋',
            author: _omar, minutesAgo: 60),
        text('a2', 'Version 0.2.0 is out. Read the release notes!',
            author: _omar, minutesAgo: 5),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        onReactionSelected: (m, emoji) => c.toggleReaction(m.id, emoji, me.id),
        moderation: const ChatModerationOptions(
          readOnly: true,
          readOnlyMessage: 'Only admins can post in this channel',
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Slow mode',
    description: 'One message every 10 seconds, with a countdown.',
    icon: Icons.hourglass_bottom,
    builder: (_) => DemoChat(
      title: 'Slow mode',
      hint: 'Send a message: the input waits 10 seconds before the next one.',
      seed: () => [
        text('w1', 'Slow mode is on to keep things calm.',
            author: _bea, minutesAgo: 3),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        moderation: const ChatModerationOptions(
          slowMode: Duration(seconds: 10),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Report and block',
    description: 'Report a message or block its author from the menu.',
    icon: Icons.flag_outlined,
    builder: (_) => DemoChat(
      title: 'Report and block',
      hint: 'Long press a message from Leo and choose Report or Block.',
      seed: () => [
        text('r1', 'Buy cheap followers at spam.example!',
            author: _leo, minutesAgo: 4),
        text('r2', 'Please stop posting that.', author: ana, minutesAgo: 2),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        moderation: ChatModerationOptions(
          onReportMessage: (m) => toast(
              context, 'Reported message from ${m.author.name ?? 'someone'}'),
          onBlockUser: (u) => toast(context, '${u.name ?? 'User'} blocked'),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Word filter',
    description: 'Offensive words are masked in every message.',
    icon: Icons.filter_alt_outlined,
    builder: (_) => DemoChat(
      title: 'Word filter',
      hint: 'Filtered words: "darn" and "heck". Try sending one.',
      seed: () => [
        text('f1', 'This darn build failed again', author: _leo, minutesAgo: 3),
        text('f2', 'What the heck happened?', author: ana, minutesAgo: 2),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        moderation: ChatModerationOptions(
          wordFilter: ChatWordFilter({'darn', 'heck'}),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Delete for everyone',
    description: 'Replace your message with a "deleted" placeholder.',
    icon: Icons.delete_sweep_outlined,
    builder: (_) => DemoChat(
      title: 'Delete for everyone',
      hint: 'Long press your message and choose Delete for everyone.',
      seed: () => [
        text('d1', 'Oops, wrong chat', author: me, minutesAgo: 2),
        text('d2', 'Haha, saw that', author: ana, minutesAgo: 1),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        onDeleteMessage: (m) => c.remove(m.id),
        moderation: ChatModerationOptions(
          onDeleteForEveryone: (m) => c.markDeleted(m.id),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Roles, members and profile',
    description: 'Owner, admin and moderator badges, member list, profiles.',
    icon: Icons.groups_outlined,
    builder: (context) => DemoChat(
      title: 'Roles and members',
      hint: 'Tap the header or the people icon for members. Tap an avatar '
          'for the profile.',
      actions: [
        Builder(
          builder: (context) => IconButton(
            key: const Key('demo_members'),
            tooltip: 'Members',
            icon: const Icon(Icons.people_outline),
            onPressed: () => _showMembers(context),
          ),
        ),
      ],
      seed: () => [
        SystemMessage(id: 's0', createdAt: ago(60), text: 'Omar created Atlas'),
        text('m1', 'Welcome, everyone!', author: _omar, minutesAgo: 50),
        text('m2', 'I set up the CI.', author: _kai, minutesAgo: 30),
        text('m3', 'Please keep threads on topic 🙏',
            author: _bea, minutesAgo: 20),
        text('m4', 'Hi all!', author: _lu, minutesAgo: 10),
      ],
      view: (context, c) => Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ChatHeader(
                user: const ChatUser(id: 'atlas', name: 'Project Atlas'),
                memberCount: _members.length,
                controller: c,
                onTap: () => _showMembers(context),
              ),
            ),
          ),
          Expanded(
            child: ChatView(
              controller: c,
              currentUser: me,
              onSend: (o) => sendText(c, o),
              onAvatarTap: (u) => _showProfile(context, u),
            ),
          ),
        ],
      ),
    ),
  ),
  FeatureDemo(
    title: 'Offline queue',
    description: 'Messages wait while offline and send on reconnect.',
    icon: Icons.cloud_off_outlined,
    builder: (_) => const _OfflineDemo(),
  ),
  FeatureDemo(
    title: 'Hover actions',
    description: 'Reply, react and more on mouse hover (desktop and web).',
    icon: Icons.mouse_outlined,
    builder: (_) => DemoChat(
      title: 'Hover actions',
      hint: 'Needs a mouse: hover a bubble on desktop or web to see Reply, '
          'React and More.',
      seed: () => [
        text('h1', 'Hover me with the mouse', minutesAgo: 3),
        text('h2', 'Me too', author: me, minutesAgo: 2),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        showHoverActions: true,
        onDeleteMessage: (m) => c.remove(m.id),
        onReactionSelected: (m, emoji) => c.toggleReaction(m.id, emoji, me.id),
      ),
    ),
  ),
]);

void _showMembers(BuildContext context) {
  unawaited(
    ChatMemberList.show(
      context,
      members: _members,
      onlineIds: const {'bea', 'kai'},
      onTap: (u) => _showProfile(context, u),
    ),
  );
}

void _showProfile(BuildContext context, ChatUser user) {
  unawaited(
    ChatUserProfile.show(
      context,
      user: user,
      subtitle: user.id == 'bea' ? 'online' : 'last seen today',
      actions: [
        ChatProfileAction(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Message',
          onPressed: () => toast(context, 'Message ${user.name ?? 'user'}'),
        ),
        ChatProfileAction(
          icon: Icons.block_rounded,
          label: 'Block',
          isDestructive: true,
          onPressed: () => toast(context, '${user.name ?? 'user'} blocked'),
        ),
      ],
    ),
  );
}

class _OfflineDemo extends StatefulWidget {
  const _OfflineDemo();

  @override
  State<_OfflineDemo> createState() => _OfflineDemoState();
}

class _OfflineDemoState extends State<_OfflineDemo> {
  bool _online = false;

  void _send(ChatController c, ChatOutgoing o) {
    if (_online || o is! OutgoingText) {
      sendText(c, o);
      return;
    }
    c.insert(
      TextMessage(
        id: newId(),
        author: me,
        createdAt: DateTime.now(),
        text: o.text,
        replyToId: o.replyTo?.id,
        status: MessageStatus.queued,
      ),
    );
  }

  Future<void> _flush(ChatController c, List<ChatMessage> queued) async {
    for (final m in queued) {
      c.updateStatus(m.id, MessageStatus.sending);
    }
    await latency(700);
    for (final m in queued) {
      c.updateStatus(m.id, MessageStatus.sent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoChat(
      title: 'Offline queue',
      hint: 'You start offline. Send a few messages, then flip the switch '
          'to go online and watch them send.',
      actions: [
        Icon(_online ? Icons.wifi_rounded : Icons.wifi_off_rounded),
        Switch(
          key: const Key('demo_online'),
          value: _online,
          onChanged: (v) => setState(() => _online = v),
        ),
      ],
      seed: () => [
        text('o1', 'Ping me when you are back online', minutesAgo: 4),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => _send(c, o),
        connectionState:
            _online ? ChatConnectionState.online : ChatConnectionState.offline,
        onSendQueued: (queued) => unawaited(_flush(c, queued)),
      ),
    );
  }
}
