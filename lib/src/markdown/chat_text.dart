import 'dart:async';
import 'dart:ui' show LocaleStringAttribute, SpellOutStringAttribute;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import '../l10n/chat_localizations.dart';
import '../material.dart';
import '../models/chat_user.dart';
import 'chat_link_policy.dart';
import 'markdown_parser.dart';
import 'syntax_highlighter.dart';

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
/// allowed links are tappable and passed to [onLinkTap]. Mentions and links
/// inside a link label are part of that label, not separate targets.
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
    this.onCopyText,
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

  /// Called instead of writing to the clipboard when the user copies a code
  /// block. Use it to mark copied text as sensitive or to clear it later.
  /// When `null`, the text goes to the clipboard.
  final ValueChanged<String>? onCopyText;

  /// Drops the parsed markdown that chatx keeps for recently shown texts.
  ///
  /// Parsed messages are cached in memory, across all [ChatText] widgets, so
  /// scrolling stays fast. Call this when that text should no longer be
  /// held, for example when the user logs out.
  static void clearCache() => MarkdownParser.clearCache();

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
    if (widget.enableMarkdown) return MarkdownParser.parseCached(widget.text);
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
        return _CodeBlock(
          code: code,
          language: language,
          style: style.code,
          background: style.codeBackground,
          trailing: tail,
          onCopy: widget.onCopyText,
        );
      case MdTable():
        return _table(block, style);
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

  Widget _table(MdTable table, _Styles style) {
    final border = style.quoteBar.withValues(alpha: 0.35);
    TextAlign align(int column) => switch (table.alignments[column]) {
          MdAlign.left => TextAlign.start,
          MdAlign.center => TextAlign.center,
          MdAlign.right => TextAlign.end,
        };
    Widget cell(List<MdInline> nodes, int column, {bool header = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text.rich(
          TextSpan(
            style: header
                ? style.base.copyWith(fontWeight: FontWeight.w700)
                : style.base,
            children: [for (final node in nodes) _inline(node, style)],
          ),
          textAlign: align(column),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(color: border),
          children: [
            TableRow(
              decoration: BoxDecoration(color: style.codeBackground),
              children: [
                for (var c = 0; c < table.header.length; c++)
                  cell(table.header[c], c, header: true),
              ],
            ),
            for (final row in table.rows)
              TableRow(
                children: [
                  for (var c = 0; c < row.length; c++) cell(row[c], c),
                ],
              ),
          ],
        ),
      ),
    );
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

  // [link] is set while rendering a link label. Every leaf span of the label
  // carries its recognizer, because taps hit the leaf that holds the text.
  // [_LinkSpan] then gives screen readers the label as one link.
  InlineSpan _inline(MdInline node, _Styles style, [_LinkLabel? link]) {
    switch (node) {
      case MdText(:final text):
        return TextSpan(children: _decorate(text, style, link));
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
            for (final child in children) _inline(child, style, link),
          ],
        );
      case MdCode(:final code):
        return TextSpan(
          text: code,
          style: style.code.copyWith(backgroundColor: style.codeBackground),
          recognizer: link?.recognizer,
          mouseCursor: link?.cursor ?? MouseCursor.defer,
        );
      case MdLink(:final children) when link != null:
        // A link inside a link label is only text of the outer label.
        return TextSpan(children: [
          for (final child in children) _inline(child, style, link),
        ]);
      case MdLink(:final target, :final children):
        final policy = widget.linkPolicy;
        final uri = policy.resolve(target);
        if (uri == null) {
          // Disallowed links keep their label but are never interactive.
          return TextSpan(children: [
            for (final child in children)
              _inline(child, style, const _LinkLabel(null)),
          ]);
        }
        final onLinkTap = widget.onLinkTap;
        TapGestureRecognizer? recognizer;
        if (onLinkTap != null) {
          recognizer = TapGestureRecognizer()..onTap = () => onLinkTap(uri);
          _recognizers.add(recognizer);
        }
        final label = _LinkLabel(recognizer);
        // A label that names another address shows where the link really
        // goes, as part of the same link.
        final reveal = policy.revealDeceptiveTargets &&
            policy.isDeceptive(children.map(_plain).join(), uri);
        return _LinkSpan(
          link: recognizer,
          style: style.link,
          mouseCursor: label.cursor,
          children: [
            for (final child in children) _inline(child, style, label),
            if (reveal)
              TextSpan(
                text: ' (${uri.host})',
                style: TextStyle(
                  color: style.link.color?.withValues(alpha: 0.75),
                ),
                recognizer: recognizer,
                mouseCursor: label.cursor,
              ),
          ],
        );
    }
  }
}

/// A link label: its leaves share [link], so a tap on any of them opens it.
///
/// Flutter gives every leaf span with a recognizer its own semantics node,
/// so a label split by styles, mentions or a search highlight would read
/// as several links. This span reports the whole label as one link instead.
class _LinkSpan extends TextSpan {
  const _LinkSpan({
    required this.link,
    super.style,
    super.mouseCursor,
    super.children,
  });

  /// Opens the link, or `null` when the link is not tappable.
  final TapGestureRecognizer? link;

