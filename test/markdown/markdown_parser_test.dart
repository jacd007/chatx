import 'package:chatx/chatx.dart';
import 'package:chatx/src/markdown/markdown_parser.dart';
import 'package:flutter_test/flutter_test.dart';

List<MdInline> inline(String s) => MarkdownParser.parseInline(s);

void main() {
  group('inline', () {
    test('plain text', () {
      expect(inline('hello world'), [const MdText('hello world')]);
    });

    test('bold, italic and strike', () {
      expect(inline('**b** *i* _i_ ~~s~~'), [
        const MdStyled(MdStyle.bold, [MdText('b')]),
        const MdText(' '),
        const MdStyled(MdStyle.italic, [MdText('i')]),
        const MdText(' '),
        const MdStyled(MdStyle.italic, [MdText('i')]),
        const MdText(' '),
        const MdStyled(MdStyle.strike, [MdText('s')]),
      ]);
    });

    test('nested emphasis', () {
      expect(inline('*a **b** c*'), [
        const MdStyled(MdStyle.italic, [
          MdText('a '),
          MdStyled(MdStyle.bold, [MdText('b')]),
          MdText(' c'),
        ]),
      ]);
    });

    test('snake_case and lone delimiters stay literal', () {
      expect(inline('my_var_name'), [const MdText('my_var_name')]);
      expect(inline('2 * 3 * 4'), [const MdText('2 * 3 * 4')]);
      expect(inline('**unclosed'), [const MdText('**unclosed')]);
    });

    test('code spans are not parsed', () {
      expect(inline('use `**x**` here'), [
        const MdText('use '),
        const MdCode('**x**'),
        const MdText(' here'),
      ]);
    });

    test('escapes', () {
      expect(inline(r'\*not italic\*'), [const MdText('*not italic*')]);
    });

    test('links', () {
      expect(inline('see [docs](https://dart.dev) now'), [
        const MdText('see '),
        const MdLink('https://dart.dev', [MdText('docs')]),
        const MdText(' now'),
      ]);
    });

    test('autolinks drop trailing punctuation', () {
      expect(inline('go to https://flutter.dev.'), [
        const MdText('go to '),
        const MdLink('https://flutter.dev', [MdText('https://flutter.dev')]),
        const MdText('.'),
      ]);
      expect(inline('(www.dart.dev)'), [
        const MdText('('),
        const MdLink('www.dart.dev', [MdText('www.dart.dev')]),
        const MdText(')'),
      ]);
    });

    test('autolinks keep balanced parentheses', () {
      const url = 'https://en.wikipedia.org/wiki/Dart_(language)';
      expect(inline(url), [
        const MdLink(url, [MdText(url)]),
      ]);
    });

    test('HTML is literal text', () {
      expect(inline('<b>hi</b>'), [const MdText('<b>hi</b>')]);
    });
  });

  group('blocks', () {
    test('paragraphs keep single line breaks', () {
      expect(MarkdownParser.parse('a\nb\n\nc'), [
        const MdParagraph([MdText('a\nb')]),
        const MdParagraph([MdText('c')]),
      ]);
    });

    test('fenced code block', () {
      expect(MarkdownParser.parse('```dart\nvoid main() {}\n```'), [
        const MdCodeBlock('void main() {}', language: 'dart'),
      ]);
    });

    test('unclosed fence runs to the end (streaming)', () {
      expect(MarkdownParser.parse('```\nline 1\nline 2'), [
        const MdCodeBlock('line 1\nline 2'),
      ]);
    });

    test('quote, lists and headings', () {
      final blocks = MarkdownParser.parse(
        '# Title\n> quoted\n- one\n- two\n3. three\n4. four',
      );
      expect(blocks[0], const MdHeading(1, [MdText('Title')]));
      expect(
          blocks[1],
          const MdQuote([
            MdParagraph([MdText('quoted')])
          ]));
      expect(
        blocks[2],
        const MdList(ordered: false, items: [
          [MdText('one')],
          [MdText('two')],
        ]),
      );
      expect(
        blocks[3],
        const MdList(ordered: true, start: 3, items: [
          [MdText('three')],
          [MdText('four')],
        ]),
      );
    });

    test('hashtags are not headings', () {
      expect(MarkdownParser.parse('#flutter'), [
        const MdParagraph([MdText('#flutter')]),
      ]);
    });

    test('never throws on arbitrary input', () {
      const samples = [
        '',
        '*',
        '**',
        '***',
        '[',
        '[]()',
        '[a](',
        '`',
        '``',
        '~~',
        '\\',
        '_*_*',
        '> ',
        '1.',
        '- ',
        '```',
        '](',
        'http://',
        'www.',
      ];
      for (final s in samples) {
        expect(() => MarkdownParser.parse(s), returnsNormally, reason: s);
      }
    });
  });

  group('ChatLinkPolicy', () {
    const policy = ChatLinkPolicy();

    test('allows web and mail links', () {
      expect(policy.resolve('https://dart.dev'), Uri.parse('https://dart.dev'));
      expect(policy.resolve('www.dart.dev'), Uri.parse('https://www.dart.dev'));
      expect(policy.resolve('mailto:a@b.com'), isNotNull);
    });

    test('blocks dangerous or malformed links', () {
      expect(policy.resolve('javascript:alert(1)'), isNull);
      expect(policy.resolve('JavaScript:alert(1)'), isNull);
      expect(policy.resolve('file:///etc/passwd'), isNull);
      expect(policy.resolve('intent://scan#Intent;end'), isNull);
      expect(policy.resolve('data:text/html,<script>'), isNull);
      expect(policy.resolve('https://'), isNull);
      expect(policy.resolve('relative/path'), isNull);
    });

    test('custom schemes can be allowed', () {
      const custom = ChatLinkPolicy(allowedSchemes: {'myapp'});
      expect(custom.resolve('myapp://open/1'), isNotNull);
      expect(custom.resolve('https://dart.dev'), isNull);
    });
  });
}
