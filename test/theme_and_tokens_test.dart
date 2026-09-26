import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnest/core/theme/app_colors.dart';
import 'package:wellnest/core/theme/app_radii.dart';
import 'package:wellnest/core/theme/app_spacing.dart';
import 'package:wellnest/core/theme/glass_tokens.dart';

void main() {
  group('Biothrix Design Tokens Verification', () {
    test('Reference Image 2 16px Grid Guideline Check', () {
      expect(AppSpacing.pageMargin, 16.0);
      expect(AppSpacing.gutter, 16.0);
    });

    test('Wellness Accent Colors Check', () {
      // Primary fresh wellness lime green
      expect(AppColors.primary, const Color(0xFF92DF2B));
      expect(AppColors.waterBlue, const Color(0xFF2EB5FA));
      expect(AppColors.stepsOrange, const Color(0xFFFF9442));
      expect(AppColors.heartRed, const Color(0xFFFF5252));
      expect(AppColors.lightSurfaceElevated, const Color(0xFFF2F4F3));
    });

    test('Radii and Geometry Check', () {
      expect(AppRadii.card, 24.0);
      expect(AppRadii.navigation, 32.0);
      expect(AppRadii.sheet, 32.0);
    });

    test('Platform Glass Tokens Distinct Sigma Check', () {
      // Android frosted glass vs iOS liquid glass
      expect(GlassTokens.androidBlurSigma, 16.0);
      expect(GlassTokens.iosBlurSigma, 24.0);
    });
  });
}
