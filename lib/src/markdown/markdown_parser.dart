// Internal AST and parser; not exported from package:chatx.
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';

/// Inline style applied by a [MdStyled] node.
enum MdStyle {
  /// `**text**` or `__text__`.
  bold,

  /// `*text*` or `_text_`.
  italic,

  /// `~~text~~`.
  strike,

  /// `||text||`: hidden until the reader taps it.
  spoiler,
}

/// A node inside a line of text.
@immutable
sealed class MdInline {
  const MdInline();
}

/// Plain text.
final class MdText extends MdInline {
  const MdText(this.text);
  final String text;

  @override
  bool operator ==(Object other) => other is MdText && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'MdText($text)';
}

/// Text with an [MdStyle].
final class MdStyled extends MdInline {
  const MdStyled(this.style, this.children);
  final MdStyle style;
  final List<MdInline> children;

  @override
  bool operator ==(Object other) =>
      other is MdStyled &&
      other.style == style &&
      listEquals(other.children, children);

  @override
  int get hashCode => Object.hash(style, Object.hashAll(children));

  @override
  String toString() => 'MdStyled($style, $children)';
}

/// Inline code span. Its content is never parsed.
final class MdCode extends MdInline {
  const MdCode(this.code);
  final String code;

  @override
  bool operator ==(Object other) => other is MdCode && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'MdCode($code)';
}

/// A link. [target] is the raw, unvalidated destination.
final class MdLink extends MdInline {
  const MdLink(this.target, this.children);
  final String target;
  final List<MdInline> children;

  @override
  bool operator ==(Object other) =>
      other is MdLink &&
      other.target == target &&
      listEquals(other.children, children);

  @override
  int get hashCode => Object.hash(target, Object.hashAll(children));

  @override
  String toString() => 'MdLink($target, $children)';
}

/// A block-level element.
@immutable
sealed class MdBlock {
  const MdBlock();
}

/// A paragraph. Single line breaks are kept, as users expect in chats.
final class MdParagraph extends MdBlock {
  const MdParagraph(this.children);
  final List<MdInline> children;

  @override
  bool operator ==(Object other) =>
      other is MdParagraph && listEquals(other.children, children);

  @override
  int get hashCode => Object.hashAll(children);

  @override
  String toString() => 'MdParagraph($children)';
}

/// `#` to `######` heading.
final class MdHeading extends MdBlock {
  const MdHeading(this.level, this.children);
  final int level;
  final List<MdInline> children;

  @override
  bool operator ==(Object other) =>
      other is MdHeading &&
      other.level == level &&
      listEquals(other.children, children);

  @override
  int get hashCode => Object.hash(level, Object.hashAll(children));
}

/// Fenced code block.
final class MdCodeBlock extends MdBlock {
  const MdCodeBlock(this.code, {this.language});
  final String code;
  final String? language;

  @override
  bool operator ==(Object other) =>
      other is MdCodeBlock && other.code == code && other.language == language;

  @override
  int get hashCode => Object.hash(code, language);

  @override
  String toString() => 'MdCodeBlock($language, $code)';
}

/// `>` block quote.
final class MdQuote extends MdBlock {
  const MdQuote(this.children);
  final List<MdBlock> children;

  @override
  bool operator ==(Object other) =>
      other is MdQuote && listEquals(other.children, children);

  @override
  int get hashCode => Object.hashAll(children);
}

/// Bulleted (`-`, `*`, `+`) or numbered (`1.`, `1)`) list.
final class MdList extends MdBlock {
  const MdList({required this.ordered, required this.items, this.start = 1});
  final bool ordered;
  final int start;
  final List<List<MdInline>> items;

  @override
  bool operator ==(Object other) =>
      other is MdList &&
      other.ordered == ordered &&
      other.start == start &&
      listEquals(
        other.items.map(Object.hashAll).toList(),
        items.map(Object.hashAll).toList(),
      );

  @override
  int get hashCode =>
      Object.hash(ordered, start, Object.hashAll(items.map(Object.hashAll)));
}

