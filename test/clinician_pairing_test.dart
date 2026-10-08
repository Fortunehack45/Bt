import 'package:flutter_test/flutter_test.dart';
import 'package:wellnest/core/services/firebase_sync_service.dart';
import 'package:wellnest/domain/models/clinician_pair_model.dart';
import 'package:wellnest/domain/models/shared_goal_model.dart';
import 'package:wellnest/domain/models/support_ticket_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ClinicianPairGrant Domain Model Tests', () {
    test('accurately calculates isExpired and remaining time', () {
      final activeGrant = ClinicianPairGrant(
        id: 'grant_1',
        pairCode: 'DOC-1234',
        patientUid: 'patient_alpha',
        patientLegalName: 'Sarah Connor',
        secretAnswer: 'Blue',
        expiresAt: DateTime.now().add(const Duration(hours: 4)),
        createdAt: DateTime.now(),
        permittedCategories: ['vitals', 'sleep'],
      );

      expect(activeGrant.isExpired, false);
      expect(activeGrant.remainingTime.inMinutes, greaterThan(200));

      final expiredGrant = ClinicianPairGrant(
        id: 'grant_2',
        pairCode: 'DOC-9999',
        patientUid: 'patient_beta',
        patientLegalName: 'John Doe',
        secretAnswer: 'Green',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        permittedCategories: ['vitals'],
      );

      expect(expiredGrant.isExpired, true);
      expect(expiredGrant.remainingTime, Duration.zero);
    });

    test('enforces strict category access permissions', () {
      final grant = ClinicianPairGrant(
        id: 'grant_3',
        pairCode: 'DOC-5678',
        patientUid: 'patient_gamma',
        patientLegalName: 'Alice Springs',
        secretAnswer: 'Indigo',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        permittedCategories: ['vitals', 'steps'],
      );

      expect(grant.canAccessSection('vitals'), true);
      expect(grant.canAccessSection('steps'), true);
      expect(grant.canAccessSection('sleep'), false);
      expect(grant.canAccessSection('reproductive_health'), false);
    });

    test('verifies security answers case-insensitively and trims whitespace', () {
      final grant = ClinicianPairGrant(
        id: 'grant_4',
        pairCode: 'DOC-4444',
        patientUid: 'patient_delta',
        patientLegalName: 'Alexander Hamilton',
        secretAnswer: 'Amber',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        createdAt: DateTime.now(),
      );

      expect(grant.verifySecurityAnswers('alexander hamilton', 'amber'), true);
      expect(grant.verifySecurityAnswers(' ALEXANDER HAMILTON ', ' AMBER '), true);
      expect(grant.verifySecurityAnswers('Alexander Hamilton', 'wrong_secret'), false);
      expect(grant.verifySecurityAnswers('Wrong Name', 'Amber'), false);
    });
  });

  group('FirebaseSyncService Clinician and Screenshot Tests', () {
    late FirebaseSyncService syncService;

    setUp(() {
      syncService = FirebaseSyncService();
    });

    test('creates new grant with unique pair code and security questions', () async {
      final grant = await syncService.createClinicianGrant(
        patientUid: 'patient_omega',
        patientLegalName: 'Doctor Who',
        secretAnswer: 'Tardis Blue',
        durationHours: 24,
        categories: ['vitals', 'sleep', 'steps'],
      );

      expect(grant.pairCode.startsWith('DOC-'), true);
      expect(grant.patientLegalName, 'Doctor Who');
      expect(grant.permittedCategories.length, 3);
      expect(grant.isExpired, false);
    });

    test('verifies doctor login with pair code and security questions', () async {
      final created = await syncService.createClinicianGrant(
        patientUid: 'patient_test',
        patientLegalName: 'Grace Hopper',
        secretAnswer: 'Navy Blue',
        durationHours: 12,
      );

      final verified = await syncService.verifyClinicianLogin(
        pairCode: created.pairCode,
        patientLegalName: 'grace hopper',
        secretAnswer: 'navy blue',
      );

      expect(verified, isNotNull);
      expect(verified?.id, created.id);

      final failed = await syncService.verifyClinicianLogin(
        pairCode: created.pairCode,
        patientLegalName: 'grace hopper',
        secretAnswer: 'red',
      );
      expect(failed, isNull);
    });

    test('logs screenshot audit and dispatches notification callback', () async {
      final grant = await syncService.createClinicianGrant(
        patientUid: 'patient_monitored',
        patientLegalName: 'Alan Turing',
        secretAnswer: 'Enigma',
        durationHours: 2,
      );

      ScreenshotAuditEntry? notifiedEntry;
      syncService.onScreenshotAlert = (entry) {
        notifiedEntry = entry;
      };

      final entry = await syncService.reportDoctorScreenshot(
        grantId: grant.id,
        capturedSection: 'Resting Heart Rate & HRV Graph',
      );

      expect(entry, isNotNull);
      expect(entry?.capturedSection, 'Resting Heart Rate & HRV Graph');
      expect(notifiedEntry?.grantId, grant.id);

      final updatedGrant = syncService.activeGrants.firstWhere((g) => g.id == grant.id);
      expect(updatedGrant.screenshotAudits.isNotEmpty, true);
    });
  });

  group('FirebaseSyncService Social Goals & Support Tests', () {
    late FirebaseSyncService syncService;

    setUp(() {
      syncService = FirebaseSyncService();
    });

    test('creates and tracks shared partner goals with nudges', () async {
      final goal = await syncService.createSharedGoal(
        title: '7-Day 10k Steps Challenge',
        targetValue: 70000,
        unit: 'steps',
        creatorUid: 'user_1',
        creatorName: 'Alex',
        partnerUid: 'user_2',
        partnerName: 'Jordan',
      );

      expect(goal.title, '7-Day 10k Steps Challenge');
      expect(goal.participants.length, 2);
      expect(goal.totalProgressPercent, 0.0);

      // Send nudge
      final nudge = await syncService.sendGoalNudge(
        goalId: goal.id,
        senderUid: 'user_1',
        senderName: 'Alex',
        targetUid: 'user_2',
        message: 'Let’s go for an evening walk! 🚶',
      );

      expect(nudge, isNotNull);
      expect(nudge?.message, contains('evening walk'));
    });

    test('creates support ticket and exchanges real-time messages', () async {
      final ticket = await syncService.createSupportTicket(
        userId: 'usr_premium_1',
        subject: 'Pair code expiry extension request',
        category: SupportCategory.security,
        initialMessage: 'Can I extend my doctor session while it is active?',
      );

      expect(ticket.subject, 'Pair code expiry extension request');
      expect(ticket.status, TicketStatus.open);
      expect(ticket.messages.length, 1);

      final repliedTicket = await syncService.addSupportMessage(
        ticketId: ticket.id,
        sender: MessageSender.support,
        senderName: 'Support Agent Marcus',
        content: 'Hi! You can create a new pass with a custom duration at any time.',
      );

      expect(repliedTicket?.messages.length, 2);
      expect(repliedTicket?.status, TicketStatus.inProgress);
    });
  });
}
