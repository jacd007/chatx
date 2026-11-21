import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana');
const leo = ChatUser(id: 'leo', name: 'Leo');

void main() {
  testWidgets('thread rows and countdowns fit narrow screens with large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final now = DateTime.now();
    final controller = ChatController(
      messages: [
        TextMessage(
          id: 't',
          author: ana,
          createdAt: now.subtract(const Duration(minutes: 5)),
          text: 'Ideas?',
          thread: ChatThreadSummary(
            replyCount: 128,
            lastReplyAt: now.subtract(const Duration(days: 3)),
            participants: const [ana, leo, me],
          ),
        ),
        CountdownMessage(
          id: 'c',
          author: ana,
          createdAt: now,
          title: 'Launch',
          endsAt: now.add(const Duration(days: 3, hours: 4)),
        ),
      ],
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: Scaffold(
            body: ChatView(
              controller: controller,
              currentUser: me,
              onSend: (_) {},
              onThreadTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('chatx_thread_t')), findsOneWidget);
  });
}
