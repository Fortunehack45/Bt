import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/state/wellness_provider.dart';
import '../../core/widgets/biothrix_calendar_sheet.dart';
import 'widgets/ai_readiness_sheet.dart';
import 'widgets/calendar_strip.dart';
import 'widgets/home_header.dart';
import 'widgets/meal_tracker_section.dart';
import 'widgets/metric_summary_grid.dart';
import 'widgets/recommendations_carousel.dart';
import 'widgets/weekly_progress_hero_card.dart';

/// Complete Home Dashboard screen matching Reference Image 1 Screen 1.
/// Features a 2x2 wellness grid linking directly to Hydration, Activity, Sleep, and Nutrition,
/// plus a fully functional dynamic calendar with week navigation and custom slide-up calendar sheet.
class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToStats;
  final VoidCallback onNavigateToHydration;
  final VoidCallback onNavigateToActivity;
  final VoidCallback onNavigateToSleep;
  final VoidCallback onNavigateToNutrition;
  final VoidCallback onAddMeal;
  final VoidCallback onWaterQuickAdd;
  final VoidCallback? onNavigateToProfile;

  const HomeScreen({
    super.key,
    required this.onNavigateToStats,
    required this.onNavigateToHydration,
    required this.onNavigateToActivity,
    required this.onNavigateToSleep,
    required this.onNavigateToNutrition,
    required this.onAddMeal,
    required this.onWaterQuickAdd,
    this.onNavigateToProfile,
  });

  void _openDatePicker(BuildContext context, WellnessProvider provider) {
    showBiothrixCalendarSheet(context, provider);
  }

  @override
  Widget build(BuildContext context) {
    final provider = WellnessStateScope.of(context);

    // Calculate real composite progress from current goals
    final calorieRatio = provider.targetCalories > 0
        ? (provider.calories / provider.targetCalories)
        : 0.0;
    final waterRatio = provider.waterGoal > 0
        ? (provider.waterGlasses / provider.waterGoal)
        : 0.0;
    final stepRatio = provider.stepGoal > 0
        ? (provider.steps / provider.stepGoal)
        : 0.0;

    final overallProgress = ((calorieRatio * 0.4) + (waterRatio * 0.3) + (stepRatio * 0.3))
        .clamp(0.0, 1.0);
    final completedDays = overallProgress >= 0.7 ? 1 : 0;

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
              // 1. Header (User avatar, greeting, name, glass utility buttons)
              HomeHeader(
                onProfileTap: onNavigateToProfile,
                onCalendarTap: () => _openDatePicker(context, provider),
                onRefreshTap: () => showAiWellnessInsightsSheet(context, provider),
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Weekly Progress Hero Card (Lime gradient, "Daily intake", ring)
              WeeklyProgressHeroCard(
                progress: overallProgress,
                completedDays: completedDays,
                onTap: onNavigateToStats,
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. 2x2 Metric Grid (Steps, Water, Sleep, Nutrition)
              MetricSummaryGrid(
                steps: provider.steps,
                waterGlasses: provider.waterGlasses,
                sleepHours: provider.sleepHours,
                calories: provider.calories,
                onStepsTap: onNavigateToActivity,
                onWaterTap: onNavigateToHydration,
                onSleepTap: onNavigateToSleep,
                onNutritionTap: onNavigateToNutrition,
              ),
              const SizedBox(height: AppSpacing.md),

              // 4. Interactive Weekly Calendar Strip
              CalendarStrip(
                selectedDate: provider.selectedDate,
                onDateSelected: (date) => provider.setSelectedDate(date),
                onPreviousWeek: () => provider.previousWeek(),
                onNextWeek: () => provider.nextWeek(),
                onOpenDatePicker: () => _openDatePicker(context, provider),
                telemetryProvider: (date) => provider.getDayTelemetry(date),
                snapshotProvider: (date) => provider.getMetricsForDate(date),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5. Meals Section (Breakfast & Lunch time solid cards or empty state)
              MealTrackerSection(
                meals: provider.meals,
                onAddMeal: onAddMeal,
              ),
              const SizedBox(height: AppSpacing.sm),

              // 6. Daily Recommendations Carousel
              const RecommendationsCarousel(),
            ],
          ),
        ),
      ),
    );
  }
}
