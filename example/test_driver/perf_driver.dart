import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver.dart';

/// Writes frame timing summaries of `integration_test/perf_test.dart` to
/// `build/perf_summary.json` and prints the key numbers.
Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data == null) return;
      final timeline = Timeline.fromJson(
        data['scroll_10k'] as Map<String, dynamic>,
      );
      final summary = TimelineSummary.summarize(timeline);
      await summary.writeTimelineToFile(
        'perf_summary',
        pretty: true,
        includeSummary: true,
      );
      final json = summary.summaryJson;
      final report = {
        for (final key in [
          'average_frame_build_time_millis',
          '90th_percentile_frame_build_time_millis',
          'worst_frame_build_time_millis',
          'average_frame_rasterizer_time_millis',
          '90th_percentile_frame_rasterizer_time_millis',
          'missed_frame_build_budget_count',
          'frame_count',
        ])
          key: json[key],
      };
      stdout.writeln('PERF ${jsonEncode(report)}');
    },
  );
}
