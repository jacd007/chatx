import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

import '../chat_scope.dart';
import '../material.dart';

/// Visual overrides for chatx widgets.
///
/// Every field is optional. Fields you leave `null` are derived from the
/// ambient Material 3 [ThemeData], so chatx matches your app (including dark
/// mode) with no configuration.
///
/// Provide overrides in one of two ways:
///
/// * App-wide, as a theme extension:
///
///   ```dart
///   MaterialApp(
///     theme: ThemeData(
///       extensions: const [ChatTheme(outgoingBubbleColor: Colors.teal)],
///     ),
///   )
///   ```
///
/// * For a single chat, through `ChatView.theme`.
///
/// Text styles are merged with the defaults, so `TextStyle(fontSize: 18)`
/// only changes the size. Read the fully resolved values with
/// [ChatThemeData.of].
@immutable
class ChatTheme extends ThemeExtension<ChatTheme> with Diagnosticable {
  /// Creates a set of theme overrides.
  const ChatTheme({
    this.backgroundColor,
    this.outgoingBubbleColor,
    this.incomingBubbleColor,
    this.outgoingTextStyle,
    this.incomingTextStyle,
    this.linkStyle,
    this.codeTextStyle,
    this.timestampTextStyle,
    this.userNameTextStyle,
    this.dateSeparatorTextStyle,
    this.dateSeparatorColor,
    this.systemMessageTextStyle,
    this.bubbleRadius,
    this.bubbleGroupedRadius,
    this.bubblePadding,
    this.maxBubbleWidth,
    this.maxBubbleWidthFactor,
    this.avatarSize,
    this.inputBackgroundColor,
    this.inputFieldColor,
    this.inputTextStyle,
    this.inputHintStyle,
    this.sendButtonColor,
    this.sendButtonIconColor,
    this.readStatusColor,
    this.errorColor,
    this.typingIndicatorColor,
    this.scrollButtonColor,
    this.scrollButtonIconColor,
    this.unreadBadgeColor,
    this.unreadBadgeTextColor,
  });

  /// Background behind the message list.
  final Color? backgroundColor;

  /// Bubble color of messages sent by the current user.
  final Color? outgoingBubbleColor;

  /// Bubble color of messages sent by other users.
  final Color? incomingBubbleColor;

  /// Text style inside outgoing bubbles.
  final TextStyle? outgoingTextStyle;

  /// Text style inside incoming bubbles.
  final TextStyle? incomingTextStyle;

  /// Style merged on top of the bubble text style for links.
  final TextStyle? linkStyle;

  /// Style merged on top of the bubble text style for code.
  final TextStyle? codeTextStyle;

  /// Style of the time and "edited" label inside bubbles. Its color defaults
  /// to the bubble text color at 70% opacity.
  final TextStyle? timestampTextStyle;

  /// Style of author names above incoming groups.
  final TextStyle? userNameTextStyle;

  /// Style of the day labels between messages.
  final TextStyle? dateSeparatorTextStyle;

  /// Background of the day label pill.
  final Color? dateSeparatorColor;

  /// Style of `SystemMessage` text.
  final TextStyle? systemMessageTextStyle;

  /// Corner radius of bubbles.
  final double? bubbleRadius;

  /// Corner radius on the side where consecutive bubbles of a group touch.
  final double? bubbleGroupedRadius;

  /// Padding inside bubbles.
  final EdgeInsetsGeometry? bubblePadding;

  /// Absolute maximum bubble width, in logical pixels.
  final double? maxBubbleWidth;

  /// Maximum bubble width as a fraction of the list width.
  final double? maxBubbleWidthFactor;

  /// Diameter of avatars.
  final double? avatarSize;

  /// Background of the input bar.
  final Color? inputBackgroundColor;

  /// Fill color of the text field in the input bar.
  final Color? inputFieldColor;

  /// Style of the text typed in the input bar.
  final TextStyle? inputTextStyle;

