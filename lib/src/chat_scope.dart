import 'package:flutter/widgets.dart';

import 'l10n/chat_localizations.dart';
import 'theme/chat_theme.dart';

/// Shares the resolved theme and strings of a `ChatView` with its subtree.
///
/// Internal: read the values with `ChatThemeData.of` and
/// `ChatLocalizations.of` instead.
class ChatScope extends InheritedWidget {
  /// Creates a scope.
  const ChatScope({
    super.key,
    required this.theme,
    required this.localizations,
    required super.child,
  });

  /// Resolved theme of the enclosing `ChatView`.
  final ChatThemeData theme;

  /// Strings of the enclosing `ChatView`.
  final ChatLocalizations localizations;

  /// Returns the nearest scope, or `null` outside a `ChatView`.
  static ChatScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChatScope>();

  @override
  bool updateShouldNotify(ChatScope oldWidget) =>
      theme != oldWidget.theme || localizations != oldWidget.localizations;
}
