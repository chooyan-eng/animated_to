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

  final _controller = ScrollController();

  // Sample data
  final items = List.generate(
    50,
    (index) => 'Item ${index + 1}',
  );

  final keys = List.generate(
    50,
    (index) => GlobalKey(),
  );

  /// Don't provide [ScrollController] when using [ListView].
  // final _controller = ScrollController();

  int _currentSelected = 0;
  final _iconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AnimatedToBoundary(
      child: Scaffold(
        // Set dark theme colors
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey[850],
          title: const Text('ListView Page'),
        ),
        body: ListView.builder(
          controller: _controller,
          itemCount: items.length,
          // controller: _controller,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedTo.spring(
              verticalController: _controller,
              slidingFrom: Offset(200 + index * 10, 0),
              globalKey: keys[index],
              child: ListTile(
                onTap: () {
                  setState(() {
                    _currentSelected = index;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                tileColor: Colors.grey[850],
                contentPadding: const EdgeInsets.all(16),
                leading: index == _currentSelected
                    ? AnimatedTo.spring(
                        globalKey: _iconKey,
                        verticalController: _controller,
                        child: const Icon(
                          Icons.folder,
                          color: Colors.blue,
                          size: 28,
                        ),
                      )
                    : null,
                title: Text(
                  items[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
