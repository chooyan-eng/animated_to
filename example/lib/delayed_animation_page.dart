import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

/// Demonstrates the `delay` argument of [AnimatedTo].
///
/// Five circles are lined up horizontally. Pressing "Move" sends them all to
/// the opposite vertical edge, but each circle departs 120ms after the one on
/// its left — so the row travels like a wave.
///
/// Things to try:
/// - Press "Move" again before the wave has finished: every press reserves
///   its own start (deadlines are never reset), so each circle still visits
///   both edges in order, trailing behind the leader.
/// - Switch to "spring" for a bouncy wave with velocity-preserving redirects.
/// - Turn off "animate" to compare with instant (non-animated) updates.
class DelayedAnimationPage extends StatefulWidget {
  const DelayedAnimationPage({super.key});

  @override
  State<DelayedAnimationPage> createState() => _DelayedAnimationPageState();
}

class _DelayedAnimationPageState extends State<DelayedAnimationPage> {
  static const _circleCount = 5;
  static const _delayStep = Duration(milliseconds: 120);

  bool _isUp = false;
  bool _useSpring = false;
  bool _animationEnabled = true;

  final _keys = List.generate(_circleCount, (index) => GlobalKey());

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
          onPressed: () => setState(() => _isUp = !_isUp),
          icon: const Icon(Icons.swap_vert),
          label: const Text('Move'),
        ),
        body: SafeArea(
          top: false,
          child: Padding(
            // The bottom inset keeps the movement area above the FAB:
            // 16 (FAB margin) + 48 (extended FAB height) + 8 (gap) + 24 (base).
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'Press "Move" and the circles travel to the other edge\n'
                    'like a wave: each one departs 120ms after its neighbor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < _circleCount; i++)
                      Expanded(
                        child: Align(
                          alignment: _isUp
                              ? Alignment.topCenter
                              : Alignment.bottomCenter,
                          child: _buildCircle(i),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(int index) {
    final delay = _delayStep * index;
    final child = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.primaries[index * 3 % Colors.primaries.length],
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${delay.inMilliseconds}',
        style: const TextStyle(color: Colors.white, fontSize: 11),
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
