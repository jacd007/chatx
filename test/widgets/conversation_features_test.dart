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
      expect(find.byKey(const Key('chatx_message_menu')), findsOneWidget);

      await tester.tap(find.byKey(const Key('chatx_react_❤️')));
      await tester.pumpAndSettle();
      expect(reacted, [('1', '❤️')]);
    });

    for (final style in ChatMessageMenuStyle.values) {
      testWidgets('the ${style.name} menu never covers its bubble',
          (tester) async {
        for (var i = 0; i < 20; i++) {
          controller.insert(message('m$i', text: 'Message $i'));
        }
        await pump(tester, menuStyle: style);
        // The newest message sits right above the input.
        await tester.longPress(find.byKey(const Key('chatx_bubble_m19')));
        await tester.pumpAndSettle();

        final focus = find.byKey(const Key('chatx_menu_focus'));
        final menu = find.byKey(const Key('chatx_message_menu'));
        expect(focus, findsOneWidget);
        expect(menu, findsOneWidget);
        final focusRect = tester.getRect(focus);
        final menuRect = tester.getRect(menu);
        expect(focusRect.overlaps(menuRect), isFalse);
        final screen = Offset.zero &
            tester.view.physicalSize / tester.view.devicePixelRatio;
        expect(screen.contains(focusRect.topLeft), isTrue);
        expect(
            screen.contains(menuRect.bottomRight - const Offset(1, 1)), isTrue);

        // Closing shows the bubble of the list again.
        await tester.tap(find.byKey(const Key('chatx_menu_scrim')),
            warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(focus, findsNothing);
        final opacity = tester.widget<Opacity>(
          find
              .ancestor(
                of: find.byKey(const Key('chatx_bubble_m19')),
                matching: find.byType(Opacity),
              )
              .first,
        );
        expect(opacity.opacity, 1);
      });
    }

    testWidgets('a popup points at its bubble', (tester) async {
      controller.insert(message('m', text: 'Hi'));
      await pump(tester, menuStyle: ChatMessageMenuStyle.popup);
      await tester.longPress(find.byKey(const Key('chatx_bubble_m')));
      await tester.pumpAndSettle();
      final pointer =
          tester.getCenter(find.byKey(const Key('chatx_menu_pointer')));
      final menu = tester.getRect(find.byKey(const Key('chatx_message_menu')));
      final bubble = tester.getRect(find.byKey(const Key('chatx_menu_focus')));
      // On the menu edge that faces the bubble.
      expect(
        (pointer.dy - menu.top).abs() < 1 ||
            (pointer.dy - menu.bottom).abs() < 1,
        isTrue,
      );
      expect(pointer.dx, inInclusiveRange(menu.left, menu.right));
      expect(
        (pointer.dy - bubble.bottom).abs() < 20 ||
            (pointer.dy - bubble.top).abs() < 20,
        isTrue,
      );
    });

    testWidgets('a very tall bubble stays in place and the menu previews it',
        (tester) async {
      controller.insert(
        message('long',
            text: List.filled(60, 'A long line of text.').join(' ')),
      );
      await pump(tester, menuStyle: ChatMessageMenuStyle.popup);
      await tester.longPress(find.byKey(const Key('chatx_bubble_long')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_menu_focus')), findsNothing);
      expect(find.byKey(const Key('chatx_menu_pointer')), findsNothing);
      expect(find.byKey(const Key('chatx_menu_preview')), findsOneWidget);
      expect(find.text('Ana'), findsWidgets);
      // The bubble in the list is not hidden.
      final opacity = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.byKey(const Key('chatx_bubble_long')),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(opacity.opacity, 1);
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
    testWidgets('one pill groups the reactions; its sheet toggles them',
        (tester) async {
      controller.insert(
        message(
          '1',
          reactions: const [
            ChatReaction(emoji: '🎉', userIds: ['ana']),
            ChatReaction(emoji: '👍', userIds: ['ana', 'me']),
            ChatReaction(emoji: '❤️', userIds: ['leo']),
            ChatReaction(emoji: '🙏', userIds: ['sam']),
            ChatReaction(emoji: '😁', userIds: ['bea']),
          ],
        ),
      );
      await pump(tester);
      // Most used first, three emoji at most, and the total.
      expect(find.text('👍🎉❤️ 6'), findsOneWidget);

      await tester.tap(find.byKey(const Key('chatx_reactions_1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_reactions_sheet_1')), findsOneWidget);
      expect(find.text('😁'), findsOneWidget);

      await tester.tap(find.byKey(const Key('chatx_reaction_1_👍')));
      await tester.pumpAndSettle();
      expect(reacted, [('1', '👍')]);
      expect(find.byKey(const Key('chatx_reactions_sheet_1')), findsNothing);
    });

    testWidgets('many reactions stay one pill under the bubble',
        (tester) async {
      controller.insert(
        message(
          '1',
          text: 'Long-press a message to save it for later',
          reactions: [
            for (final emoji in [
              '🥳',
              '👍',
              '❤️',
              '🙏',
              '😁',
              '🖖',
              '👏',
              '🏎'
            ])
              ChatReaction(emoji: emoji, userIds: const ['ana']),
          ],
        ),
      );
      await pump(tester);
      final pill = tester.getRect(find.byKey(const Key('chatx_reactions_1')));
      final bubble = tester.getRect(find.byKey(const Key('chatx_bubble_1')));
      expect(pill.height, 48);
      expect(pill.width, lessThan(bubble.width));
      expect(pill.left, greaterThanOrEqualTo(bubble.left));
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

  testWidgets('opens with the unread separator in view in long chats',
      (tester) async {
    final now = DateTime.now();
    controller.insertAll([
      for (var i = 0; i < 40; i++)
        message('m$i', at: now.subtract(Duration(minutes: 40 - i))),
    ]);
    // A phone, with a banner above the chat like the demo app.
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Chat')),
          body: Column(
            children: [
              const SizedBox(height: 80),
              Expanded(
                child: ChatView(
                  controller: controller,
                  currentUser: me,
                  onSend: (_) {},
                  firstUnreadMessageId: 'm25',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final separator = find.byKey(const Key('chatx_unread_separator'));
    expect(separator, findsOneWidget);
    final rect = tester.getRect(separator);
    final list = tester.getRect(find.byType(CustomScrollView).first);
    expect(rect.top, greaterThanOrEqualTo(list.top));
    expect(rect.bottom, lessThanOrEqualTo(list.bottom));
  });

  testWidgets('mentions of the current user are highlighted', (tester) async {
    controller.insert(message('1', text: 'Hi @Me, can you check?'));
    await pump(tester);
    final spans = <TextSpan>[];
    for (final text in tester.widgetList<RichText>(find.byType(RichText))) {
      text.text.visitChildren((span) {
        if (span is TextSpan) spans.add(span);
        return true;
      });
    }
    final mention = spans.firstWhere((s) => s.text == '@Me');
    expect(mention.style?.backgroundColor, isNotNull);
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
