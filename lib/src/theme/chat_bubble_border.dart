import 'dart:math' as math;

import '../material.dart';

/// Where a chat bubble draws its tail.
enum ChatBubbleTail {
  /// No tail. Bubbles are rounded rectangles.
  none,

  /// A curved tail at the bottom corner on the author's side, on the last
  /// bubble of a group (iMessage style).
  bottom,

  /// A pointed nip at the top corner on the author's side, on the first
  /// bubble of a group (WhatsApp style).
  top,
}

/// The shape of a chat bubble: a rounded rectangle with an optional tail.
///
/// When [tail] is not [ChatBubbleTail.none], the shape always reserves
/// [tailWidth] on the tail side, even if [showTail] is `false`. This keeps
/// the bubbles of a group aligned. Add [contentInsets] to your padding so
/// content does not overlap the reserved space.
///
/// Use it with any widget that accepts a [ShapeBorder]:
///
/// ```dart
/// Material(
///   color: Colors.teal,
///   shape: const ChatBubbleBorder(
///     borderRadius: BorderRadius.all(Radius.circular(18)),
///     tail: ChatBubbleTail.bottom,
///   ),
///   child: const Padding(
///     padding: EdgeInsets.fromLTRB(12, 8, 19, 8),
///     child: Text('Hello'),
///   ),
/// )
/// ```
@immutable
class ChatBubbleBorder extends OutlinedBorder {
  /// Creates a bubble shape.
  const ChatBubbleBorder({
    super.side,
    this.borderRadius = BorderRadius.zero,
    this.tail = ChatBubbleTail.none,
    this.showTail = true,
    this.tailAtEnd = true,
    this.tailWidth = 7,
    this.tailHeight = 14,
  });

  /// Radii of the body corners. The corner replaced by the tail ignores its
  /// radius.
  final BorderRadiusGeometry borderRadius;

  /// Tail style.
  final ChatBubbleTail tail;

  /// Whether to draw the tail. The space stays reserved when `false`.
  final bool showTail;

  /// Whether the tail is on the end side (right in left-to-right layouts).
  final bool tailAtEnd;

  /// Horizontal size of the tail.
  final double tailWidth;

  /// Vertical size of the tail.
  final double tailHeight;

