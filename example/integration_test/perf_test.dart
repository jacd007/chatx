// Scrolls a 10,000-message conversation and records frame timings.
//
//   flutter drive --profile -d macos \
//     --driver=test_driver/perf_driver.dart \
//     --target=integration_test/perf_test.dart

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scroll 10k messages', (tester) async {
    const me = ChatUser(id: 'me', name: 'Me');
    const ana = ChatUser(id: 'ana', name: 'Ana');
    final start = DateTime(2026, 1, 1);
    final controller = ChatController(
      messages: [
        for (var i = 0; i < 10000; i++)
          TextMessage(
            id: 'm$i',
            author: i % 3 == 0 ? me : ana,
            createdAt: start.add(Duration(minutes: i * 7)),
            text: i % 5 == 0
                ? 'Message **$i** with `code`, a link https://dart.dev '
                    'and enough words to wrap over a couple of lines.'
                : 'Message $i',
            reactions: i % 11 == 0
                ? const [
                    ChatReaction(emoji: '👍', userIds: ['me'])
                  ]
                : const [],
            status: i % 3 == 0 ? MessageStatus.read : null,
          ),
      ],
    );
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
    await tester.pumpAndSettle();
    final list = find.byType(CustomScrollView).first;

    await binding.traceAction(
      () async {
        for (var i = 0; i < 6; i++) {
          await tester.fling(list, const Offset(0, 900), 4000);
          await tester.pumpAndSettle();
        }
        for (var i = 0; i < 6; i++) {
          await tester.fling(list, const Offset(0, -900), 4000);
          await tester.pumpAndSettle();
        }
      },
      reportKey: 'scroll_10k',
    );
    controller.dispose();
  });
}
