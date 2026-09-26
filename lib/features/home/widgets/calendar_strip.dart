import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/models/wellness_models.dart';
import '../../../domain/state/wellness_provider.dart';

/// Interactive, platform-adaptive weekly calendar strip with seamless
/// in-place Day Details flip:
/// - Week View: Month & Year, week pagination, day pills with telemetry dots
/// - Day Details View: In-place transition showing daily telemetry breakdown
///   (Steps, Water, Calories, Sleep/Heart) WITHOUT changing container height
/// - 1-tap return button to week view
class CalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onOpenDatePicker;
  final DayTelemetryStatus Function(DateTime)? telemetryProvider;
  final DaySnapshot Function(DateTime)? snapshotProvider;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onOpenDatePicker,
    this.telemetryProvider,
    this.snapshotProvider,
  });

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  bool _isDetailsView = false;

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> _dayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  List<DateTime> _computeWeekDays(DateTime anchor) {
    final diffToSunday = anchor.weekday % 7;
    final sunday = anchor.subtract(Duration(days: diffToSunday));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDayDetailsTitle(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));

    final dayName = _dayNames[date.weekday % 7];
    final monthShort = _monthsShort[date.month - 1];

    if (_isSameDay(date, now)) {
      return 'Today, $monthShort ${date.day}';
    } else if (_isSameDay(date, yesterday)) {
      return 'Yesterday, $monthShort ${date.day}';
    } else if (_isSameDay(date, tomorrow)) {
      return 'Tomorrow, $monthShort ${date.day}';
    }
    return '$dayName, $monthShort ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.04),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _isDetailsView
            ? _buildDayDetailsView(isDark)
            : _buildWeekView(isDark),
      ),
    );
  }

  /// 1. Standard Weekly Calendar Strip View (Fixed Inner Height: 112px)
  Widget _buildWeekView(bool isDark) {
    final now = DateTime.now();
    final weekDays = _computeWeekDays(widget.selectedDate);
    final monthName = _months[widget.selectedDate.month - 1];
    final isViewingToday = _isSameDay(widget.selectedDate, now);

    return SizedBox(
      key: const ValueKey('week_view'),
      height: 112,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header with Month, Year, and Pagination Chevrons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: widget.onOpenDatePicker,
                child: Row(
                  children: [
                    Text(
                      '$monthName ${widget.selectedDate.year}',
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
                        widget.onDateSelected(now);
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
                      widget.onPreviousWeek();
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildNavArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: () {
                      HapticService.selection();
                      widget.onNextWeek();
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),

          // 7-Day Interactive Row (Tap flips to Day Details View)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(weekDays.length, (index) {
              final dayDate = weekDays[index];
              final isSelected = _isSameDay(dayDate, widget.selectedDate);
              final isToday = _isSameDay(dayDate, now);
              final dayLetter = _dayLetters[dayDate.weekday % 7];
              final dateNumber = dayDate.day.toString().padLeft(2, '0');

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticService.selection();
                  widget.onDateSelected(dayDate);
                  setState(() => _isDetailsView = true);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                      const SizedBox(height: 5),
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
                      const SizedBox(height: 3),
                      // Mini telemetry dots under date
                      Builder(
                        builder: (_) {
                          final telemetry = widget.telemetryProvider?.call(dayDate);
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

  /// 2. In-Place Day Details View (Fixed Inner Height: Exactly 112px, zero layout shift)
  Widget _buildDayDetailsView(bool isDark) {
    final snapshot = widget.snapshotProvider?.call(widget.selectedDate) ?? DaySnapshot.zero;
    final title = _formatDayDetailsTitle(widget.selectedDate);

    return SizedBox(
      key: const ValueKey('day_details_view'),
      height: 112,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Day Details Header Row with Date & "Week View ↩" Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                  ),
                ],
              ),
              Row(
                children: [
                  // Previous Day Arrow
                  _buildNavArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: () {
                      HapticService.selection();
                      widget.onDateSelected(widget.selectedDate.subtract(const Duration(days: 1)));
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                  // Next Day Arrow
                  _buildNavArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: () {
                      HapticService.selection();
                      widget.onDateSelected(widget.selectedDate.add(const Duration(days: 1)));
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  // "Week Strip ↩" Pill
                  GestureDetector(
                    onTap: () {
                      HapticService.selection();
                      setState(() => _isDetailsView = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                        borderRadius: AppRadii.roundedPill,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_view_week_rounded,
                            size: 13,
                            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Week',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 4 Compact Telemetry Metrics Row
          Row(
            children: [
              // 1. Steps
              _buildMetricChip(
                isDark: isDark,
                label: 'Steps',
                value: snapshot.steps > 0 ? _formatNumber(snapshot.steps) : '0',
                icon: Icons.directions_run_rounded,
                accentColor: const Color(0xFFFF9442),
              ),
              const SizedBox(width: 8),

              // 2. Water
              _buildMetricChip(
                isDark: isDark,
                label: 'Water',
                value: snapshot.waterGlasses > 0 ? '${snapshot.waterGlasses} gls' : '0 gls',
                icon: Icons.water_drop_rounded,
                accentColor: const Color(0xFF2EB5FA),
              ),
              const SizedBox(width: 8),

              // 3. Calories
              _buildMetricChip(
                isDark: isDark,
                label: 'Calories',
                value: snapshot.calories > 0 ? '${snapshot.calories}' : '0',
                icon: Icons.local_fire_department_rounded,
                accentColor: const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),

              // 4. Sleep or BPM
              _buildMetricChip(
                isDark: isDark,
                label: snapshot.sleepHours > 0 ? 'Sleep' : (snapshot.bpm > 0 ? 'BPM' : 'Rest'),
                value: snapshot.sleepHours > 0
                    ? '${snapshot.sleepHours}h'
                    : (snapshot.bpm > 0 ? '${snapshot.bpm}' : '--'),
                icon: snapshot.sleepHours > 0
                    ? Icons.bedtime_rounded
                    : (snapshot.bpm > 0 ? Icons.favorite_rounded : Icons.spa_rounded),
                accentColor: snapshot.sleepHours > 0
                    ? const Color(0xFF818CF8)
                    : (snapshot.bpm > 0 ? const Color(0xFFEF4444) : AppColors.primaryDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required bool isDark,
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Expanded(
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B231F) : const Color(0xFFF4F7F4),
          borderRadius: AppRadii.roundedSm,
          border: Border.all(
            color: isDark ? const Color(0xFF2C3931) : const Color(0xFFE2E7E2),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: accentColor),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final s = number.toString();
      final thousands = s.substring(0, s.length - 3);
      final rest = s.substring(s.length - 3);
      return '$thousands,$rest';
    }
    return number.toString();
  }

  Widget _buildNavArrow({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 17,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}