/// Alignment of a table column.
enum MdAlign { left, center, right }

/// A table with a header row.
final class MdTable extends MdBlock {
  const MdTable({
    required this.header,
    required this.alignments,
    required this.rows,
  });
  final List<List<MdInline>> header;
  final List<MdAlign> alignments;
  final List<List<List<MdInline>>> rows;

  @override
  bool operator ==(Object other) =>
      other is MdTable &&
      listEquals(other.alignments, alignments) &&
      other.header.length == header.length &&
      other.rows.length == rows.length;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(alignments), header.length, rows.length);
}

/// Parses the markdown subset supported by chatx.
///
/// The parser never throws and is safe on partial input, which matters for
/// streamed messages (an unclosed code fence simply runs to the end).
/// HTML is not interpreted: `<b>` stays literal text.
abstract final class MarkdownParser {
  static final RegExp _heading = RegExp(r'^ {0,3}(#{1,6})[ \t]+(.*?)[ \t#]*$');
  static final RegExp _listItem =
      RegExp(r'^ {0,3}([-*+]|(\d{1,9})[.)])[ \t]+(.*)$');
  static final RegExp _quote = RegExp(r'^ {0,3}> ?(.*)$');
  static final RegExp _fence = RegExp(r'^ {0,3}(```+|~~~+)[ \t]*([^`\s]*)');
  static final RegExp _tableSeparator =
      RegExp(r'^\s*\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)*\|?\s*$');

