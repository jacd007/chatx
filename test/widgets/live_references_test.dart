import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana');

TextMessage message(String id, int minute, String text, {String? replyTo}) =>
    TextMessage(
      id: id,
      author: ana,
      createdAt: DateTime.now().subtract(Duration(minutes: 10 - minute)),
      text: text,
      replyToId: replyTo,
    );

void main() {
  late ChatController controller;

  setUp(() => controller = ChatController());
  tearDown(() => controller.dispose());

  Widget view({
    ChatConnectionState connection = ChatConnectionState.online,
    ValueChanged<List<ChatMessage>>? onQueued,
  }) =>
      ChatView(
        controller: controller,
        currentUser: me,
        onSend: (_) {},
        connectionState: connection,
        onSendQueued: onQueued,
      );

  testWidgets('reply quote follows edits and deletion of the original',
      (tester) async {
    controller.insertAll([
      message('a', 1, 'Lunch at noon?'),
      message('b', 2, 'Sure', replyTo: 'a'),
    ]);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: view())));
    final quote = find.byKey(const Key('chatx_quote_b'));
    expect(
      find.descendant(of: quote, matching: find.text('Lunch at noon?')),
      findsOneWidget,
    );

    controller.editText('a', 'Lunch at one?');
    await tester.pump();
    expect(
      find.descendant(of: quote, matching: find.text('Lunch at one?')),
      findsOneWidget,
    );

    controller.markDeleted('a');
    await tester.pump();
    expect(
      find.descendant(of: quote, matching: find.text('Lunch at one?')),
      findsNothing,
    );
  });

  testWidgets('pinned banner follows edits of the pinned message',
      (tester) async {
    controller
      ..insert(message('a', 1, 'Meeting at 5'))
      ..pin('a');
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: view())));
    final banner = find.byKey(const Key('chatx_pinned_banner'));
    expect(
      find.descendant(of: banner, matching: find.text('Meeting at 5')),
      findsOneWidget,
    );

    controller.editText('a', 'Meeting at 6');
    await tester.pump();
    expect(
      find.descendant(of: banner, matching: find.text('Meeting at 6')),
      findsOneWidget,
    );
  });

  testWidgets('two views sharing a controller send the queue once',
      (tester) async {
    controller.insert(
      message('q', 1, 'offline').copyWith(
        author: me,
        status: MessageStatus.queued,
      ),
    );
    final calls = <List<String>>[];
    void onQueued(List<ChatMessage> queued) =>
        calls.add([for (final m in queued) m.id]);

    Widget app(ChatConnectionState connection) => MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                    child: view(connection: connection, onQueued: onQueued)),
                Expanded(
                    child: view(connection: connection, onQueued: onQueued)),
              ],
            ),
          ),
        );

    await tester.pumpWidget(app(ChatConnectionState.offline));
    await tester.pumpWidget(app(ChatConnectionState.online));
    expect(calls, [
      ['q'],
    ]);

    // A later reconnection hands the queue out again.
    await tester.pumpWidget(app(ChatConnectionState.offline));
    await tester.pumpWidget(app(ChatConnectionState.online));
    expect(calls, hasLength(2));
  });

  testWidgets('input shows a draft cleared by a conversation switch',
      (tester) async {
    controller.insert(message('a', 1, 'hi'));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: view())));
    await tester.enterText(
      find.byKey(const Key('chatx_input_field')),
      'half written',
    );
    await tester.pump();

    controller
        .setMessages([message('x', 1, 'other chat')], newConversation: true);
    await tester.pump();
    expect(find.text('half written'), findsNothing);
  });
}
