import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

/// Demonstrates the `delay` argument of [AnimatedTo].
///
/// Each box waits `index * 150ms` after its position changes before starting
/// to animate, so a single rebuild produces a staggered (cascading) motion.
///
/// Things to try:
/// - Press "Move" once and watch the cascade: boxes further down start later.
/// - Press "Move" again while boxes are still waiting: each press reserves
///   its own start (deadlines are never reset), so the first reservation
///   departs on time and the next one redirects afterwards — including
///   coming back when the destination is the original position.
/// - Turn off "animate" to compare with instant (non-animated) updates.
class DelayedAnimationPage extends StatefulWidget {
  const DelayedAnimationPage({super.key});

  @override
  State<DelayedAnimationPage> createState() => _DelayedAnimationPageState();
}

class _DelayedAnimationPageState extends State<DelayedAnimationPage> {
  static const _boxCount = 6;

  bool _isLeft = true;
  bool _useSpring = false;
  bool _animationEnabled = true;

  final _keys = List.generate(_boxCount, (index) => GlobalKey());

  /// Shared with [SingleChildScrollView] and every [AnimatedTo] so that
  /// scrolling is not misdetected as a position change (see
  /// [AnimatedTo.verticalController]). Try scrolling while boxes are still
  /// waiting: the held positions follow the scroll.
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
          onPressed: () => setState(() => _isLeft = !_isLeft),
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Move'),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  _isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Center(
                  child: Text(
                    'Press "Move" to move the boxes.\n'
                    'Each box starts 150ms after the one above it.\n'
                    'Turn off "animate" to compare with instant updates.\n'
                    'Scroll while boxes are waiting: held positions follow.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 120),
                for (var i = 0; i < _boxCount; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: _buildBox(i),
                  ),
                const SizedBox(height: 400),
              ],
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
            enabled: _animationEnabled,
            verticalController: _scrollController,
            child: child,
          )
        : AnimatedTo.curve(
            globalKey: _keys[index],
            delay: delay,
            enabled: _animationEnabled,
            verticalController: _scrollController,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: child,
          );
  }
}
