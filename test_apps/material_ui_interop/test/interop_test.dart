import 'package:chatx/chatx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const me = ChatUser(id: 'me');
const seed = Color(0xFF7C3AED);

Widget app(
  ChatController controller, {
  required bool bridge,
  Locale? locale,
  ChatMessageMenuStyle menuStyle = ChatMessageMenuStyle.bottomSheet,
}) {
  return MaterialApp(
    theme: ThemeData(colorSchemeSeed: seed),
    locale: locale,
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('en'), Locale('es')],
    builder: bridge
        ? (context, child) => MaterialUiCompatibilityBridge(child: child!)
        : null,
    home: Scaffold(
      body: ChatView(
        controller: controller,
        currentUser: me,
        onReactionSelected: (m, emoji) =>
            controller.toggleReaction(m.id, emoji, me.id),
        messageMenuStyle: menuStyle,
        onSendMessage: (text, replyTo) => controller.insert(
          TextMessage(
            id: text,
            author: me,
            createdAt: DateTime.now(),
            text: text,
          ),
        ),
      ),
    ),
  );
}

void main() {
  late ChatController controller;

  setUp(() => controller = ChatController());
  tearDown(() => controller.dispose());

  testWidgets('works with the bridge and inherits the app theme', (
    tester,
  ) async {
    await tester.pumpWidget(app(controller, bridge: true));

    await tester.enterText(find.byKey(const Key('chatx_input_field')), 'hi');
    await tester.pump();
    await tester.tap(find.byKey(const Key('chatx_send_button')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final bubble = tester.widget<Widget>(
      find.byKey(const Key('chatx_bubble_hi')),
    );
    final color = (bubble as dynamic).color as Color;
    expect(color, ThemeData(colorSchemeSeed: seed).colorScheme.primary);
  });

  testWidgets('uses the app locale through the bridge', (tester) async {
    controller.insert(
      TextMessage(id: '1', author: me, createdAt: DateTime.now(), text: 'hola'),
    );
    await tester.pumpWidget(
      app(controller, bridge: true, locale: const Locale('es')),
    );
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Mensaje'), findsOneWidget);
  });

  testWidgets('long-press menu opens through the bridge', (tester) async {
    controller.insert(
      TextMessage(id: '1', author: me, createdAt: DateTime.now(), text: 'x'),
    );
    await tester.pumpWidget(app(controller, bridge: true));
    await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Copy text'), findsOneWidget);
  });

  testWidgets('popup menu, reactions and swipe work through the bridge', (
    tester,
  ) async {
    controller.insert(
      TextMessage(
        id: '1',
        author: const ChatUser(id: 'ana', name: 'Ana'),
        createdAt: DateTime.now(),
        text: 'hey',
      ),
    );
    await tester.pumpWidget(
      app(controller, bridge: true, menuStyle: ChatMessageMenuStyle.popup),
    );
    await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatx_react_👍')));
    await tester.pumpAndSettle();
    expect(controller.messageById('1')!.reactions.single.emoji, '👍');

    await tester.drag(
      find.byKey(const Key('chatx_bubble_1')),
      const Offset(120, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Replying to Ana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
