import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/wellness_bottom_sheet.dart';
import '../../../domain/state/wellness_provider.dart';

void showLogActivitySheet(BuildContext context, WellnessProvider provider, {String? initialDiscipline}) {
  showWellnessBottomSheet<void>(
    context: context,
    title: 'Log Workout Session',
    subtitle: 'Keep your body moving and energized',
    builder: (sheetContext) {
      return _LogActivityForm(provider: provider, initialDiscipline: initialDiscipline);
    },
  );
}

class _LogActivityForm extends StatefulWidget {
  final WellnessProvider provider;
  final String? initialDiscipline;

  const _LogActivityForm({required this.provider, this.initialDiscipline});

  @override
  State<_LogActivityForm> createState() => _LogActivityFormState();
}

class _LogActivityFormState extends State<_LogActivityForm> {
  late String _discipline;
  double _durationMinutes = 30.0;
  String _intensity = 'Moderate';

  @override
  void initState() {
    super.initState();
    _discipline = widget.initialDiscipline ?? 'Walking';
  }

  final List<Map<String, dynamic>> _disciplines = const [
    {'name': 'Walking', 'icon': Icons.directions_walk_rounded, 'calPerMin': 4.5, 'stepsPerMin': 100},
    {'name': 'Running', 'icon': Icons.directions_run_rounded, 'calPerMin': 11.0, 'stepsPerMin': 160},
    {'name': 'Cycling', 'icon': Icons.directions_bike_rounded, 'calPerMin': 8.5, 'stepsPerMin': 0},
    {'name': 'Gym & Weights', 'icon': Icons.fitness_center_rounded, 'calPerMin': 6.5, 'stepsPerMin': 30},
    {'name': 'HIIT Cardio', 'icon': Icons.bolt_rounded, 'calPerMin': 12.0, 'stepsPerMin': 120},
    {'name': 'Yoga / Stretch', 'icon': Icons.self_improvement_rounded, 'calPerMin': 3.5, 'stepsPerMin': 15},
  ];

  int get _calculatedCalories {
    final item = _disciplines.firstWhere((d) => d['name'] == _discipline);
    final rate = item['calPerMin'] as double;
    final mult = _intensity == 'High' ? 1.25 : (_intensity == 'Light' ? 0.8 : 1.0);
    return (_durationMinutes * rate * mult).round();
  }

  int get _calculatedSteps {
    final item = _disciplines.firstWhere((d) => d['name'] == _discipline);
    final rate = item['stepsPerMin'] as int;
    return (_durationMinutes * rate).round();
  }

  void _submit() {
    HapticService.success();
    final hours = _durationMinutes / 60.0;
    widget.provider.logActivity(hours, _calculatedCalories, _calculatedSteps);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged $_discipline: ${_durationMinutes.toInt()} min (+$_calculatedCalories kcal, +$_calculatedSteps steps)!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Discipline Grid
        Text(
          'WORKOUT DISCIPLINE',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _disciplines.map((d) {
            final name = d['name'] as String;
            final isSelected = _discipline == name;

            return GestureDetector(
              onTap: () {
                HapticService.selection();
                setState(() => _discipline = name);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.stepsOrange.withOpacity(0.2)
                      : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(
                    color: isSelected ? AppColors.stepsOrange : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(d['icon'] as IconData, size: 16, color: isSelected ? AppColors.stepsOrange : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight)),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Duration Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('DURATION', style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
            )),
            Text('${_durationMinutes.toInt()} minutes', style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.stepsOrange,
            )),
          ],
        ),
        Slider(
          value: _durationMinutes,
          min: 10,
          max: 120,
          divisions: 22,
          activeColor: AppColors.stepsOrange,
          inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          onChanged: (val) {
            HapticService.selection();
            setState(() => _durationMinutes = val);
          },
        ),
        const SizedBox(height: 16),

        // Intensity selector
        Text('INTENSITY LEVEL', style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
        )),
        const SizedBox(height: 8),
        Row(
          children: ['Light', 'Moderate', 'High'].map((lvl) {
            final isSelected = _intensity == lvl;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _intensity = lvl);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.stepsOrange.withOpacity(0.2)
                        : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: isSelected ? AppColors.stepsOrange : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      lvl,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.stepsOrange
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Result Preview Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF221A15) : const Color(0xFFFFF6ED),
            borderRadius: AppRadii.roundedMd,
            border: Border.all(
              color: AppColors.stepsOrange.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('Estimated Burn', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight)),
                  const SizedBox(height: 2),
                  Text('+$_calculatedCalories kcal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.stepsOrange)),
                ],
              ),
              Container(width: 1, height: 28, color: AppColors.stepsOrange.withOpacity(0.25)),
              Column(
                children: [
                  Text('Active Steps', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight)),
                  const SizedBox(height: 2),
                  Text('+$_calculatedSteps steps', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.stepsOrange)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action CTA
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.stepsOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
            ),
            child: const Text(
              'Log Workout Session',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
