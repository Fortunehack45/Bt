import 'package:flutter_test/flutter_test.dart';
import 'package:wellnest/core/services/firebase_auth_service.dart';
import 'package:wellnest/domain/models/auth_user_model.dart';
import 'package:wellnest/domain/state/wellness_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthUser Domain Model Tests', () {
    test('serializes and deserializes AuthUser accurately with bloodGroup and onboarding state', () {
      final user = AuthUser(
        uid: 'usr_test_123',
        email: 'patient@example.com',
        displayName: 'Test Patient',
        photoUrl: null,
        plan: UserPlanTier.premium,
        createdAt: DateTime.parse('2026-10-01T12:00:00Z'),
        lastActiveAt: DateTime.parse('2026-10-08T04:00:00Z'),
        bloodGroup: 'O+',
        hasCompletedOnboarding: true,
        healthProfile: {'weightKg': 72.0, 'heightCm': 178.0},
      );

      final json = user.toJson();
      expect(json['uid'], 'usr_test_123');
      expect(json['email'], 'patient@example.com');
      expect(json['plan'], 'premium');
      expect(json['bloodGroup'], 'O+');
      expect(json['hasCompletedOnboarding'], true);
      expect(json['healthProfile']?['weightKg'], 72.0);

      final revived = AuthUser.fromJson(json);
      expect(revived.uid, user.uid);
      expect(revived.email, user.email);
      expect(revived.plan, UserPlanTier.premium);
      expect(revived.plan == UserPlanTier.premium, true);
      expect(revived.bloodGroup, 'O+');
      expect(revived.hasCompletedOnboarding, true);
      expect(revived.healthProfile?['weightKg'], 72.0);
    });

    test('anonymizedId formats correctly for zero-knowledge isolation', () {
      final user = AuthUser(
        uid: 'a1b2c3d4e5f6g7h8',
        email: 'secret@patient.org',
        displayName: 'Secret Patient',
        plan: UserPlanTier.freemium,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      expect(user.anonymizedId.startsWith('USR-'), true);
      expect(user.plan == UserPlanTier.premium, false);
    });
  });

  group('FirebaseAuthService Authentication Flow Tests', () {
    final authService = FirebaseAuthService.instance;

    test('signs in as guest explorer seamlessly', () async {
      await authService.signInAsGuest();
      expect(authService.currentUser, isNotNull);
      expect(authService.isGuest, true);
      expect(authService.currentUser?.plan, UserPlanTier.freemium);
    });

    test('registers and authenticates new email user with hasCompletedOnboarding false', () async {
      final success = await authService.registerWithEmailAndPassword(
        email: 'health_explorer@wellnest.com',
        password: 'Password123!',
        displayName: 'Health Explorer',
      );

      expect(success, true);
      expect(authService.currentUser?.email, 'health_explorer@wellnest.com');
      expect(authService.currentUser?.displayName, 'Health Explorer');
      expect(authService.currentUser?.hasCompletedOnboarding, false);
      expect(authService.isAuthenticated, true);
    });

    test('completes onboarding and persists blood group in database', () async {
      await authService.markOnboardingComplete(
        bloodGroup: 'B+',
        healthProfile: {
          'age': 28,
          'gender': 'Male',
          'heightCm': 180.0,
          'weightKg': 75.0,
          'bloodGroup': 'B+',
        },
      );

      expect(authService.currentUser?.hasCompletedOnboarding, true);
      expect(authService.currentUser?.bloodGroup, 'B+');
      expect(authService.currentUser?.healthProfile?['weightKg'], 75.0);
    });

    test('rejects duplicate email registration', () async {
      final duplicateSuccess = await authService.registerWithEmailAndPassword(
        email: 'health_explorer@wellnest.com',
        password: 'AnotherPassword456!',
        displayName: 'Impostor',
      );

      expect(duplicateSuccess, false);
      expect(authService.lastAuthError?.contains('already exists'), true);
    });

    test('rejects incorrect password on sign in', () async {
      final wrongPasswordSuccess = await authService.signInWithEmailAndPassword(
        email: 'health_explorer@wellnest.com',
        password: 'WrongPassword!',
      );

      expect(wrongPasswordSuccess, false);
      expect(authService.lastAuthError?.contains('Incorrect password'), true);
    });

    test('authenticates valid email and password credentials restoring persisted profile', () async {
      final loginSuccess = await authService.signInWithEmailAndPassword(
        email: 'health_explorer@wellnest.com',
        password: 'Password123!',
      );

      expect(loginSuccess, true);
      expect(authService.currentUser?.email, 'health_explorer@wellnest.com');
      expect(authService.currentUser?.hasCompletedOnboarding, true);
      expect(authService.currentUser?.bloodGroup, 'B+');
      expect(authService.isAuthenticated, true);
    });

    test('handles Google Sign-In with user specific identity', () async {
      final success = await authService.signInWithGoogle(
        email: 'fortunedomination@gmail.com',
        displayName: 'Fortune User',
      );
      expect(success, true);
      expect(authService.currentUser?.email, 'fortunedomination@gmail.com');
      expect(authService.currentUser?.displayName, 'Fortune User');
      expect(authService.currentUser?.email != 'alex.morgan@gmail.com', true);
      expect(authService.isAuthenticated, true);
    });

    test('signOut terminates active session cleanly', () async {
      await authService.signInAsGuest();
      expect(authService.currentUser, isNotNull);

      await authService.signOut();
      expect(authService.isGuest, true);
      expect(authService.isAuthenticated, false);
    });
  });

  group('WellnessProvider Health Intelligence & Predictive Formulas', () {
    late WellnessProvider provider;

    setUp(() {
      provider = WellnessProvider();
    });

    test('calculates BMR, TDEE, water goal, and heart rate zones accurately', () {
      provider.updateBiometrics(
        age: 26,
        gender: 'Male',
        heightCm: 178.0,
        weightKg: 70.0,
        activityLevel: 'Moderate Activity',
        bloodGroup: 'O+',
      );

      // Mifflin-St Jeor formula for male (70kg, 178cm, 26y):
      // (10 * 70) + (6.25 * 178) - (5 * 26) + 5 = 700 + 1112.5 - 130 + 5 = 1687.5 kcal
      expect(provider.bmr.round(), 1688);

      // TDEE = BMR * 1.55 = 1687.5 * 1.55 = 2615.6 -> 2616 kcal
      expect(provider.tdee, 2616);

      // Water intake = (70 * 35) + 350 (moderate activity) = 2450 + 350 = 2800 ml
      expect(provider.recommendedWaterMl, 2800);
      expect(provider.recommendedWaterGlasses, (2800 / 250).ceil());

      // Max HR = 220 - 26 = 194 bpm
      expect(provider.maxHeartRateBpm, 194);
      expect(provider.heartRateZones.containsKey(2), true);

      // Blood Group report
      expect(provider.bloodGroup, 'O+');
      expect(provider.bloodGroupReport.archetype.contains('Hunter-Gatherer'), true);
      expect(provider.bloodGroupReport.clinicalRecommendations.isNotEmpty, true);
    });

    test('updates provider state on user sign in and upgrade', () async {
      final success = await FirebaseAuthService.instance.signInWithEmailAndPassword(
        email: 'subscriber@wellnest.com',
        password: 'password',
      );

      expect(success, true);
      expect(provider.authUser?.email, 'subscriber@wellnest.com');

      // Upgrade tier
      await FirebaseAuthService.instance.upgradeToPremium();
      expect(provider.planTier, UserPlanTier.premium);
    });
  });
}
