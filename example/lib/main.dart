import 'dart:async';

import 'package:animated_to/animated_to.dart';
import 'package:example/boundary_constraints_page.dart';
import 'package:example/draggable_page.dart';
import 'package:example/graph_page.dart';
import 'package:example/hit_test_page.dart';
import 'package:example/horizontal_scrollable_page.dart';
import 'package:example/list_switch_page.dart';
import 'package:example/listview_page.dart';
import 'package:example/nested_animated_to_page.dart';
import 'package:example/scrollable_page.dart';
import 'package:example/simple_demo_page.dart';
import 'package:example/spring_page.dart';
import 'package:example/todo_cards_page.dart';
import 'package:example/two_lines_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const AnimatedToSamplePage());
  }
}

class AnimatedToSamplePage extends StatefulWidget {
  const AnimatedToSamplePage({super.key});

  @override
  State<AnimatedToSamplePage> createState() => _AnimatedToSamplePageState();
}

class _AnimatedToSamplePageState extends State<AnimatedToSamplePage>
    with TickerProviderStateMixin {
  var _isExpanded = true;

  final _drawerScrollController = ScrollController();

  /// Some item objects. In this demo, simply a list of [String].
  final _items = List.generate(
    50,
    (index) => index.toString(),
  );

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final children = _items
        .map(
          (item) => _Card(
            item: item,
            index: _items.indexOf(item),
            opacity: 1.0,
            isExpanded: _isExpanded,
            vsync: this,
            enabled: true,
            controller: _scrollController,
          ),
        )
        .toList();

    return Scaffold(
      drawer: AnimatedToBoundary(
        child: Drawer(
          backgroundColor: Colors.grey[300],
          child: SafeArea(
            child: SingleChildScrollView(
              controller: _drawerScrollController,
              child: Column(
                spacing: 4,
                children: [
                  _DrawerMenuItem(
                    title: 'Spring Demo',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SpringPage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'Boundary Constraints',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const BoundaryConstraintsPage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'Graph Demo',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GraphPage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'Throwing ball',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DraggablePage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'List Switch Demo',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ListSwitchPage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'TODO cards',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TodoCardsPage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'Two line boxes',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TwoLinesPage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'Scrollable',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ScrollablePage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'Horizontal Scrollable',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const HorizontalScrollablePage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'Simple Demo',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SimpleDemoPage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'Hit Test Demo',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HitTestPage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'Nested AnimatedTo',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NestedAnimatedToPage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                  _DrawerMenuItem(
                    title: 'List menu page',
                    vsync: this,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ListPage(),
                        ),
                      );
                    },
                    controller: _drawerScrollController,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(title: const Text('Animated Sample Page')),
      // TODO(chooyan-eng): note that [AnimatedTo] doesn't work on scrollable widgets
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: switch (_isExpanded) {
              // toggle [Wrap] and [Column] with animation
              true => Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: children,
                ),
              false => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() => _isExpanded = !_isExpanded);
        },
        icon: Icon(_isExpanded ? Icons.collections : Icons.expand),
        label: Text(_isExpanded ? 'Collapse' : 'Expand'),
      ),
    );
  }
}

/// A circle or a rectangle shaped widget to be animated with [CurveAnimatedTo].
class _Card extends StatelessWidget {
  const _Card({
    required this.item,
    required this.index,
    required this.opacity,
    required this.isExpanded,
    required this.vsync,
    required this.enabled,
    required this.controller,
  });

  final String item;
  final int index;
  final double opacity;
  final bool isExpanded;
  final TickerProvider vsync;
  final bool enabled;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) {
    final size = 60.0;
    return AnimatedTo.spring(
      // try either of [appearingFrom] or [slidingFrom]
      appearingFrom: const Offset(100, 0),
      // slidingFrom: const Offset(0, 100),

      // [GlobalObjectKey] is required to identify the widget
      globalKey: GlobalObjectKey(item),
      // duration: Duration(milliseconds: 300 + (10 * index)),
      // curve: Curves.easeOutQuad,
      enabled: enabled,
      verticalController: controller,
      onEnd: (cause) {
        switch (cause) {
          case AnimationEndCause.interrupted:
            // called when the animation is interrupted by another animation
            break;
          case AnimationEndCause.completed:
            // called when the animation is completed
            break;
        }
      },
      // [AnimatedTo] can be combined with some Animated widgets
      child: Container(
        // duration: Duration(milliseconds: 300 + (10 * index)),
        // curve: Curves.easeIn,
        decoration: BoxDecoration(
          color: Colors.primaries[int.parse(item) % Colors.primaries.length]
              .withAlpha(isExpanded ? 255 : 128),
          borderRadius: isExpanded
              ? BorderRadius.circular(100)
              : BorderRadius.circular(4),
        ),
        margin: const EdgeInsets.all(2),
        width: size,
        height: size,
        child: Center(
          child: Text(
            item,
            style: TextStyle(
              color: Colors.white.withAlpha(isExpanded ? 255 : 128),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatefulWidget {
  const _DrawerMenuItem({
    required this.title,
    required this.onTap,
    required this.vsync,
    required this.controller,
  });

  final String title;
  final VoidCallback onTap;
  final TickerProvider vsync;
  final ScrollController controller;

  @override
  State<_DrawerMenuItem> createState() => _DrawerMenuItemState();
}

class _DrawerMenuItemState extends State<_DrawerMenuItem> {
  var _preparing = true;
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 200), () {
      setState(() => _preparing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_preparing) {
      return const SizedBox.shrink();
    }
    return AnimatedTo.spring(
      globalKey: GlobalObjectKey(widget.title),
      appearingFrom: const Offset(0, -100),
      // duration: const Duration(milliseconds: 500),
      // curve: Curves.easeOutQuad,
      verticalController: widget.controller,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
