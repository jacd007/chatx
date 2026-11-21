import 'dart:typed_data';

import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana');
const bot = ChatUser(id: 'bot', name: 'Assistant', isBot: true);

final Uint8List _pixel = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

List<ChatMessage> conversation() {
  final t = DateTime.now().subtract(const Duration(minutes: 30));
  DateTime at(int m) => t.add(Duration(minutes: m));
  return [
    TextMessage(
      id: 't1',
      author: ana,
      createdAt: at(1),
      text: 'Hi **there**',
      reactions: const [
        ChatReaction(emoji: '👍', userIds: ['me']),
      ],
    ),
    TextMessage(
      id: 't2',
      author: me,
      createdAt: at(2),
      text: 'Hello https://dart.dev',
      status: MessageStatus.read,
      replyToId: 't1',
    ),
    FileMessage(id: 'f', author: ana, createdAt: at(3), name: 'a.pdf'),
    VoiceMessage(
      id: 'v',
      author: ana,
      createdAt: at(4),
      uri: 'x',
      duration: const Duration(seconds: 9),
    ),
    PollMessage(
      id: 'p',
      author: ana,
      createdAt: at(5),
      question: 'Lunch?',
      options: const [
        PollOption(id: 'a', text: 'Yes'),
        PollOption(id: 'b', text: 'No'),
      ],
    ),
    EventMessage(
      id: 'e',
      author: ana,
      createdAt: at(6),
      title: 'Dinner',
      startsAt: at(600),
    ),
    TextMessage(
      id: 'b1',
      author: bot,
      createdAt: at(7),
      text: 'Answer with `code`',
      buttons: const [ChatMessageButton(id: 'x', label: 'More')],
      quickReplies: const [ChatQuickReply(label: 'Thanks')],
    ),
  ];
}

Future<void> pumpAll(WidgetTester tester, {double textScale = 1}) async {
  final controller = ChatController(messages: conversation());
  addTearDown(controller.dispose);
  tester.view.physicalSize = const Size(430, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: ChatView(
            controller: controller,
            currentUser: me,
            onSendMessage: (_, __) {},
            onPollVote: (_, __) {},
            onRsvp: (_, __) {},
            onVoicePlay: (_) {},
            onMessageButton: (_, __) {},
            onFeedback: (_, __) {},
            onReactionSelected: (_, __) {},
            onRegenerate: (_) {},
            onLinkTap: (_) {},
            imageProviderBuilder: (_) => MemoryImage(_pixel),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('meets accessibility guidelines at ${scale}x text',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpAll(tester, textScale: scale);
      expect(tester.takeException(), isNull, reason: 'no overflow');
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  }
}
