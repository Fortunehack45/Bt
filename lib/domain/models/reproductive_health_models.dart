import 'package:flutter/material.dart';

/// Flow intensity levels for menstrual tracking.
enum PeriodFlowLevel {
  spotting(displayName: 'Spotting', description: 'Minimal staining / spotting'),
  light(displayName: 'Light', description: 'Light flow'),
  medium(displayName: 'Medium', description: 'Moderate regular flow'),
  heavy(displayName: 'Heavy', description: 'Heavy flow requiring frequent changes');

  final String displayName;
  final String description;
  const PeriodFlowLevel({required this.displayName, required this.description});
}

/// Clinically recognized cycle & PMS symptoms.
enum PeriodSymptom {
  cramps(displayName: 'Abdominal Cramps', icon: Icons.waves_rounded),
  headache(displayName: 'Headache', icon: Icons.psychology_alt_rounded),
  bloating(displayName: 'Bloating', icon: Icons.bubble_chart_rounded),
  fatigue(displayName: 'Fatigue / Low Energy', icon: Icons.battery_2_bar_rounded),
  breastTenderness(displayName: 'Breast Tenderness', icon: Icons.favorite_border_rounded),
  backDiscomfort(displayName: 'Lower Back Discomfort', icon: Icons.accessibility_new_rounded),
  nausea(displayName: 'Nausea', icon: Icons.sick_rounded),
  moodChanges(displayName: 'Mood Shifts', icon: Icons.sentiment_neutral_rounded),
  acne(displayName: 'Skin Breakouts', icon: Icons.grain_rounded),
  cravings(displayName: 'Food Cravings', icon: Icons.restaurant_rounded),
  insomnia(displayName: 'Sleep Disruption', icon: Icons.bedtime_outlined),
  bodyAches(displayName: 'General Body Aches', icon: Icons.healing_rounded);

  final String displayName;
  final IconData icon;
  const PeriodSymptom({required this.displayName, required this.icon});
}

/// Emotional & mood states recorded during cycle tracking.
enum PeriodMood {
  calm(displayName: 'Calm & Grounded', emoji: '😌'),
  happy(displayName: 'Energetic & Uplifted', emoji: '✨'),
  sensitive(displayName: 'Emotionally Sensitive', emoji: '🥺'),
  irritable(displayName: 'Irritable / Restless', emoji: '😤'),
  anxious(displayName: 'Anxious / Overwhelmed', emoji: '😰'),
  exhausted(displayName: 'Exhausted / Drained', emoji: '😴');

  final String displayName;
  final String emoji;
  const PeriodMood({required this.displayName, required this.emoji});
}

/// Biological cycle phase.
enum PeriodPhase {
  menstrual(
    displayName: 'Menstrual Phase',
    description: 'Active cycle flow. Rest, gentle hydration, and restorative sleep are prioritized.',
    color: Color(0xFFF43F5E), // Rose
  ),
  follicular(
    displayName: 'Follicular Phase',
    description: 'Estrogen rises. Energy, metabolic stamina, and aerobic drive steadily climb.',
    color: Color(0xFF10B981), // Emerald
  ),
  ovulation(
    displayName: 'Ovulation Window',
    description: 'Peak hormonal vitality and cellular aerobic endurance. Optimal fertility window.',
    color: Color(0xFFA855F7), // Purple / Violet
  ),
  luteal(
    displayName: 'Luteal Phase',
    description: 'Progesterone dominant. Focus on magnesium-rich nutrition, recovery, and steady hydration.',
    color: Color(0xFFF59E0B), // Amber
  );

  final String displayName;
  final String description;
  final Color color;
  const PeriodPhase({
    required this.displayName,
    required this.description,
    required this.color,
  });
}

/// Represents a logged menstrual cycle or period window.
class PeriodCycleEntry {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final PeriodFlowLevel flow;
  final List<PeriodSymptom> symptoms;
  final PeriodMood? mood;
  final String notes;

  const PeriodCycleEntry({
    required this.id,
    required this.startDate,
    this.endDate,
    this.flow = PeriodFlowLevel.medium,
    this.symptoms = const [],
    this.mood,
    this.notes = '',
  });

  bool get isOngoing => endDate == null;

  int get periodDurationDays {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays.abs() + 1;
  }

  PeriodCycleEntry copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    PeriodFlowLevel? flow,
    List<PeriodSymptom>? symptoms,
    PeriodMood? mood,
    String? notes,
  }) {
    return PeriodCycleEntry(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flow: flow ?? this.flow,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
    );
  }
}

/// A daily logged entry for symptoms, mood, flow, or notes on a specific date.
class PeriodDailyLog {
  final String id;
  final DateTime date;
  final PeriodFlowLevel? flow;
  final List<PeriodSymptom> symptoms;
  final PeriodMood? mood;
  final String notes;

  const PeriodDailyLog({
    required this.id,
    required this.date,
    this.flow,
    this.symptoms = const [],
    this.mood,
    this.notes = '',
  });

  PeriodDailyLog copyWith({
    String? id,
    DateTime? date,
    PeriodFlowLevel? flow,
    List<PeriodSymptom>? symptoms,
    PeriodMood? mood,
    String? notes,
  }) {
    return PeriodDailyLog(
      id: id ?? this.id,
      date: date ?? this.date,
      flow: flow ?? this.flow,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
    );
  }
}

