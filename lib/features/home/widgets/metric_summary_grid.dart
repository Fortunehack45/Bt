import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/metric_badge.dart';
import '../../../core/widgets/solid_wellness_card.dart';

/// The dual-metric row on Home matching Reference Image 1 Screen 1:
/// - "Step to walk" (orange footprint badge, 5,500 steps)
/// - "Drink Water" (blue droplet badge, 12 glass)
class MetricSummaryGrid extends StatelessWidget {
  final int steps;
  final int waterGlasses;
  final VoidCallback onStepsTap;
  final VoidCallback onWaterTap;

  const MetricSummaryGrid({
    super.key,
    required this.steps,
    required this.waterGlasses,
    required this.onStepsTap,
    required this.onWaterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Steps Card
        Expanded(
          child: SolidWellnessCard(
            onTap: onStepsTap,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step to\nwalk',
                      style: AppTypography.bodyMedium(isDark).copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const MetricBadge(
                      icon: Icons.directions_walk_rounded,
                      color: AppColors.stepsOrange,
                      backgroundColor: AppColors.stepsOrangeTint,
                      size: 34,
                      iconSize: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    children: [
                      TextSpan(
                        text: _formatNumber(steps),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: ' steps',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.gutter),

        // Water Card
        Expanded(
          child: SolidWellnessCard(
            onTap: onWaterTap,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Drink\nWater',
                      style: AppTypography.bodyMedium(isDark).copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const MetricBadge(
                      icon: Icons.water_drop_rounded,
                      color: AppColors.waterBlue,
                      backgroundColor: AppColors.waterBlueTint,
                      size: 34,
                      iconSize: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    children: [
                      TextSpan(
                        text: '$waterGlasses',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: ' glass',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final s = number.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return number.toString();
  }
}