  /// Style of the input bar placeholder.
  final TextStyle? inputHintStyle;

  /// Background of the send button.
  final Color? sendButtonColor;

  /// Icon color of the send button.
  final Color? sendButtonIconColor;

  /// Color of the "read" status icon.
  final Color? readStatusColor;

  /// Color used for failed messages.
  final Color? errorColor;

  /// Color of the typing indicator dots.
  final Color? typingIndicatorColor;

  /// Background of the scroll-to-bottom button.
  final Color? scrollButtonColor;

  /// Icon color of the scroll-to-bottom button.
  final Color? scrollButtonIconColor;

  /// Background of the unread counter badge.
  final Color? unreadBadgeColor;

  /// Text color of the unread counter badge.
  final Color? unreadBadgeTextColor;

  @override
  ChatTheme copyWith({
    Color? backgroundColor,
    Color? outgoingBubbleColor,
    Color? incomingBubbleColor,
    TextStyle? outgoingTextStyle,
    TextStyle? incomingTextStyle,
    TextStyle? linkStyle,
    TextStyle? codeTextStyle,
    TextStyle? timestampTextStyle,
    TextStyle? userNameTextStyle,
    TextStyle? dateSeparatorTextStyle,
    Color? dateSeparatorColor,
    TextStyle? systemMessageTextStyle,
    double? bubbleRadius,
    double? bubbleGroupedRadius,
    EdgeInsetsGeometry? bubblePadding,
    double? maxBubbleWidth,
    double? maxBubbleWidthFactor,
    double? avatarSize,
    Color? inputBackgroundColor,
    Color? inputFieldColor,
    TextStyle? inputTextStyle,
    TextStyle? inputHintStyle,
    Color? sendButtonColor,
    Color? sendButtonIconColor,
    Color? readStatusColor,
    Color? errorColor,
    Color? typingIndicatorColor,
    Color? scrollButtonColor,
    Color? scrollButtonIconColor,
    Color? unreadBadgeColor,
    Color? unreadBadgeTextColor,
  }) {
    return ChatTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      outgoingBubbleColor: outgoingBubbleColor ?? this.outgoingBubbleColor,
      incomingBubbleColor: incomingBubbleColor ?? this.incomingBubbleColor,
      outgoingTextStyle: outgoingTextStyle ?? this.outgoingTextStyle,
      incomingTextStyle: incomingTextStyle ?? this.incomingTextStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      codeTextStyle: codeTextStyle ?? this.codeTextStyle,
      timestampTextStyle: timestampTextStyle ?? this.timestampTextStyle,
      userNameTextStyle: userNameTextStyle ?? this.userNameTextStyle,
      dateSeparatorTextStyle:
          dateSeparatorTextStyle ?? this.dateSeparatorTextStyle,
      dateSeparatorColor: dateSeparatorColor ?? this.dateSeparatorColor,
      systemMessageTextStyle:
          systemMessageTextStyle ?? this.systemMessageTextStyle,
      bubbleRadius: bubbleRadius ?? this.bubbleRadius,
      bubbleGroupedRadius: bubbleGroupedRadius ?? this.bubbleGroupedRadius,
      bubblePadding: bubblePadding ?? this.bubblePadding,
      maxBubbleWidth: maxBubbleWidth ?? this.maxBubbleWidth,
      maxBubbleWidthFactor: maxBubbleWidthFactor ?? this.maxBubbleWidthFactor,
      avatarSize: avatarSize ?? this.avatarSize,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputFieldColor: inputFieldColor ?? this.inputFieldColor,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      inputHintStyle: inputHintStyle ?? this.inputHintStyle,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      sendButtonIconColor: sendButtonIconColor ?? this.sendButtonIconColor,
      readStatusColor: readStatusColor ?? this.readStatusColor,
      errorColor: errorColor ?? this.errorColor,
      typingIndicatorColor: typingIndicatorColor ?? this.typingIndicatorColor,
      scrollButtonColor: scrollButtonColor ?? this.scrollButtonColor,
      scrollButtonIconColor:
          scrollButtonIconColor ?? this.scrollButtonIconColor,
      unreadBadgeColor: unreadBadgeColor ?? this.unreadBadgeColor,
      unreadBadgeTextColor: unreadBadgeTextColor ?? this.unreadBadgeTextColor,
    );
  }

  /// Returns a theme where non-null fields of [other] replace this one's.
  /// Text styles are merged.
  ChatTheme merge(ChatTheme? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      outgoingBubbleColor: other.outgoingBubbleColor,
      incomingBubbleColor: other.incomingBubbleColor,
      outgoingTextStyle:
          _mergeStyle(outgoingTextStyle, other.outgoingTextStyle),
      incomingTextStyle:
          _mergeStyle(incomingTextStyle, other.incomingTextStyle),
      linkStyle: _mergeStyle(linkStyle, other.linkStyle),
      codeTextStyle: _mergeStyle(codeTextStyle, other.codeTextStyle),
      timestampTextStyle:
          _mergeStyle(timestampTextStyle, other.timestampTextStyle),
      userNameTextStyle:
          _mergeStyle(userNameTextStyle, other.userNameTextStyle),
      dateSeparatorTextStyle:
          _mergeStyle(dateSeparatorTextStyle, other.dateSeparatorTextStyle),
      dateSeparatorColor: other.dateSeparatorColor,
      systemMessageTextStyle:
          _mergeStyle(systemMessageTextStyle, other.systemMessageTextStyle),
      bubbleRadius: other.bubbleRadius,
      bubbleGroupedRadius: other.bubbleGroupedRadius,
      bubblePadding: other.bubblePadding,
      maxBubbleWidth: other.maxBubbleWidth,
      maxBubbleWidthFactor: other.maxBubbleWidthFactor,
      avatarSize: other.avatarSize,
      inputBackgroundColor: other.inputBackgroundColor,
      inputFieldColor: other.inputFieldColor,
      inputTextStyle: _mergeStyle(inputTextStyle, other.inputTextStyle),
      inputHintStyle: _mergeStyle(inputHintStyle, other.inputHintStyle),
      sendButtonColor: other.sendButtonColor,
      sendButtonIconColor: other.sendButtonIconColor,
      readStatusColor: other.readStatusColor,
      errorColor: other.errorColor,
      typingIndicatorColor: other.typingIndicatorColor,
      scrollButtonColor: other.scrollButtonColor,
      scrollButtonIconColor: other.scrollButtonIconColor,
      unreadBadgeColor: other.unreadBadgeColor,
      unreadBadgeTextColor: other.unreadBadgeTextColor,
    );
  }

  static TextStyle? _mergeStyle(TextStyle? a, TextStyle? b) =>
      a == null ? b : a.merge(b);

  @override
  ChatTheme lerp(covariant ChatTheme? other, double t) {
    if (other == null) return this;
    return ChatTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      outgoingBubbleColor:
          Color.lerp(outgoingBubbleColor, other.outgoingBubbleColor, t),
      incomingBubbleColor:
          Color.lerp(incomingBubbleColor, other.incomingBubbleColor, t),
      outgoingTextStyle:
          TextStyle.lerp(outgoingTextStyle, other.outgoingTextStyle, t),
      incomingTextStyle:
          TextStyle.lerp(incomingTextStyle, other.incomingTextStyle, t),
      linkStyle: TextStyle.lerp(linkStyle, other.linkStyle, t),
      codeTextStyle: TextStyle.lerp(codeTextStyle, other.codeTextStyle, t),
      timestampTextStyle:
          TextStyle.lerp(timestampTextStyle, other.timestampTextStyle, t),
      userNameTextStyle:
          TextStyle.lerp(userNameTextStyle, other.userNameTextStyle, t),
      dateSeparatorTextStyle: TextStyle.lerp(
          dateSeparatorTextStyle, other.dateSeparatorTextStyle, t),
      dateSeparatorColor:
          Color.lerp(dateSeparatorColor, other.dateSeparatorColor, t),
      systemMessageTextStyle: TextStyle.lerp(
          systemMessageTextStyle, other.systemMessageTextStyle, t),
      bubbleRadius: lerpDouble(bubbleRadius, other.bubbleRadius, t),
      bubbleGroupedRadius:
          lerpDouble(bubbleGroupedRadius, other.bubbleGroupedRadius, t),
      bubblePadding:
          EdgeInsetsGeometry.lerp(bubblePadding, other.bubblePadding, t),
      maxBubbleWidth: lerpDouble(maxBubbleWidth, other.maxBubbleWidth, t),
      maxBubbleWidthFactor:
          lerpDouble(maxBubbleWidthFactor, other.maxBubbleWidthFactor, t),
      avatarSize: lerpDouble(avatarSize, other.avatarSize, t),
      inputBackgroundColor:
          Color.lerp(inputBackgroundColor, other.inputBackgroundColor, t),
      inputFieldColor: Color.lerp(inputFieldColor, other.inputFieldColor, t),
      inputTextStyle: TextStyle.lerp(inputTextStyle, other.inputTextStyle, t),
      inputHintStyle: TextStyle.lerp(inputHintStyle, other.inputHintStyle, t),
      sendButtonColor: Color.lerp(sendButtonColor, other.sendButtonColor, t),
      sendButtonIconColor:
          Color.lerp(sendButtonIconColor, other.sendButtonIconColor, t),
      readStatusColor: Color.lerp(readStatusColor, other.readStatusColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      typingIndicatorColor:
          Color.lerp(typingIndicatorColor, other.typingIndicatorColor, t),
      scrollButtonColor:
          Color.lerp(scrollButtonColor, other.scrollButtonColor, t),
      scrollButtonIconColor:
          Color.lerp(scrollButtonIconColor, other.scrollButtonIconColor, t),
      unreadBadgeColor: Color.lerp(unreadBadgeColor, other.unreadBadgeColor, t),
      unreadBadgeTextColor:
          Color.lerp(unreadBadgeTextColor, other.unreadBadgeTextColor, t),
    );
  }

  List<Object?> get _props => [
        backgroundColor,
        outgoingBubbleColor,
        incomingBubbleColor,
        outgoingTextStyle,
        incomingTextStyle,
        linkStyle,
        codeTextStyle,
        timestampTextStyle,
        userNameTextStyle,
        dateSeparatorTextStyle,
        dateSeparatorColor,
        systemMessageTextStyle,
        bubbleRadius,
        bubbleGroupedRadius,
        bubblePadding,
        maxBubbleWidth,
        maxBubbleWidthFactor,
        avatarSize,
        inputBackgroundColor,
        inputFieldColor,
        inputTextStyle,
        inputHintStyle,
        sendButtonColor,
        sendButtonIconColor,
        readStatusColor,
        errorColor,
        typingIndicatorColor,
        scrollButtonColor,
        scrollButtonIconColor,
        unreadBadgeColor,
        unreadBadgeTextColor,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatTheme && listEquals(other._props, _props);

  @override
  int get hashCode => Object.hashAll(_props);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('outgoingBubbleColor', outgoingBubbleColor))
      ..add(ColorProperty('incomingBubbleColor', incomingBubbleColor))
      ..add(DoubleProperty('bubbleRadius', bubbleRadius));
  }
}

