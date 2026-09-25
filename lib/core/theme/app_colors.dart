import 'package:flutter/material.dart';

/// Centralized color palette for the AuraPulse Wellness application.
/// Inspired by the fresh, high-contrast, calm aesthetic in Reference Image 1.
class AppColors {
  AppColors._();

  // Primary Brand - Fresh Lime Wellness Green
  static const Color primary = Color(0xFF92DF2B);
  static const Color primaryDark = Color(0xFF78C01E);
  static const Color primaryLight = Color(0xFFAEF04E);
  static const Color primaryTint = Color(0xFFEFFCD8); // Soft hero card wash
  static const Color primaryTintLight = Color(0xFFF6FDEE);

  // Functional & Metric Accents
  static const Color stepsOrange = Color(0xFFFF9442);
  static const Color stepsOrangeTint = Color(0xFFFFF2E8);

  static const Color waterBlue = Color(0xFF2EB5FA);
  static const Color waterBlueTint = Color(0xFFE8F7FF);

  static const Color heartRed = Color(0xFFFF5252);
  static const Color heartRedTint = Color(0xFFFFECEC);

  static const Color exerciseGreen = Color(0xFF10B981);
  static const Color exerciseGreenTint = Color(0xFFE8FAF2);

  static const Color sleepPurple = Color(0xFF818CF8);
  static const Color sleepPurpleTint = Color(0xFFEEF0FE);

  static const Color nutritionGold = Color(0xFFF59E0B);
  static const Color nutritionGoldTint = Color(0xFFFEF7EA);

  // Light Mode Surfaces & Neutrals
  static const Color lightBackground = Color(0xFFF7F9F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF2F4F3);
  static const Color lightBorder = Color(0xFFE8ECE9);
  static const Color lightBorderStrong = Color(0xFFD6DED9);

  // Light Mode Typography
  static const Color textPrimaryLight = Color(0xFF141917);
  static const Color textSecondaryLight = Color(0xFF737A76);
  static const Color textMutedLight = Color(0xFF9BA29E);

  // Dark Mode Surfaces & Neutrals
  static const Color darkBackground = Color(0xFF0F1412);
  static const Color darkSurface = Color(0xFF1A211E);
  static const Color darkSurfaceSubtle = Color(0xFF222B27);
  static const Color darkBorder = Color(0xFF29352F);
  static const Color darkBorderStrong = Color(0xFF38463F);

  // Dark Mode Typography
  static const Color textPrimaryDark = Color(0xFFF4F7F5);
  static const Color textSecondaryDark = Color(0xFF9AA39E);
  static const Color textMutedDark = Color(0xFF6B746F);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
