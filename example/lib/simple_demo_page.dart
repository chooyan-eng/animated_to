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
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isLeft = !_isLeft;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              const Spacer(),
              ...List.generate(
                3,
                (index) => Align(
                  alignment:
                      _isLeft ? Alignment.centerLeft : Alignment.centerRight,
                  child: AnimatedTo.spring(
                    verticalController: PrimaryScrollController.of(context),
                    globalKey: _keys[index],
                    sizeWidget: SizedBox(
                      width: _isLeft ? 100 : 40,
                      height: _isLeft ? 100 : 40,
                    ),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _isLeft ? 100 : 40,
                      height: _isLeft ? 100 : 40,
                      decoration: BoxDecoration(
                        color: _isLeft ? Colors.white : Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Spacer(),
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
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
