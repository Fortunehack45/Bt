import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Production service bridging Flutter to native Android & iOS capabilities:
/// - Real heads-up system status-bar notifications
class NativePlatformService {
  NativePlatformService._() {
    _browserChannel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final uri = call.arguments as String?;
        if (uri != null && uri.isNotEmpty) {
          for (final listener in List.of(_deepLinkListeners)) {
            listener(uri);
          }
        }
      }
    });
  }
  static final NativePlatformService instance = NativePlatformService._();

  static const MethodChannel _notificationChannel = MethodChannel('com.wellnest.vitality.health/notifications');
  static const MethodChannel _preferencesChannel = MethodChannel('com.wellnest.vitality.health/preferences');
  static const MethodChannel _browserChannel = MethodChannel('com.wellnest.vitality.health/browser');

  final List<void Function(String uri)> _deepLinkListeners = [];

  void addDeepLinkListener(void Function(String uri) listener) {
    _deepLinkListeners.add(listener);
  }

  void removeDeepLinkListener(void Function(String uri) listener) {
    _deepLinkListeners.remove(listener);
  }

  /// Triggers the device's native browser (Chrome on Android, Safari on iOS)
  Future<bool> openUrlInBrowser(String url) async {
    try {
      final res = await _browserChannel.invokeMethod<bool>('openUrl', {'url': url});
      return res ?? false;
    } catch (e) {
      debugPrint('[NativePlatformService] openUrlInBrowser note: $e');
      return false;
    }
  }

  /// Checks if the app was launched by a deep link from the phone browser
  Future<String?> getInitialDeepLinkUri() async {
    try {
      return await _browserChannel.invokeMethod<String>('getInitialUri');
    } catch (_) {
      return null;
    }
  }

  // In-memory fallback map for test environments & web
  final Map<String, dynamic> _fallbackPrefs = {};

  // Persistent Keys
  static const String keyOnboardingComplete = 'wellnest_onboarding_completed';
  static const String keyUserProfileName = 'wellnest_user_profile_name';
  static const String keySpotlightTourSeen = 'wellnest_spotlight_tour_seen';
  static const String keyThemeMode = 'wellnest_theme_mode';
  static const String keyProfileData = 'wellnest_profile_data';
  static const String keyVitalsData = 'wellnest_vitals_data';
  static const String keyHabitsData = 'wellnest_habits_data';
  static const String keyMealsData = 'wellnest_meals_data';
  static const String keyPersistentSteps = 'wellnest_persistent_steps';

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

  /// Retrieves a string from persistent storage.
  Future<String?> getString(String key, {String? defaultValue}) async {
    try {
      final res = await _preferencesChannel.invokeMethod<String>('getString', {
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
    return _fallbackPrefs[key] as String? ?? defaultValue;
  }

  /// Persists a string value to native storage.
  Future<void> setString(String key, String value) async {
    _fallbackPrefs[key] = value;
    try {
      await _preferencesChannel.invokeMethod<bool>('setString', {
        'key': key,
        'value': value,
      });
    } catch (_) {
      // Ignored for non-native test environments
    }
  }

  /// Retrieves an integer from persistent storage.
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    try {
      final res = await _preferencesChannel.invokeMethod<int>('getInt', {
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
    return _fallbackPrefs[key] as int? ?? defaultValue;
  }

  /// Persists an integer value to native storage.
  Future<void> setInt(String key, int value) async {
    _fallbackPrefs[key] = value;
    try {
      await _preferencesChannel.invokeMethod<bool>('setInt', {
        'key': key,
        'value': value,
      });
    } catch (_) {
      // Ignored for non-native test environments
    }
  }

  /// Retrieves a double from persistent storage.
  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    try {
      final res = await _preferencesChannel.invokeMethod<double>('getDouble', {
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
    return _fallbackPrefs[key] as double? ?? defaultValue;
  }

  /// Persists a double value to native storage.
  Future<void> setDouble(String key, double value) async {
    _fallbackPrefs[key] = value;
    try {
      await _preferencesChannel.invokeMethod<bool>('setDouble', {
        'key': key,
        'value': value,
      });
    } catch (_) {
      // Ignored for non-native test environments
    }
  }

  /// Removes a key from persistent storage.
  Future<void> remove(String key) async {
    _fallbackPrefs.remove(key);
    try {
      await _preferencesChannel.invokeMethod<bool>('remove', {
        'key': key,
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

  /// Checks if the spotlight tour has been seen.
  Future<bool> hasSeenSpotlightTour() async {
    return getBool(keySpotlightTourSeen, defaultValue: false);
  }

  /// Records spotlight tour as completed permanently.
  Future<void> setSpotlightTourSeen(bool seen) async {
    await setBool(keySpotlightTourSeen, seen);
  }
}
