import 'package:flutter/material.dart';

/// A widget to maintain [AnimatedTo]'s child size.
/// This widget is used when the child's size is updated with animation.
///
/// Because [AnimatedTo] starts animation at every time when [child] updates its position,
/// which means if the [child] updates its size with animation, [AnimatedTo] tries to start
/// its own animation at every frame resulting in [child] doesn't animate as expected.
///
/// [SizeMaintainer] is to calculate and preserve the desired size and position which [AnimatedTo] requires.
class SizeMaintainer extends StatelessWidget {
  const SizeMaintainer({
    super.key,
    required this.child,
    required this.sizeWidget,
  });
  final Widget child;
  final Widget sizeWidget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(opacity: 0, child: sizeWidget),
        Positioned(
          left: 0,
          top: 0,
          child: child,
        ),
      ],
    );
  }
}
