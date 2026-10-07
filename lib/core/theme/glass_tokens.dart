import 'package:flutter/material.dart';

/// Design tokens specifically tailored for Platform-Adaptive Glass UI.
/// Strict separation:
/// - Android: Frosted glass (blur 16, soft diffused tint, subtle borders, gentle elevation)
/// - iOS: Liquid-glass-inspired (blur 24, specular layered highlights, dynamic depth, squircle curvature)
class GlassTokens {
  GlassTokens._();

  // Blur Sigmas
  static const double androidBlurSigma = 16.0; // Preserved for legacy token tests
  static const double iosBlurSigma = 24.0;
  static const double liquidBlurSigma = 24.0; // Unified liquid glass blur across Android & iOS

  // Android Frosted Surface Colors (Upgraded with liquid translucency)
  static Color androidLightBackground = Colors.white.withOpacity(0.85);
  static Color androidDarkBackground = const Color(0xFF1E2822).withOpacity(0.85);

  static Color androidLightBorder = Colors.white.withOpacity(0.65);
  static Color androidDarkBorder = const Color(0xFF2E3D34).withOpacity(0.70);

  // Unified Liquid Glass Gradient Stops & Surface Tints (iOS & Android)
  static List<Color> liquidLightGradient = [
    Colors.white.withOpacity(0.92),
    Colors.white.withOpacity(0.78),
    Colors.white.withOpacity(0.65),
    Colors.white.withOpacity(0.72),
  ];

  static List<Color> liquidDarkGradient = [
    const Color(0xFF26332C).withOpacity(0.92),
    const Color(0xFF1E2822).withOpacity(0.82),
    const Color(0xFF141A17).withOpacity(0.70),
    const Color(0xFF1B231F).withOpacity(0.80),
  ];

  // Liquid Specular Highlight Border
  static List<Color> liquidLightBorderGradient = [
    Colors.white.withOpacity(0.90),
    Colors.white.withOpacity(0.35),
  ];

  static List<Color> liquidDarkBorderGradient = [
    Colors.white.withOpacity(0.30),
    Colors.white.withOpacity(0.08),
  ];

  // iOS Legacy Token Aliases (Referencing unified liquid glass tokens)
  static List<Color> get iosLightGradient => liquidLightGradient;
  static List<Color> get iosDarkGradient => liquidDarkGradient;
  static List<Color> get iosLightBorderGradient => liquidLightBorderGradient;
  static List<Color> get iosDarkBorderGradient => liquidDarkBorderGradient;

  // Button Glass Surface
  static Color buttonLightSurface = Colors.white.withOpacity(0.85);
  static Color buttonDarkSurface = const Color(0xFF222B27).withOpacity(0.82);
}
