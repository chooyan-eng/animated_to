import 'package:animated_to/animated_to.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end smoke test for the `delay` feature.
///
/// This file only uses the public API (`AnimatedTo.curve(delay: ...)`) and
/// observes the actually painted position via the internal RepaintBoundary's
/// OffsetLayer, so it is agnostic to how the delay is implemented internally.
///
/// Note: the initial position is deliberately non-zero. A widget whose first
/// paint offset is exactly Offset.zero hits a pre-existing issue where the
/// curve version never leaves its "preparing" state (see Journey.isPreparing)
/// and the first move is neither animated nor delayed.

const _childKey = ValueKey('animated-child');

/// Painted position of AnimatedTo's internal RepaintBoundary
/// (= where the child is actually drawn), relative to its parent layer.
Offset paintedOffset(WidgetTester tester) {
  RenderObject ro = tester.renderObject(find.byKey(_childKey));
  while (!ro.isRepaintBoundary) {
    ro = ro.parent!;
  }
  return (ro.debugLayer! as OffsetLayer).offset;
}

Widget _app({required double left, required Duration delay, GlobalKey? key}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Stack(
      children: [
        Positioned(
          left: left,
          top: 0,
          child: AnimatedTo.curve(
            globalKey: key!,
            delay: delay,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear,
            child: const SizedBox(key: _childKey, width: 10, height: 10),
          ),
        ),
      ],
    ),
  );
}