/// Fully resolved visual values used by chatx widgets.
///
/// Obtain it with [ChatThemeData.of]. Unlike [ChatTheme], every value is
/// non-null, which makes it convenient inside your own builders:
///
/// ```dart
/// bubbleBuilder: (context, details, child) {
///   final theme = ChatThemeData.of(context);
///   return DecoratedBox(
///     decoration: BoxDecoration(color: theme.incomingBubbleColor),
///     child: child,
///   );
/// },
/// ```
@immutable
class ChatThemeData {
  /// Creates resolved theme values. Prefer [ChatThemeData.fallback] or
  /// [ChatThemeData.of].
  const ChatThemeData({
    required this.backgroundColor,
    required this.outgoingBubbleColor,
    required this.incomingBubbleColor,
    required this.outgoingTextStyle,
    required this.incomingTextStyle,
    required this.linkStyle,
    required this.codeTextStyle,
    required this.timestampTextStyle,
    required this.userNameTextStyle,
    required this.dateSeparatorTextStyle,
    required this.dateSeparatorColor,
    required this.systemMessageTextStyle,
    required this.bubbleRadius,
    required this.bubbleGroupedRadius,
    required this.bubblePadding,
    required this.maxBubbleWidth,
    required this.maxBubbleWidthFactor,
    required this.avatarSize,
    required this.inputBackgroundColor,
    required this.inputFieldColor,
    required this.inputTextStyle,
    required this.inputHintStyle,
    required this.sendButtonColor,
    required this.sendButtonIconColor,
    required this.readStatusColor,
    required this.errorColor,
    required this.typingIndicatorColor,
    required this.scrollButtonColor,
    required this.scrollButtonIconColor,
    required this.unreadBadgeColor,
    required this.unreadBadgeTextColor,
  });

