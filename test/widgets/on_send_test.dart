import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 1x1 PNG, so stickers render without the network.
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

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana');

DateTime ago(int minutes) =>
    DateTime.now().subtract(Duration(minutes: minutes));

void main() {
  late ChatController controller;
  late List<ChatOutgoing> sent;

  setUp(() {
    controller = ChatController();
    sent = [];
  });
  tearDown(() => controller.dispose());

  Future<void> pump(
    WidgetTester tester, {
    Set<ChatSendFeature> features = const {},
    List<ChatStickerPack> stickerPacks = const [],
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatView(
              controller: controller,
              currentUser: me,
              onSend: sent.add,
              sendFeatures: features,
              stickerPacks: stickerPacks,
              builders: ChatBuilders(
                imageProviderBuilder: (_) => MemoryImage(_pixel),
              ),
              ai: ChatAiOptions(
                suggestedPrompts: const [
                  ChatPrompt(title: 'Plan a trip'),
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('chatx_input_field')), text);
    await tester.pump();
  }

  Future<void> openMenu(WidgetTester tester, String id) async {
    await tester.longPress(find.byKey(Key('chatx_bubble_$id')));
    await tester.pumpAndSettle();
  }

  testWidgets('text and prompts arrive as OutgoingText with the reply',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Plan a trip'));
    await tester.pumpAndSettle();
    expect(sent, [const OutgoingText('Plan a trip')]);

    controller.insert(
      TextMessage(id: 'a', author: ana, createdAt: ago(1), text: 'Lunch?'),
    );
    await tester.pump();
    final original = controller.messageById('a')!;
    controller.composer.startReply(original);
    await type(tester, 'Sure');
    await tester.tap(find.byKey(const Key('chatx_send_button')));
    await tester.pumpAndSettle();
    expect(sent.last, OutgoingText('Sure', replyTo: original));
    expect(controller.composer.replyingTo.value, isNull);
  });

  testWidgets('edit is offered only with ChatSendFeature.edit', (tester) async {
    controller.insert(
      TextMessage(id: 'm', author: me, createdAt: ago(1), text: 'Helo'),
    );
    await pump(tester);
    await openMenu(tester, 'm');
    expect(find.text('Edit'), findsNothing);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await pump(tester, features: {ChatSendFeature.edit});
    await openMenu(tester, 'm');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await type(tester, 'Hello');
    await tester.tap(find.byKey(const Key('chatx_send_button')));
    await tester.pumpAndSettle();
    final edit = sent.single as OutgoingEdit;
    expect(edit.message.id, 'm');
    expect(edit.text, 'Hello');
  });

  testWidgets('attachments need ChatSendFeature.attachments', (tester) async {
    controller.composer.addAttachments(const [
      ChatAttachment(id: '1', name: 'notes.pdf'),
    ]);
    await pump(tester);
    expect(find.byKey(const Key('chatx_attachment_tray')), findsNothing);

    await pump(tester, features: {ChatSendFeature.attachments});
    expect(find.byKey(const Key('chatx_attachment_tray')), findsOneWidget);
    await type(tester, 'For tomorrow');
    await tester.tap(find.byKey(const Key('chatx_send_button')));
    await tester.pumpAndSettle();
    final outgoing = sent.single as OutgoingAttachments;
    expect(outgoing.attachments.single.name, 'notes.pdf');
    expect(outgoing.caption, 'For tomorrow');
    expect(controller.composer.attachments.value, isEmpty);
  });

  testWidgets('stickers carry the reply', (tester) async {
    controller.insert(
      TextMessage(id: 'a', author: ana, createdAt: ago(1), text: 'Hi'),
    );
    await pump(
      tester,
      features: {ChatSendFeature.stickers},
      stickerPacks: const [
        ChatStickerPack(
          id: 'cats',
          name: 'Cats',
          stickers: [ChatSticker(id: 'c1', uri: 'cat1')],
        ),
      ],
    );
    controller.composer.startReply(controller.messageById('a')!);
    await tester.pump();
    await tester.tap(find.byKey(const Key('chatx_emoji_button')));
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const Key('chatx_sticker_pack_cats')));
    await tester.tap(find.byKey(const Key('chatx_sticker_pack_cats')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatx_sticker_c1')));
    await tester.pumpAndSettle();
    final sticker = sent.single as OutgoingSticker;
    expect(sticker.sticker.id, 'c1');
    expect(sticker.replyTo?.id, 'a');
    expect(controller.composer.replyingTo.value, isNull);
  });

  testWidgets('scheduling and send now', (tester) async {
    await pump(
      tester,
      features: {ChatSendFeature.schedule, ChatSendFeature.sendScheduledNow},
    );
    await type(tester, 'Happy birthday!');
    await tester.longPress(find.byKey(const Key('chatx_send_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tomorrow morning'));
    await tester.pumpAndSettle();
    final scheduled = sent.single as OutgoingText;
    expect(scheduled.text, 'Happy birthday!');
    expect(scheduled.scheduledFor!.hour, 9);

    controller.insert(
      TextMessage(
        id: 'p',
        author: me,
        createdAt: DateTime.now(),
        text: 'Happy birthday!',
        scheduledFor: scheduled.scheduledFor,
      ),
    );
    await tester.pumpAndSettle();
    await openMenu(tester, 'p');
    await tester.tap(find.text('Send now'));
    await tester.pumpAndSettle();
    expect((sent.last as OutgoingScheduledNow).message.id, 'p');
  });
}
