import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

/// Demonstrates the `delay` argument of [AnimatedTo].
///
/// Three circles travel around the four corners of the screen, alternating
/// between a horizontal row and a vertical column:
///
///   bottom-left (row) -> top-left (column) -> top-right (row)
///     -> bottom-right (column) -> back to bottom-left
///
/// The first circle moves immediately and the others follow one by one
/// (index * 200ms), trailing behind like a queue.
///
/// Things to try:
/// - Press "Move" repeatedly before the trailing circles have departed:
///   every press reserves its own start (deadlines are never reset), so each
///   circle still visits the corners in order, just later than the leader.
/// - Turn off "animate" to compare with instant (non-animated) updates.
class DelayedAnimationPage extends StatefulWidget {
  const DelayedAnimationPage({super.key});

  @override
  State<DelayedAnimationPage> createState() => _DelayedAnimationPageState();
}

class _DelayedAnimationPageState extends State<DelayedAnimationPage> {
  static const _circleCount = 3;

  /// 0: bottom-left (row), 1: top-left (column),
  /// 2: top-right (row), 3: bottom-right (column)
  var _corner = 0;
  bool _useSpring = false;
  bool _animationEnabled = true;

  final _keys = List.generate(_circleCount, (index) => GlobalKey());

  static const _alignments = [
    Alignment.bottomLeft,
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomRight,
  ];

  @override
  Widget build(BuildContext context) {
    final circles = [
      for (var i = 0; i < _circleCount; i++) _buildCircle(i),
    ];

    return AnimatedToBoundary(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          title: const Text(
            'Delayed Animation',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            const Text('animate', style: TextStyle(color: Colors.white)),
            Switch(
              value: _animationEnabled,
              onChanged: (value) => setState(() => _animationEnabled = value),
            ),
            const SizedBox(width: 8),
            const Text('spring', style: TextStyle(color: Colors.white)),
            Switch(
              value: _useSpring,
              onChanged: (value) => setState(() => _useSpring = value),
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: Colors.grey[900],
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => setState(() => _corner = (_corner + 1) % 4),
          icon: const Icon(Icons.rotate_right),
          label: const Text('Move'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Center(
                child: Text(
                  'Press "Move" to send the circles to the next corner.\n'
                  'The leader departs immediately; the others follow\n'
                  '200ms and 400ms behind.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
              Align(
                alignment: _alignments[_corner],
                child: _corner.isEven
                    ? Row(mainAxisSize: MainAxisSize.min, children: circles)
                    : Column(mainAxisSize: MainAxisSize.min, children: circles),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(int index) {
    final delay = Duration(milliseconds: 200 * index);
    final child = Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.primaries[index * 4 % Colors.primaries.length],
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${delay.inMilliseconds}ms',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );

    return _useSpring
        ? AnimatedTo.spring(
            globalKey: _keys[index],
            delay: delay,
            enabled: _animationEnabled,
            child: child,
          )
        : AnimatedTo.curve(
            globalKey: _keys[index],
            delay: delay,
            enabled: _animationEnabled,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: child,
          );
  }
}
