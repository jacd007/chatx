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
