import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'native_platform_service.dart';

/// Configurable auto-lock delay options when app moves to background.
enum AutoLockTimeout {
  immediately(0, 'Immediately'),
  oneMinute(60, 'After 1 minute'),
  fiveMinutes(300, 'After 5 minutes'),
  fifteenMinutes(900, 'After 15 minutes');

  final int seconds;
  final String label;
  const AutoLockTimeout(this.seconds, this.label);

  static AutoLockTimeout fromSeconds(int seconds) {
    for (final val in AutoLockTimeout.values) {
      if (val.seconds == seconds) return val;
    }
    return AutoLockTimeout.immediately;
  }
}

/// Device hardware biometric status (Fingerprint / Face ID).
class BiometricStatus {
  final bool hasHardware;
  final bool isEnrolled;
  final bool isAvailable;

  const BiometricStatus({
    required this.hasHardware,
    required this.isEnrolled,
    required this.isAvailable,
  });

  const BiometricStatus.unavailable()
      : hasHardware = false,
        isEnrolled = false,
        isAvailable = false;
}

/// 100% Local App Lock & Biometric Security Service.
/// - PIN and biometric settings are stored locally on device only (zero cloud leaks).
/// - PIN is salted and hashed with standard SHA-256 before local persistence.
/// - Communicates with native Android BiometricPrompt via platform channel.
class AppLockService extends ChangeNotifier {
  AppLockService._();
  static final AppLockService instance = AppLockService._();

  static const MethodChannel _biometricsChannel =
      MethodChannel('com.wellnest.vitality.health/biometrics');

  static const String keyAppLockEnabled = 'wellnest_app_lock_enabled';
  static const String keyPinHash = 'wellnest_app_lock_pin_hash';
  static const String keyPinSalt = 'wellnest_app_lock_pin_salt';
  static const String keyBiometricsEnabled = 'wellnest_app_lock_biometrics_enabled';
  static const String keyTimeoutSeconds = 'wellnest_app_lock_timeout_seconds';

  bool _isLockEnabled = false;
  bool get isLockEnabled => _isLockEnabled;

  bool _isBiometricsEnabled = false;
  bool get isBiometricsEnabled => _isBiometricsEnabled;

  AutoLockTimeout _timeout = AutoLockTimeout.immediately;
  AutoLockTimeout get timeout => _timeout;

  String? _storedHash;
  String? _storedSalt;

  bool get hasPinSet => _storedHash != null && _storedHash!.isNotEmpty;

  bool _isLocked = false;
  bool get isLocked => _isLocked;

  DateTime? _lastPausedTime;

  BiometricStatus _biometricStatus = const BiometricStatus.unavailable();
  BiometricStatus get biometricStatus => _biometricStatus;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Loads locally stored security settings from native storage.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = NativePlatformService.instance;
      _isLockEnabled = await prefs.getBool(keyAppLockEnabled, defaultValue: false);
      _storedHash = await prefs.getString(keyPinHash);
      _storedSalt = await prefs.getString(keyPinSalt);
      _isBiometricsEnabled = await prefs.getBool(keyBiometricsEnabled, defaultValue: false);
      final timeoutSec = await prefs.getInt(keyTimeoutSeconds, defaultValue: 0);
      _timeout = AutoLockTimeout.fromSeconds(timeoutSec);

      // Check native biometric hardware status
      _biometricStatus = await checkBiometricHardware();

