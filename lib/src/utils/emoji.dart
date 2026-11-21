/// Emoji detection without third-party packages.
///
/// The rules cover the emoji people actually send in chats: pictographs,
/// skin tones, ZWJ sequences (families, professions), flags and keycaps.
abstract final class EmojiUtils {
  /// Returns how many emoji [text] contains when it holds only emoji and
  /// whitespace, or `null` when it contains anything else.
  static int? countIfOnlyEmoji(String text) {
    final runes = text.runes.toList(growable: false);
    var count = 0;
    var joinNext = false; // After a ZWJ, the next pictograph joins the cluster.
    var pendingFlag = false; // First half of a regional-indicator pair.
    var keycapBase = false; // 0-9, # or * waiting for U+20E3.

    for (final rune in runes) {
      if (_isWhitespace(rune)) {
        if (joinNext || pendingFlag || keycapBase) return null;
        continue;
      }
      if (rune == 0x200D) {
        if (count == 0) return null;
        joinNext = true;
        continue;
      }
      if (rune == 0xFE0F ||
          rune == 0xFE0E ||
          _isSkinTone(rune) ||
          (rune >= 0xE0020 && rune <= 0xE007F)) {
        if (count == 0 && !keycapBase) return null;
        continue;
      }
      if (rune == 0x20E3) {
        if (!keycapBase) return null;
        keycapBase = false;
        count++;
        continue;
      }
      if (keycapBase) return null;
      if (_isKeycapBase(rune)) {
        keycapBase = true;
        continue;
      }
      if (rune >= 0x1F1E6 && rune <= 0x1F1FF) {
        if (pendingFlag) {
          pendingFlag = false;
        } else {
          pendingFlag = true;
          count++;
        }
        continue;
      }
      if (pendingFlag) return null;
      if (!_isPictograph(rune)) return null;
      if (joinNext) {
        joinNext = false;
      } else {
        count++;
      }
    }
    if (joinNext || pendingFlag || keycapBase || count == 0) return null;
    return count;
  }

  static bool _isWhitespace(int r) =>
      r == 0x20 || r == 0x09 || r == 0x0A || r == 0x0D;

  static bool _isSkinTone(int r) => r >= 0x1F3FB && r <= 0x1F3FF;

  static bool _isKeycapBase(int r) =>
      (r >= 0x30 && r <= 0x39) || r == 0x23 || r == 0x2A;

  static bool _isPictograph(int r) =>
      (r >= 0x1F000 && r <= 0x1FAFF) ||
      (r >= 0x2600 && r <= 0x27BF) ||
      (r >= 0x2300 && r <= 0x23FF) ||
      (r >= 0x2B00 && r <= 0x2BFF) ||
      (r >= 0x2190 && r <= 0x21FF) ||
      (r >= 0x25A0 && r <= 0x25FF) ||
      r == 0x00A9 ||
      r == 0x00AE ||
      r == 0x203C ||
      r == 0x2049 ||
      r == 0x2122 ||
      r == 0x2139 ||
      r == 0x24C2 ||
      r == 0x3030 ||
      r == 0x303D ||
      r == 0x3297 ||
      r == 0x3299;
}
