import 'dart:async';

import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

class HorizontalScrollablePage extends StatefulWidget {
  const HorizontalScrollablePage({super.key});

  @override
  State<HorizontalScrollablePage> createState() =>
      _HorizontalScrollablePageState();
}

class _HorizontalScrollablePageState extends State<HorizontalScrollablePage>
    with TickerProviderStateMixin {
  bool _isTop = true;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // start automatically
    Timer(const Duration(milliseconds: 100), () {
      setState(() {
        _isTop = !_isTop;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        title: const Text(
          'Horizontal Scrollable Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: Row(
          children: [
            const SizedBox(width: 62),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'START',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Container(
              height: double.infinity,
              width: MediaQuery.sizeOf(context).width,
              color: Colors.black,
              child: Stack(
                children: [
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Stack(
                      children: [
                        Positioned(
                          top: _isTop ? 50 : null,
                          bottom: _isTop ? null : 50,
                          left: MediaQuery.sizeOf(context).width / 2 - 50,
                          child: AnimatedTo.curve(
                            horizontalController: _scrollController,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOutCubic,
                            globalKey: const GlobalObjectKey('afterImage'),
                            onEnd: (cause) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                if (mounted) {
                                  setState(() {
                                    _isTop = !_isTop;
                                  });
                                }
                              });
                            },
                            child: _Cube(alpha: 255, index: -1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 100),
            Material(
              color: Colors.black,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'END',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 100),
          ],
        ),
      ),
    );
  }
}

class _Cube extends StatelessWidget {
  const _Cube({
    required this.alpha,
    required this.index,
  });

  final int alpha;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withAlpha(alpha),
            Colors.purple.withAlpha(alpha),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (index == -1)
            BoxShadow(
              color: Colors.blue.withAlpha(150),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
    );
  }
}
