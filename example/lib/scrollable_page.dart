import 'dart:async';

import 'package:animated_to/animated_to.dart';
import 'package:flutter/material.dart';

class ScrollablePage extends StatefulWidget {
  const ScrollablePage({super.key});

  @override
  State<ScrollablePage> createState() => _ScrollablePageState();
}

class _ScrollablePageState extends State<ScrollablePage>
    with TickerProviderStateMixin {
  bool _isLeft = true;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // start automatically
    Timer(const Duration(milliseconds: 100), () {
      setState(() {
        _isLeft = !_isLeft;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedToBoundary(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          title: const Text(
            'Scrollable Page',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const SizedBox(height: 62),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 100,
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
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height,
                color: Colors.black,
                child: Stack(
                  children: [
                    Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Stack(
                        children: [
                          Positioned(
                            left: _isLeft ? 50 : null,
                            right: _isLeft ? null : 50,
                            top: MediaQuery.sizeOf(context).height / 2 - 50,
                            child: AnimatedTo.curve(
                              verticalController: _scrollController,
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeInOutCubic,
                              globalKey: const GlobalObjectKey('afterImage'),
                              onEnd: (cause) {
                                if (cause == AnimationEndCause.completed) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((timeStamp) {
                                    if (mounted) {
                                      setState(() {
                                        _isLeft = !_isLeft;
                                      });
                                    }
                                  });
                                }
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
              const SizedBox(height: 100),
              Material(
                color: Colors.black,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 100,
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
              const SizedBox(height: 100),
            ],
          ),
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
