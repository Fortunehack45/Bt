import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';

import '../../../domain/state/wellness_provider.dart';

/// Fully interactive, dynamic weekly calendar strip matching Reference Image 1 Screen 1:
/// - Real dynamic month and year display
/// - Weekday columns (S M T W T F S) dynamically calculated from actual dates
/// - Interactive week pagination (< and >)
/// - Selected date highlighted in soft lime green pill
/// - Colored telemetry dots indicating logged health data
/// - 1-tap full calendar picker integration
class CalendarStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onOpenDatePicker;
  final DayTelemetryStatus Function(DateTime)? telemetryProvider;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onOpenDatePicker,
    this.telemetryProvider,
  });

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _dayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  /// Computes the 7 days of the week starting from Sunday containing the selected date.
  List<DateTime> _computeWeekDays(DateTime anchor) {
    // weekday in Dart is 1 (Mon) to 7 (Sun)
    final diffToSunday = anchor.weekday % 7;
    final sunday = anchor.subtract(Duration(days: diffToSunday));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final weekDays = _computeWeekDays(selectedDate);
    final monthName = _months[selectedDate.month - 1];
    final isViewingToday = _isSameDay(selectedDate, now);

    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          // Header with Month, Year, and Pagination Chevrons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onOpenDatePicker,
                child: Row(
                  children: [
                    Text(
                      '$monthName ${selectedDate.year}',
                      style: AppTypography.h3(isDark).copyWith(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  ],
                ),
              ),
              Row(
                children: [
                  if (!isViewingToday)
                    GestureDetector(
                      onTap: () {
                        HapticService.selection();
                        onDateSelected(now);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                          borderRadius: AppRadii.roundedPill,
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                  _buildNavArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: () {
                      HapticService.selection();
                      onPreviousWeek();
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildNavArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: () {
                      HapticService.selection();
                      onNextWeek();
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7-Day Interactive Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(weekDays.length, (index) {
              final dayDate = weekDays[index];
              final isSelected = _isSameDay(dayDate, selectedDate);
              final isToday = _isSameDay(dayDate, now);
              final dayLetter = _dayLetters[dayDate.weekday % 7];
              final dateNumber = dayDate.day.toString().padLeft(2, '0');

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticService.selection();
                  onDateSelected(dayDate);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.primary.withOpacity(0.28) : const Color(0xFFD6F57D))
                        : Colors.transparent,
                    borderRadius: AppRadii.roundedPill,
                    border: isSelected
                        ? Border.all(
                            color: isDark ? AppColors.primary : const Color(0xFFC4E968),
                            width: 1.2,
                          )
                        : (isToday
                            ? Border.all(
                                color: isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong,
                                width: 1.0,
                              )
                            : null),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayLetter,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (isDark ? AppColors.primaryLight : AppColors.textPrimaryLight)
                              : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dateNumber,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? (isDark ? AppColors.primaryLight : AppColors.textPrimaryLight)
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Mini telemetry dots under date
                      Builder(
                        builder: (_) {
                          final telemetry = telemetryProvider?.call(dayDate);
                          if (telemetry == null || !telemetry.hasAny) {
                            return const SizedBox(height: 4);
                          }
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (telemetry.hasNutrition)
                                Container(
                                  width: 3.5,
                                  height: 3.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 0.8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (telemetry.hasWater)
                                Container(
                                  width: 3.5,
                                  height: 3.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 0.8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2EB5FA),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (telemetry.hasActivity)
                                Container(
                                  width: 3.5,
                                  height: 3.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 0.8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF9442),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (telemetry.hasSleep)
                                Container(
                                  width: 3.5,
                                  height: 3.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 0.8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF818CF8),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          );
                        },
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
