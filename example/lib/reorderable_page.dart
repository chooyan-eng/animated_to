import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: TapCancelDemo()));

class TapCancelDemo extends StatefulWidget {
  const TapCancelDemo({super.key});

  @override
  State<TapCancelDemo> createState() => _TapCancelDemoState();
}

class _TapCancelDemoState extends State<TapCancelDemo>
    with TickerProviderStateMixin {
  final _cubes = {
    '1': GlobalKey(),
    '2': GlobalKey(),
    '3': GlobalKey(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: 10,
          children: _cubes.entries
              .map(
                (cube) => AnimatedTo(
                  globalKey: cube.value,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.linear,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.primaries[
                          int.parse(cube.key) % Colors.primaries.length],
                      borderRadius: BorderRadius.circular(100),
                    ),
                    width: 60,
                    height: 60,
                  ),
                ),
              )
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _cubes[(_cubes.length + 1).toString()] = GlobalKey());
        },
        child: const Icon(Icons.shuffle),
      ),
    );
  }
}
