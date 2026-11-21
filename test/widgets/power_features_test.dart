import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:chatx/src/markdown/markdown_parser.dart';
import 'package:chatx/src/markdown/syntax_highlighter.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana');
const bot = ChatUser(id: 'bot', name: 'Assistant', isBot: true);

DateTime ago(int minutes) =>
    DateTime.now().subtract(Duration(minutes: minutes));

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

void main() {
  late ChatController controller;
  setUp(() => controller = ChatController());
  tearDown(() => controller.dispose());

  Future<void> pump(WidgetTester tester, ChatView Function() build) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: build())));

  ChatView view({
    ValueChanged<TextMessage>? onRegenerate,
    ChatFeedbackCallback? onFeedback,
    ValueChanged<TextMessage>? onStop,
    Future<String> Function(TextMessage)? onTranslate,
    ChatRsvpCallback? onRsvp,
    void Function(ContactMessage, ChatContactAction)? onContact,
    ValueChanged<ChatMessage>? onDeleteForEveryone,
    void Function(String text, DateTime at, ChatMessage? replyTo)? onSchedule,
    ValueChanged<ChatMessage>? onSendNow,
    bool readOnly = false,
    Duration? slowMode,
    ValueChanged<ChatMessage>? onReport,
    ValueChanged<ChatUser>? onBlock,
    void Function(ChatMessage, bool)? onSave,
    ChatWordFilter? wordFilter,
    List<ChatStickerPack> stickers = const [],
    ValueChanged<ChatSticker>? onSticker,
    ValueChanged<String>? onSend,
    void Function(TextMessage message, String text)? onEdit,
  }) {
    return ChatView(
      controller: controller,
      currentUser: me,
      onSend: (outgoing) {
        switch (outgoing) {
          case OutgoingText(:final text, :final replyTo, :final scheduledFor?):
            onSchedule?.call(text, scheduledFor, replyTo);
          case OutgoingText(:final text):
            onSend?.call(text);
          case OutgoingEdit(:final message, :final text):
            onEdit?.call(message, text);
          case OutgoingScheduledNow(:final message):
            onSendNow?.call(message);
          case OutgoingSticker(:final sticker):
            onSticker?.call(sticker);
          case OutgoingAttachments():
            break;
        }
      },
      sendFeatures: {
        if (onEdit != null) ChatSendFeature.edit,
        if (onSchedule != null) ChatSendFeature.schedule,
        if (onSendNow != null) ChatSendFeature.sendScheduledNow,
        if (onSticker != null) ChatSendFeature.stickers,
      },
      ai: ChatAiOptions(
        onRegenerate: onRegenerate,
        onFeedback: onFeedback,
        onStopGenerating: onStop,
        onTranslate: onTranslate,
      ),
      contentCallbacks: ChatContentCallbacks(
        onRsvp: onRsvp,
        onContactAction: onContact,
      ),
      moderation: ChatModerationOptions(
        onDeleteForEveryone: onDeleteForEveryone,
        readOnly: readOnly,
        slowMode: slowMode,
        onReportMessage: onReport,
        onBlockUser: onBlock,
        wordFilter: wordFilter,
      ),
      onSaveMessage: onSave,
      stickerPacks: stickers,
      builders: ChatBuilders(
        imageProviderBuilder: (_) => MemoryImage(_pixel),
      ),
    );
  }

  group('AI', () {
    testWidgets('actions under bot answers', (tester) async {
      final regenerated = <String>[];
      final ratings = <ChatFeedback?>[];
      controller.insertAll([
        TextMessage(id: 'a1', author: bot, createdAt: ago(3), text: 'Old'),
        TextMessage(id: 'q', author: me, createdAt: ago(2), text: 'Why?'),
        TextMessage(id: 'a2', author: bot, createdAt: ago(1), text: 'Because'),
      ]);
      await pump(
        tester,
        () => view(
          onRegenerate: (m) => regenerated.add(m.id),
          onFeedback: (m, f) {
            ratings.add(f);
            controller
                .update(m.copyWith(feedback: f, clearFeedback: f == null));
          },
        ),
      );
      expect(find.byKey(const Key('chatx_ai_regenerate_a1')), findsNothing,
          reason: 'only the newest answer');
      await tester.tap(find.byKey(const Key('chatx_ai_regenerate_a2')));
      expect(regenerated, ['a2']);

      await tester.tap(find.byKey(const Key('chatx_ai_good_a2')));
      await tester.pump();
      expect(ratings, [ChatFeedback.positive]);
      expect(find.byIcon(Icons.thumb_up_rounded), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_ai_good_a2')));
      expect(ratings.last, isNull);
    });

    testWidgets('stop replaces send while an answer streams', (tester) async {
      final stopped = <String>[];
      controller.insert(
        TextMessage(
          id: 's',
          author: bot,
          createdAt: ago(1),
          text: 'Thinking',
          isStreaming: true,
        ),
      );
      await pump(tester, () => view(onStop: (m) => stopped.add(m.id)));
      await tester.tap(find.byKey(const Key('chatx_stop_button')));
      expect(stopped, ['s']);

      controller.completeStream('s');
      await tester.pump();
      expect(find.byKey(const Key('chatx_stop_button')), findsNothing);
    });

    testWidgets('code blocks are highlighted and copyable', (tester) async {
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
      controller.insert(
        TextMessage(
          id: 'c',
          author: bot,
          createdAt: ago(1),
          text: '```dart\nfinal x = 42; // answer\n```',
        ),
      );
      await pump(tester, view);
      expect(find.text('dart'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_copy_code')));
      await tester.pump();
      expect(clipboard, 'final x = 42; // answer');
      expect(find.text('Copied'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    test('syntax highlighter colors tokens', () {
      final spans = SyntaxHighlighter.highlight(
        "final name = 'chatx'; // ok\nprint(name);",
        language: 'dart',
        palette: SyntaxPalette.light,
      );
      Color? colorOf(String text) =>
          spans.firstWhere((s) => s.text == text).style?.color;
      expect(colorOf('final'), SyntaxPalette.light.keyword);
      expect(colorOf("'chatx'"), SyntaxPalette.light.string);
      expect(colorOf('// ok'), SyntaxPalette.light.comment);
      expect(colorOf('print'), SyntaxPalette.light.function);
      expect(spans.map((s) => s.text).join(),
          "final name = 'chatx'; // ok\nprint(name);");
    });

    test('markdown tables', () {
      final blocks = MarkdownParser.parse(
        '| Plan | Price |\n|:-----|------:|\n| Free | \$0 |\n| Pro | \$9 |',
      );
      final table = blocks.single as MdTable;
      expect(table.header, hasLength(2));
      expect(table.alignments, [MdAlign.left, MdAlign.right]);
      expect(table.rows, hasLength(2));
      expect(
        MarkdownParser.parse('| a | b |\n|:-|--:|\n| 1 | 2 |').single,
        isA<MdTable>(),
        reason: 'one dash per column is enough',
      );
      expect(MarkdownParser.toPlainText('| a | b |\n|---|---|\n| 1 | 2 |'),
          'a | b 1 | 2');
    });

    testWidgets('tables render inside bubbles', (tester) async {
      controller.insert(
        TextMessage(
          id: 't',
          author: bot,
          createdAt: ago(1),
          text: '| Plan | Price |\n|---|---|\n| Free | 0 |',
        ),
      );
      await pump(tester, view);
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Free', findRichText: true), findsOneWidget);
    });

    testWidgets('translate and show original', (tester) async {
      final completer = Completer<String>();
      controller.insert(
        TextMessage(id: 'm', author: ana, createdAt: ago(1), text: 'Hola'),
      );
      await pump(tester, () => view(onTranslate: (_) => completer.future));
      await tester.longPress(find.byKey(const Key('chatx_bubble_m')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Translate'));
      await tester.pump();
      expect(find.text('Translating…'), findsOneWidget);
      completer.complete('Hello');
      await tester.pumpAndSettle();
      expect(find.text('Hello', findRichText: true), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_translation_toggle')));
      await tester.pumpAndSettle();
      expect(find.text('Hola', findRichText: true), findsOneWidget);
    });
  });

  group('content', () {
    testWidgets('location card with live badge', (tester) async {
      controller.insert(
        LocationMessage(
          id: 'l',
          author: ana,
          createdAt: ago(1),
          latitude: 40.4,
          longitude: -3.7,
          title: 'Café Central',
          address: 'Plaza del Ángel 10',
          liveUntil: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
      await pump(tester, view);
      expect(find.text('Café Central'), findsOneWidget);
      expect(find.textContaining('Live location'), findsOneWidget);
    });

    testWidgets('event RSVP', (tester) async {
      controller.insert(
        EventMessage(
          id: 'e',
          author: ana,
          createdAt: ago(1),
          title: 'Team dinner',
          startsAt: DateTime.now().add(const Duration(days: 2)),
          rsvps: const {'ana': ChatRsvp.going, 'leo': ChatRsvp.maybe},
        ),
      );
      await pump(
        tester,
        () => view(onRsvp: (m, r) => controller.setRsvp(m.id, me.id, r)),
      );
      expect(find.text('1 going · 1 maybe'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_rsvp_e_going')));
      await tester.pump();
      expect(find.text('2 going · 1 maybe'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_rsvp_e_going')));
      await tester.pump();
      expect(find.text('1 going · 1 maybe'), findsOneWidget,
          reason: 'tapping again removes the answer');
    });

    testWidgets('contact card actions', (tester) async {
      final actions = <ChatContactAction>[];
      controller.insert(
        ContactMessage(
          id: 'c',
          author: ana,
          createdAt: ago(1),
          name: 'Leo Martín',
          phone: '+34 600 000 000',
        ),
      );
      await pump(tester, () => view(onContact: (m, a) => actions.add(a)));
      expect(find.byKey(const Key('chatx_contact_c_email')), findsNothing);
      await tester.tap(find.byKey(const Key('chatx_contact_c_call')));
      expect(actions, [ChatContactAction.call]);
    });

    testWidgets('stickers render without a bubble and can be sent',
        (tester) async {
      final sent = <String>[];
      controller.insert(
        StickerMessage(id: 's', author: ana, createdAt: ago(1), uri: 'cat'),
      );
      await pump(
        tester,
        () => view(
          stickers: const [
            ChatStickerPack(
              id: 'cats',
              name: 'Cats',
              stickers: [ChatSticker(id: 'c1', uri: 'cat1')],
            ),
          ],
          onSticker: (s) => sent.add(s.id),
        ),
      );
      expect(find.byKey(const Key('chatx_sticker_message_s')), findsOneWidget);
      final bubble =
          tester.widget<Material>(find.byKey(const Key('chatx_bubble_s')));
      expect(bubble.color, Colors.transparent);

      await tester.tap(find.byKey(const Key('chatx_emoji_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_sticker_pack_cats')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_sticker_c1')));
      expect(sent, ['c1']);
    });
  });

  group('moderation', () {
    testWidgets('delete for everyone shows a placeholder', (tester) async {
      controller.insert(
        TextMessage(id: 'm', author: me, createdAt: ago(1), text: 'oops'),
      );
      await pump(
        tester,
        () => view(onDeleteForEveryone: (m) => controller.markDeleted(m.id)),
      );
      await tester.longPress(find.byKey(const Key('chatx_bubble_m')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete for everyone'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_deleted')), findsOneWidget);
      expect(find.text('oops', findRichText: true), findsNothing);
    });

    testWidgets('edit history', (tester) async {
      controller.insert(
        TextMessage(id: 'm', author: me, createdAt: ago(5), text: 'v1'),
      );
      controller
        ..editText('m', 'v2', editedAt: ago(3))
        ..editText('m', 'v3', editedAt: ago(1));
      expect(
        (controller.messageById('m')! as TextMessage)
            .editHistory
            .map((e) => e.text),
        ['v1', 'v2'],
      );
      await pump(tester, view);
      await tester.tap(find.byKey(const Key('chatx_edited_m')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_edit_history')), findsOneWidget);
      expect(find.text('v1', findRichText: true), findsOneWidget);
    });

    testWidgets('scheduling from a long press on send', (tester) async {
      final scheduled = <(String, DateTime)>[];
      final sentNow = <String>[];
      await pump(
        tester,
        () => view(
          onSchedule: (text, at, _) => scheduled.add((text, at)),
          onSendNow: (m) => sentNow.add(m.id),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('chatx_input_field')),
        'Happy birthday!',
      );
      await tester.pump();
      await tester.longPress(find.byKey(const Key('chatx_send_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tomorrow morning'));
      await tester.pumpAndSettle();
      expect(scheduled.single.$1, 'Happy birthday!');
      expect(scheduled.single.$2.hour, 9);

      controller.insert(
        TextMessage(
          id: 'p',
          author: me,
          createdAt: DateTime.now(),
          text: 'Happy birthday!',
          scheduledFor: scheduled.single.$2,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_scheduled')), findsOneWidget);
      await tester.longPress(find.byKey(const Key('chatx_bubble_p')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send now'));
      await tester.pumpAndSettle();
      expect(sentNow, ['p']);
    });

    testWidgets('read-only channels hide the input', (tester) async {
      await pump(tester, () => view(readOnly: true));
      expect(find.byKey(const Key('chatx_read_only')), findsOneWidget);
      expect(find.byKey(const Key('chatx_input_field')), findsNothing);
    });

    testWidgets('slow mode blocks sending for a while', (tester) async {
      final sent = <String>[];
      await pump(
        tester,
        () => view(slowMode: const Duration(seconds: 30), onSend: sent.add),
      );
      final field = find.byKey(const Key('chatx_input_field'));
      await tester.enterText(field, 'first');
      await tester.pump();
      await tester.tap(find.byKey(const Key('chatx_send_button')));
      await tester.pump();
      expect(sent, ['first']);
      expect(tester.widget<TextField>(field).enabled, isFalse);
      expect(find.text('Slow mode: wait 0:30'), findsOneWidget);
      await tester.pump(const Duration(seconds: 31));
      expect(tester.widget<TextField>(field).enabled, isTrue);
    });

    testWidgets('report, block, save and word filter', (tester) async {
      final reports = <String>[];
      final blocked = <String>[];
      controller.insert(
        TextMessage(id: 'm', author: ana, createdAt: ago(1), text: 'darn it'),
      );
      await pump(
        tester,
        () => view(
          onReport: (m) => reports.add(m.id),
          onBlock: (u) => blocked.add(u.id),
          onSave: (m, saved) => controller.toggleSaved(m.id),
          wordFilter: ChatWordFilter({'darn'}),
        ),
      );
      expect(find.text('d*** it', findRichText: true), findsOneWidget);

      await tester.longPress(find.byKey(const Key('chatx_bubble_m')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(controller.isSaved('m'), isTrue);
      expect(find.byKey(const Key('chatx_saved_icon')), findsOneWidget);

      await tester.longPress(find.byKey(const Key('chatx_bubble_m')));
      await tester.pumpAndSettle();
      expect(find.text('Remove from saved'), findsOneWidget);
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      expect(reports, ['m']);

      await tester.longPress(find.byKey(const Key('chatx_bubble_m')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block Ana'));
      await tester.pumpAndSettle();
      expect(blocked, ['ana']);
    });

    test('word filter keeps unrelated words', () {
      final filter = ChatWordFilter({'ass'});
      expect(filter.apply('a classic assessment, ASS!'),
          'a classic assessment, A**!');
    });
  });
}
