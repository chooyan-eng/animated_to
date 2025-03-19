import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with TickerProviderStateMixin {
  // Track selected item
  int? selectedIndex;

  // Sample data
  final items = List.generate(
    20,
    (index) => 'Item ${index + 1}',
  );

  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set dark theme colors
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey[850],
        title: const Text('ListView Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        controller: _controller,
        child: Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: Colors.grey[850],
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(
                      Icons.folder,
                      color: Colors.blue,
                      size: 28,
                    ),
                    title: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: selectedIndex == items.indexOf(item)
                        ? AnimatedTo.spring(
                            controller: _controller,
                            globalKey: GlobalObjectKey('selected_item'),
                            slidingFrom: const Offset(0, 200),
                            child: Container(
                              width: 12, // Smaller indicator
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                            ),
                          )
                        : null,
                    onTap: () =>
                        setState(() => selectedIndex = items.indexOf(item)),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
