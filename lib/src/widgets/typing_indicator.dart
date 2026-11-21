import 'dart:math' as math;

import '../l10n/chat_localizations.dart';
import '../material.dart';
import '../models/chat_user.dart';
import '../theme/chat_theme.dart';

/// Three bouncing dots, used for typing users and empty streaming messages.
///
/// The animation stops when the platform asks to reduce motion.
class TypingDots extends StatefulWidget {
  /// Creates the dots.
  const TypingDots({super.key, this.color, this.dotSize = 7});

  /// Dot color. Defaults to [ChatThemeData.typingIndicatorColor].
  final Color? color;

  /// Diameter of each dot.
  final double dotSize;

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.color ?? ChatThemeData.of(context).typingIndicatorColor;
    final size = widget.dotSize;
    return ExcludeSemantics(
      child: SizedBox(
        height: size * 2.2,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) SizedBox(width: size * 0.6),
                  _dot(i, color, size),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _dot(int index, Color color, double size) {
    // Each dot is a third of a cycle behind the previous one.
    final phase = (_controller.value - index / 6) % 1.0;
    final wave = phase < 0.5 ? math.sin(phase * 2 * math.pi) : 0.0;
    return Transform.translate(
      offset: Offset(0, -wave * size * 0.8),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.45 + 0.55 * wave),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Bubble that tells which [users] are typing.
class TypingIndicator extends StatelessWidget {
  /// Creates a typing indicator.
  const TypingIndicator({super.key, required this.users});

  /// Users currently typing. Shows nothing when empty.
  final List<ChatUser> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    final names = [for (final u in users) u.name ?? l10n.someone];
    final label = l10n.typing(names);
    return Semantics(
      liveRegion: true,
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.incomingBubbleColor,
              borderRadius: BorderRadius.circular(theme.bubbleRadius),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: TypingDots(),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: ExcludeSemantics(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.systemMessageTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
