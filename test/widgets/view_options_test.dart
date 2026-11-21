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

  testWidgets('deprecated flat parameters still work and follow rebuilds',
      (tester) async {
    Future<void> pumpFlat({required bool readOnly}) => pump(
          tester,
          ChatView(
            controller: controller,
            currentUser: me,
            onSend: (_) {},
            // ignore: deprecated_member_use_from_same_package
            readOnly: readOnly,
          ),
        );
    await pumpFlat(readOnly: true);
    expect(find.byKey(const Key('chatx_read_only')), findsOneWidget);
    await pumpFlat(readOnly: false);
    expect(find.byKey(const Key('chatx_read_only')), findsNothing);
  });

  testWidgets('mixing a group with its flat parameters asserts',
      (tester) async {
    await pump(
      tester,
      ChatView(
        controller: controller,
        currentUser: me,
        onSend: (_) {},
        moderation: const ChatModerationOptions(readOnly: true),
        // ignore: deprecated_member_use_from_same_package
        slowMode: const Duration(seconds: 5),
      ),
    );
    expect(
      tester.takeException(),
      isA<AssertionError>().having(
        (e) => e.message,
        'message',
        contains('ChatView.moderation is set'),
      ),
    );
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
}
