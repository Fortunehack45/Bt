import 'package:flutter_test/flutter_test.dart';
import 'package:wellnest/core/services/firebase_auth_service.dart';
import 'package:wellnest/domain/models/auth_user_model.dart';
import 'package:wellnest/domain/state/wellness_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthUser Domain Model Tests', () {
    test('serializes and deserializes AuthUser accurately', () {
      final user = AuthUser(
        uid: 'usr_test_123',
        email: 'patient@example.com',
        displayName: 'Test Patient',
        photoUrl: null,
        isGuest: false,
        planTier: UserPlanTier.premium,
        createdAt: DateTime.parse('2026-10-01T12:00:00Z'),
        lastActiveAt: DateTime.parse('2026-10-08T04:00:00Z'),
      );

      final json = user.toJson();
      expect(json['uid'], 'usr_test_123');
      expect(json['email'], 'patient@example.com');
      expect(json['planTier'], 'premium');
      expect(json['isGuest'], false);

      final revived = AuthUser.fromJson(json);
      expect(revived.uid, user.uid);
      expect(revived.email, user.email);
      expect(revived.planTier, UserPlanTier.premium);
      expect(revived.isPremium, true);
    });

    test('anonymizedAccountId formats correctly for zero-knowledge isolation', () {
      final user = AuthUser(
        uid: 'a1b2c3d4e5f6g7h8',
        email: 'secret@patient.org',
        isGuest: false,
        planTier: UserPlanTier.freemium,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      expect(user.anonymizedAccountId, 'USR-A1B2');
      expect(user.isPremium, false);
    });
  });

  group('FirebaseAuthService Authentication Flow Tests', () {
    late FirebaseAuthService authService;

    setUp(() {
      authService = FirebaseAuthService();
    });

    test('signs in as guest explorer seamlessly', () async {
      final guest = await authService.signInAsGuest();
      expect(guest.isGuest, true);
      expect(guest.planTier, UserPlanTier.freemium);
      expect(authService.currentUser?.isGuest, true);
    });

    test('registers and authenticates new email user', () async {
      final user = await authService.registerWithEmailPassword(
        email: 'health_explorer@wellnest.com',
        password: 'Password123!',
        displayName: 'Health Explorer',
      );

      expect(user.email, 'health_explorer@wellnest.com');
      expect(user.displayName, 'Health Explorer');
      expect(user.isGuest, false);
      expect(authService.currentUser?.email, 'health_explorer@wellnest.com');
    });

    test('handles Google Sign-In fallback correctly', () async {
      final googleUser = await authService.signInWithGoogle();
      expect(googleUser.email, isNotNull);
      expect(googleUser.isGuest, false);
      expect(authService.currentUser, isNotNull);
    });

    test('signOut terminates active session cleanly', () async {
      await authService.signInAsGuest();
      expect(authService.currentUser, isNotNull);

      await authService.signOut();
      expect(authService.currentUser, isNull);
    });
  });

  group('WellnessProvider Auth Integration Tests', () {
    late WellnessProvider provider;

    setUp(() {
      provider = WellnessProvider();
    });

    test('updates provider state on user sign in and upgrade', () async {
      expect(provider.isAuthenticated, false);
      expect(provider.planTier, UserPlanTier.freemium);

      final user = await provider.authService.signInWithEmailPassword(
        email: 'subscriber@wellnest.com',
        password: 'password',
      );

      expect(provider.isAuthenticated, true);
      expect(provider.authUser?.email, user.email);

      // Upgrade tier
      await provider.authService.upgradeToPremium();
      expect(provider.planTier, UserPlanTier.premium);
      expect(provider.isPremiumPlan, true);
    });
  });
}
