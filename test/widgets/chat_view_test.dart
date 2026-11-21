import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana');

TextMessage message(
  String id, {
  ChatUser author = ana,
  String? text,
  DateTime? at,
  MessageStatus? status,
}) {
  return TextMessage(
    id: id,
    author: author,
    createdAt: at ?? DateTime.now(),
    text: text ?? 'text $id',
    status: status,
  );
}

Future<void> pumpChat(
  WidgetTester tester, {
  required ChatController controller,
  ValueChanged<String>? onSend,
  Future<bool> Function()? onLoadMore,
  ValueChanged<ChatMessage>? onRetry,
  ValueChanged<Uri>? onLinkTap,
  ChatTheme? theme,
  Locale? locale,
  ChatMessageActionsBuilder? actionsBuilder,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('es')],
      // ignore: deprecated_member_use, matches the Material library chatx uses.
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(
        body: ChatView(
          controller: controller,
          currentUser: me,
          onSendMessage: (text, _) => onSend?.call(text),
          onLoadMore: onLoadMore,
          onRetry: onRetry,
          onLinkTap: onLinkTap,
          theme: theme,
          messageActionsBuilder: actionsBuilder,
        ),
      ),
    ),
  );
}

List<TapGestureRecognizer> linkRecognizers(InlineSpan root) {
  final found = <TapGestureRecognizer>[];
  void walk(InlineSpan span) {
    if (span is! TextSpan) return;
    final recognizer = span.recognizer;
    if (recognizer is TapGestureRecognizer) found.add(recognizer);
    span.children?.forEach(walk);
  }

  walk(root);
  return found;
}

Finder statusIcon(String label) => find.byWidgetPredicate(
      (w) => w is Icon && w.semanticLabel == label,
    );

