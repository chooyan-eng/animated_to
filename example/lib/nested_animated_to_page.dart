import 'package:animated_to/animated_to.dart';
import 'package:example/grid_painter.dart';
import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

class NestedAnimatedToPage extends StatefulWidget {
  const NestedAnimatedToPage({super.key});

  @override
  State<NestedAnimatedToPage> createState() => _NestedAnimatedToPageState();
}

class _NestedAnimatedToPageState extends State<NestedAnimatedToPage> {
  bool _parentAtTop = true;
  bool _childAtLeft = true;

  void _moveParent() {
    setState(() {
      _parentAtTop = !_parentAtTop;
    });
  }

  void _moveChild() {
    setState(() {
      _childAtLeft = !_childAtLeft;
    });
  }

  void _moveBoth() {
    setState(() {
      _childAtLeft = !_childAtLeft;
      _parentAtTop = !_parentAtTop;
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
            'Nested Animation Control',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: Stack(
          children: [
            // Grid background
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(),
            ),
            // Main content
            Column(
              children: [
                // Control panel
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF0F3460).withAlpha(179),
                          const Color(0xFF16213E).withAlpha(179),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blue[400]!.withAlpha(102),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue[900]!.withAlpha(128),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Stats row
                        // Control buttons
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _ControlButton(
                              icon: Icons.swap_vert_rounded,
                              label: _parentAtTop ? 'Parent ↓' : 'Parent ↑',
                              onPressed: _moveParent,
                              color: Colors.purple,
                            ),
                            _ControlButton(
                              icon: Icons.swap_horiz_rounded,
                              label: _childAtLeft ? 'Child →' : 'Child ←',
                              onPressed: _moveChild,
                              color: Colors.pink,
                            ),
                            _ControlButton(
                              icon: Icons.all_inclusive_rounded,
                              label: 'Move Both',
                              onPressed: _moveBoth,
                              color: Colors.cyan,
                              isWide: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Animation area
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: _parentAtTop
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 20),
                          _buildParentContainer(),
                        ],
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentContainer() {
    return AnimatedTo.spring(
      globalKey: const GlobalObjectKey('parent'),
      description: CupertinoMotion.bouncy().description,
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple[700]!.withAlpha(153),
              Colors.purple[900]!.withAlpha(128),
            ],
          ),
          border: Border.all(
            color: Colors.purple[400]!.withAlpha(128),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.purple[700]!.withAlpha(102),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Title
            Positioned(
              top: 12,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple[400]!.withAlpha(77),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.purple[300]!.withAlpha(102),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.layers_rounded,
                      color: Colors.purple[200],
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Parent Container',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[100],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Child container
            Align(
              alignment:
                  _childAtLeft ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildChildContainer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildContainer() {
    return AnimatedTo.spring(
      globalKey: const GlobalObjectKey('child'),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink[400]!,
              Colors.pink[700]!,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink[600]!.withAlpha(128),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shine effect
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withAlpha(77),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Icon and label
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Colors.white.withAlpha(230),
                    size: 36,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Child',
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isWide = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isWide ? 200 : 130,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withAlpha(179),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: color.withAlpha(128),
              width: 2,
            ),
          ),
          elevation: 0,
          shadowColor: color.withAlpha(128),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
