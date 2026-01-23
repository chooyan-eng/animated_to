import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _DragHarness extends StatefulWidget {
  const _DragHarness({
    required this.cardKey,
    required this.onDragStarted,
    super.key,
  });

  final GlobalKey cardKey;
  final VoidCallback onDragStarted;

  @override
  State<_DragHarness> createState() => _DragHarnessState();
}

class _DragHarnessState extends State<_DragHarness> {
  static const _contentKey = Key('drag-content');
  bool _moved = false;

  void moveRight() {
    setState(() {
      _moved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const content = SizedBox(
      key: _contentKey,
      width: 120,
      height: 160,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
      ),
    );

    final animated = AnimatedTo.curve(
      globalKey: widget.cardKey,
      duration: const Duration(seconds: 3),
      child: content,
    );

    return SizedBox(
      width: 320,
      height: 240,
      child: Align(
        alignment: _moved ? Alignment.centerRight : Alignment.centerLeft,
        child: Draggable(
          feedback: content,
          childWhenDragging: const Opacity(opacity: 0, child: content),
          onDragStarted: widget.onDragStarted,
          child: animated,
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'AnimatedToBoundary hit testing preserves ancestor chain while animating',
    (tester) async {
      var dragStarted = 0;
      final harnessKey = GlobalKey<_DragHarnessState>();
      final cardKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedToBoundary(
            child: Center(
              child: _DragHarness(
                key: harnessKey,
                cardKey: cardKey,
                onDragStarted: () => dragStarted++,
              ),
            ),
          ),
        ),
      );

      harnessKey.currentState!.moveRight();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      final boundaryBox =
          tester.renderObject(find.byType(AnimatedToBoundary)) as RenderBox;
      final renderObject =
          cardKey.currentContext!.findRenderObject() as RenderAnimatedTo;
      final renderBox = renderObject as RenderBox;
      final animatedOffset = renderObject.currentAnimatedOffset;
      expect(animatedOffset, isNotNull);
      expect(
        (animatedOffset! - renderObject.globalOffset).distance,
        greaterThan(0.1),
      );

      final animatedCenter = boundaryBox.localToGlobal(
        animatedOffset + renderBox.size.center(Offset.zero),
      );

      final gesture = await tester.startGesture(animatedCenter);
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(dragStarted, 1);
    },
  );
}
