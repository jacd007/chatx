import '../material.dart';

/// Colors used to highlight code.
@immutable
class SyntaxPalette {
  /// Creates a palette.
  const SyntaxPalette({
    required this.keyword,
    required this.string,
    required this.comment,
    required this.number,
    required this.type,
    required this.function,
    required this.property,
  });

  /// GitHub-inspired colors for light backgrounds.
  static const light = SyntaxPalette(
    keyword: Color(0xFFCF222E),
    string: Color(0xFF0A3069),
    comment: Color(0xFF6E7781),
    number: Color(0xFF0550AE),
    type: Color(0xFF8250DF),
    function: Color(0xFF6639BA),
    property: Color(0xFF953800),
  );

  /// GitHub-inspired colors for dark backgrounds.
  static const dark = SyntaxPalette(
    keyword: Color(0xFFFF7B72),
    string: Color(0xFFA5D6FF),
    comment: Color(0xFF8B949E),
    number: Color(0xFF79C0FF),
    type: Color(0xFFD2A8FF),
    function: Color(0xFFD2A8FF),
    property: Color(0xFFFFA657),
  );

  /// Color of keywords such as `final` or `return`.
  final Color keyword;

  /// Color of string literals.
  final Color string;

  /// Color of comments.
  final Color comment;

  /// Color of numbers and constants such as `true`.
  final Color number;

  /// Color of type names and annotations.
  final Color type;

  /// Color of function names at call sites.
  final Color function;

  /// Color of object keys, for example in JSON.
  final Color property;
}

/// Tokenizes code and returns colored spans. Supports Dart, JavaScript and
/// TypeScript, Python, JSON, SQL, Kotlin, Swift, Java, Go, Rust, shell and
/// YAML; other languages get strings, comments and numbers.
abstract final class SyntaxHighlighter {
  static const _common = {
    'if',
    'else',
    'for',
    'while',
    'do',
    'return',
    'break',
    'continue',
    'switch',
    'case',
    'default',
    'try',
    'catch',
    'finally',
    'throw',
    'new',
    'class',
    'import',
    'export',
    'from',
    'as',
    'in',
    'is',
    'this',
    'super',
    'static',
    'const',
    'final',
    'var',
    'let',
    'function',
    'async',
    'await',
    'yield',
    'extends',
    'implements',
    'interface',
    'enum',
    'public',
    'private',
    'protected',
    'void',
    'null',
    'true',
    'false',
    'typeof',
  };

  static const Map<String, Set<String>> _keywords = {
    'dart': {
      ..._common,
      'late',
      'required',
      'sealed',
      'mixin',
      'with',
      'factory',
      'get',
      'set',
      'operator',
      'part',
      'library',
      'show',
      'hide',
      'when',
      'external',
      'covariant',
      'dynamic',
      'abstract',
      'base',
      'extension',
    },
    'js': {..._common, 'undefined', 'of', 'delete', 'instanceof'},
    'ts': {
      ..._common,
      'type',
      'readonly',
      'keyof',
      'namespace',
      'declare',
      'abstract',
      'any',
      'unknown',
      'never',
      'undefined',
      'of',
    },
    'python': {
      'def',
      'class',
      'return',
      'if',
      'elif',
      'else',
      'for',
      'while',
      'in',
      'not',
      'and',
      'or',
      'is',
      'import',
      'from',
      'as',
      'with',
      'try',
      'except',
      'finally',
      'raise',
      'pass',
      'break',
      'continue',
      'lambda',
      'yield',
      'async',
      'await',
      'global',
      'None',
      'True',
      'False',
      'self',
    },
    'sql': {
      'select',
      'from',
      'where',
      'and',
      'or',
      'not',
      'insert',
      'into',
      'values',
      'update',
      'set',
      'delete',
      'create',
      'table',
      'drop',
      'alter',
      'join',
      'left',
      'right',
      'inner',
      'outer',
      'on',
      'group',
      'by',
      'order',
      'having',
      'limit',
      'offset',
      'as',
      'distinct',
      'null',
      'is',
      'in',
      'like',
      'primary',
      'key',
      'index',
      'asc',
      'desc',
      'count',
      'union',
    },
    'kotlin': {
      ..._common,
      'fun',
      'val',
      'object',
      'data',
      'sealed',
      'when',
      'override',
      'open',
      'internal',
      'companion',
      'suspend',
      'lateinit',
    },
    'swift': {
      ..._common,
      'func',
      'struct',
      'protocol',
      'guard',
      'self',
      'Self',
      'some',
      'override',
      'mutating',
      'inout',
      'nil',
      'actor',
      'extension',
    },
    'java': {
      ..._common,
      'package',
      'abstract',
      'synchronized',
      'boolean',
      'int',
      'long',
      'double',
      'float',
      'char',
      'byte',
      'short',
      'instanceof',
    },
    'go': {
      'func',
      'package',
      'import',
      'var',
      'const',
      'type',
      'struct',
      'interface',
      'map',
      'chan',
      'go',
      'defer',
      'select',
      'if',
      'else',
      'for',
      'range',
      'return',
      'switch',
      'case',
      'default',
      'nil',
      'true',
      'false',
      'break',
      'continue',
    },
    'rust': {
      'fn',
      'let',
      'mut',
      'pub',
      'struct',
      'enum',
      'impl',
      'trait',
      'use',
      'mod',
      'match',
      'if',
      'else',
      'for',
      'while',
      'loop',
      'return',
      'self',
      'Self',
      'true',
      'false',
      'async',
      'await',
      'move',
      'ref',
      'where',
      'const',
      'static',
      'crate',
      'super',
    },
    'shell': {
      'if',
      'then',
      'else',
      'elif',
      'fi',
      'for',
      'do',
      'done',
      'while',
      'case',
      'esac',
      'function',
      'echo',
      'export',
      'return',
      'in',
      'local',
    },
    'yaml': {'true', 'false', 'null', 'yes', 'no'},
  };

