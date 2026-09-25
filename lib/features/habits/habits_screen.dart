import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';
import 'widgets/add_habit_sheet.dart';

/// Habits Screen with completion progress, category filters, quick habit starter templates,
/// and interactive streak checklist.
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

  final List<Map<String, dynamic>> _habitTemplates = const [
    {
      'title': 'Drink 500ml upon waking',
      'category': 'Hydration',
      'icon': Icons.water_drop_rounded,
      'color': AppColors.waterBlue,
    },
    {
      'title': '10 min Morning Sunlight',
      'category': 'Mindfulness',
      'icon': Icons.wb_sunny_rounded,
      'color': AppColors.nutritionGold,
    },
    {
      'title': '10,000 Steps Daily',
      'category': 'Activity',
      'icon': Icons.directions_walk_rounded,
      'color': AppColors.stepsOrange,
    },
    {
      'title': '5 min Deep Box Breathing',
      'category': 'Mindfulness',
      'icon': Icons.spa_rounded,
      'color': AppColors.primaryDark,
    },
    {
      'title': 'No screens 30m before sleep',
      'category': 'Sleep',
      'icon': Icons.bedtime_rounded,
      'color': AppColors.sleepPurple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

    final filteredHabits = _selectedCategory == 'All'
        ? provider.habits
        : provider.habits.where((h) => h.category == _selectedCategory).toList();

    final completedCount = provider.habits.where((h) => h.isCompletedToday).length;
    final totalHabits = provider.habits.length;
    final completionRatio = totalHabits > 0 ? (completedCount / totalHabits.toDouble()) : 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: false,
        child: Column(
          children: [
            // Standardized 56pt Header
            ScreenHeader(
              title: 'Daily Habits',
              subtitle: totalHabits > 0
                  ? '$completedCount of $totalHabits completed today'
                  : 'Build healthy micro-routines',
              trailing: ElevatedButton.icon(
                onPressed: widget.onAddHabit,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Habit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimaryLight,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: AppSpacing.pageMargin,
                  right: AppSpacing.pageMargin,
                  top: AppSpacing.xs,
                  bottom: AppSpacing.contentBottomPadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Daily Completion Progress Hero
              SolidWellnessCard(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.stepsOrangeTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_fire_department_rounded, color: AppColors.stepsOrange, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text('Routine Consistency', style: AppTypography.h3(isDark).copyWith(fontSize: 16)),
                          ],
                        ),
                        Text(
                          totalHabits > 0 ? '${(completionRatio * 100).toInt()}%' : '0%',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completionRatio,
                        minHeight: 8,
                        backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      totalHabits == 0
                          ? 'Choose a habit from the starter templates below to begin.'
                          : (completedCount == totalHabits
                              ? '🔥 Outstanding! All daily habits completed today!'
                              : '${totalHabits - completedCount} habits remaining today.'),
                      style: AppTypography.caption(isDark).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Category Filter Pills
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              // 4. Section: Active Habits List
              if (filteredHabits.isNotEmpty) ...[
                Text('Active Routines (${filteredHabits.length})', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                const SizedBox(height: AppSpacing.sm),
                ...filteredHabits.map((habit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SolidWellnessCard(
                      onTap: () {
                        HapticService.success();
                        provider.toggleHabit(habit.id);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Row(
                        children: [
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
                                    const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.stepsOrange),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${habit.streakDays} day streak • ${habit.category}',
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
                const SizedBox(height: AppSpacing.md),
              ],

              // 5. Section: Popular Starter Templates (1-Tap Add)
              Text('Starter Habit Templates', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.xs),
              Text('Tap any template to instantly add it to your daily routine:', style: AppTypography.caption(isDark)),
              const SizedBox(height: AppSpacing.sm),
              ..._habitTemplates.map((template) {
                final isAlreadyAdded = provider.habits.any((h) => h.title == template['title']);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SolidWellnessCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    onTap: isAlreadyAdded
                        ? null
                        : () {
                            showAddHabitSheet(
                              context,
                              provider,
                              initialTitle: template['title'] as String,
                              initialCategory: template['category'] as String,
                            );
                          },
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (template['color'] as Color).withOpacity(0.14),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: Icon(template['icon'] as IconData, color: template['color'] as Color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(template['title'] as String, style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
                              Text(template['category'] as String, style: AppTypography.caption(isDark)),
                            ],
                          ),
                        ),
                        isAlreadyAdded
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                                  borderRadius: AppRadii.roundedPill,
                                ),
                                child: const Text('+ Configure', style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                )),
                              ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ],
  ),
),
);
}
}
