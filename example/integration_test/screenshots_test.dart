// End-to-end walkthrough of the demo app that also captures the screenshots
// used in the README and on pub.dev.
//
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshots_test.dart \
//     -d <iPhone simulator>

import 'package:chatx_example/main.dart';
import 'package:flutter/gestures.dart';
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

  /// Waits in real time while frames keep rendering.
  Future<void> wait(WidgetTester tester, int ms) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    }
  }

  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
      await wait(tester, 100);
    }
  }

  Future<void> waitUntilGone(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 150 && finder.evaluate().isNotEmpty; i++) {
      await wait(tester, 100);
    }
  }

  Future<void> open(WidgetTester tester, String demo) async {
    // Screenshots are in English regardless of the simulator language.
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const ChatxExampleApp());
    await settle(tester);
    await tester.scrollUntilVisible(find.text(demo), 200);
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
    await shoot('36_ai_prompts');
    await tester.tap(find.byKey(const Key('chatx_prompt_0')));
    await wait(tester, 700);
    expect(find.text('Thinking…'), findsOneWidget);
    await shoot('35_ai_reasoning');
    await waitFor(tester, find.byIcon(Icons.check_circle_rounded));
    await wait(tester, 900);
    expect(find.byKey(const Key('chatx_stop_button')), findsOneWidget);
    await shoot('24_ai_stop');
    await waitUntilGone(tester, find.byKey(const Key('chatx_stop_button')));
    await settle(tester, 600);
    await tester.tap(find.byIcon(Icons.thumb_up_outlined).first);
    await settle(tester);
    await shoot('23_ai_code_table');

    await tester.tap(find.byIcon(Icons.refresh_rounded).first);
    await wait(tester, 300);
    await waitUntilGone(tester, find.byKey(const Key('chatx_stop_button')));
    await settle(tester, 600);
    expect(find.text('2/2'), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -2000),
    );
    // Let the floating date fade out.
    await wait(tester, 2200);
    await shoot('37_ai_versions_sources');

    // The earlier version comes back with its own reasoning, tools and
    // sources.
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>)
                .value
                .startsWith('chatx_version_previous_'),
      ),
    );
    await settle(tester);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Searched the chatx docs'), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -2000),
    );
    await wait(tester, 2200);
    await shoot('50_ai_previous_version');
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
    await shoot('26_location_contact_sticker');

    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_link_preview')),
      250,
      scrollable: list,
    );
    await settle(tester, 600);
    await shoot('07_files_links_spoilers');

    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_voice_play_voice1')),
      250,
      scrollable: list,
    );
    await tester.drag(list, const Offset(0, 250));
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

    await tester.tap(find.byKey(const Key('chatx_emoji_button')));
    await settle(tester, 600);
    await tester.tap(find.byKey(const Key('chatx_sticker_pack_faces')));
    await settle(tester, 900);
    await shoot('27_sticker_picker');
    await tester.tap(find.byKey(const Key('chatx_emoji_button')));
    await settle(tester, 600);
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester, 600);

    await tester.tap(find.byKey(const Key('chatx_attach_button')));
    await settle(tester, 600);
    final media = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_video_video')),
      200,
      scrollable: media,
    );
    await settle(tester, 600);
    await shoot('39_video_attachments');

    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_transcribe_voice1')),
      250,
      scrollable: media,
    );
    await tester.drag(media, const Offset(0, -150));
    await settle(tester, 400);
    await tester.tap(find.byKey(const Key('chatx_transcribe_voice1')));
    await wait(tester, 1500);
    await settle(tester, 400);
    await shoot('40_voice_transcript');
  });

  testWidgets('community: survey, poll, mentions, search, selection, thread',
      (tester) async {
    await open(tester, 'Community');
    await shoot('16_survey_seen_forward');

    final communityList = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_bubble_pt')),
      200,
      scrollable: communityList,
    );
    await settle(tester);
    await tester.longPress(find.byKey(const Key('chatx_bubble_pt')));
    await settle(tester);
    await shoot('29_moderation_menu');
    await tester.tap(find.text('Translate'));
    await Future<void>.delayed(const Duration(milliseconds: 900));
    await settle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_edited_edited')),
      -150,
      scrollable: communityList,
    );
    await settle(tester);
    await tester.tap(find.byKey(const Key('chatx_edited_edited')));
    await settle(tester, 700);
    await shoot('30_edit_history');
    await tester.tapAt(const Offset(20, 120));
    await settle(tester, 700);
    await shoot('25_translate_deleted_scheduled');

    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_rsvp_event_going')),
      200,
      scrollable: communityList,
    );
    await tester.tap(find.byKey(const Key('chatx_rsvp_event_going')));
    await settle(tester);
    await shoot('28_event_rsvp');
    final backToBottom = find.byKey(const Key('chatx_scroll_to_bottom'));
    if (backToBottom.hitTestable().evaluate().isNotEmpty) {
      await tester.tap(backToBottom);
      await settle(tester, 700);
    }

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
    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_bubble_drinks')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    await tester.longPress(find.byKey(const Key('chatx_bubble_drinks')));
    await settle(tester);
    // The menu has many entries here: scroll it to "Select".
    await tester.ensureVisible(find.text('Select'));
    await settle(tester, 300);
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

  testWidgets('support bot: slow mode', (tester) async {
    await open(tester, 'Support bot');
    await tester.enterText(
      find.byKey(const Key('chatx_input_field')),
      'Where is my order?',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('chatx_send_button')));
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    await settle(tester);
    await shoot('34_slow_mode');
  });

  testWidgets('announcements: read-only channel', (tester) async {
    await open(tester, 'Announcements');
    await shoot('31_read_only_channel');
  });

  testWidgets('large text and another language', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(tester, 'Media & files');
    await settle(tester, 1000);
    await shoot('32_large_text');
    tester.platformDispatcher.clearTextScaleFactorTestValue();

    tester.platformDispatcher.localesTestValue = const [Locale('de', 'DE')];
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const ChatxExampleApp());
    await settle(tester);
    await tester.tap(find.text('Community'));
    await settle(tester, 900);
    await shoot('33_german');
  });

  testWidgets('workspace: mentions, roles, members, gallery, offline',
      (tester) async {
    await open(tester, 'Workspace');
    await settle(tester, 900);
    await shoot('41_workspace_mentions');

    await tester.tap(find.byKey(const Key('chatx_mentions_button')));
    await settle(tester, 900);
    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('chatx_check_check_c')),
      200,
      scrollable: list,
    );
    await settle(tester, 400);
    await tester.tap(find.byKey(const Key('chatx_check_check_c')));
    await settle(tester, 600);
    await shoot('42_checklist_call');

    await tester.tap(find.byKey(const Key('chatx_header')));
    await settle(tester, 900);
    await shoot('43_members');
    await tester.tap(find.byKey(const Key('chatx_member_bea')));
    await settle(tester, 900);
    await shoot('44_profile');
    await tester.tapAt(const Offset(20, 120));
    await settle(tester, 700);

    await tester.tap(find.byKey(const Key('demo_gallery')));
    await settle(tester, 900);
    await shoot('45_gallery');
    await tester.tapAt(const Offset(20, 60));
    await settle(tester, 700);

    await tester.tap(find.byKey(const Key('demo_network')));
    await settle(tester, 500);
    await tester.enterText(
      find.byKey(const Key('chatx_input_field')),
      'Reviewing it on the train 🚆',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('chatx_send_button')));
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester, 800);
    final bottom = find.byKey(const Key('chatx_scroll_to_bottom'));
    if (bottom.hitTestable().evaluate().isNotEmpty) {
      await tester.tap(bottom);
      await settle(tester, 900);
    }
    await shoot('46_offline_queue');
  });

  testWidgets('support bot: products and payment', (tester) async {
    await open(tester, 'Support bot');
    await tester.tap(find.text('Shop'));
    await wait(tester, 1500);
    await settle(tester, 500);
    await shoot('47_products');
    // Slow mode allows one message every 5 seconds.
    await wait(tester, 4000);
    await tester.tap(find.text('Billing'));
    await wait(tester, 1500);
    await settle(tester, 500);
    await shoot('48_payment');
  });

  testWidgets('desktop: hover actions', (tester) async {
    await open(tester, 'Basic chat');
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1, 1));
    final bubble = find
        .byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('chatx_bubble_'),
        )
        .hitTestable()
        .first;
    await mouse.moveTo(tester.getCenter(bubble));
    await settle(tester, 400);
    await shoot('49_hover_actions');
    await mouse.moveTo(const Offset(1, 1));
    await mouse.removePointer();
    await settle(tester, 300);
  });
}
