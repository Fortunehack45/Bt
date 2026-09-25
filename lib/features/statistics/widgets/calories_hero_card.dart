import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../core/widgets/weekly_bar_chart.dart';

/// Calorie breakdown card housing the weekly bar chart.
/// Directly matches Reference Image 1 Screen 2:
/// - "Calories" label
/// - "1250 Kcal" bold display
/// - "Target: 1920 Kcal"
/// - Weekly bar chart with percentage badges
class CaloriesHeroCard extends StatelessWidget {
  final int calories;
  final int targetCalories;
  final List<DayBarData> barData;
  final int selectedDayIndex;
  final ValueChanged<int> onDaySelected;
  final VoidCallback? onTap;

  const CaloriesHeroCard({
    super.key,
    required this.calories,
    required this.targetCalories,
    required this.barData,
    required this.selectedDayIndex,
    required this.onDaySelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle "Calories" with optional arrow to Nutrition Hub
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calories',
                style: AppTypography.caption(isDark).copyWith(fontSize: 13),
              ),
              if (onTap != null)
                GestureDetector(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nutrition Hub',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primaryDark),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Main Metric Row: "1250 Kcal" and "Target: 1920 Kcal"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  children: [
                    TextSpan(
                      text: '$calories ',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Kcal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Target: $targetCalories Kcal',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Interactive Weekly Bar Chart
          WeeklyBarChart(
            days: barData,
            selectedIndex: selectedDayIndex,
            onDaySelected: onDaySelected,
          ),
        ],
      ),
    );
  }
}
