import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E8E8),
              Color(0xFFE8DDE5),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo with concentric circles
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer circle
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE8C5D4).withValues(alpha: 0.3),
                              ),
                            ),
                            // Middle circle
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE8C5D4).withValues(alpha: 0.5),
                              ),
                            ),
                            // Inner flower shape
                            CustomPaint(
                              size: const Size(60, 60),
                              painter: FlowerLogoPainter(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // App name
                        const Text(
                          'MASIKA',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 8,
                            color: Color(0xFF8B3A5C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        const Text(
                          'WELLNESS • AI • INSIGHT',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2,
                            color: Color(0xFFB8B8B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Loading indicator at bottom
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Center(
                    child: LoadingDots(),
                  ),
                ),
              ),
              // Bottom indicator line
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8D8D8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlowerLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B3A5C)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final petalRadius = size.width / 5;
    final petalDistance = size.width / 3.5;

    // Draw 8 petals in a flower pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final petalCenter = Offset(
        center.dx + petalDistance * math.cos(angle),
        center.dy + petalDistance * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, petalRadius, paint);
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = const Color(0xFFA94768)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width / 4.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4A5B8).withValues(alpha: opacity),
              ),
            );
          },
        );
      }),
    );
  }
}
