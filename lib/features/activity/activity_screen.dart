import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/circular_progress_ring.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../core/services/pedometer_service.dart';
import '../../domain/state/wellness_provider.dart';
import '../wearables/wearables_hub_screen.dart';
import 'widgets/log_activity_sheet.dart';

/// Activity Screen detailing live step counting, cadence, distance, and workouts.
class ActivityScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ActivityScreen({super.key, required this.onBack});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  StreamSubscription? _stepSub;

  @override
  void initState() {
    super.initState();
    _stepSub = PedometerService.instance.stepStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final distanceKm = PedometerService.calculateDistanceKm(provider.steps).toStringAsFixed(2);
    final stepProgress = (provider.steps / provider.stepGoal.toDouble()).clamp(0.0, 1.0);
    final activeMinutes = (provider.exerciseHours * 60).toInt();
    final burnedKcal = PedometerService.calculateActiveCalories(provider.steps);
    final isPedometerActive = PedometerService.instance.isTracking;

    final workoutTypes = [
      {'name': 'Walking', 'duration': 30, 'cals': 150, 'steps': 2700, 'icon': Icons.directions_walk_rounded, 'color': AppColors.stepsOrange},
      {'name': 'Running', 'duration': 25, 'cals': 260, 'steps': 3100, 'icon': Icons.directions_run_rounded, 'color': AppColors.heartRed},
      {'name': 'Cycling', 'duration': 40, 'cals': 320, 'steps': 1200, 'icon': Icons.directions_bike_rounded, 'color': AppColors.waterBlue},
      {'name': 'Gym & Weights', 'duration': 45, 'cals': 220, 'steps': 800, 'icon': Icons.fitness_center_rounded, 'color': AppColors.primaryDark},
      {'name': 'Yoga / Stretch', 'duration': 20, 'cals': 85, 'steps': 400, 'icon': Icons.self_improvement_rounded, 'color': AppColors.sleepPurple},
      {'name': 'HIIT Cardio', 'duration': 20, 'cals': 210, 'steps': 2200, 'icon': Icons.bolt_rounded, 'color': AppColors.nutritionGold},
    ];

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
              title: 'Activity & Movement',
              subtitle: 'Daily Energy & Steps',
              onLeadingTap: widget.onBack,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.watch_rounded, size: 22),
                    tooltip: 'Wearable Sync',
                    color: const Color(0xFF10B981),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (ctx) => WearablesHubScreen(onBack: () => Navigator.of(ctx).pop()),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showLogActivitySheet(context, provider),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Log', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.stepsOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
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
                    // 1. Activity Hero Card
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
                                Text(
                                  'Target: ${provider.stepGoal} steps • ${(stepProgress * 100).toInt()}% completed',
                                  style: AppTypography.caption(isDark),
                                ),
                              ],
                            ),
                          ),
                          CircularProgressRing(
                            progress: stepProgress,
                            size: 78,
                            strokeWidth: 8.5,
                            progressColor: AppColors.stepsOrange,
                            trackColor: isDark ? AppColors.darkBorder : AppColors.stepsOrangeTint,
                            centerPrimaryText: '${(stepProgress * 100).toInt()}%',
                            centerSecondaryText: 'Goal',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 2. Metrics 3-Column Strip
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            isDark: isDark,
                            icon: Icons.place_rounded,
                            color: AppColors.stepsOrange,
                            label: 'Distance',
                            value: '$distanceKm km',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricTile(
                            isDark: isDark,
                            icon: Icons.timer_outlined,
                            color: AppColors.waterBlue,
                            label: 'Active Time',
                            value: '$activeMinutes min',
                          ),
                        ),
                        const SizedBox(width: 8),
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
                    const SizedBox(height: AppSpacing.md),

                    // 3. Live Pedometer & Cadence Section
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.stepsOrange.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.directions_walk_rounded,
                                  color: AppColors.stepsOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Live Pedometer & Cadence',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      isPedometerActive
                                          ? 'Cadence: ${provider.cadenceSpm} SPM • ${PedometerService.instance.paceCategory.label}'
                                          : 'Pedometer tracking is idle',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isPedometerActive
                                            ? AppColors.stepsOrange
                                            : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (isPedometerActive) {
                                    PedometerService.instance.stopTracking(provider);
                                  } else {
                                    PedometerService.instance.startTracking(provider, simulation: true);
                                  }
                                  setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPedometerActive
                                      ? const Color(0xFFEF4444)
                                      : AppColors.stepsOrange,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadii.roundedPill,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: Text(isPedometerActive ? 'Pause' : 'Start Walk'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Simulation quick action
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  PedometerService.instance.simulateBurstWalk(provider, 250);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.bolt_rounded, size: 16),
                                label: const Text('+250 Steps', style: TextStyle(fontSize: 11)),
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  PedometerService.instance.simulateBurstWalk(provider, 1000);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.directions_run_rounded, size: 16),
                                label: const Text('+1,000 Steps', style: TextStyle(fontSize: 11)),
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 4. Section: Log Workouts
                    Text('Log Workout Disciplines', style: AppTypography.h3(isDark)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Select a discipline to configure minutes and intensity', style: AppTypography.caption(isDark)),
                    const SizedBox(height: AppSpacing.sm),

                    ...workoutTypes.map((w) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SolidWellnessCard(
                          onTap: () {
                            showLogActivitySheet(context, provider, initialDiscipline: w['name'] as String);
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: (w['color'] as Color).withValues(alpha: 0.16),
                                  borderRadius: AppRadii.roundedMd,
                                ),
                                child: Icon(
                                  w['icon'] as IconData,
                                  color: w['color'] as Color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      w['name'] as String,
                                      style: AppTypography.bodyMedium(isDark).copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Avg ${w['duration']} min • ~${w['cals']} kcal',
                                      style: AppTypography.caption(isDark),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                size: 18,
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

  Widget _buildMetricTile({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
