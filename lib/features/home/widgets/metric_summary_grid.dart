import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/metric_badge.dart';
import '../../../core/widgets/solid_wellness_card.dart';

/// 2x2 Wellness Metric Grid on Home providing instant access to all core dimensions:
/// - Step to walk
/// - Drink Water
/// - Sleep & Rest
/// - Energy Intake (Nutrition)
class MetricSummaryGrid extends StatelessWidget {
  final int steps;
  final int waterGlasses;
  final double sleepHours;
  final int calories;
  final VoidCallback onStepsTap;
  final VoidCallback onWaterTap;
  final VoidCallback onSleepTap;
  final VoidCallback onNutritionTap;

  const MetricSummaryGrid({
    super.key,
    required this.steps,
    required this.waterGlasses,
    required this.sleepHours,
    required this.calories,
    required this.onStepsTap,
    required this.onWaterTap,
    required this.onSleepTap,
    required this.onNutritionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Row 1: Steps & Water
        Row(
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
                    const SizedBox(height: 16),
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
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' steps',
                            style: TextStyle(
                              fontSize: 12,
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
                    const SizedBox(height: 16),
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
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' glass',
                            style: TextStyle(
                              fontSize: 12,
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
        ),
        const SizedBox(height: AppSpacing.sm),

        // Row 2: Sleep & Nutrition
        Row(
          children: [
            // Sleep Card
            Expanded(
              child: SolidWellnessCard(
                onTap: onSleepTap,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sleep &\nRest',
                          style: AppTypography.bodyMedium(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        const MetricBadge(
                          icon: Icons.bedtime_rounded,
                          color: AppColors.sleepPurple,
                          backgroundColor: AppColors.sleepPurpleTint,
                          size: 34,
                          iconSize: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        children: [
                          TextSpan(
                            text: sleepHours.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' hrs',
                            style: TextStyle(
                              fontSize: 12,
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

            // Nutrition Card
            Expanded(
              child: SolidWellnessCard(
                onTap: onNutritionTap,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nutrition\nMeals',
                          style: AppTypography.bodyMedium(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        const MetricBadge(
                          icon: Icons.restaurant_rounded,
                          color: AppColors.nutritionGold,
                          backgroundColor: AppColors.nutritionGoldTint,
                          size: 34,
                          iconSize: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        children: [
                          TextSpan(
                            text: '$calories',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' kcal',
                            style: TextStyle(
                              fontSize: 12,
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
