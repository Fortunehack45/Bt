import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/state/wellness_provider.dart';
import 'widgets/calories_hero_card.dart';
import 'widgets/metric_2x2_grid.dart';
import 'widgets/statistics_header.dart';

/// Complete Statistics Screen directly matching Reference Image 1 Screen 2.
class StatisticsScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onExerciseTap;
  final VoidCallback onBpmTap;
  final VoidCallback onWeightTap;
  final VoidCallback onWaterTap;

  const StatisticsScreen({
    super.key,
    required this.onBack,
    required this.onExerciseTap,
    required this.onBpmTap,
    required this.onWeightTap,
    required this.onWaterTap,
  });

  @override
  Widget build(BuildContext context) {
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
            top: AppSpacing.sm,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Navigation Header (< Statistic ...)
              StatisticsHeader(
                onBack: onBack,
                onMore: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exporting telemetry & weekly health PDF report...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Calories Hero Card with Weekly Bar Chart (Mon-Sun, Wednesday highlighted)
              CaloriesHeroCard(
                calories: provider.calories,
                targetCalories: provider.targetCalories,
                barData: provider.weeklyBarData,
                selectedDayIndex: provider.selectedStatDayIndex,
                onDaySelected: (index) => provider.selectStatDay(index),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. 2x2 Metric Grid (Exercise, BPM, Weight, Water)
              Metric2x2Grid(
                exerciseHours: provider.exerciseHours,
                bpm: provider.bpm,
                weightKg: provider.weightKg,
                waterLitres: provider.waterGlasses * 0.25,
                onExerciseTap: onExerciseTap,
                onBpmTap: onBpmTap,
                onWeightTap: onWeightTap,
                onWaterTap: onWaterTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