void main() {
  testWidgets('scenario 1: holds old position during delay, then animates',
      (tester) async {
    final key = GlobalKey();
    const delay = Duration(milliseconds: 300);
    await tester.pumpWidget(_app(left: 40, delay: delay, key: key));
    final origin = paintedOffset(tester);

    // move to x=240
    await tester.pumpWidget(_app(left: 240, delay: delay, key: key));
    expect(paintedOffset(tester), origin, reason: 'held right after move');

    await tester.pump(const Duration(milliseconds: 150)); // t=150 < 300
    expect(paintedOffset(tester), origin, reason: 'still held mid-delay');

    await tester.pump(const Duration(milliseconds: 150)); // t=300: expiry
    await tester.pump(const Duration(milliseconds: 100)); // mid-animation
    final mid = paintedOffset(tester);
    expect(mid.dx, greaterThan(origin.dx), reason: 'animation has started');
    expect(mid.dx, lessThan(origin.dx + 200), reason: 'animation not finished');

    await tester.pump(const Duration(milliseconds: 300)); // finish
    expect(paintedOffset(tester).dx, origin.dx + 200,
        reason: 'settled at new position');
  });

  testWidgets('scenario 2: delay zero behaves like original (no hold)',
      (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(_app(left: 40, delay: Duration.zero, key: key));
    final origin = paintedOffset(tester);

    await tester.pumpWidget(_app(left: 240, delay: Duration.zero, key: key));
    await tester.pump(const Duration(milliseconds: 100)); // mid-animation
    final mid = paintedOffset(tester);
    expect(mid.dx, greaterThan(origin.dx),
        reason: 'animation starts immediately without delay');
    expect(mid.dx, lessThan(origin.dx + 200),
        reason: 'actually animating, not an instant jump');

    await tester.pump(const Duration(milliseconds: 200)); // finish (t=300)
    expect(paintedOffset(tester).dx, origin.dx + 200,
        reason: 'already settled where a delayed run would still be waiting');
  });

  testWidgets(
      'scenario 3: each move during wait gets its own reservation; the first '
      'fires on time toward ITS destination, the second redirects later',
      (tester) async {
    final key = GlobalKey();
    const delay = Duration(milliseconds: 300);
    await tester.pumpWidget(_app(left: 40, delay: delay, key: key));
    final origin = paintedOffset(tester);

    // move 1: A(40) -> B(240). Reservation 1 fires at t=300.
    await tester.pumpWidget(_app(left: 240, delay: delay, key: key)); // t=0
    await tester.pump(const Duration(milliseconds: 150)); // t=150
    // move 2 during the wait: B(240) -> C(340). Reservation 2 fires at t=450.
    await tester.pumpWidget(_app(left: 340, delay: delay, key: key));
    expect(paintedOffset(tester), origin, reason: 'still held after 2nd move');

    await tester.pump(const Duration(milliseconds: 150)); // t=300: fire 1
    await tester.pump(const Duration(milliseconds: 100)); // t=400: mid A->B
    final midAB = paintedOffset(tester);
    expect(midAB.dx, greaterThan(origin.dx),
        reason: 'reservation 1 fired at its own deadline');
    expect(midAB.dx, lessThan(origin.dx + 200),
        reason: 'heading to B (its own destination), not straight to C');

    await tester.pump(const Duration(milliseconds: 50)); // t=450: fire 2
    await tester.pump(const Duration(milliseconds: 600)); // settle
    expect(paintedOffset(tester).dx, origin.dx + 300,
        reason: 'reservation 2 redirected to C');
  });

  testWidgets(
      'scenario 4: move during animation defers redirect; previous animation '
      'completes during the wait', (tester) async {
    final key = GlobalKey();
    const delay = Duration(milliseconds: 300);
    await tester.pumpWidget(_app(left: 40, delay: delay, key: key));
    final origin = paintedOffset(tester);

    // 1st move: A(40) -> B(240)
    await tester.pumpWidget(_app(left: 240, delay: delay, key: key)); // t=0
    await tester.pump(const Duration(milliseconds: 300)); // t=300: start A->B
    await tester.pump(const Duration(milliseconds: 100)); // t=400: mid A->B
    final midAB = paintedOffset(tester);
    expect(midAB.dx, greaterThan(origin.dx));
    expect(midAB.dx, lessThan(origin.dx + 200));

    // 2nd move while animating: B(240) -> C(340). New deadline: t=700.
    await tester.pumpWidget(_app(left: 340, delay: delay, key: key)); // t=400
    // A->B animation keeps going toward B (t=300..500)
    await tester.pump(const Duration(milliseconds: 100)); // t=500: A->B done
    expect(paintedOffset(tester).dx, origin.dx + 200,
        reason: 'previous animation completed at its ORIGINAL destination B');

    await tester.pump(const Duration(milliseconds: 100)); // t=600: waiting
    expect(paintedOffset(tester).dx, origin.dx + 200,
        reason: 'resting at B until the new deadline');

    await tester.pump(const Duration(milliseconds: 100)); // t=700: start B->C
    await tester.pump(const Duration(milliseconds: 100)); // t=800: mid B->C
    final midBC = paintedOffset(tester);
    expect(midBC.dx, greaterThan(origin.dx + 200));
    expect(midBC.dx, lessThan(origin.dx + 300));

    await tester.pump(const Duration(milliseconds: 300)); // finish
    expect(paintedOffset(tester).dx, origin.dx + 300,
        reason: 'settled at C');
  });

  // Dynamic `delay` update while waiting: deadlines are stamped when each
  // reservation is made, so changing `delay` afterwards does not disturb
  // reservations already waiting — it only applies to subsequent changes.
  testWidgets(
      'scenario 5: changing delay mid-wait keeps existing reservations on '
      'their original deadline', (tester) async {
    final key = GlobalKey();
    const delay = Duration(milliseconds: 300);
    await tester.pumpWidget(_app(left: 40, delay: delay, key: key));
    final origin = paintedOffset(tester);

    await tester.pumpWidget(_app(left: 240, delay: delay, key: key)); // t=0
    await tester.pump(const Duration(milliseconds: 100)); // t=100: held
    expect(paintedOffset(tester), origin);

    // rebuild with delay: zero while waiting (position unchanged)
    await tester.pumpWidget(
        _app(left: 240, delay: Duration.zero, key: key)); // t=100
    await tester.pump(const Duration(milliseconds: 100)); // t=200
    expect(paintedOffset(tester), origin,
        reason: 'the existing reservation keeps its original deadline');

    await tester.pump(const Duration(milliseconds: 100)); // t=300: fires
    await tester.pump(const Duration(milliseconds: 100)); // t=400: animating
    expect(paintedOffset(tester).dx, greaterThan(origin.dx));

    await tester.pump(const Duration(milliseconds: 400));
    expect(paintedOffset(tester).dx, origin.dx + 200);
  });

  testWidgets(
      'scenario 6: A -> B then back to A during wait: departs toward B on '
      'the first deadline, then returns to A on the second', (tester) async {
    final key = GlobalKey();
    const delay = Duration(milliseconds: 300);
    await tester.pumpWidget(_app(left: 40, delay: delay, key: key));
    final origin = paintedOffset(tester);

    // move 1: A(40) -> B(240). Reservation 1 fires at t=300 toward B.
    await tester.pumpWidget(_app(left: 240, delay: delay, key: key)); // t=0
    await tester.pump(const Duration(milliseconds: 150)); // t=150
    // move 2: back to A. Reservation 2 fires at t=450 toward A.
    await tester.pumpWidget(_app(left: 40, delay: delay, key: key));
    expect(paintedOffset(tester), origin, reason: 'held at A while waiting');

    await tester.pump(const Duration(milliseconds: 150)); // t=300: fire 1
    await tester.pump(const Duration(milliseconds: 100)); // t=400: mid A->B
    final midAB = paintedOffset(tester);
    expect(midAB.dx, greaterThan(origin.dx),
        reason: 'departed toward B even though the layout is back at A');

    await tester.pump(const Duration(milliseconds: 50)); // t=450: fire 2
    await tester.pump(const Duration(milliseconds: 100)); // t=550: returning
    await tester.pump(const Duration(milliseconds: 600)); // settle
    expect(paintedOffset(tester).dx, origin.dx,
        reason: 'came back and settled at A');
  });

  testWidgets('scenario 7: spring version also holds during delay and settles',
      (tester) async {
    final key = GlobalKey();
    const delay = Duration(milliseconds: 300);
    Widget app(double left) => Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Positioned(
                left: left,
                top: 0,
                child: AnimatedTo.spring(
                  globalKey: key,
                  delay: delay,
                  child: const SizedBox(key: _childKey, width: 10, height: 10),
                ),
              ),
            ],
          ),
        );

    await tester.pumpWidget(app(40));
    final origin = paintedOffset(tester);

    await tester.pumpWidget(app(240)); // t=0
    await tester.pump(const Duration(milliseconds: 150)); // t=150
    expect(paintedOffset(tester), origin, reason: 'held mid-delay');

    await tester.pump(const Duration(milliseconds: 150)); // t=300: fires
    await tester.pump(const Duration(milliseconds: 150)); // mid-spring
    expect(paintedOffset(tester).dx, greaterThan(origin.dx),
        reason: 'spring animation started after the delay');

    // let the spring settle (snapToEnd guarantees exact arrival)
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(paintedOffset(tester).dx, closeTo(origin.dx + 200, 0.1),
        reason: 'settled at the destination');
  });
}
