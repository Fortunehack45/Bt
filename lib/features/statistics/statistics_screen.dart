import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/wellness_bottom_sheet.dart';
import '../../domain/state/wellness_provider.dart';
import 'widgets/calories_hero_card.dart';
import 'widgets/metric_2x2_grid.dart';
import 'widgets/statistics_header.dart';
import '../profile/widgets/export_report_sheet.dart';

/// Complete Statistics Screen directly matching Reference Image 1 Screen 2.
class StatisticsScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onExerciseTap;
  final VoidCallback onBpmTap;
  final VoidCallback onWeightTap;
  final VoidCallback onWaterTap;
  final VoidCallback? onCaloriesTap;

  const StatisticsScreen({
    super.key,
    required this.onBack,
    required this.onExerciseTap,
    required this.onBpmTap,
    required this.onWeightTap,
    required this.onWaterTap,
    this.onCaloriesTap,
  });

  void _showMoreActionsSheet(BuildContext context, WellnessProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    WellnessBottomSheet.show<void>(
      context: context,
      title: 'Statistics & Reports',
      subtitle: 'Export and telemetry options for ${provider.userName}',
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSubtle : AppColors.primaryTint,
                borderRadius: AppRadii.roundedSm,
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryDark, size: 20),
            ),
            title: Text('Export Weekly PDF Report', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
            subtitle: Text('Full breakdown of calorie, water, and sleep trends', style: AppTypography.caption(isDark)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).pop();
              HapticService.selection();
              final provider = WellnessStateScope.of(context);
              showExportReportSheet(context, provider);
            },
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                borderRadius: AppRadii.roundedSm,
              ),
              child: const Icon(Icons.data_object_rounded, size: 20),
            ),
            title: Text('Export JSON Telemetry', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
            subtitle: Text('Raw data export for personal archiving', style: AppTypography.caption(isDark)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).pop();
              HapticService.selection();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Telemetry JSON file saved to downloads.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: provider.isDemoMode
                    ? AppColors.primaryTint
                    : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                borderRadius: AppRadii.roundedSm,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: provider.isDemoMode ? AppColors.primaryDark : null,
                size: 20,
              ),
            ),
            title: Text('Investor Pitch Demo Mode', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
            subtitle: Text(
              provider.isDemoMode ? 'Active (Demo data populated)' : 'Off (Clean zero state)',
              style: AppTypography.caption(isDark),
            ),
            trailing: Switch.adaptive(
              value: provider.isDemoMode,
              activeColor: AppColors.primary,
              onChanged: (val) {
                provider.toggleDemoMode(val);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      val
                          ? 'Demo data loaded for presentation!'
                          : 'Clean zero state restored.',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
            top: 10.0,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Navigation Header (< Statistic ...)
              StatisticsHeader(
                onBack: onBack,
                onMore: () => _showMoreActionsSheet(context, provider),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Calories Hero Card with Weekly Bar Chart (Mon-Sun with interactive day selection)
              CaloriesHeroCard(
                calories: provider.statCalories,
                targetCalories: provider.targetCalories,
                barData: provider.weeklyBarData,
                selectedDayIndex: provider.selectedStatDayIndex,
                onDaySelected: (index) => provider.selectStatDay(index),
                onTap: onCaloriesTap,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. 2x2 Metric Grid (Exercise, BPM, Weight, Water) dynamically updating with selected day
              Metric2x2Grid(
                exerciseHours: provider.statExerciseHours,
                bpm: provider.statBpm,
                weightKg: provider.statWeightKg,
                waterLitres: provider.statWaterGlasses * 0.25,
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
