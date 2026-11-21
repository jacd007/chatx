part of '../chat_view.dart';

/// Lets the user drag [child] toward the end side to trigger an action.
///
/// The child follows the finger with growing resistance, an icon fades in
/// behind it, and a haptic tick marks the point where releasing triggers the
/// action. The child springs back either way.
class _SwipeToAction extends StatefulWidget {
  const _SwipeToAction({
    required this.icon,
    required this.label,
    required this.onTriggered,
    required this.child,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTriggered;
  final Widget child;

  @override
  State<_SwipeToAction> createState() => _SwipeToActionState();
}

class _SwipeToActionState extends State<_SwipeToAction>
    with SingleTickerProviderStateMixin {
  static const double _threshold = 64;
  static const double _maxOffset = 96;
  static final SpringDescription _spring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 500,
    ratio: 0.8,
  );

  late final AnimationController _offset =
      AnimationController.unbounded(vsync: this);
  double _dragDistance = 0;
  bool _armed = false;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  double get _direction =>
      Directionality.of(context) == TextDirection.rtl ? -1 : 1;

  void _onDragStart(DragStartDetails details) {
    _offset.stop();
    _dragDistance = _offset.value;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragDistance =
        math.max(0, _dragDistance + (details.primaryDelta ?? 0) * _direction);
    // Linear until the threshold, then resistance like a rubber band.
    final offset = _dragDistance <= _threshold
        ? _dragDistance
        : _threshold + (_dragDistance - _threshold) * 0.3;
    _offset.value = math.min(offset, _maxOffset);

    final armed = _offset.value >= _threshold;
    if (armed != _armed) {
      _armed = armed;
      if (armed) HapticFeedback.mediumImpact();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_armed) widget.onTriggered();
    _armed = false;
    _dragDistance = 0;
    final velocity = (details.primaryVelocity ?? 0) * _direction;
    _offset.animateWith(
      SpringSimulation(_spring, _offset.value, 0, velocity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = ChatThemeData.of(context).typingIndicatorColor;
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: widget.label): widget.onTriggered,
      },
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: _offset,
          child: widget.child,
          builder: (context, child) {
            final offset = math.max(0.0, _offset.value);
            final progress = (offset / _threshold).clamp(0.0, 1.0);
            return Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.centerStart,
              children: [
                if (offset > 0)
                  PositionedDirectional(
                    start: 4,
                    child: ExcludeSemantics(
                      child: Opacity(
                        opacity: progress,
                        child: Transform.scale(
                          scale: 0.5 + 0.5 * progress,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(
                                alpha: progress >= 1 ? 0.18 : 0.08,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(widget.icon, size: 20, color: color),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(offset * _direction, 0),
                  child: child,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
