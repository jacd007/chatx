import 'dart:io';

import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every built-in language is complete and distinct', () {
    expect(ChatLocalizations.builtIn.keys, ['en', 'es', 'pt', 'fr', 'de']);
    for (final entry in ChatLocalizations.builtIn.entries) {
      final l = entry.value;
      expect(l.typing(['Ana']), isNotEmpty, reason: entry.key);
      expect(l.emojiCategories, hasLength(10), reason: entry.key);
      expect(l.rsvpSummary(2, 1), contains('2'), reason: entry.key);
      expect(l.reactionLabel('👍', 3, includesYou: true), contains('3'));
    }
    expect(ChatLocalizations.pt.inputHint, 'Mensagem');
    expect(ChatLocalizations.fr.today, "Aujourd'hui");
    expect(ChatLocalizations.de.reply, 'Antworten');
    expect(ChatLocalizations.forLocale(const Locale('de', 'AT')),
        ChatLocalizations.de);
    expect(
        ChatLocalizations.forLocale(const Locale('ja')), ChatLocalizations.en);
  });

  // Strings left out fall back to English, so the compiler no longer
  // catches a string missing from a built-in language. This does.
  test('built-in languages set every string', () {
    final source =
        File('lib/src/l10n/chat_localizations.dart').readAsStringSync();
    final ctor = source.substring(
      source.indexOf('  const ChatLocalizations({'),
      source.indexOf('  });', source.indexOf('  const ChatLocalizations({')),
    );
    final fields = RegExp(r'this\.(\w+) =')
        .allMatches(ctor)
        .map((m) => m.group(1)!)
        .toSet();
    expect(fields, hasLength(greaterThan(150)));
    for (final code in ['es', 'pt', 'fr', 'de']) {
      final start = source.indexOf('static const ChatLocalizations $code = ');
      final body = source.substring(start, source.indexOf('\n  );', start));
      final set = RegExp(r'^\s{4}(\w+):', multiLine: true)
          .allMatches(body)
          .map((m) => m.group(1)!)
          .toSet();
      expect(fields.difference(set), isEmpty, reason: code);
    }
  });

  test('a partial language falls back to English', () {
    const italian = ChatLocalizations(inputHint: 'Messaggio', today: 'Oggi');
    expect(italian.inputHint, 'Messaggio');
    expect(italian.today, 'Oggi');
    expect(italian.yesterday, ChatLocalizations.en.yesterday);
    expect(italian.typing(['Ana']), ChatLocalizations.en.typing(['Ana']));
  });

  testWidgets('emoji search understands Spanish without accents',
      (tester) async {
    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatEmojiPicker(onSelected: (e) => picked = e),
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('chatx_emoji_search')),
      'corazon',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatx_emoji_❤️')));
    expect(picked, '❤️');

    await tester.enterText(
      find.byKey(const Key('chatx_emoji_search')),
      'Cumpleaños',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatx_emoji_🎂')), findsOneWidget);
  });
}
