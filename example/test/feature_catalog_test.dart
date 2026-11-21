import 'package:chatx_example/features/ai_features.dart';
import 'package:chatx_example/features/all_features_page.dart';
import 'package:chatx_example/features/appearance_features.dart';
import 'package:chatx_example/features/community_features.dart';
import 'package:chatx_example/features/content_features.dart';
import 'package:chatx_example/features/media_features.dart';
import 'package:chatx_example/features/messaging_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Opens every demo of the catalog and fails on any exception, so a demo
// never breaks unnoticed.
void main() {
  final groups = [
    messagingFeatures,
    mediaFeatures,
    contentFeatures,
    aiFeatures,
    communityFeatures,
    appearanceFeatures,
  ];

  Future<void> open(WidgetTester tester, WidgetBuilder builder) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Builder(builder: builder)));
    // Let streams, typing and uploads of the demo run.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    // Closing the demo must cancel its timers and streams.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  }

  for (final group in groups) {
    for (final demo in group.demos) {
      testWidgets('${group.title}: ${demo.title}', (tester) async {
        await open(tester, demo.builder);
      });
    }
  }

  testWidgets('All features', (tester) async {
    await open(tester, (_) => const AllFeaturesPage());
  });
}
