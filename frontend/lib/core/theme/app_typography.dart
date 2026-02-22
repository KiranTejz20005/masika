import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium typography system for Masika app
/// Using Google Fonts for elegant, readable typography
class AppTypography {
  AppTypography._();
  
  // Base font families
  static String get primaryFont => 'Plus Jakarta Sans';
  static String get secondaryFont => 'Playfair Display';

  /// Font family string for ThemeData.fontFamily and TextSpan usage
  static String get fontFamily =>
      GoogleFonts.plusJakartaSans().fontFamily ?? 'Plus Jakarta Sans';
  
  /// Display text styles - Used for largest text (hero sections)
  static TextStyle displayLarge = GoogleFonts.plusJakartaSans(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.1,
  );
  
  static TextStyle displayMedium = GoogleFonts.plusJakartaSans(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.1,
  );
  
  static TextStyle displaySmall = GoogleFonts.plusJakartaSans(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  /// Headline text styles - Used for section headings
  static TextStyle headlineLarge = GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );
  
  static TextStyle headlineMedium = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static TextStyle headlineSmall = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  /// Screen / app bar title - Same font as Screening heading (black in theme)
  static TextStyle get screenTitle => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.3,
  );

  /// Nav bar label - Plus Jakarta Sans, compact, no overflow (FittedBox in shell)
  static TextStyle get navBarLabel => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.2,
  );

  /// Title text styles - Used for card titles, screen titles
  static TextStyle titleLarge = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static TextStyle titleMedium = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
  );
  
  static TextStyle titleSmall = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  /// Body text styles - Used for main content
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  /// Label text styles - Used for labels, captions
  static TextStyle labelLarge = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.4,
  );
  
  static TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.4,
  );
  
  static TextStyle labelSmall = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.3,
  );
  
  /// Button text styles
  static TextStyle buttonLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
  );
  
  static TextStyle buttonMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
  );
  
  static TextStyle buttonSmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
  );
  
  /// Caption text styles - Used for small secondary text
  static TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.3,
  );
  
  /// Overline text styles - Used for category labels
  static TextStyle overline = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    height: 1.2,
  );
  
  /// Decorative text styles - Using secondary font
  static TextStyle decorativeLarge = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static TextStyle decorativeMedium = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static TextStyle decorativeSmall = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.2,
    height: 1.3,
  );
}
