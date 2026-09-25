import 'package:flutter/material.dart';

/// Centralized elevation shadows for solid cards and floating glass UI.
class AppShadows {
  AppShadows._();

  // Subtle clean card shadow for light mode
  static List<BoxShadow> card(bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(0xFF141917).withOpacity(0.04),
        blurRadius: 18,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: const Color(0xFF141917).withOpacity(0.02),
        blurRadius: 6,
        spreadRadius: 0,
        offset: const Offset(0, 1),
      ),
    ];
  }

  // Floating Glass Bar & Sheet Shadows
  static List<BoxShadow> floatingGlass({required bool isDark, required bool isIos}) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.45),
          blurRadius: isIos ? 28 : 20,
          spreadRadius: -2,
          offset: const Offset(0, 10),
        ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(0xFF141917).withOpacity(isIos ? 0.08 : 0.06),
        blurRadius: isIos ? 28 : 20,
        spreadRadius: -2,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: const Color(0xFF141917).withOpacity(0.03),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  // Central FAB Soft Wellness Glow
  static List<BoxShadow> fabGlow = [
    BoxShadow(
      color: const Color(0xFF92DF2B).withOpacity(0.38),
      blurRadius: 20,
      spreadRadius: 1,
      offset: const Offset(0, 8),
    ),
  ];
}
