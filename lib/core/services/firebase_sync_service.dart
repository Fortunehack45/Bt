import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/models/auth_user_model.dart';
import '../../domain/models/clinician_pair_model.dart';
import '../../domain/models/shared_goal_model.dart';
import '../../domain/models/support_ticket_model.dart';
import 'firebase_auth_service.dart';
import 'native_platform_service.dart';

/// Central Cloud Synchronizer & Ecosystem Service for Wellnest.
/// Manages Clinician Pair-Code access, Screenshot Audit alerts, Support Inquiries,
/// and Partner Shared Goals.
class FirebaseSyncService extends ChangeNotifier {
  FirebaseSyncService._();
  static final FirebaseSyncService instance = FirebaseSyncService._();

  static const MethodChannel _biometricsChannel =
      MethodChannel('com.wellnest.vitality.health/biometrics');

  static const String keyClinicianGrants = 'wellnest_clinician_pair_grants';
  static const String keySupportTickets = 'wellnest_support_tickets_cache';
  static const String keySharedGoals = 'wellnest_shared_goals_cache';

  // State Collections
  final List<ClinicianPairGrant> _pairGrants = [];
  List<ClinicianPairGrant> get pairGrants => List.unmodifiable(_pairGrants);

  final List<SupportTicket> _tickets = [];
  List<SupportTicket> get tickets => List.unmodifiable(_tickets);

  final List<SharedGoal> _sharedGoals = [];
  List<SharedGoal> get sharedGoals => List.unmodifiable(_sharedGoals);

  // Active Clinician Session (when app is in Doctor Examination Mode)
  ClinicianPairGrant? _activeClinicianSession;
  ClinicianPairGrant? get activeClinicianSession => _activeClinicianSession;
  bool get isClinicianSessionActive => _activeClinicianSession != null && !_activeClinicianSession!.isExpired;

  // Real-time security callback for screenshot alerts
  Function(ScreenshotAuditEntry entry)? onScreenshotAlert;

  bool _isInitialized = false;

  /// Loads persisted cloud state and seeds default demo records if empty.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadPairGrants();
      await _loadSupportTickets();
      await _loadSharedGoals();

