import 'package:animated_to/animated_to.dart';
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
    15,
    (index) => index.toString(),
  );

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
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Animated Sample Page')),
      // TODO(chooyan-eng): note that [AnimatedTo] doesn't work on scrollable widgets
      // try scrolling the page to see the issue
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: switch (_isExpanded) {
              // toggle [Wrap] and [Column] with animation
              true => Wrap(
                  spacing: 16,
                  runSpacing: 16,
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

/// A circle or a rectangle shaped widget to be animated with [AnimatedTo].
class _Card extends StatelessWidget {
  const _Card({
    required this.item,
    required this.index,
    required this.opacity,
    required this.isExpanded,
    required this.vsync,
  });

  final String item;
  final int index;
  final double opacity;
  final bool isExpanded;
  final TickerProvider vsync;

  @override
  Widget build(BuildContext context) {
    return AnimatedTo(
      // try either of [appearingFrom] or [slidingFrom]
      appearingFrom: const Offset(100, 0),
      // slidingFrom: const Offset(0, 100),

      // [TickerProviderStateMixin] is currently required to use [AnimatedTo]
      vsync: vsync,
      // [GlobalObjectKey] is required to identify the widget
      key: GlobalObjectKey(item),
      duration: Duration(milliseconds: 300 + (50 * index)),
      curve: Curves.easeIn,
      // [AnimatedTo] can be combined with some Animated widgets
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300 + (50 * index)),
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          color: Colors.primaries[int.parse(item) % Colors.primaries.length]
              .withAlpha(isExpanded ? 255 : 128),
          borderRadius: isExpanded
              ? BorderRadius.circular(100)
              : BorderRadius.circular(4),
        ),
        margin: const EdgeInsets.all(8),
        width: 80,
        height: 80,
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
