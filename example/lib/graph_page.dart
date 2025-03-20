import 'dart:async';
import 'dart:math';

import 'package:animated_to/animated_to.dart';
import 'package:example/draggable_page.dart';
import 'package:example/grid_painter.dart';
import 'package:flutter/material.dart';

/// A page that demonstrates the `AnimatedTo` package with a live graph simulation.
/// To see the usage of `AnimatedTo`, jump to line 130.
class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  static const _items = 8;

  final List<_Item> data = List.generate(
    _items,
    (index) => _Item(
      key: GlobalObjectKey(index),
      value: _items - index,
      color: Colors.primaries[index % Colors.primaries.length],
    ),
  );

  Timer? _timer;

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final target = Random().nextInt(_items);
      final item = data.firstWhere((e) => e.key == GlobalObjectKey(target));
      setState(() {
        item.value += Random().nextInt(3) + 1;
        data.sort((a, b) => b.value.compareTo(a.value));
      });
    });
  }

  void _stopSimulation() {
    _timer?.cancel();
    _timer = null;
  }

  int get _maxValue => data.map((e) => e.value).reduce((a, b) => max(a, b));

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16213E),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Graph Simulation'),
        ),
        body: Stack(
          children: [
            // Grid background
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(),
            ),
            // Graph content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats panel
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3460).withAlpha(128),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue[400]!.withAlpha(128),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatItem(
                          label: 'Max Value',
                          value: _maxValue.toString(),
                          icon: Icons.arrow_upward_rounded,
                        ),
                        const SizedBox(width: 24),
                        _StatItem(
                          label: 'Items',
                          value: _items.toString(),
                          icon: Icons.bar_chart_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Graph
                  Expanded(
                    child: Row(
                      children: [
                        // Y-axis
                        Container(
                          width: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.blue[400]!,
                                Colors.blue[400]!.withAlpha(128),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Bars
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              ...data.map(
                                (e) => AnimatedTo.spring(
                                  globalKey: e.key,
                                  child: _Bar(
                                    value: e.value,
                                    maxValue: _maxValue,
                                    color: e.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_timer != null) {
              _stopSimulation();
            } else {
              _startSimulation();
            }
          },
          child: Icon(
            _timer != null ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth * value / maxValue)
            .clamp(0.0, constraints.maxWidth);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 40,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withAlpha(200),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[400]!.withAlpha(128),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue[300],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.blue[300],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Item {
  _Item({
    required this.key,
    required this.value,
    required this.color,
  });

  final GlobalKey key;
  int value;
  final Color color;
}
