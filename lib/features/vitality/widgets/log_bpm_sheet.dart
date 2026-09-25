import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/wellness_bottom_sheet.dart';
import '../../../domain/state/wellness_provider.dart';

void showLogBpmSheet(BuildContext context, WellnessProvider provider) {
  showWellnessBottomSheet<void>(
    context: context,
    title: 'Record Heart Rate (BPM)',
    subtitle: 'Track your resting and active cardiovascular vitals',
    builder: (sheetContext) {
      return _LogBpmForm(provider: provider);
    },
  );
}

class _LogBpmForm extends StatefulWidget {
  final WellnessProvider provider;

  const _LogBpmForm({required this.provider});

  @override
  State<_LogBpmForm> createState() => _LogBpmFormState();
}

class _LogBpmFormState extends State<_LogBpmForm> {
  int _bpm = 72;
  String _state = 'Resting';

  final List<String> _states = const ['Resting', 'Post-Workout', 'Walking', 'General'];

  @override
  void initState() {
    super.initState();
    if (widget.provider.bpm > 0) {
      _bpm = widget.provider.bpm;
    }
  }

  void _submit() {
    HapticService.success();
    widget.provider.setBpm(_bpm);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recorded $_bpm BPM ($_state reading)!'),
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
        // Pulse BPM Counter Hero
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.heartRed.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.heartRed,
                  size: 42,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_bpm',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.heartRed,
                ),
              ),
              Text(
                'BEATS PER MINUTE',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Stepper
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                HapticService.selection();
                setState(() => _bpm = (_bpm - 1).clamp(40, 220));
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: const Center(child: Icon(Icons.remove_rounded, size: 22)),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              '$_bpm BPM',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                HapticService.selection();
                setState(() => _bpm = (_bpm + 1).clamp(40, 220));
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: const Center(child: Icon(Icons.add_rounded, size: 22)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Slider
        Slider(
          value: _bpm.toDouble(),
          min: 40,
          max: 200,
          divisions: 160,
          activeColor: AppColors.heartRed,
          inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          onChanged: (val) {
            HapticService.selection();
            setState(() => _bpm = val.round());
          },
        ),
        const SizedBox(height: 16),

        // Reading State Context
        Text(
          'MEASUREMENT STATE',
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
          children: _states.map((s) {
            final isSelected = _state == s;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _state = s);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.heartRed.withOpacity(0.2)
                        : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: isSelected ? AppColors.heartRed : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      s,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.heartRed
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        // Action CTA
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.heartRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
            ),
            child: const Text(
              'Save Heart Rate',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