  /// Derives every value from a Material [theme].
  factory ChatThemeData.fallback(ThemeData theme) {
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final body = (text.bodyLarge ?? const TextStyle(fontSize: 16))
        .copyWith(height: 1.35);
    return ChatThemeData(
      backgroundColor: scheme.surface,
      outgoingBubbleColor: scheme.primary,
      incomingBubbleColor: scheme.surfaceContainerHigh,
      outgoingTextStyle: body.copyWith(color: scheme.onPrimary),
      incomingTextStyle: body.copyWith(color: scheme.onSurface),
      linkStyle: const TextStyle(
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w600,
      ),
      codeTextStyle: TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: const ['Menlo', 'Consolas', 'Roboto Mono'],
        fontSize: (body.fontSize ?? 16) * 0.88,
      ),
      // No color: the footer derives it from the bubble text color so it
      // stays readable on both bubble colors.
      timestampTextStyle: TextStyle(
        fontSize: text.labelSmall?.fontSize ?? 11,
        fontWeight: text.labelSmall?.fontWeight,
        letterSpacing: 0.2,
      ),
      userNameTextStyle: (text.labelMedium ?? const TextStyle(fontSize: 12))
          .copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
      dateSeparatorTextStyle:
          (text.labelMedium ?? const TextStyle(fontSize: 12)).copyWith(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      dateSeparatorColor: scheme.surfaceContainerHighest,
      systemMessageTextStyle: (text.bodySmall ?? const TextStyle(fontSize: 12))
          .copyWith(color: scheme.onSurfaceVariant),
      bubbleRadius: 20,
      bubbleGroupedRadius: 6,
      bubblePadding: const EdgeInsets.fromLTRB(14, 9, 14, 7),
      maxBubbleWidth: 560,
      maxBubbleWidthFactor: 0.78,
      avatarSize: 32,
      inputBackgroundColor: scheme.surface,
      inputFieldColor: scheme.surfaceContainerHigh,
      inputTextStyle: body.copyWith(color: scheme.onSurface),
      inputHintStyle: body.copyWith(color: scheme.onSurfaceVariant),
      sendButtonColor: scheme.primary,
      sendButtonIconColor: scheme.onPrimary,
      readStatusColor: scheme.inversePrimary,
      errorColor: scheme.error,
      typingIndicatorColor: scheme.onSurfaceVariant,
      scrollButtonColor: scheme.secondaryContainer,
      scrollButtonIconColor: scheme.onSecondaryContainer,
      unreadBadgeColor: scheme.primary,
      unreadBadgeTextColor: scheme.onPrimary,
    );
  }