  @override
  void computeSemanticsInformation(
    List<InlineSpanSemanticsInformation> collector, {
    Locale? inheritedLocale,
    bool inheritedSpellOut = false,
  }) {
    final text = StringBuffer();
    var merge = link != null;
    // Leaves with their own recognizer (a hidden spoiler) or label keep
    // their own nodes, so nothing hidden is read out.
    visitChildren((span) {
      if (span is! TextSpan) return merge = false;
      final value = span.text;
      if (value == null) return true;
      if (span.recognizer != link || span.semanticsLabel != null) {
        return merge = false;
      }
      text.write(value);
      return true;
    });
    if (!merge || text.isEmpty) {
      super.computeSemanticsInformation(
        collector,
        inheritedLocale: inheritedLocale,
        inheritedSpellOut: inheritedSpellOut,
      );
      return;
    }
    final label = text.toString();
    final effectiveLocale = locale ?? inheritedLocale;
    collector.add(
      InlineSpanSemanticsInformation(
        label,
        stringAttributes: [
          if (spellOut ?? inheritedSpellOut)
            SpellOutStringAttribute(
                range: TextRange(start: 0, end: label.length)),
          if (effectiveLocale != null)
            LocaleStringAttribute(
              locale: effectiveLocale,
              range: TextRange(start: 0, end: label.length),
            ),
        ],
        recognizer: link,
      ),
    );
  }
}

/// The link whose label is being rendered.
class _LinkLabel {
  const _LinkLabel(this.recognizer);

  /// Opens the link, or `null` when the link is not tappable.
  final TapGestureRecognizer? recognizer;

  MouseCursor get cursor =>
      recognizer == null ? MouseCursor.defer : SystemMouseCursors.click;
}

extension on _ChatTextState {
  /// Splits plain text into spans for mentions and highlighted matches.
  ///
  /// Inside a [link] label, mentions are styled but open the link instead.
  List<InlineSpan> _decorate(String text, _Styles style, _LinkLabel? link) {
    final spans = <InlineSpan>[];
    var plainStart = 0;
    var i = 0;
    while (i < text.length) {
      final mention = _mentionAt(text, i);
      if (mention == null) {
        i++;
        continue;
      }
      spans.addAll(_highlighted(text.substring(plainStart, i), style, link));
      final (user, length) = mention;
      final onTap = widget.onMentionTap;
      var recognizer = link?.recognizer;
      if (link == null && onTap != null) {
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
    spans.addAll(_highlighted(text.substring(plainStart), style, link));
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

  List<InlineSpan> _highlighted(
    String text,
    _Styles style,
    _LinkLabel? link,
  ) {
    if (text.isEmpty) return const [];
    final recognizer = link?.recognizer;
    final cursor = link?.cursor ?? MouseCursor.defer;
    TextSpan leaf(String text, [TextStyle? style]) => TextSpan(
          text: text,
          style: style,
          recognizer: recognizer,
          mouseCursor: cursor,
        );
    final query = widget.highlight?.trim().toLowerCase() ?? '';
    if (query.isEmpty) return [leaf(text)];
    final lower = text.toLowerCase();
    final spans = <InlineSpan>[];
    var start = 0;
    while (true) {
      final match = lower.indexOf(query, start);
      if (match == -1) break;
      if (match > start) spans.add(leaf(text.substring(start, match)));
      spans.add(
        leaf(
          text.substring(match, match + query.length),
          TextStyle(backgroundColor: style.highlightBackground),
        ),
      );
      start = match + query.length;
    }
    if (start < text.length) spans.add(leaf(text.substring(start)));
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

/// Fenced code block with syntax colors, language label and copy button.
class _CodeBlock extends StatefulWidget {
  const _CodeBlock({
    required this.code,
    required this.language,
    required this.style,
    required this.background,
    required this.trailing,
    required this.onCopy,
  });

  final String code;
  final String? language;
  final TextStyle style;
  final Color background;
  final InlineSpan? trailing;
  final ValueChanged<String>? onCopy;

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  void _copy() {
    final onCopy = widget.onCopy;
    if (onCopy != null) {
      onCopy(widget.code);
    } else {
      Clipboard.setData(ClipboardData(text: widget.code));
    }
    HapticFeedback.selectionClick();
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final color = widget.style.color ?? Theme.of(context).colorScheme.onSurface;
    // Light text means a dark background, and the other way around.
    final palette = color.computeLuminance() > 0.5
        ? SyntaxPalette.dark
        : SyntaxPalette.light;
    final label = widget.language;
    final muted = color.withValues(alpha: 0.65);
    return DecoratedBox(
      key: const Key('chatx_code_block'),
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 10),
                child: Text(
                  label ?? '',
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: _copied ? l10n.copied : l10n.copyCode,
                excludeSemantics: true,
                child: InkWell(
                  key: const Key('chatx_copy_code'),
                  onTap: _copy,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 32),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _copied ? Icons.check_rounded : Icons.copy_rounded,
                            size: 14,
                            color: muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _copied ? l10n.copied : l10n.copyCode,
                            style: TextStyle(fontSize: 11, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Text.rich(
              TextSpan(
                style: widget.style,
                children: [
                  ...SyntaxHighlighter.highlight(
                    widget.code,
                    language: label,
                    palette: palette,
                  ),
                  if (widget.trailing != null) widget.trailing!,
                ],
              ),
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}
