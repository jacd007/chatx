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

  test('updates of old messages do not scan the conversation', () {
    final controller = ChatController(messages: conversation(20000));
    addTearDown(controller.dispose);
    final watch = Stopwatch()..start();
    for (var i = 0; i < 20000; i++) {
      controller.updateStatus('m${i % 100}', MessageStatus.read);
      controller.updateStatus('m${i % 100}', null);
    }
    expect(watch.elapsedMilliseconds, lessThan(300));
  });

  test('a page of history is merged, not inserted one by one', () {
    final controller = ChatController(
      messages: [
        for (final m in conversation(20000))
          (m as TextMessage).copyWith(
            id: 'new${m.id}',
            createdAt: m.createdAt.add(const Duration(days: 365)),
          ),
      ],
    );
    addTearDown(controller.dispose);
    final watch = Stopwatch()..start();
    controller.insertAll(conversation(20000));
    expect(watch.elapsedMilliseconds, lessThan(150));
    expect(controller.messages.first.id, 'm0');
    expect(controller.messages.last.id, 'newm19999');
  });

  test('repeated searches do not parse the history again', () {
    final controller = ChatController(messages: conversation(10000));
    addTearDown(controller.dispose);
    final cold = Stopwatch()..start();
    controller.search('message');
    cold.stop();
    final warm = Stopwatch()..start();
    for (final q in ['mes', 'mess', 'messa', 'messag', 'message']) {
      controller.search(q);
    }
    warm.stop();
    expect(
        warm.elapsedMicroseconds / 5, lessThan(cold.elapsedMicroseconds / 3));
  });

  testWidgets('rebuilding the parent costs the same in long conversations',
      (tester) async {
    Future<double> rebuildCost(int size) async {
      final controller = ChatController(messages: conversation(size));
      final tick = ValueNotifier(0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<int>(
              valueListenable: tick,
              builder: (_, value, __) => ChatView(
                controller: controller,
                currentUser: me,
                onSendMessage: (_, __) {},
                readOnlyMessage: 'tick $value',
              ),
            ),
          ),
        ),
      );
      final watch = Stopwatch()..start();
      const rebuilds = 40;
      for (var i = 0; i < rebuilds; i++) {
        tick.value++;
        await tester.pump();
      }
      final cost = watch.elapsedMicroseconds / rebuilds;
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      tick.dispose();
      return cost;
    }

    final small = await rebuildCost(100);
    final large = await rebuildCost(20000);
    expect(large, lessThan(small * 2));
  });
}
