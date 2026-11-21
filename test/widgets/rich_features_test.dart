import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana Ruiz');
const leo = ChatUser(id: 'leo', name: 'Leo');

// A 1x1 transparent PNG so image tests never touch the network.
final Uint8List _pixel = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

DateTime ago(int minutes) =>
    DateTime.now().subtract(Duration(minutes: minutes));

void main() {
  late ChatController controller;
  setUp(() => controller = ChatController());
  tearDown(() => controller.dispose());

  Future<void> pump(
    WidgetTester tester, {
    ChatPollVoteCallback? onPollVote,
    ValueChanged<FileMessage>? onFileTap,
    ValueChanged<VoiceMessage>? onVoicePlay,
    ValueListenable<ChatVoicePlayback?>? voicePlayback,
    VoidCallback? onRecordStart,
    ChatVoiceRecordEndCallback? onRecordEnd,
    ValueChanged<ChatUser>? onMentionTap,
    ChatSearchController? search,
    ValueChanged<Uri>? onLinkTap,
    ValueChanged<ChatMessage>? onDelete,
    ChatPinCallback? onPin,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            controller: controller,
            currentUser: me,
            onSend: (_) {},
            builders: ChatBuilders(
              imageProviderBuilder: (_) => MemoryImage(_pixel),
            ),
            contentCallbacks: ChatContentCallbacks(
              onPollVote: onPollVote,
            ),
            media: ChatMediaOptions(
              onFileTap: onFileTap,
              onVoicePlay: onVoicePlay,
              voicePlayback: voicePlayback,
              onVoiceRecordStart: onRecordStart,
              onVoiceRecordEnd: onRecordEnd,
            ),
            mentionableUsers: const [me, ana, leo],
            onMentionTap: onMentionTap,
            searchController: search,
            onLinkTap: onLinkTap,
            onDeleteMessage: onDelete,
            onPinMessage: onPin,
          ),
        ),
      ),
    );
  }

  group('images', () {
    testWidgets('shows up to four tiles and a +N counter', (tester) async {
      controller.insert(
        ImageMessage(
          id: 'img',
          author: ana,
          createdAt: ago(1),
          images: [for (var i = 0; i < 6; i++) ChatImage(uri: 'u$i')],
        ),
      );
      await pump(tester);
      expect(find.byKey(const Key('chatx_image_img_3')), findsOneWidget);
      expect(find.byKey(const Key('chatx_image_img_4')), findsNothing);
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('tapping opens the viewer, which closes again', (tester) async {
      controller.insert(
        ImageMessage(
          id: 'img',
          author: ana,
          createdAt: ago(1),
          images: const [ChatImage(uri: 'a'), ChatImage(uri: 'b')],
        ),
      );
      await pump(tester);
      await tester.tap(find.byKey(const Key('chatx_image_img_1')));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_viewer_close')));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsNothing);
    });

    testWidgets('spoiler images are blurred until tapped', (tester) async {
      controller.insert(
        ImageMessage(
          id: 'img',
          author: ana,
          createdAt: ago(1),
          images: const [ChatImage(uri: 'a')],
          isSpoiler: true,
        ),
      );
      await pump(tester);
      ImageFiltered filter() => tester.widget(find.byType(ImageFiltered));
      expect(filter().enabled, isTrue);
      await tester.tap(find.byKey(const Key('chatx_spoiler_img')));
      await tester.pump();
      expect(filter().enabled, isFalse);
    });

    testWidgets('upload progress is shown', (tester) async {
      controller.insert(
        ImageMessage(
          id: 'img',
          author: me,
          createdAt: ago(1),
          images: const [ChatImage(uri: 'a')],
          uploadProgress: 0.4,
        ),
      );
      await pump(tester);
      await tester.pump(const Duration(milliseconds: 400));
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, closeTo(0.4, 0.001));
    });
  });

  testWidgets('files show name and size and report taps', (tester) async {
    final tapped = <String>[];
    controller.insert(
      FileMessage(
        id: 'f',
        author: ana,
        createdAt: ago(1),
        name: 'Budget.xlsx',
        sizeBytes: 2516582,
      ),
    );
    await pump(tester, onFileTap: (m) => tapped.add(m.id));
    expect(find.text('Budget.xlsx'), findsOneWidget);
    expect(find.text('XLSX · 2.4 MB'), findsOneWidget);
    await tester.tap(find.byKey(const Key('chatx_bubble_f')));
    expect(tapped, ['f']);
  });

  testWidgets('voice notes follow the reported playback', (tester) async {
    final played = <String>[];
    final playback = ValueNotifier<ChatVoicePlayback?>(null);
    addTearDown(playback.dispose);
    controller.insert(
      VoiceMessage(
        id: 'v',
        author: ana,
        createdAt: ago(1),
        uri: 'a.m4a',
        duration: const Duration(seconds: 42),
        waveform: const [0.2, 0.8, 0.5],
      ),
    );
    await pump(tester,
        onVoicePlay: (m) => played.add(m.id), voicePlayback: playback);
    expect(find.text('0:42'), findsOneWidget);
    await tester.tap(find.byKey(const Key('chatx_voice_play_v')));
    expect(played, ['v']);

    playback.value = const ChatVoicePlayback(
      messageId: 'v',
      position: Duration(seconds: 7),
      isPlaying: true,
    );
    await tester.pump();
    expect(find.text('0:07'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });

  testWidgets('holding the mic records; sliding away cancels', (tester) async {
    final events = <String>[];
    await pump(
      tester,
      onRecordStart: () => events.add('start'),
      onRecordEnd: (d, {required cancelled}) =>
          events.add(cancelled ? 'cancel' : 'send'),
    );
    final mic = find.byKey(const Key('chatx_record_button'));

    var gesture = await tester.startGesture(tester.getCenter(mic));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('chatx_recording_indicator')), findsOneWidget);
    await gesture.up();
    await tester.pump();

    gesture = await tester.startGesture(tester.getCenter(mic));
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(events, ['start', 'send', 'start', 'cancel']);
  });

  testWidgets('polls report votes and reveal results', (tester) async {
    controller.insert(
      PollMessage(
        id: 'p',
        author: ana,
        createdAt: ago(1),
        question: 'Lunch?',
        options: const [
          PollOption(id: 'a', text: 'Pizza', voterIds: ['ana']),
          PollOption(id: 'b', text: 'Tacos'),
        ],
      ),
    );
    await pump(
      tester,
      onPollVote: (m, option) => controller.votePoll(m.id, option, me.id),
    );
    expect(find.text('50%'), findsNothing, reason: 'hidden until voting');
    await tester.tap(find.byKey(const Key('chatx_poll_p_b')));
    await tester.pumpAndSettle();
    expect(find.text('50%'), findsNWidgets(2));
    expect(find.text('2 votes'), findsOneWidget);
  });

  testWidgets('countdowns tick and complete', (tester) async {
    controller.insert(
      CountdownMessage(
        id: 'c',
        author: ana,
        createdAt: ago(1),
        title: 'Launch',
        endsAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
      ),
    );
    controller.insert(
      CountdownMessage(
        id: 'done',
        author: ana,
        createdAt: ago(1),
        title: 'Webinar',
        endsAt: ago(5),
      ),
    );
    await pump(tester);
    expect(find.text('Launch'), findsOneWidget);
    expect(find.text('days'), findsOneWidget);
    expect(find.text('02'), findsOneWidget, reason: 'two days left');
    expect(find.text("It's time!"), findsOneWidget);
  });

  testWidgets('link previews open the link', (tester) async {
    final taps = <Uri>[];
    controller.insert(
      TextMessage(
        id: 't',
        author: ana,
        createdAt: ago(1),
        text: 'Look',
        linkPreview: const ChatLinkPreview(
          url: 'https://flutter.dev',
          title: 'Flutter',
          description: 'Build apps for any screen',
        ),
      ),
    );
    await pump(tester, onLinkTap: taps.add);
    expect(find.text('flutter.dev'), findsOneWidget);
    await tester.tap(find.byKey(const Key('chatx_link_preview')));
    expect(taps, [Uri.parse('https://flutter.dev')]);
  });

  testWidgets('inline spoilers reveal on tap', (tester) async {
    controller.insert(
      TextMessage(
          id: 't', author: ana, createdAt: ago(1), text: 'It was ||Bob||'),
    );
    await pump(tester);
    TextSpan spoiler() {
      late TextSpan found;
      final rich = tester.widget<RichText>(
        find.textContaining('It was', findRichText: true),
      );
      void walk(InlineSpan span) {
        if (span is TextSpan) {
          if (span.text == 'Bob') found = span;
          span.children?.forEach(walk);
        }
      }

      walk(rich.text);
      return found;
    }

    expect(spoiler().recognizer, isNotNull);
    (spoiler().recognizer! as TapGestureRecognizer).onTap!();
    await tester.pump();
    expect(spoiler().recognizer, isNull);
  });

  testWidgets('mentions are styled and tappable, and the input suggests them',
      (tester) async {
    final mentioned = <String>[];
    controller.insert(
      TextMessage(
          id: 't', author: leo, createdAt: ago(1), text: 'Hi @Ana Ruiz!'),
    );
    await pump(tester, onMentionTap: (u) => mentioned.add(u.id));

    final rich = tester.widget<RichText>(
      find.textContaining('Ana Ruiz', findRichText: true),
    );
    TextSpan? mention;
    void walk(InlineSpan span) {
      if (span is TextSpan) {
        if (span.text == '@Ana Ruiz') mention = span;
        span.children?.forEach(walk);
      }
    }

    walk(rich.text);
    (mention!.recognizer! as TapGestureRecognizer).onTap!();
    expect(mentioned, ['ana']);

    final field = find.byKey(const Key('chatx_input_field'));
    await tester.enterText(field, 'Thanks @an');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatx_mention_ana')), findsOneWidget);
    expect(find.byKey(const Key('chatx_mention_me')), findsNothing);
    await tester.tap(find.byKey(const Key('chatx_mention_ana')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(field).controller!.text,
      'Thanks @Ana Ruiz ',
    );
  });

  testWidgets('search highlights matches and counts results', (tester) async {
    controller.insertAll([
      TextMessage(id: '1', author: ana, createdAt: ago(3), text: 'Pizza night'),
      TextMessage(id: '2', author: me, createdAt: ago(2), text: 'More pizza!'),
    ]);
    final search = ChatSearchController(chatController: controller);
    addTearDown(search.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: ChatSearchBar(controller: search)),
          body: ChatView(
            controller: controller,
            currentUser: me,
            onSend: (_) {},
            searchController: search,
          ),
        ),
      ),
    );
    await tester.enterText(
        find.byKey(const Key('chatx_search_field')), 'pizza');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);

    final rich = tester.widget<RichText>(
      find.textContaining('Pizza night', findRichText: true),
    );
    var highlighted = false;
    void walk(InlineSpan span) {
      if (span is TextSpan) {
        if (span.text == 'Pizza' && span.style?.backgroundColor != null) {
          highlighted = true;
        }
        span.children?.forEach(walk);
      }
    }

    walk(rich.text);
    expect(highlighted, isTrue);
    await tester.tap(find.byKey(const Key('chatx_search_older')));
    await tester.pumpAndSettle();
    expect(find.text('2/2'), findsOneWidget);
  });

  testWidgets('pinned banner jumps to the pinned message', (tester) async {
    controller.insertAll([
      for (var i = 0; i < 30; i++)
        TextMessage(
          id: 'm$i',
          author: ana,
          createdAt: ago(60 - i),
          text: 'message $i',
        ),
    ]);
    controller.pin('m0');
    await pump(tester);
    expect(find.byKey(const Key('chatx_pinned_banner')), findsOneWidget);
    expect(find.text('message 0'), findsWidgets);
    await tester.tap(find.byKey(const Key('chatx_pinned_banner')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('chatx_bubble_m0')).hitTestable(), findsOneWidget);
  });

  testWidgets('selection mode: select, copy and delete', (tester) async {
    final deleted = <String>[];
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    controller.insertAll([
      TextMessage(id: '1', author: me, createdAt: ago(3), text: 'one'),
      TextMessage(id: '2', author: me, createdAt: ago(2), text: 'two'),
    ]);
    await pump(tester, onDelete: (m) => deleted.add(m.id));

    await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatx_bubble_2')));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.byKey(const Key('chatx_selection_action_0')));
    await tester.pumpAndSettle();
    expect(clipboard, 'one\n\ntwo');
    expect(controller.isSelecting, isFalse);

    controller
      ..toggleSelection('1')
      ..toggleSelection('2');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatx_selection_action_1')));
    await tester.pumpAndSettle();
    expect(deleted, ['1', '2']);
  });

  testWidgets('the menu offers pin and unpin', (tester) async {
    final pins = <(String, bool)>[];
    controller.insert(
      TextMessage(id: '1', author: ana, createdAt: ago(1), text: 'x'),
    );
    await pump(tester, onPin: (m, pinned) {
      pins.add((m.id, pinned));
      pinned ? controller.pin(m.id) : controller.unpin(m.id);
    });
    await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pin'));
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unpin'));
    await tester.pumpAndSettle();
    expect(pins, [('1', true), ('1', false)]);
  });

  testWidgets('a date chip floats while scrolling', (tester) async {
    controller.insertAll([
      for (var i = 0; i < 40; i++)
        TextMessage(
          id: 'm$i',
          author: ana,
          createdAt: DateTime(2026, 3, 1 + i ~/ 10, 12, i),
          text: 'message $i',
        ),
    ]);
    await pump(tester);
    final gesture = await tester.startGesture(const Offset(200, 300));
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();
    }
    expect(find.byKey(const Key('chatx_floating_date')), findsOneWidget);
    await gesture.up();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatx_floating_date')), findsNothing);
  });
}
