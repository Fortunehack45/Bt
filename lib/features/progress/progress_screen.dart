import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/circular_progress_ring.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';

/// Progress Screen showing long-term trends, streaks, and consistency.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

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
              Text(
                'Wellness Progress',
                style: AppTypography.h1(isDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Historical consistency and monthly benchmarks',
                style: AppTypography.bodyMedium(isDark),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Streak Hero Card
              SolidWellnessCard(
                padding: const EdgeInsets.all(20.0),
                backgroundColor: isDark ? const Color(0xFF262D24) : const Color(0xFFF3FBE8),
                border: Border.all(
                  color: isDark ? const Color(0xFF384635) : const Color(0xFFD6F3A5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.textPrimaryLight,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '14-Day Perfect Streak',
                            style: AppTypography.h3(isDark).copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'You have met all primary wellness targets 14 consecutive days.',
                            style: AppTypography.caption(isDark).copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Habit Consistency Grid
              SolidWellnessCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '30-Day Activity Consistency',
                      style: AppTypography.h3(isDark),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(30, (index) {
                        final isCompleted = index % 5 != 0;
                        return Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkSurfaceSubtle
                                    : AppColors.lightSurfaceSubtle),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 0.5,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Less active', style: AppTypography.caption(isDark)),
                        Row(
                          children: [
                            Container(width: 12, height: 12, color: AppColors.lightSurfaceSubtle),
                            const SizedBox(width: 4),
                            Container(width: 12, height: 12, color: AppColors.primaryLight),
                            const SizedBox(width: 4),
                            Container(width: 12, height: 12, color: AppColors.primary),
                          ],
                        ),
                        Text('Goal achieved', style: AppTypography.caption(isDark)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Habit Breakdown Cards
              Text(
                'Active Routines',
                style: AppTypography.h2(isDark).copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...provider.habits.map((habit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SolidWellnessCard(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark ? habit.color.withOpacity(0.18) : habit.color.withOpacity(0.12),
                            borderRadius: AppRadii.roundedMd,
                          ),
                          child: Icon(habit.icon, color: habit.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(habit.title, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                              const SizedBox(height: 2),
                              Text('${habit.streakDays} day streak • ${habit.category}', style: AppTypography.caption(isDark)),
                            ],
                          ),
                        ),
                        CircularProgressRing(
                          progress: (habit.streakDays / 21.0).clamp(0.1, 1.0),
                          size: 38,
                          strokeWidth: 4.5,
                          progressColor: habit.color,
                          trackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
    );
  }
}
