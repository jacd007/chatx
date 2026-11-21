import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');

void main() {
  late ChatController controller;

  setUp(() => controller = ChatController());
  tearDown(() => controller.dispose());

  Future<void> pump(WidgetTester tester, ChatView view) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: view)));

  testWidgets('option groups drive the view', (tester) async {
    await pump(
      tester,
      ChatView(
        controller: controller,
        currentUser: me,
        onSend: (_) {},
        ai: const ChatAiOptions(
          suggestedPrompts: [ChatPrompt(title: 'Plan a trip')],
        ),
      ),
    );
    expect(find.text('Plan a trip'), findsOneWidget);

    await pump(
      tester,
      ChatView(
        controller: controller,
        currentUser: me,
        onSend: (_) {},
        builders: ChatBuilders(
          emptyStateBuilder: (_) => const Text('Nothing yet'),
        ),
        moderation: const ChatModerationOptions(
          readOnly: true,
          readOnlyMessage: 'Announcements only',
        ),
      ),
    );
    expect(find.text('Nothing yet'), findsOneWidget);
    expect(find.text('Announcements only'), findsOneWidget);
    expect(find.byKey(const Key('chatx_input_field')), findsNothing);
  });

  testWidgets('content callbacks receive quick replies', (tester) async {
    final replies = <String>[];
    controller.insert(
      TextMessage(
        id: 'q',
        author: const ChatUser(id: 'bot', isBot: true),
        createdAt: DateTime.now(),
        text: 'Pick one',
        quickReplies: const [ChatQuickReply(label: 'Yes', value: 'yes')],
      ),
    );
    await pump(
      tester,
      ChatView(
        controller: controller,
        currentUser: me,
        onSend: (_) {},
        contentCallbacks: ChatContentCallbacks(
          onQuickReply: (reply, _) => replies.add(reply.text),
        ),
      ),
    );
    await tester.tap(find.text('Yes'));
    expect(replies, ['yes']);
  });

  testWidgets('custom messages use the builder of their type', (tester) async {
    final at = DateTime.now();
    controller.insertAll([
      CustomMessage(id: 'a', author: me, createdAt: at, type: 'invoice'),
      CustomMessage(id: 'b', author: me, createdAt: at, type: 'unknown'),
    ]);
    await pump(
      tester,
      ChatView(
        controller: controller,
        currentUser: me,
        onSend: (_) {},
        builders: ChatBuilders(
          customMessageBuilders: {
            'invoice': (_, message, __) => Text('Invoice ${message.id}'),
          },
          customMessageBuilder: (_, message, __) => Text('Other ${message.id}'),
        ),
      ),
    );
    expect(find.text('Invoice a'), findsOneWidget);
    expect(find.text('Other b'), findsOneWidget);
  });
}
