import 'package:flutter/material.dart';
import '../../core/glass/platform_glass_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/circular_progress_ring.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';

/// Activity Screen detailing steps, active minutes, workout categories,
/// and fitness pacing.
class ActivityScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ActivityScreen({super.key, required this.onBack});

  void _showLogCustomWorkoutDialog(BuildContext context, WellnessProvider provider) {
    final titleController = TextEditingController(text: 'Outdoor Walk');
    final durationController = TextEditingController(text: '30');
    final caloriesController = TextEditingController(text: '160');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Log Workout Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Activity Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories Burned (kcal)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final mins = double.tryParse(durationController.text) ?? 30.0;
                final cals = int.tryParse(caloriesController.text) ?? 150;
                final estimatedSteps = (mins * 90).toInt();
                provider.logActivity(mins / 60.0, cals, estimatedSteps);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged ${titleController.text} (${mins.toInt()} mins, +$cals kcal)'), duration: const Duration(seconds: 1)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.stepsOrange),
              child: const Text('Save Workout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final distanceKm = (provider.steps * 0.00078).toStringAsFixed(2);
    final stepProgress = (provider.steps / provider.stepGoal.toDouble()).clamp(0.0, 1.0);
    final activeMinutes = (provider.exerciseHours * 60).toInt();
    final burnedKcal = (provider.steps * 0.04).toInt();

    final workoutTypes = [
      {'name': 'Outdoor Walk', 'duration': 30, 'cals': 150, 'steps': 2700, 'icon': Icons.directions_walk_rounded, 'color': AppColors.stepsOrange},
      {'name': 'Running Session', 'duration': 25, 'cals': 260, 'steps': 3100, 'icon': Icons.directions_run_rounded, 'color': AppColors.heartRed},
      {'name': 'Cycling Ride', 'duration': 40, 'cals': 320, 'steps': 1200, 'icon': Icons.directions_bike_rounded, 'color': AppColors.waterBlue},
      {'name': 'Strength Training', 'duration': 45, 'cals': 220, 'steps': 800, 'icon': Icons.fitness_center_rounded, 'color': AppColors.primaryDark},
      {'name': 'Yoga & Stretch', 'duration': 20, 'cals': 85, 'steps': 400, 'icon': Icons.self_improvement_rounded, 'color': AppColors.sleepPurple},
      {'name': 'HIIT Cardio', 'duration': 20, 'cals': 210, 'steps': 2200, 'icon': Icons.bolt_rounded, 'color': AppColors.nutritionGold},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
            top: AppSpacing.xs,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar Header
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
                  Text('Activity & Movement', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => _showLogCustomWorkoutDialog(context, provider),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Log', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.stepsOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Activity Hero Card
              SolidWellnessCard(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DAILY MOVEMENT GOAL', style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          )),
                          const SizedBox(height: 6),
                          Text('${provider.steps} steps', style: AppTypography.displayMedium(isDark).copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          )),
                          const SizedBox(height: 4),
                          Text('Goal: ${provider.stepGoal} steps', style: AppTypography.bodyMedium(isDark)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.stepsOrange.withOpacity(0.2) : AppColors.stepsOrangeTint,
                              borderRadius: AppRadii.roundedPill,
                            ),
                            child: Text(
                              '$distanceKm km covered today',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.stepsOrange,
                              ),
                            ),
                          ),
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
                      centerSecondaryText: 'Pace',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Movement Triad Metric Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      isDark: isDark,
                      icon: Icons.directions_walk_rounded,
                      color: AppColors.stepsOrange,
                      label: 'Distance',
                      value: '$distanceKm km',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildMetricTile(
                      isDark: isDark,
                      icon: Icons.timer_outlined,
                      color: AppColors.waterBlue,
                      label: 'Active Time',
                      value: '$activeMinutes min',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildMetricTile(
                      isDark: isDark,
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.heartRed,
                      label: 'Burned',
                      value: '$burnedKcal kcal',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Section: 1-Tap Quick Workout Logging
              Text('Quick Workout Disciplines', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.xs),
              Text('Tap any activity to instantly log your session:', style: AppTypography.caption(isDark)),
              const SizedBox(height: AppSpacing.sm),
              ...workoutTypes.map((w) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SolidWellnessCard(
                    onTap: () {
                      HapticService.success();
                      provider.logActivity(
                        (w['duration'] as int) / 60.0,
                        w['cals'] as int,
                        w['steps'] as int,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logged ${w['name']} (+${w['cals']} kcal, +${w['steps']} steps)!'), duration: const Duration(seconds: 1)),
                      );
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (w['color'] as Color).withOpacity(0.16),
                            borderRadius: AppRadii.roundedMd,
                          ),
                          child: Icon(w['icon'] as IconData, color: w['color'] as Color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w['name'] as String, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                              const SizedBox(height: 2),
                              Text('${w['duration']} min • ~${w['cals']} kcal • +${w['steps']} steps', style: AppTypography.caption(isDark)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                            borderRadius: AppRadii.roundedPill,
                          ),
                          child: const Text('+ Log', style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.stepsOrange,
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
    );
  }

  Widget _buildMetricTile({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(label, style: AppTypography.caption(isDark).copyWith(fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}