  static List<String> _cells(String line) {
    var text = line.trim();
    if (text.startsWith('|')) text = text.substring(1);
    if (text.endsWith('|') && !text.endsWith(r'\|')) {
      text = text.substring(0, text.length - 1);
    }
    final cells = <String>[];
    final current = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (text[i] == r'\' && i + 1 < text.length && text[i + 1] == '|') {
        current.write('|');
        i++;
      } else if (text[i] == '|') {
        cells.add(current.toString().trim());
        current.clear();
      } else {
        current.write(text[i]);
      }
    }
    cells.add(current.toString().trim());
    return cells;
  }

  static final Map<String, List<MdBlock>> _cache = {};
  static const int _cacheSize = 512;

  /// Like [parse], but reuses the result for recently parsed texts. Message
  /// rows are rebuilt often while scrolling; their text rarely changes.
  static List<MdBlock> parseCached(String source) {
    final cached = _cache.remove(source);
    if (cached != null) {
      _cache[source] = cached; // Most recently used goes last.
      return cached;
    }
    final blocks = List<MdBlock>.unmodifiable(parse(source));
    _cache[source] = blocks;
    if (_cache.length > _cacheSize) _cache.remove(_cache.keys.first);
    return blocks;
  }

  /// Empties the [parseCached] cache, releasing the texts it holds.
  static void clearCache() => _cache.clear();

  /// Parses [source] into blocks.
  static List<MdBlock> parse(String source) {
    final lines = source.replaceAll('\r\n', '\n').split('\n');
    return _parseBlocks(lines);
  }

  /// Parses a single line (or paragraph) of inline markdown.
  static List<MdInline> parseInline(String source) =>
      _InlineParser(source).parse();

  /// Returns [source] without markdown syntax, on a single line. Used for
  /// reply quotes and previews.
  static String toPlainText(String source) {
    final parts = <String>[];
    void inline(MdInline node, StringBuffer out) {
      switch (node) {
        case MdText(:final text):
          out.write(text);
        case MdCode(:final code):
          out.write(code);
        case MdStyled(style: MdStyle.spoiler):
          out.write('•••');
        case MdStyled(:final children):
          for (final child in children) {
            inline(child, out);
          }
        case MdLink(:final children):
          for (final child in children) {
            inline(child, out);
          }
      }
    }

    String inlines(List<MdInline> nodes) {
      final out = StringBuffer();
      for (final node in nodes) {
        inline(node, out);
      }
      return out.toString();
    }

    void block(MdBlock node) {
      switch (node) {
        case MdParagraph(:final children):
          parts.add(inlines(children));
        case MdHeading(:final children):
          parts.add(inlines(children));
        case MdCodeBlock(:final code):
          parts.add(code);
        case MdQuote(:final children):
          children.forEach(block);
        case MdList(:final items):
          parts.addAll(items.map(inlines));
        case MdTable(:final header, :final rows):
          parts.add(header.map(inlines).join(' | '));
          for (final row in rows) {
            parts.add(row.map(inlines).join(' | '));
          }
      }
    }

    parse(source).forEach(block);
    return parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static List<MdBlock> _parseBlocks(List<String> lines) {
    final blocks = <MdBlock>[];
    final paragraph = <String>[];

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      blocks.add(MdParagraph(parseInline(paragraph.join('\n'))));
      paragraph.clear();
    }

    var i = 0;
    while (i < lines.length) {
      final line = lines[i];

      final fence = _fence.firstMatch(line);
      if (fence != null) {
        flushParagraph();
        final marker = fence.group(1)!;
        final language = fence.group(2)!;
        final code = <String>[];
        i++;
        while (i < lines.length && !_closesFence(lines[i], marker)) {
          code.add(lines[i]);
          i++;
        }
        i++; // Skip the closing fence, if any.
        blocks.add(
          MdCodeBlock(
            code.join('\n'),
            language: language.isEmpty ? null : language,
          ),
        );
        continue;
      }

      if (line.trim().isEmpty) {
        flushParagraph();
        i++;
        continue;
      }

      if (line.contains('|') &&
          i + 1 < lines.length &&
          _tableSeparator.hasMatch(lines[i + 1])) {
        flushParagraph();
        final header = _cells(line);
        final alignments = [
          for (final cell in _cells(lines[i + 1]))
            cell.startsWith(':') && cell.endsWith(':')
                ? MdAlign.center
                : cell.endsWith(':')
                    ? MdAlign.right
                    : MdAlign.left,
        ];
        i += 2;
        final rows = <List<List<MdInline>>>[];
        while (i < lines.length &&
            lines[i].contains('|') &&
            lines[i].trim().isNotEmpty) {
          final cells = _cells(lines[i]);
          rows.add([
            for (var c = 0; c < header.length; c++)
              parseInline(c < cells.length ? cells[c] : ''),
          ]);
          i++;
        }
        blocks.add(
          MdTable(
            header: [for (final cell in header) parseInline(cell)],
            alignments: [
              for (var c = 0; c < header.length; c++)
                c < alignments.length ? alignments[c] : MdAlign.left,
            ],
            rows: rows,
          ),
        );
        continue;
      }

      final heading = _heading.firstMatch(line);
      if (heading != null) {
        flushParagraph();
        blocks.add(
          MdHeading(heading.group(1)!.length, parseInline(heading.group(2)!)),
        );
        i++;
        continue;
      }

      if (_quote.hasMatch(line)) {
        flushParagraph();
        final inner = <String>[];
        while (i < lines.length) {
          final match = _quote.firstMatch(lines[i]);
          if (match == null) break;
          inner.add(match.group(1)!);
          i++;
        }
        blocks.add(MdQuote(_parseBlocks(inner)));
        continue;
      }

      final item = _listItem.firstMatch(line);
      if (item != null) {
        flushParagraph();
        final ordered = item.group(2) != null;
        final start = ordered ? int.parse(item.group(2)!) : 1;
        final items = <List<MdInline>>[];
        while (i < lines.length) {
          final match = _listItem.firstMatch(lines[i]);
          if (match == null || (match.group(2) != null) != ordered) break;
          items.add(parseInline(match.group(3)!));
          i++;
        }
        blocks.add(MdList(ordered: ordered, start: start, items: items));
        continue;
      }

      paragraph.add(line);
      i++;
    }
    flushParagraph();
    return blocks;
  }

  static bool _closesFence(String line, String marker) {
    final trimmed = line.trim();
    return trimmed.length >= marker.length &&
        trimmed.startsWith(marker) &&
        trimmed.replaceAll(marker[0], '').isEmpty;
  }
}

