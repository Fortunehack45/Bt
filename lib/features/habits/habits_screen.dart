import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';

/// Habits Screen with interactive checklist, streaks, and habit creation.
/// Supports clean empty state for new users starting fresh.
class HabitsScreen extends StatefulWidget {
  final VoidCallback onAddHabit;

  const HabitsScreen({
    super.key,
    required this.onAddHabit,
  });

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = const ['All', 'Hydration', 'Activity', 'Mindfulness', 'Sleep'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

    final filteredHabits = _selectedCategory == 'All'
        ? provider.habits
        : provider.habits.where((h) => h.category == _selectedCategory).toList();

    final completedCount = provider.habits.where((h) => h.isCompletedToday).length;

    return Scaffold(
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.pageMargin,
            right: AppSpacing.pageMargin,
            top: AppSpacing.md,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Habits', style: AppTypography.h1(isDark)),
                      const SizedBox(height: 2),
                      Text(
                        provider.habits.isEmpty
                            ? 'Build your personalized daily routine'
                            : '$completedCount of ${provider.habits.length} completed today',
                        style: AppTypography.bodyMedium(isDark),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: widget.onAddHabit,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimaryLight,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.roundedMd,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              if (provider.habits.isNotEmpty) ...[
                // Category Pills
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;

                      return GestureDetector(
                        onTap: () {
                          HapticService.selection();
                          setState(() => _selectedCategory = cat);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.primary : AppColors.textPrimaryLight)
                                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                            borderRadius: AppRadii.roundedPill,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? AppColors.textPrimaryLight : Colors.white)
                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Habit Cards
                ...filteredHabits.map((habit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SolidWellnessCard(
                      onTap: () {
                        HapticService.success();
                        provider.toggleHabit(habit.id);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Row(
                        children: [
                          // Animated Checkbox
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutBack,
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: habit.isCompletedToday
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: habit.isCompletedToday
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong),
                                width: 1.8,
                              ),
                            ),
                            child: habit.isCompletedToday
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.textPrimaryLight,
                                    size: 20,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),

                          // Icon badge
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark ? habit.color.withOpacity(0.18) : habit.color.withOpacity(0.12),
                              borderRadius: AppRadii.roundedMd,
                            ),
                            child: Icon(habit.icon, color: habit.color, size: 22),
                          ),
                          const SizedBox(width: 12),

                          // Title & Streak
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.title,
                                  style: AppTypography.h3(isDark).copyWith(
                                    fontSize: 15,
                                    decoration: habit.isCompletedToday
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: habit.isCompletedToday
                                        ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 14,
                                      color: AppColors.stepsOrange,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${habit.streakDays} day streak',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                            onPressed: () {
                              HapticService.lightImpact();
                              provider.removeHabit(habit.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ] else ...[
                const SizedBox(height: 40),
                EmptyStateView(
                  icon: Icons.track_changes_rounded,
                  title: 'No Habits Yet',
                  description: 'Start building healthy routines. Tap "Add Habit" above to create your first goal.',
                  actionLabel: 'Add First Habit',
                  onAction: widget.onAddHabit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
