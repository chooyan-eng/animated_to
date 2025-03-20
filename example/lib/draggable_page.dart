import 'package:animated_to/animated_to.dart';
import 'package:example/grid_painter.dart';
import 'package:flutter/material.dart';

class DraggablePage extends StatefulWidget {
  const DraggablePage({super.key});

  @override
  State<DraggablePage> createState() => _DraggablePageState();
}

enum _BallState { none, dragging, thrown }

class _DraggablePageState extends State<DraggablePage> {
  static const _initialOffset = Offset(200, 500);
  Offset _offset = _initialOffset;
  Offset? _velocity;
  _BallState _ballState = _BallState.none;

  void _resetBall() {
    setState(() {
      _offset = _initialOffset;
      _velocity = null;
      _ballState = _BallState.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16213E),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Spring Ball Physics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Grid background
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(),
            ),
            // Target zone
            Positioned(
              top: 90,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue[400]!.withAlpha(51),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue[400]!.withAlpha(102),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[400]!.withAlpha(51),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.flag_rounded,
                    color: Colors.blue[400]!.withAlpha(153),
                    size: 32,
                  ),
                ),
              ),
            ),
            // Instructions
            if (_ballState != _BallState.thrown)
              Positioned(
                top: 220,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3460).withAlpha(179),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue[400]!.withAlpha(51),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Drag and throw the ball',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Draggable ball
            if (_ballState != _BallState.thrown)
              Positioned(
                left: _offset.dx,
                top: _offset.dy,
                child: GestureDetector(
                  onPanStart: (_) {
                    setState(() {
                      _ballState = _BallState.dragging;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _offset = _offset + details.delta;
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      _ballState = _BallState.thrown;
                      _velocity = details.velocity.pixelsPerSecond;
                    });
                  },
                  child: _Ball(enabled: _ballState != _BallState.dragging),
                ),
              ),
            // Thrown ball with spring animation
            if (_ballState == _BallState.thrown)
              Positioned(
                top: 100,
                child: _Ball(velocity: _velocity, enabled: true),
              ),
          ],
        ),
        floatingActionButton: _ballState == _BallState.thrown
            ? FloatingActionButton.extended(
                onPressed: _resetBall,
                backgroundColor: Colors.blue[600],
                label: Row(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: Colors.white.withAlpha(230),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reset Ball',
                      style: TextStyle(
                        color: Colors.white.withAlpha(230),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}

class _Ball extends StatelessWidget {
  const _Ball({this.velocity, required this.enabled});

  final Offset? velocity;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedTo.spring(
      enabled: enabled,
      globalKey: const GlobalObjectKey('ball'),
      velocityBuilder: velocity != null ? () => velocity! : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[400]!,
              Colors.blue[600]!,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue[600]!.withAlpha(77),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.sports_baseball_rounded,
            color: Colors.white.withAlpha(230),
            size: 32,
          ),
        ),
      ),
    );
  }
}
