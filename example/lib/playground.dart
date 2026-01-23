import 'package:flutter/material.dart';
import 'package:animated_to/animated_to.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatefulWidget {
  const Demo({super.key});
  @override
  State<Demo> createState() => _DemoState();
}

class RoundClip extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // Clip to only show the left 60px (half the width)
    return Rect.fromLTWH(0, 0, 60, size.height);
  }

  @override
  bool shouldReclip(RoundClip oldClipper) => false;
}

class _DemoState extends State<Demo> {
  int idx = 0;

  static const labels = [
    'Boundary -> AnimateTo -> Transform -> child',
    'AnimateTo -> Transform -> child',
    'Boundary -> Transform -> AnimateTo -> child',
    'Transform -> Boundary -> AnimateTo -> child',
    'Boundary -> IgnorePointer(ignoring) -> AnimatedTo -> child',
    'Boundary -> AbsorbPointer(absorbing) -> AnimatedTo -> child',
    'Boundary -> ClipRect -> AnimatedTo -> child',
    'Flutter: TweenAnimationBuilder -> Transform -> child',
  ];

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: () => debugPrint('TAP!'),
      child: Container(
        width: 120,
        height: 120,
        color: Colors.orange,
        alignment: Alignment.center,
        child: const Text('TAP'),
      ),
    );

    Widget makeCase(int i) {
      switch (i) {
        case 0:
          return AnimatedToBoundary(
            hitTestOverflow: true,
            child: AnimatedTo.curve(
              hitTestOverflow: true,
              globalKey: GlobalKey(),
              curve: Curves.linear,
              duration: const Duration(seconds: 8),
              slidingFrom: const Offset(-200, 0),
              child: Transform.rotate(
                transformHitTests: true,
                angle: 0.6,
                child: child,
              ),
            ),
          );
        case 1:
          return AnimatedTo.curve(
            hitTestOverflow: true,
            globalKey: GlobalKey(),
            curve: Curves.linear,
            duration: const Duration(seconds: 8),
            slidingFrom: const Offset(-200, 0),
            child: Transform.rotate(
                transformHitTests: true, angle: 0.6, child: child),
          );
        case 2:
          return AnimatedToBoundary(
            hitTestOverflow: true,
            child: Transform.rotate(
              transformHitTests: true,
              angle: 0.6,
              child: AnimatedTo.curve(
                hitTestOverflow: true,
                globalKey: GlobalKey(),
                curve: Curves.linear,
                duration: const Duration(seconds: 8),
                slidingFrom: const Offset(-200, 0),
                child: child,
              ),
            ),
          );
        case 3:
          return Transform.rotate(
            transformHitTests: true,
            angle: 0.6,
            child: AnimatedToBoundary(
              hitTestOverflow: true,
              child: AnimatedTo.curve(
                hitTestOverflow: true,
                globalKey: GlobalKey(),
                curve: Curves.linear,
                duration: const Duration(seconds: 8),
                slidingFrom: const Offset(-200, 0),
                child: child,
              ),
            ),
          );

        case 4:
          return AnimatedToBoundary(
            hitTestOverflow: true,
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedTo.curve(
                hitTestOverflow: true,
                globalKey: GlobalKey(),
                curve: Curves.linear,
                duration: const Duration(seconds: 8),
                slidingFrom: const Offset(-200, 0),
                child: child,
              ),
            ),
          );
        case 5:
          return AnimatedToBoundary(
            hitTestOverflow: true,
            child: AbsorbPointer(
              absorbing: true,
              child: AnimatedTo.curve(
                hitTestOverflow: true,
                globalKey: GlobalKey(),
                curve: Curves.linear,
                duration: const Duration(seconds: 8),
                slidingFrom: const Offset(-200, 0),
                child: child,
              ),
            ),
          );
        case 6:
          return AnimatedToBoundary(
            hitTestOverflow: true,
            child: Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: AnimatedTo.curve(
                  hitTestOverflow: true,
                  globalKey: GlobalKey(),
                  curve: Curves.linear,
                  duration: const Duration(seconds: 8),
                  slidingFrom: const Offset(-200, 0),
                  child: ClipRect(
                    clipper: RoundClip(),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        case 7:
        default:
          return TweenAnimationBuilder<Offset>(
            tween:
                Tween<Offset>(begin: const Offset(-200, 0), end: Offset.zero),
            duration: const Duration(seconds: 8),
            curve: Curves.linear,
            child: child,
            builder: (context, value, builtChild) {
              return Transform.translate(
                transformHitTests: true,
                offset: value,
                child: Transform.rotate(angle: 0.6, child: builtChild),
              );
            },
          );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(labels[idx]),
        actions: [
          IconButton(
            onPressed: () => setState(() => idx = (idx + 1) % labels.length),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: Center(child: makeCase(idx)),
    );
  }
}
