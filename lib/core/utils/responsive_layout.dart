import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Helper utility implementing the responsive layout rules from Reference Image 2:
/// - Margins: 16px
/// - Gutters: 16px
/// - Columns: Stretch
/// - Dynamic platform safe-area handling with hardware cutout clearance
class ResponsiveLayout {
  ResponsiveLayout._();

  static const double standardMargin = AppSpacing.pageMargin; // 16px
  static const double standardGutter = AppSpacing.gutter;     // 16px

  /// Maximum readable content width on tablets and desktop screens
  static const double maxContentWidth = 640.0;

  /// Wraps content in standard 16px margins, centered on wider viewports,
  /// with guaranteed status bar and camera punch-hole/cutout clearance.
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
      // Determine physical hardware status bar height even if an ancestor Scaffold
      // consumed MediaQuery.padding.top.
      final paddingData = MediaQuery.paddingOf(context);
      final viewPaddingData = MediaQuery.viewPaddingOf(context);
      final rawHardwareTop = math.max(paddingData.top, viewPaddingData.top);

      // On Android edge-to-edge and modern iOS dynamic island devices, status bars
      // typically range from 28dp to 54dp. Guarantee safe clearance + comfortable breathing room.
      final safeTopMinimum = topSafeArea
          ? (rawHardwareTop > 0 ? (rawHardwareTop + 6.0) : 38.0)
          : 0.0;

      final safeBottomMinimum = bottomSafeArea
          ? math.max(paddingData.bottom, viewPaddingData.bottom)
          : 0.0;

      content = SafeArea(
        top: topSafeArea,
        bottom: bottomSafeArea,
        minimum: EdgeInsets.only(
          top: safeTopMinimum,
          bottom: safeBottomMinimum,
        ),
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
