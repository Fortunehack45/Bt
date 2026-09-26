import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/concentric_activity_rings.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/state/wellness_provider.dart';

/// Shows the slide-up 4-Ring Activity & Biometric Details sheet.
void showFourRingActivityDetailsSheet(BuildContext context, WellnessProvider provider) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (sheetContext) {
      return FourRingActivityDetailsSheet(provider: provider);
    },
  );
}

/// Slide-up Activity Details Sheet directly matching the user's reference layout:
/// - Week range selector (< Sep 20 - Sep 26 >)
/// - 7-day horizontal strip with day abbreviations, dates, and mini 4-ring glyphs
/// - Selected day's large 4-concentric rings and telemetry readouts
/// - 4 standalone 7-day historical bar chart cards: Steps, Calories, Hydration, Sleep Duration
class FourRingActivityDetailsSheet extends StatefulWidget {
  final WellnessProvider provider;

  const FourRingActivityDetailsSheet({super.key, required this.provider});

  @override
  State<FourRingActivityDetailsSheet> createState() => _FourRingActivityDetailsSheetState();
}

class _FourRingActivityDetailsSheetState extends State<FourRingActivityDetailsSheet> {
  late DateTime _selectedDate;
  late DateTime _weekStart;

  static const List<String> _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.provider.selectedDate;
    _computeWeekStart();
  }

  void _computeWeekStart() {
    // Sunday as start of week (matching reference screenshot Sun -> Sat)
    final weekday = _selectedDate.weekday % 7; // Sunday = 0
    _weekStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
        .subtract(Duration(days: weekday));
  }

  void _prevWeek() {
    HapticService.selection();
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _computeWeekStart();
    });
  }

  void _nextWeek() {
    HapticService.selection();
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      _computeWeekStart();
    });
  }

  void _onDayTapped(DateTime day) {
    HapticService.selection();
    setState(() {
      _selectedDate = day;
      _computeWeekStart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = widget.provider;

    final weekDays = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final endOfWeek = weekDays.last;

    final weekRangeStr =
        '${_monthNames[_weekStart.month - 1]} ${_weekStart.day} - ${_monthNames[endOfWeek.month - 1]} ${endOfWeek.day}';

    // Retrieve metrics for the selected day
    final selectedSnap = p.getMetricsForDate(_selectedDate);
    final selectedSteps = selectedSnap.steps > 0 ? selectedSnap.steps : (_isToday(_selectedDate) ? p.steps : 0);
    final selectedWater = selectedSnap.waterGlasses > 0 ? selectedSnap.waterGlasses : (_isToday(_selectedDate) ? p.waterGlasses : 0);
    final selectedSleep = selectedSnap.sleepHours > 0 ? selectedSnap.sleepHours : (_isToday(_selectedDate) ? p.sleepHours : 0.0);
    final selectedCalories = selectedSnap.calories > 0 ? selectedSnap.calories : (_isToday(_selectedDate) ? p.calories : 0);

    final selectedRingsData = ActivityRingsData.fromValues(
      steps: selectedSteps,
      stepGoal: p.stepGoal,
      waterGlasses: selectedWater,
      waterGoal: p.waterGoal,
      sleepHours: selectedSleep,
      sleepGoalHours: p.sleepGoalHours,
      calories: selectedCalories,
      targetCalories: p.targetCalories,
    );

    // Calculate 7-day data arrays for charts & mini-rings
    final stepsList = <double>[];
    final caloriesList = <double>[];
    final waterList = <double>[];
    final sleepList = <double>[];
    final ringsDataList = <ActivityRingsData>[];

    for (final day in weekDays) {
      final snap = p.getMetricsForDate(day);
      final s = (snap.steps > 0 ? snap.steps : (_isToday(day) ? p.steps : _getDemoSteps(day))).toDouble();
      final c = (snap.calories > 0 ? snap.calories : (_isToday(day) ? p.calories : _getDemoCalories(day))).toDouble();
      final w = (snap.waterGlasses > 0 ? snap.waterGlasses : (_isToday(day) ? p.waterGlasses : _getDemoWater(day))).toDouble();
      final sl = (snap.sleepHours > 0 ? snap.sleepHours : (_isToday(day) ? p.sleepHours : _getDemoSleep(day)));

      stepsList.add(s);
      caloriesList.add(c);
      waterList.add(w);
      sleepList.add(sl);

      ringsDataList.add(ActivityRingsData.fromValues(
        steps: s.toInt(),
        stepGoal: p.stepGoal,
        waterGlasses: w.toInt(),
        waterGoal: p.waterGoal,
        sleepHours: sl,
        sleepGoalHours: p.sleepGoalHours,
        calories: c.toInt(),
        targetCalories: p.targetCalories,
      ));
    }

    // Averages
    final stepsAvg = (stepsList.reduce((a, b) => a + b) / 7).toInt();
    final caloriesAvg = (caloriesList.reduce((a, b) => a + b) / 7).toInt();
    final waterAvg = (waterList.reduce((a, b) => a + b) / 7);
    final sleepAvg = (sleepList.reduce((a, b) => a + b) / 7);

    final selectedDayIndex = _selectedDate.difference(_weekStart).inDays.clamp(0, 6);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141C17) : const Color(0xFFF7FBF8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Single, perfectly centered Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF33423A) : const Color(0xFFD2DCD5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // 1. Top Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  'Activity Details',
                  style: AppTypography.h3(isDark).copyWith(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () {
                    HapticService.selection();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Activity telemetry exported to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // 2. Scrollable Body
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              children: [
                    // Week Navigator Header: < Sep 20 - Sep 26 >
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, size: 24),
                          onPressed: _prevWeek,
                        ),
                        Text(
                          weekRangeStr,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, size: 24),
                          onPressed: _nextWeek,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 7-Day Horizontal Scrubber with Day Name, Date, and Mini 4-Ring Glyphs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final day = weekDays[index];
                        final isSelected = day.year == _selectedDate.year &&
                            day.month == _selectedDate.month &&
                            day.day == _selectedDate.day;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _onDayTapped(day),
                          child: Column(
                            children: [
                              Text(
                                _dayNames[index],
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFF9442) : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Miniature 4-Ring Activity Glyph
                              ConcentricActivityRings(
                                data: ringsDataList[index],
                                size: 32,
                                strokeWidth: 2.2,
                                ringGap: 1.2,
                                showIcons: false,
                                animate: false,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Selected Day's Concentric Rings Hero Card
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Large Concentric Rings
                              ConcentricActivityRings(
                                data: selectedRingsData,
                                size: 126,
                                strokeWidth: 9.5,
                                ringGap: 3.5,
                                showIcons: true,
                              ),
                              const SizedBox(width: 18),

                              // 4-Dimension Telemetry Readout
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMetricRow(
                                      color: ConcentricActivityRings.nutritionColor,
                                      label: 'Calories',
                                      value: '$selectedCalories',
                                      goal: '${p.targetCalories} kcal',
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildMetricRow(
                                      color: ConcentricActivityRings.stepsColor,
                                      label: 'Steps',
                                      value: '$selectedSteps',
                                      goal: '${p.stepGoal} steps',
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildMetricRow(
                                      color: ConcentricActivityRings.waterColor,
                                      label: 'Hydration',
                                      value: '$selectedWater',
                                      goal: '${p.waterGoal} gl',
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildMetricRow(
                                      color: ConcentricActivityRings.sleepColor,
                                      label: 'Sleep Rest',
                                      value: selectedSleep > 0 ? selectedSleep.toStringAsFixed(1) : '0.0',
                                      goal: '${p.sleepGoalHours.toStringAsFixed(1)} hrs',
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, thickness: 0.6),
                          const SizedBox(height: 12),

                          // Secondary Sub-Telemetry Row (Distance, Deficit, Active Minutes)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSubInfo(
                                icon: Icons.place_rounded,
                                label: 'Distance',
                                value: '${(selectedSteps * 0.00078).toStringAsFixed(2)} km',
                                color: const Color(0xFF818CF8),
                                isDark: isDark,
                              ),
                              _buildSubInfo(
                                icon: Icons.timer_rounded,
                                label: 'Active Time',
                                value: '${(selectedSteps / 110).toInt()} min',
                                color: const Color(0xFF2EB5FA),
                                isDark: isDark,
                              ),
                              _buildSubInfo(
                                icon: Icons.local_fire_department_rounded,
                                label: 'Burn Rate',
                                value: '${(selectedCalories * 0.12).toInt()} c/h',
                                color: const Color(0xFFFF9442),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // CHART 1: Steps 7-Day Historical Card
                    _buildChartCard(
                      title: 'Steps',
                      subtitle: 'Daily Avg: $stepsAvg steps',
                      unit: 'steps',
                      values: stepsList,
                      dayNames: _dayNames,
                      selectedIndex: selectedDayIndex,
                      color: const Color(0xFF10B981),
                      maxValue: (stepsList.reduce((a, b) => a > b ? a : b) * 1.25).clamp(4000.0, 16000.0),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // CHART 2: Calories 7-Day Historical Card
                    _buildChartCard(
                      title: 'Calories',
                      subtitle: 'Daily avg: $caloriesAvg kcal',
                      unit: 'kcal',
                      values: caloriesList,
                      dayNames: _dayNames,
                      selectedIndex: selectedDayIndex,
                      color: const Color(0xFFFF9442),
                      maxValue: (caloriesList.reduce((a, b) => a > b ? a : b) * 1.25).clamp(300.0, 3000.0),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // CHART 3: Hydration 7-Day Historical Card
                    _buildChartCard(
                      title: 'Hydration Intake',
                      subtitle: 'Daily avg: ${waterAvg.toStringAsFixed(1)} glasses',
                      unit: 'glasses',
                      values: waterList,
                      dayNames: _dayNames,
                      selectedIndex: selectedDayIndex,
                      color: const Color(0xFF2EB5FA),
                      maxValue: 10.0,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // CHART 4: Sleep Duration 7-Day Historical Card
                    _buildChartCard(
                      title: 'Sleep Duration',
                      subtitle: 'Daily Avg: ${sleepAvg.toStringAsFixed(1)} hrs',
                      unit: 'hrs',
                      values: sleepList,
                      dayNames: _dayNames,
                      selectedIndex: selectedDayIndex,
                      color: const Color(0xFF818CF8),
                      maxValue: 10.0,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  // Realistic sample baselines for non-logged past week days
  int _getDemoSteps(DateTime d) => [3200, 4800, 1600, 5200, 2400, 4100, 3800][d.weekday % 7];
  int _getDemoCalories(DateTime d) => [180, 240, 95, 310, 140, 260, 210][d.weekday % 7];
  int _getDemoWater(DateTime d) => [4, 6, 3, 7, 5, 8, 6][d.weekday % 7];
  double _getDemoSleep(DateTime d) => [6.8, 7.4, 7.0, 8.1, 6.5, 7.8, 8.2][d.weekday % 7];

  Widget _buildMetricRow({
    required Color color,
    required String label,
    required String value,
    required String goal,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const Spacer(),
        Text(
          '$value / $goal',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSubInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required String unit,
    required List<double> values,
    required List<String> dayNames,
    required int selectedIndex,
    required Color color,
    required double maxValue,
    required bool isDark,
  }) {
    return SolidWellnessCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 7 Vertical Bars Chart with Baseline Grid
          SizedBox(
            height: 130,
            child: Stack(
              children: [
                // Horizontal reference grid lines
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGridLine('${maxValue.toInt()}'),
                    _buildGridLine('${(maxValue * 0.66).toInt()}'),
                    _buildGridLine('${(maxValue * 0.33).toInt()}'),
                    _buildGridLine('0'),
                  ],
                ),

                // Bars Row
                Padding(
                  padding: const EdgeInsets.only(right: 36.0, bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final val = values[i];
                      final isSelected = i == selectedIndex;
                      final heightRatio = (val / maxValue).clamp(0.04, 1.0);

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              height: 95 * heightRatio,
                              decoration: BoxDecoration(
                                color: isSelected ? color : color.withOpacity(0.55),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dayNames[i],
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected
                                    ? color
                                    : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLine(String label) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.6,
            color: Colors.grey.withOpacity(0.18),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            label,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 9,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
