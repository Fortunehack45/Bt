import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biothrix/domain/state/wellness_provider.dart';

void main() {
  group('Biothrix WellnessProvider Fresh User Tests', () {
    late WellnessProvider provider;

    setUp(() {
      provider = WellnessProvider();
    });

    test('Fresh user initializes with clean zero state', () {
      expect(provider.steps, 0);
      expect(provider.waterGlasses, 0);
      expect(provider.calories, 0);
      expect(provider.exerciseHours, 0.0);
      expect(provider.bpm, 0);
      expect(provider.weightKg, 0.0);
      expect(provider.sleepHours, 0.0);
      expect(provider.habits, isEmpty);
      expect(provider.meals, isEmpty);
      expect(provider.userName, 'Wellness Explorer');
    });

    test('setUserName personalizes user profile', () {
      provider.setUserName('Alex Rivers');
      expect(provider.userName, 'Alex Rivers');
      expect(provider.isProfileConfigured, true);
    });

    test('addWaterGlass increments water intake', () {
      provider.addWaterGlass(2);
      expect(provider.waterGlasses, 2);
    });

    test('addHabit creates a new habit in clean state', () {
      provider.addHabit(
        'Morning Sunlight',
        'Mindfulness',
        Icons.wb_sunny_rounded,
        Colors.amber,
      );

      expect(provider.habits.length, 1);
      expect(provider.habits.first.title, 'Morning Sunlight');
      expect(provider.habits.first.isCompletedToday, false);
      expect(provider.habits.first.streakDays, 0);

      // Toggling increments streak
      provider.toggleHabit(provider.habits.first.id);
      expect(provider.habits.first.isCompletedToday, true);
      expect(provider.habits.first.streakDays, 1);
    });

    test('addMeal adds to meal list and increases calories', () {
      provider.addMeal('Avocado Toast', 'Breakfast', 380, 'Fresh healthy fats');
      expect(provider.meals.length, 1);
      expect(provider.calories, 380);
    });

    test('logActivity records workout and steps', () {
      provider.logActivity(0.5, 200, 2500);
      expect(provider.exerciseHours, 0.5);
      expect(provider.calories, 200);
      expect(provider.steps, 2500);
    });

    test('Theme toggle switches between light and dark mode', () {
      expect(provider.themeMode, ThemeMode.light);
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, true);
    });

    test('Calendar week navigation and date selection work seamlessly', () {
      final initialDate = provider.selectedDate;
      provider.nextWeek();
      expect(provider.selectedDate.isAfter(initialDate), true);
      provider.previousWeek();
      expect(provider.selectedDate.day, initialDate.day);

      final customDate = DateTime(2026, 10, 15);
      provider.setSelectedDate(customDate);
      expect(provider.selectedDate, customDate);

      provider.jumpToToday();
      expect(provider.selectedDate.year, DateTime.now().year);
    });

    test('removeMeal decrements calories and removes entry', () {
      provider.addMeal('Oatmeal', 'Breakfast', 300, 'Healthy breakfast');
      expect(provider.meals.length, 1);
      expect(provider.calories, 300);

      final mealId = provider.meals.first.id;
      provider.removeMeal(mealId);
      expect(provider.meals, isEmpty);
      expect(provider.calories, 0);
    });

    test('resetAllData clears all telemetry back to clean state', () {
      provider.addSteps(5000);
      provider.addWaterGlass(4);
      provider.addMeal('Salad', 'Lunch', 450, 'Green salad');
      provider.logSleep(8.0);

      expect(provider.steps, 5000);
      provider.resetAllData();
      expect(provider.steps, 0);
      expect(provider.waterGlasses, 0);
      expect(provider.calories, 0);
      expect(provider.sleepHours, 0.0);
      expect(provider.meals, isEmpty);
    });

    test('Investor Demo Mode populates data while strictly preserving user name', () {
      provider.setUserName('Fortune');
      expect(provider.userName, 'Fortune');

      // Turn on demo mode
      provider.toggleDemoMode(true);
      expect(provider.isDemoMode, true);
      expect(provider.userName, 'Fortune'); // Preserved!
      expect(provider.steps, 8420);
      expect(provider.waterGlasses, 7);
      expect(provider.calories, 1775);
      expect(provider.habits.length, 5);
      expect(provider.meals.length, 4);

      // Turn off demo mode
      provider.toggleDemoMode(false);
      expect(provider.isDemoMode, false);
      expect(provider.userName, 'Fortune'); // Still preserved!
      expect(provider.steps, 0);
      expect(provider.habits, isEmpty);
      expect(provider.meals, isEmpty);
    });

    test('Weekly statistics chart populates all 7 days with interactive selection in demo mode', () {
      provider.toggleDemoMode(true);

      // Verify all 7 days have varying non-zero percentages and calories
      final barData = provider.weeklyBarData;
      expect(barData.length, 7);
      expect(barData[0].value, 1840); // Mon (92%)
      expect(barData[1].value, 2120); // Tue (106%)
      expect(barData[2].value, 1960); // Wed (98%)
      expect(barData[3].value, 1775); // Thu (88%)
      expect(barData[4].value, 2250); // Fri (112%)
      expect(barData[5].value, 2380); // Sat (119%)
      expect(barData[6].value, 1690); // Sun (84%)

      // Selecting Wednesday (index 2) updates interactive stat metrics
      provider.selectStatDay(2);
      expect(provider.statCalories, 1960);
      expect(provider.statExerciseHours, 4.0);
      expect(provider.statBpm, 73);
      expect(provider.statWeightKg, 69.3);
      expect(provider.statWaterGlasses, 8);

      // Selecting Monday (index 0) updates interactive stat metrics
      provider.selectStatDay(0);
      expect(provider.statCalories, 1840);
      expect(provider.statExerciseHours, 3.5);
      expect(provider.statBpm, 71);
      expect(provider.statWeightKg, 69.5);
      expect(provider.statWaterGlasses, 7);
    });

    test('Past dates have full multi-colored telemetry and historical snapshots in demo mode', () {
      provider.toggleDemoMode(true);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));

      // Telemetry dots active for past days
      final yTelemetry = provider.getDayTelemetry(yesterday);
      expect(yTelemetry.hasNutrition, true);
      expect(yTelemetry.hasWater, true);
      expect(yTelemetry.hasActivity, true);
      expect(yTelemetry.hasSleep, true);

      // getMetricsForDate returns rich data for past days
      final yMetrics = provider.getMetricsForDate(yesterday);
      expect(yMetrics.calories > 0, true);
      expect(yMetrics.waterGlasses > 0, true);
      expect(yMetrics.steps > 0, true);
      expect(yMetrics.sleepHours > 0, true);

      final threeDaysMetrics = provider.getMetricsForDate(threeDaysAgo);
      expect(threeDaysMetrics.calories > 0, true);
      expect(threeDaysMetrics.steps > 0, true);
    });
  });
}