      // If lock is enabled and a PIN exists, app starts locked
      if (_isLockEnabled && hasPinSet) {
        _isLocked = true;
      }
    } catch (e) {
      debugPrint('[AppLockService] Local initialization note: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Checks if the physical device has fingerprint / biometric hardware and enrolled credentials.
  Future<BiometricStatus> checkBiometricHardware() async {
    try {
      final res = await _biometricsChannel.invokeMapMethod<String, dynamic>('isBiometricsAvailable');
      if (res != null) {
        return BiometricStatus(
          hasHardware: res['hasHardware'] as bool? ?? false,
          isEnrolled: res['isEnrolled'] as bool? ?? false,
          isAvailable: res['available'] as bool? ?? false,
        );
      }
    } catch (_) {}
    return const BiometricStatus.unavailable();
  }

  /// Sets up a new 6-digit PIN. Salting and hashing are performed locally.
  Future<bool> setPin(String pin) async {
    if (pin.length != 6) return false;

    final salt = _generateSalt();
    final hash = _sha256Hash('$salt$pin');

    _storedSalt = salt;
    _storedHash = hash;
    _isLockEnabled = true;

    final prefs = NativePlatformService.instance;
    await prefs.setString(keyPinSalt, salt);
    await prefs.setString(keyPinHash, hash);
    await prefs.setBool(keyAppLockEnabled, true);

    notifyListeners();
    return true;
  }

  /// Verifies entered PIN against the local salted hash.
  bool verifyPin(String pin) {
    if (_storedHash == null || _storedSalt == null) return false;
    final inputHash = _sha256Hash('$_storedSalt$pin');
    final isValid = inputHash == _storedHash;
    if (isValid) {
      unlock();
    }
    return isValid;
  }

  /// Clears PIN and disables App Lock locally.
  Future<void> removePin() async {
    _storedHash = null;
    _storedSalt = null;
    _isLockEnabled = false;
    _isBiometricsEnabled = false;
    _isLocked = false;

    final prefs = NativePlatformService.instance;
    await prefs.setString(keyPinHash, '');
    await prefs.setString(keyPinSalt, '');
    await prefs.setBool(keyAppLockEnabled, false);
    await prefs.setBool(keyBiometricsEnabled, false);

    notifyListeners();
  }

  /// Toggles App Lock state. If turning ON and no PIN is set, returns false.
  Future<bool> setLockEnabled(bool enabled) async {
    if (enabled && !hasPinSet) return false;
    _isLockEnabled = enabled;
    await NativePlatformService.instance.setBool(keyAppLockEnabled, enabled);
    notifyListeners();
    return true;
  }

  /// Toggles biometric unlock preference (stored locally).
  Future<void> setBiometricsEnabled(bool enabled) async {
    _isBiometricsEnabled = enabled;
    await NativePlatformService.instance.setBool(keyBiometricsEnabled, enabled);
    notifyListeners();
  }

  /// Updates auto-lock timeout duration (stored locally).
  Future<void> setAutoLockTimeout(AutoLockTimeout timeout) async {
    _timeout = timeout;
    await NativePlatformService.instance.setInt(keyTimeoutSeconds, timeout.seconds);
    notifyListeners();
  }

  /// Immediately locks the app.
  void lock() {
    if (_isLockEnabled && hasPinSet) {
      _isLocked = true;
      notifyListeners();
    }
  }

  /// Unlocks the app.
  void unlock() {
    _isLocked = false;
    _lastPausedTime = null;
    notifyListeners();
  }

  /// Authenticates using the physical phone's biometric sensor (Fingerprint / Face ID).
  Future<bool> authenticateWithBiometrics({
    String title = 'Unlock Wellnest',
    String subtitle = 'Confirm your identity with biometric security',
  }) async {
    if (!_isBiometricsEnabled) return false;

    try {
      final res = await _biometricsChannel.invokeMapMethod<String, dynamic>('authenticate', {
        'title': title,
        'subtitle': subtitle,
        'negativeButton': 'Use 6-Digit PIN',
      });

      if (res != null && res['success'] == true) {
        unlock();
        return true;
      }
    } catch (_) {}

    return false;
  }

  /// Cancels any active biometric prompt.
  void cancelBiometrics() {
    try {
      _biometricsChannel.invokeMethod<bool>('cancelAuthentication');
    } catch (_) {}
  }

  /// Lifecycle callback when the app moves into background / pauses.
  void onAppPaused() {
    if (_isLockEnabled && hasPinSet) {
      _lastPausedTime = DateTime.now();
    }
  }

  /// Lifecycle callback when the app resumes into foreground.
  bool onAppResumed() {
    if (!_isLockEnabled || !hasPinSet || _isLocked) return false;

    if (_lastPausedTime == null) {
      // First resume or immediate lock
      if (_timeout == AutoLockTimeout.immediately) {
        lock();
        return true;
      }
      return false;
    }

    final diffSeconds = DateTime.now().difference(_lastPausedTime!).inSeconds;
    if (diffSeconds >= _timeout.seconds) {
      lock();
      return true;
    }

    return false;
  }

  // -------------------------------------------------------------
  // Cryptographic Helper Functions (Pure Dart SHA-256 & Salt)
  // -------------------------------------------------------------

  String _generateSalt() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Pure Dart standard SHA-256 implementation.
  /// Generates a 64-character lowercase hex digest.
  String _sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = _sha256(bytes);
    return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  List<int> _sha256(List<int> message) {
    // Standard SHA-256 Constants
    const k = <int>[
      0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
      0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
      0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
      0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
      0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
      0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
      0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
      0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    ];

    int h0 = 0x6a09e667;
    int h1 = 0xbb67ae85;
    int h2 = 0x3c6ef372;
    int h3 = 0xa54ff53a;
    int h4 = 0x510e527f;
    int h5 = 0x9b05688c;
    int h6 = 0x1f83d9ab;
    int h7 = 0x5be0cd19;

    final bitLength = message.length * 8;
    final withOne = List<int>.from(message)..add(0x80);

    while ((withOne.length + 8) % 64 != 0) {
      withOne.add(0x00);
    }

    final lenBytes = Uint8List(8);
    ByteData.view(lenBytes.buffer).setUint64(0, bitLength, Endian.big);
    withOne.addAll(lenBytes);

    final w = List<int>.filled(64, 0);

    for (int i = 0; i < withOne.length; i += 64) {
      for (int t = 0; t < 16; t++) {
        final offset = i + (t * 4);
        w[t] = (withOne[offset] << 24) |
            (withOne[offset + 1] << 16) |
            (withOne[offset + 2] << 8) |
            withOne[offset + 3];
      }

      for (int t = 16; t < 64; t++) {
        final s0 = _rotr(w[t - 15], 7) ^ _rotr(w[t - 15], 18) ^ (w[t - 15] >>> 3);
        final s1 = _rotr(w[t - 2], 17) ^ _rotr(w[t - 2], 19) ^ (w[t - 2] >>> 10);
        w[t] = (w[t - 16] + s0 + w[t - 7] + s1) & 0xFFFFFFFF;
      }

      int a = h0;
      int b = h1;
      int c = h2;
      int d = h3;
      int e = h4;
      int f = h5;
      int g = h6;
      int h = h7;

      for (int t = 0; t < 64; t++) {
        final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        final ch = (e & f) ^ (~e & g);
        final temp1 = (h + s1 + ch + k[t] + w[t]) & 0xFFFFFFFF;
        final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = (s0 + maj) & 0xFFFFFFFF;

        h = g;
        g = f;
        f = e;
        e = (d + temp1) & 0xFFFFFFFF;
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & 0xFFFFFFFF;
      }

      h0 = (h0 + a) & 0xFFFFFFFF;
      h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF;
      h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF;
      h5 = (h5 + f) & 0xFFFFFFFF;
      h6 = (h6 + g) & 0xFFFFFFFF;
      h7 = (h7 + h) & 0xFFFFFFFF;
    }

    final out = Uint8List(32);
    final bd = ByteData.view(out.buffer);
    bd.setUint32(0, h0, Endian.big);
    bd.setUint32(4, h1, Endian.big);
    bd.setUint32(8, h2, Endian.big);
    bd.setUint32(12, h3, Endian.big);
    bd.setUint32(16, h4, Endian.big);
    bd.setUint32(20, h5, Endian.big);
    bd.setUint32(24, h6, Endian.big);
    bd.setUint32(28, h7, Endian.big);

    return out;
  }

  int _rotr(int x, int n) => ((x >>> n) | (x << (32 - n))) & 0xFFFFFFFF;
}
