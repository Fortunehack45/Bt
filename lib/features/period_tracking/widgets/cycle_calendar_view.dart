import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/state/wellness_provider.dart';
import 'log_period_sheet.dart';

/// Interactive Menstrual Cycle Calendar View matching Biothrix calendar styling.
class CycleCalendarView extends StatefulWidget {
  final WellnessProvider provider;
  final ValueChanged<DateTime>? onDateSelected;

  const CycleCalendarView({
    super.key,
    required this.provider,
    this.onDateSelected,
  });

  @override
  State<CycleCalendarView> createState() => _CycleCalendarViewState();
}

class _CycleCalendarViewState extends State<CycleCalendarView> {
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
    widget.onDateSelected?.call(now);
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

    final selectedLog = widget.provider.getPeriodDailyLog(_selected);
    final isSelectedPeriod = widget.provider.isPeriodDay(_selected);
    final isSelectedPredicted = widget.provider.isPredictedPeriodDay(_selected);
    final isSelectedFertile = widget.provider.isFertileWindowDay(_selected);

    return SolidWellnessCard(
      padding: const EdgeInsets.all(16),
      child: Column(
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
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _jumpToToday,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF26332C) : const Color(0xFFE2EBE5),
                        borderRadius: AppRadii.roundedPill,
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryLight : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _prevMonth,
                  ),
                  const SizedBox(width: 14),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays.map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
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
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.15,
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
              final isPeriod = widget.provider.isPeriodDay(cellDate);
              final isPredicted = widget.provider.isPredictedPeriodDay(cellDate);
              final isFertile = widget.provider.isFertileWindowDay(cellDate);
              final log = widget.provider.getPeriodDailyLog(cellDate);
              final hasSymptoms = log != null && (log.symptoms.isNotEmpty || log.notes.isNotEmpty);

              // Background color calculation
              Color cellBgColor = Colors.transparent;
              if (isSelected) {
                cellBgColor = isDark ? const Color(0xFF33423A) : const Color(0xFFD6F57D);
              } else if (isPeriod) {
                cellBgColor = const Color(0xFFF43F5E).withOpacity(0.22);
              } else if (isPredicted) {
                cellBgColor = const Color(0xFFF43F5E).withOpacity(0.08);
              } else if (isFertile) {
                cellBgColor = const Color(0xFFA855F7).withOpacity(0.12);
              }

              return GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _selected = cellDate);
                  widget.onDateSelected?.call(cellDate);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: cellBgColor,
                    borderRadius: AppRadii.roundedSm,
                    border: isSelected
                        ? Border.all(
                            color: isDark ? AppColors.primary : const Color(0xFF6B9E00),
                            width: 1.4,
                          )
                        : (isPeriod
                            ? Border.all(color: const Color(0xFFF43F5E), width: 1.0)
                            : (isPredicted
                                ? Border.all(color: const Color(0xFFF43F5E).withOpacity(0.5), width: 1.0)
                                : (isToday
                                    ? Border.all(
                                        color: isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong,
                                        width: 1.0,
                                      )
                                    : null))),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: (isSelected || isPeriod) ? FontWeight.w800 : FontWeight.w600,
                          color: isPeriod
                              ? (isDark ? const Color(0xFFFDA4AF) : const Color(0xFFE11D48))
                              : (isSelected
                                  ? (isDark ? AppColors.primaryLight : AppColors.textPrimaryLight)
                                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPeriod)
                            _buildDot(const Color(0xFFF43F5E))
                          else if (isPredicted)
                            _buildDot(const Color(0xFFF43F5E).withOpacity(0.6))
                          else if (isFertile)
                            _buildDot(const Color(0xFFA855F7))
                          else if (hasSymptoms)
                            _buildDot(isDark ? Colors.white54 : Colors.black45)
                          else
                            const SizedBox(height: 3),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Calendar Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Period', const Color(0xFFF43F5E), isDark),
              const SizedBox(width: 12),
              _buildLegendItem('Predicted', const Color(0xFFF43F5E).withOpacity(0.5), isDark),
              const SizedBox(width: 12),
              _buildLegendItem('Fertile', const Color(0xFFA855F7), isDark),
              const SizedBox(width: 12),
              _buildLegendItem('Logged', isDark ? Colors.white54 : Colors.black45, isDark),
            ],
          ),
          const SizedBox(height: 14),

          // Selected Day Inspection & Action Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B241E) : const Color(0xFFF3F7F4),
              borderRadius: AppRadii.roundedSm,
              border: Border.all(
                color: isDark ? const Color(0xFF28362E) : const Color(0xFFDEE7E1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_months[_selected.month - 1]} ${_selected.day}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isSelectedPeriod)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Period Day',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            )
                          else if (isSelectedPredicted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Estimated Period',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFF43F5E)),
                              ),
                            )
                          else if (isSelectedFertile)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA855F7).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Fertile Window',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFA855F7)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selectedLog != null && selectedLog.symptoms.isNotEmpty
                            ? 'Symptoms: ${selectedLog.symptoms.map((s) => s.displayName).join(', ')}'
                            : (isSelectedPeriod ? 'Flow active • No symptoms logged' : 'No symptoms logged for this date'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption(isDark).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showLogPeriodSheet(context, widget.provider, initialDate: _selected);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                  ),
                  child: Text(
                    selectedLog != null || isSelectedPeriod ? 'Edit Log' : '+ Log Day',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 4.5,
      height: 4.5,
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
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
}
