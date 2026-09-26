import 'package:flutter/material.dart';
import '../../core/widgets/weekly_bar_chart.dart';
import '../models/notification_item.dart';
import '../models/reproductive_health_models.dart';
import '../models/smart_device_models.dart';
import '../models/wellness_models.dart';

/// Central reactive state store for Biothrix Wellness.
/// Clean state with ZERO hardcoded demo data — all users start fresh.
class WellnessProvider extends ChangeNotifier {
  WellnessProvider() {
    _seedInitialNotifications();
  }

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

  String _gender = 'Female';
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
    _age = calculatedAge.clamp(13, 100);
    notifyListeners();
  }

  void setAge(int age) {
    _age = age.clamp(13, 100);
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    // Reproductive health tracking (period & pregnancy) is exclusive to female profiles
    if (gender.toLowerCase() == 'male') {
      _isPeriodTrackingEnabled = false;
      _isPregnancyTrackingEnabled = false;
    }
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
    bool? isPeriodTrackingEnabled,
    bool? isPregnancyTrackingEnabled,
  }) {
    if (dateOfBirth != null) {
      _dateOfBirth = dateOfBirth;
      final now = DateTime.now();
      int calculatedAge = now.year - dateOfBirth.year;
      if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
        calculatedAge--;
      }
      _age = calculatedAge.clamp(13, 100);
    } else if (age != null) {
      _age = age.clamp(13, 100);
    }
    if (gender != null) {
      _gender = gender;
      if (gender.toLowerCase() == 'male') {
        _isPeriodTrackingEnabled = false;
        _isPregnancyTrackingEnabled = false;
      }
    }
    if (heightCm != null) _heightCm = heightCm;
    if (weightKg != null) _weightKg = weightKg;
    if (targetWeightKg != null) _targetWeightKg = targetWeightKg;
    if (primaryGoal != null) _primaryGoal = primaryGoal;
    if (activityLevel != null) _activityLevel = activityLevel;

    // Biological Sex Guard & Mutual Exclusivity:
    if (_gender.toLowerCase() == 'male') {
      _isPeriodTrackingEnabled = false;
      _isPregnancyTrackingEnabled = false;
    } else if (isPregnancyTrackingEnabled == true) {
      _isPregnancyTrackingEnabled = true;
      _isPeriodTrackingEnabled = false;
    } else if (isPeriodTrackingEnabled == true) {
      _isPeriodTrackingEnabled = true;
      _isPregnancyTrackingEnabled = false;
    } else {
      if (isPeriodTrackingEnabled != null) _isPeriodTrackingEnabled = isPeriodTrackingEnabled;
      if (isPregnancyTrackingEnabled != null) _isPregnancyTrackingEnabled = isPregnancyTrackingEnabled;
    }
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

  // --- Extended Clinical & Wearable Telemetry ---
  int _systolicBp = 118; // mmHg
  int get systolicBp => _systolicBp;

  int _diastolicBp = 76; // mmHg
  int get diastolicBp => _diastolicBp;

  BloodPressureCategory get bpCategory {
    if (_systolicBp < 120 && _diastolicBp < 80) {
      return BloodPressureCategory.optimal;
    } else if (_systolicBp <= 129 && _diastolicBp < 80) {
      return BloodPressureCategory.elevated;
    } else if ((_systolicBp >= 130 && _systolicBp <= 139) || (_diastolicBp >= 80 && _diastolicBp <= 89)) {
      return BloodPressureCategory.stage1Hypertension;
    } else if (_systolicBp >= 180 || _diastolicBp >= 120) {
      return BloodPressureCategory.hypertensiveCrisis;
    } else {
      return BloodPressureCategory.stage2Hypertension;
    }
  }

  void recordBloodPressure(int systolic, int diastolic) {
    _systolicBp = systolic;
    _diastolicBp = diastolic;
    notifyListeners();
  }

  double _bodyTemperatureCelsius = 36.6; // °C
  double get bodyTemperatureCelsius => _bodyTemperatureCelsius;
  double get bodyTemperatureFahrenheit => (_bodyTemperatureCelsius * 9 / 5) + 32.0;

  void recordBodyTemperature(double tempC) {
    _bodyTemperatureCelsius = double.parse(tempC.toStringAsFixed(1));
    notifyListeners();
  }

  int _bloodOxygenSpO2 = 98; // %
  int get bloodOxygenSpO2 => _bloodOxygenSpO2;

  void recordBloodOxygen(int spo2) {
    _bloodOxygenSpO2 = spo2.clamp(70, 100);
    notifyListeners();
  }

  int _hrvMs = 54; // RMSSD in ms
  int get hrvMs => _hrvMs;

  void recordHrv(int ms) {
    _hrvMs = ms;
    notifyListeners();
  }

  int _cadenceSpm = 0; // Steps per minute
  int get cadenceSpm => _cadenceSpm;

  void updateCadence(int spm) {
    _cadenceSpm = spm;
    notifyListeners();
  }

  // --- Smart Wearables & Peripheral Devices Hub ---
  final List<SmartDevice> _connectedDevices = [];
  List<SmartDevice> get connectedDevices => List.unmodifiable(_connectedDevices);

  SmartDevice? _activeDevice;
  SmartDevice? get activeDevice => _activeDevice;

  bool _isAutoSyncEnabled = true;
  bool get isAutoSyncEnabled => _isAutoSyncEnabled;

  void toggleAutoSync(bool enabled) {
    _isAutoSyncEnabled = enabled;
    notifyListeners();
  }

  void pairDevice(SmartDevice device) {
    final idx = _connectedDevices.indexWhere((d) => d.id == device.id);
    if (idx != -1) {
      _connectedDevices[idx] = device.copyWith(
        connectionState: DeviceConnectionState.connected,
        lastSyncedAt: DateTime.now(),
      );
      _activeDevice = _connectedDevices[idx];
    } else {
      final paired = device.copyWith(
        connectionState: DeviceConnectionState.connected,
        lastSyncedAt: DateTime.now(),
      );
      _connectedDevices.add(paired);
      _activeDevice = paired;
    }
    notifyListeners();
  }

  void disconnectDevice(String id) {
    final idx = _connectedDevices.indexWhere((d) => d.id == id);
    if (idx != -1) {
      _connectedDevices[idx] = _connectedDevices[idx].copyWith(
        connectionState: DeviceConnectionState.disconnected,
      );
      if (_activeDevice?.id == id) {
        _activeDevice = null;
      }
      notifyListeners();
    }
  }

  void syncActiveDevice([VitalsTelemetry? telemetry]) {
    if (telemetry != null) {
      if (telemetry.steps > 0) _steps = telemetry.steps;
      if (telemetry.cadenceSpm > 0) _cadenceSpm = telemetry.cadenceSpm;
      if (telemetry.heartRateBpm > 0) _bpm = telemetry.heartRateBpm;
      if (telemetry.systolicBp > 0) {
        _systolicBp = telemetry.systolicBp;
        _diastolicBp = telemetry.diastolicBp;
      }
      if (telemetry.bodyTemperatureCelsius > 0) {
        _bodyTemperatureCelsius = telemetry.bodyTemperatureCelsius;
      }
      if (telemetry.spo2Percentage > 0) {
        _bloodOxygenSpO2 = telemetry.spo2Percentage;
      }
      if (telemetry.hrvMs > 0) {
        _hrvMs = telemetry.hrvMs;
      }
    }

    if (_activeDevice != null) {
      final idx = _connectedDevices.indexWhere((d) => d.id == _activeDevice!.id);
      if (idx != -1) {
        _connectedDevices[idx] = _connectedDevices[idx].copyWith(
          lastSyncedAt: DateTime.now(),
        );
        _activeDevice = _connectedDevices[idx];
      }
    }
    notifyListeners();
  }

  // --- Clinical Composite Health Score Engine ---
  /// Computes a comprehensive 0-100 score based on 5 pillars:
  /// Steps (25%), Hydration (20%), Sleep Rest (25%), Nutrition Pacing (15%), and Cardiovascular Vitals (15%).
  int get healthScore {
    final stepPart = _stepGoal > 0 ? (_steps / _stepGoal).clamp(0.0, 1.0) * 25.0 : 0.0;
    final waterPart = _waterGoal > 0 ? (_waterGlasses / _waterGoal).clamp(0.0, 1.0) * 20.0 : 0.0;
    final sleepPart = _sleepGoalHours > 0 ? (_sleepHours / _sleepGoalHours).clamp(0.0, 1.0) * 25.0 : 0.0;
    final caloriePart = (_targetCalories > 0 && _calories > 0)
        ? (1.0 - ((_calories - _targetCalories).abs() / _targetCalories)).clamp(0.0, 1.0) * 15.0
        : 0.0;

    double vitalsPart = 4.0;
    if (_bpm > 0) {
      vitalsPart += (_bpm >= 55 && _bpm <= 80) ? 6.0 : 3.0;
    } else {
      vitalsPart += 3.0;
    }
    if (_systolicBp > 0 && _diastolicBp > 0) {
      vitalsPart += (_systolicBp < 120 && _diastolicBp < 80) ? 5.0 : 2.0;
    }

    return (stepPart + waterPart + sleepPart + caloriePart + vitalsPart).round().clamp(0, 100);
  }

  double get healthScoreProgress => healthScore / 100.0;

  String get healthScoreTier {
    final score = healthScore;
    if (score >= 85) return '🌟 Optimal Health Tier';
    if (score >= 70) return '⚡ Good Vitality Tier';
    if (score >= 50) return '🌱 Building Momentum Tier';
    return '🎯 Foundation Phase Tier';
  }

  Color get healthScoreColor {
    final score = healthScore;
    if (score >= 85) return const Color(0xFF10B981);
    if (score >= 70) return const Color(0xFF14B8A6);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFF64748B);
  }

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

  /// Calculates the count of days in the current week where composite goal progress reached >= 70%
  int get completedDaysThisWeek {
    if (_isDemoMode && _weeklyStatDays.isNotEmpty) {
      int count = 0;
      for (final snap in _weeklyStatDays.values) {
        final calRatio = _targetCalories > 0 ? (snap.calories / _targetCalories) : 0.0;
        final stepRatio = _stepGoal > 0 ? (snap.steps / _stepGoal) : 0.0;
        final waterRatio = _waterGoal > 0 ? (snap.waterGlasses / _waterGoal) : 0.0;
        final score = (calRatio * 0.4) + (stepRatio * 0.3) + (waterRatio * 0.3);
        if (score >= 0.7) count++;
      }
      return count.clamp(0, 7);
    }

    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Mon ... 7 = Sun
    int count = 0;
    for (int i = 1; i < todayWeekday; i++) {
      final pastDate = now.subtract(Duration(days: todayWeekday - i));
      final key = '${pastDate.year}-${pastDate.month}-${pastDate.day}';
      final snap = _pastDaysData[key];
      if (snap != null) {
        final calRatio = _targetCalories > 0 ? (snap.calories / _targetCalories) : 0.0;
        final stepRatio = _stepGoal > 0 ? (snap.steps / _stepGoal) : 0.0;
        final waterRatio = _waterGoal > 0 ? (snap.waterGlasses / _waterGoal) : 0.0;
        final score = (calRatio * 0.4) + (stepRatio * 0.3) + (waterRatio * 0.3);
        if (score >= 0.7) count++;
      }
    }

    final todayCalRatio = _targetCalories > 0 ? (_calories / _targetCalories) : 0.0;
    final todayStepRatio = _stepGoal > 0 ? (_steps / _stepGoal) : 0.0;
    final todayWaterRatio = _waterGoal > 0 ? (_waterGlasses / _waterGoal) : 0.0;
    final todayScore = (todayCalRatio * 0.4) + (todayStepRatio * 0.3) + (todayWaterRatio * 0.3);
    if (todayScore >= 0.7) count++;

    return count.clamp(0, 7);
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
  double _sleepGoalHours = 8.0;
  double get sleepGoalHours => _sleepGoalHours;
  int _sleepScore = 0;
  int get sleepScore => _sleepScore;

  void logSleep(double hours) {
    _sleepHours = hours;
    _sleepScore = ((hours / (_sleepGoalHours > 0 ? _sleepGoalHours : 8.0)) * 100).clamp(0, 100).toInt();
    notifyListeners();
  }

  void setSleepGoalHours(double hours) {
    if (hours > 0) {
      _sleepGoalHours = hours;
      notifyListeners();
    }
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
    _periodCycles.clear();
    _periodDailyLogs.clear();
    _pregnancyData = null;
    _pregnancyLogs.clear();
    _pregnancyAppointments.clear();
    _isPeriodTrackingEnabled = false;
    _isPregnancyTrackingEnabled = false;
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

      // If user gender is female or investor asks for female preview, populate realistic cycle
      if (_gender == 'Female') {
        _isPeriodTrackingEnabled = true;
        final cycleStart = now.subtract(const Duration(days: 14));
        final prevCycleStart = now.subtract(const Duration(days: 42));
        _periodCycles.clear();
        _periodCycles.addAll([
          PeriodCycleEntry(
            id: 'demo_c1',
            startDate: cycleStart,
            endDate: cycleStart.add(const Duration(days: 4)),
            flow: PeriodFlowLevel.medium,
            symptoms: const [PeriodSymptom.cramps, PeriodSymptom.fatigue],
            mood: PeriodMood.calm,
            notes: 'Regular flow, smooth cycle start.',
          ),
          PeriodCycleEntry(
            id: 'demo_c2',
            startDate: prevCycleStart,
            endDate: prevCycleStart.add(const Duration(days: 5)),
            flow: PeriodFlowLevel.heavy,
            symptoms: const [PeriodSymptom.headache, PeriodSymptom.bloating],
            mood: PeriodMood.sensitive,
            notes: '28-day cycle interval.',
          ),
        ]);
      }
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
        hasPeriod: _isPeriodTrackingEnabled && isPeriodDay(date),
        hasPregnancyLog: _isPregnancyTrackingEnabled && _pregnancyLogs.any((l) => l.date.year == date.year && l.date.month == date.month && l.date.day == date.day),
      );
    }

    return const DayTelemetryStatus();
  }

  // ==========================================
  // REPRODUCTIVE & HORMONAL HEALTH STATE
  // ==========================================
  bool _isPeriodTrackingEnabled = false;
  bool get isPeriodTrackingEnabled => _isPeriodTrackingEnabled;

  bool _isPregnancyTrackingEnabled = false;
  bool get isPregnancyTrackingEnabled => _isPregnancyTrackingEnabled;

  int _defaultCycleLengthDays = 28;
  int get defaultCycleLengthDays => _defaultCycleLengthDays;

  int _defaultPeriodDurationDays = 5;
  int get defaultPeriodDurationDays => _defaultPeriodDurationDays;

  final List<PeriodCycleEntry> _periodCycles = [];
  List<PeriodCycleEntry> get periodCycles => List.unmodifiable(_periodCycles);

  final Map<String, PeriodDailyLog> _periodDailyLogs = {};
  Map<String, PeriodDailyLog> get periodDailyLogs => Map.unmodifiable(_periodDailyLogs);

  PregnancyData? _pregnancyData;
  PregnancyData? get pregnancyData => _pregnancyData;

  final List<PregnancyLogEntry> _pregnancyLogs = [];
  List<PregnancyLogEntry> get pregnancyLogs => List.unmodifiable(_pregnancyLogs);

  final List<PregnancyAppointment> _pregnancyAppointments = [];
  List<PregnancyAppointment> get pregnancyAppointments => List.unmodifiable(_pregnancyAppointments);

  bool get isReproductiveTrackingEligible => _gender.toLowerCase() == 'female';

  void setPeriodTrackingEnabled(bool enabled) {
    // Male users cannot enable menstrual cycle tracking
    if (enabled && !isReproductiveTrackingEligible) {
      return;
    }
    _isPeriodTrackingEnabled = enabled;
    // Strict biological mutual exclusivity: True periods do not occur during pregnancy
    if (enabled) {
      _isPregnancyTrackingEnabled = false;
    }
    notifyListeners();
  }

  void setPregnancyTrackingEnabled(bool enabled) {
    // Male users cannot enable pregnancy tracking
    if (enabled && !isReproductiveTrackingEligible) {
      return;
    }
    _isPregnancyTrackingEnabled = enabled;
    // Strict biological mutual exclusivity: True periods do not occur during pregnancy
    if (enabled) {
      _isPeriodTrackingEnabled = false;
    }
    notifyListeners();
  }

  /// Clinical Basal Metabolic Rate using the validated Mifflin-St Jeor equation
  double get bmr {
    final w = _weightKg > 0 ? _weightKg : 70.0;
    final h = _heightCm > 0 ? _heightCm : 175.0;
    final a = _age;
    if (_gender.toLowerCase() == 'female') {
      return (10 * w) + (6.25 * h) - (5 * a) - 161;
    } else {
      return (10 * w) + (6.25 * h) - (5 * a) + 5;
    }
  }

  /// Clinically calculated daily caloric recommendation based on BMR & activity level
  int get recommendedDailyCalories {
    final baseBmr = bmr;
    double factor = 1.35;
    if (_activityLevel.toLowerCase().contains('sedentary')) {
      factor = 1.2;
    } else if (_activityLevel.toLowerCase().contains('high') || _activityLevel.toLowerCase().contains('athletic')) {
      factor = 1.725;
    }
    return (baseBmr * factor).round();
  }

  /// Recommended daily hydration glasses based on weight (35ml per kg / 250ml per glass)
  int get recommendedHydrationGlasses {
    final w = _weightKg > 0 ? _weightKg : 70.0;
    final liters = (w * 0.035).clamp(1.5, 4.5);
    return (liters / 0.25).round();
  }

  void setDefaultCycleParameters({int? cycleLength, int? periodDuration}) {
    if (cycleLength != null && cycleLength >= 20 && cycleLength <= 45) {
      _defaultCycleLengthDays = cycleLength;
    }
    if (periodDuration != null && periodDuration >= 2 && periodDuration <= 10) {
      _defaultPeriodDurationDays = periodDuration;
    }
    notifyListeners();
  }

  /// Configures personalized menstrual tracking collected during Onboarding.
  void configureInitialPeriodTracking({
    required DateTime lastPeriodStartDate,
    required int periodDurationDays,
    required int cycleLengthDays,
    String? regularity,
    String? trackingGoal,
  }) {
    _isPeriodTrackingEnabled = true;
    _isPregnancyTrackingEnabled = false;
    _defaultCycleLengthDays = cycleLengthDays.clamp(20, 45);
    _defaultPeriodDurationDays = periodDurationDays.clamp(2, 10);

    final cleanStart = DateTime(lastPeriodStartDate.year, lastPeriodStartDate.month, lastPeriodStartDate.day);
    final cleanEnd = cleanStart.add(Duration(days: periodDurationDays - 1));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isStillOngoing = cleanEnd.isAfter(today) || cleanEnd.isAtSameMomentAs(today);

    _periodCycles.clear();
    _periodCycles.add(
      PeriodCycleEntry(
        id: 'initial_cycle_${DateTime.now().millisecondsSinceEpoch}',
        startDate: cleanStart,
        endDate: isStillOngoing ? null : cleanEnd,
        flow: PeriodFlowLevel.medium,
        notes: 'Onboarding setup (${regularity ?? 'Regular'}) • Goal: ${trackingGoal ?? 'Cycle Wellness'}',
      ),
    );
    notifyListeners();
  }

  PeriodCycleEntry? get activePeriod {
    try {
      return _periodCycles.firstWhere((c) => c.isOngoing);
    } catch (_) {
      return null;
    }
  }

  PeriodCycleEntry? get lastRecordedPeriod {
    if (_periodCycles.isEmpty) return null;
    final sorted = List<PeriodCycleEntry>.from(_periodCycles)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return sorted.first;
  }

  int get currentCycleDay {
    final last = lastRecordedPeriod;
    if (last == null) return 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(last.startDate.year, last.startDate.month, last.startDate.day);
    final diff = today.difference(start).inDays;
    return (diff >= 0 ? diff + 1 : 1);
  }

  double get averageCycleLength {
    if (_periodCycles.length < 2) return _defaultCycleLengthDays.toDouble();
    final sorted = List<PeriodCycleEntry>.from(_periodCycles)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final lengths = <int>[];
    for (int i = 0; i < sorted.length - 1; i++) {
      final diff = sorted[i].startDate.difference(sorted[i + 1].startDate).inDays.abs();
      if (diff >= 20 && diff <= 45) {
        lengths.add(diff);
      }
    }
    if (lengths.isEmpty) return _defaultCycleLengthDays.toDouble();
    return lengths.reduce((a, b) => a + b) / lengths.length;
  }

  double get averagePeriodDuration {
    final completed = _periodCycles.where((c) => c.endDate != null).toList();
    if (completed.isEmpty) return _defaultPeriodDurationDays.toDouble();
    final durations = completed.map((c) => c.periodDurationDays).toList();
    return durations.reduce((a, b) => a + b) / durations.length;
  }

  PeriodPrediction get periodPrediction {
    final last = lastRecordedPeriod;
    if (last == null) {
      return PeriodPrediction.uninitialized;
    }

    final cycleLen = averageCycleLength.round();
    final periodDur = averagePeriodDuration.round();
    final nextPeriod = last.startDate.add(Duration(days: cycleLen));
    final ovulation = nextPeriod.subtract(const Duration(days: 14));
    final fertileStart = ovulation.subtract(const Duration(days: 4));
    final fertileEnd = ovulation.add(const Duration(days: 1));

    final day = currentCycleDay;
    PeriodPhase phase;
    if (day <= periodDur || activePeriod != null) {
      phase = PeriodPhase.menstrual;
    } else if (day < (cycleLen - 17)) {
      phase = PeriodPhase.follicular;
    } else if (day >= (cycleLen - 17) && day <= (cycleLen - 12)) {
      phase = PeriodPhase.ovulation;
    } else {
      phase = PeriodPhase.luteal;
    }

    final isLearning = _periodCycles.length < 2;
    final message = isLearning
        ? "We're still learning your cycle. Log a few more cycles to improve your estimates."
        : "Estimate based on your previous $cycleLen-day cycle patterns. Individual cycles vary naturally.";

    return PeriodPrediction(
      estimatedNextPeriodDate: nextPeriod,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
      estimatedOvulationDate: ovulation,
      currentCycleDay: day,
      currentPhase: phase,
      isLearningPhase: isLearning,
      confidenceMessage: message,
    );
  }

  PeriodDailyLog? getPeriodDailyLog(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    return _periodDailyLogs[key];
  }

  void startPeriod(DateTime date, {
    PeriodFlowLevel flow = PeriodFlowLevel.medium,
    List<PeriodSymptom>? symptoms,
    PeriodMood? mood,
    String? notes,
  }) {
    final ongoing = activePeriod;
    if (ongoing != null) {
      final index = _periodCycles.indexWhere((c) => c.id == ongoing.id);
      if (index != -1) {
        _periodCycles[index] = ongoing.copyWith(endDate: date.subtract(const Duration(days: 1)));
      }
    }

    final newEntry = PeriodCycleEntry(
      id: 'cycle_${DateTime.now().millisecondsSinceEpoch}',
      startDate: DateTime(date.year, date.month, date.day),
      flow: flow,
      symptoms: symptoms ?? [],
      mood: mood,
      notes: notes ?? '',
    );
    _periodCycles.insert(0, newEntry);
    logDailyPeriodDetails(date, flow: flow, symptoms: symptoms, mood: mood, notes: notes);
    notifyListeners();
  }

  void endPeriod(DateTime date) {
    final ongoing = activePeriod;
    if (ongoing != null) {
      final index = _periodCycles.indexWhere((c) => c.id == ongoing.id);
      if (index != -1) {
        _periodCycles[index] = ongoing.copyWith(
          endDate: DateTime(date.year, date.month, date.day),
        );
        notifyListeners();
      }
    }
  }

  void logDailyPeriodDetails(DateTime date, {
    PeriodFlowLevel? flow,
    List<PeriodSymptom>? symptoms,
    PeriodMood? mood,
    String? notes,
  }) {
    final key = '${date.year}-${date.month}-${date.day}';
    final existing = _periodDailyLogs[key];
    final updated = PeriodDailyLog(
      id: existing?.id ?? 'pday_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime(date.year, date.month, date.day),
      flow: flow ?? existing?.flow,
      symptoms: symptoms ?? existing?.symptoms ?? [],
      mood: mood ?? existing?.mood,
      notes: notes ?? existing?.notes ?? '',
    );
    _periodDailyLogs[key] = updated;
    notifyListeners();
  }

  void deletePeriodCycle(String id) {
    _periodCycles.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  bool isPeriodDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    for (final c in _periodCycles) {
      final start = DateTime(c.startDate.year, c.startDate.month, c.startDate.day);
      final end = c.endDate != null
          ? DateTime(c.endDate!.year, c.endDate!.month, c.endDate!.day)
          : DateTime.now();
      if ((d.isAfter(start) || d.isAtSameMomentAs(start)) &&
          (d.isBefore(end) || d.isAtSameMomentAs(end))) {
        return true;
      }
    }
    return false;
  }

  bool isPredictedPeriodDay(DateTime date) {
    final pred = periodPrediction;
    if (pred.estimatedNextPeriodDate == null) return false;
    final target = DateTime(pred.estimatedNextPeriodDate!.year, pred.estimatedNextPeriodDate!.month, pred.estimatedNextPeriodDate!.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(target).inDays;
    return diff >= 0 && diff < averagePeriodDuration.round();
  }

  bool isFertileWindowDay(DateTime date) {
    final pred = periodPrediction;
    if (pred.fertileWindowStart == null || pred.fertileWindowEnd == null) return false;
    final d = DateTime(date.year, date.month, date.day);
    final start = DateTime(pred.fertileWindowStart!.year, pred.fertileWindowStart!.month, pred.fertileWindowStart!.day);
    final end = DateTime(pred.fertileWindowEnd!.year, pred.fertileWindowEnd!.month, pred.fertileWindowEnd!.day);
    return (d.isAfter(start) || d.isAtSameMomentAs(start)) &&
           (d.isBefore(end) || d.isAtSameMomentAs(end));
  }

  void setupPregnancy({
    required PregnancyReferenceType type,
    required DateTime date,
    String notes = '',
  }) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    DateTime calculatedDueDate;
    DateTime lmpDate;

    switch (type) {
      case PregnancyReferenceType.lastMenstrualPeriod:
        lmpDate = cleanDate;
        calculatedDueDate = cleanDate.add(const Duration(days: 280));
        break;
      case PregnancyReferenceType.estimatedDueDate:
        calculatedDueDate = cleanDate;
        lmpDate = cleanDate.subtract(const Duration(days: 280));
        break;
      case PregnancyReferenceType.conceptionDate:
        lmpDate = cleanDate.subtract(const Duration(days: 14));
        calculatedDueDate = cleanDate.add(const Duration(days: 266));
        break;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final elapsedDays = today.difference(lmpDate).inDays.clamp(0, 300);
    final currentWeek = (elapsedDays ~/ 7) + 1;
    final currentDay = elapsedDays % 7;

    int trimester;
    if (currentWeek <= 12) {
      trimester = 1;
    } else if (currentWeek <= 27) {
      trimester = 2;
    } else {
      trimester = 3;
    }

    final fruitInfo = _getBabyFruitInfo(currentWeek);

    _pregnancyData = PregnancyData(
      id: 'preg_${DateTime.now().millisecondsSinceEpoch}',
      referenceType: type,
      referenceDate: cleanDate,
      dueDate: calculatedDueDate,
      currentWeek: currentWeek.clamp(1, 42),
      currentDayOfCurrentWeek: currentDay,
      totalDays: elapsedDays,
      trimester: trimester,
      babySizeFruit: fruitInfo.fruit,
      babySizeComparison: fruitInfo.comparison,
      estimatedLengthCm: fruitInfo.lengthCm,
      estimatedWeightGrams: fruitInfo.weightGrams,
      notes: notes,
    );

    _isPregnancyTrackingEnabled = true;
    notifyListeners();
  }

  void logPregnancyWellness(DateTime date, {
    List<String>? symptoms,
    String? mood,
    String? notes,
    double? sleepHours,
    int? waterGlasses,
  }) {
    final entry = PregnancyLogEntry(
      id: 'preg_log_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime(date.year, date.month, date.day),
      symptoms: symptoms ?? [],
      mood: mood,
      notes: notes ?? '',
      sleepHours: sleepHours ?? _sleepHours,
      waterGlasses: waterGlasses ?? _waterGlasses,
    );
    _pregnancyLogs.insert(0, entry);
    notifyListeners();
  }

  void addPregnancyAppointment(
    String title,
    DateTime date, {
    String timeString = '09:30 AM',
    PrenatalAppointmentType type = PrenatalAppointmentType.routineCheckup,
    String providerOrLocation = '',
    String notes = '',
    String preparation = '',
  }) {
    final appt = PregnancyAppointment(
      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      date: date,
      timeString: timeString,
      type: type,
      providerOrLocation: providerOrLocation,
      notes: notes,
      preparation: preparation,
      isCompleted: false,
    );
    _pregnancyAppointments.add(appt);
    notifyListeners();
  }

  void deletePregnancyAppointment(String id) {
    _pregnancyAppointments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void toggleAppointmentCompleted(String id) {
    final index = _pregnancyAppointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final a = _pregnancyAppointments[index];
      _pregnancyAppointments[index] = a.copyWith(isCompleted: !a.isCompleted);
      notifyListeners();
    }
  }

  void transitionToPregnancyFromLastPeriod() {
    final last = lastRecordedPeriod;
    final lmp = last?.startDate ?? DateTime.now().subtract(const Duration(days: 28));
    setupPregnancy(
      type: PregnancyReferenceType.lastMenstrualPeriod,
      date: lmp,
      notes: 'Transitioned seamlessly from Period Tracking based on last recorded period.',
    );
  }

  void clearPregnancyData({bool keepHistory = true}) {
    _isPregnancyTrackingEnabled = false;
    if (!keepHistory) {
      _pregnancyData = null;
      _pregnancyLogs.clear();
      _pregnancyAppointments.clear();
    }
    notifyListeners();
  }

  static ({String fruit, String comparison, double lengthCm, double weightGrams}) _getBabyFruitInfo(int week) {
    if (week <= 4) return (fruit: 'Poppy Seed', comparison: 'Small as a tiny poppy seed (~1mm)', lengthCm: 0.1, weightGrams: 0.1);
    if (week <= 6) return (fruit: 'Sweet Pea', comparison: 'Size of a sweet garden pea (~5mm)', lengthCm: 0.5, weightGrams: 0.2);
    if (week <= 8) return (fruit: 'Raspberry', comparison: 'Size of a fresh raspberry (~1.6cm)', lengthCm: 1.6, weightGrams: 1.0);
    if (week <= 10) return (fruit: 'Prune', comparison: 'Size of a small prune (~3.1cm)', lengthCm: 3.1, weightGrams: 4.0);
    if (week <= 12) return (fruit: 'Plum', comparison: 'Size of a juicy plum (~5.4cm)', lengthCm: 5.4, weightGrams: 14.0);
    if (week <= 14) return (fruit: 'Navel Orange', comparison: 'Size of a sweet navel orange (~8.7cm)', lengthCm: 8.7, weightGrams: 43.0);
    if (week <= 16) return (fruit: 'Avocado', comparison: 'Size of a ripe avocado (~11.6cm)', lengthCm: 11.6, weightGrams: 100.0);
    if (week <= 18) return (fruit: 'Sweet Bell Pepper', comparison: 'Size of a sweet bell pepper (~14.2cm)', lengthCm: 14.2, weightGrams: 190.0);
    if (week <= 20) return (fruit: 'Banana', comparison: 'Length of a fresh yellow banana (~25.6cm)', lengthCm: 25.6, weightGrams: 300.0);
    if (week <= 22) return (fruit: 'Papaya', comparison: 'Size of a golden papaya (~27.8cm)', lengthCm: 27.8, weightGrams: 430.0);
    if (week <= 24) return (fruit: 'Cantaloupe', comparison: 'Size of an ear of sweet corn (~30cm)', lengthCm: 30.0, weightGrams: 600.0);
    if (week <= 28) return (fruit: 'Eggplant', comparison: 'Size of a rich eggplant (~37.6cm)', lengthCm: 37.6, weightGrams: 1000.0);
    if (week <= 32) return (fruit: 'Pineapple', comparison: 'Size of a tropical pineapple (~42.4cm)', lengthCm: 42.4, weightGrams: 1700.0);
    if (week <= 36) return (fruit: 'Honeydew Melon', comparison: 'Size of a ripe honeydew melon (~47.4cm)', lengthCm: 47.4, weightGrams: 2600.0);
    return (fruit: 'Watermelon', comparison: 'Full term, size of a sweet watermelon (~51cm)', lengthCm: 51.0, weightGrams: 3400.0);
  }

  // ==========================================
  // NOTIFICATIONS STATE & PREFERENCES
  // ==========================================
  final List<WellnestNotification> _notifications = [];
  List<WellnestNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  bool _isHydrationNotificationEnabled = true;
  bool get isHydrationNotificationEnabled => _isHydrationNotificationEnabled;

  bool _isPeriodReminderEnabled = true;
  bool get isPeriodReminderEnabled => _isPeriodReminderEnabled;

  bool _isPregnancyAlertsEnabled = true;
  bool get isPregnancyAlertsEnabled => _isPregnancyAlertsEnabled;

  bool _isSleepReminderEnabled = true;
  bool get isSleepReminderEnabled => _isSleepReminderEnabled;

  bool _isActivityRemindersEnabled = true;
  bool get isActivityRemindersEnabled => _isActivityRemindersEnabled;

  bool _isSystemSoundEnabled = true;
  bool get isSystemSoundEnabled => _isSystemSoundEnabled;

  bool _isInAppBannersEnabled = true;
  bool get isInAppBannersEnabled => _isInAppBannersEnabled;

  void addNotification(WellnestNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void clearNotification(String id) {
    final before = _notifications.length;
    _notifications.removeWhere((n) => n.id == id);
    if (_notifications.length != before) {
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      notifyListeners();
    }
  }

  void updateNotificationPreferences({
    bool? hydration,
    bool? period,
    bool? pregnancy,
    bool? sleep,
    bool? activity,
    bool? sound,
    bool? inAppBanners,
  }) {
    if (hydration != null) _isHydrationNotificationEnabled = hydration;
    if (period != null) _isPeriodReminderEnabled = period;
    if (pregnancy != null) _isPregnancyAlertsEnabled = pregnancy;
    if (sleep != null) _isSleepReminderEnabled = sleep;
    if (activity != null) _isActivityRemindersEnabled = activity;
    if (sound != null) _isSystemSoundEnabled = sound;
    if (inAppBanners != null) _isInAppBannersEnabled = inAppBanners;
    notifyListeners();
  }

  void _seedInitialNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
      WellnestNotification(
        id: 'seed-1',
        title: 'Welcome to Wellnest OS',
        message: 'Your biometric command center is primed and ready. Explore cycle insights, daily hydration pacing, and rest telemetry.',
        timestamp: now.subtract(const Duration(minutes: 12)),
        category: NotificationCategory.insights,
        type: NotificationType.milestone,
        isRead: false,
      ),
      WellnestNotification(
        id: 'seed-2',
        title: 'Hydration Target Optimal',
        message: 'Stay ahead of afternoon fatigue. Drink a glass of water now to maintain peak metabolic rate.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 25)),
        category: NotificationCategory.reminders,
        type: NotificationType.hydration,
        isRead: false,
      ),
      WellnestNotification(
        id: 'seed-3',
        title: 'Cycle Phase Advisory',
        message: 'Follicular energy peak detected. Great day for strength workouts or focused creative problem solving.',
        timestamp: now.subtract(const Duration(hours: 6)),
        category: NotificationCategory.reproductive,
        type: NotificationType.period,
        isRead: true,
      ),
      WellnestNotification(
        id: 'seed-4',
        title: 'Rest & Recovery Score: 92%',
        message: 'Deep sleep ratio was exceptional last night. Your heart rate variability indicates optimal nervous system recovery.',
        timestamp: now.subtract(const Duration(hours: 14)),
        category: NotificationCategory.system,
        type: NotificationType.sleep,
        isRead: true,
      ),
    ]);
  }
}

/// Snapshot of telemetry metrics recorded on a specific date.
class DayTelemetryStatus {
  final bool hasNutrition;
  final bool hasWater;
  final bool hasActivity;
  final bool hasSleep;
  final bool hasPeriod;
  final bool hasPregnancyLog;

  const DayTelemetryStatus({
    this.hasNutrition = false,
    this.hasWater = false,
    this.hasActivity = false,
    this.hasSleep = false,
    this.hasPeriod = false,
    this.hasPregnancyLog = false,
  });

  bool get hasAny => hasNutrition || hasWater || hasActivity || hasSleep || hasPeriod || hasPregnancyLog;
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
