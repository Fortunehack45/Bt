import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';

class CalendarDayItem {
  final String dayLetter; // S, M, T, W, T, F, S
  final String dateNumber; // 07, 08, 09, 10, 11, 12, 13

  const CalendarDayItem({
    required this.dayLetter,
    required this.dateNumber,
  });
}

/// Interactive weekly calendar strip matching Reference Image 1 Screen 1:
/// - "August 2025" with left/right pagination
/// - Weekday columns (S M T W T F S)
/// - Selected date highlighted in soft lime green pill
class CalendarStrip extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const CalendarStrip({
    super.key,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  static const List<CalendarDayItem> days = [
    CalendarDayItem(dayLetter: 'S', dateNumber: '07'),
    CalendarDayItem(dayLetter: 'M', dateNumber: '08'),
    CalendarDayItem(dayLetter: 'T', dateNumber: '09'),
    CalendarDayItem(dayLetter: 'W', dateNumber: '10'),
    CalendarDayItem(dayLetter: 'T', dateNumber: '11'),
    CalendarDayItem(dayLetter: 'F', dateNumber: '12'),
    CalendarDayItem(dayLetter: 'S', dateNumber: '13'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      child: Column(
        children: [
          // Header with Month and Pagination Chevrons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'August 2025',
                style: AppTypography.h3(isDark).copyWith(fontSize: 16),
              ),
              Row(
                children: [
                  _buildNavArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => HapticService.selection(),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildNavArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => HapticService.selection(),
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 7-Day Interactive Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (index) {
              final isSelected = index == selectedIndex;
              final day = days[index];

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticService.selection();
                  onDaySelected(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.primary.withOpacity(0.25) : const Color(0xFFD6F57D))
                        : Colors.transparent,
                    borderRadius: AppRadii.roundedPill,
                    border: isSelected
                        ? Border.all(
                            color: isDark ? AppColors.primary : const Color(0xFFC4E968),
                            width: 1.0,
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        day.dayLetter,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (isDark ? AppColors.primaryLight : AppColors.textPrimaryLight)
                              : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day.dateNumber,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? (isDark ? AppColors.primaryLight : AppColors.textPrimaryLight)
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavArrow({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}