const int _backslash = 0x5C;
const int _backtick = 0x60;
const int _openBracket = 0x5B;
const int _closeBracket = 0x5D;
const int _openParen = 0x28;
const int _closeParen = 0x29;
const int _star = 0x2A;
const int _underscore = 0x5F;
const int _tilde = 0x7E;
const int _pipe = 0x7C;

bool _isWhitespace(int c) => c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D;

bool _isAlphanumeric(int c) =>
    (c >= 0x30 && c <= 0x39) ||
    (c >= 0x41 && c <= 0x5A) ||
    (c >= 0x61 && c <= 0x7A) ||
    c > 0x7F;

bool _isAsciiPunctuation(int c) =>
    (c >= 0x21 && c <= 0x2F) ||
    (c >= 0x3A && c <= 0x40) ||
    (c >= 0x5B && c <= 0x60) ||
    (c >= 0x7B && c <= 0x7E);

class _InlineParser {
  _InlineParser(this.source);

  final String source;

  List<MdInline> parse() => _parse(0, source.length);

  List<MdInline> _parse(int start, int end) {
    final nodes = <MdInline>[];
    final text = StringBuffer();
    var segment = start;
    var i = start;

    void flushText(int upTo) {
      if (upTo > segment) text.write(source.substring(segment, upTo));
      if (text.isNotEmpty) {
        nodes.add(MdText(text.toString()));
        text.clear();
      }
    }

    while (i < end) {
      final c = source.codeUnitAt(i);

      if (c == _backslash &&
          i + 1 < end &&
          _isAsciiPunctuation(source.codeUnitAt(i + 1))) {
        text.write(source.substring(segment, i));
        text.writeCharCode(source.codeUnitAt(i + 1));
        i += 2;
        segment = i;
        continue;
      }

      if (c == _backtick) {
        final close = source.indexOf('`', i + 1);
        if (close != -1 && close < end && close > i + 1) {
          flushText(i);
          nodes.add(MdCode(source.substring(i + 1, close)));
          i = close + 1;
          segment = i;
          continue;
        }
      }

      if (c == _openBracket) {
        final link = _tryLink(i, end);
        if (link != null) {
          flushText(i);
          nodes.add(link.$1);
          i = link.$2;
          segment = i;
          continue;
        }
      }

      if (c == _star || c == _underscore || c == _tilde || c == _pipe) {
        final styled = _tryEmphasis(i, end);
        if (styled != null) {
          flushText(i);
          nodes.add(styled.$1);
          i = styled.$2;
          segment = i;
          continue;
        }
      }

      if (_isWordStart(i, start)) {
        final autolink = _tryAutolink(i, end);
        if (autolink != null) {
          flushText(i);
          nodes.add(autolink.$1);
          i = autolink.$2;
          segment = i;
          continue;
        }
      }

      i++;
    }
    flushText(end);
    return nodes;
  }

  (MdInline, int)? _tryEmphasis(int i, int end) {
    final c = source.codeUnitAt(i);
    final isDouble = i + 1 < end && source.codeUnitAt(i + 1) == c;
    if ((c == _tilde || c == _pipe) && !isDouble) return null;

    // `_` and `__` only work at word boundaries, so snake_case stays intact.
    if (c == _underscore &&
        i > 0 &&
        _isAlphanumeric(source.codeUnitAt(i - 1))) {
      return null;
    }

    if (isDouble) {
      final result = _tryDelimited(i, end, 2, c);
      if (result != null) return result;
      if (c == _tilde || c == _pipe) return null;
    }
    return _tryDelimited(i, end, 1, c);
  }

  (MdInline, int)? _tryDelimited(int i, int end, int length, int char) {
    final contentStart = i + length;
    if (contentStart >= end || _isWhitespace(source.codeUnitAt(contentStart))) {
      return null;
    }
    final close = _findCloser(contentStart, end, length, char);
    if (close == -1) return null;
    final style = switch ((char, length)) {
      (_tilde, _) => MdStyle.strike,
      (_pipe, _) => MdStyle.spoiler,
      (_, 2) => MdStyle.bold,
      _ => MdStyle.italic,
    };
    return (MdStyled(style, _parse(contentStart, close)), close + length);
  }

