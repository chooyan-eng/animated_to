import 'package:flutter/material.dart';
import 'package:animated_to/animated_to.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameKey = GlobalKey();
  double _unOffset = 0;
  final _passwordKey = GlobalKey();
  double _pwOffset = 0;
  final _loginButtonKey = GlobalKey();
  double _lbOffset = 0;
  final _titleKey = GlobalKey();
  double _tOffset = 0;
  final _backgroundKey = GlobalKey();
  double _bgOffset = 0;
  final _suKey = GlobalKey();
  double _suOffset = 0;
  final _fpKey = GlobalKey();
  double _fpOffset = 0;
  final _bglKey = GlobalKey();
  double _bglOffset = 0;
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final width = screenSize.width;
    final height = screenSize.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ],
                ),
              ),
            ),
          ),

          // Background decoration circles
          Positioned(
            top: -100,
            right: -100 - _bglOffset,
            child: GestureDetector(
              onTap: () {
                setState(() => _bglOffset = 100);
              },
              child: AnimatedTo.burst(
                globalKey: _bglKey,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[700]!.withAlpha(30),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -80 + _bgOffset,
            child: GestureDetector(
              onTap: () {
                setState(() => _bgOffset = 100);
              },
              child: AnimatedTo.burst(
                globalKey: _backgroundKey,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[400]!.withAlpha(25),
                  ),
                ),
              ),
            ),
          ),

          // App title
          Positioned(
            top: height * 0.15,
            left: 0 + _tOffset,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() => _tOffset = 100);
              },
              child: AnimatedTo.burst(
                globalKey: _titleKey,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[600]!.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 48,
                          color: Colors.blue[300],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sign in to continue",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Username field
          Positioned(
            top: height * 0.40,
            left: width * 0.1 + _unOffset,
            right: width * 0.1,
            child: GestureDetector(
              onTap: () {
                setState(() => _unOffset = 100);
              },
              child: AnimatedTo.burst(
                globalKey: _usernameKey,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withAlpha(40),
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      style: TextStyle(color: Colors.white.withAlpha(230)),
                      enabled: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Username",
                        hintStyle:
                            TextStyle(color: Colors.white.withAlpha(120)),
                        icon: Icon(
                          Icons.person_outline,
                          color: Colors.blue[300],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Password field
          Positioned(
            top: height * 0.40 + 80,
            left: width * 0.1 + _pwOffset,
            right: width * 0.1,
            child: GestureDetector(
              onTap: () {
                setState(() => _pwOffset = 100);
              },
              child: AnimatedTo.burst(
                globalKey: _passwordKey,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withAlpha(40),
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      enabled: false,
                      obscureText: true,
                      style: TextStyle(color: Colors.white.withAlpha(230)),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                        hintStyle:
                            TextStyle(color: Colors.white.withAlpha(120)),
                        icon: Icon(
                          Icons.lock_outline,
                          color: Colors.blue[300],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Forgot password
          Positioned(
            top: height * 0.40 + 150,
            right: width * 0.1 + _fpOffset,
            child: GestureDetector(
              onTap: () {
                setState(() => _fpOffset = 100);
              },
              child: AnimatedTo.burst(
                globalKey: _fpKey,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Login button
          Positioned(
            bottom: height * 0.15,
            left: width * 0.1 + _lbOffset,
            right: width * 0.1,
            child: GestureDetector(
              onTap: () {
                setState(() => _lbOffset = 100);
              },
              child: AnimatedTo.burst(
                globalKey: _loginButtonKey,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue[400]!,
                        Colors.blue[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[700]!.withAlpha(60),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withAlpha(230),
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "LOG IN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),

          // Sign up text
          Positioned(
            bottom: height * 0.05,
            left: 0 + _suOffset,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() => _suOffset = 100);
              },
              child: AnimatedTo.burst(
                globalKey: _suKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.white.withAlpha(160),
                      ),
                    ),
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
