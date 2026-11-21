import 'package:flutter/gestures.dart';

import '../l10n/chat_localizations.dart';
import '../material.dart';
import '../models/chat_user.dart';
import 'chat_link_policy.dart';
import 'markdown_parser.dart';

/// Renders message text with chatx's markdown subset.
///
/// Supported syntax:
///
/// | Syntax                       | Result              |
/// | ---------------------------- | ------------------- |
/// | `**bold**` or `__bold__`     | **bold**            |
/// | `*italic*` or `_italic_`     | _italic_            |
/// | `~~strike~~`                 | strikethrough       |
/// | `` `code` ``                 | inline code         |
/// | ```` ``` ```` fences         | code block          |
/// | `> quote`                    | block quote         |
/// | `- item`, `1. item`          | lists               |
/// | `# Heading`                  | heading             |
/// | `[label](https://...)`       | link                |
/// | `\|\|spoiler\|\|`              | hidden until tapped |
/// | `https://...`, `www....`     | automatic link      |
///
/// HTML is never interpreted. Links are filtered by [linkPolicy]; only
/// allowed links are tappable and passed to [onLinkTap].
///
/// `ChatView` uses this widget for every `TextMessage`. You can also use it
/// in your own builders.
class ChatText extends StatefulWidget {
  /// Creates a markdown text widget.
  const ChatText(
    this.text, {
    super.key,
    this.style,
    this.linkStyle,
    this.codeStyle,
    this.codeBackgroundColor,
    this.onLinkTap,
    this.linkPolicy = const ChatLinkPolicy(),
    this.trailing,
    this.enableMarkdown = true,
    this.mentionableUsers = const [],
    this.onMentionTap,
    this.mentionStyle,
    this.currentUserId,
    this.highlight,
    this.highlightColor,
  });

  /// Raw markdown source.
  final String text;

  /// Base text style. Defaults to the ambient [DefaultTextStyle].
  final TextStyle? style;

  /// Style merged on top of [style] for links. Defaults to an underline.
  final TextStyle? linkStyle;

  /// Style merged on top of [style] for inline code and code blocks.
  /// Defaults to a monospace font.
  final TextStyle? codeStyle;

  /// Background of code spans and code blocks. Defaults to the text color
  /// at 12% opacity.
  final Color? codeBackgroundColor;

  /// Called with the resolved [Uri] when the user taps an allowed link.
  /// When `null`, links are styled but not tappable.
  final ValueChanged<Uri>? onLinkTap;

  /// Filters which links are tappable.
  final ChatLinkPolicy linkPolicy;

  /// Inline content appended after the last paragraph, such as a streaming
  /// caret.
  final InlineSpan? trailing;

  /// When `false`, [text] is shown verbatim (links are still detected).
  final bool enableMarkdown;

  /// Users that can be mentioned. `@Name` (case-insensitive) is styled as a
  /// mention when it matches one of their names.
  final List<ChatUser> mentionableUsers;

  /// Called when the user taps a mention.
  final ValueChanged<ChatUser>? onMentionTap;

  /// Style merged on top of the text style for mentions. Defaults to bold.
  final TextStyle? mentionStyle;

  /// Mentions of this user are emphasized with a background.
  final String? currentUserId;

  /// Text to highlight, for example the current search query.
  final String? highlight;

  /// Background of [highlight] matches.
  final Color? highlightColor;

  @override
  State<ChatText> createState() => _ChatTextState();
}

class _ChatTextState extends State<ChatText> {
  final List<TapGestureRecognizer> _recognizers = [];
  List<MdBlock>? _blocks;
  bool _spoilersRevealed = false;
  List<ChatUser> _mentionUsers = const [];

