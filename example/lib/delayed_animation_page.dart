import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

/// Demonstrates the `delay` argument of [AnimatedTo].
///
/// Each box waits `index * 150ms` after its position changes before starting
/// to animate, so a single rebuild produces a staggered (cascading) motion.
///
/// Things to try:
/// - Tap once and watch the cascade: boxes further down start later.
/// - Tap again quickly while boxes are still waiting: the destination is
///   updated without resetting each box's deadline.
/// - Tap again while boxes are animating: a running animation keeps going to
///   its original destination and is redirected only after the new delay
///   expires.
class DelayedAnimationPage extends StatefulWidget {
  const DelayedAnimationPage({super.key});

  @override
  State<DelayedAnimationPage> createState() => _DelayedAnimationPageState();
}

class _DelayedAnimationPageState extends State<DelayedAnimationPage> {
  static const _boxCount = 6;

  bool _isLeft = true;
  bool _useSpring = false;

  final _keys = List.generate(_boxCount, (index) => GlobalKey());

  @override
  Widget build(BuildContext context) {
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
            const Text('spring', style: TextStyle(color: Colors.white)),
            Switch(
              value: _useSpring,
              onChanged: (value) => setState(() => _useSpring = value),
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: Colors.grey[900],
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _isLeft = !_isLeft),
          child: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: _isLeft
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < _boxCount; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildBox(i),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Tap anywhere to move the boxes.\n'
                      'Each box starts 150ms after the one above it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(int index) {
    final delay = Duration(milliseconds: 150 * index);
    final child = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.primaries[index * 2 % Colors.primaries.length],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '${delay.inMilliseconds}ms',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );

    return _useSpring
        ? AnimatedTo.spring(
            globalKey: _keys[index],
            delay: delay,
            child: child,
          )
        : AnimatedTo.curve(
            globalKey: _keys[index],
            delay: delay,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: child,
          );
  }
}
