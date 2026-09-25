import 'package:flutter/material.dart';

/// Centralized spacing system adhering strictly to the 16px grid guideline
/// shown in Reference Image 2 (Margins: 16px, Gutters: 16px).
class AppSpacing {
  AppSpacing._();

  // Reference Image 2 Core Grid Standards
  static const double pageMargin = 16.0;
  static const double gutter = 16.0;

  // Base Spacing Scale
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  // Element Specific Heights & Insets
  static const double floatingNavHeight = 68.0;
  static const double floatingNavBottomPadding = 12.0;
  static const double iconButtonSize = 44.0;
  static const double centralFabSize = 56.0;

  // EdgeInsets Helpers
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: pageMargin);
  static const EdgeInsets cardPadding = EdgeInsets.all(18.0);
  static const EdgeInsets compactCardPadding = EdgeInsets.all(14.0);
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0);
  static const EdgeInsets pillButtonPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0);

  /// Bottom safe padding to ensure scrolling content never collides with
  /// the floating glass navigation bar.
  static double contentBottomPadding(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return floatingNavHeight + floatingNavBottomPadding + (bottomInset > 0 ? bottomInset : 16.0) + 16.0;
  }
}
