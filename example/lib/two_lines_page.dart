import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

class TwoLinesPage extends StatefulWidget {
  const TwoLinesPage({super.key});

  @override
  State<TwoLinesPage> createState() => _TwoLinesPageState();
}

class _TwoLinesPageState extends State<TwoLinesPage>
    with TickerProviderStateMixin {
  final _leftLineItems = ['a', 'b', 'c', 'd', 'e', 'f'];
  final _rightLineItems = ['k', 'l', 'm', 'n', 'o', 'p'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Line Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              spacing: 10,
              children: _leftLineItems
                  .map(
                    (item) => _Item(
                      item: item,
                      vsync: this,
                      onTap: () {
                        setState(() {
                          _leftLineItems.remove(item);
                          _rightLineItems.add(item);
                        });
                      },
                      color: Colors.amberAccent,
                    ),
                  )
                  .toList(),
            ),
            Column(
              spacing: 10,
              children: _rightLineItems
                  .map(
                    (item) => _Item(
                      item: item,
                      vsync: this,
                      onTap: () {
                        setState(() {
                          _rightLineItems.remove(item);
                          _leftLineItems.add(item);
                        });
                      },
                      color: Colors.blueAccent,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.item,
    required this.vsync,
    required this.onTap,
    required this.color,
  });

  final String item;
  final TickerProvider vsync;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedTo(
      vsync: vsync,
      key: GlobalObjectKey(item),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
          ),
          child: Center(
              child: Text(
            item,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )),
        ),
      ),
    );
  }
}
