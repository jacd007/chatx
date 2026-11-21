// End-to-end walkthrough of the demo app that also captures the screenshots
// used in the README and on pub.dev.
//
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshots_test.dart \
//     -d <iPhone simulator>

import 'package:chatx_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shoot(String name) async {
    await binding.convertFlutterSurfaceToImage();
    await binding.takeScreenshot(name);
  }

  Future<void> settle(WidgetTester tester, [int ms = 600]) async {
    await tester.pump(Duration(milliseconds: ms));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> open(WidgetTester tester, String demo) async {
    // Screenshots are in English regardless of the simulator language.
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const ChatxExampleApp());
    await settle(tester);
    await tester.tap(find.text(demo));
    await settle(tester, 900);
  }

  testWidgets('basic chat: conversation, popup menu and swipe to reply',
      (tester) async {
    await open(tester, 'Basic chat');
    await shoot('01_conversation');

    await tester.tap(find.byKey(const Key('chatx_bubble_m4')));
    await settle(tester);
    expect(find.byKey(const Key('chatx_react_❤️')), findsOneWidget);
    await shoot('02_popup_menu');

    await tester.tap(find.byKey(const Key('chatx_react_❤️')));
    await settle(tester);

    await tester.timedDrag(
      find.byKey(const Key('chatx_bubble_m4')),
      const Offset(140, 0),
      const Duration(milliseconds: 400),
    );
    await settle(tester);
    expect(find.byKey(const Key('chatx_reply_banner')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('chatx_input_field')),
      'Swipe to reply works great 🙌',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await shoot('03_reply');

    await tester.tap(find.byKey(const Key('chatx_send_button')));
    await settle(tester, 3500);
  });

  testWidgets('AI streaming', (tester) async {
    await open(tester, 'AI streaming');
    await tester.enterText(
      find.byKey(const Key('chatx_input_field')),
      'Summarize chatx for me',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('chatx_send_button')));
    // Let the "thinking" pause pass and part of the answer stream in.
    FocusManager.instance.primaryFocus?.unfocus();
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await shoot('04_ai_markdown');
  });

  testWidgets('bubble styles', (tester) async {
    await open(tester, 'Bubble styles');
    await tester.tap(find.text('Top'));
    await tester.tap(find.text('Shadow'));
    await settle(tester);
    await shoot('05_bubble_styles');
  });

  testWidgets('dark mode', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await open(tester, 'Custom look');
    await shoot('06_dark_custom_look');
  });
}
