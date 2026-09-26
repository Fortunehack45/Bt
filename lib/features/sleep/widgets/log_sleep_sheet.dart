import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/wellness_bottom_sheet.dart';
import '../../../domain/state/wellness_provider.dart';

void showLogSleepSheet(BuildContext context, WellnessProvider provider) {
  showWellnessBottomSheet<void>(
    context: context,
    title: 'Log Night Sleep',
    subtitle: 'Track your recovery & sleep cycles',
    builder: (sheetContext) {
      return _LogSleepForm(provider: provider);
    },
  );
}

class _LogSleepForm extends StatefulWidget {
  final WellnessProvider provider;

  const _LogSleepForm({required this.provider});

  @override
  State<_LogSleepForm> createState() => _LogSleepFormState();
}

class _LogSleepFormState extends State<_LogSleepForm> {
  double _hours = 7.5;
  int _qualityStars = 4;
  String _bedtime = '11:00 PM';
  String _wakeTime = '06:30 AM';

  final List<String> _bedtimes = const ['10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM', '12:00 AM'];
  final List<String> _waketimes = const ['05:30 AM', '06:00 AM', '06:30 AM', '07:00 AM', '07:30 AM'];

  @override
  void initState() {
    super.initState();
    if (widget.provider.sleepHours > 0) {
      _hours = widget.provider.sleepHours;
    }
  }

  void _submit() {
    HapticService.success();
    widget.provider.logSleep(_hours);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recorded ${_hours.toStringAsFixed(1)} hours of sleep with $_qualityStars-star recovery!'),
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
        // Hours Slept Hero Counter
        Center(
          child: Column(
            children: [
              Text(
                '${_hours.toStringAsFixed(1)} hrs',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.sleepPurple,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _hours >= 7.0 ? 'Optimal Rest Duration 🌙' : 'Below Target Sleep',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Hours Slider
        Slider(
          value: _hours,
          min: 3.0,
          max: 12.0,
          divisions: 18,
          activeColor: AppColors.sleepPurple,
          inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          onChanged: (val) {
            HapticService.selection();
            setState(() => _hours = val);
          },
        ),
        const SizedBox(height: 20),

        // Sleep Quality Stars
        Text(
          'SLEEP QUALITY',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final star = index + 1;
            final isFilled = star <= _qualityStars;
            return IconButton(
              icon: Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 34,
                color: isFilled ? const Color(0xFFFBBF24) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              onPressed: () {
                HapticService.selection();
                setState(() => _qualityStars = star);
              },
            );
          }),
        ),
        const SizedBox(height: 20),

        // Bedtime and Wake time selector
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BEDTIME', style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  )),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                      borderRadius: AppRadii.roundedMd,
                    ),
                    child: DropdownButton<String>(
                      value: _bedtime,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      items: _bedtimes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setState(() => _bedtime = val!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WAKE TIME', style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  )),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                      borderRadius: AppRadii.roundedMd,
                    ),
                    child: DropdownButton<String>(
                      value: _wakeTime,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      items: _waketimes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setState(() => _wakeTime = val!),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Action CTA
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sleepPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
            ),
            child: const Text(
              'Save Sleep Record',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
