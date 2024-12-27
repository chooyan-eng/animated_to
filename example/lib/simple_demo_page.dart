import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

class SimpleDemoPage extends StatefulWidget {
  const SimpleDemoPage({super.key});

  @override
  State<SimpleDemoPage> createState() => _SimpleDemoPageState();
}

class _SimpleDemoPageState extends State<SimpleDemoPage>
    with TickerProviderStateMixin {
  bool _isLeft = true;

  final _keys = List.generate(10, (index) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        title: const Text(
          'Simple Demo Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 400,
            child: Stack(
              children: List.generate(10, (index) {
                return Positioned(
                  left: _isLeft ? 50 : null,
                  right: _isLeft ? null : 50,
                  top: index * (50 + 8.0),
                  child: AnimatedTo(
                    duration: Duration(milliseconds: 500 + (index * 100)),
                    curve: Curves.easeInOut,
                    globalKey: _keys[index],
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500 + (index * 100)),
                      curve: Curves.easeInOut,
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isLeft
                            ? Colors.grey[100]
                            : Colors.blue[(index + 1) * 100],
                        borderRadius: _isLeft
                            ? BorderRadius.circular(8)
                            : BorderRadius.circular(100),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isLeft = !_isLeft;
                  });
                },
                icon: const Icon(Icons.arrow_left),
                label: const Text('Left'),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isLeft = !_isLeft;
                  });
                },
                icon: const Icon(Icons.arrow_right),
                label: const Text('Right'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
