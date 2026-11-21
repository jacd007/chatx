import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';
import 'demo_chat.dart';

const _leo = ChatUser(id: 'leo', name: 'Leo', role: ChatRole.admin);
const _sam = ChatUser(id: 'sam', name: 'Sam', role: ChatRole.moderator);

/// One conversation with every chatx feature turned on at once.
class AllFeaturesPage extends StatefulWidget {
  const AllFeaturesPage({super.key});

  @override
  State<AllFeaturesPage> createState() => _AllFeaturesPageState();
}

class _AllFeaturesPageState extends State<AllFeaturesPage> {
  late final ChatController controller = ChatController(messages: _seed());
  late final search = ChatSearchController(chatController: controller);
  final playback = ValueNotifier<ChatVoicePlayback?>(null);
  Timer? _playTimer;
  StreamSubscription<String>? _answer;
  bool _searching = false;
  bool _online = true;

  @override
  void dispose() {
    _playTimer?.cancel();
    unawaited(_answer?.cancel());
    playback.dispose();
    search.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? ChatSearchBar(controller: search)
            : const Text('All features'),
        actions: [
          IconButton(
            tooltip: _searching ? 'Close search' : 'Search',
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              if (_searching) search.clear();
              setState(() => _searching = !_searching);
            },
          ),
          IconButton(
            tooltip: _online ? 'Go offline' : 'Go online',
            icon: Icon(_online ? Icons.wifi : Icons.wifi_off),
            onPressed: () => setState(() => _online = !_online),
          ),
        ],
      ),
      body: ChatView(
        controller: controller,
        currentUser: me,
        onSend: _send,
        sendFeatures: ChatSendFeature.values.toSet(),
        stickerPacks: const [demoStickers],
        onAttach: _attach,
        onDeleteMessage: (m) => controller.remove(m.id),
        onReactionSelected: (m, emoji) =>
            controller.toggleReaction(m.id, emoji, me.id),
        onRetry: (m) => controller.updateStatus(m.id, MessageStatus.sent),
        onLinkTap: (uri) => showLink(context, uri),
        onPinMessage: (m, pinned) =>
            pinned ? controller.pin(m.id) : controller.unpin(m.id),
        onSaveMessage: (m, _) => controller.toggleSaved(m.id),
        onForwardMessages: (list) =>
            toast(context, 'Forward ${list.length} messages'),
        onThreadTap: (m) => toast(context, 'Open the thread of ${m.id}'),
        onAvatarTap: (u) => toast(context, 'Profile of ${u.name}'),
        mentionableUsers: const [ana, _leo, _sam, bot],
        onMentionTap: (u) => toast(context, 'Profile of ${u.name}'),
        searchController: search,
        enableSelection: true,
        firstUnreadMessageId: 'unread',
        connectionState:
            _online ? ChatConnectionState.online : ChatConnectionState.offline,
        onSendQueued: (queued) {
          for (final m in queued) {
            controller.updateStatus(m.id, MessageStatus.sent);
          }
        },
        builders: const ChatBuilders(imageProviderBuilder: demoImage),
        ai: ChatAiOptions(
          suggestedPrompts: const [
            ChatPrompt(title: 'Summarize', subtitle: 'this conversation'),
          ],
          onRegenerate: (m) {
            controller.startRegeneration(m.id);
            _stream(m.id, 'A new answer, generated again.');
          },
          onStopGenerating: (m) {
            unawaited(_answer?.cancel());
            controller.completeStream(m.id);
          },
          onFeedback: (m, feedback) => controller.update(
            m.copyWith(feedback: feedback, clearFeedback: feedback == null),
          ),
          onTranslate: (m) async {
            await latency();
            return '(es) ${m.text}';
          },
          onSourceTap: (s) => toast(context, 'Open ${s.url}'),
        ),
        moderation: ChatModerationOptions(
          onReportMessage: (m) => toast(context, 'Reported'),
          onBlockUser: (u) => toast(context, '${u.name} blocked'),
          wordFilter: ChatWordFilter({'darn'}),
          onDeleteForEveryone: (m) => controller.markDeleted(m.id),
        ),
        media: ChatMediaOptions(
          onFileTap: (f) => toast(context, 'Open ${f.name}'),
          onVideoTap: (v) => toast(context, 'Play video'),
          voicePlayback: playback,
          onVoicePlay: _play,
          onVoicePause: (_) => _pause(),
          onVoiceSeek: (m, position) => playback.value = ChatVoicePlayback(
            messageId: m.id,
            position: position,
            isPlaying: playback.value?.isPlaying ?? false,
          ),
          onVoiceRecordStart: () => toast(context, 'Recording…'),
          onVoiceRecordEnd: (duration, {required cancelled}) {
            if (cancelled) return;
            controller.insert(
              VoiceMessage(
                id: newId(),
                author: me,
                createdAt: DateTime.now(),
                uri: 'recording',
                duration: duration,
                status: MessageStatus.sent,
              ),
            );
          },
          onTranscribe: (m) async {
            await latency();
            controller.update(m.copyWith(transcript: 'See you at five!'));
          },
        ),
        contentCallbacks: ChatContentCallbacks(
          onPollVote: (poll, option) =>
              controller.votePoll(poll.id, option, me.id),
          onSurveySubmit: (survey, response) {
            controller.recordSurveyResponse(survey.id, me.id);
            toast(context, '${response.answers.length} answers sent');
          },
          onMessageButton: (m, button) => toast(context, button.label),
          onQuickReply: (reply, _) => _send(OutgoingText(reply.text)),
          onLocationTap: (l) => toast(context, 'Open maps'),
          onRsvp: (e, rsvp) => controller.setRsvp(e.id, me.id, rsvp),
          onContactAction: (c, action) => toast(context, action.name),
          onChecklistToggle: (list, item) =>
              controller.toggleChecklistItem(list.id, item.id, me.id),
          onProductTap: (m, product) => toast(context, product.title),
          onPaymentAction: (m, action) => controller.update(
            m.copyWith(
              paymentStatus: action == ChatPaymentAction.pay
                  ? ChatPaymentStatus.paid
                  : ChatPaymentStatus.declined,
            ),
          ),
          onCallBack: (call) => toast(context, 'Calling…'),
        ),
      ),
    );
  }

  void _send(ChatOutgoing outgoing) {
    if (outgoing is OutgoingText && outgoing.scheduledFor == null) {
      controller.insert(
        TextMessage(
          id: newId(),
          author: me,
          createdAt: DateTime.now(),
          text: outgoing.text,
          replyToId: outgoing.replyTo?.id,
          status: _online ? MessageStatus.sent : MessageStatus.queued,
        ),
      );
      if (_online) unawaited(_botAnswer(outgoing.text));
      return;
    }
    sendText(controller, outgoing);
  }

  Future<void> _botAnswer(String question) async {
    controller.setTyping(bot, isTyping: true);
    await latency(900);
    if (!mounted) return;
    controller.setTyping(bot, isTyping: false);
    final id = newId();
    controller.insert(
      TextMessage(
        id: id,
        author: bot,
        createdAt: DateTime.now(),
        text: '',
        isStreaming: true,
      ),
    );
    _stream(
        id,
        'You said **$question**. Try regenerating or rating this '
        'answer.');
  }

  void _stream(String id, String answer) {
    unawaited(_answer?.cancel());
    _answer = Stream.periodic(
      const Duration(milliseconds: 45),
      (i) => i,
    ).take(answer.split(' ').length).map((i) {
      final word = answer.split(' ')[i];
      return i == 0 ? word : ' $word';
    }).listen(
      (token) => controller.appendText(id, token),
      onDone: () => controller.completeStream(id),
    );
  }

  void _attach() {
    controller.composer.addAttachments([
      ChatAttachment(
        id: newId(),
        name: 'report.pdf',
        sizeBytes: 182000,
      ),
    ]);
  }

  void _play(VoiceMessage message) {
    _playTimer?.cancel();
    var position = playback.value?.messageId == message.id
        ? playback.value!.position
        : Duration.zero;
    _playTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      position += const Duration(milliseconds: 200);
      if (position >= message.duration) {
        timer.cancel();
        playback.value = null;
        return;
      }
      playback.value = ChatVoicePlayback(
        messageId: message.id,
        position: position,
        isPlaying: true,
      );
    });
  }

  void _pause() {
    _playTimer?.cancel();
    final current = playback.value;
    if (current != null) {
      playback.value = ChatVoicePlayback(
        messageId: current.messageId,
        position: current.position,
        isPlaying: false,
      );
    }
  }
}

