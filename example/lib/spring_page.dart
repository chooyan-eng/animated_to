import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

class SpringPage extends StatefulWidget {
  const SpringPage({super.key});

  @override
  State<SpringPage> createState() => _SpringPageState();
}

// Define spring types for easy switching
enum SpringType { defaultIOS, bouncy, snappy, gentle, custom }

class _SpringPageState extends State<SpringPage> with TickerProviderStateMixin {
  final _padding = 32.0;
  final _boxSize = 80.0;

  final _boxKey = GlobalKey();
  var _cornerIndex = 0;
  var _springType = SpringType.defaultIOS;

  // Get the current spring description
  SpringDescription get _currentSpring => switch (_springType) {
        SpringType.defaultIOS => CupertinoMotion.smooth().description,
        SpringType.bouncy => CupertinoMotion.bouncy().description,
        SpringType.snappy => CupertinoMotion.snappy().description,
        SpringType.gentle => SpringDescription(
            mass: 1,
            stiffness: 100,
            damping: 20,
          ),
        SpringType.custom => SpringDescription(
            mass: 1,
            stiffness: 400,
            damping: 10,
          ),
      };

  void _moveToCorner(int index) {
    setState(() => _cornerIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final corners = [
      Offset(_padding, _padding), // Top-left
      Offset(size.width - _boxSize - _padding, _padding), // Top-right
      Offset(
        // Bottom-right
        size.width - _boxSize - _padding,
        (size.height * 0.7) - _boxSize - _padding - kToolbarHeight,
      ),
      Offset(
        // Bottom-left
        _padding,
        (size.height * 0.7) - _boxSize - _padding - kToolbarHeight,
      ),
    ];

    return AnimatedToBoundary(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spring Demo'),
          actions: [
            PopupMenuButton<SpringType>(
              initialValue: _springType,
              onSelected: (type) => setState(() => _springType = type),
              itemBuilder: (context) => SpringType.values
                  .map((type) => PopupMenuItem(
                        value: type,
                        child: Text(type.name),
                      ))
                  .toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.tune),
                    const SizedBox(width: 8),
                    Text(_springType.name),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Corner indicators (now matching box style)
            ...corners.map((corner) {
              final index = corners.indexOf(corner);
              final color = Colors.blue.withAlpha(
                index == _cornerIndex % 4 ? 64 : 32,
              );
              return Positioned(
                left: corner.dx,
                top: corner.dy,
                child: GestureDetector(
                  onTap: () => _moveToCorner(index),
                  child: Container(
                    width: _boxSize,
                    height: _boxSize,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.blue.withAlpha(128),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Moving box
            Positioned(
              left: corners[_cornerIndex % 4].dx,
              top: corners[_cornerIndex % 4].dy,
              child: AnimatedTo.spring(
                globalKey: _boxKey,
                description: _currentSpring,
                child: Container(
                  width: _boxSize,
                  height: _boxSize,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
