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
          // 1. Top Section Header with clean title & total percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  letterSpacing: -0.3,
                ),
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
          const SizedBox(height: 14),

          // 2. Middle Row: Concentric Rings on Left, 4 Dimensions on Right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Concentric 4-Ring Visual Engine
              ConcentricActivityRings(
                data: ringsData,
                size: 130,
                strokeWidth: 9.2,
                ringGap: 3.8,
                showIcons: true,
              ),
              const SizedBox(width: 16),

              // 4 Dimension Telemetry Readouts (No Line Breaking)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDimensionRow(
                      color: ConcentricActivityRings.stepsColor,
                      label: 'Steps',
                      value: _formatNumber(provider.steps),
                      goal: _formatNumber(provider.stepGoal),
                      unit: 'steps',
                      ratio: ringsData.stepsRatio,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 7),
                    _buildDimensionRow(
                      color: ConcentricActivityRings.waterColor,
                      label: 'Water',
                      value: '${provider.waterGlasses}',
                      goal: '${provider.waterGoal}',
                      unit: 'gl',
                      ratio: ringsData.waterRatio,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 7),
                    _buildDimensionRow(
                      color: ConcentricActivityRings.sleepColor,
                      label: 'Sleep',
                      value: provider.sleepHours > 0 ? provider.sleepHours.toStringAsFixed(1) : '0.0',
                      goal: provider.sleepGoalHours.toStringAsFixed(1),
                      unit: 'hrs',
                      ratio: ringsData.sleepRatio,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 7),
                    _buildDimensionRow(
                      color: ConcentricActivityRings.nutritionColor,
                      label: 'Nutrition',
                      value: _formatNumber(provider.calories),
                      goal: _formatNumber(provider.targetCalories),
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
                    size: 10,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Line: Dot + Label (left) & Percentage (right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            Text(
              '$pct%',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1.5),

        // Bottom Line: Value / Goal Unit (aligned, no wrap)
        Padding(
          padding: const EdgeInsets.only(left: 13.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                TextSpan(
                  text: ' / $goal $unit',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatNumber(int val) {
    if (val >= 1000) {
      final s = val.toString();
      final thousands = s.substring(0, s.length - 3);
      final rest = s.substring(s.length - 3);
      return '$thousands,$rest';
    }
    return val.toString();
  }
}
