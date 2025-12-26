import 'dart:async';
import 'dart:math';

import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

class HitTestPage extends StatefulWidget {
  const HitTestPage({super.key});

  @override
  State<HitTestPage> createState() => _HitTestPageState();
}

class _HitTestPageState extends State<HitTestPage>
    with TickerProviderStateMixin {
  int _tapCount = 0;
  Color _currentColor = Colors.blue;
  Alignment _currentAlignment = Alignment.center;
  Timer? _animationTimer;

  final _random = Random();
  final _objectKey = GlobalKey();

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  final List<Alignment> _positions = [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAnimation();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _startAutoAnimation() {
    _animationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // Move to a random position
          _currentAlignment = _positions[_random.nextInt(_positions.length)];
        });
      }
    });
  }

  void _handleTap() {
    setState(() {
      _tapCount++;
      // Change color on tap
      _currentColor = _colors[_random.nextInt(_colors.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedToBoundary(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          title: const Text(
            'Hit Test Demo',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.grey[900],
        body: Stack(
          children: [
            // Info panel
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tap Counter: $_tapCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try tapping the moving object!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'AnimatedToBoundary enables hit testing during animation.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Animated tappable object
            Align(
              alignment: _currentAlignment,
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: AnimatedTo.curve(
                  duration: const Duration(seconds: 3),
                  globalKey: _objectKey,
                  child: GestureDetector(
                    onTap: _handleTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _currentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _currentColor.withValues(alpha: 150),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$_tapCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
