import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

class BoundaryConstraintsPage extends StatefulWidget {
  const BoundaryConstraintsPage({super.key});

  @override
  State<BoundaryConstraintsPage> createState() => _BoundaryConstraintsPageState();
}

class _BoundaryConstraintsPageState extends State<BoundaryConstraintsPage>
    with TickerProviderStateMixin {
  final _leftLineItems = ['a'];
  final _rightLineItems = ['k'];
  final Map<String, int> _hitCounts = {};
  bool _scale = false;
  bool _rotate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boundary Constraints Page'),
        actions: [
          Row(
            children: [
              const Text('Scale'),
              Switch(
                value: _scale,
                onChanged: (value) => setState(() => _scale = value),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Rotate'),
              Switch(
                value: _rotate,
                onChanged: (value) => setState(() => _rotate = value),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  spacing: 10,
                  children: _leftLineItems
                      .map(
                          (item) => _SpringItem(
                            item: item,
                            vsync: this,
                            hits: _hitCounts[item] ?? 0,
                            onTap: () {
                              setState(() {
                                _hitCounts[item] = (_hitCounts[item] ?? 0) + 1;
                                _leftLineItems.remove(item);
                                _rightLineItems.add(item);
                              });
                            },
                            scale: _scale,
                            rotate: _rotate,
                          color: Colors.amberAccent,
                        ),
                      )
                      .toList(),
                ),
                Column(
                  spacing: 10,
                  children: _rightLineItems
                      .map(
                          (item) => _SpringItem(
                            item: item,
                            vsync: this,
                            hits: _hitCounts[item] ?? 0,
                            onTap: () {
                              setState(() {
                                _hitCounts[item] = (_hitCounts[item] ?? 0) + 1;
                                _rightLineItems.remove(item);
                                _leftLineItems.add(item);
                              });
                            },
                            scale: _scale,
                            rotate: _rotate,
                          color: Colors.blueAccent,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpringItem extends StatelessWidget {
  const _SpringItem({
    required this.item,
    required this.vsync,
    required this.onTap,
    required this.hits,
    required this.scale,
    required this.rotate,
    required this.color,
  });

  final String item;
  final TickerProvider vsync;
  final VoidCallback onTap;
  final int hits;
  final bool scale;
  final bool rotate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 9000),
      curve: Curves.easeInOut,
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Hits: $hits',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    if (scale) {
      content = Transform.scale(scale: 1.5,transformHitTests: true, child: content,);
    }
    if (rotate) {
      content = Transform.rotate(angle: 0.5, transformHitTests: true, child: content,);
    }

    return AnimatedTo.curve(
      duration: Duration(milliseconds: 9000),
      curve: Curves.easeIn,
      globalKey: GlobalObjectKey(item),
      child: GestureDetector(
        onTap: onTap,
        child: content,
      ),
    );
  }
}
