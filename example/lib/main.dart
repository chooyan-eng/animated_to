import 'dart:async';

import 'package:animated_to/animated_to.dart';
import 'package:example/draggable_page.dart';
import 'package:example/graph_page.dart';
import 'package:example/list_switch_page.dart';
import 'package:example/login_page.dart';
import 'package:example/scrollable_page.dart';
import 'package:example/simple_demo_page.dart';
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
      drawer: Drawer(
        backgroundColor: Colors.grey[300],
        child: SafeArea(
          child: Column(
            spacing: 4,
            children: [
              _DrawerMenuItem(
                title: 'Login Page',
                vsync: this,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
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
              ),
              _DrawerMenuItem(
                title: 'List menu page',
                vsync: this,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ListSwitchPage(),
                    ),
                  );
                },
              ),
            ],
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
    return AnimatedTo.burst(
      // try either of [appearingFrom] or [slidingFrom]
      // appearingFrom: const Offset(100, 0),
      // slidingFrom: const Offset(0, 100),

      // [GlobalObjectKey] is required to identify the widget
      globalKey: GlobalObjectKey(item),
      // duration: Duration(milliseconds: 300 + (10 * index)),
      // curve: Curves.easeOutQuad,
      enabled: enabled,
      controller: controller,
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
  });

  final String title;
  final VoidCallback onTap;
  final TickerProvider vsync;

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
    return AnimatedTo.burst(
      globalKey: GlobalObjectKey(widget.title),
      // appearingFrom: const Offset(0, -100),
      // duration: const Duration(milliseconds: 500),
      // curve: Curves.easeOutQuad,
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
