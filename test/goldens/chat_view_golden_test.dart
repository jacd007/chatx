@Tags(['golden'])
library;

import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana Ruiz');

ChatController buildConversation() {
  final day = DateTime(2024, 3, 14, 9, 41);
  TextMessage text(
    String id,
    ChatUser author,
    int minute,
    String body, {
    MessageStatus? status,
  }) =>
      TextMessage(
        id: id,
        author: author,
        createdAt: day.add(Duration(minutes: minute)),
        text: body,
        status: status,
      );

  return ChatController(
    messages: [
      SystemMessage(id: 's', createdAt: day, text: 'Ana joined the chat'),
      text('1', ana, 1, 'Hi! Did you see the **new release**?'),
      text('2', ana, 2, 'Notes: https://dart.dev'),
      text('3', me, 3, 'Yes, the `ChatController` API is _great_.',
          status: MessageStatus.read),
      text('4', me, 4, '- streaming\n- markdown\n- zero deps',
          status: MessageStatus.delivered),
      text('5', me, 6, 'Sending this now', status: MessageStatus.failed),
      text('6', ana, 8, '```dart\nfinal x = 42;\n```'),
    ],
  );
}

Future<void> pumpGolden(WidgetTester tester, Brightness brightness) async {
  tester.view.physicalSize = const Size(400, 820);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final controller = buildConversation();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0F766E),
        brightness: brightness,
      ),
      home: Scaffold(
        body: ChatView(
          controller: controller,
          currentUser: me,
          onSendMessage: (_) {},
          onRetry: (_) {},
          onLinkTap: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('conversation, light', (tester) async {
    await pumpGolden(tester, Brightness.light);
    await expectLater(
      find.byType(ChatView),
      matchesGoldenFile('goldens/chat_view_light.png'),
    );
  });

  testWidgets('conversation, dark', (tester) async {
    await pumpGolden(tester, Brightness.dark);
    await expectLater(
      find.byType(ChatView),
      matchesGoldenFile('goldens/chat_view_dark.png'),
    );
  });
}
