import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biothrix/domain/models/reproductive_health_models.dart';
import 'package:biothrix/domain/state/wellness_provider.dart';
import 'package:biothrix/features/home/home_screen.dart';
import 'package:biothrix/features/home/widgets/period_cycle_hero_card.dart';
import 'package:biothrix/features/home/widgets/pregnancy_journey_hero_card.dart';

void main() {
  group('Reproductive Health Onboarding & Home Screen Integration Tests', () {
    test('Updating biometrics enables specialized reproductive health tracking', () {
      final provider = WellnessProvider();
      expect(provider.isPeriodTrackingEnabled, isFalse);
      expect(provider.isPregnancyTrackingEnabled, isFalse);

      provider.updateBiometrics(
        gender: 'Female',
        age: 28,
        heightCm: 165.0,
        weightKg: 60.0,
        goal: 'Vitality & Daily Energy',
        isPeriodTrackingEnabled: true,
        isPregnancyTrackingEnabled: false,
      );

      expect(provider.gender, 'Female');
      expect(provider.age, 28);
      expect(provider.isPeriodTrackingEnabled, isTrue);
      expect(provider.isPregnancyTrackingEnabled, isFalse);
    });

    testWidgets('HomeScreen renders PeriodCycleHeroCard when period tracking is active', (WidgetTester tester) async {
      final provider = WellnessProvider();
      provider.updateBiometrics(
        gender: 'Female',
        age: 26,
        heightCm: 168.0,
        weightKg: 58.0,
        goal: 'Vitality & Daily Energy',
        isPeriodTrackingEnabled: true,
      );

      // Start a cycle so the hero card shows active status
      provider.startPeriod(DateTime.now(), flow: PeriodFlowLevel.medium);

      await tester.pumpWidget(
        MaterialApp(
          home: WellnessStateScope(
            provider: provider,
            child: HomeScreen(
              onNavigateToStats: () {},
              onNavigateToHydration: () {},
              onNavigateToActivity: () {},
              onNavigateToSleep: () {},
              onNavigateToNutrition: () {},
              onAddMeal: () {},
              onWaterQuickAdd: () {},
            ),
          ),
        ),
      );

      expect(find.byType(PeriodCycleHeroCard), findsOneWidget);
      expect(find.text('Menstrual Cycle'), findsOneWidget);
      expect(find.textContaining('Period Active'), findsOneWidget);
      expect(find.byType(PregnancyJourneyHeroCard), findsNothing);
    });

    testWidgets('HomeScreen renders PregnancyJourneyHeroCard when pregnancy tracking is active', (WidgetTester tester) async {
      final provider = WellnessProvider();
      provider.updateBiometrics(
        gender: 'Female',
        age: 29,
        heightCm: 165.0,
        weightKg: 62.0,
        goal: 'Healthy Weight Management',
        isPregnancyTrackingEnabled: true,
      );

      provider.setupPregnancy(
        type: PregnancyReferenceType.lastMenstrualPeriod,
        date: DateTime.now().subtract(const Duration(days: 70)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WellnessStateScope(
            provider: provider,
            child: HomeScreen(
              onNavigateToStats: () {},
              onNavigateToHydration: () {},
              onNavigateToActivity: () {},
              onNavigateToSleep: () {},
              onNavigateToNutrition: () {},
              onAddMeal: () {},
              onWaterQuickAdd: () {},
            ),
          ),
        ),
      );

      expect(find.byType(PregnancyJourneyHeroCard), findsOneWidget);
      expect(find.text('Pregnancy Journey'), findsOneWidget);
      expect(find.textContaining('Week 11'), findsOneWidget);
      expect(find.byType(PeriodCycleHeroCard), findsNothing);
    });

    testWidgets('HomeScreen renders standard layout without reproductive hero cards when disabled', (WidgetTester tester) async {
      final provider = WellnessProvider();
      provider.updateBiometrics(
        gender: 'Male',
        age: 32,
        heightCm: 180.0,
        weightKg: 75.0,
        goal: 'Cardiovascular Fitness',
        isPeriodTrackingEnabled: false,
        isPregnancyTrackingEnabled: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WellnessStateScope(
            provider: provider,
            child: HomeScreen(
              onNavigateToStats: () {},
              onNavigateToHydration: () {},
              onNavigateToActivity: () {},
              onNavigateToSleep: () {},
              onNavigateToNutrition: () {},
              onAddMeal: () {},
              onWaterQuickAdd: () {},
            ),
          ),
        ),
      );

      expect(find.byType(PeriodCycleHeroCard), findsNothing);
      expect(find.byType(PregnancyJourneyHeroCard), findsNothing);
    });
  });
}