  @override
  void didUpdateWidget(ChatText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.enableMarkdown != widget.enableMarkdown) {
      _blocks = null;
      if (oldWidget.text != widget.text) _spoilersRevealed = false;
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  List<MdBlock> _parse() {
    if (widget.enableMarkdown) return MarkdownParser.parse(widget.text);
    return [MdParagraph(_linksOnly(widget.text))];
  }

  // Detects links without applying any other markdown.
  static List<MdInline> _linksOnly(String text) {
    final nodes = <MdInline>[];
    for (final node in MarkdownParser.parseInline(text)) {
      if (node is MdLink && node.children.length == 1) {
        final child = node.children.single;
        if (child is MdText && child.text == node.target) {
          nodes.add(node);
          continue;
        }
      }
      nodes.add(MdText(_plain(node)));
    }
    return _mergeText(nodes);
  }

  static String _plain(MdInline node) => switch (node) {
        MdText(:final text) => text,
        MdCode(:final code) => code,
        MdStyled(:final children) => children.map(_plain).join(),
        MdLink(:final children) => children.map(_plain).join(),
      };

  static List<MdInline> _mergeText(List<MdInline> nodes) {
    final merged = <MdInline>[];
    for (final node in nodes) {
      final last = merged.isEmpty ? null : merged.last;
      if (node is MdText && last is MdText) {
        merged[merged.length - 1] = MdText(last.text + node.text);
      } else {
        merged.add(node);
      }
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    // Recognizers are rebuilt with the spans; the previous ones are released.
    _disposeRecognizers();
    final blocks = _blocks ??= _parse();
    // Longest names first, so "@Ana María" wins over "@Ana".
    _mentionUsers = [
      for (final user in widget.mentionableUsers)
        if ((user.name ?? '').trim().isNotEmpty) user,
    ]..sort((a, b) => b.name!.length.compareTo(a.name!.length));
    final base = DefaultTextStyle.of(context).style.merge(widget.style);
    final color = base.color ?? Theme.of(context).colorScheme.onSurface;
    final codeBackground =
        widget.codeBackgroundColor ?? color.withValues(alpha: 0.12);
    final style = _Styles(
      base: base,
      link: base.merge(
        const TextStyle(
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
        ).merge(widget.linkStyle).copyWith(decorationColor: color),
      ),
      code: base
          .merge(
            const TextStyle(
              fontFamily: 'monospace',
              fontFamilyFallback: ['Menlo', 'Consolas', 'Roboto Mono'],
            ),
          )
          .merge(widget.codeStyle),
      codeBackground: codeBackground,
      quoteBar: color.withValues(alpha: 0.4),
      mention: base
          .merge(const TextStyle(fontWeight: FontWeight.w700))
          .merge(widget.mentionStyle),
      selfMentionBackground: color.withValues(alpha: 0.16),
      spoiler: TextStyle(
        color: const Color(0x00000000),
        backgroundColor: color.withValues(alpha: 0.3),
        decoration: TextDecoration.none,
      ),
      highlightBackground: widget.highlightColor ??
          Theme.of(context).colorScheme.tertiaryContainer,
      spoilerLabel: ChatLocalizations.of(context).spoiler,
    );

    if (blocks.isEmpty) {
      return Text.rich(
        TextSpan(style: base, children: [
          if (widget.trailing != null) widget.trailing!,
        ]),
      );
    }

    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      if (i > 0) children.add(const SizedBox(height: 6));
      final isLast = i == blocks.length - 1;
      children.add(_block(blocks[i], style, trailing: isLast));
    }
    if (children.length == 1) return children.single;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _block(MdBlock block, _Styles style, {required bool trailing}) {
    final tail = trailing ? widget.trailing : null;
    switch (block) {
      case MdParagraph(:final children):
        return _richText(children, style.base, style, trailing: tail);
      case MdHeading(:final level, :final children):
        final scale = const [1.4, 1.3, 1.2, 1.1, 1.0, 1.0][level - 1];
        final size = (style.base.fontSize ?? 14) * scale;
        return _richText(
          children,
          style.base.copyWith(fontSize: size, fontWeight: FontWeight.w700),
          style,
          trailing: tail,
        );
      case MdCodeBlock(:final code, :final language):
        return Semantics(
          label: language,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: style.codeBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text.rich(
                TextSpan(
                  text: code,
                  style: style.code,
                  children: [if (tail != null) tail],
                ),
                softWrap: false,
              ),
            ),
          ),
        );
      case MdQuote(:final children):
        final quoteStyle = style.copyWithBase(
          style.base.copyWith(
            color: style.base.color?.withValues(alpha: 0.85),
            fontStyle: FontStyle.italic,
          ),
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: style.quoteBar, width: 3)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < children.length; i++)
                  _block(
                    children[i],
                    quoteStyle,
                    trailing: trailing && i == children.length - 1,
                  ),
              ],
            ),
          ),
        );
      case MdList(:final ordered, :final start, :final items):
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      excluding: !ordered,
                      child: Text(ordered ? '${start + i}.' : '•',
                          style: style.base),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _richText(
                        items[i],
                        style.base,
                        style,
                        trailing: i == items.length - 1 ? tail : null,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
    }
  }

  Widget _richText(
    List<MdInline> nodes,
    TextStyle textStyle,
    _Styles style, {
    InlineSpan? trailing,
  }) {
    return Text.rich(
      TextSpan(
        style: textStyle,
        children: [
          for (final node in nodes) _inline(node, style),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  InlineSpan _inline(MdInline node, _Styles style) {
    switch (node) {
      case MdText(:final text):
        return TextSpan(children: _decorate(text, style));
      case MdStyled(style: MdStyle.spoiler, :final children)
          when !_spoilersRevealed:
        final recognizer = TapGestureRecognizer()
          ..onTap = () => setState(() => _spoilersRevealed = true);
        _recognizers.add(recognizer);
        return TextSpan(
          text: children.map(_plain).join(),
          style: style.spoiler,
          recognizer: recognizer,
          semanticsLabel: style.spoilerLabel,
          mouseCursor: SystemMouseCursors.click,
        );
      case MdStyled(style: final kind, :final children):
        return TextSpan(
          style: switch (kind) {
            MdStyle.bold => const TextStyle(fontWeight: FontWeight.w700),
            MdStyle.italic => const TextStyle(fontStyle: FontStyle.italic),
            MdStyle.strike =>
              const TextStyle(decoration: TextDecoration.lineThrough),
            MdStyle.spoiler => null,
          },
          children: [
            for (final child in children) _inline(child, style),
          ],
        );
      case MdCode(:final code):
        return TextSpan(
          text: code,
          style: style.code.copyWith(backgroundColor: style.codeBackground),
        );
      case MdLink(:final target, :final children):
        final uri = widget.linkPolicy.resolve(target);
        if (uri == null) {
          // Disallowed links keep their label but are never interactive.
          return TextSpan(children: [
            for (final child in children) _inline(child, style),
          ]);
        }
        final onLinkTap = widget.onLinkTap;
        TapGestureRecognizer? recognizer;
        if (onLinkTap != null) {
          recognizer = TapGestureRecognizer()..onTap = () => onLinkTap(uri);
          _recognizers.add(recognizer);
        }
        return TextSpan(
          style: style.link,
          recognizer: recognizer,
          mouseCursor:
              recognizer == null ? MouseCursor.defer : SystemMouseCursors.click,
          children: [
            for (final child in children) _inline(child, style),
          ],
        );
    }
  }
}

extension on _ChatTextState {
  /// Splits plain text into spans for mentions and highlighted matches.
  List<InlineSpan> _decorate(String text, _Styles style) {
    final spans = <InlineSpan>[];
    var plainStart = 0;
    var i = 0;
    while (i < text.length) {
      final mention = _mentionAt(text, i);
      if (mention == null) {
        i++;
        continue;
      }
      spans.addAll(_highlighted(text.substring(plainStart, i), style));
      final (user, length) = mention;
      final onTap = widget.onMentionTap;
      TapGestureRecognizer? recognizer;
      if (onTap != null) {
        recognizer = TapGestureRecognizer()..onTap = () => onTap(user);
        _recognizers.add(recognizer);
      }
      final isSelf = user.id == widget.currentUserId;
      spans.add(
        TextSpan(
          text: text.substring(i, i + length),
          style: isSelf
              ? style.mention
                  .copyWith(backgroundColor: style.selfMentionBackground)
              : style.mention,
          recognizer: recognizer,
          mouseCursor:
              recognizer == null ? MouseCursor.defer : SystemMouseCursors.click,
        ),
      );
      i += length;
      plainStart = i;
    }
    spans.addAll(_highlighted(text.substring(plainStart), style));
    return spans;
  }

  /// Returns the mentioned user and the length of `@Name` at [index].
  (ChatUser, int)? _mentionAt(String text, int index) {
    if (_mentionUsers.isEmpty || text.codeUnitAt(index) != 0x40) return null;
    if (index > 0 && _isWordChar(text.codeUnitAt(index - 1))) return null;
    final rest = text.substring(index + 1).toLowerCase();
    for (final user in _mentionUsers) {
      final name = user.name!.toLowerCase();
      if (!rest.startsWith(name)) continue;
      final end = index + 1 + name.length;
      if (end < text.length && _isWordChar(text.codeUnitAt(end))) continue;
      return (user, name.length + 1);
    }
    return null;
  }

  static bool _isWordChar(int c) =>
      (c >= 0x30 && c <= 0x39) ||
      (c >= 0x41 && c <= 0x5A) ||
      (c >= 0x61 && c <= 0x7A) ||
      c == 0x5F ||
      c > 0x7F;

  List<InlineSpan> _highlighted(String text, _Styles style) {
    if (text.isEmpty) return const [];
    final query = widget.highlight?.trim().toLowerCase() ?? '';
    if (query.isEmpty) return [TextSpan(text: text)];
    final lower = text.toLowerCase();
    final spans = <InlineSpan>[];
    var start = 0;
    while (true) {
      final match = lower.indexOf(query, start);
      if (match == -1) break;
      if (match > start) {
        spans.add(TextSpan(text: text.substring(start, match)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match, match + query.length),
          style: TextStyle(backgroundColor: style.highlightBackground),
        ),
      );
      start = match + query.length;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return spans;
  }
}

class _Styles {
  const _Styles({
    required this.base,
    required this.link,
    required this.code,
    required this.codeBackground,
    required this.quoteBar,
    required this.mention,
    required this.selfMentionBackground,
    required this.spoiler,
    required this.highlightBackground,
    required this.spoilerLabel,
  });

  final TextStyle base;
  final TextStyle link;
  final TextStyle code;
  final Color codeBackground;
  final Color quoteBar;
  final TextStyle mention;
  final Color selfMentionBackground;
  final TextStyle spoiler;
  final Color highlightBackground;
  final String spoilerLabel;

  _Styles copyWithBase(TextStyle base) => _Styles(
        base: base,
        link: link,
        code: code,
        codeBackground: codeBackground,
        quoteBar: quoteBar,
        mention: mention,
        selfMentionBackground: selfMentionBackground,
        spoiler: spoiler,
        highlightBackground: highlightBackground,
        spoilerLabel: spoilerLabel,
      );
}
