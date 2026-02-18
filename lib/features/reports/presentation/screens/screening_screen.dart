import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_providers.dart';

/// Screening / Lab Results screen. Matches design: Hemoglobin result,
/// Medical Insights, Consult CTA, Educational content, security footer.
class ScreeningScreen extends ConsumerWidget {
  const ScreeningScreen({super.key});

  static const _maroon = Color(0xFF6A1A21);
  static const _bg = Color(0xFFFBF8F6);
  static const _labelGray = Color(0xFF4B4B4B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _bg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _maroon, size: 20),
          ),
          onPressed: () => ref.read(navIndexProvider.notifier).state = 0,
        ),
        title: const Text(
          'Lab Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _maroon,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: _maroon),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share lab results'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          _buildResultCard(context),
          const SizedBox(height: 24),
          _buildSectionTitle('Medical Insights'),
          const SizedBox(height: 12),
          _buildInsightCard(
            icon: Icons.info_outline_rounded,
            iconBg: const Color(0xFFF3F3F3),
            title: 'What this means',
            body:
                'Your levels are slightly below the target range for adult females, which may indicate mild anemia.',
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            icon: Icons.restaurant_rounded,
            iconBg: const Color(0xFFE8F5E9),
            title: 'Recommended Action',
            body:
                'Consider increasing iron-rich foods like spinach, lentils, and lean proteins in your diet.',
          ),
          const SizedBox(height: 24),
          _buildConsultCard(context),
          const SizedBox(height: 24),
          _buildSectionTitle('Educational Content'),
          const SizedBox(height: 12),
          _buildVideoCard(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hemoglobin (Hb)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _labelGray,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'BELOW RANGE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _maroon,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '11.2',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: _maroon,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'g/dL',
                style: TextStyle(
                  fontSize: 14,
                  color: _labelGray.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRangeTrack(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LOW (10.0)', style: TextStyle(fontSize: 11, color: _labelGray.withValues(alpha: 0.7))),
              Text('NORMAL (12.1-15.1)', style: TextStyle(fontSize: 11, color: _labelGray.withValues(alpha: 0.7))),
              Text('HIGH (16.0+)', style: TextStyle(fontSize: 11, color: _labelGray.withValues(alpha: 0.7))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeTrack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const lowWidth = 0.25;
        final w = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 10,
              width: w,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Container(
              width: w * lowWidth,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB74D),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Positioned(
              left: w * 0.22 - 8,
              top: -3,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: _maroon,
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _maroon, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _maroon,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: _labelGray.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _maroon,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consult with Masika AI Doctor',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get a professional interpretation of your results and a personalized health plan in minutes.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _maroon,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Start Consultation',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF87D0C4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.play_circle_filled_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Understanding Iron Deficiency',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '5:12 mins • Dr. Elena Smith',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
