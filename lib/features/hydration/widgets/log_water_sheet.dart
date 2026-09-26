import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/wellness_bottom_sheet.dart';
import '../../../domain/state/wellness_provider.dart';

void showLogWaterSheet(BuildContext context, WellnessProvider provider, {int? initialMl}) {
  showWellnessBottomSheet<void>(
    context: context,
    title: 'Log Hydration',
    subtitle: 'Optimal daily water intake for energy and recovery',
    builder: (sheetContext) {
      return _LogWaterForm(provider: provider, initialMl: initialMl);
    },
  );
}

class _LogWaterForm extends StatefulWidget {
  final WellnessProvider provider;
  final int? initialMl;

  const _LogWaterForm({required this.provider, this.initialMl});

  @override
  State<_LogWaterForm> createState() => _LogWaterFormState();
}

class _LogWaterFormState extends State<_LogWaterForm> {
  late int _ml;
  String _beverageType = 'Pure Water';

  @override
  void initState() {
    super.initState();
    _ml = widget.initialMl ?? 250;
  }

  final List<Map<String, dynamic>> _presets = const [
    {'label': '150 ml', 'name': 'Espresso / Cup', 'amount': 150, 'icon': Icons.local_cafe_rounded},
    {'label': '250 ml', 'name': 'Standard Glass', 'amount': 250, 'icon': Icons.water_drop_rounded},
    {'label': '500 ml', 'name': 'Water Bottle', 'amount': 500, 'icon': Icons.local_drink_rounded},
    {'label': '750 ml', 'name': 'Sports Flask', 'amount': 750, 'icon': Icons.fitness_center_rounded},
  ];

  final List<String> _beverages = const [
    'Pure Water',
    'Electrolyte',
    'Herbal Tea',
    'Coconut Water',
  ];

  void _submit() {
    HapticService.success();
    widget.provider.addWaterAmount(_ml);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged $_ml ml of $_beverageType!'),
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
        // Volume Display Hero
        Center(
          child: Column(
            children: [
              Text(
                '$_ml ml',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.waterBlue,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '≈ ${(_ml / 250.0).toStringAsFixed(1)} standard glasses',
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

        // Stepper Controls (-50ml and +50ml)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                HapticService.selection();
                setState(() => _ml = (_ml - 50).clamp(50, 2000));
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
            const SizedBox(width: 24),
            GestureDetector(
              onTap: () {
                HapticService.selection();
                setState(() => _ml = (_ml + 50).clamp(50, 2000));
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

        // Quick Presets
        Text(
          'CONTAINER PRESETS',
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
          children: _presets.map((preset) {
            final amount = preset['amount'] as int;
            final isSelected = _ml == amount;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _ml = amount);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.waterBlue.withOpacity(0.2)
                        : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: isSelected ? AppColors.waterBlue : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(preset['icon'] as IconData, size: 18, color: isSelected ? AppColors.waterBlue : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight)),
                      const SizedBox(height: 4),
                      Text(
                        preset['label'] as String,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Beverage Type
        Text(
          'DRINK TYPE',
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
          children: _beverages.map((bev) {
            final isSelected = _beverageType == bev;
            return GestureDetector(
              onTap: () {
                HapticService.selection();
                setState(() => _beverageType = bev);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.waterBlue.withOpacity(0.2)
                      : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(color: isSelected ? AppColors.waterBlue : Colors.transparent),
                ),
                child: Text(
                  bev,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
              backgroundColor: AppColors.waterBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
            ),
            child: const Text(
              'Log Hydration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
