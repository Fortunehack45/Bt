import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Helper utility implementing the responsive layout rules from Reference Image 2:
/// - Margins: 16px
/// - Gutters: 16px
/// - Columns: Stretch
/// - Dynamic platform safe-area handling
class ResponsiveLayout {
  ResponsiveLayout._();

  static const double standardMargin = AppSpacing.pageMargin; // 16px
  static const double standardGutter = AppSpacing.gutter;     // 16px

  /// Maximum readable content width on tablets and desktop screens
  static const double maxContentWidth = 640.0;

  /// Wraps content in standard 16px margins, centered on wider viewports
  static Widget pageContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    bool topSafeArea = true,
    bool bottomSafeArea = false,
  }) {
    Widget content = Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: standardMargin),
      child: child,
    );

    content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: content,
      ),
    );

    if (topSafeArea || bottomSafeArea) {
      content = SafeArea(
        top: topSafeArea,
        bottom: bottomSafeArea,
        child: content,
      );
    }

    return content;
  }

  /// Calculates item width for a 2-column grid obeying 16px margins & 16px gutter
  static double twoColumnWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boundedWidth = screenWidth > maxContentWidth ? maxContentWidth : screenWidth;
    final available = boundedWidth - (standardMargin * 2) - standardGutter;
    return available / 2;
  }
}
