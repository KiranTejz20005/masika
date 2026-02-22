import 'package:flutter/material.dart';

/// Data for a single onboarding page (title, description, visuals).
/// Use [illustrationAsset] for high-resolution logo/illustration (e.g. assets/images/onboarding_1.png).
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    this.titleAccent,
    required this.description,
    required this.topBackgroundColor,
    this.illustrationBackgroundColor,
    required this.illustrationBuilder,
    this.illustrationAsset,
    this.showOverlayButtons = false,
    this.overlayTopRightIcon = Icons.bar_chart_rounded,
    this.overlayBottomLeftIcon = Icons.favorite_rounded,
  });

  final String title;
  final String? titleAccent;
  final String description;
  final Color topBackgroundColor;
  final Color? illustrationBackgroundColor;
  final Widget Function(BuildContext context) illustrationBuilder;
  /// Optional high-res image path (e.g. 'assets/images/onboarding_1.png'). Shown instead of builder when set.
  final String? illustrationAsset;
  final bool showOverlayButtons;
  final IconData overlayTopRightIcon;
  final IconData overlayBottomLeftIcon;
}