/// Prediction calculations and cycle metrics.
/// All predictions are treated as estimates with explicit uncertainty.
class PeriodPrediction {
  final DateTime? estimatedNextPeriodDate;
  final DateTime? fertileWindowStart;
  final DateTime? fertileWindowEnd;
  final DateTime? estimatedOvulationDate;
  final int currentCycleDay;
  final PeriodPhase currentPhase;
  final bool isLearningPhase;
  final String confidenceMessage;

  const PeriodPrediction({
    this.estimatedNextPeriodDate,
    this.fertileWindowStart,
    this.fertileWindowEnd,
    this.estimatedOvulationDate,
    required this.currentCycleDay,
    required this.currentPhase,
    required this.isLearningPhase,
    required this.confidenceMessage,
  });

  static const PeriodPrediction uninitialized = PeriodPrediction(
    currentCycleDay: 1,
    currentPhase: PeriodPhase.follicular,
    isLearningPhase: true,
    confidenceMessage: "Log your first period to start building your cycle estimates.",
  );
}

/// Method used to configure pregnancy tracking.
enum PregnancyReferenceType {
  lastMenstrualPeriod(displayName: 'Last Menstrual Period (LMP)'),
  estimatedDueDate(displayName: 'Estimated Due Date (EDD)'),
  conceptionDate(displayName: 'Conception Date');

  final String displayName;
  const PregnancyReferenceType({required this.displayName});
}

/// Active pregnancy configuration and calculated gestation milestones.
class PregnancyData {
  final String id;
  final PregnancyReferenceType referenceType;
  final DateTime referenceDate;
  final DateTime dueDate;
  final int currentWeek;
  final int currentDayOfCurrentWeek;
  final int totalDays;
  final int trimester;
  final String babySizeFruit;
  final String babySizeComparison;
  final double estimatedLengthCm;
  final double estimatedWeightGrams;
  final String notes;

  const PregnancyData({
    required this.id,
    required this.referenceType,
    required this.referenceDate,
    required this.dueDate,
    required this.currentWeek,
    required this.currentDayOfCurrentWeek,
    required this.totalDays,
    required this.trimester,
    required this.babySizeFruit,
    required this.babySizeComparison,
    required this.estimatedLengthCm,
    required this.estimatedWeightGrams,
    this.notes = '',
  });

  /// Calculates days remaining until the estimated due date.
  int get daysUntilDueDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return target.difference(today).inDays;
  }

  /// Gestational progress from 0.0 to 1.0 (based on standard 280 days = 40 weeks).
  double get progressRatio => (totalDays / 280.0).clamp(0.0, 1.0);

  String get trimesterLabel {
    switch (trimester) {
      case 1:
        return 'First Trimester';
      case 2:
        return 'Second Trimester';
      case 3:
        return 'Third Trimester';
      default:
        return 'Trimester $trimester';
    }
  }

  PregnancyData copyWith({
    String? id,
    PregnancyReferenceType? referenceType,
    DateTime? referenceDate,
    DateTime? dueDate,
    int? currentWeek,
    int? currentDayOfCurrentWeek,
    int? totalDays,
    int? trimester,
    String? babySizeFruit,
    String? babySizeComparison,
    double? estimatedLengthCm,
    double? estimatedWeightGrams,
    String? notes,
  }) {
    return PregnancyData(
      id: id ?? this.id,
      referenceType: referenceType ?? this.referenceType,
      referenceDate: referenceDate ?? this.referenceDate,
      dueDate: dueDate ?? this.dueDate,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDayOfCurrentWeek: currentDayOfCurrentWeek ?? this.currentDayOfCurrentWeek,
      totalDays: totalDays ?? this.totalDays,
      trimester: trimester ?? this.trimester,
      babySizeFruit: babySizeFruit ?? this.babySizeFruit,
      babySizeComparison: babySizeComparison ?? this.babySizeComparison,
      estimatedLengthCm: estimatedLengthCm ?? this.estimatedLengthCm,
      estimatedWeightGrams: estimatedWeightGrams ?? this.estimatedWeightGrams,
      notes: notes ?? this.notes,
    );
  }
}

/// Daily wellness log during pregnancy (symptoms, mood, sleep, notes).
class PregnancyLogEntry {
  final String id;
  final DateTime date;
  final List<String> symptoms;
  final String? mood;
  final String notes;
  final double sleepHours;
  final int waterGlasses;

  const PregnancyLogEntry({
    required this.id,
    required this.date,
    this.symptoms = const [],
    this.mood,
    this.notes = '',
    this.sleepHours = 0.0,
    this.waterGlasses = 0,
  });
}

/// Prenatal appointment or reminder item.
class PregnancyAppointment {
  final String id;
  final String title;
  final DateTime date;
  final String providerOrLocation;
  final String notes;
  final bool isCompleted;

  const PregnancyAppointment({
    required this.id,
    required this.title,
    required this.date,
    this.providerOrLocation = '',
    this.notes = '',
    this.isCompleted = false,
  });

  PregnancyAppointment copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? providerOrLocation,
    String? notes,
    bool? isCompleted,
  }) {
    return PregnancyAppointment(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      providerOrLocation: providerOrLocation ?? this.providerOrLocation,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