  /// Resolves the theme for [context].
  ///
  /// Inside a `ChatView`, returns the values the view uses. Elsewhere, merges
  /// the [ChatTheme] extension of the ambient [ThemeData] (if any) on top of
  /// [ChatThemeData.fallback].
  static ChatThemeData of(BuildContext context) {
    final scope = ChatScope.maybeOf(context);
    if (scope != null) return scope.theme;
    final theme = Theme.of(context);
    return ChatThemeData.fallback(theme).merge(theme.extension<ChatTheme>());
  }

  /// See [ChatTheme.backgroundColor].
  final Color backgroundColor;

  /// See [ChatTheme.outgoingBubbleColor].
  final Color outgoingBubbleColor;

  /// See [ChatTheme.incomingBubbleColor].
  final Color incomingBubbleColor;

  /// See [ChatTheme.outgoingTextStyle].
  final TextStyle outgoingTextStyle;

  /// See [ChatTheme.incomingTextStyle].
  final TextStyle incomingTextStyle;

  /// See [ChatTheme.linkStyle].
  final TextStyle linkStyle;

  /// See [ChatTheme.codeTextStyle].
  final TextStyle codeTextStyle;

  /// See [ChatTheme.timestampTextStyle].
  final TextStyle timestampTextStyle;

  /// See [ChatTheme.userNameTextStyle].
  final TextStyle userNameTextStyle;

