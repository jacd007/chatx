import 'package:flutter/foundation.dart';

/// Decides which links found in message text become tappable.
///
/// Message text usually comes from other users, so it must be treated as
/// untrusted. By default only `http`, `https` and `mailto` links are allowed.
/// Links with any other scheme (for example `javascript:`, `file:`,
/// `intent:` or custom deep links) are rendered as plain text and never reach
/// your `onLinkTap` callback.
///
/// ```dart
/// ChatView(
///   linkPolicy: const ChatLinkPolicy(
///     allowedSchemes: {'https', 'myapp'},
///   ),
///   // ...
/// )
/// ```
@immutable
class ChatLinkPolicy {
  /// Creates a link policy.
  const ChatLinkPolicy({
    this.allowedSchemes = const {'http', 'https', 'mailto'},
  });

  /// Lowercase URI schemes that may become tappable links.
  final Set<String> allowedSchemes;

  /// Parses [raw] and returns the [Uri] if this policy allows it.
  ///
  /// Text starting with `www.` is treated as an `https` link. Returns `null`
  /// for malformed or disallowed links.
  Uri? resolve(String raw) {
    var value = raw.trim();
    if (value.isEmpty || value.length > 2048) return null;
    if (value.toLowerCase().startsWith('www.')) value = 'https://$value';
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return null;
    final scheme = uri.scheme.toLowerCase();
    if (!allowedSchemes.contains(scheme)) return null;
    if ((scheme == 'http' || scheme == 'https') && uri.host.isEmpty) {
      return null;
    }
    if (scheme == 'mailto' && uri.path.isEmpty) return null;
    return uri;
  }

  @override
  bool operator ==(Object other) =>
      other is ChatLinkPolicy &&
      setEquals(other.allowedSchemes, allowedSchemes);

  @override
  int get hashCode => Object.hashAllUnordered(allowedSchemes);
}
