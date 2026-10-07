import 'package:flutter_test/flutter_test.dart';
import 'package:wellnest/core/services/app_lock_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLockService Local Security Verification', () {
    final service = AppLockService.instance;

    setUp(() async {
      await service.removePin();
    });

    test('Initial state has no PIN and app is unlocked', () {
      expect(service.hasPinSet, isFalse);
      expect(service.isLockEnabled, isFalse);
      expect(service.isLocked, isFalse);
      expect(service.isBiometricsEnabled, isFalse);
    });

    test('Reject PINs that are not exactly 6 digits', () async {
      expect(await service.setPin('12345'), isFalse);
      expect(await service.setPin('1234567'), isFalse);
      expect(await service.setPin(''), isFalse);
      expect(service.hasPinSet, isFalse);
    });

    test('Setting valid 6-digit PIN enables lock and hashes locally', () async {
      final success = await service.setPin('654321');
      expect(success, isTrue);
      expect(service.hasPinSet, isTrue);
      expect(service.isLockEnabled, isTrue);
    });

    test('PIN verification correctly validates match and unlocks', () async {
      await service.setPin('987654');
      service.lock();
      expect(service.isLocked, isTrue);

      // Wrong PIN fails and remains locked
      expect(service.verifyPin('111111'), isFalse);
      expect(service.verifyPin('987653'), isFalse);
      expect(service.isLocked, isTrue);

      // Correct PIN succeeds and unlocks
      expect(service.verifyPin('987654'), isTrue);
      expect(service.isLocked, isFalse);
    });

    test('Biometric setting can be toggled locally', () async {
      await service.setPin('123456');
      expect(service.isBiometricsEnabled, isFalse);

      await service.setBiometricsEnabled(true);
      expect(service.isBiometricsEnabled, isTrue);

      await service.setBiometricsEnabled(false);
      expect(service.isBiometricsEnabled, isFalse);
    });

    test('Auto-lock timeout options configure correctly', () async {
      expect(service.timeout, AutoLockTimeout.immediately);

      await service.setAutoLockTimeout(AutoLockTimeout.oneMinute);
      expect(service.timeout, AutoLockTimeout.oneMinute);
      expect(service.timeout.seconds, 60);

      await service.setAutoLockTimeout(AutoLockTimeout.fiveMinutes);
      expect(service.timeout, AutoLockTimeout.fiveMinutes);
      expect(service.timeout.seconds, 300);

      await service.setAutoLockTimeout(AutoLockTimeout.fifteenMinutes);
      expect(service.timeout, AutoLockTimeout.fifteenMinutes);
      expect(service.timeout.seconds, 900);
    });

    test('Removing PIN resets all security states cleanly', () async {
      await service.setPin('123456');
      await service.setBiometricsEnabled(true);
      service.lock();

      await service.removePin();
      expect(service.hasPinSet, isFalse);
      expect(service.isLockEnabled, isFalse);
      expect(service.isBiometricsEnabled, isFalse);
      expect(service.isLocked, isFalse);
    });

    test('onAppResumed does NOT lock if app was never paused (continuous foreground usage)', () async {
      await service.setPin('123456');
      service.unlock();
      expect(service.isLocked, isFalse);

      // App is actively in foreground, never paused:
      final locked = service.onAppResumed();
      expect(locked, isFalse);
      expect(service.isLocked, isFalse);
    });

    test('onAppResumed does NOT lock during recent unlock grace period', () async {
      await service.setPin('123456');
      service.lock();
      expect(service.isLocked, isTrue);

      service.unlock();
      expect(service.isLocked, isFalse);

      // Even if onAppPaused had set a timestamp before unlocking:
      service.onAppPaused();
      // Right after unlock, resume events must not re-lock:
      final locked = service.onAppResumed();
      expect(locked, isFalse);
      expect(service.isLocked, isFalse);
    });
  });
}
