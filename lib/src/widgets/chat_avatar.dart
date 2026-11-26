import '../material.dart';
import '../models/chat_user.dart';
import '../theme/chat_theme.dart';
import '../utils/display_name.dart';

/// Circular avatar of a [ChatUser].
///
/// Shows [ChatUser.avatarUrl] when set, and the user's initials on a color
/// derived from [ChatUser.id] otherwise or when the image fails to load. The
/// image is decoded at the displayed size to save memory.
class ChatAvatar extends StatelessWidget {
  /// Creates an avatar.
  const ChatAvatar({super.key, required this.user, this.size, this.onTap});

  /// The user to show.
  final ChatUser user;

  /// Diameter. Defaults to [ChatThemeData.avatarSize].
  final double? size;

  /// Called when the avatar is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final diameter = size ?? ChatThemeData.of(context).avatarSize;
    final scheme = Theme.of(context).colorScheme;
    final palette = [
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
    ];
    final (background, foreground) = palette[_stableHash(user.id) % 3];

    final initials = Center(
      child: Text(
        user.initials,
        maxLines: 1,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          color: foreground,
          fontSize: diameter * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final url = user.avatarUrl;
    final pixels = (diameter * MediaQuery.devicePixelRatioOf(context)).round();
    Widget avatar = DecoratedBox(
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: url == null || url.isEmpty
          ? initials
          : ClipOval(
              child: Image.network(
                url,
                width: diameter,
                height: diameter,
                cacheWidth: pixels,
                cacheHeight: pixels,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => initials,
              ),
            ),
    );
    avatar = SizedBox.square(dimension: diameter, child: avatar);

    final label = user.displayName ?? user.initials;
    if (onTap == null) {
      return Semantics(image: true, label: label, child: avatar);
    }
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatar,
      ),
    );
  }

  // String.hashCode is not stable across runs; colors should be.
  static int _stableHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }
}
