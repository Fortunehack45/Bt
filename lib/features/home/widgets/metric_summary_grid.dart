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
                          'Daily\nSteps',
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
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 8),
                    _buildProgressBar(
                      progress: (steps / 10000.0).clamp(0.0, 1.0),
                      color: AppColors.stepsOrange,
                      isDark: isDark,
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
                          'Daily\nHydration',
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
                    const SizedBox(height: 14),
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
                            text: ' glasses',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildProgressBar(
                      progress: (waterGlasses / 8.0).clamp(0.0, 1.0),
                      color: AppColors.waterBlue,
                      isDark: isDark,
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
                          'Rest &\nRecovery',
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
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 8),
                    _buildProgressBar(
                      progress: (sleepHours / 8.0).clamp(0.0, 1.0),
                      color: AppColors.sleepPurple,
                      isDark: isDark,
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
                          'Nutrition\nEnergy',
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
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 8),
                    _buildProgressBar(
                      progress: (calories / 2000.0).clamp(0.0, 1.0),
                      color: AppColors.nutritionGold,
                      isDark: isDark,
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

  Widget _buildProgressBar({
    required double progress,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      height: 4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF233025) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