      // Listen for hardware screenshot events from native Android
      _biometricsChannel.setMethodCallHandler((call) async {
        if (call.method == 'onScreenshotDetected') {
          if (_activeClinicianSession != null) {
            await reportScreenshotCaptured('Clinical Telemetry Screen');
          }
        }
      });
    } catch (e) {
      debugPrint('[FirebaseSyncService] Init note: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // 1. Clinician / Doctor Pair-Code Sharing & Screenshot Detection
  // -------------------------------------------------------------

  /// Generates a new 6-character Clinician Pair Code for patient.
  Future<ClinicianPairGrant> createClinicianPairGrant({
    required String patientName,
    required String securityQuestion1,
    required String securityAnswer1,
    required String securityQuestion2,
    required String securityAnswer2,
    required List<String> permittedSections,
    required Duration duration,
  }) async {
    final user = FirebaseAuthService.instance.currentUser;
    final patientId = user?.uid ?? 'patient_local';
    final code = _generateRandomPairCode();

    final now = DateTime.now();
    final grant = ClinicianPairGrant(
      pairCode: code,
      patientId: patientId,
      patientDisplayName: patientName.isNotEmpty ? patientName : (user?.displayName ?? 'Patient'),
      securityQuestion1: securityQuestion1,
      securityAnswer1: securityAnswer1,
      securityQuestion2: securityQuestion2,
      securityAnswer2: securityAnswer2,
      permittedSections: permittedSections,
      createdAt: now,
      expiresAt: now.add(duration),
      isActive: true,
      screenshotAuditLog: [],
    );

    _pairGrants.insert(0, grant);
    await _persistPairGrants();
    notifyListeners();
    return grant;
  }

  /// Verifies Doctor login with Pair Code + 2 Security Answers.
  Future<ClinicianPairGrant?> verifyClinicianAccess({
    required String pairCode,
    required String ans1,
    required String ans2,
  }) async {
    final cleanCode = pairCode.trim().toUpperCase();
    for (final grant in _pairGrants) {
      if (grant.pairCode.toUpperCase() == cleanCode) {
        if (grant.isExpired || !grant.isActive) {
          return null;
        }
        if (grant.verifyAnswers(ans1, ans2)) {
          _activeClinicianSession = grant;
          notifyListeners();
          return grant;
        }
      }
    }
    return null;
  }

  /// Records that a screenshot was taken during an examiner session,
  /// attaches it to the audit log, and notifies the patient immediately!
  Future<void> reportScreenshotCaptured(String sectionName) async {
    if (_activeClinicianSession == null) return;

    final entry = ScreenshotAuditEntry(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      examinerCode: _activeClinicianSession!.pairCode,
      sectionName: sectionName,
      timestamp: DateTime.now(),
    );

    final idx = _pairGrants.indexWhere((g) => g.pairCode == _activeClinicianSession!.pairCode);
    if (idx != -1) {
      final updatedList = List<ScreenshotAuditEntry>.from(_pairGrants[idx].screenshotAuditLog)..insert(0, entry);
      _pairGrants[idx] = _pairGrants[idx].copyWith(screenshotAuditLog: updatedList);
      _activeClinicianSession = _pairGrants[idx];
      await _persistPairGrants();
      notifyListeners();
    }

    // Trigger instant real-time callback to alert patient UI
    onScreenshotAlert?.call(entry);
  }

  /// Revokes an active pairing grant manually.
  Future<void> revokePairGrant(String pairCode) async {
    final idx = _pairGrants.indexWhere((g) => g.pairCode == pairCode);
    if (idx != -1) {
      _pairGrants[idx] = _pairGrants[idx].copyWith(isActive: false);
      if (_activeClinicianSession?.pairCode == pairCode) {
        _activeClinicianSession = null;
      }
      await _persistPairGrants();
      notifyListeners();
    }
  }

  /// Exits examiner view mode.
  void exitClinicianSession() {
    _activeClinicianSession = null;
    notifyListeners();
  }

  String _generateRandomPairCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    final buffer = StringBuffer('DOC-');
    for (int i = 0; i < 4; i++) {
      buffer.write(chars[rand.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  // -------------------------------------------------------------
  // 2. Customer Support & Live Inquiries
  // -------------------------------------------------------------

  /// Creates a new support inquiry ticket from the mobile app.
  Future<SupportTicket> createSupportTicket({
    required String subject,
    required String category,
    required String initialMessage,
  }) async {
    final user = FirebaseAuthService.instance.currentUser;
    final userId = user?.uid ?? 'usr_local';
    final userPlan = user?.plan ?? UserPlanTier.freemium;

    final now = DateTime.now();
    final ticketId = 'TCK-${now.millisecondsSinceEpoch.toString().substring(7)}';

    final firstMsg = SupportMessage(
      id: 'msg_1',
      senderRole: 'user',
      senderName: user?.displayName ?? 'User',
      content: initialMessage,
      timestamp: now,
    );

    final ticket = SupportTicket(
      ticketId: ticketId,
      userId: userId,
      userPlan: userPlan,
      subject: subject,
      category: category,
      status: 'open',
      createdAt: now,
      updatedAt: now,
      messages: [firstMsg],
    );

    _tickets.insert(0, ticket);
    await _persistSupportTickets();
    notifyListeners();
    return ticket;
  }

  /// Sends a message in an existing support inquiry (from user or support agent).
  Future<void> sendTicketMessage({
    required String ticketId,
    required String content,
    bool isSupport = false,
  }) async {
    final idx = _tickets.indexWhere((t) => t.ticketId == ticketId);
    if (idx == -1) return;

    final user = FirebaseAuthService.instance.currentUser;
    final now = DateTime.now();
    final msg = SupportMessage(
      id: 'msg_${now.millisecondsSinceEpoch}',
      senderRole: isSupport ? 'support' : 'user',
      senderName: isSupport ? 'Wellnest Care Team' : (user?.displayName ?? 'User'),
      content: content,
      timestamp: now,
    );

    final currentTicket = _tickets[idx];
    final updatedMsgs = List<SupportMessage>.from(currentTicket.messages)..add(msg);
    _tickets[idx] = currentTicket.copyWith(
      messages: updatedMsgs,
      updatedAt: now,
      status: isSupport ? 'in_progress' : currentTicket.status,
    );

    await _persistSupportTickets();
    notifyListeners();
  }

  // -------------------------------------------------------------
  // 3. Collaborative Partner Shared Goals
  // -------------------------------------------------------------

  /// Creates a new collaborative challenge between friends/partners.
  Future<SharedGoal> createSharedGoal({
    required String title,
    required String metricType,
    required double targetValue,
    required String unit,
    int durationDays = 7,
  }) async {
    final user = FirebaseAuthService.instance.currentUser;
    final userId = user?.uid ?? 'usr_local';
    final userName = user?.displayName ?? 'You';

    final now = DateTime.now();
    final goalId = 'GOAL-${_generateShortCode()}';

    final participants = <String, GoalParticipant>{
      userId: GoalParticipant(
        userId: userId,
        displayName: userName,
        currentProgress: 0.0,
        lastUpdated: now,
      ),
    };

    final goal = SharedGoal(
      goalId: goalId,
      title: title,
      metricType: metricType,
      targetValue: targetValue,
      unit: unit,
      creatorId: userId,
      participants: participants,
      startDate: now,
      endDate: now.add(Duration(days: durationDays)),
      reminders: [],
    );

    _sharedGoals.insert(0, goal);
    await _persistSharedGoals();
    notifyListeners();
    return goal;
  }

  /// Joins an existing shared goal by ID / Invite Code.
  Future<bool> joinSharedGoal(String goalId) async {
    final idx = _sharedGoals.indexWhere((g) => g.goalId.toUpperCase() == goalId.trim().toUpperCase());
    if (idx == -1) return false;

    final user = FirebaseAuthService.instance.currentUser;
    final userId = user?.uid ?? 'usr_partner';
    final userName = user?.displayName ?? 'Partner';

    final goal = _sharedGoals[idx];
    if (goal.participants.containsKey(userId)) return true;

    final updatedParticipants = Map<String, GoalParticipant>.from(goal.participants);
    updatedParticipants[userId] = GoalParticipant(
      userId: userId,
      displayName: userName,
      currentProgress: 0.0,
      lastUpdated: DateTime.now(),
    );

    _sharedGoals[idx] = goal.copyWith(participants: updatedParticipants);
    await _persistSharedGoals();
    notifyListeners();
    return true;
  }

  /// Updates current user's progress on a collaborative goal.
  Future<void> updateGoalProgress(String goalId, double progress) async {
    final idx = _sharedGoals.indexWhere((g) => g.goalId == goalId);
    if (idx == -1) return;

    final user = FirebaseAuthService.instance.currentUser;
    final userId = user?.uid ?? 'usr_local';

    final goal = _sharedGoals[idx];
    final participant = goal.participants[userId];
    if (participant == null) return;

    final updatedParticipants = Map<String, GoalParticipant>.from(goal.participants);
    updatedParticipants[userId] = GoalParticipant(
      userId: userId,
      displayName: participant.displayName,
      currentProgress: progress,
      lastUpdated: DateTime.now(),
    );

    _sharedGoals[idx] = goal.copyWith(participants: updatedParticipants);
    await _persistSharedGoals();
    notifyListeners();
  }

  /// Sends a mutual reminder / cheer nudge to partners in a goal.
  Future<void> sendGoalReminder(String goalId, String message) async {
    final idx = _sharedGoals.indexWhere((g) => g.goalId == goalId);
    if (idx == -1) return;

    final user = FirebaseAuthService.instance.currentUser;
    final userId = user?.uid ?? 'usr_local';
    final userName = user?.displayName ?? 'Partner';

    final nudge = GoalReminderNudge(
      id: 'nudge_${DateTime.now().millisecondsSinceEpoch}',
      senderId: userId,
      senderName: userName,
      message: message,
      timestamp: DateTime.now(),
    );

    final goal = _sharedGoals[idx];
    final updatedReminders = List<GoalReminderNudge>.from(goal.reminders)..insert(0, nudge);
    _sharedGoals[idx] = goal.copyWith(reminders: updatedReminders);

    await _persistSharedGoals();
    notifyListeners();
  }

  String _generateShortCode() {
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final rand = Random.secure();
    final buffer = StringBuffer();
    for (int i = 0; i < 4; i++) {
      buffer.write(chars[rand.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  // -------------------------------------------------------------
  // 4. Persistence Helpers & Seeders
  // -------------------------------------------------------------

  Future<void> _loadPairGrants() async {
    final jsonStr = await NativePlatformService.instance.getString(keyClinicianGrants);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _pairGrants.clear();
      _pairGrants.addAll(list.map((e) => ClinicianPairGrant.fromJson(e as Map<String, dynamic>)));
    }
  }

  Future<void> _persistPairGrants() async {
    try {
      final jsonStr = jsonEncode(_pairGrants.map((e) => e.toJson()).toList());
      await NativePlatformService.instance.setString(keyClinicianGrants, jsonStr);
    } catch (_) {}
  }

  Future<void> _loadSupportTickets() async {
    final jsonStr = await NativePlatformService.instance.getString(keySupportTickets);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _tickets.clear();
      _tickets.addAll(list.map((e) => SupportTicket.fromJson(e as Map<String, dynamic>)));
    } else {
      // Seed default welcome ticket
      final now = DateTime.now();
      _tickets.add(
        SupportTicket(
          ticketId: 'TCK-10492',
          userId: 'usr_welcome',
          userPlan: UserPlanTier.freemium,
          subject: 'Welcome to Wellnest Care & Telemetry Sync',
          category: 'General',
          status: 'resolved',
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 2)),
          messages: [
            SupportMessage(
              id: 'm1',
              senderRole: 'user',
              senderName: 'Explorer',
              content: 'How do I synchronize my Bluetooth smart ring and monitor heart rate variability?',
              timestamp: now.subtract(const Duration(days: 3)),
            ),
            SupportMessage(
              id: 'm2',
              senderRole: 'support',
              senderName: 'Wellnest Care Team',
              content: 'Hello! You can tap the Smart Ring icon in your Devices Hub to initiate live BLE scanning. All vital telemetry syncs in real-time.',
              timestamp: now.subtract(const Duration(days: 2)),
            ),
          ],
        ),
      );
      await _persistSupportTickets();
    }
  }

  Future<void> _persistSupportTickets() async {
    try {
      final jsonStr = jsonEncode(_tickets.map((e) => e.toJson()).toList());
      await NativePlatformService.instance.setString(keySupportTickets, jsonStr);
    } catch (_) {}
  }

  Future<void> _loadSharedGoals() async {
    final jsonStr = await NativePlatformService.instance.getString(keySharedGoals);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _sharedGoals.clear();
      _sharedGoals.addAll(list.map((e) => SharedGoal.fromJson(e as Map<String, dynamic>)));
    } else {
      // Seed starter challenge
      final now = DateTime.now();
      _sharedGoals.add(
        SharedGoal(
          goalId: 'GOAL-STEP8',
          title: 'Daily 10,000 Steps Sprint',
          metricType: 'steps',
          targetValue: 10000,
          unit: 'steps',
          creatorId: 'usr_alex',
          participants: {
            'usr_alex': GoalParticipant(
              userId: 'usr_alex',
              displayName: 'Alex',
              currentProgress: 7420,
              lastUpdated: now,
            ),
            'usr_jordan': GoalParticipant(
              userId: 'usr_jordan',
              displayName: 'Jordan',
              currentProgress: 8910,
              lastUpdated: now,
            ),
          },
          startDate: now.subtract(const Duration(days: 2)),
          endDate: now.add(const Duration(days: 5)),
          reminders: [
            GoalReminderNudge(
              id: 'n1',
              senderId: 'usr_jordan',
              senderName: 'Jordan',
              message: 'Halfway there! Let\'s crush the 10k mark before dinner!',
              timestamp: now.subtract(const Duration(hours: 3)),
            ),
          ],
        ),
      );
      await _persistSharedGoals();
    }
  }

  Future<void> _persistSharedGoals() async {
    try {
      final jsonStr = jsonEncode(_sharedGoals.map((e) => e.toJson()).toList());
      await NativePlatformService.instance.setString(keySharedGoals, jsonStr);
    } catch (_) {}
  }
}
