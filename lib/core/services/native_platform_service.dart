import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Production service bridging Flutter to native Android & iOS capabilities:
/// - Real heads-up system status-bar notifications
/// - Persistent local key-value store (SharedPreferences / UserDefaults)
class NativePlatformService {
  NativePlatformService._();
  static final NativePlatformService instance = NativePlatformService._();

  static const MethodChannel _notificationChannel = MethodChannel('com.biothrix.app/notifications');
  static const MethodChannel _preferencesChannel = MethodChannel('com.biothrix.app/preferences');

  // In-memory fallback map for test environments & web
  final Map<String, dynamic> _fallbackPrefs = {};

  // Keys
  static const String keyOnboardingComplete = 'wellnest_onboarding_completed';
  static const String keyUserProfileName = 'wellnest_user_profile_name';

  /// Displays an authentic system-level status-bar notification on Android & iOS.
  Future<bool> showSystemNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    try {
      final notificationId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final result = await _notificationChannel.invokeMethod<bool>('showNotification', {
        'id': notificationId,
        'title': title,
        'body': body,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('[NativePlatformService] System notification exception (handled): $e');
      return false;
    }
  }

  /// Retrieves a boolean from persistent storage.
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      final res = await _preferencesChannel.invokeMethod<bool>('getBool', {
        'key': key,
        'defaultValue': defaultValue,
      });
      if (res != null) {
        _fallbackPrefs[key] = res;
        return res;
      }
    } catch (_) {
      // In-memory fallback
    }
    return _fallbackPrefs[key] as bool? ?? defaultValue;
  }

  /// Persists a boolean value to native storage.
  Future<void> setBool(String key, bool value) async {
    _fallbackPrefs[key] = value;
    try {
      await _preferencesChannel.invokeMethod<bool>('setBool', {
        'key': key,
        'value': value,
      });
    } catch (_) {
      // Ignored for non-native test environments
    }
  }

  /// Checks if the user has previously completed onboarding.
  Future<bool> isOnboardingCompleted() async {
    return getBool(keyOnboardingComplete, defaultValue: false);
  }

  /// Flags onboarding as completed permanently across cold starts.
  Future<void> setOnboardingCompleted(bool completed) async {
    await setBool(keyOnboardingComplete, completed);
  }
}