  static const Map<String, String> _aliases = {
    'javascript': 'js',
    'jsx': 'js',
    'mjs': 'js',
    'typescript': 'ts',
    'tsx': 'ts',
    'py': 'python',
    'kt': 'kotlin',
    'kts': 'kotlin',
    'sh': 'shell',
    'bash': 'shell',
    'zsh': 'shell',
    'yml': 'yaml',
    'golang': 'go',
    'rs': 'rust',
    'postgres': 'sql',
    'mysql': 'sql',
  };

  static final RegExp _colonAhead = RegExp(r'[ \t]*:');
  static final RegExp _number =
      RegExp(r'0[xX][0-9a-fA-F]+|\d[\d_]*(\.\d+)?([eE][+-]?\d+)?');

  static String? _normalize(String? language) {
    if (language == null) return null;
    final lower = language.toLowerCase();
    return _aliases[lower] ?? lower;
  }

  /// Returns colored spans for [code]. Plain parts inherit the text style.
  static List<TextSpan> highlight(
    String code, {
    required String? language,
    required SyntaxPalette palette,
  }) {
    final lang = _normalize(language);
    final keywords = _keywords[lang] ?? const <String>{};
    final caseInsensitive = lang == 'sql';
    final hashComments = lang == 'python' || lang == 'shell' || lang == 'yaml';
    final dashComments = lang == 'sql';
    final isJson = lang == 'json';

    final spans = <TextSpan>[];
    final plain = StringBuffer();
    void flush() {
      if (plain.isEmpty) return;
      spans.add(TextSpan(text: plain.toString()));
      plain.clear();
    }

    void emit(String text, Color color, {FontStyle? style}) {
      flush();
      spans.add(
        TextSpan(text: text, style: TextStyle(color: color, fontStyle: style)),
      );
    }

    var i = 0;
    final length = code.length;
    while (i < length) {
      final c = code[i];

      // Comments.
      if ((!hashComments && !isJson && code.startsWith('//', i)) ||
          (hashComments && c == '#') ||
          (dashComments && code.startsWith('--', i))) {
        final end = code.indexOf('\n', i);
        final stop = end == -1 ? length : end;
        emit(code.substring(i, stop), palette.comment, style: FontStyle.italic);
        i = stop;
        continue;
      }
      if (!hashComments && code.startsWith('/*', i)) {
        final end = code.indexOf('*/', i + 2);
        final stop = end == -1 ? length : end + 2;
        emit(code.substring(i, stop), palette.comment, style: FontStyle.italic);
        i = stop;
        continue;
      }

      // Strings, including triple-quoted ones.
      if (c == '"' || c == "'" || c == '`') {
        final triple = code.startsWith(c * 3, i);
        final quote = triple ? c * 3 : c;
        var j = i + quote.length;
        while (j < length) {
          if (code[j] == r'\' && !triple) {
            j += 2;
            continue;
          }
          if (code.startsWith(quote, j)) {
            j += quote.length;
            break;
          }
          if (!triple && c != '`' && code[j] == '\n') break;
          j++;
        }
        final stop = j > length ? length : j;
        final text = code.substring(i, stop);
        // JSON keys are strings followed by a colon.
        final isKey = isJson && _colonAhead.matchAsPrefix(code, stop) != null;
        emit(text, isKey ? palette.property : palette.string);
        i = stop;
        continue;
      }

      // Numbers.
      if (_isDigit(c) && (i == 0 || !_isWord(code[i - 1]))) {
        final match = _number.matchAsPrefix(code, i);
        if (match != null) {
          emit(match.group(0)!, palette.number);
          i = match.end;
          continue;
        }
      }

      // Annotations and decorators.
      if (c == '@' && i + 1 < length && _isWordStart(code[i + 1])) {
        var j = i + 1;
        while (j < length && _isWord(code[j])) {
          j++;
        }
        emit(code.substring(i, j), palette.type);
        i = j;
        continue;
      }

      // Words: keywords, types and function calls.
      if (_isWordStart(c)) {
        var j = i;
        while (j < length && _isWord(code[j])) {
          j++;
        }
        final word = code.substring(i, j);
        final lookup = caseInsensitive ? word.toLowerCase() : word;
        if (keywords.contains(lookup) ||
            (isJson && (word == 'true' || word == 'false' || word == 'null'))) {
          emit(word, isJson ? palette.number : palette.keyword);
        } else if (lang != 'sql' &&
            lang != 'shell' &&
            word[0].toUpperCase() == word[0] &&
            word[0].toLowerCase() != word[0]) {
          emit(word, palette.type);
        } else if (j < length && code[j] == '(') {
          emit(word, palette.function);
        } else if (lang == 'yaml' &&
            _colonAhead.matchAsPrefix(code, j) != null) {
          emit(word, palette.property);
        } else {
          plain.write(word);
        }
        i = j;
        continue;
      }

      plain.write(c);
      i++;
    }
    flush();
    return spans;
  }

  static bool _isDigit(String c) =>
      c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;

  static bool _isWordStart(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 0x41 && u <= 0x5A) ||
        (u >= 0x61 && u <= 0x7A) ||
        u == 0x5F ||
        u == 0x24;
  }

  static bool _isWord(String c) => _isWordStart(c) || _isDigit(c);
}
