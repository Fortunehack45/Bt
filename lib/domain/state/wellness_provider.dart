import 'package:flutter/material.dart';
import '../../core/widgets/weekly_bar_chart.dart';
import '../models/wellness_models.dart';

/// Central reactive state store for Biothrix Wellness.
/// Clean state with ZERO hardcoded demo data — all users start fresh.
class WellnessProvider extends ChangeNotifier {
  // User Profile
  String _userName = 'Wellness Explorer';
  String get userName => _userName;
  bool _isProfileConfigured = false;
  bool get isProfileConfigured => _isProfileConfigured;

  void setUserName(String name) {
    if (name.trim().isNotEmpty) {
      _userName = name.trim();
      _isProfileConfigured = true;
      notifyListeners();
    }
  }

  // Theme Mode
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Selected Date in Calendar Strip (3 is current day by default)
  int _selectedCalendarDayIndex = 3;
  int get selectedCalendarDayIndex => _selectedCalendarDayIndex;

  void selectCalendarDay(int index) {
    _selectedCalendarDayIndex = index;
    notifyListeners();
  }

  // Steps & Activity (Starts Fresh at 0)
  int _steps = 0;
  int get steps => _steps;
  int _stepGoal = 10000;
  int get stepGoal => _stepGoal;

  void setStepGoal(int goal) {
    if (goal > 0) {
      _stepGoal = goal;
      notifyListeners();
    }
  }

  void addSteps(int count) {
    _steps += count;
    notifyListeners();
  }

  // Water Hydration (Starts Fresh at 0)
  int _waterGlasses = 0;
  int get waterGlasses => _waterGlasses;
  int _waterGoal = 8; // 8 glasses = 2.0 Litres standard
  int get waterGoal => _waterGoal;

  void setWaterGoal(int goal) {
    if (goal > 0) {
      _waterGoal = goal;
      notifyListeners();
    }
  }

  void addWaterGlass([int amount = 1]) {
    _waterGlasses += amount;
    notifyListeners();
  }

  void resetWater() {
    _waterGlasses = 0;
    notifyListeners();
  }

  // Calories & Energy (Starts Fresh at 0)
  int _calories = 0;
  int get calories => _calories;
  int _targetCalories = 2000;
  int get targetCalories => _targetCalories;

  void setTargetCalories(int target) {
    if (target > 0) {
      _targetCalories = target;
      notifyListeners();
    }
  }

  double _exerciseHours = 0.0;
  double get exerciseHours => _exerciseHours;

  int _bpm = 0; // 0 indicates no sensor reading recorded yet
  int get bpm => _bpm;

  double _weightKg = 0.0; // 0.0 indicates not yet logged
  double get weightKg => _weightKg;

  void setWeight(double weight) {
    _weightKg = weight;
    notifyListeners();
  }

  void recordBpm(int value) {
    _bpm = value;
    notifyListeners();
  }

  // Weekly Statistics Bar Data (Starts Fresh: 0% until user logs)
  int _selectedStatDayIndex = 3; // Today
  int get selectedStatDayIndex => _selectedStatDayIndex;

  List<DayBarData> get weeklyBarData {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (index) {
      final isToday = index == _selectedStatDayIndex;
      final val = isToday ? _calories : 0;
      final pct = _targetCalories > 0 ? ((val / _targetCalories) * 100).toInt() : 0;
      return DayBarData(
        dayName: days[index],
        percentage: pct,
        value: val,
      );
    });
  }

  void selectStatDay(int index) {
    _selectedStatDayIndex = index;
    notifyListeners();
  }

  // Habits State (Starts Fresh: Empty List)
  List<HabitItem> _habits = [];
  List<HabitItem> get habits => _habits;

  void toggleHabit(String id) {
    _habits = _habits.map((habit) {
      if (habit.id == id) {
        final newStatus = !habit.isCompletedToday;
        return habit.copyWith(
          isCompletedToday: newStatus,
          streakDays: newStatus ? habit.streakDays + 1 : (habit.streakDays > 0 ? habit.streakDays - 1 : 0),
        );
      }
      return habit;
    }).toList();
    notifyListeners();
  }

  void addHabit(String title, String category, IconData icon, Color color) {
    final newHabit = HabitItem(
      id: 'h_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      icon: icon,
      color: color,
      streakDays: 0,
      isCompletedToday: false,
    );
    _habits = [newHabit, ..._habits];
    notifyListeners();
  }

  void removeHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  // Meals State (Starts Fresh: Empty List)
  List<MealEntry> _meals = [];
  List<MealEntry> get meals => _meals;

  void addMeal(String name, String mealType, int calories, String description) {
    final newMeal = MealEntry(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      mealType: mealType,
      calories: calories,
      timeString: 'Just now',
      description: description,
    );
    _meals = [..._meals, newMeal];
    _calories += calories;
    notifyListeners();
  }

  // Sleep State (Starts Fresh at 0)
  double _sleepHours = 0.0;
  double get sleepHours => _sleepHours;
  int _sleepScore = 0;
  int get sleepScore => _sleepScore;

  void logSleep(double hours) {
    _sleepHours = hours;
    _sleepScore = ((hours / 8.0) * 100).clamp(0, 100).toInt();
    notifyListeners();
  }

  // Activity Logging
  void logActivity(double hours, int caloriesBurned, int stepsCount) {
    _exerciseHours += hours;
    _calories += caloriesBurned;
    _steps += stepsCount;
    notifyListeners();
  }
}

/// An InheritedNotifier providing access to the reactive state tree.
class WellnessStateScope extends InheritedNotifier<WellnessProvider> {
  const WellnessStateScope({
    super.key,
    required WellnessProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static WellnessProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WellnessStateScope>();
    assert(scope != null, 'No WellnessStateScope found in context');
    return scope!.notifier!;
  }
}