void main() {
  late ChatController controller;

  setUp(() => controller = ChatController());
  tearDown(() => controller.dispose());

  testWidgets('shows the empty state', (tester) async {
    await pumpChat(tester, controller: controller);
    expect(find.text(ChatLocalizations.en.emptyState), findsOneWidget);
  });

  testWidgets('renders messages with markdown', (tester) async {
    controller.insert(message('1', text: 'Hello **world**'));
    await pumpChat(tester, controller: controller);
    expect(
        find.textContaining('Hello world', findRichText: true), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('sends trimmed text and clears the field', (tester) async {
    final sent = <String>[];
    await pumpChat(tester, controller: controller, onSend: sent.add);

    final field = find.byKey(const Key('chatx_input_field'));
    await tester.enterText(field, '   ');
    await tester.tap(find.byKey(const Key('chatx_send_button')));
    expect(sent, isEmpty);

    await tester.enterText(field, '  hi there  ');
    await tester.pump();
    await tester.tap(find.byKey(const Key('chatx_send_button')));
    await tester.pump();
    expect(sent, ['hi there']);
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
  });

  testWidgets('Enter sends on desktop, Shift+Enter does not', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final sent = <String>[];
    await pumpChat(tester, controller: controller, onSend: sent.add);

    final field = find.byKey(const Key('chatx_input_field'));
    await tester.tap(field);
    await tester.enterText(field, 'hello');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(sent, isEmpty);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(sent, ['hello']);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('status updates rebuild the bubble in place', (tester) async {
    controller.insert(message('1', author: me, status: MessageStatus.sending));
    await pumpChat(tester, controller: controller);
    expect(statusIcon('Sending'), findsOneWidget);

    controller.updateStatus('1', MessageStatus.read);
    await tester.pumpAndSettle();
    expect(statusIcon('Read'), findsOneWidget);
  });

  testWidgets('failed messages offer retry', (tester) async {
    final retried = <String>[];
    controller.insert(message('1', author: me, status: MessageStatus.failed));
    await pumpChat(
      tester,
      controller: controller,
      onRetry: (m) => retried.add(m.id),
    );
    await tester.tap(find.byKey(const Key('chatx_retry_1')));
    expect(retried, ['1']);
  });

  testWidgets('streams text into a single bubble', (tester) async {
    controller.insert(
      TextMessage(
        id: 'bot',
        author: ana,
        createdAt: DateTime.now(),
        text: '',
        isStreaming: true,
      ),
    );
    await pumpChat(tester, controller: controller);
    expect(find.byType(TypingDots), findsOneWidget);

    controller.appendText('bot', 'Thinking');
    await tester.pump();
    expect(find.textContaining('Thinking', findRichText: true), findsOneWidget);

    controller.completeStream('bot');
    await tester.pumpAndSettle();
    expect(find.byType(TypingDots), findsNothing);
  });

  testWidgets('typing indicator follows controller state', (tester) async {
    await pumpChat(tester, controller: controller);
    controller.setTyping(ana, isTyping: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Ana is typing…'), findsOneWidget);

    controller.setTyping(ana, isTyping: false);
    await tester.pumpAndSettle();
    expect(find.byType(TypingIndicator), findsNothing);
  });

  testWidgets('the current user is never shown as typing', (tester) async {
    await pumpChat(tester, controller: controller);
    controller.setTyping(me, isTyping: true);
    await tester.pumpAndSettle();
    expect(find.byType(TypingIndicator), findsNothing);
  });

  testWidgets('allowed links call onLinkTap', (tester) async {
    final taps = <Uri>[];
    controller.insert(message('1', text: 'https://dart.dev'));
    await pumpChat(tester, controller: controller, onLinkTap: taps.add);

    final text = find.textContaining('https://dart.dev', findRichText: true);
    final recognizers = linkRecognizers(tester.widget<RichText>(text).text);
    expect(recognizers, hasLength(1));
    recognizers.single.onTap!();
    expect(taps, [Uri.parse('https://dart.dev')]);
  });

  testWidgets('disallowed links are never tappable', (tester) async {
    controller.insert(message('1', text: '[click](javascript:alert(1))'));
    await pumpChat(tester, controller: controller, onLinkTap: (_) {});
    final rich = tester.widget<RichText>(
      find.textContaining('click', findRichText: true),
    );
    expect(linkRecognizers(rich.text), isEmpty);
  });

  testWidgets('long press shows actions', (tester) async {
    final selected = <String>[];
    controller.insert(message('1'));
    await pumpChat(
      tester,
      controller: controller,
      actionsBuilder: (context, m, defaults) => [
        ChatMessageAction(
            label: 'Reply', onSelected: (m) => selected.add(m.id)),
      ],
    );
    await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();
    expect(selected, ['1']);
  });

  testWidgets('loads older messages until there are no more', (tester) async {
    var calls = 0;
    controller.insert(message('latest'));
    await pumpChat(
      tester,
      controller: controller,
      onLoadMore: () async {
        calls++;
        controller.insertAll([
          message(
            'old$calls',
            at: DateTime.now().subtract(Duration(minutes: calls)),
          ),
        ]);
        return calls < 2;
      },
    );
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(controller.length, 3);
  });

  testWidgets('shows a retry button when loading fails', (tester) async {
    var fail = true;
    await pumpChat(
      tester,
      controller: controller,
      onLoadMore: () async {
        if (fail) throw StateError('offline');
        return false;
      },
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isA<StateError>());
    expect(find.byKey(const Key('chatx_load_more_retry')), findsOneWidget);

    fail = false;
    await tester.tap(find.byKey(const Key('chatx_load_more_retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatx_load_more_retry')), findsNothing);
  });

  testWidgets('scroll-to-bottom button counts unread messages', (tester) async {
    final start = DateTime.now().subtract(const Duration(hours: 1));
    controller.insertAll([
      for (var i = 0; i < 40; i++)
        message('m$i', at: start.add(Duration(seconds: i))),
    ]);
    await pumpChat(tester, controller: controller);

    await tester.drag(find.byType(ListView), const Offset(0, 1500));
    await tester.pumpAndSettle();
    final button = find.byKey(const Key('chatx_scroll_to_bottom'));
    expect(button.hitTestable(), findsOneWidget);

    controller.insert(message('new'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(button.hitTestable(), findsNothing);
  });

  testWidgets('uses Spanish strings for the es locale', (tester) async {
    await pumpChat(tester, controller: controller, locale: const Locale('es'));
    expect(find.text(ChatLocalizations.es.emptyState), findsOneWidget);
  });

  testWidgets('theme overrides reach the bubbles', (tester) async {
    controller.insert(message('1'));
    await pumpChat(
      tester,
      controller: controller,
      theme: const ChatTheme(incomingBubbleColor: Color(0xFF123456)),
    );
    final material = tester.widget<Material>(
      find.byKey(const Key('chatx_bubble_1')),
    );
    expect(material.color, const Color(0xFF123456));
  });

  testWidgets('groups consecutive messages of one author', (tester) async {
    final now = DateTime.now();
    controller.insertAll([
      message('1', at: now.subtract(const Duration(minutes: 2))),
      message('2', at: now.subtract(const Duration(minutes: 1))),
      message('3', author: me, at: now),
    ]);
    await pumpChat(tester, controller: controller);
    expect(find.text('Ana'), findsOneWidget, reason: 'name once per group');
    expect(find.byType(ChatAvatar), findsOneWidget, reason: 'avatar once');
  });

  testWidgets('meets tap target and labeling guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    controller.insert(message('1', author: me, status: MessageStatus.sent));
    await pumpChat(tester, controller: controller);
    await tester.enterText(find.byKey(const Key('chatx_input_field')), 'x');
    await tester.pump();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('mirrors outgoing bubbles in right-to-left layouts',
      (tester) async {
    controller.insert(message('1', author: me));
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: ChatView(
              controller: controller,
              currentUser: me,
              onSendMessage: (_, __) {},
            ),
          ),
        ),
      ),
    );
    final bubble = tester.getRect(find.byKey(const Key('chatx_bubble_1')));
    final screen = tester.getRect(find.byType(ChatView));
    expect(bubble.left - screen.left, lessThan(screen.right - bubble.right));
  });

  testWidgets('lays out without overflow at 2x text scale', (tester) async {
    controller.insertAll([
      message('1', text: 'A fairly long message that needs to wrap lines'),
      message('2', author: me, status: MessageStatus.failed),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: ChatView(
              controller: controller,
              currentUser: me,
              onSendMessage: (_, __) {},
              onRetry: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
