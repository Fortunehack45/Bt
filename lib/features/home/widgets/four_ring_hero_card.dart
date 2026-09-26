import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/concentric_activity_rings.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/state/wellness_provider.dart';
import 'four_ring_activity_details_sheet.dart';

/// Top-level Hero Card on the Home Screen displaying the 4-concentric activity rings:
/// 1. Outer Ring: Steps walked (Orange)
/// 2. Second Ring: Water drank (Cyan)
/// 3. Third Ring: Sleep & Rest (Indigo)
/// 4. Inner Ring: Nutrition meals (Lime)
///
/// Tapping anywhere on the card slides up the comprehensive 7-day Activity Details sheet.
class FourRingHeroCard extends StatelessWidget {
  final VoidCallback? onTap;

  const FourRingHeroCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

    final ringsData = ActivityRingsData.fromValues(
      steps: provider.steps,
      stepGoal: provider.stepGoal,
      waterGlasses: provider.waterGlasses,
      waterGoal: provider.waterGoal,
      sleepHours: provider.sleepHours,
      sleepGoalHours: provider.sleepGoalHours,
      calories: provider.calories,
      targetCalories: provider.targetCalories,
    );

    final avgPercent = (ringsData.averageProgress * 100).toInt();

    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      onTap: () {
        HapticService.selection();
        if (onTap != null) {
          onTap!();
        } else {
          showFourRingActivityDetailsSheet(context, provider);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Section Header with status badge & total percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF26332A) : AppColors.primaryTint,
                      borderRadius: AppRadii.roundedPill,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 13, color: AppColors.primaryDark),
                        SizedBox(width: 4),
                        Text(
                          '4-DIMENSION VITALITY RINGS',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.roundedPill,
                ),
                child: Text(
                  '$avgPercent% Done',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Middle Row: Concentric Rings on Left, 4 Dimensions on Right
          Row(
            children: [
              // Concentric 4-Ring Visual Engine
              ConcentricActivityRings(
                data: ringsData,
                size: 138,
                strokeWidth: 10.5,
                ringGap: 4.2,
                showIcons: true,
              ),
              const SizedBox(width: 18),

              // 4 Dimension Telemetry Readouts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDimensionRow(
                      color: ConcentricActivityRings.stepsColor,
                      label: 'Steps',
                      value: '${provider.steps}',
                      goal: '${provider.stepGoal}',
                      unit: 'steps',
                      ratio: ringsData.stepsRatio,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildDimensionRow(
                      color: ConcentricActivityRings.waterColor,
                      label: 'Water',
                      value: '${provider.waterGlasses}',
                      goal: '${provider.waterGoal}',
                      unit: 'gl',
                      ratio: ringsData.waterRatio,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildDimensionRow(
                      color: ConcentricActivityRings.sleepColor,
                      label: 'Sleep',
                      value: provider.sleepHours > 0 ? provider.sleepHours.toStringAsFixed(1) : '0.0',
                      goal: provider.sleepGoalHours.toStringAsFixed(1),
                      unit: 'hrs',
                      ratio: ringsData.sleepRatio,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildDimensionRow(
                      color: ConcentricActivityRings.nutritionColor,
                      label: 'Nutrition',
                      value: '${provider.calories}',
                      goal: '${provider.targetCalories}',
                      unit: 'kcal',
                      ratio: ringsData.nutritionRatio,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Bottom Row: Interactive Details Affordance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Biometric Alignment',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Activity Details',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionRow({
    required Color color,
    required String label,
    required String value,
    required String goal,
    required String unit,
    required double ratio,
    required bool isDark,
  }) {
    final pct = (ratio * 100).toInt();

    return Row(
      children: [
        // Colored dot
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),

        // Label
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),

        // Numerical Value & Goal
        Expanded(
          child: Text(
            '$value / $goal $unit',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
            ),
          ),
        ),

        // Percent
        Text(
          '$pct%',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
