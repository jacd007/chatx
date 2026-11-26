/// Removes invisible characters that can disguise text.
///
/// Bidirectional controls let a sender reorder what the reader sees: with a
/// right-to-left override, `invoice\u202Efdp.exe` is displayed as
/// `invoiceexe.pdf`. Zero-width characters make two different names or
/// links look the same, and Unicode tag characters carry text the reader
/// never sees.
///
/// chatx strips user names with [strip] before showing them. Message
/// bodies are shown as sent unless you pass `ChatView.textSanitizer`, for
/// example `textSanitizer: ChatTextSanitizer.strip`.
///
/// The zero-width joiner (U+200D) and non-joiner (U+200C) are kept: emoji
/// sequences such as 👩‍💻 and scripts such as Persian need them.
abstract final class ChatTextSanitizer {
  /// Returns [text] without bidirectional embeddings, overrides and isolates
  /// (U+202A to U+202E, U+2066 to U+2069), direction marks (U+200E, U+200F,
  /// U+061C), invisible characters (U+200B, U+2060, U+FEFF) and Unicode tag
  /// characters (U+E0000 to U+E007F), which can smuggle hidden text.
  ///
  /// Tag characters that follow a black flag (U+1F3F4) are kept: they spell
  /// subdivision flags such as the flag of England.
  ///
  /// Returns [text] itself when it has none of them.
  static String strip(String text) {
    StringBuffer? buffer;
    // Whether the last kept character is a black flag or one of its tags.
    var inFlag = false;
    var i = 0;
    while (i < text.length) {
      final unit = text.codeUnitAt(i);
      final pair = unit >= 0xD800 &&
          unit <= 0xDBFF &&
          i + 1 < text.length &&
          (text.codeUnitAt(i + 1) & 0xFC00) == 0xDC00;
      final width = pair ? 2 : 1;
      final bool drop;
      if (pair && unit == 0xDB40 && text.codeUnitAt(i + 1) <= 0xDC7F) {
        // A tag character, kept only inside a flag sequence. The cancel tag
        // U+E007F ends that sequence.
        drop = !inFlag;
        inFlag = !drop && text.codeUnitAt(i + 1) != 0xDC7F;
      } else {
        drop = !pair && _isStripped(unit);
        inFlag = !drop &&
            pair &&
            unit == 0xD83C &&
            text.codeUnitAt(i + 1) == 0xDFF4; // U+1F3F4
      }
      if (drop) {
        buffer ??= StringBuffer(text.substring(0, i));
      } else {
        buffer?.write(text.substring(i, i + width));
      }
      i += width;
    }
    return buffer?.toString() ?? text;
  }

  /// Returns [strip] of [text] wrapped in a first strong isolate (U+2068)
  /// and a pop directional isolate (U+2069).
  ///
  /// Use it when you embed text of unknown direction, such as a name, in a
  /// sentence: the text cannot reorder what surrounds it.
  static String isolate(String text) => '\u2068${strip(text)}\u2069';

  // Characters removed from the Basic Multilingual Plane. [strip] reads
  // surrogate pairs whole, so it never splits one.
  static bool _isStripped(int unit) =>
      (unit >= 0x202A && unit <= 0x202E) ||
      (unit >= 0x2066 && unit <= 0x2069) ||
      unit == 0x200E ||
      unit == 0x200F ||
      unit == 0x061C ||
      unit == 0x200B ||
      unit == 0x2060 ||
      unit == 0xFEFF;
}
