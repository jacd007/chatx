import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me');
const other = ChatUser(id: 'a');
final start = DateTime(2026);

List<ChatMessage> conversation(int count) => [
      for (var i = 0; i < count; i++)
        TextMessage(
          id: 'm$i',
          author: i.isEven ? other : me,
          createdAt: start.add(Duration(minutes: i)),
          text: 'message **$i** with `code` and https://dart.dev',
        ),
    ];

/// Average time to insert one message and render the next frame.
Future<double> insertCost(WidgetTester tester, int size) async {
  final controller = ChatController(messages: conversation(size));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ChatView(
          controller: controller,
          currentUser: me,
          onSendMessage: (_, __) {},
        ),
      ),
    ),
  );
  final watch = Stopwatch()..start();
  const inserts = 40;
  for (var i = 0; i < inserts; i++) {
    controller.insert(
      TextMessage(
        id: 'n$i',
        author: other,
        createdAt: start.add(Duration(minutes: size + i)),
        text: 'new $i',
      ),
    );
    await tester.pump();
  }
  final cost = watch.elapsedMicroseconds / inserts;
  await tester.pumpWidget(const SizedBox());
  controller.dispose();
  return cost;
}

void main() {
  test('the controller handles 10k messages quickly', () {
    final watch = Stopwatch()..start();
    final controller = ChatController()..insertAll(conversation(10000));
    for (var i = 0; i < 1000; i++) {
      controller.insert(
        TextMessage(
          id: 'n$i',
          author: other,
          createdAt: start.add(Duration(days: 30, seconds: i)),
          text: 'x',
        ),
      );
    }
    expect(controller.length, 11000);
    expect(watch.elapsedMilliseconds, lessThan(1000));
    controller.dispose();
  });

  testWidgets('new messages cost the same in long conversations',
      (tester) async {
    final small = await insertCost(tester, 100);
    final large = await insertCost(tester, 10000);
    // Appending must not depend on the size of the history.
    expect(large, lessThan(small * 2));
  });
}
