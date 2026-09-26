import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/wellness_bottom_sheet.dart';
import '../../../domain/state/wellness_provider.dart';

/// Shows the slide-in Add Habit modal sheet.
void showAddHabitSheet(BuildContext context, WellnessProvider provider, {String? initialTitle, String? initialCategory}) {
  showWellnessBottomSheet<void>(
    context: context,
    title: 'New Wellness Habit',
    subtitle: 'Build consistent daily micro-routines',
    builder: (sheetContext) {
      return _AddHabitForm(
        provider: provider,
        initialTitle: initialTitle,
        initialCategory: initialCategory,
      );
    },
  );
}

class _AddHabitForm extends StatefulWidget {
  final WellnessProvider provider;
  final String? initialTitle;
  final String? initialCategory;

  const _AddHabitForm({
    required this.provider,
    this.initialTitle,
    this.initialCategory,
  });

  @override
  State<_AddHabitForm> createState() => _AddHabitFormState();
}

class _AddHabitFormState extends State<_AddHabitForm> {
  late final TextEditingController _titleController;
  late String _selectedCategory;
  IconData _selectedIcon = Icons.spa_rounded;
  Color _selectedColor = AppColors.primary;
  String _frequency = 'Daily';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _selectedCategory = widget.initialCategory ?? 'Mindfulness';
  }

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Mindfulness', 'color': Color(0xFF10B981), 'icon': Icons.spa_rounded},
    {'name': 'Activity', 'color': Color(0xFFFF9442), 'icon': Icons.directions_run_rounded},
    {'name': 'Hydration', 'color': Color(0xFF2EB5FA), 'icon': Icons.water_drop_rounded},
    {'name': 'Sleep', 'color': Color(0xFF818CF8), 'icon': Icons.bedtime_rounded},
    {'name': 'Nutrition', 'color': Color(0xFFF59E0B), 'icon': Icons.restaurant_rounded},
  ];

  final List<IconData> _iconOptions = const [
    Icons.spa_rounded,
    Icons.wb_sunny_rounded,
    Icons.directions_run_rounded,
    Icons.water_drop_rounded,
    Icons.bedtime_rounded,
    Icons.menu_book_rounded,
    Icons.self_improvement_rounded,
    Icons.fitness_center_rounded,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    HapticService.success();
    widget.provider.addHabit(
      title,
      _selectedCategory,
      _selectedIcon,
      _selectedColor,
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added new habit "$title" to your daily routine!'),
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
        // Habit Title Input
        Text(
          'HABIT TITLE',
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
          controller: _titleController,
          autofocus: true,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. 10m Morning Sunlight',
            hintStyle: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: const OutlineInputBorder(
              borderRadius: AppRadii.roundedMd,
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadii.roundedMd,
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Category Selection
        Text(
          'CATEGORY',
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
          children: _categories.map((cat) {
            final name = cat['name'] as String;
            final isSelected = _selectedCategory == name;
            final color = cat['color'] as Color;

            return GestureDetector(
              onTap: () {
                HapticService.selection();
                setState(() {
                  _selectedCategory = name;
                  _selectedColor = color;
                  _selectedIcon = cat['icon'] as IconData;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.2)
                      : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat['icon'] as IconData, size: 16, color: color),
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

        // Icon Selection
        Text(
          'HABIT ICON',
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _iconOptions.map((icon) {
            final isSelected = _selectedIcon == icon;
            return GestureDetector(
              onTap: () {
                HapticService.selection();
                setState(() => _selectedIcon = icon);
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? _selectedColor.withOpacity(0.2)
                      : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _selectedColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? _selectedColor
                        : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Target Frequency
        Text(
          'FREQUENCY',
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
          children: ['Daily', 'Weekdays', '3x / Week'].map((freq) {
            final isSelected = _frequency == freq;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _frequency = freq);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF28362D) : const Color(0xFFE2F4C5))
                        : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      freq,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryDark
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
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimaryLight,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
            ),
            child: const Text(
              'Create Habit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
