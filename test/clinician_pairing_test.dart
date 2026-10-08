import 'package:flutter_test/flutter_test.dart';
import 'package:wellnest/core/services/firebase_sync_service.dart';
import 'package:wellnest/domain/models/clinician_pair_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ClinicianPairGrant Domain Model Tests', () {
    test('accurately calculates isExpired and remaining duration', () {
      final activeGrant = ClinicianPairGrant(
        pairCode: 'DOC-1234',
        patientId: 'patient_alpha',
        patientDisplayName: 'Sarah Connor',
        securityQuestion1: 'Patient Legal Name',
        securityAnswer1: 'Sarah Connor',
        securityQuestion2: 'Favorite Color',
        securityAnswer2: 'Blue',
        permittedSections: ['vitals', 'sleep'],
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 4)),
      );

      expect(activeGrant.isExpired, false);
      expect(activeGrant.remainingDuration.inMinutes, greaterThan(200));

      final expiredGrant = ClinicianPairGrant(
        pairCode: 'DOC-9999',
        patientId: 'patient_beta',
        patientDisplayName: 'John Doe',
        securityQuestion1: 'Patient Legal Name',
        securityAnswer1: 'John Doe',
        securityQuestion2: 'Favorite Color',
        securityAnswer2: 'Green',
        permittedSections: ['vitals'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(expiredGrant.isExpired, true);
      expect(expiredGrant.remainingDuration, Duration.zero);
    });

    test('enforces strict category access permissions', () {
      final grant = ClinicianPairGrant(
        pairCode: 'DOC-5678',
        patientId: 'patient_gamma',
        patientDisplayName: 'Alice Springs',
        securityQuestion1: 'Patient Legal Name',
        securityAnswer1: 'Alice Springs',
        securityQuestion2: 'Favorite Color',
        securityAnswer2: 'Indigo',
        permittedSections: ['vitals', 'steps'],
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );

      expect(grant.canAccessSection('vitals'), true);
      expect(grant.canAccessSection('steps'), true);
      expect(grant.canAccessSection('sleep'), false);
      expect(grant.canAccessSection('reproductive_health'), false);
    });

    test('verifies security answers case-insensitively and trims whitespace', () {
      final grant = ClinicianPairGrant(
        pairCode: 'DOC-4444',
        patientId: 'patient_delta',
        patientDisplayName: 'Alexander Hamilton',
        securityQuestion1: 'Patient Legal Name',
        securityAnswer1: 'Alexander Hamilton',
        securityQuestion2: 'Favorite Color',
        securityAnswer2: 'Amber',
        permittedSections: ['vitals'],
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(grant.verifyAnswers('alexander hamilton', 'amber'), true);
      expect(grant.verifyAnswers(' ALEXANDER HAMILTON ', ' AMBER '), true);
      expect(grant.verifyAnswers('Alexander Hamilton', 'wrong_secret'), false);
      expect(grant.verifyAnswers('Wrong Name', 'Amber'), false);
    });
  });

  group('FirebaseSyncService Clinician and Screenshot Tests', () {
    final syncService = FirebaseSyncService.instance;

    test('creates new grant with unique pair code and security questions', () async {
      final grant = await syncService.createClinicianGrant(
        legalName: 'Doctor Who',
        secretColor: 'Tardis Blue',
        durationHours: 24,
        allowedCategories: ['vitals', 'sleep', 'steps'],
      );

      expect(grant.pairCode.startsWith('DOC-'), true);
      expect(grant.patientDisplayName, 'Doctor Who');
      expect(grant.permittedSections.length, 3);
      expect(grant.isExpired, false);
    });

    test('verifies doctor login with pair code and security questions', () async {
      final created = await syncService.createClinicianGrant(
        legalName: 'Grace Hopper',
        secretColor: 'Navy Blue',
        durationHours: 12,
      );

      final verified = await syncService.verifyClinicianCode(
        code: created.pairCode,
        ans1: 'grace hopper',
        ans2: 'navy blue',
      );

      expect(verified, isNotNull);
      expect(verified?.pairCode, created.pairCode);

      final failed = await syncService.verifyClinicianCode(
        code: created.pairCode,
        ans1: 'grace hopper',
        ans2: 'red',
      );
      expect(failed, isNull);
    });

    test('logs screenshot audit and dispatches notification callback', () async {
      final grant = await syncService.createClinicianGrant(
        legalName: 'Alan Turing',
        secretColor: 'Enigma',
        durationHours: 2,
      );

      // Log in as clinician
      await syncService.verifyClinicianCode(
        code: grant.pairCode,
        ans1: 'Alan Turing',
        ans2: 'Enigma',
      );

      ScreenshotAuditEntry? notifiedEntry;
      syncService.onScreenshotAlert = (entry) {
        notifiedEntry = entry;
      };

      await syncService.reportScreenshotCaptured('Resting Heart Rate & HRV Graph');

      expect(notifiedEntry, isNotNull);
      expect(notifiedEntry?.sectionName, 'Resting Heart Rate & HRV Graph');

      final activeSession = syncService.activeClinicianSession;
      expect(activeSession?.screenshotAuditLog.isNotEmpty, true);
    });
  });

  group('FirebaseSyncService Social Goals & Support Tests', () {
    final syncService = FirebaseSyncService.instance;

    test('creates and tracks shared partner goals with nudges', () async {
      final goal = await syncService.createSharedGoal(
        title: '7-Day 10k Steps Challenge',
        metricType: 'steps',
        targetValue: 70000,
        unit: 'steps',
      );

      expect(goal.title, '7-Day 10k Steps Challenge');
      expect(goal.participants.isNotEmpty, true);
      expect(goal.totalProgressPercent, 0.0);

      // Send nudge
      await syncService.sendGoalNudge(
        goalId: goal.id,
        targetUserId: 'partner_01',
        message: 'Let’s go for an evening walk! 🚶',
      );

      final updatedGoal = syncService.sharedGoals.firstWhere((g) => g.id == goal.id);
      expect(updatedGoal.recentNudges.isNotEmpty, true);
      expect(updatedGoal.recentNudges.first.message, contains('evening walk'));
    });

    test('creates support ticket and exchanges real-time messages', () async {
      final ticket = await syncService.createSupportTicket(
        subject: 'Pair code expiry extension request',
        category: 'Security',
        initialMessage: 'Can I extend my doctor session while it is active?',
      );

      expect(ticket.subject, 'Pair code expiry extension request');
      expect(ticket.status, 'open');
      expect(ticket.messages.length, 1);

      await syncService.sendTicketMessage(
        ticketId: ticket.ticketId,
        content: 'Hi! You can create a new pass with a custom duration at any time.',
        isSupport: true,
      );

      final updatedTicket = syncService.supportTickets.firstWhere((t) => t.ticketId == ticket.ticketId);
      expect(updatedTicket.messages.length, 2);
      expect(updatedTicket.status, 'in_progress');
    });
  });
}
