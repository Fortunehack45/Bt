import 'package:flutter/material.dart';
import '../core/glass/platform_glass_bottom_sheet.dart';
import '../core/glass/platform_glass_navigation_bar.dart';
import '../core/glass/platform_glass_quick_action_panel.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/haptic_service.dart';
import '../domain/state/wellness_provider.dart';
import '../features/activity/activity_screen.dart';
import '../features/habits/habits_screen.dart';
import '../features/home/home_screen.dart';
import '../features/hydration/hydration_screen.dart';
import '../features/nutrition/nutrition_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/settings_screen.dart';
import '../features/sleep/sleep_screen.dart';
import '../features/statistics/statistics_screen.dart';

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
            HapticService.success();
            provider.addWaterGlass(1);
            _showFeedback(context, 'Added 250 ml of water (Total: ${provider.waterGlasses} glasses)');
          },
          onLogActivity: () {
            _showLogActivityDialog(context, provider);
          },
          onAddMeal: () {
            _showAddMealDialog(context, provider);
          },
          onLogSleep: () {
            _showLogSleepDialog(context, provider);
          },
          onAddHabit: () {
            _showAddHabitDialog(context, provider);
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

  void _showAddMealDialog(BuildContext context, WellnessProvider provider) {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    String selectedMealType = 'Breakfast';

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Log Meal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedMealType,
                    items: const [
                      DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                      DropdownMenuItem(value: 'Lunch time', child: Text('Lunch')),
                      DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                      DropdownMenuItem(value: 'Healthy Snack', child: Text('Snack')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedMealType = val);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Meal Type'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Meal Name',
                      hintText: 'e.g. Oatmeal & Blueberries',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Calories (kcal)',
                      hintText: 'e.g. 350',
                    ),
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
                    final name = nameController.text.trim().isNotEmpty
                        ? nameController.text.trim()
                        : selectedMealType;
                    final cals = int.tryParse(caloriesController.text) ?? 250;
                    provider.addMeal(name, selectedMealType, cals, 'Logged today');
                    Navigator.of(ctx).pop();
                    _showFeedback(context, 'Meal recorded: $name ($cals kcal)');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Save Meal', style: TextStyle(color: AppColors.textPrimaryLight)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddHabitDialog(BuildContext context, WellnessProvider provider) {
    final titleController = TextEditingController();
    String selectedCategory = 'Mindfulness';

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('New Wellness Habit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Habit Title',
                      hintText: 'e.g. 10m Morning Sunlight',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    items: const [
                      DropdownMenuItem(value: 'Hydration', child: Text('Hydration')),
                      DropdownMenuItem(value: 'Activity', child: Text('Activity')),
                      DropdownMenuItem(value: 'Mindfulness', child: Text('Mindfulness')),
                      DropdownMenuItem(value: 'Sleep', child: Text('Sleep')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedCategory = val);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
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
                    if (titleController.text.trim().isNotEmpty) {
                      final icon = selectedCategory == 'Hydration'
                          ? Icons.water_drop_rounded
                          : (selectedCategory == 'Activity'
                              ? Icons.directions_run_rounded
                              : (selectedCategory == 'Sleep'
                                  ? Icons.bedtime_rounded
                                  : Icons.spa_rounded));
                      final color = selectedCategory == 'Hydration'
                          ? AppColors.waterBlue
                          : (selectedCategory == 'Activity'
                              ? AppColors.stepsOrange
                              : (selectedCategory == 'Sleep'
                                  ? AppColors.sleepPurple
                                  : AppColors.primaryDark));

                      provider.addHabit(titleController.text.trim(), selectedCategory, icon, color);
                      Navigator.of(ctx).pop();
                      _showFeedback(context, 'Habit "${titleController.text.trim()}" activated!');
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Create', style: TextStyle(color: AppColors.textPrimaryLight)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogActivityDialog(BuildContext context, WellnessProvider provider) {
    final titleController = TextEditingController(text: 'Outdoor Walk');
    final durationController = TextEditingController(text: '30');
    final caloriesController = TextEditingController(text: '160');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Log Workout / Activity'),
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
                _showFeedback(context, 'Logged ${titleController.text} (${mins.toInt()} mins, +$cals kcal)');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save', style: TextStyle(color: AppColors.textPrimaryLight)),
            ),
          ],
        );
      },
    );
  }

  void _showLogSleepDialog(BuildContext context, WellnessProvider provider) {
    final hoursController = TextEditingController(text: '7.5');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Log Sleep Duration'),
          content: TextField(
            controller: hoursController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Hours of Sleep',
              hintText: 'e.g. 7.5',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final hrs = double.tryParse(hoursController.text) ?? 7.0;
                provider.logSleep(hrs);
                Navigator.of(ctx).pop();
                _showFeedback(context, 'Sleep logged: $hrs hours (Quality score: ${provider.sleepScore}%)');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save', style: TextStyle(color: AppColors.textPrimaryLight)),
            ),
          ],
        );
      },
    );
  }

  void _showRecordBpmDialog(BuildContext context, WellnessProvider provider) {
    final bpmController = TextEditingController(text: '74');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Record Heart Rate (BPM)'),
          content: TextField(
            controller: bpmController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Resting BPM',
              hintText: 'e.g. 72',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final bpm = int.tryParse(bpmController.text) ?? 72;
                provider.recordBpm(bpm);
                Navigator.of(ctx).pop();
                _showFeedback(context, 'Resting heart rate recorded: $bpm bpm');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save', style: TextStyle(color: AppColors.textPrimaryLight)),
            ),
          ],
        );
      },
    );
  }

  void _showRecordWeightDialog(BuildContext context, WellnessProvider provider) {
    final weightController = TextEditingController(text: '68.0');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Record Body Weight'),
          content: TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              hintText: 'e.g. 68.0',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final w = double.tryParse(weightController.text) ?? 68.0;
                provider.setWeight(w);
                Navigator.of(ctx).pop();
                _showFeedback(context, 'Weight updated: $w kg');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save', style: TextStyle(color: AppColors.textPrimaryLight)),
            ),
          ],
        );
      },
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
        onAddMeal: () => _showAddMealDialog(context, provider),
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
        onBpmTap: () => _showRecordBpmDialog(context, provider),
        onWeightTap: () => _showRecordWeightDialog(context, provider),
        onWaterTap: () => _navigateToSubpage(context, HydrationScreen(onBack: () => Navigator.of(context).pop())),
      ),

      // 2: Habits
      HabitsScreen(
        onAddHabit: () => _showAddHabitDialog(context, provider),
      ),

      // 3: Profile
      ProfileScreen(
        onOpenSettings: () => _navigateToSubpage(context, SettingsScreen(onBack: () => Navigator.of(context).pop())),
        onOpenHydration: () => _navigateToSubpage(context, HydrationScreen(onBack: () => Navigator.of(context).pop())),
        onOpenActivity: () => _navigateToSubpage(context, ActivityScreen(onBack: () => Navigator.of(context).pop())),
        onOpenSleep: () => _navigateToSubpage(context, SleepScreen(onBack: () => Navigator.of(context).pop())),
        onOpenNutrition: () => _navigateToSubpage(context, NutritionScreen(onBack: () => Navigator.of(context).pop(), onAddMeal: () => _showAddMealDialog(context, provider))),
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
