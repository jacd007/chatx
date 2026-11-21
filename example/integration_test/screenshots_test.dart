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
    // Wait for Ana's reply to start: the header switches to "typing…".
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('typing…').evaluate().isNotEmpty) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 300));
    await shoot('22_header_typing');
    await settle(tester, 2500);
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

  testWidgets('media: files, links, spoilers, images, voice', (tester) async {
    await open(tester, 'Media & files');
    await settle(tester, 1200);
    await shoot('07_files_links_spoilers');

    await tester.timedDrag(
      find.byType(ListView),
      const Offset(0, 700),
      const Duration(milliseconds: 600),
    );
    await settle(tester, 800);
    await tester.tap(find.byKey(const Key('chatx_voice_play_voice1')));
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    await settle(tester);
    await shoot('08_images_voice');

    await tester.tap(find.byKey(const Key('chatx_image_trip_0')));
    await settle(tester, 900);
    await shoot('09_image_viewer');
    await tester.tap(find.byKey(const Key('chatx_viewer_close')));
    await settle(tester, 900);

    // Start recording through the accessibility action, so no test pointer
    // is drawn on the screenshot.
    final semantics = tester.ensureSemantics();
    final mic = find.semantics.byLabel('Hold to record a voice message');
    tester.semantics.tap(mic);
    await Future<void>.delayed(const Duration(milliseconds: 2300));
    await settle(tester);
    await shoot('10_voice_recording');
    tester.semantics.tap(mic);
    await settle(tester);
    semantics.dispose();
  });

  testWidgets('community: survey, poll, mentions, search, selection, thread',
      (tester) async {
    await open(tester, 'Community');
    await shoot('16_survey_seen_forward');

    await tester.tap(find.byKey(const Key('chatx_survey_survey')));
    await settle(tester, 700);
    final next = find.byKey(const Key('chatx_survey_next'));
    await tester.tap(find.byKey(const Key('chatx_survey_rating_5')));
    await settle(tester);
    await tester.tap(next);
    await settle(tester, 500);
    await tester.tap(find.byKey(const Key('chatx_survey_choice_music')));
    await tester.tap(find.byKey(const Key('chatx_survey_choice_people')));
    await settle(tester);
    await tester.tap(next);
    await settle(tester, 500);
    await tester.tap(find.byKey(const Key('chatx_survey_nps_9')));
    await settle(tester);
    await shoot('17_survey_nps');
    await tester.tap(next);
    await settle(tester, 500);
    await tester.tap(next);
    await settle(tester, 900);

    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_poll_poll_pizza')),
      250,
      scrollable: list,
    );
    await tester.tap(find.byKey(const Key('chatx_poll_poll_pizza')));
    await settle(tester, 1200);
    await shoot('11_poll_countdown_pinned');

    final field = find.byKey(const Key('chatx_input_field'));
    await tester.enterText(field, 'Count me in! @');
    await settle(tester);
    expect(find.byKey(const Key('chatx_mention_leo')), findsOneWidget);
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await shoot('12_mentions');
    await tester.tap(find.byKey(const Key('chatx_mention_leo')));
    await tester.enterText(field, '');
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);

    await tester.tap(find.byKey(const Key('demo_search')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const Key('chatx_search_field')),
      'rooftop',
    );
    await settle(tester, 900);
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester, 600);
    await shoot('13_search');
    await tester.tap(find.byKey(const Key('chatx_search_close')));
    await settle(tester);

    final toBottom = find.byKey(const Key('chatx_scroll_to_bottom'));
    if (toBottom.hitTestable().evaluate().isNotEmpty) {
      await tester.tap(toBottom);
      await settle(tester, 700);
    }
    await tester.longPress(find.byKey(const Key('chatx_bubble_drinks')));
    await settle(tester);
    await tester.tap(find.text('Select'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('chatx_bubble_forwarded')));
    await settle(tester);
    await shoot('14_selection');
    await tester.tap(find.byKey(const Key('chatx_selection_close')));
    await settle(tester);

    final drag = await tester.startGesture(const Offset(200, 450));
    for (var i = 0; i < 14; i++) {
      await drag.moveBy(const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await settle(tester, 100);
    await shoot('15_floating_date');
    await drag.up();
    await settle(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_thread_old9')),
      250,
      scrollable: list,
    );
    await tester.tap(find.byKey(const Key('chatx_thread_old9')));
    await settle(tester, 900);
    await shoot('19_thread');
  });

  testWidgets('support bot: buttons, quick replies, disappearing code',
      (tester) async {
    await open(tester, 'Support bot');
    await shoot('18_bot_buttons');
    await tester.tap(find.text('📦 Track my order'));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const Key('chatx_expiry')).evaluate().isNotEmpty) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await settle(tester, 800);
    await shoot('20_bot_disappearing');

    await tester.tap(find.byKey(const Key('chatx_emoji_button')));
    await settle(tester, 600);
    await tester.tap(find.byKey(const Key('chatx_emoji_😀')));
    await tester.tap(find.byKey(const Key('chatx_emoji_😍')));
    await settle(tester);
    await shoot('21_emoji_picker');
  });
}
