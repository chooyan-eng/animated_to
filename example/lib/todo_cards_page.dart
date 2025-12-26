import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

class TodoCardsPage extends StatefulWidget {
  const TodoCardsPage({super.key});

  @override
  State<TodoCardsPage> createState() => _TodoCardsPageState();
}

class _TodoCardsPageState extends State<TodoCardsPage>
    with TickerProviderStateMixin {
  final _leftLineItems = ['a', 'b', 'c'];
  final _rightLineItems = ['k', 'l'];
  final _centerLineItems = ['u'];

  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedToBoundary(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todo Cards Page'),
        ),
        body: NotificationListener<ScrollNotification>(
          // workaround to fix scrolling issue by disabling animation when scrolling
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => _enabled = false);
              });
            }
            if (notification is ScrollEndNotification) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => _enabled = true);
              });
            }
            return true;
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 32,
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
                                _centerLineItems.add(item);
                              });
                            },
                            color: Colors.amber[700]!,
                            enabled: _enabled,
                          ),
                        )
                        .toList(),
                  ),
                  Column(
                    spacing: 10,
                    children: _centerLineItems
                        .map(
                          (item) => _Item(
                            item: item,
                            vsync: this,
                            onTap: () {
                              setState(() {
                                _centerLineItems.remove(item);
                                _rightLineItems.add(item);
                              });
                            },
                            color: Colors.green[700]!,
                            enabled: _enabled,
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
                                _centerLineItems.add(item);
                              });
                            },
                            color: Colors.blue[700]!,
                            enabled: _enabled,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              final allItemNumber = _leftLineItems.length +
                  _centerLineItems.length +
                  _rightLineItems.length;
              _leftLineItems.add('t${allItemNumber + 1}');
            });
          },
          child: const Icon(Icons.add),
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
    required this.enabled,
  });

  final String item;
  final TickerProvider vsync;
  final VoidCallback onTap;
  final Color color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedTo.spring(
      enabled: enabled,
      hitTestEnabled: false,
      globalKey: GlobalObjectKey(item),
      slidingFrom: Offset(0, 30),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          width: 200,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TODO #$item',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sample task to complete',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