List<ChatMessage> _seed() {
  var minute = 300;
  DateTime next() => ago(minute -= 3);
  return [
    SystemMessage(id: 'sys', createdAt: next(), text: 'Ana created the group'),
    TextMessage(
      id: 'welcome',
      author: ana,
      createdAt: next(),
      text: 'Welcome! **Bold**, _italic_, `code` and a ||spoiler||. '
          'Docs: https://pub.dev/packages/chatx',
      reactions: const [
        ChatReaction(emoji: '🎉', userIds: ['leo', 'sam']),
      ],
      thread: ChatThreadSummary(
        replyCount: 2,
        lastReplyAt: ago(100),
        participants: const [_leo, _sam],
      ),
    ),
    TextMessage(
      id: 'pinned',
      author: _leo,
      createdAt: next(),
      text: 'Pinned: standup moved to 10:30',
    ),
    TextMessage(
      id: 'reply',
      author: me,
      createdAt: next(),
      text: 'Got it, thanks @Leo',
      replyToId: 'pinned',
      status: MessageStatus.read,
      receipts: [
        ChatReadReceipt(user: ana, readAt: ago(200)),
        ChatReadReceipt(user: _leo, readAt: ago(199)),
      ],
    ),
    ImageMessage(
      id: 'images',
      author: ana,
      createdAt: next(),
      images: const [
        ChatImage(uri: 'asset:sunset', width: 1200, height: 800),
        ChatImage(uri: 'asset:forest', width: 1200, height: 800),
        ChatImage(uri: 'asset:ocean', width: 1200, height: 800),
      ],
      caption: 'Photos from the trip',
    ),
    FileMessage(
      id: 'file',
      author: _sam,
      createdAt: next(),
      name: 'Budget 2027.xlsx',
      sizeBytes: 48200,
    ),
    VoiceMessage(
      id: 'voice',
      author: ana,
      createdAt: next(),
      uri: 'voice',
      duration: const Duration(seconds: 12),
    ),
    LocationMessage(
      id: 'location',
      author: _leo,
      createdAt: next(),
      latitude: 40.4168,
      longitude: -3.7038,
      title: 'Plaza Mayor',
      address: 'Madrid',
    ),
    ContactMessage(
      id: 'contact',
      author: ana,
      createdAt: next(),
      name: 'Marta Ruiz',
      phone: '+34 600 000 000',
    ),
    StickerMessage(
      id: 'sticker',
      author: _sam,
      createdAt: next(),
      uri: 'sticker:love',
    ),
    PollMessage(
      id: 'poll',
      author: _leo,
      createdAt: next(),
      question: 'Lunch?',
      options: const [
        PollOption(id: 'pizza', text: 'Pizza'),
        PollOption(id: 'sushi', text: 'Sushi'),
        PollOption(id: 'tacos', text: 'Tacos'),
      ],
    ),
    SurveyMessage(
      id: 'survey',
      author: ana,
      createdAt: next(),
      title: 'Team retro',
      questions: const [
        RatingQuestion(id: 'sprint', title: 'How was the sprint?'),
        NpsQuestion(id: 'nps', title: 'Would you recommend the team?'),
        TextQuestion(id: 'ideas', title: 'Ideas?'),
      ],
    ),
    EventMessage(
      id: 'event',
      author: _leo,
      createdAt: next(),
      title: 'Team dinner',
      startsAt: DateTime.now().add(const Duration(days: 3)),
      location: 'La Tasca',
    ),
    CountdownMessage(
      id: 'countdown',
      author: _sam,
      createdAt: next(),
      title: 'Release 0.3',
      endsAt: DateTime.now().add(const Duration(hours: 5)),
    ),
    ChecklistMessage(
      id: 'checklist',
      author: ana,
      createdAt: next(),
      title: 'Trip',
      items: const [
        ChecklistItem(id: 'tickets', text: 'Tickets', doneBy: 'ana'),
        ChecklistItem(id: 'hotel', text: 'Hotel'),
      ],
    ),
    CallMessage(
      id: 'call',
      author: _leo,
      createdAt: next(),
      kind: ChatCallKind.video,
      outcome: ChatCallOutcome.missed,
    ),
    TextMessage(
      id: 'darn',
      author: _sam,
      createdAt: next(),
      text: 'Darn, the build broke again',
      forwardedFrom: 'CI bot',
    ),
    TextMessage(
      id: 'unread',
      author: bot,
      createdAt: next(),
      text: 'How can I help? Pick one:',
      buttons: const [
        ChatMessageButton(id: 'docs', label: 'Open docs'),
      ],
      quickReplies: const [
        ChatQuickReply(label: 'Pricing'),
        ChatQuickReply(label: 'Talk to a human'),
      ],
    ),
    ProductMessage(
      id: 'products',
      author: bot,
      createdAt: next(),
      products: const [
        ChatProduct(id: 'a', title: 'Card stock', price: r'$12'),
        ChatProduct(id: 'b', title: 'Sticker pack', price: r'$4'),
      ],
    ),
    PaymentMessage(
      id: 'payment',
      author: bot,
      createdAt: next(),
      amount: r'$16.00',
      note: 'Order #1042',
    ),
    TextMessage(
      id: 'ai',
      author: bot,
      createdAt: next(),
      text: 'Here is the summary with sources.',
      reasoning: const ChatReasoning(
        text: 'The user wants a short summary.',
        duration: Duration(seconds: 4),
      ),
      toolCalls: const [
        ChatToolCall(id: 'search', name: 'Searched the docs'),
      ],
      sources: const [
        ChatSource(title: 'chatx', url: 'https://pub.dev/packages/chatx'),
      ],
      versions: const [
        ChatAnswerVersion(text: 'An earlier, longer summary.'),
      ],
    ),
    TextMessage(
      id: 'expiring',
      author: ana,
      createdAt: next(),
      text: 'This disappears in a minute',
      expiresAt: DateTime.now().add(const Duration(minutes: 1)),
    ),
  ];
}
