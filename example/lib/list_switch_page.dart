import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

class ListSwitchPage extends StatefulWidget {
  const ListSwitchPage({super.key});

  @override
  State<ListSwitchPage> createState() => _ListSwitchPageState();
}

enum _Mode { list, grid }

class _ListSwitchPageState extends State<ListSwitchPage> {
  final List<_Item> items = [
    _Item(
      id: 'item_id_1',
      description: 'Item 1',
      imagePath: 'assets/image_1.png',
      iconKey: GlobalObjectKey('item_id_1_icon'),
      textKey: GlobalObjectKey('item_id_1_text'),
    ),
    _Item(
      id: 'item_id_2',
      description: 'Item 2',
      imagePath: 'assets/image_2.png',
      iconKey: GlobalObjectKey('item_id_2_icon'),
      textKey: GlobalObjectKey('item_id_2_text'),
    ),
  ];

  _Mode _mode = _Mode.list;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Switch')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<_Mode>(
                  selected: {_mode},
                  onSelectionChanged: (Set<_Mode> newSelection) {
                    setState(() => _mode = newSelection.first);
                  },
                  segments: const [
                    ButtonSegment<_Mode>(
                      value: _Mode.list,
                      icon: Icon(Icons.view_list),
                      label: Text('List'),
                    ),
                    ButtonSegment<_Mode>(
                      value: _Mode.grid,
                      icon: Icon(Icons.grid_view),
                      label: Text('Grid'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              // Because animated_to doesn't support sliver right now,
              // we must use Column/Row inside SingleChildScrollView.
              child: SingleChildScrollView(
                controller: _scrollController,
                child: _mode == _Mode.list
                    ? Column(
                        spacing: 20,
                        children: items
                            .map((e) => _ListItem(
                                  item: e,
                                  scrollController: _scrollController,
                                ))
                            .toList(),
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            Row(
                              spacing: 20,
                              children: items
                                  .map((e) => Expanded(
                                        child: _GridItem(
                                          item: e,
                                          scrollController: _scrollController,
                                        ),
                                      ))
                                  .toList(),
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

class _ListItem extends StatelessWidget {
  final _Item item;
  final ScrollController scrollController;

  const _ListItem({required this.item, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // AnimatedTo for text
      title: AnimatedTo.spring(
        globalKey: item.textKey,
        child: Text(item.description),
      ),
      // AnimatedTo for image
      leading: AnimatedTo.spring(
        globalKey: item.iconKey,
        // if we want to change size as well as position, we need to provide a widget
        // whose size will be calculated exact the same as child
        sizeWidget: const SizedBox(width: 60, height: 60),
        controller: scrollController,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.hardEdge,
          width: 60,
          height: 60,
          child: Image.asset(
            item.imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final _Item item;
  final ScrollController scrollController;

  const _GridItem({required this.item, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder to determine the constraints of this item
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AnimatedTo for image
          AnimatedTo.spring(
            globalKey: item.iconKey,
            // if we want to change size as well as position, we need to provide a widget
            // whose size will be calculated exact the same as child
            sizeWidget: SizedBox(
              width: constraints.maxWidth,
              child: AspectRatio(aspectRatio: 1),
            ),
            controller: scrollController,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: constraints.maxWidth,
              height: constraints.maxWidth, // square shape
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedTo.spring(
            globalKey: item.textKey,
            child: Text(item.description),
          ),
        ],
      );
    });
  }
}

class _Item {
  final String id;
  final String description;
  final String imagePath;
  final GlobalKey iconKey;
  final GlobalKey textKey;

  const _Item({
    required this.id,
    required this.description,
    required this.imagePath,
    required this.iconKey,
    required this.textKey,
  });
}