  /// Space reserved for the tail. Add it to the content padding.
  EdgeInsetsDirectional get contentInsets {
    if (tail == ChatBubbleTail.none) return EdgeInsetsDirectional.zero;
    return tailAtEnd
        ? EdgeInsetsDirectional.only(end: tailWidth)
        : EdgeInsetsDirectional.only(start: tailWidth);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  ChatBubbleBorder copyWith({
    BorderSide? side,
    BorderRadiusGeometry? borderRadius,
    ChatBubbleTail? tail,
    bool? showTail,
    bool? tailAtEnd,
    double? tailWidth,
    double? tailHeight,
  }) {
    return ChatBubbleBorder(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
      tail: tail ?? this.tail,
      showTail: showTail ?? this.showTail,
      tailAtEnd: tailAtEnd ?? this.tailAtEnd,
      tailWidth: tailWidth ?? this.tailWidth,
      tailHeight: tailHeight ?? this.tailHeight,
    );
  }

  @override
  ChatBubbleBorder scale(double t) => copyWith(
        side: side.scale(t),
        borderRadius: borderRadius * t,
        tailWidth: tailWidth * t,
        tailHeight: tailHeight * t,
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is ChatBubbleBorder) return _lerp(a, this, t);
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is ChatBubbleBorder) return _lerp(this, b, t);
    return super.lerpTo(b, t);
  }

  static ChatBubbleBorder _lerp(
      ChatBubbleBorder a, ChatBubbleBorder b, double t) {
    final discrete = t < 0.5 ? a : b;
    return ChatBubbleBorder(
      side: BorderSide.lerp(a.side, b.side, t),
      borderRadius:
          BorderRadiusGeometry.lerp(a.borderRadius, b.borderRadius, t)!,
      tail: discrete.tail,
      showTail: discrete.showTail,
      tailAtEnd: discrete.tailAtEnd,
      tailWidth: a.tailWidth + (b.tailWidth - a.tailWidth) * t,
      tailHeight: a.tailHeight + (b.tailHeight - a.tailHeight) * t,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(side.strokeInset),
          textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final tailOnRight = tailAtEnd == (textDirection != TextDirection.rtl);
    var radius = borderRadius.resolve(textDirection);
    if (!tailOnRight) {
      // Build the shape with the tail on the right, then mirror it.
      radius = BorderRadius.only(
        topLeft: radius.topRight,
        topRight: radius.topLeft,
        bottomLeft: radius.bottomRight,
        bottomRight: radius.bottomLeft,
      );
    }
    final path = _rightTailPath(rect, radius);
    if (tailOnRight) return path;
    final mirror = Matrix4.diagonal3Values(-1, 1, 1)
      ..setTranslationRaw(rect.left + rect.right, 0, 0);
    return path.transform(mirror.storage);
  }

  Path _rightTailPath(Rect r, BorderRadius radius) {
    final reserve = tail == ChatBubbleTail.none ? 0.0 : tailWidth;
    final body = Rect.fromLTRB(r.left, r.top, r.right - reserve, r.bottom);
    if (!showTail || tail == ChatBubbleTail.none || body.width <= 0) {
      return Path()..addRRect(radius.toRRect(body).scaleRadii());
    }

    final rr = radius.toRRect(body).scaleRadii();
    final tl = Radius.elliptical(rr.tlRadiusX, rr.tlRadiusY);
    final tr = Radius.elliptical(rr.trRadiusX, rr.trRadiusY);
    final bl = Radius.elliptical(rr.blRadiusX, rr.blRadiusY);
    final br = Radius.elliptical(rr.brRadiusX, rr.brRadiusY);
    final height = math.min(tailHeight, body.height * 0.75);
    final path = Path()..moveTo(body.left + tl.x, body.top);

    if (tail == ChatBubbleTail.top) {
      // Top edge runs out to the tip, then a straight edge back to the body.
      path
        ..lineTo(r.right - 2, body.top)
        ..quadraticBezierTo(r.right + 0.5, body.top, r.right - 1, body.top + 2)
        ..lineTo(body.right, body.top + height)
        ..lineTo(body.right, body.bottom - br.y)
        ..arcToPoint(Offset(body.right - br.x, body.bottom), radius: br);
    } else {
      // The right edge flares out into a curved tail at the bottom.
      path
        ..lineTo(body.right - tr.x, body.top)
        ..arcToPoint(Offset(body.right, body.top + tr.y), radius: tr)
        ..lineTo(body.right, body.bottom - height)
        ..quadraticBezierTo(
          body.right,
          body.bottom - height * 0.12,
          r.right,
          body.bottom,
        )
        ..quadraticBezierTo(
          body.right - reserve * 0.2,
          body.bottom,
          body.right - reserve * 1.4,
          body.bottom,
        );
    }

    return path
      ..lineTo(body.left + bl.x, body.bottom)
      ..arcToPoint(Offset(body.left, body.bottom - bl.y), radius: bl)
      ..lineTo(body.left, body.top + tl.y)
      ..arcToPoint(Offset(body.left + tl.x, body.top), radius: tl)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    final path = getOuterPath(
      rect.deflate(side.width / 2),
      textDirection: textDirection,
    );
    canvas.drawPath(path, side.toPaint());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatBubbleBorder &&
          other.side == side &&
          other.borderRadius == borderRadius &&
          other.tail == tail &&
          other.showTail == showTail &&
          other.tailAtEnd == tailAtEnd &&
          other.tailWidth == tailWidth &&
          other.tailHeight == tailHeight;

  @override
  int get hashCode => Object.hash(
        side,
        borderRadius,
        tail,
        showTail,
        tailAtEnd,
        tailWidth,
        tailHeight,
      );

  @override
  String toString() =>
      'ChatBubbleBorder($tail, showTail: $showTail, tailAtEnd: $tailAtEnd)';
}
