import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/wellness_bottom_sheet.dart';
import '../../../domain/state/wellness_provider.dart';

void showLogMealSheet(BuildContext context, WellnessProvider provider, {String defaultType = 'Breakfast'}) {
  showWellnessBottomSheet<void>(
    context: context,
    title: 'Log Meal & Nutrition',
    subtitle: 'Fuel your body with wholesome energy',
    builder: (sheetContext) {
      return _LogMealForm(provider: provider, initialType: defaultType);
    },
  );
}

class _LogMealForm extends StatefulWidget {
  final WellnessProvider provider;
  final String initialType;

  const _LogMealForm({required this.provider, required this.initialType});

  @override
  State<_LogMealForm> createState() => _LogMealFormState();
}

class _LogMealFormState extends State<_LogMealForm> {
  late String _mealType;
  final _nameController = TextEditingController();
  final _calorieController = TextEditingController(text: '350');
  String _notes = '';

  final List<Map<String, dynamic>> _types = const [
    {'name': 'Breakfast', 'icon': Icons.wb_twilight_rounded, 'color': Color(0xFFF59E0B)},
    {'name': 'Lunch time', 'label': 'Lunch', 'icon': Icons.wb_sunny_rounded, 'color': Color(0xFF10B981)},
    {'name': 'Dinner', 'icon': Icons.nightlight_round, 'color': Color(0xFF818CF8)},
    {'name': 'Healthy Snack', 'label': 'Snack', 'icon': Icons.apple_rounded, 'color': Color(0xFFFF9442)},
  ];

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  void _addCalories(int delta) {
    HapticService.selection();
    final current = int.tryParse(_calorieController.text) ?? 0;
    final next = (current + delta).clamp(50, 3000);
    setState(() => _calorieController.text = next.toString());
  }

  void _submit() {
    final name = _nameController.text.trim().isEmpty ? '$_mealType Entry' : _nameController.text.trim();
    final cals = int.tryParse(_calorieController.text) ?? 300;

    HapticService.success();
    widget.provider.addMeal(name, _mealType, cals, _notes.isEmpty ? 'Fresh wholesome meal' : _notes);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged "$name" (+$cals kcal) into $_mealType!'),
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
        // Meal Type Selector
        Text(
          'MEAL CATEGORY',
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
          children: _types.map((type) {
            final name = type['name'] as String;
            final label = (type['label'] ?? name) as String;
            final isSelected = _mealType == name;
            final color = type['color'] as Color;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _mealType = name);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(type['icon'] as IconData, size: 20, color: color),
                      const SizedBox(height: 4),
                      Text(
                        label,
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

        // Meal Name
        Text(
          'MEAL DESCRIPTION',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Avocado Toast with Poached Eggs',
            hintStyle: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: AppRadii.roundedMd,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.roundedMd,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Calories Input & Presets
        Text(
          'CALORIC ENERGY (KCAL)',
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
          children: [
            Expanded(
              child: TextField(
                controller: _calorieController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
                decoration: InputDecoration(
                  suffixText: 'kcal',
                  suffixStyle: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.roundedMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Preset Quick Chips
        Row(
          children: [100, 200, 350, 500].map((c) {
            return Expanded(
              child: GestureDetector(
                onTap: () => _addCalories(c),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                    borderRadius: AppRadii.roundedPill,
                  ),
                  child: Center(
                    child: Text(
                      '+$c',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimaryLight,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
            ),
            child: const Text(
              'Log Meal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
