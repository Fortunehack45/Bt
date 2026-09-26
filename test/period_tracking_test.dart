import 'package:flutter_test/flutter_test.dart';
import 'package:biothrix/domain/models/reproductive_health_models.dart';
import 'package:biothrix/domain/state/wellness_provider.dart';

void main() {
  group('Period Tracking & Menstrual Vitality Tests', () {
    late WellnessProvider provider;

    setUp(() {
      provider = WellnessProvider();
    });

    test('Initializes with period tracking disabled and empty cycle records', () {
      expect(provider.isPeriodTrackingEnabled, isFalse);
      expect(provider.periodCycles, isEmpty);
      expect(provider.periodDailyLogs, isEmpty);
      expect(provider.activePeriod, isNull);
      expect(provider.lastRecordedPeriod, isNull);
      expect(provider.currentCycleDay, 1);
      expect(provider.averageCycleLength, 28.0);
      expect(provider.averagePeriodDuration, 5.0);
      expect(provider.periodPrediction.isLearningPhase, isTrue);
    });

    test('Enabling and disabling period tracking toggles flag without data loss', () {
      provider.setPeriodTrackingEnabled(true);
      expect(provider.isPeriodTrackingEnabled, isTrue);

      final startDate = DateTime.now().subtract(const Duration(days: 3));
      provider.startPeriod(startDate, flow: PeriodFlowLevel.medium);
      expect(provider.periodCycles.length, 1);

      provider.setPeriodTrackingEnabled(false);
      expect(provider.isPeriodTrackingEnabled, isFalse);
      // Historical cycle records must be preserved
      expect(provider.periodCycles.length, 1);
    });

    test('Starting a period sets active period and cycle day', () {
      provider.setPeriodTrackingEnabled(true);
      final today = DateTime.now();
      final start = today.subtract(const Duration(days: 2));

      provider.startPeriod(
        start,
        flow: PeriodFlowLevel.heavy,
        symptoms: [PeriodSymptom.cramps, PeriodSymptom.fatigue],
        mood: PeriodMood.sensitive,
        notes: 'Flow started in morning',
      );

      expect(provider.activePeriod, isNotNull);
      expect(provider.activePeriod!.flow, PeriodFlowLevel.heavy);
      expect(provider.activePeriod!.symptoms, contains(PeriodSymptom.cramps));
      expect(provider.activePeriod!.mood, PeriodMood.sensitive);
      expect(provider.activePeriod!.notes, 'Flow started in morning');
      expect(provider.currentCycleDay, 3); // 2 days ago + 1 = day 3
      expect(provider.isPeriodDay(start), isTrue);
      expect(provider.isPeriodDay(today), isTrue);
    });

    test('Ending a period marks active cycle as completed', () {
      provider.setPeriodTrackingEnabled(true);
      final start = DateTime.now().subtract(const Duration(days: 5));
      provider.startPeriod(start, flow: PeriodFlowLevel.medium);

      expect(provider.activePeriod, isNotNull);

      final end = DateTime.now().subtract(const Duration(days: 1));
      provider.endPeriod(end);

      expect(provider.activePeriod, isNull);
      expect(provider.lastRecordedPeriod, isNotNull);
      expect(provider.lastRecordedPeriod!.endDate, isNotNull);
      expect(provider.lastRecordedPeriod!.periodDurationDays, 5);
    });

    test('Logging daily details updates daily log map', () {
      final logDate = DateTime(2026, 9, 26);
      provider.logDailyPeriodDetails(
        logDate,
        flow: PeriodFlowLevel.spotting,
        symptoms: [PeriodSymptom.bloating, PeriodSymptom.headache],
        mood: PeriodMood.calm,
        notes: 'Mild headache before bedtime',
      );

      final dailyLog = provider.getPeriodDailyLog(logDate);
      expect(dailyLog, isNotNull);
      expect(dailyLog!.flow, PeriodFlowLevel.spotting);
      expect(dailyLog.symptoms.length, 2);
      expect(dailyLog.symptoms, contains(PeriodSymptom.bloating));
      expect(dailyLog.mood, PeriodMood.calm);
      expect(dailyLog.notes, 'Mild headache before bedtime');
    });

    test('Cycle length and period duration compute accurate historical averages', () {
      final now = DateTime.now();
      // Cycle 1: 58 days ago to 53 days ago (5 days duration)
      final c1Start = now.subtract(const Duration(days: 58));
      final c1End = now.subtract(const Duration(days: 53));

      // Cycle 2: 30 days ago to 25 days ago (5 days duration, 28 days interval)
      final c2Start = now.subtract(const Duration(days: 30));
      final c2End = now.subtract(const Duration(days: 25));

      // Cycle 3: 2 days ago (ongoing)
      final c3Start = now.subtract(const Duration(days: 2));

      provider.startPeriod(c1Start);
      provider.endPeriod(c1End);

      provider.startPeriod(c2Start);
      provider.endPeriod(c2End);

      provider.startPeriod(c3Start);

      expect(provider.periodCycles.length, 3);
      expect(provider.averageCycleLength, 28.0);
      expect(provider.averagePeriodDuration, 5.0);
    });

    test('Predictions calculate next period date, ovulation, and fertile window accurately', () {
      final now = DateTime.now();
      // Single recent cycle 10 days ago (follicular phase)
      final start = now.subtract(const Duration(days: 10));
      provider.startPeriod(start);
      provider.endPeriod(start.add(const Duration(days: 4)));

      final pred = provider.periodPrediction;
      expect(pred.isLearningPhase, isTrue); // < 2 cycles = learning phase
      expect(pred.confidenceMessage, contains('learning'));

      // Cycle length defaults to 28 days
      expect(pred.estimatedNextPeriodDate, isNotNull);
      final expectedNext = DateTime(start.year, start.month, start.day).add(const Duration(days: 28));
      expect(pred.estimatedNextPeriodDate!.year, expectedNext.year);
      expect(pred.estimatedNextPeriodDate!.month, expectedNext.month);
      expect(pred.estimatedNextPeriodDate!.day, expectedNext.day);

      // Fertile window and ovulation
      expect(pred.estimatedOvulationDate, isNotNull);
      expect(pred.fertileWindowStart, isNotNull);
      expect(pred.fertileWindowEnd, isNotNull);
      expect(pred.fertileWindowStart!.isBefore(pred.estimatedOvulationDate!), isTrue);
      expect(pred.fertileWindowEnd!.isAfter(pred.estimatedOvulationDate!), isTrue);
    });

    test('Calendar telemetry reflects period active days', () {
      provider.setPeriodTrackingEnabled(true);
      final today = DateTime.now();
      provider.startPeriod(today);

      final telemetry = provider.getDayTelemetry(today);
      expect(telemetry.hasPeriod, isTrue);
    });
  });
}