  /// See [ChatTheme.dateSeparatorTextStyle].
  final TextStyle dateSeparatorTextStyle;

  /// See [ChatTheme.dateSeparatorColor].
  final Color dateSeparatorColor;

  /// See [ChatTheme.systemMessageTextStyle].
  final TextStyle systemMessageTextStyle;

  /// See [ChatTheme.bubbleRadius].
  final double bubbleRadius;

  /// See [ChatTheme.bubbleGroupedRadius].
  final double bubbleGroupedRadius;

  /// See [ChatTheme.bubblePadding].
  final EdgeInsetsGeometry bubblePadding;

  /// See [ChatTheme.maxBubbleWidth].
  final double maxBubbleWidth;

  /// See [ChatTheme.maxBubbleWidthFactor].
  final double maxBubbleWidthFactor;

  /// See [ChatTheme.avatarSize].
  final double avatarSize;

  /// See [ChatTheme.inputBackgroundColor].
  final Color inputBackgroundColor;

  /// See [ChatTheme.inputFieldColor].
  final Color inputFieldColor;

  /// See [ChatTheme.inputTextStyle].
  final TextStyle inputTextStyle;

  /// See [ChatTheme.inputHintStyle].
  final TextStyle inputHintStyle;

  /// See [ChatTheme.sendButtonColor].
  final Color sendButtonColor;

  /// See [ChatTheme.sendButtonIconColor].
  final Color sendButtonIconColor;

  /// See [ChatTheme.readStatusColor].
  final Color readStatusColor;

  /// See [ChatTheme.errorColor].
  final Color errorColor;

  /// See [ChatTheme.typingIndicatorColor].
  final Color typingIndicatorColor;

  /// See [ChatTheme.scrollButtonColor].
  final Color scrollButtonColor;

  /// See [ChatTheme.scrollButtonIconColor].
  final Color scrollButtonIconColor;

  /// See [ChatTheme.unreadBadgeColor].
  final Color unreadBadgeColor;

  /// See [ChatTheme.unreadBadgeTextColor].
  final Color unreadBadgeTextColor;

  /// Text style of a bubble, depending on its direction.
  TextStyle bubbleTextStyle({required bool isOutgoing}) =>
      isOutgoing ? outgoingTextStyle : incomingTextStyle;

  /// Background of a bubble, depending on its direction.
  Color bubbleColor({required bool isOutgoing}) =>
      isOutgoing ? outgoingBubbleColor : incomingBubbleColor;

