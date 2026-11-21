import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rect = Rect.fromLTWH(0, 0, 100, 40);
  const radius = BorderRadius.all(Radius.circular(12));

  test('reserves tail space on the end side', () {
    const border = ChatBubbleBorder(
      borderRadius: radius,
      tail: ChatBubbleTail.bottom,
      tailWidth: 8,
    );
    final path = border.getOuterPath(rect, textDirection: TextDirection.ltr);
    expect(path.contains(const Offset(95, 39)), isTrue, reason: 'tail');
    expect(path.contains(const Offset(97, 5)), isFalse, reason: 'reserved');
    expect(border.contentInsets, const EdgeInsetsDirectional.only(end: 8));
  });

  test('mirrors in right-to-left layouts', () {
    const border = ChatBubbleBorder(
      borderRadius: radius,
      tail: ChatBubbleTail.bottom,
      tailWidth: 8,
    );
    final path = border.getOuterPath(rect, textDirection: TextDirection.rtl);
    expect(path.contains(const Offset(5, 39)), isTrue);
    expect(path.contains(const Offset(95, 39)), isFalse);
  });

  test('top nip points up at the corner', () {
    const border = ChatBubbleBorder(
      borderRadius: radius,
      tail: ChatBubbleTail.top,
      tailWidth: 8,
    );
    final path = border.getOuterPath(rect, textDirection: TextDirection.ltr);
    expect(path.contains(const Offset(97, 1)), isTrue);
    expect(path.contains(const Offset(97, 30)), isFalse);
  });

  test('hidden tails keep the reserved space', () {
    const border = ChatBubbleBorder(
      borderRadius: radius,
      tail: ChatBubbleTail.bottom,
      showTail: false,
      tailWidth: 8,
    );
    final bounds =
        border.getOuterPath(rect, textDirection: TextDirection.ltr).getBounds();
    expect(bounds.right, closeTo(92, 0.01));
  });

  test('lerps and compares by value', () {
    const a = ChatBubbleBorder(tailWidth: 4);
    const b = ChatBubbleBorder(tailWidth: 8);
    expect(a.lerpTo(b, 0.5), const ChatBubbleBorder(tailWidth: 6));
    expect(a, const ChatBubbleBorder(tailWidth: 4));
  });
}
