import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Premium shadow system for depth and elevation
class AppShadows {
  AppShadows._();
  
  // Subtle shadows for cards and surfaces
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 12,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 4,
      offset: const Offset(0, 1),
      spreadRadius: -1,
    ),
  ];
  
  // Medium shadow for elevated elements
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: -2,
    ),
  ];
  
  // Strong shadow for modals and dialogs
  static List<BoxShadow> get modalShadow => [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 32,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: -4,
    ),
  ];
  
  // Button shadow
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  // Floating action button shadow
  static List<BoxShadow> get fabShadow => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: -4,
    ),
  ];
  
  // Inner shadow effect (using light color on top)
  static List<BoxShadow> get innerGlow => [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.8),
      blurRadius: 2,
      offset: const Offset(0, -1),
      spreadRadius: 0,
    ),
  ];
  
  // Colored shadows for special elements
  static List<BoxShadow> pinkShadow = [
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> purpleShadow = [
    BoxShadow(
      color: AppColors.gradientStart.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> greenShadow = [
    BoxShadow(
      color: AppColors.success.withValues(alpha: 0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
}
