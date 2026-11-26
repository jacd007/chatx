import 'package:flutter/foundation.dart';

/// Decides which links found in message text become tappable.
///
/// Message text usually comes from other users, so it must be treated as
/// untrusted. By default only `http`, `https` and `mailto` links are allowed.
/// Links with any other scheme (for example `javascript:`, `file:`,
/// `intent:` or custom deep links) are rendered as plain text and never reach
/// your `onLinkTap` callback.
///
/// By default, links whose label looks like a different address than the
/// one they open (such as `[bank.com](https://evil.com)`) show the real host
/// after the label. See [revealDeceptiveTargets].
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
    this.revealDeceptiveTargets = true,
  });

  /// Lowercase URI schemes that may become tappable links.
  final Set<String> allowedSchemes;

  /// When `true`, a link whose label looks like a URL or domain on another
  /// host than its target shows that host after the label, as in
  /// `bank.com (evil.com)`. The link stays tappable. See [isDeceptive]; you
  /// can also call it from `onLinkTap` to block such links.
  final bool revealDeceptiveTargets;

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

  /// Whether a link showing [label] but opening [target] misleads the reader.
  ///
  /// A label is deceptive when it looks like an address (`https://...`,
  /// `www....`, a bare domain such as `bank.com/login` or an IPv4 address)
  /// on a different host than [target]. Ordinary words like `Docs` are never
  /// deceptive. Only `http` and `https` targets are checked.
  ///
  /// Ideographic and fullwidth full stops (`bank。com`) count as dots, as
  /// browsers read them that way. A label that hides its host behind `user@`
  /// is deceptive when the part before `@` has a dot (`bank.com@evil.com`)
  /// or the label starts with a scheme. An email-like label such as
  /// `ana@x.com` on an `https` target is compared by its host only: it is
  /// deceptive on `https://evil.com` but not on `https://x.com`.
  bool isDeceptive(String label, Uri target) {
    final scheme = target.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return false;
    final text = label.trim().replaceAll(_unicodeDots, '.');
    if (text.isEmpty) return false;
    final hasScheme = _schemePrefix.hasMatch(text);
    String candidate;
    if (hasScheme) {
      candidate = text;
    } else if (text.toLowerCase().startsWith('www.') ||
        _bareDomain.hasMatch(text)) {
      candidate = 'https://$text';
    } else {
      return false;
    }
    final shown = Uri.tryParse(candidate);
    // An address we can't read is never trusted.
    if (shown == null || shown.host.isEmpty) return true;
    // Neither is one hiding a host behind `user@`, unless the user part is
    // a plain name, as in an email address.
    if (shown.userInfo.isNotEmpty &&
        (hasScheme || shown.userInfo.contains('.'))) {
      return true;
    }
    return _normalizeHost(shown.host) != _normalizeHost(target.host);
  }

  static final RegExp _schemePrefix = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://');

  // U+3002 ideographic, U+FF0E fullwidth and U+FF61 halfwidth ideographic
  // full stops.
  static final RegExp _unicodeDots = RegExp('[。．｡]');

  // `name.tld` (a punycode TLD such as `xn--p1ai` too) or an IPv4 address,
  // optionally after `user@` and followed by a port, path, query or
  // fragment.
  static final RegExp _bareDomain = RegExp(
    r'^(?:[^\s/?#]+@)?'
    r'(?:(?:[^\s./:?#@]+\.)+(?:[^\s./:?#@\d]{2,}|xn--[a-zA-Z0-9-]+)\.?'
    r'|(?:\d{1,3}\.){3}\d{1,3})'
    r'(?:[:/?#]\S*)?$',
  );

  static String _normalizeHost(String host) {
    var value = host.toLowerCase();
    if (value.endsWith('.')) value = value.substring(0, value.length - 1);
    if (value.startsWith('www.')) value = value.substring(4);
    return value;
  }

  @override
  bool operator ==(Object other) =>
      other is ChatLinkPolicy &&
      other.revealDeceptiveTargets == revealDeceptiveTargets &&
      setEquals(other.allowedSchemes, allowedSchemes);

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(allowedSchemes),
        revealDeceptiveTargets,
      );
}
