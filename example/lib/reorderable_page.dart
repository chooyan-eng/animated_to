import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

class ReorderableDemoPage extends StatefulWidget {
  const ReorderableDemoPage({super.key});

  @override
  State<ReorderableDemoPage> createState() => _ReorderableDemoPageState();
}

class _Item {
  _Item({required this.id, required this.color});
  final String id;
  final Color color;
}

class _ReorderableDemoPageState extends State<ReorderableDemoPage> {
  final _cubes = List.generate(
    2,
    (index) => _Item(
      id: index.toString(),
      color: Colors.primaries[index % Colors.primaries.length],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cubes
                .map(
                  (e) => _Cube(
                    item: e,
                    onAccept: (data) {
                      final targetIndex = _cubes.indexOf(e);
                      final draggingIndex = _cubes.indexOf(data);
                      setState(() {
                        final temp = _cubes[targetIndex];
                        _cubes[targetIndex] = _cubes[draggingIndex];
                        _cubes[draggingIndex] = temp;
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _Cube extends StatelessWidget {
  const _Cube({required this.item, required this.onAccept});

  final _Item item;
  final ValueSetter<_Item> onAccept;

  @override
  Widget build(BuildContext context) {
    return AnimatedTo.spring(
      globalKey: GlobalObjectKey('reorderable_item_${item.id}'),
      child: DragTarget(
        onWillAcceptWithDetails: (details) {
          if (details.data == item) {
            return false;
          }
          onAccept(details.data as _Item);
          return true;
        },
        builder: (context, candidateData, rejectedData) => Draggable(
          feedback: _CubeFace(color: item.color, size: 60),
          childWhenDragging: _CubeFace(color: Colors.transparent),
          data: item,
          child: _CubeFace(color: item.color),
        ),
      ),
    );
  }
}

class _CubeFace extends StatelessWidget {
  const _CubeFace({required this.color, this.size = 60});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
