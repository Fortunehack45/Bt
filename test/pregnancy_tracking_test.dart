import 'package:flutter_test/flutter_test.dart';
import 'package:biothrix/domain/models/reproductive_health_models.dart';
import 'package:biothrix/domain/state/wellness_provider.dart';

void main() {
  group('Pregnancy Tracking & Gestational Wellness Tests', () {
    late WellnessProvider provider;

    setUp(() {
      provider = WellnessProvider();
    });

    test('Initializes with pregnancy tracking disabled and empty state', () {
      expect(provider.isPregnancyTrackingEnabled, isFalse);
      expect(provider.pregnancyData, isNull);
      expect(provider.pregnancyLogs, isEmpty);
      expect(provider.pregnancyAppointments, isEmpty);
    });

    test('setupPregnancy with LMP computes correct gestation week and due date', () {
      final now = DateTime.now();
      // LMP 10 weeks ago (70 days)
      final lmp = now.subtract(const Duration(days: 70));

      provider.setupPregnancy(
        type: PregnancyReferenceType.lastMenstrualPeriod,
        date: lmp,
        notes: 'Confirmed by home test',
      );

      expect(provider.isPregnancyTrackingEnabled, isTrue);
      final preg = provider.pregnancyData;
      expect(preg, isNotNull);
      expect(preg!.referenceType, PregnancyReferenceType.lastMenstrualPeriod);
      expect(preg.currentWeek, 11); // 70 ~/ 7 + 1 = 11
      expect(preg.trimester, 1); // <= 12 is 1st trimester
      expect(preg.trimesterLabel, 'First Trimester');
      expect(preg.babySizeFruit, isNotEmpty);
      expect(preg.daysUntilDueDate, greaterThan(0));
    });

    test('setupPregnancy with EDD computes accurate remaining days and trimester', () {
      final now = DateTime.now();
      // Due in 140 days (approx 20 weeks remaining = around week 20)
      final edd = now.add(const Duration(days: 140));

      provider.setupPregnancy(
        type: PregnancyReferenceType.estimatedDueDate,
        date: edd,
      );

      final preg = provider.pregnancyData;
      expect(preg, isNotNull);
      expect(preg!.referenceType, PregnancyReferenceType.estimatedDueDate);
      expect(preg.trimester, 2); // Week 21 is Second Trimester
      expect(preg.trimesterLabel, 'Second Trimester');
      expect(preg.babySizeFruit, 'Papaya');
      expect(preg.daysUntilDueDate, 140);
    });

    test('setupPregnancy with Conception Date correctly maps to 266-day gestation', () {
      final now = DateTime.now();
      final conception = now.subtract(const Duration(days: 28));

      provider.setupPregnancy(
        type: PregnancyReferenceType.conceptionDate,
        date: conception,
      );

      final preg = provider.pregnancyData;
      expect(preg, isNotNull);
      // LMP is conception - 14 days = 42 days ago (week 7)
      expect(preg!.currentWeek, 7);
      expect(preg.babySizeFruit, 'Raspberry');
    });

    test('logPregnancyWellness records maternal wellbeing and symptoms', () {
      final today = DateTime.now();
      provider.setupPregnancy(
        type: PregnancyReferenceType.lastMenstrualPeriod,
        date: today.subtract(const Duration(days: 84)), // week 13
      );

      provider.logPregnancyWellness(
        today,
        symptoms: ['Morning Sickness', 'Mild Fatigue'],
        mood: 'Hopeful & calm',
        notes: 'Felt first flutters today',
        sleepHours: 8.5,
        waterGlasses: 8,
      );

      expect(provider.pregnancyLogs.length, 1);
      final log = provider.pregnancyLogs.first;
      expect(log.symptoms, contains('Morning Sickness'));
      expect(log.mood, 'Hopeful & calm');
      expect(log.notes, 'Felt first flutters today');
      expect(log.sleepHours, 8.5);
      expect(log.waterGlasses, 8);

      final telemetry = provider.getDayTelemetry(today);
      expect(telemetry.hasPregnancyLog, isTrue);
    });

    test('addPregnancyAppointment adds and toggles completion', () {
      final apptDate = DateTime.now().add(const Duration(days: 14));
      provider.addPregnancyAppointment(
        '20-Week Anatomy Ultrasound',
        apptDate,
        providerOrLocation: 'Dr. Evelyn Carter, St. Jude Clinic',
        notes: 'Bring ultrasound journal',
      );

      expect(provider.pregnancyAppointments.length, 1);
      final appt = provider.pregnancyAppointments.first;
      expect(appt.title, '20-Week Anatomy Ultrasound');
      expect(appt.isCompleted, isFalse);

      provider.toggleAppointmentCompleted(appt.id);
      expect(provider.pregnancyAppointments.first.isCompleted, isTrue);
    });

    test('transitionToPregnancyFromLastPeriod uses most recent period as LMP', () {
      final now = DateTime.now();
      final lastPeriodDate = now.subtract(const Duration(days: 35));

      // User logged a period 5 weeks ago
      provider.startPeriod(lastPeriodDate);
      provider.endPeriod(lastPeriodDate.add(const Duration(days: 5)));

      // Tap 1-step transition to pregnancy
      provider.transitionToPregnancyFromLastPeriod();

      expect(provider.isPregnancyTrackingEnabled, isTrue);
      final preg = provider.pregnancyData;
      expect(preg, isNotNull);
      expect(preg!.referenceDate.year, lastPeriodDate.year);
      expect(preg.referenceDate.month, lastPeriodDate.month);
      expect(preg.referenceDate.day, lastPeriodDate.day);
      expect(preg.currentWeek, 6);

      // Period history is preserved
      expect(provider.periodCycles.length, 1);
    });

    test('clearPregnancyData preserves historical records when keepHistory is true', () {
      provider.setupPregnancy(
        type: PregnancyReferenceType.lastMenstrualPeriod,
        date: DateTime.now().subtract(const Duration(days: 60)),
      );
      provider.logPregnancyWellness(DateTime.now(), symptoms: ['Nausea']);
      provider.addPregnancyAppointment('Follow-up', DateTime.now().add(const Duration(days: 7)));

      expect(provider.pregnancyLogs.length, 1);
      expect(provider.pregnancyAppointments.length, 1);

      // Toggle off pregnancy focus
      provider.clearPregnancyData(keepHistory: true);

      expect(provider.isPregnancyTrackingEnabled, isFalse);
      // History remains intact for user peace of mind
      expect(provider.pregnancyLogs.length, 1);
      expect(provider.pregnancyAppointments.length, 1);
      expect(provider.pregnancyData, isNotNull);
    });
  });
}
