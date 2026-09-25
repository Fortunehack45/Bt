import 'package:flutter/services.dart';

/// Provides consistent, gentle haptic feedback for user interactions
/// such as habit completion, water logging, and navigation selection.
class HapticService {
  HapticService._();

  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 90));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }
}
