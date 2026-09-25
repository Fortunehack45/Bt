import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../utils/haptic_service.dart';
import 'solid_wellness_card.dart';
import 'wellness_bottom_sheet.dart';
import '../../domain/state/wellness_provider.dart';

/// Shows the custom Biothrix slide-up calendar sheet with date telemetry marking.
void showBiothrixCalendarSheet(BuildContext context, WellnessProvider provider) {
  showWellnessBottomSheet<void>(
    context: context,
    title: 'Wellness Calendar',
    subtitle: 'Track your daily health journey across time',
    builder: (sheetContext) {
      return _BiothrixCalendarView(provider: provider);
    },
  );
}

class _BiothrixCalendarView extends StatefulWidget {
  final WellnessProvider provider;

  const _BiothrixCalendarView({required this.provider});

  @override
  State<_BiothrixCalendarView> createState() => _BiothrixCalendarViewState();
}

class _BiothrixCalendarViewState extends State<_BiothrixCalendarView> {
  late DateTime _viewMonth;
  late DateTime _selected;

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _selected = widget.provider.selectedDate;
    _viewMonth = DateTime(_selected.year, _selected.month, 1);
  }

  void _prevMonth() {
    HapticService.selection();
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    HapticService.selection();
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
    });
  }

  void _jumpToToday() {
    HapticService.selection();
    final now = DateTime.now();
    setState(() {
      _selected = now;
      _viewMonth = DateTime(now.year, now.month, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final monthName = _months[_viewMonth.month - 1];

    final daysInMonth = DateUtils.getDaysInMonth(_viewMonth.year, _viewMonth.month);
    final firstDayWeekday = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7; // Sunday = 0

    final telemetry = widget.provider.getDayTelemetry(_selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Month / Year Navigation Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '$monthName ${_viewMonth.year}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: _jumpToToday,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                      borderRadius: AppRadii.roundedPill,
                    ),
                    child: Text(
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
                _buildNavBtn(Icons.chevron_left_rounded, _prevMonth, isDark),
                const SizedBox(width: 6),
                _buildNavBtn(Icons.chevron_right_rounded, _nextMonth, isDark),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Weekday Columns (S M T W T F S)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _weekdays.map((day) {
            return SizedBox(
              width: 38,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Monthly Day Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 4,
            childAspectRatio: 0.9,
          ),
          itemCount: firstDayWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstDayWeekday) {
              return const SizedBox();
            }

            final dayNumber = index - firstDayWeekday + 1;
            final cellDate = DateTime(_viewMonth.year, _viewMonth.month, dayNumber);
            final isSelected = _isSameDay(cellDate, _selected);
            final isToday = _isSameDay(cellDate, now);
            final dayTel = widget.provider.getDayTelemetry(cellDate);

            return GestureDetector(
              onTap: () {
                HapticService.selection();
                setState(() => _selected = cellDate);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.primary.withOpacity(0.28) : const Color(0xFFD6F57D))
                      : Colors.transparent,
                  borderRadius: AppRadii.roundedMd,
                  border: isSelected
                      ? Border.all(
                          color: isDark ? AppColors.primary : const Color(0xFFC4E968),
                          width: 1.5,
                        )
                      : (isToday
                          ? Border.all(
                              color: isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong,
                              width: 1.0,
                            )
                          : null),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
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
                    // Telemetry Data Dots Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dayTel.hasNutrition)
                          _buildDot(const Color(0xFF10B981)), // Nutrition
                        if (dayTel.hasWater)
                          _buildDot(AppColors.waterBlue),      // Water
                        if (dayTel.hasActivity)
                          _buildDot(AppColors.stepsOrange),    // Activity
                        if (dayTel.hasSleep)
                          _buildDot(AppColors.sleepPurple),    // Sleep
                        if (!dayTel.hasAny)
                          const SizedBox(height: 4),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // Telemetry Dots Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Nutrition', const Color(0xFF10B981), isDark),
            const SizedBox(width: 12),
            _buildLegendItem('Water', AppColors.waterBlue, isDark),
            const SizedBox(width: 12),
            _buildLegendItem('Activity', AppColors.stepsOrange, isDark),
            const SizedBox(width: 12),
            _buildLegendItem('Sleep', AppColors.sleepPurple, isDark),
          ],
        ),
        const SizedBox(height: 16),

        // Selected Day Summary Card
        Builder(
          builder: (_) {
            final metrics = widget.provider.getMetricsForDate(_selected);
            final calStr = metrics.calories > 0 ? '${metrics.calories} kcal' : '0 kcal';
            final waterStr = metrics.waterGlasses > 0 ? '${(metrics.waterGlasses * 0.25).toStringAsFixed(1)} L' : '0.0 L';
            final stepStr = metrics.steps > 0 ? '${metrics.steps}' : '0';
            final sleepStr = metrics.sleepHours > 0 ? '${metrics.sleepHours.toStringAsFixed(1)} hrs' : '0.0 hrs';

            return SolidWellnessCard(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCol('Calories', calStr, isDark),
                  _buildSummaryCol('Water', waterStr, isDark),
                  _buildSummaryCol('Steps', stepStr, isDark),
                  _buildSummaryCol('Sleep', sleepStr, isDark),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 18),

        // Action Button: Sync & Apply Date
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              HapticService.success();
              widget.provider.setSelectedDate(_selected);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Synchronized to ${_selected.day} ${_months[_selected.month - 1]} ${_selected.year}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimaryLight,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
            ),
            child: Text(
              'Select ${_selected.day} $monthName',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCol(String title, String val, bool isDark) {
    return Column(
      children: [
        Text(title, style: AppTypography.caption(isDark).copyWith(fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          val,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildNavBtn(IconData icon, VoidCallback onTap, bool isDark) {
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
            size: 20,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}
