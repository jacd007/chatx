import 'package:chatx/src/utils/emoji.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmojiUtils.countIfOnlyEmoji', () {
    test('counts simple and composed emoji', () {
      expect(EmojiUtils.countIfOnlyEmoji('🎉'), 1);
      expect(EmojiUtils.countIfOnlyEmoji('🎉 🔥'), 2);
      expect(EmojiUtils.countIfOnlyEmoji('❤️'), 1,
          reason: 'variation selector');
      expect(EmojiUtils.countIfOnlyEmoji('👍🏽'), 1, reason: 'skin tone');
      expect(EmojiUtils.countIfOnlyEmoji('👨‍👩‍👧'), 1, reason: 'ZWJ family');
      expect(EmojiUtils.countIfOnlyEmoji('🇲🇽🇪🇸'), 2, reason: 'flags');
      expect(EmojiUtils.countIfOnlyEmoji('1️⃣'), 1, reason: 'keycap');
    });

    test('rejects text', () {
      expect(EmojiUtils.countIfOnlyEmoji('ok 🎉'), isNull);
      expect(EmojiUtils.countIfOnlyEmoji('1'), isNull);
      expect(EmojiUtils.countIfOnlyEmoji(''), isNull);
      expect(EmojiUtils.countIfOnlyEmoji('   '), isNull);
      expect(EmojiUtils.countIfOnlyEmoji('#'), isNull);
    });
  });
}
