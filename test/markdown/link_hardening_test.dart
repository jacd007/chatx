import 'package:chatx/chatx.dart';
import 'package:chatx/src/markdown/markdown_parser.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const ana = ChatUser(id: 'ana', name: 'Ana');

void main() {
  Future<List<Uri>> pumpText(
    WidgetTester tester,
    String text, {
    ChatLinkPolicy linkPolicy = const ChatLinkPolicy(),
    List<ChatUser> mentionableUsers = const [],
    ValueChanged<ChatUser>? onMentionTap,
    String? highlight,
  }) async {
    final opened = <Uri>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: ChatText(
            text,
            onLinkTap: opened.add,
            linkPolicy: linkPolicy,
            mentionableUsers: mentionableUsers,
            onMentionTap: onMentionTap,
            highlight: highlight,
          ),
        ),
      ),
    ));
    return opened;
  }

  Future<void> tapText(WidgetTester tester, String substring) async {
    await tester.tapOnText(find.textRange.ofSubstring(substring));
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('real taps', () {
    testWidgets('open a plain autolink', (tester) async {
      final opened = await pumpText(tester, 'see https://dart.dev now');
      await tapText(tester, 'dart.dev');
      expect(opened, [Uri.parse('https://dart.dev')]);
    });

    testWidgets('open a [label](url) link', (tester) async {
      final opened =
          await pumpText(tester, 'read [the docs](https://dart.dev)');
      await tapText(tester, 'docs');
      expect(opened, [Uri.parse('https://dart.dev')]);
    });

    testWidgets('open a link with a bold label', (tester) async {
      final opened =
          await pumpText(tester, '[**bold** plain](https://dart.dev)');
      await tapText(tester, 'bold');
      await tapText(tester, 'plain');
      expect(opened, [
        Uri.parse('https://dart.dev'),
        Uri.parse('https://dart.dev'),
      ]);
    });

    testWidgets('a mention inside a label opens the link', (tester) async {
      final mentioned = <ChatUser>[];
      final opened = await pumpText(
        tester,
        '[ping @Ana](https://dart.dev)',
        mentionableUsers: const [ana],
        onMentionTap: mentioned.add,
      );
      await tapText(tester, '@Ana');
      expect(opened, [Uri.parse('https://dart.dev')]);
      expect(mentioned, isEmpty);
    });

    testWidgets('a mention outside links still opens the user', (tester) async {
      final mentioned = <ChatUser>[];
      final opened = await pumpText(
        tester,
        'hi @Ana',
        mentionableUsers: const [ana],
        onMentionTap: mentioned.add,
      );
      await tapText(tester, '@Ana');
      expect(mentioned, [ana]);
      expect(opened, isEmpty);
    });

    testWidgets('a nested link opens only the outer target', (tester) async {
      final opened = await pumpText(
        tester,
        '[https://dart.dev](https://dart.dev/guides)',
      );
      await tapText(tester, 'dart.dev');
      expect(opened, [Uri.parse('https://dart.dev/guides')]);
    });

    testWidgets('a spoiler label is revealed before it opens', (tester) async {
      final opened = await pumpText(tester, '[||secret||](https://dart.dev)');
      // The hidden spoiler reads as its semantics label, so tap its middle.
      await tester.tap(find.byType(RichText));
      await tester.pump();
      expect(opened, isEmpty);
      await tapText(tester, 'secret');
      expect(opened, [Uri.parse('https://dart.dev')]);
    });

    testWidgets('every leaf of a label shares one recognizer', (tester) async {
      await pumpText(tester, '[a **b** `c`](https://dart.dev)');
      final recognizers = <GestureRecognizer>{};
      void walk(InlineSpan span) {
        if (span is! TextSpan) return;
        if ((span.text ?? '').isNotEmpty) {
          expect(span.recognizer, isNotNull, reason: span.text);
          recognizers.add(span.recognizer!);
        }
        span.children?.forEach(walk);
      }

      walk(tester.widget<RichText>(find.byType(RichText)).text);
      expect(recognizers, hasLength(1));
    });
  });

  group('link semantics', () {
    // Semantics nodes that screen readers announce as links.
    List<SemanticsNode> linkNodes(WidgetTester tester) {
      final nodes = <SemanticsNode>[];
      bool visit(SemanticsNode node) {
        final data = node.getSemanticsData();
        // hasFlag is deprecated on newer Flutter, but flagsCollection does
        // not exist on the minimum supported version.
        // ignore: deprecated_member_use
        if (data.hasFlag(SemanticsFlag.isLink)) {
          expect(data.hasAction(SemanticsAction.tap), isTrue);
          nodes.add(node);
        }
        node.visitChildren(visit);
        return true;
      }

      visit(tester.getSemantics(find.byType(RichText)));
      return nodes;
    }

    List<String> linkLabels(WidgetTester tester) => [
          for (final node in linkNodes(tester)) node.getSemanticsData().label,
        ];

    for (final (name, source, highlight, label) in [
      (
        'a bold label',
        '[**bold** plain](https://dart.dev)',
        null,
        'bold plain'
      ),
      (
        'a highlighted label',
        '[the docs](https://dart.dev)',
        'doc',
        'the docs'
      ),
      (
        'a mention and code',
        '[@Ana `run`](https://dart.dev)',
        null,
        '@Ana run',
      ),
      (
        'a revealed host',
        '[bank.com](https://evil.com)',
        null,
        'bank.com (evil.com)',
      ),
    ]) {
      testWidgets('$name is one link', (tester) async {
        final handle = tester.ensureSemantics();
        final opened = await pumpText(
          tester,
          source,
          highlight: highlight,
          mentionableUsers: const [ana],
        );
        expect(linkLabels(tester), [label]);
        final link = linkNodes(tester).single;
        link.owner!.performAction(link.id, SemanticsAction.tap);
        expect(opened, hasLength(1));
        // Real taps still hit every part of the label.
        await tapText(tester, label.split(' ').first);
        await tapText(tester, label.split(' ').last);
        expect(opened, hasLength(3));
        handle.dispose();
      });
    }

    testWidgets('separate links stay separate', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpText(
        tester,
        '[**a** b](https://dart.dev) and [c](https://flutter.dev)',
      );
      expect(linkLabels(tester), ['a b', 'c']);
      handle.dispose();
    });

    testWidgets('a hidden spoiler in a label is not read out', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpText(tester, '[open ||secret||](https://dart.dev)');
      expect(linkLabels(tester).join(), isNot(contains('secret')));
      handle.dispose();
    });
  });

  group('deceptive labels', () {
    String shownText(WidgetTester tester) =>
        tester.widget<RichText>(find.byType(RichText)).text.toPlainText();

    for (final (name, source, shown, target) in [
      (
        'url label',
        '[https://bank.com](https://evil.com)',
        'https://bank.com (evil.com)',
        'https://evil.com',
      ),
      (
        'domain label',
        '[bank.com](https://evil.com)',
        'bank.com (evil.com)',
        'https://evil.com',
      ),
      (
        'www label',
        '[www.bank.com](https://www.evil.com)',
        'www.bank.com (www.evil.com)',
        'https://www.evil.com',
      ),
      (
        'domain with path',
        '[bank.com/login](https://evil.com/login)',
        'bank.com/login (evil.com)',
        'https://evil.com/login',
      ),
      (
        'bare userinfo label',
        '[bank.com@evil.com](https://evil.com)',
        'bank.com@evil.com (evil.com)',
        'https://evil.com',
      ),
      (
        'fullwidth dot label',
        '[bank\uFF0Ecom](https://evil.com)',
        'bank\uFF0Ecom (evil.com)',
        'https://evil.com',
      ),
      (
        'userinfo label',
        '[https://evil.com@bank.com](https://evil.com)',
        'https://evil.com@bank.com (evil.com)',
        'https://evil.com',
      ),
    ]) {
      testWidgets('$name reveals the real host', (tester) async {
        final opened = await pumpText(tester, source);
        expect(shownText(tester), shown);
        await tapText(tester, 'bank');
        expect(opened, [Uri.parse(target)]);
      });
    }

    testWidgets('the revealed host opens the same link', (tester) async {
      final opened = await pumpText(tester, '[bank.com](https://evil.com)');
      await tapText(tester, '(evil.com)');
      expect(opened, [Uri.parse('https://evil.com')]);
    });

    testWidgets('dotted words are revealed, not broken', (tester) async {
      final opened = await pumpText(tester, '[Node.js](https://nodejs.org)');
      expect(shownText(tester), 'Node.js (nodejs.org)');
      await tapText(tester, 'Node.js');
      expect(opened, [Uri.parse('https://nodejs.org')]);
    });

    for (final (name, source, shown, target) in [
      ('word label', '[Bank](https://evil.com)', 'Bank', 'https://evil.com'),
      (
        'same host',
        '[dart.dev](https://dart.dev/guides)',
        'dart.dev',
        'https://dart.dev/guides',
      ),
      (
        'www on the label only',
        '[www.dart.dev](https://dart.dev)',
        'dart.dev',
        'https://dart.dev',
      ),
    ]) {
      testWidgets('$name shows only the label', (tester) async {
        final opened = await pumpText(tester, source);
        expect(shownText(tester), isNot(contains('(')));
        await tapText(tester, shown);
        expect(opened, [Uri.parse(target)]);
      });
    }

    testWidgets('revealDeceptiveTargets: false keeps the old behavior',
        (tester) async {
      final opened = await pumpText(
        tester,
        '[bank.com](https://evil.com)',
        linkPolicy: const ChatLinkPolicy(revealDeceptiveTargets: false),
      );
      expect(shownText(tester), 'bank.com');
      await tapText(tester, 'bank.com');
      expect(opened, [Uri.parse('https://evil.com')]);
    });
  });

  group('ChatLinkPolicy.isDeceptive', () {
    const policy = ChatLinkPolicy();
    final evil = Uri.parse('https://evil.com/path');

    test('labels that name another host', () {
      expect(policy.isDeceptive('https://bank.com', evil), isTrue);
      expect(policy.isDeceptive('http://bank.com/login', evil), isTrue);
      expect(policy.isDeceptive('www.bank.com', evil), isTrue);
      expect(policy.isDeceptive('  bank.com  ', evil), isTrue);
      expect(policy.isDeceptive('bank.com/login?x=1', evil), isTrue);
      expect(policy.isDeceptive('sub.bank.co.uk', evil), isTrue);
      expect(policy.isDeceptive('evil.com.bank.com', evil), isTrue);
      expect(policy.isDeceptive('https://evil.com@bank.com', evil), isTrue);
    });

    test('bare labels hiding a host behind user@', () {
      expect(policy.isDeceptive('bank.com@evil.com', evil), isTrue);
      expect(policy.isDeceptive('www.bank.com@evil.com', evil), isTrue);
      expect(policy.isDeceptive('bank.com@evil.com/login', evil), isTrue);
      expect(policy.isDeceptive('203.0.113.5@evil.com', evil), isTrue);
    });

    test('email-like labels compare only the host', () {
      final x = Uri.parse('https://x.com');
      expect(policy.isDeceptive('ana@x.com', x), isFalse);
      expect(policy.isDeceptive('ana@x.com', evil), isTrue);
      // A dotted user part could be a domain: never trusted.
      expect(policy.isDeceptive('ana.lopez@x.com', x), isTrue);
    });

    test('Unicode full stops count as dots', () {
      expect(policy.isDeceptive('bank\u3002com', evil), isTrue);
      expect(policy.isDeceptive('bank\uFF0Ecom', evil), isTrue);
      expect(policy.isDeceptive('bank\uFF61com/login', evil), isTrue);
      expect(policy.isDeceptive('https://bank\u3002com', evil), isTrue);
      expect(policy.isDeceptive('evil\u3002com', evil), isFalse);
    });

    test('punycode TLDs and IPv4 labels', () {
      expect(policy.isDeceptive('xn--80ak6aa92e.xn--p1ai', evil), isTrue);
      expect(
        policy.isDeceptive(
          'xn--80ak6aa92e.xn--p1ai',
          Uri.parse('https://xn--80ak6aa92e.xn--p1ai/'),
        ),
        isFalse,
      );
      expect(policy.isDeceptive('203.0.113.5', evil), isTrue);
      expect(policy.isDeceptive('203.0.113.5/login', evil), isTrue);
      expect(
        policy.isDeceptive('203.0.113.5', Uri.parse('https://203.0.113.5')),
        isFalse,
      );
    });

    test('ports are not deceptive', () {
      expect(
        policy.isDeceptive('evil.com:8080', Uri.parse('https://evil.com')),
        isFalse,
      );
    });

    test('labels on the same host', () {
      expect(policy.isDeceptive('evil.com', evil), isFalse);
      expect(policy.isDeceptive('EVIL.com', evil), isFalse);
      expect(policy.isDeceptive('www.evil.com', evil), isFalse);
      expect(policy.isDeceptive('https://evil.com./other', evil), isFalse);
      expect(
        policy.isDeceptive('evil.com', Uri.parse('https://www.evil.com')),
        isFalse,
      );
    });

    test('ordinary words are never deceptive', () {
      expect(policy.isDeceptive('Bank', evil), isFalse);
      expect(policy.isDeceptive('click here', evil), isFalse);
      expect(policy.isDeceptive('visit bank.com today', evil), isFalse);
      expect(policy.isDeceptive('3.14', evil), isFalse);
      expect(policy.isDeceptive('v1.2.3', evil), isFalse);
      expect(policy.isDeceptive('', evil), isFalse);
    });

    test('only http and https targets are checked', () {
      expect(
        policy.isDeceptive('bank.com', Uri.parse('mailto:a@evil.com')),
        isFalse,
      );
    });

    test('equality includes revealDeceptiveTargets', () {
      const off = ChatLinkPolicy(revealDeceptiveTargets: false);
      expect(policy, const ChatLinkPolicy());
      expect(policy == off, isFalse);
      expect(policy.hashCode, const ChatLinkPolicy().hashCode);
      expect(off.revealDeceptiveTargets, isFalse);
    });
  });

  test('ChatText.clearCache drops parsed texts', () {
    const text = 'my **private** text';
    final first = MarkdownParser.parseCached(text);
    expect(identical(MarkdownParser.parseCached(text), first), isTrue);
    ChatText.clearCache();
    final second = MarkdownParser.parseCached(text);
    expect(identical(second, first), isFalse);
    expect(second, first);
  });

  group('onCopyText', () {
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
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));
      return writes;
    }

    testWidgets('receives the code instead of the clipboard', (tester) async {
      final writes = captureClipboard(tester);
      final copied = <String>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ChatText('```\napi_key=123\n```', onCopyText: copied.add),
        ),
      ));
      await tester.tap(find.byKey(const Key('chatx_copy_code')));
      await tester.pump(const Duration(seconds: 3));
      expect(copied, ['api_key=123']);
      expect(writes, isEmpty);
    });

    testWidgets('falls back to the clipboard when null', (tester) async {
      final writes = captureClipboard(tester);
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ChatText('```\napi_key=123\n```')),
      ));
      await tester.tap(find.byKey(const Key('chatx_copy_code')));
      await tester.pump(const Duration(seconds: 3));
      expect(writes, ['api_key=123']);
    });
  });
}
