/// Premium spacing system for consistent layout
/// Using 4px base unit for pixel-perfect spacing
class AppSpacing {
  AppSpacing._();
  
  // Base spacing unit (4px)
  static const double unit = 4.0;
  
  // Micro spacing (for tight elements)
  static const double xxxs = unit * 1; // 4px
  static const double xxs = unit * 2;  // 8px
  static const double xs = unit * 3;   // 12px
  
  // Small spacing
  static const double sm = unit * 4;   // 16px
  static const double md = unit * 5;   // 20px
  
  // Medium spacing (most common)
  static const double lg = unit * 6;   // 24px
  static const double xl = unit * 8;   // 32px
  
  // Large spacing
  static const double xxl = unit * 10; // 40px
  static const double xxxl = unit * 12; // 48px
  
  // Extra large spacing (for major sections)
  static const double huge = unit * 16; // 64px
  static const double massive = unit * 20; // 80px
  
  // Common edge insets
  static const screenPadding = lg; // 24px
  static const screenPaddingH = lg; // 24px horizontal
  static const screenPaddingV = xl; // 32px vertical
  
  static const cardPadding = md; // 20px
  static const cardMargin = sm; // 16px
  
  static const buttonPaddingH = lg; // 24px
  static const buttonPaddingV = sm; // 16px
  
  static const inputPaddingH = md; // 20px
  static const inputPaddingV = sm; // 16px
}

/// Border radius system
class AppRadius {
  AppRadius._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 28.0;
  static const double full = 9999.0; // Fully rounded
  
  // Common border radius
  static const double card = lg; // 16px
  static const double button = xxl; // 24px (pill-shaped)
  static const double input = md; // 12px
  static const double dialog = xl; // 20px
  static const double bottomSheet = xxl; // 24px
}

/// Icon sizes
class AppIconSize {
  AppIconSize._();
  
  static const double xxs = 12.0;
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 40.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Elevation system (for shadows)
class AppElevation {
  AppElevation._();
  
  static const double none = 0;
  static const double xs = 2;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
}
