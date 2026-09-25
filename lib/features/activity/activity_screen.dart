import 'package:flutter/material.dart';
import '../../core/glass/platform_glass_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/circular_progress_ring.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';

/// Activity Screen detailing steps, active minutes, and workouts.
class ActivityScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ActivityScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final distanceKm = (provider.steps * 0.00078).toStringAsFixed(2);
    final stepProgress = (provider.steps / provider.stepGoal.toDouble()).clamp(0.0, 1.0);

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
            top: AppSpacing.sm,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PlatformGlassButton(
                    icon: Icons.chevron_left_rounded,
                    size: 42,
                    iconSize: 24,
                    tooltip: 'Back',
                    onTap: onBack,
                  ),
                  Text('Activity & Steps', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                  const SizedBox(width: 42),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Activity Hero Card
              SolidWellnessCard(
                padding: const EdgeInsets.all(22.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Goal', style: AppTypography.caption(isDark)),
                          const SizedBox(height: 4),
                          Text('${provider.steps} steps', style: AppTypography.h1(isDark).copyWith(fontSize: 26)),
                          const SizedBox(height: 4),
                          Text('Goal: ${provider.stepGoal} steps', style: AppTypography.bodyMedium(isDark)),
                          const SizedBox(height: 12),
                          Text('$distanceKm km walked today', style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.stepsOrange,
                          )),
                        ],
                      ),
                    ),
                    CircularProgressRing(
                      progress: stepProgress,
                      size: 96,
                      strokeWidth: 10,
                      progressColor: AppColors.stepsOrange,
                      trackColor: isDark ? const Color(0xFF382D24) : AppColors.stepsOrangeTint,
                      centerPrimaryText: '${(stepProgress * 100).toInt()}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 3-Metric Row (Distance, Time, Burn)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      isDark: isDark,
                      title: 'Distance',
                      value: '$distanceKm km',
                      icon: Icons.map_rounded,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildMetricTile(
                      isDark: isDark,
                      title: 'Workout',
                      value: '${provider.exerciseHours} hrs',
                      icon: Icons.fitness_center_rounded,
                      color: AppColors.exerciseGreen,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildMetricTile(
                      isDark: isDark,
                      title: 'Burned',
                      value: '${provider.calories} kcal',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.stepsOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Workout History
              Text('Today\'s Workouts', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.exerciseGreenTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_run_rounded, color: AppColors.exerciseGreen, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Outdoor Morning Run', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('35 mins • 4.2 km • 320 kcal', style: AppTypography.caption(isDark)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(title, style: AppTypography.caption(isDark)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.h3(isDark).copyWith(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
