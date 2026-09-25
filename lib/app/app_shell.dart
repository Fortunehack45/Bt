import 'package:flutter/material.dart';
import '../core/glass/platform_glass_bottom_sheet.dart';
import '../core/glass/platform_glass_navigation_bar.dart';
import '../core/glass/platform_glass_quick_action_panel.dart';
import '../core/utils/haptic_service.dart';
import '../domain/state/wellness_provider.dart';
import '../features/activity/activity_screen.dart';
import '../features/activity/widgets/log_activity_sheet.dart';
import '../features/habits/habits_screen.dart';
import '../features/habits/widgets/add_habit_sheet.dart';
import '../features/home/home_screen.dart';
import '../features/hydration/hydration_screen.dart';
import '../features/hydration/widgets/log_water_sheet.dart';
import '../features/nutrition/nutrition_screen.dart';
import '../features/nutrition/widgets/log_meal_sheet.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/settings_screen.dart';
import '../features/sleep/sleep_screen.dart';
import '../features/sleep/widgets/log_sleep_sheet.dart';
import '../features/statistics/statistics_screen.dart';
import '../features/vitality/bpm_screen.dart';
import '../features/vitality/weight_screen.dart';

/// The root application shell housing the floating platform-adaptive glass
/// navigation bar and managing top-level feature routing.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _onCentralActionPressed(BuildContext context) {
    final provider = WellnessStateScope.of(context);

    showPlatformGlassBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return PlatformGlassQuickActionPanel(
          onAddWater: () {
            showLogWaterSheet(context, provider);
          },
          onLogActivity: () {
            showLogActivitySheet(context, provider);
          },
          onAddMeal: () {
            showLogMealSheet(context, provider);
          },
          onLogSleep: () {
            showLogSleepSheet(context, provider);
          },
          onAddHabit: () {
            showAddHabitSheet(context, provider);
          },
        );
      },
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = WellnessStateScope.of(context);

    // Indexed Stack keeps state alive across tabs
    final pages = [
      // 0: Home
      HomeScreen(
        onNavigateToStats: () => setState(() => _currentIndex = 1),
        onNavigateToHydration: () => _navigateToSubpage(context, HydrationScreen(onBack: () => Navigator.of(context).pop())),
        onNavigateToActivity: () => _navigateToSubpage(context, ActivityScreen(onBack: () => Navigator.of(context).pop())),
        onNavigateToSleep: () => _navigateToSubpage(context, SleepScreen(onBack: () => Navigator.of(context).pop())),
        onNavigateToNutrition: () => _navigateToSubpage(context, NutritionScreen(onBack: () => Navigator.of(context).pop(), onAddMeal: () => showLogMealSheet(context, provider))),
        onAddMeal: () => showLogMealSheet(context, provider),
        onWaterQuickAdd: () {
          HapticService.success();
          provider.addWaterGlass(1);
          _showFeedback(context, 'Logged 1 glass of water (${provider.waterGlasses} total)');
        },
      ),

      // 1: Statistics
      StatisticsScreen(
        onBack: () => setState(() => _currentIndex = 0),
        onExerciseTap: () => _navigateToSubpage(context, ActivityScreen(onBack: () => Navigator.of(context).pop())),
        onBpmTap: () => _navigateToSubpage(context, BpmScreen(onBack: () => Navigator.of(context).pop())),
        onWeightTap: () => _navigateToSubpage(context, WeightScreen(onBack: () => Navigator.of(context).pop())),
        onWaterTap: () => _navigateToSubpage(context, HydrationScreen(onBack: () => Navigator.of(context).pop())),
        onCaloriesTap: () => _navigateToSubpage(context, NutritionScreen(onBack: () => Navigator.of(context).pop(), onAddMeal: () => showLogMealSheet(context, provider))),
      ),

      // 2: Habits
      HabitsScreen(
        onAddHabit: () => showAddHabitSheet(context, provider),
      ),

      // 3: Profile
      ProfileScreen(
        onOpenSettings: () => _navigateToSubpage(context, SettingsScreen(onBack: () => Navigator.of(context).pop())),
        onOpenHydration: () => _navigateToSubpage(context, HydrationScreen(onBack: () => Navigator.of(context).pop())),
        onOpenActivity: () => _navigateToSubpage(context, ActivityScreen(onBack: () => Navigator.of(context).pop())),
        onOpenSleep: () => _navigateToSubpage(context, SleepScreen(onBack: () => Navigator.of(context).pop())),
        onOpenNutrition: () => _navigateToSubpage(context, NutritionScreen(onBack: () => Navigator.of(context).pop(), onAddMeal: () => showLogMealSheet(context, provider))),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),

          // Floating Platform-Adaptive Glass Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PlatformGlassNavigationBar(
              currentIndex: _currentIndex,
              onIndexChanged: (newIndex) {
                setState(() => _currentIndex = newIndex);
              },
              onCentralActionPressed: () => _onCentralActionPressed(context),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSubpage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => page),
    );
  }
}
