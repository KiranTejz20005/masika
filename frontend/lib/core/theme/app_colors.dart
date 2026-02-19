import 'package:flutter/material.dart';

/// Premium color palette for Masika menstrual wellness app
/// Warm, calming, and supportive color scheme
class AppColors {
  AppColors._();

  // Primary Brand Colors - Burgundy/Rose Theme
  static const primary = Color(0xFF8B1538); // Deep burgundy
  static const primaryLight = Color(0xFFA84B6F); // Lighter burgundy
  static const primaryDark = Color(0xFF6B1028); // Darker burgundy
  
  // Secondary Colors - Warm Pinks
  static const secondary = Color(0xFFFF6B9D); // Vibrant pink
  static const secondaryLight = Color(0xFFFFB5D5); // Light pink
  static const secondaryDark = Color(0xFFE94B6F); // Deep pink
  
  // Accent Colors
  static const accent = Color(0xFFEAA0B7); // Soft rose
  static const accentLight = Color(0xFFF5C5D8); // Light rose
  
  // Background Colors
  static const background = Color(0xFFFAF8F9); // Off-white with pink tint
  static const backgroundLight = Color(0xFFFFFBFC); // Almost white
  static const surface = Color(0xFFFFFFFF); // Pure white
  static const surfaceVariant = Color(0xFFF5F3F4); // Light gray-pink
  
  // Text Colors
  static const textPrimary = Color(0xFF1A1A1A); // Near black
  static const textSecondary = Color(0xFF757575); // Medium gray
  static const textTertiary = Color(0xFF9E9E9E); // Light gray
  static const textDisabled = Color(0xFFBDBDBD); // Disabled gray
  static const textOnPrimary = Color(0xFFFFFFFF); // White
  
  // Functional Colors
  static const success = Color(0xFF2E7D32); // Green
  static const successLight = Color(0xFFC1E8D7); // Light green
  static const warning = Color(0xFFFF9800); // Orange
  static const warningLight = Color(0xFFFFE4CC); // Light orange
  static const error = Color(0xFFD32F2F); // Red
  static const errorLight = Color(0xFFFFCDD2); // Light red
  static const info = Color(0xFF1976D2); // Blue
  static const infoLight = Color(0xFFBBDEFB); // Light blue
  
  // Phase Colors (for cycle tracking)
  static const phaseFollicular = Color(0xFFE8D4F8); // Light purple
  static const phaseOvulation = Color(0xFFFFF4CC); // Light yellow
  static const phaseLuteal = Color(0xFFFFE8EE); // Light pink
  static const phaseMenstrual = Color(0xFFFFCDD2); // Light red
  
  // Gradient Colors
  static const gradientStart = Color(0xFFB8A4F5); // Purple
  static const gradientEnd = Color(0xFFA89FF5); // Darker purple
  static const gradientPinkStart = Color(0xFFFFB5D5); // Light pink
  static const gradientPinkEnd = Color(0xFFFF6B9D); // Vibrant pink
  
  // Border & Divider Colors
  static const border = Color(0xFFE8E5E6); // Light gray border
  static const borderLight = Color(0xFFF0F0F0); // Very light border
  static const divider = Color(0xFFE0E0E0); // Divider
  
  // Overlay Colors
  static const overlay = Color(0x0D000000); // 5% black
  static const overlayMedium = Color(0x1F000000); // 12% black
  static const overlayHigh = Color(0x33000000); // 20% black
  
  // Shadow Colors
  static const shadowLight = Color(0x0D000000); // Light shadow
  static const shadowMedium = Color(0x1F000000); // Medium shadow
  static const shadowDark = Color(0x33000000); // Dark shadow
  
  // Special Colors
  static const shimmerBase = Color(0xFFF0F0F0);
  static const shimmerHighlight = Color(0xFFFAFAFA);

  // ─── Semantic UI (single source of truth for feature screens) ─────────────────
  // Use these instead of local const to avoid duplication. Values match existing UI.
  static const semanticMaroon = Color(0xFF6C102C);       // Doctor portal primary
  static const semanticMaroonNav = Color(0xFF8D2D3B);    // Patient nav active
  static const semanticMaroonWelcome = Color(0xFF8C1D3F); // Welcome / auth primary
  static const semanticBgScreen = Color(0xFFF8F7F5);
  static const semanticBgAlt = Color(0xFFF5F5F5);
  static const semanticBgBottom = Color(0xFFF8F8F8);
  static const semanticCardBg = Color(0xFFFFFFFF);
  static const semanticSectionGray = Color(0xFF9E9E9E);
  static const semanticLabelGray = Color(0xFF4B4B4B);
  static const semanticInputBg = Color(0xFFF0EFEF);
  static const semanticNavInactive = Color(0xFF7A8BA8);
  static const semanticTextMuted = Color(0xFF6B6B6B);
  static const semanticTitle = Color(0xFF1A1A1A);
  static const semanticOnlineGreen = Color(0xFF4CAF50);
  static const semanticBubbleGray = Color(0xFFE8E8E8);
  static const semanticFertilePink = Color(0xFFFFB6C1);
  static const semanticRoutineBrown = Color(0xFF8D6E63);
  static const semanticTeal = Color(0xFF00695C);
  static const semanticTealLight = Color(0xFFB2DFDB);
  static const semanticRegisterInactive = Color(0xFFB47C8B);
  static const semanticNavBarBg = Color(0xFFEEEEEE);
}

/// Gradient definitions for premium UI effects
class AppGradients {
  AppGradients._();
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientStart,
      AppColors.gradientEnd,
    ],
  );
  
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientPinkStart,
      AppColors.gradientPinkEnd,
    ],
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surface,
      AppColors.surfaceVariant,
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
      AppColors.backgroundLight,
    ],
  );
}