  /// Returns a copy where the non-null values of [overrides] win.
  /// Text styles are merged.
  ChatThemeData merge(ChatTheme? overrides) {
    final o = overrides;
    if (o == null) return this;
    return ChatThemeData(
      backgroundColor: o.backgroundColor ?? backgroundColor,
      outgoingBubbleColor: o.outgoingBubbleColor ?? outgoingBubbleColor,
      incomingBubbleColor: o.incomingBubbleColor ?? incomingBubbleColor,
      outgoingTextStyle: outgoingTextStyle.merge(o.outgoingTextStyle),
      incomingTextStyle: incomingTextStyle.merge(o.incomingTextStyle),
      linkStyle: linkStyle.merge(o.linkStyle),
      codeTextStyle: codeTextStyle.merge(o.codeTextStyle),
      timestampTextStyle: timestampTextStyle.merge(o.timestampTextStyle),
      userNameTextStyle: userNameTextStyle.merge(o.userNameTextStyle),
      dateSeparatorTextStyle:
          dateSeparatorTextStyle.merge(o.dateSeparatorTextStyle),
      dateSeparatorColor: o.dateSeparatorColor ?? dateSeparatorColor,
      systemMessageTextStyle:
          systemMessageTextStyle.merge(o.systemMessageTextStyle),
      bubbleRadius: o.bubbleRadius ?? bubbleRadius,
      bubbleGroupedRadius: o.bubbleGroupedRadius ?? bubbleGroupedRadius,
      bubblePadding: o.bubblePadding ?? bubblePadding,
      maxBubbleWidth: o.maxBubbleWidth ?? maxBubbleWidth,
      maxBubbleWidthFactor: o.maxBubbleWidthFactor ?? maxBubbleWidthFactor,
      avatarSize: o.avatarSize ?? avatarSize,
      inputBackgroundColor: o.inputBackgroundColor ?? inputBackgroundColor,
      inputFieldColor: o.inputFieldColor ?? inputFieldColor,
      inputTextStyle: inputTextStyle.merge(o.inputTextStyle),
      inputHintStyle: inputHintStyle.merge(o.inputHintStyle),
      sendButtonColor: o.sendButtonColor ?? sendButtonColor,
      sendButtonIconColor: o.sendButtonIconColor ?? sendButtonIconColor,
      readStatusColor: o.readStatusColor ?? readStatusColor,
      errorColor: o.errorColor ?? errorColor,
      typingIndicatorColor: o.typingIndicatorColor ?? typingIndicatorColor,
      scrollButtonColor: o.scrollButtonColor ?? scrollButtonColor,
      scrollButtonIconColor: o.scrollButtonIconColor ?? scrollButtonIconColor,
      unreadBadgeColor: o.unreadBadgeColor ?? unreadBadgeColor,
      unreadBadgeTextColor: o.unreadBadgeTextColor ?? unreadBadgeTextColor,
    );
  }

  List<Object?> get _props => [
        backgroundColor,
        outgoingBubbleColor,
        incomingBubbleColor,
        outgoingTextStyle,
        incomingTextStyle,
        linkStyle,
        codeTextStyle,
        timestampTextStyle,
        userNameTextStyle,
        dateSeparatorTextStyle,
        dateSeparatorColor,
        systemMessageTextStyle,
        bubbleRadius,
        bubbleGroupedRadius,
        bubblePadding,
        maxBubbleWidth,
        maxBubbleWidthFactor,
        avatarSize,
        inputBackgroundColor,
        inputFieldColor,
        inputTextStyle,
        inputHintStyle,
        sendButtonColor,
        sendButtonIconColor,
        readStatusColor,
        errorColor,
        typingIndicatorColor,
        scrollButtonColor,
        scrollButtonIconColor,
        unreadBadgeColor,
        unreadBadgeTextColor,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatThemeData && listEquals(other._props, _props);

  @override
  int get hashCode => Object.hashAll(_props);
}