  int _findCloser(int from, int end, int length, int char) {
    var j = from;
    while (j < end) {
      final c = source.codeUnitAt(j);
      if (c == _backslash) {
        j += 2;
        continue;
      }
      if (c == _backtick) {
        final close = source.indexOf('`', j + 1);
        if (close != -1 && close < end) {
          j = close + 1;
          continue;
        }
      }
      if (c == char) {
        var run = 1;
        while (j + run < end && source.codeUnitAt(j + run) == char) {
          run++;
        }
        final validEnd = j > from && !_isWhitespace(source.codeUnitAt(j - 1));
        final after = j + length;
        final wordBoundary = char != _underscore ||
            after >= end ||
            !_isAlphanumeric(source.codeUnitAt(after));
        // A single delimiter skips over a nested double one (`*a **b** c*`).
        final matchesRun = length == 2 ? run >= 2 : run != 2;
        if (validEnd && wordBoundary && matchesRun) {
          return length == 1 && run > 2 ? j + run - 1 : j;
        }
        j += run;
        continue;
      }
      j++;
    }
    return -1;
  }

  (MdInline, int)? _tryLink(int i, int end) {
    final closeText = source.indexOf(']', i + 1);
    if (closeText == -1 || closeText + 1 >= end) return null;
    if (source.codeUnitAt(closeText + 1) != _openParen) return null;
    if (closeText == i + 1) return null;

    var depth = 1;
    var j = closeText + 2;
    while (j < end) {
      final c = source.codeUnitAt(j);
      if (_isWhitespace(c) && c != 0x20) return null;
      if (c == _openParen) depth++;
      if (c == _closeParen) {
        depth--;
        if (depth == 0) break;
      }
      j++;
    }
    if (j >= end) return null;
    final target = source.substring(closeText + 2, j).trim();
    if (target.isEmpty || target.contains(' ')) return null;
    final label = _parse(i + 1, closeText);
    return (MdLink(target, label), j + 1);
  }

  bool _isWordStart(int i, int start) {
    if (i == start) return true;
    final previous = source.codeUnitAt(i - 1);
    return !_isAlphanumeric(previous) &&
        previous != 0x2F && // '/'
        previous != 0x40 && // '@'
        previous != 0x2E; // '.'
  }

  static const _autolinkPrefixes = ['https://', 'http://', 'www.'];

  (MdInline, int)? _tryAutolink(int i, int end) {
    final c = source.codeUnitAt(i);
    // Fast reject: only `h`, `H`, `w` or `W` can start an autolink.
    if (c != 0x68 && c != 0x48 && c != 0x77 && c != 0x57) return null;
    final prefix = _autolinkPrefixes.firstWhere(
      (p) =>
          i + p.length < end &&
          source.substring(i, i + p.length).toLowerCase() == p,
      orElse: () => '',
    );
    if (prefix.isEmpty) return null;

    var j = i + prefix.length;
    while (j < end) {
      final ch = source.codeUnitAt(j);
      if (_isWhitespace(ch) || ch == 0x3C || ch == 0x3E) break; // '<' '>'
      j++;
    }
    // Trailing punctuation belongs to the sentence, not the URL.
    var openParens = 0;
    for (var k = i; k < j; k++) {
      final ch = source.codeUnitAt(k);
      if (ch == _openParen) openParens++;
      if (ch == _closeParen) openParens--;
    }
    while (j > i + prefix.length) {
      final last = source.codeUnitAt(j - 1);
      if ('.,:;!?\'"*_~'.codeUnits.contains(last)) {
        j--;
      } else if (last == _closeParen && openParens < 0) {
        openParens++;
        j--;
      } else if (last == _closeBracket) {
        j--;
      } else {
        break;
      }
    }
    if (j <= i + prefix.length) return null;
    final url = source.substring(i, j);
    return (MdLink(url, [MdText(url)]), j);
  }
}
