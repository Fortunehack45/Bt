import 'package:flutter/material.dart';

/// Centralized animation durations and curves for smooth 60 FPS transitions.
class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration sheet = Duration(milliseconds: 340);
  static const Duration progress = Duration(milliseconds: 900);
  static const Duration pulse = Duration(milliseconds: 1400);

  // Curves
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve fluid = Curves.easeOutQuart;
  static const Curve spring = Curves.easeOutBack;
}
