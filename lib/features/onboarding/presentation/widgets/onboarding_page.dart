import 'package:flutter/material.dart';

import '../../domain/onboarding_model.dart';

/// Single onboarding page: top colored section with illustration, bottom white card.
class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({
    super.key,
    required this.data,
    this.illustrationShape = OnboardingIllustrationShape.circle,
  });

  final OnboardingPageData data;
  final OnboardingIllustrationShape illustrationShape;

  @override
  Widget build(BuildContext context) {
    final topFraction = data.illustrationBackgroundColor != null ? 0.40 : 0.42;
    return Column(
      children: [
        // Top section: colored background + illustration
        Expanded(
          flex: (topFraction * 100).round(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                color: data.topBackgroundColor,
              ),
              _buildIllustration(context),
              if (data.showOverlayButtons) _buildOverlayButtons(context),
            ],
          ),
        ),
        // Bottom white card with curved top
        Expanded(
          flex: 100 - (topFraction * 100).round(),
          child: _BottomCard(data: data),
        ),
      ],
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width * 0.55;
    final color = data.illustrationBackgroundColor ?? const Color(0xFFE8D4C4);
    final child = data.illustrationBuilder(context);
    if (illustrationShape == OnboardingIllustrationShape.circle) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.8), width: 2),
        ),
        child: ClipOval(child: child),
      );
    }
    return Container(
      width: size * 1.1,
      height: size * 0.9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }

  Widget _buildOverlayButtons(BuildContext context) {
    final size = 48.0;
    return Stack(
      children: [
        Positioned(
          top: 24,
          right: MediaQuery.sizeOf(context).width * 0.12,
          child: _GlassButton(size: size, icon: data.overlayTopRightIcon),
        ),
        Positioned(
          left: MediaQuery.sizeOf(context).width * 0.08,
          top: MediaQuery.sizeOf(context).height * 0.18,
          child: _GlassButton(size: size, icon: data.overlayBottomLeftIcon),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.size, required this.icon});

  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class _BottomCard extends StatefulWidget {
  const _BottomCard({required this.data});

  final OnboardingPageData data;

  @override
  State<_BottomCard> createState() => _BottomCardState();
}

class _BottomCardState extends State<_BottomCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              FadeTransition(
                opacity: _opacity,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B2B2B),
                          height: 1.2,
                        ),
                      ),
                      if (data.titleAccent != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          data.titleAccent!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: data.topBackgroundColor,
                            height: 1.2,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9E9E9E),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

enum OnboardingIllustrationShape { circle, roundedRect }
