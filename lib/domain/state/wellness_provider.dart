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

  bool _hasSeenSpotlightTour = false;
  bool get hasSeenSpotlightTour => _hasSeenSpotlightTour;

  void markSpotlightTourSeen() {
    _hasSeenSpotlightTour = true;
    notifyListeners();
  }

  void replaySpotlightTour() {
    _hasSeenSpotlightTour = false;
    notifyListeners();
  }

  void setUserName(String name) {
    if (name.trim().isNotEmpty) {
      _userName = name.trim();
      _isProfileConfigured = true;
      notifyListeners();
    }
  }

  // Biometrics & Personal Health Profile
  DateTime _dateOfBirth = DateTime(1998, 6, 14);
  DateTime get dateOfBirth => _dateOfBirth;

  int _age = 26;
  int get age => _age;

  String _gender = 'Male';
  String get gender => _gender;

  double _heightCm = 178.0;
  double get heightCm => _heightCm;

  double _targetWeightKg = 70.0;
  double get targetWeightKg => _targetWeightKg;

  String _primaryGoal = 'Vitality & Longevity';
  String get primaryGoal => _primaryGoal;

  String _activityLevel = 'Moderate Activity';
  String get activityLevel => _activityLevel;

  void setDateOfBirth(DateTime dob) {
    _dateOfBirth = dob;
    final now = DateTime.now();
    int calculatedAge = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      calculatedAge--;
    }
    _age = calculatedAge.clamp(1, 120);
    notifyListeners();
  }

  void setAge(int age) {
    _age = age;
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void setHeight(double cm) {
    _heightCm = cm;
    notifyListeners();
  }

  void setTargetWeight(double kg) {
    _targetWeightKg = kg;
    notifyListeners();
  }

  void setPrimaryGoal(String goal) {
    _primaryGoal = goal;
    notifyListeners();
  }

  void setActivityLevel(String level) {
    _activityLevel = level;
    notifyListeners();
  }

  void updateBiometrics({
    DateTime? dateOfBirth,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    String? primaryGoal,
    String? activityLevel,
  }) {
    if (dateOfBirth != null) {
      _dateOfBirth = dateOfBirth;
      final now = DateTime.now();
      int calculatedAge = now.year - dateOfBirth.year;
      if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
        calculatedAge--;
      }
      _age = calculatedAge.clamp(1, 120);
    } else if (age != null) {
      _age = age;
    }
    if (gender != null) _gender = gender;
    if (heightCm != null) _heightCm = heightCm;
    if (weightKg != null) _weightKg = weightKg;
    if (targetWeightKg != null) _targetWeightKg = targetWeightKg;
    if (primaryGoal != null) _primaryGoal = primaryGoal;
    if (activityLevel != null) _activityLevel = activityLevel;
    notifyListeners();
  }

  double get bmi {
    final currentWeight = _isDemoMode && _weeklyStatDays.containsKey(_selectedStatDayIndex)
        ? _weeklyStatDays[_selectedStatDayIndex]!.weightKg
        : (_weightKg > 0 ? _weightKg : 72.5);
    final hM = _heightCm > 0 ? _heightCm / 100.0 : 1.78;
    return double.parse((currentWeight / (hM * hM)).toStringAsFixed(1));
  }

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Optimal Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese Range';
  }

  Color get bmiColor {
    final b = bmi;
    if (b < 18.5) return const Color(0xFF2EB5FA);
    if (b < 25.0) return const Color(0xFF10B981);
    if (b < 30.0) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
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

  // Real Selected Date in Calendar
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  int _selectedCalendarDayIndex = 3;
  int get selectedCalendarDayIndex => _selectedCalendarDayIndex;

  void selectCalendarDay(int index) {
    _selectedCalendarDayIndex = index;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void previousWeek() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void nextWeek() {
    _selectedDate = _selectedDate.add(const Duration(days: 7));
    notifyListeners();
  }

  void jumpToToday() {
    _selectedDate = DateTime.now();
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

  void setBpm(int value) => recordBpm(value);

  // Weekly Statistics Bar Data & Historical Storage
  int _selectedStatDayIndex = 3; // Defaults to Thursday / Current Day
  int get selectedStatDayIndex => _selectedStatDayIndex;

  final Map<int, DaySnapshot> _weeklyStatDays = {};
  final Map<String, DaySnapshot> _pastDaysData = {};

  List<DayBarData> get weeklyBarData {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (index) {
      if (_isDemoMode && _weeklyStatDays.containsKey(index)) {
        final snap = _weeklyStatDays[index]!;
        final pct = _targetCalories > 0 ? ((snap.calories / _targetCalories) * 100).toInt() : 0;
        return DayBarData(
          dayName: days[index],
          percentage: pct,
          value: snap.calories,
        );
      }
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

  // Interactive metrics for the currently selected day on the Statistics screen
  int get statCalories {
    if (_isDemoMode && _weeklyStatDays.containsKey(_selectedStatDayIndex)) {
      return _weeklyStatDays[_selectedStatDayIndex]!.calories;
    }
    return _calories;
  }

  double get statExerciseHours {
    if (_isDemoMode && _weeklyStatDays.containsKey(_selectedStatDayIndex)) {
      return _weeklyStatDays[_selectedStatDayIndex]!.exerciseHours;
    }
    return _exerciseHours;
  }

  int get statBpm {
    if (_isDemoMode && _weeklyStatDays.containsKey(_selectedStatDayIndex)) {
      return _weeklyStatDays[_selectedStatDayIndex]!.bpm;
    }
    return _bpm;
  }

  double get statWeightKg {
    if (_isDemoMode && _weeklyStatDays.containsKey(_selectedStatDayIndex)) {
      return _weeklyStatDays[_selectedStatDayIndex]!.weightKg;
    }
    return _weightKg;
  }

  int get statWaterGlasses {
    if (_isDemoMode && _weeklyStatDays.containsKey(_selectedStatDayIndex)) {
      return _weeklyStatDays[_selectedStatDayIndex]!.waterGlasses;
    }
    return _waterGlasses;
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

  void removeMeal(String id) {
    final meal = _meals.firstWhere((m) => m.id == id, orElse: () => const MealEntry(id: '', name: '', mealType: '', calories: 0, timeString: '', description: ''));
    if (meal.id.isNotEmpty) {
      _calories = (_calories - meal.calories).clamp(0, 99999);
      _meals.removeWhere((m) => m.id == id);
      notifyListeners();
    }
  }

  void addWaterAmount(int ml) {
    final glassesToAdd = (ml / 250.0).round().clamp(1, 10);
    _waterGlasses += glassesToAdd;
    notifyListeners();
  }

  void resetAllData() {
    _steps = 0;
    _waterGlasses = 0;
    _calories = 0;
    _exerciseHours = 0.0;
    _bpm = 0;
    _weightKg = 0.0;
    _sleepHours = 0.0;
    _sleepScore = 0;
    _habits = [];
    _meals = [];
    _weeklyStatDays.clear();
    _pastDaysData.clear();
    notifyListeners();
  }

  // Investor Presentation Demo Mode
  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  void toggleDemoMode(bool enable) {
    _isDemoMode = enable;
    if (enable) {
      // User's name (_userName) is strictly preserved!
      _steps = 8420;
      _waterGlasses = 7;
      _calories = 1775;
      _exerciseHours = 4.4;
      _bpm = 74;
      _weightKg = 69.2;
      _sleepHours = 7.8;
      _sleepScore = 92;
      _age = 26;
      _gender = 'Male';
      _heightCm = 178.0;
      _targetWeightKg = 68.5;
      _primaryGoal = 'Vitality & Longevity';
      _activityLevel = 'Active (4-5x / week)';

      // Rich weekly statistics breakdown for all 7 days of the week (Mon-Sun)
      _weeklyStatDays[0] = const DaySnapshot(calories: 1840, waterGlasses: 7, steps: 9240, exerciseHours: 3.5, bpm: 71, weightKg: 69.5, sleepHours: 7.4, sleepScore: 92);
      _weeklyStatDays[1] = const DaySnapshot(calories: 2120, waterGlasses: 8, steps: 10850, exerciseHours: 4.8, bpm: 76, weightKg: 69.4, sleepHours: 8.0, sleepScore: 100);
      _weeklyStatDays[2] = const DaySnapshot(calories: 1960, waterGlasses: 8, steps: 9920, exerciseHours: 4.0, bpm: 73, weightKg: 69.3, sleepHours: 7.6, sleepScore: 95);
      _weeklyStatDays[3] = const DaySnapshot(calories: 1775, waterGlasses: 7, steps: 8420, exerciseHours: 4.4, bpm: 74, weightKg: 69.2, sleepHours: 7.8, sleepScore: 92);
      _weeklyStatDays[4] = const DaySnapshot(calories: 2250, waterGlasses: 9, steps: 11400, exerciseHours: 5.2, bpm: 78, weightKg: 69.1, sleepHours: 8.2, sleepScore: 100);
      _weeklyStatDays[5] = const DaySnapshot(calories: 2380, waterGlasses: 8, steps: 12650, exerciseHours: 5.5, bpm: 75, weightKg: 69.0, sleepHours: 8.5, sleepScore: 100);
      _weeklyStatDays[6] = const DaySnapshot(calories: 1690, waterGlasses: 6, steps: 7450, exerciseHours: 2.5, bpm: 68, weightKg: 69.2, sleepHours: 7.5, sleepScore: 94);

      // Populate 30 days of rich historical snapshots for the calendar
      final now = DateTime.now();
      final baseCalories = [1840, 2120, 1960, 1775, 2250, 2380, 1690, 1920, 2080, 1850, 2180, 2290, 1790, 1990];
      final baseSteps = [9240, 10850, 9920, 8420, 11400, 12650, 7450, 9800, 10500, 8900, 11100, 12100, 8300, 9700];
      final baseWater = [7, 8, 8, 7, 9, 8, 6, 8, 8, 7, 9, 8, 7, 8];
      final baseSleep = [7.4, 8.0, 7.6, 7.8, 8.2, 8.5, 7.5, 7.7, 8.1, 7.3, 8.0, 8.3, 7.6, 7.9];

      for (int i = 0; i < 30; i++) {
        final d = now.subtract(Duration(days: i));
        final key = '${d.year}-${d.month}-${d.day}';
        final mod = i % baseCalories.length;
        _pastDaysData[key] = DaySnapshot(
          calories: baseCalories[mod],
          waterGlasses: baseWater[mod],
          steps: baseSteps[mod],
          exerciseHours: 3.0 + ((i % 5) * 0.5),
          bpm: 70 + (i % 8),
          weightKg: 69.2 + ((i % 4) * 0.1),
          sleepHours: baseSleep[mod],
          sleepScore: (baseSleep[mod] >= 8.0 ? 100 : 90 + (i % 6)),
        );
      }

      _meals = [
        const MealEntry(id: 'd1', name: 'Avocado Toast & Poached Egg', mealType: 'Breakfast', calories: 380, timeString: '08:15 AM', description: 'Fresh healthy fats and protein'),
        const MealEntry(id: 'd2', name: 'Grilled Chicken Quinoa Bowl', mealType: 'Lunch time', calories: 580, timeString: '12:45 PM', description: 'Lean protein & complex carbs'),
        const MealEntry(id: 'd3', name: 'Atlantic Salmon & Steamed Greens', mealType: 'Dinner', calories: 620, timeString: '07:30 PM', description: 'Omega-3 rich dinner'),
        const MealEntry(id: 'd4', name: 'Mixed Berries & Greek Yogurt', mealType: 'Healthy Snack', calories: 195, timeString: '04:10 PM', description: 'Antioxidant afternoon boost'),
      ];

      _habits = [
        const HabitItem(id: 'h1', title: '10 min Morning Sunlight', category: 'Mindfulness', icon: Icons.wb_sunny_rounded, color: Color(0xFF10B981), isCompletedToday: true, streakDays: 14),
        const HabitItem(id: 'h2', title: 'Drink 500ml upon waking', category: 'Hydration', icon: Icons.water_drop_rounded, color: Color(0xFF2EB5FA), isCompletedToday: true, streakDays: 21),
        const HabitItem(id: 'h3', title: '10,000 Steps Daily', category: 'Activity', icon: Icons.directions_run_rounded, color: Color(0xFFFF9442), isCompletedToday: false, streakDays: 7),
        const HabitItem(id: 'h4', title: '5 min Deep Box Breathing', category: 'Mindfulness', icon: Icons.spa_rounded, color: Color(0xFF10B981), isCompletedToday: true, streakDays: 5),
        const HabitItem(id: 'h5', title: 'No screens 30m before sleep', category: 'Sleep', icon: Icons.bedtime_rounded, color: Color(0xFF818CF8), isCompletedToday: false, streakDays: 9),
      ];
    } else {
      resetAllData();
      _isDemoMode = false;
    }
    notifyListeners();
  }

  // Get full metrics snapshot for any calendar date
  DaySnapshot getMetricsForDate(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    if (_isDemoMode) {
      if (isToday) {
        return DaySnapshot(
          calories: _calories,
          waterGlasses: _waterGlasses,
          steps: _steps,
          exerciseHours: _exerciseHours,
          bpm: _bpm,
          weightKg: _weightKg,
          sleepHours: _sleepHours,
          sleepScore: _sleepScore,
        );
      }
      if (_pastDaysData.containsKey(key)) {
        return _pastDaysData[key]!;
      }
    }

    if (isToday) {
      return DaySnapshot(
        calories: _calories,
        waterGlasses: _waterGlasses,
        steps: _steps,
        exerciseHours: _exerciseHours,
        bpm: _bpm,
        weightKg: _weightKg,
        sleepHours: _sleepHours,
        sleepScore: _sleepScore,
      );
    }

    return DaySnapshot.zero;
  }

  // Activity Logging
  void logActivity(double hours, int caloriesBurned, int stepsCount) {
    _exerciseHours += hours;
    _calories += caloriesBurned;
    _steps += stepsCount;
    notifyListeners();
  }

  // Day Telemetry Tracking for Calendar Dots
  DayTelemetryStatus getDayTelemetry(DateTime date) {
    final now = DateTime.now();
    final isSelectedOrToday = (date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day) ||
                              (date.year == now.year && date.month == now.month && date.day == now.day);

    if (_isDemoMode) {
      final diff = now.difference(date).inDays;
      // In demo mode, show full telemetry dots for all days within the past 30 days
      if (diff >= 0 && diff <= 30) {
        return const DayTelemetryStatus(
          hasNutrition: true,
          hasWater: true,
          hasActivity: true,
          hasSleep: true,
        );
      }
    }

    if (isSelectedOrToday) {
      return DayTelemetryStatus(
        hasNutrition: _calories > 0,
        hasWater: _waterGlasses > 0,
        hasActivity: _exerciseHours > 0 || _steps > 0,
        hasSleep: _sleepHours > 0,
      );
    }

    return const DayTelemetryStatus();
  }

}

/// Snapshot of telemetry metrics recorded on a specific date.
class DayTelemetryStatus {
  final bool hasNutrition;
  final bool hasWater;
  final bool hasActivity;
  final bool hasSleep;

  const DayTelemetryStatus({
    this.hasNutrition = false,
    this.hasWater = false,
    this.hasActivity = false,
    this.hasSleep = false,
  });

  bool get hasAny => hasNutrition || hasWater || hasActivity || hasSleep;
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
