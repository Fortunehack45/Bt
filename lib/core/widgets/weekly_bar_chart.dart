import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/haptic_service.dart';

class DayBarData {
  final String dayName;
  final int percentage;
  final int value;

  const DayBarData({
    required this.dayName,
    required this.percentage,
    required this.value,
  });
}

/// Interactive weekly bar chart matching Reference Image 1 Screen 2.
/// - Shows percentage badges above bars
/// - Highlights selected day in solid vibrant wellness green
/// - Muted striped/tinted bars for other days
/// - Fully interactive with haptic feedback
class WeeklyBarChart extends StatelessWidget {
  final List<DayBarData> days;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const WeeklyBarChart({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      height: 220,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(days.length, (index) {
          final isSelected = index == selectedIndex;
          final item = days[index];
          // Normalized height factor (max 120% = 1.0)
          final heightFactor = (item.percentage / 120.0).clamp(0.12, 1.0);

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticService.selection();
                onDaySelected(index);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Percentage Label Above Bar
                  Text(
                    '${item.percentage}%',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? AppColors.primaryLight : AppColors.textPrimaryLight)
                          : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Animated Vertical Bar
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: heightFactor),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutCubic,
                        builder: (context, factor, child) {
                          return FractionallySizedBox(
                            heightFactor: factor,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: isSelected ? 16 : 14,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? const Color(0xFF2C3932)
                                        : const Color(0xFFE2EED4)),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                                        width: 1.2,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Weekday Label (Mon, Tue, Wed, etc.)
                  Text(
                    item.dayName,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                          : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
