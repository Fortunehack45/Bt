import 'package:flutter/material.dart';

/// Design tokens specifically tailored for Platform-Adaptive Glass UI.
/// Strict separation:
/// - Android: Frosted glass (blur 16, soft diffused tint, subtle borders, gentle elevation)
/// - iOS: Liquid-glass-inspired (blur 24, specular layered highlights, dynamic depth, squircle curvature)
class GlassTokens {
  GlassTokens._();

  // Blur Sigmas
  static const double androidBlurSigma = 16.0;
  static const double iosBlurSigma = 24.0;

  // Android Frosted Surface Colors
  static Color androidLightBackground = Colors.white.withOpacity(0.78);
  static Color androidDarkBackground = const Color(0xFF161C19).withOpacity(0.82);

  static Color androidLightBorder = Colors.white.withOpacity(0.55);
  static Color androidDarkBorder = const Color(0xFF2A3630).withOpacity(0.65);

  // iOS Liquid Glass Gradient Stops & Surface Tints
  static List<Color> iosLightGradient = [
    Colors.white.withOpacity(0.92),
    Colors.white.withOpacity(0.78),
    Colors.white.withOpacity(0.65),
    Colors.white.withOpacity(0.72),
  ];

  static List<Color> iosDarkGradient = [
    const Color(0xFF26332C).withOpacity(0.92),
    const Color(0xFF1E2822).withOpacity(0.82),
    const Color(0xFF141A17).withOpacity(0.70),
    const Color(0xFF1B231F).withOpacity(0.80),
  ];

  // iOS Specular Highlight Border
  static List<Color> iosLightBorderGradient = [
    Colors.white.withOpacity(0.90),
    Colors.white.withOpacity(0.35),
  ];

  static List<Color> iosDarkBorderGradient = [
    Colors.white.withOpacity(0.30),
    Colors.white.withOpacity(0.08),
  ];

  // Button Glass Surface
  static Color buttonLightSurface = Colors.white.withOpacity(0.82);
  static Color buttonDarkSurface = const Color(0xFF222B27).withOpacity(0.80);
}
