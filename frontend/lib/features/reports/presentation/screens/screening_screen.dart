import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';

/// Screening — Coming Soon screen. Matches reference: app bar, circular gradient
/// with microscope icon, "Coming Soon" copy, pill "Notify Me" button.
/// Navbar is provided by DashboardShell (unchanged).
class ScreeningScreen extends ConsumerWidget {
  const ScreeningScreen({super.key});

  static const _maroon = Color(0xFF8D2D3B);
  static const _maroonLight = Color(0xFFA63D4D);
  static const _maroonDark = Color(0xFF6A1A21);
  static const _bg = Color(0xFFF8F7F5);
  static const _labelGray = Color(0xFF4B4B4B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _maroon, size: 20),
          onPressed: () => ref.read(navIndexProvider.notifier).state = 0,
        ),
        title: Text(
          'Screening',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              _buildComingSoonGraphic(context),
              const SizedBox(height: 32),
              Text(
                'Coming Soon',
                style: AppTypography.screenTitle.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We are working on bringing advanced AI-powered health screenings to your fingertips. Stay tuned!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: _labelGray.withValues(alpha: 0.95),
                ),
              ),
              const Spacer(flex: 1),
              _buildNotifyButton(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonGraphic(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_maroonLight, _maroon, _maroonDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: _maroon.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _DashedCirclePainter(
                color: Colors.white.withValues(alpha: 0.5),
                strokeWidth: 2,
                dashLength: 8,
                gapLength: 6,
              ),
              size: const Size(200, 200),
            ),
          ),
          const Icon(
            Icons.biotech_rounded,
            size: 72,
            color: Colors.white,
          ),
          Positioned(
            right: 12,
            bottom: 24,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: _maroon,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          color: _maroon,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: _maroon.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(27),
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You’ll be notified when Screening is ready.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(27),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Notify Me',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.mail_outline_rounded, color: Colors.white, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashLength = 8,
    this.gapLength = 6,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const twoPi = 2 * 3.14159265359;
    const dashCount = 36.0;
    final segmentRad = (dashLength / (dashLength + gapLength)) * (twoPi / dashCount);
    final gapRad = (gapLength / (dashLength + gapLength)) * (twoPi / dashCount);

    for (var i = 0.0; i < twoPi; i += segmentRad + gapRad) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i,
        segmentRad,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
