import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/wellness_bottom_sheet.dart';
import '../../../domain/state/wellness_provider.dart';

void showLogWeightSheet(BuildContext context, WellnessProvider provider) {
  showWellnessBottomSheet<void>(
    context: context,
    title: 'Record Body Weight',
    subtitle: 'Monitor weight trends and body mass composition',
    builder: (sheetContext) {
      return _LogWeightForm(provider: provider);
    },
  );
}

class _LogWeightForm extends StatefulWidget {
  final WellnessProvider provider;

  const _LogWeightForm({required this.provider});

  @override
  State<_LogWeightForm> createState() => _LogWeightFormState();
}

class _LogWeightFormState extends State<_LogWeightForm> {
  double _weight = 70.0;

  @override
  void initState() {
    super.initState();
    if (widget.provider.weightKg > 0) {
      _weight = widget.provider.weightKg;
    }
  }

  void _submit() {
    HapticService.success();
    widget.provider.setWeight(_weight);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved weight: ${_weight.toStringAsFixed(1)} kg!'),
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
        // Current Weight Display Hero
        Center(
          child: Column(
            children: [
              Text(
                '${_weight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '≈ ${(_weight * 2.20462).toStringAsFixed(1)} lbs',
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
        const SizedBox(height: 20),

        // Precision Steppers (-1.0, -0.1, +0.1, +1.0)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepButton('-1.0', () => setState(() => _weight = (_weight - 1.0).clamp(30.0, 250.0)), isDark),
            const SizedBox(width: 8),
            _buildStepButton('-0.1', () => setState(() => _weight = (_weight - 0.1).clamp(30.0, 250.0)), isDark),
            const SizedBox(width: 16),
            _buildStepButton('+0.1', () => setState(() => _weight = (_weight + 0.1).clamp(30.0, 250.0)), isDark),
            const SizedBox(width: 8),
            _buildStepButton('+1.0', () => setState(() => _weight = (_weight + 1.0).clamp(30.0, 250.0)), isDark),
          ],
        ),
        const SizedBox(height: 20),

        // Slider
        Slider(
          value: _weight,
          min: 40.0,
          max: 150.0,
          divisions: 220,
          activeColor: const Color(0xFFF59E0B),
          inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          onChanged: (val) {
            HapticService.selection();
            setState(() => _weight = double.parse(val.toStringAsFixed(1)));
          },
        ),
        const SizedBox(height: 28),

        // Action CTA
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
            ),
            child: const Text(
              'Save Weight Entry',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepButton(String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
          borderRadius: AppRadii.roundedPill,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF59E0B),
          ),
        ),
      ),
    );
  }
}
