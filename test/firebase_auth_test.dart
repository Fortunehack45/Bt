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
        plan: UserPlanTier.premium,
        createdAt: DateTime.parse('2026-10-01T12:00:00Z'),
        lastActiveAt: DateTime.parse('2026-10-08T04:00:00Z'),
      );

      final json = user.toJson();
      expect(json['uid'], 'usr_test_123');
      expect(json['email'], 'patient@example.com');
      expect(json['plan'], 'premium');

      final revived = AuthUser.fromJson(json);
      expect(revived.uid, user.uid);
      expect(revived.email, user.email);
      expect(revived.plan, UserPlanTier.premium);
      expect(revived.plan == UserPlanTier.premium, true);
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

    test('registers and authenticates new email user', () async {
      final success = await authService.registerWithEmailAndPassword(
        email: 'health_explorer@wellnest.com',
        password: 'Password123!',
        displayName: 'Health Explorer',
      );

      expect(success, true);
      expect(authService.currentUser?.email, 'health_explorer@wellnest.com');
      expect(authService.currentUser?.displayName, 'Health Explorer');
      expect(authService.isAuthenticated, true);
    });

    test('handles Google Sign-In fallback correctly', () async {
      final success = await authService.signInWithGoogle();
      expect(success, true);
      expect(authService.currentUser?.email.isNotEmpty, true);
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

  group('WellnessProvider Auth Integration Tests', () {
    late WellnessProvider provider;

    setUp(() {
      provider = WellnessProvider();
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
