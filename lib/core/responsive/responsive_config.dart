import 'package:flutter/material.dart';

/// Breakpoints (logical pixels) for layout decisions.
/// Use with MediaQuery.sizeOf(context).width / height.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double compactWidth = 360;
  static const double mediumWidth = 400;
  static const double expandedWidth = 600;
  static const double largeWidth = 840;

  static const double compactHeight = 600;
  static const double mediumHeight = 700;
  static const double expandedHeight = 800;
}

/// Screen size categories for adaptive layouts.
enum ScreenSize {
  compact,
  medium,
  expanded,
  large,
}

/// Centralized responsive configuration and helpers.
/// Use MediaQuery + LayoutBuilder; avoid fixed pixels for layout.
class ResponsiveConfig {
  ResponsiveConfig._();

  static ScreenSize screenSize(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= ResponsiveBreakpoints.largeWidth) return ScreenSize.large;
    if (w >= ResponsiveBreakpoints.expandedWidth) return ScreenSize.expanded;
    if (w >= ResponsiveBreakpoints.mediumWidth) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static EdgeInsets padding(BuildContext context) =>
      MediaQuery.paddingOf(context);

  /// Horizontal screen padding that scales with width (min 16, max 32).
  static double horizontalPadding(BuildContext context) {
    final w = width(context);
    if (w <= ResponsiveBreakpoints.compactWidth) return 16;
    if (w >= ResponsiveBreakpoints.expandedWidth) return 32;
    return 16 + (w - ResponsiveBreakpoints.compactWidth) /
        (ResponsiveBreakpoints.expandedWidth - ResponsiveBreakpoints.compactWidth) * 16;
  }

  /// Vertical section spacing (min 16, scales up on larger screens).
  static double sectionSpacing(BuildContext context) {
    final h = height(context);
    if (h <= ResponsiveBreakpoints.compactHeight) return 16;
    if (h >= ResponsiveBreakpoints.expandedHeight) return 24;
    return 20;
  }

  /// Scale factor for text based on width (1.0 at 360px, cap at 1.2).
  static double textScale(BuildContext context) {
    final w = width(context);
    if (w <= ResponsiveBreakpoints.compactWidth) return 1.0;
    final t = (w - ResponsiveBreakpoints.compactWidth) /
        (ResponsiveBreakpoints.expandedWidth - ResponsiveBreakpoints.compactWidth);
    return 1.0 + (t * 0.2).clamp(0.0, 0.2);
  }

  /// Minimum touch target (48dp) for accessibility.
  static const double minTouchTarget = 48;

  /// Bottom bar height including safe area (use for persistent bars).
  /// Matches DashboardShell nav bar: content 76 + bottom pad 12 + safe area.
  static double bottomBarHeight(BuildContext context) {
    return ResponsiveConfig.padding(context).bottom + 88;
  }
}

/// Spacing scale that adapts to screen size.
class ResponsiveSpacing {
  ResponsiveSpacing._();

  static double xs(BuildContext context) =>
      ResponsiveConfig.sectionSpacing(context) * 0.5;

  static double sm(BuildContext context) =>
      ResponsiveConfig.sectionSpacing(context);

  static double md(BuildContext context) =>
      ResponsiveConfig.sectionSpacing(context) * 1.25;

  static double lg(BuildContext context) =>
      ResponsiveConfig.sectionSpacing(context) * 1.5;

  static double xl(BuildContext context) =>
      ResponsiveConfig.sectionSpacing(context) * 2;

  static double xxl(BuildContext context) =>
      ResponsiveConfig.sectionSpacing(context) * 2.5;
}
