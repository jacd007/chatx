import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana Ruiz');
const bot = ChatUser(id: 'bot', name: 'Assistant', isBot: true);

const rlo = '\u202E';
const zwsp = '\u200B';

void main() {
  late ChatController controller;
  setUp(() => controller = ChatController());
  tearDown(() => controller.dispose());

  DateTime ago(int minutes) =>
      DateTime.now().subtract(Duration(minutes: minutes));

  Future<void> pump(
    WidgetTester tester, {
    int? inputMaxLength,
    ValueChanged<String>? onCopyText,
    String Function(String)? textSanitizer,
    ChatFeedbackCallback? onFeedback,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            controller: controller,
            currentUser: me,
            onSend: (_) {},
            inputMaxLength: inputMaxLength,
            onCopyText: onCopyText,
            textSanitizer: textSanitizer,
            ai: ChatAiOptions(onFeedback: onFeedback),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Records what is written to the clipboard.
  List<String> captureClipboard(WidgetTester tester) {
    final writes = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          writes.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    return writes;
  }

  String inputText(WidgetTester tester) => tester
      .widget<TextField>(find.byKey(const Key('chatx_input_field')))
      .controller!
      .text;

  String shownText(WidgetTester tester) => tester
      .widgetList<RichText>(find.byType(RichText))
      .map((r) => r.text.toPlainText())
      .join('|');

  group('inputMaxLength', () {
    testWidgets('caps typed text', (tester) async {
      await pump(tester, inputMaxLength: 5);
      expect(tester.widget<ChatInput>(find.byType(ChatInput)).maxLength, 5);
      await tester.enterText(
          find.byKey(const Key('chatx_input_field')), 'abcdefgh');
      await tester.pump();
      expect(inputText(tester), 'abcde');
    });

    testWidgets('null keeps the input unlimited', (tester) async {
      await pump(tester);
      expect(
          tester.widget<ChatInput>(find.byType(ChatInput)).maxLength, isNull);
      await tester.enterText(
          find.byKey(const Key('chatx_input_field')), 'x' * 5000);
      await tester.pump();
      expect(inputText(tester), hasLength(5000));
    });

    testWidgets('the emoji picker respects the cap', (tester) async {
      await pump(tester, inputMaxLength: 3);
      await tester.enterText(find.byKey(const Key('chatx_input_field')), 'ab');
      await tester.tap(find.byKey(const Key('chatx_emoji_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('chatx_emoji_search')), 'pizza');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_emoji_🍕')));
      await tester.pump();
      expect(inputText(tester), 'ab🍕');
      await tester.tap(find.byKey(const Key('chatx_emoji_🍕')));
      await tester.pump();
      expect(inputText(tester), 'ab🍕');
    });
  });

  group('onCopyText', () {
    testWidgets('menu copy calls it instead of the clipboard', (tester) async {
      final writes = captureClipboard(tester);
      final copied = <String>[];
      controller.insert(
          TextMessage(id: '1', author: ana, createdAt: ago(1), text: 'secret'));
      await pump(tester, onCopyText: copied.add);
      await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy text'));
      await tester.pumpAndSettle();
      expect(copied, ['secret']);
      expect(writes, isEmpty);
    });

    testWidgets('menu copy falls back to the clipboard', (tester) async {
      final writes = captureClipboard(tester);
      controller.insert(
          TextMessage(id: '1', author: ana, createdAt: ago(1), text: 'secret'));
      await pump(tester);
      await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy text'));
      await tester.pumpAndSettle();
      expect(writes, ['secret']);
    });

    testWidgets('copyText action accepts onCopy', (tester) async {
      final writes = captureClipboard(tester);
      final copied = <String>[];
      ChatMessageAction.copyText(label: 'Copy', onCopy: copied.add).onSelected(
          TextMessage(id: '1', author: ana, createdAt: ago(1), text: 'hello'));
      ChatMessageAction.copyText(label: 'Copy').onSelected(
          TextMessage(id: '2', author: ana, createdAt: ago(1), text: 'bye'));
      await tester.pump();
      expect(copied, ['hello']);
      expect(writes, ['bye']);
    });

    testWidgets('selection bar copy calls it', (tester) async {
      final writes = captureClipboard(tester);
      final copied = <String>[];
      controller.insertAll([
        TextMessage(id: '1', author: me, createdAt: ago(3), text: 'one'),
        TextMessage(id: '2', author: me, createdAt: ago(2), text: 'two'),
      ]);
      await pump(tester, onCopyText: copied.add);
      await tester.longPress(find.byKey(const Key('chatx_bubble_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_bubble_2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_selection_action_0')));
      await tester.pumpAndSettle();
      expect(copied, ['one\n\ntwo']);
      expect(writes, isEmpty);
    });

    testWidgets('AI answer copy calls it', (tester) async {
      final writes = captureClipboard(tester);
      final copied = <String>[];
      controller.insert(
          TextMessage(id: 'a', author: bot, createdAt: ago(1), text: 'answer'));
      await pump(tester, onCopyText: copied.add, onFeedback: (_, __) {});
      await tester.tap(find.byKey(const Key('chatx_ai_copy_a')));
      await tester.pumpAndSettle();
      expect(copied, ['answer']);
      expect(writes, isEmpty);
    });

    testWidgets('AI answer copy falls back to the clipboard', (tester) async {
      final writes = captureClipboard(tester);
      controller.insert(
          TextMessage(id: 'a', author: bot, createdAt: ago(1), text: 'answer'));
      await pump(tester, onFeedback: (_, __) {});
      await tester.tap(find.byKey(const Key('chatx_ai_copy_a')));
      await tester.pumpAndSettle();
      expect(writes, ['answer']);
    });

    testWidgets('code block in a bubble calls it', (tester) async {
      final writes = captureClipboard(tester);
      final copied = <String>[];
      controller.insert(TextMessage(
          id: '1',
          author: ana,
          createdAt: ago(1),
          text: '```\napi_key=123\n```'));
      await pump(tester, onCopyText: copied.add);
      await tester.tap(find.byKey(const Key('chatx_copy_code')));
      await tester.pump(const Duration(seconds: 3));
      expect(copied, ['api_key=123']);
      expect(writes, isEmpty);
    });

    testWidgets('code block in a bubble falls back to the clipboard',
        (tester) async {
      final writes = captureClipboard(tester);
      controller.insert(TextMessage(
          id: '1',
          author: ana,
          createdAt: ago(1),
          text: '```\napi_key=123\n```'));
      await pump(tester);
      await tester.tap(find.byKey(const Key('chatx_copy_code')));
      await tester.pump(const Duration(seconds: 3));
      expect(writes, ['api_key=123']);
    });
  });

  group('ChatTextSanitizer', () {
    test('strips bidi controls, marks and invisible characters', () {
      expect(ChatTextSanitizer.strip('invoice${rlo}fdp.exe'), 'invoicefdp.exe');
      expect(ChatTextSanitizer.strip('An${zwsp}a'), 'Ana');
      expect(
        ChatTextSanitizer.strip(
            'a\u202A\u202B\u202C\u202D\u2066\u2067\u2068\u2069'
            '\u200E\u200F\u061C\u2060\uFEFFb'),
        'ab',
      );
    });

    test('keeps ZWJ emoji and ZWNJ', () {
      const coder = '\u{1F469}\u200D\u{1F4BB}'; // 👩‍💻
      expect(ChatTextSanitizer.strip(coder), coder);
      const persian = 'می\u200Cخواهم';
      expect(ChatTextSanitizer.strip(persian), persian);
    });

    test('strips tag characters outside flag sequences', () {
      // U+E0068 U+E0069 spell a hidden "hi".
      expect(ChatTextSanitizer.strip('a\u{E0068}\u{E0069}\u{E007F}b'), 'ab');
      expect(ChatTextSanitizer.strip('\u{E0001}x'), 'x');
    });

    test('keeps subdivision flags and other surrogate pairs', () {
      // 🏴 + "gbeng" + cancel tag: the flag of England.
      const england = '\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}'
          '\u{E0067}\u{E007F}';
      expect(identical(ChatTextSanitizer.strip(england), england), isTrue);
      expect(ChatTextSanitizer.strip('go $england!'), 'go $england!');
      // Tags after the cancel tag no longer belong to the flag.
      expect(ChatTextSanitizer.strip('$england\u{E0068}'), england);
      expect(
        ChatTextSanitizer.strip('$rlo\u{1F600}$england\u{1F44D}'),
        '\u{1F600}$england\u{1F44D}',
      );
      // A lone surrogate is kept as is.
      expect(ChatTextSanitizer.strip('\uDB40$zwsp'), '\uDB40');
    });

    test('returns clean text unchanged', () {
      const text = 'Hello, Ana Ruiz';
      expect(identical(ChatTextSanitizer.strip(text), text), isTrue);
    });

    test('isolate wraps the stripped text in FSI and PDI', () {
      expect(ChatTextSanitizer.isolate('An${rlo}a'), '\u2068Ana\u2069');
    });
  });

  group('user names', () {
    testWidgets('normal names render as before', (tester) async {
      controller.insert(
          TextMessage(id: '1', author: ana, createdAt: ago(1), text: 'hi'));
      await pump(tester);
      expect(find.text('Ana Ruiz'), findsOneWidget);
    });

    testWidgets('bidi controls are stripped from author names', (tester) async {
      controller.insert(TextMessage(
        id: '1',
        author: const ChatUser(id: 'x', name: 'Mallory${rlo}nimdA'),
        createdAt: ago(1),
        text: 'hi',
      ));
      await pump(tester);
      expect(find.text('MallorynimdA'), findsOneWidget);
      expect(shownText(tester), isNot(contains(rlo)));
    });

    test('initials ignore invisible characters', () {
      expect(const ChatUser(id: 'x', name: '${rlo}ana ruiz').initials, 'AR');
    });
  });

  group('textSanitizer', () {
    testWidgets('is applied to bubble text only', (tester) async {
      const spoof = 'invoice${rlo}fdp.exe';
      controller.insert(
          TextMessage(id: '1', author: ana, createdAt: ago(1), text: spoof));
      await pump(tester, textSanitizer: ChatTextSanitizer.strip);
      expect(shownText(tester), contains('invoicefdp.exe'));
      expect(shownText(tester), isNot(contains(rlo)));
      expect((controller.messages.single as TextMessage).text, spoof);
    });

    String textIn(WidgetTester tester, String key) => tester
        .widgetList<RichText>(find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(RichText),
        ))
        .map((r) => r.text.toPlainText())
        .join('|');

    Future<void> pumpPreviews(
      WidgetTester tester, {
      String Function(String)? textSanitizer,
    }) async {
      controller
        ..insert(TextMessage(
          id: '1',
          author: ana,
          createdAt: ago(2),
          text: 'invoice${rlo}fdp.exe',
        ))
        ..insert(TextMessage(
          id: '2',
          author: me,
          createdAt: ago(1),
          text: 'ok',
          replyToId: '1',
        ))
        ..pin('1');
      controller.composer.startReply(controller.messages.first);
      await pump(tester, textSanitizer: textSanitizer);
    }

    testWidgets('is applied to message previews', (tester) async {
      await pumpPreviews(tester, textSanitizer: ChatTextSanitizer.strip);
      for (final key in [
        'chatx_quote_2',
        'chatx_pinned_banner',
        'chatx_reply_banner',
      ]) {
        expect(textIn(tester, key), contains('invoicefdp.exe'), reason: key);
        expect(textIn(tester, key), isNot(contains(rlo)), reason: key);
      }
    });

    testWidgets('previews are shown as sent without it', (tester) async {
      await pumpPreviews(tester);
      for (final key in [
        'chatx_quote_2',
        'chatx_pinned_banner',
        'chatx_reply_banner',
      ]) {
        expect(textIn(tester, key), contains(rlo), reason: key);
      }
    });

    testWidgets('text is shown as sent without it', (tester) async {
      const spoof = 'invoice${rlo}fdp.exe';
      controller.insert(
          TextMessage(id: '1', author: ana, createdAt: ago(1), text: spoof));
      await pump(tester);
      expect(shownText(tester), contains(rlo));
    });
  });
}
