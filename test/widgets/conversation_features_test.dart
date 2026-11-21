import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana');

TextMessage message(
  String id, {
  ChatUser author = ana,
  String? text,
  DateTime? at,
  String? replyToId,
  List<ChatReaction> reactions = const [],
}) {
  return TextMessage(
    id: id,
    author: author,
    createdAt: at ?? DateTime.now(),
    text: text ?? 'text $id',
    replyToId: replyToId,
    reactions: reactions,
  );
}

void main() {
  late ChatController controller;
  late List<(String, ChatMessage?)> sent;
  late List<(TextMessage, String)> edited;
  late List<(String, String)> reacted;
  late List<String> deleted;

  setUp(() {
    controller = ChatController();
    sent = [];
    edited = [];
    reacted = [];
    deleted = [];
  });
  tearDown(() => controller.dispose());

  Future<void> pump(
    WidgetTester tester, {
    ChatMessageMenuStyle menuStyle = ChatMessageMenuStyle.bottomSheet,
    ChatMessageMenuTrigger trigger = ChatMessageMenuTrigger.longPress,
    String? firstUnread,
    ChatSwipeAction? swipeAction = const ChatSwipeAction.reply(),
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            controller: controller,
            currentUser: me,
            onSend: (outgoing) => switch (outgoing) {
              OutgoingText(:final text, :final replyTo) =>
                sent.add((text, replyTo)),
              OutgoingEdit(:final message, :final text) =>
                edited.add((message, text)),
              _ => fail('Unexpected $outgoing'),
            },
            sendFeatures: const {ChatSendFeature.edit},
            onDeleteMessage: (m) => deleted.add(m.id),
            onReactionSelected: (m, emoji) => reacted.add((m.id, emoji)),
            messageMenuStyle: menuStyle,
            messageMenuTrigger: trigger,
            firstUnreadMessageId: firstUnread,
            swipeAction: swipeAction,
          ),
        ),
      ),
    );
  }

  Future<void> send(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('chatx_input_field')), text);
    await tester.pump();
    await tester.tap(find.byKey(const Key('chatx_send_button')));
    await tester.pumpAndSettle();
  }

  group('reply', () {
    testWidgets('swiping a bubble starts a reply that is sent with the text',
        (tester) async {
      controller.insert(message('1', text: 'Lunch?'));
      await pump(tester);

      await tester.drag(
        find.byKey(const Key('chatx_bubble_1')),
        const Offset(120, 0),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_reply_banner')), findsOneWidget);
      expect(find.text('Replying to Ana'), findsOneWidget);

      await send(tester, 'Sure!');
      expect(sent.single.$1, 'Sure!');
      expect(sent.single.$2?.id, '1');
      expect(find.byKey(const Key('chatx_reply_banner')), findsNothing);
    });

    testWidgets('a short swipe does not start a reply', (tester) async {
      controller.insert(message('1'));
      await pump(tester);
      await tester.drag(
        find.byKey(const Key('chatx_bubble_1')),
        const Offset(30, 0),
      );
      await tester.pumpAndSettle();
      expect(controller.composer.replyingTo.value, isNull);
    });

    testWidgets('swiping can be disabled', (tester) async {
      controller.insert(message('1'));
      await pump(tester, swipeAction: null);
      await tester.drag(
        find.byKey(const Key('chatx_bubble_1')),
        const Offset(120, 0),
      );
      await tester.pumpAndSettle();
      expect(controller.composer.replyingTo.value, isNull);
    });

    testWidgets('custom swipe actions receive the message', (tester) async {
      final swiped = <String>[];
      controller.insert(message('1'));
      await pump(
        tester,
        swipeAction: ChatSwipeAction(
          icon: Icons.star,
          onTriggered: (m) => swiped.add(m.id),
        ),
      );
      await tester.drag(
        find.byKey(const Key('chatx_bubble_1')),
        const Offset(120, 0),
      );
      await tester.pumpAndSettle();
      expect(swiped, ['1']);
    });

    testWidgets('the reply banner can be cancelled', (tester) async {
      controller.insert(message('1'));
      await pump(tester);
      controller.composer.startReply(controller.messageById('1')!);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_cancel_reply')));
      await tester.pumpAndSettle();
      expect(controller.composer.replyingTo.value, isNull);
    });

    testWidgets('replies show a quote that jumps to the original',
        (tester) async {
      final start = DateTime.now().subtract(const Duration(hours: 2));
      controller.insertAll([
        message('original', text: 'The **plan** is ready', at: start),
        for (var i = 0; i < 30; i++)
          message('m$i', at: start.add(Duration(minutes: i + 1))),
        message('reply', author: me, text: 'Great', replyToId: 'original'),
      ]);
      await pump(tester);

      expect(find.text('The plan is ready'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_quote_reply')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('chatx_bubble_original')).hitTestable(),
        findsOneWidget,
      );
    });

    testWidgets('quotes of missing messages say so', (tester) async {
      controller.insert(message('r', replyToId: 'gone'));
      await pump(tester);
      expect(find.text('Original message not available'), findsOneWidget);
    });
  });

  group('menu', () {
    testWidgets('default actions depend on the author', (tester) async {
      controller.insertAll([
        message('mine', author: me, at: DateTime(2026, 1, 1, 10)),
        message('theirs', at: DateTime(2026, 1, 1, 11)),
      ]);
      await pump(tester);

      await tester.longPress(find.byKey(const Key('chatx_bubble_mine')));
      await tester.pumpAndSettle();
      for (final label in ['Reply', 'Copy text', 'Edit', 'Delete']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.longPress(find.byKey(const Key('chatx_bubble_theirs')));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      expect(find.text('Reply'), findsOneWidget);
    });

    testWidgets('a tap opens the popup menu when configured', (tester) async {
      controller.insert(message('1'));
      await pump(
        tester,
        menuStyle: ChatMessageMenuStyle.popup,
        trigger: ChatMessageMenuTrigger.tap,
      );
      await tester.tap(find.byKey(const Key('chatx_bubble_1')));
      await tester.pumpAndSettle();
      expect(find.byType(PopupMenuItem<Object>), findsWidgets);

      await tester.tap(find.byKey(const Key('chatx_react_❤️')));
      await tester.pumpAndSettle();
      expect(reacted, [('1', '❤️')]);
    });

    testWidgets('delete calls onDeleteMessage', (tester) async {
      controller.insert(message('1', author: me));
      await pump(tester);
      await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(deleted, ['1']);
    });
  });

  group('edit', () {
    testWidgets('editing fills the input and saves through onSend',
        (tester) async {
      controller.insert(message('1', author: me, text: 'Helo'));
      await pump(tester);

      await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      final field = find.byKey(const Key('chatx_input_field'));
      expect(tester.widget<TextField>(field).controller!.text, 'Helo');
      expect(find.byKey(const Key('chatx_edit_banner')), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await send(tester, 'Hello');
      expect(edited.single.$1.id, '1');
      expect(edited.single.$2, 'Hello');
      expect(sent, isEmpty);
      expect(controller.composer.editing.value, isNull);
    });

    testWidgets('cancelling an edit clears the input', (tester) async {
      controller.insert(message('1', author: me, text: 'Draft'));
      await pump(tester);
      controller.composer
          .startEditing(controller.messageById('1')! as TextMessage);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_cancel_edit')));
      await tester.pumpAndSettle();
      final field = find.byKey(const Key('chatx_input_field'));
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    });

    testWidgets('edited messages show a label', (tester) async {
      controller.insert(message('1', author: me));
      controller.editText('1', 'new text');
      await pump(tester);
      expect(find.textContaining('edited'), findsOneWidget);
    });
  });

  group('reactions', () {
    testWidgets('chips show counts and report taps', (tester) async {
      controller.insert(
        message(
          '1',
          reactions: const [
            ChatReaction(emoji: '👍', userIds: ['ana', 'me']),
            ChatReaction(emoji: '🎉', userIds: ['ana']),
          ],
        ),
      );
      await pump(tester);
      expect(find.text('👍 2'), findsOneWidget);
      expect(find.text('🎉'), findsOneWidget);

      await tester.tap(find.byKey(const Key('chatx_reaction_1_👍')));
      expect(reacted, [('1', '👍')]);
    });

    testWidgets('picking a reaction from the sheet reports it', (tester) async {
      controller.insert(message('1'));
      await pump(tester);
      await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_react_😂')));
      await tester.pumpAndSettle();
      expect(reacted, [('1', '😂')]);
    });
  });

  testWidgets('shows the unread separator above the first unread message',
      (tester) async {
    final now = DateTime.now();
    controller.insertAll([
      message('read', at: now.subtract(const Duration(minutes: 2))),
      message('unread', at: now.subtract(const Duration(minutes: 1))),
    ]);
    await pump(tester, firstUnread: 'unread');
    final separator = tester.getRect(
      find.byKey(const Key('chatx_unread_separator')),
    );
    final unread = tester.getRect(find.byKey(const Key('chatx_bubble_unread')));
    final read = tester.getRect(find.byKey(const Key('chatx_bubble_read')));
    expect(separator.top, greaterThanOrEqualTo(read.bottom));
    expect(separator.bottom, lessThanOrEqualTo(unread.top));
    expect(find.text('New messages'), findsOneWidget);
  });

  testWidgets('emoji-only messages render large without a bubble',
      (tester) async {
    controller.insertAll([
      message('jumbo', text: '🎉🔥', at: DateTime(2026, 1, 1, 10)),
      message('normal', text: 'ok 🎉', at: DateTime(2026, 1, 1, 11)),
    ]);
    await pump(tester);
    final jumbo = tester.widget<Material>(
      find.byKey(const Key('chatx_bubble_jumbo')),
    );
    final normal = tester.widget<Material>(
      find.byKey(const Key('chatx_bubble_normal')),
    );
    expect(jumbo.color, Colors.transparent);
    expect(normal.color, isNot(Colors.transparent));
  });
}
