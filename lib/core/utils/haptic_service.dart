import 'package:flutter/services.dart';

/// Provides consistent, deeply satisfying haptic feedback for user interactions
/// across both iOS (Taptic Engine) and Android (Haptic Actuator).
class HapticService {
  HapticService._();

  /// Subtle micro-haptic for slider drags, step changes, and scroll notches
  static Future<void> tick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Crisp selection feedback for tab changes, chip toggles, and radio buttons
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Gentle touch confirmation for cards, buttons, and light actions
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Solid tactile thud for primary CTA button presses and modal launches
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Deep mechanical feedback for destructive or high-impact state switches
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Satisfying rhythmic double-tap for goal achievements and habit checks
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 90));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Rhythmic multi-tap celebration for completing onboarding or reaching a milestone
  static Future<void> celebrate() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.lightImpact();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Warning haptic pattern for invalid inputs or date boundary limits
  static Future<void> warning() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
