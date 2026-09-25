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
  });
}
