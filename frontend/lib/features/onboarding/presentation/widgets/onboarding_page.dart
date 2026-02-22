import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/onboarding_model.dart';

/// Single onboarding page: same layout for all (top section + bottom card).
/// Premium look: gradients, soft shadows, theme-matched colors. Consistent animations.
class OnboardingPageWidget extends StatefulWidget {
  const OnboardingPageWidget({
    super.key,
    required this.data,
    this.illustrationShape = OnboardingIllustrationShape.roundedRect,
  });

  final OnboardingPageData data;
  final OnboardingIllustrationShape illustrationShape;

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget>
    with SingleTickerProviderStateMixin {
  static const int _topFlex = 42;
  static const int _bottomFlex = 58;

  late final AnimationController _animController;
  late final Animation<double> _illustrationOpacity;
  late final Animation<double> _illustrationScale;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _illustrationOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.5, curve: Curves.easeOutCubic)),
    );
    _illustrationScale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.6, curve: Curves.easeOutCubic)),
    );
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic)),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: _topFlex,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildTopBackground(),
                  FadeTransition(
                    opacity: _illustrationOpacity,
                    child: ScaleTransition(
                      scale: _illustrationScale,
                      child: _buildIllustration(context),
                    ),
                  ),
                  if (widget.data.showOverlayButtons)
                    _buildOverlayButtons(context, constraints.maxHeight),
                ],
              );
            },
          ),
        ),
        Expanded(
          flex: _bottomFlex,
          child: FadeTransition(
            opacity: _cardOpacity,
            child: SlideTransition(
              position: _cardSlide,
              child: _BottomCard(data: widget.data),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBackground() {
    final base = widget.data.topBackgroundColor;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base,
            Color.lerp(base, Colors.black, 0.12) ?? base,
          ]!,
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    const size = 0.48; // same for all pages
    final side = w * size;
    final color = widget.data.illustrationBackgroundColor ?? const Color(0xFFE8D4C4);
    final Widget child = widget.data.illustrationAsset != null
        ? Image.asset(
            widget.data.illustrationAsset!,
            fit: BoxFit.contain,
            width: side,
            height: side * 0.92,
            color: color,
            errorBuilder: (_, __, ___) => widget.data.illustrationBuilder(context),
          )
        : widget.data.illustrationBuilder(context);
    if (widget.illustrationShape == OnboardingIllustrationShape.circle) {
      return Container(
        width: side,
        height: side,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, Color.lerp(color, Colors.white, 0.3)!],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: ClipOval(child: child),
      );
    }
    return Container(
      width: side,
      height: side * 0.92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.white, 0.25)!],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }

  Widget _buildOverlayButtons(BuildContext context, double topSectionHeight) {
    const size = 48.0;
    return Stack(
      children: [
        Positioned(
          top: 20,
          right: MediaQuery.sizeOf(context).width * 0.1,
          child: _GlassButton(size: size, icon: widget.data.overlayTopRightIcon),
        ),
        Positioned(
          left: MediaQuery.sizeOf(context).width * 0.08,
          top: topSectionHeight * 0.32,
          child: _GlassButton(size: size, icon: widget.data.overlayBottomLeftIcon),
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
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class _BottomCard extends StatelessWidget {
  const _BottomCard({required this.data});

  final OnboardingPageData data;

  static const _cardBg = Color(0xFFF8F7F5);
  static const _titleColor = Color(0xFF2B2B2B);
  static const _descColor = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height * 0.52,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                      height: 1.22,
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
                        height: 1.22,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: _descColor,
                      height: 1.48,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum OnboardingIllustrationShape { circle, roundedRect }
