import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

const _omar = ChatUser(id: 'omar', name: 'Omar', role: ChatRole.owner);
const _bea = ChatUser(id: 'bea', name: 'Bea', role: ChatRole.moderator);
const _kai = ChatUser(id: 'kai', name: 'Kai', role: ChatRole.admin);
const _lu = ChatUser(id: 'lu', name: 'Lu');

/// A team chat: roles, member list, profiles, media gallery, a shared
/// checklist, call log, unread mentions and an offline queue.
class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  static final DateTime _start =
      DateTime.now().subtract(const Duration(hours: 5));

  static DateTime _at(int minutes) => _start.add(Duration(minutes: minutes));

  late final ChatController _controller = ChatController(
    messages: [
      SystemMessage(id: 's', createdAt: _at(0), text: 'Omar created Atlas'),
      TextMessage(
        id: 'k1',
        author: _omar,
        createdAt: _at(1),
        text: 'Kickoff notes: https://example.com/atlas ☕',
      ),
      ChecklistMessage(
        id: 'check',
        author: _bea,
        createdAt: _at(5),
        title: 'Launch checklist',
        items: const [
          ChecklistItem(id: 'a', text: 'Freeze the API', doneBy: 'kai'),
          ChecklistItem(id: 'b', text: 'Write release notes', doneBy: 'bea'),
          ChecklistItem(id: 'c', text: 'Record the demo video'),
          ChecklistItem(id: 'd', text: 'Ship to TestFlight'),
        ],
      ),
      CallMessage(
        id: 'call1',
        author: _omar,
        createdAt: _at(20),
        kind: ChatCallKind.video,
        duration: const Duration(minutes: 32, seconds: 10),
      ),
      ImageMessage(
        id: 'shots',
        author: _kai,
        createdAt: _at(60),
        images: const [
          ChatImage(uri: 'asset:ocean'),
          ChatImage(uri: 'asset:forest'),
        ],
        caption: 'New onboarding screens',
      ),
      FileMessage(
        id: 'spec',
        author: _kai,
        createdAt: _at(61),
        name: 'atlas-spec.pdf',
        sizeBytes: 1840000,
      ),
      TextMessage(
        id: 'u1',
        author: _lu,
        createdAt: _at(120),
        text: 'Morning! Build 42 is up 🚀',
      ),
      for (var i = 0; i < 9; i++)
        TextMessage(
          id: 'chat$i',
          author: i.isEven ? _kai : _lu,
          createdAt: _at(124 + i * 6),
          text: const [
            'Tests are green on CI ✅',
            'I updated the icons',
            'Design review at 3?',
            'Works for me',
            'Pushing the fix now',
            'Nice, thanks!',
            'Lunch at the usual place?',
            'Yes! 🍜',
            'I will book a table for six',
          ][i],
        ),
      TextMessage(
        id: 'u2',
        author: _bea,
        createdAt: _at(190),
        text: '@You can you review the onboarding PR before lunch?',
      ),
      CallMessage(
        id: 'call2',
        author: _bea,
        createdAt: _at(200),
        outcome: ChatCallOutcome.missed,
      ),
    ],
  );

  bool _online = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send(String text, ChatMessage? replyTo) {
    final message = TextMessage(
      id: newId(),
      author: me,
      createdAt: DateTime.now(),
      text: text,
      replyToId: replyTo?.id,
      status: _online ? MessageStatus.sending : MessageStatus.queued,
    );
    _controller.insert(message);
    if (_online) unawaited(_deliver([message]));
  }

  Future<void> _deliver(List<ChatMessage> messages) async {
    for (final message in messages) {
      _controller.updateStatus(message.id, MessageStatus.sending);
    }
    await latency(500);
    if (!mounted) return;
    for (final message in messages) {
      _controller.updateStatus(message.id, MessageStatus.sent);
    }
  }

  void _showProfile(ChatUser user) {
    unawaited(
      ChatUserProfile.show(
        context,
        user: user,
        subtitle: user.id == 'bea' ? 'online' : 'last seen today',
        actions: [
          ChatProfileAction(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Message',
            onPressed: () {},
          ),
          ChatProfileAction(
            icon: Icons.call_outlined,
            label: 'Call',
            onPressed: () {},
          ),
          ChatProfileAction(
            icon: Icons.block_rounded,
            label: 'Block',
            isDestructive: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connection =
        _online ? ChatConnectionState.online : ChatConnectionState.offline;
    return Scaffold(
      appBar: AppBar(
        title: ChatHeader(
          user: const ChatUser(id: 'atlas', name: 'Project Atlas'),
          memberCount: 5,
          controller: _controller,
          onTap: () => ChatMemberList.show(
            context,
            members: const [_lu, _kai, me, _omar, _bea],
            onlineIds: const {'bea', 'kai'},
            onTap: _showProfile,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('demo_gallery'),
            tooltip: 'Media, files and links',
            icon: const Icon(Icons.perm_media_outlined),
            onPressed: () => ChatMediaGallery.show(
              context,
              controller: _controller,
              imageProviderBuilder: demoImage,
            ),
          ),
          IconButton(
            key: const Key('demo_network'),
            tooltip: _online ? 'Go offline' : 'Go online',
            icon: Icon(_online ? Icons.wifi_rounded : Icons.wifi_off_rounded),
            onPressed: () => setState(() => _online = !_online),
          ),
        ],
      ),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        onSend: (outgoing) {
          switch (outgoing) {
            case OutgoingText(:final text, :final replyTo):
              _send(text, replyTo);
            case OutgoingEdit(:final message, :final text):
              _controller.editText(message.id, text);
            case OutgoingAttachments() ||
                  OutgoingSticker() ||
                  OutgoingScheduledNow():
              break;
          }
        },
        sendFeatures: const {ChatSendFeature.edit},
        firstUnreadMessageId: 'u1',
        connectionState: connection,
        onSendQueued: (messages) => unawaited(_deliver(messages)),
        mentionableUsers: const [_omar, _bea, _kai, _lu, me],
        onAvatarTap: _showProfile,
        builders: const ChatBuilders(imageProviderBuilder: demoImage),
        contentCallbacks: ChatContentCallbacks(
          onChecklistToggle: (list, item) =>
              _controller.toggleChecklistItem(list.id, item.id, me.id),
          onCallBack: (call) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Calling ${call.author.name}…')),
          ),
        ),
        onReactionSelected: (message, emoji) =>
            _controller.toggleReaction(message.id, emoji, me.id),
      ),
    );
  }
}
