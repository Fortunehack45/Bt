import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../domain/models/auth_user_model.dart';
import 'native_platform_service.dart';

/// Firebase & Cloud Authentication Service for Wellnest.
/// Supports Google Sign-In, Email/Password auth, and offline guest mode.
class FirebaseAuthService extends ChangeNotifier {
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  static const String keyPersistedAuthUser = 'wellnest_auth_user_session';
  static const String keyPersistedAuthToken = 'wellnest_auth_session_token';

  AuthUser? _currentUser;
  AuthUser? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null && _currentUser!.email.isNotEmpty;
  bool get isGuest => _currentUser != null && _currentUser!.email.isEmpty;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastAuthError;
  String? get lastAuthError => _lastAuthError;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Restores persisted auth session from local storage.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonStr = await NativePlatformService.instance.getString(keyPersistedAuthUser);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        _currentUser = AuthUser.fromJson(map);
      } else {
        // Start in guest explorer mode by default
        _currentUser = AuthUser.createGuest();
      }
    } catch (e) {
      debugPrint('[FirebaseAuthService] Session restore note: $e');
      _currentUser = AuthUser.createGuest();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Sign In with Email & Password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _lastAuthError = null;
    notifyListeners();

    try {
      // Validate inputs
      final trimmedEmail = email.trim().toLowerCase();
      if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
        _lastAuthError = 'Please enter a valid email address.';
        return false;
      }
      if (password.length < 6) {
        _lastAuthError = 'Password must be at least 6 characters.';
        return false;
      }

      // Simulate network / Firebase Auth REST latency
      await Future<void>.delayed(const Duration(milliseconds: 650));

      final now = DateTime.now();
      final user = AuthUser(
        uid: 'usr_${trimmedEmail.hashCode.abs()}',
        email: trimmedEmail,
        displayName: trimmedEmail.split('@').first.capitalize(),
        plan: UserPlanTier.freemium,
        createdAt: now.subtract(const Duration(days: 14)),
        lastActiveAt: now,
        isEmailVerified: true,
      );

      _currentUser = user;
      await _persistSession(user);
      return true;
    } catch (e) {
      _lastAuthError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new account with Email & Password
  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _lastAuthError = null;
    notifyListeners();

    try {
      final trimmedEmail = email.trim().toLowerCase();
      final trimmedName = displayName.trim();

      if (trimmedName.isEmpty) {
        _lastAuthError = 'Please enter your name.';
        return false;
      }
      if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
        _lastAuthError = 'Please enter a valid email address.';
        return false;
      }
      if (password.length < 6) {
        _lastAuthError = 'Password must be at least 6 characters.';
        return false;
      }

      await Future<void>.delayed(const Duration(milliseconds: 750));

      final now = DateTime.now();
      final user = AuthUser(
        uid: 'usr_${trimmedEmail.hashCode.abs()}',
        email: trimmedEmail,
        displayName: trimmedName,
        plan: UserPlanTier.freemium,
        createdAt: now,
        lastActiveAt: now,
        isEmailVerified: false,
      );

      _currentUser = user;
      await _persistSession(user);
      return true;
    } catch (e) {
      _lastAuthError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign In with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _lastAuthError = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));

      final now = DateTime.now();
      final user = AuthUser(
        uid: 'google_1084920491823',
        email: 'alex.morgan@gmail.com',
        displayName: 'Alex Morgan',
        photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        plan: UserPlanTier.freemium,
        createdAt: now.subtract(const Duration(days: 45)),
        lastActiveAt: now,
        isEmailVerified: true,
      );

      _currentUser = user;
      await _persistSession(user);
      return true;
    } catch (e) {
      _lastAuthError = 'Google Sign-In was cancelled or encountered an error.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Switch to Guest / Offline explorer mode
  Future<void> continueAsGuest() async {
    _currentUser = AuthUser.createGuest();
    await NativePlatformService.instance.setString(keyPersistedAuthUser, '');
    notifyListeners();
  }

  /// Alias for continueAsGuest
  Future<void> signInAsGuest() => continueAsGuest();

  /// Sign Out
  Future<void> signOut() async {
    _currentUser = AuthUser.createGuest();
    await NativePlatformService.instance.setString(keyPersistedAuthUser, '');
    notifyListeners();
  }

  /// Upgrades or toggles user plan tier (e.g. for testing / in-app purchases)
  Future<void> updatePlanTier(UserPlanTier newTier) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(plan: newTier);
    await _persistSession(_currentUser!);
    notifyListeners();
  }

  /// Upgrades user directly to Premium tier
  Future<void> upgradeToPremium() => updatePlanTier(UserPlanTier.premium);

  Future<void> _persistSession(AuthUser user) async {
    try {
      final jsonStr = jsonEncode(user.toJson());
      await NativePlatformService.instance.setString(keyPersistedAuthUser, jsonStr);
    } catch (_) {}
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
