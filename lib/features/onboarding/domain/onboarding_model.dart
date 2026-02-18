import 'package:flutter/material.dart';

/// Data for a single onboarding page (title, description, visuals).
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    this.titleAccent,
    required this.description,
    required this.topBackgroundColor,
    this.illustrationBackgroundColor,
    required this.illustrationBuilder,
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
  final bool showOverlayButtons;
  final IconData overlayTopRightIcon;
  final IconData overlayBottomLeftIcon;
}
