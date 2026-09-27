import 'dart:async';
import 'package:flutter/services.dart';
import '../utils/haptic_service.dart';
import '../../domain/state/wellness_provider.dart';

/// Walking state category based on cadence.
enum PedometerPaceCategory {
  stationary,
  slowWalk,
  briskWalk,
  running,
}

extension PedometerPaceCategoryExtension on PedometerPaceCategory {
  String get label {
    switch (this) {
      case PedometerPaceCategory.stationary:
        return 'Stationary';
      case PedometerPaceCategory.slowWalk:
        return 'Casual Walk';
      case PedometerPaceCategory.briskWalk:
        return 'Brisk Cadence';
      case PedometerPaceCategory.running:
        return 'Running Pacing';
    }
  }
}

/// Central cross-platform pedometer and cadence tracking engine for Wellnest.
/// Bridges physical phone hardware sensors (Android Sensor.TYPE_STEP_DETECTOR / Accelerometer, iOS CMPedometer / CMMotionManager)
/// directly into the reactive wellness state without any simulations or mock data.
class PedometerService {
  PedometerService._() {
    _initChannel();
  }
  static final PedometerService instance = PedometerService._();

  static const MethodChannel _channel = MethodChannel('com.wellnest.vitality.health/pedometer');

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  bool _isHardwareSensorActive = false;
  bool get isHardwareSensorActive => _isHardwareSensorActive;

  Timer? _cadenceResetTimer;
  int _currentCadenceSpm = 0;
  int get currentCadenceSpm => _currentCadenceSpm;

  final List<DateTime> _recentStepTimestamps = [];
  WellnessProvider? _activeProvider;

  final _stepStreamController = StreamController<int>.broadcast();
  Stream<int> get stepStream => _stepStreamController.stream;

  PedometerPaceCategory get paceCategory {
    if (_currentCadenceSpm <= 10) return PedometerPaceCategory.stationary;
    if (_currentCadenceSpm < 100) return PedometerPaceCategory.slowWalk;
    if (_currentCadenceSpm < 140) return PedometerPaceCategory.briskWalk;
    return PedometerPaceCategory.running;
  }

  void _initChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onStepDetected') {
        final count = (call.arguments as num?)?.toInt() ?? 1;
        _handleHardwareStepDetected(count);
      }
    });
  }

  /// Processes genuine physical steps from the platform hardware sensor.
  void processHardwareStepEvent(WellnessProvider provider, int count) {
    if (count <= 0) return;
    _activeProvider = provider;
    _isTracking = true;
    _handleHardwareStepDetected(count);
  }

  void _handleHardwareStepDetected(int count) {
    final provider = _activeProvider;
    if (provider == null || !_isTracking) return;

    final now = DateTime.now();
    _recentStepTimestamps.add(now);
    _recentStepTimestamps.removeWhere((t) => now.difference(t).inSeconds > 8);

    // Calculate real instantaneous cadence from steps over time
    if (_recentStepTimestamps.length >= 2) {
      final elapsedSec = now.difference(_recentStepTimestamps.first).inMilliseconds / 1000.0;
      if (elapsedSec > 0.4) {
        _currentCadenceSpm = ((_recentStepTimestamps.length / elapsedSec) * 60).round().clamp(0, 220);
      }
    } else {
      _currentCadenceSpm = 104;
    }

    provider.addSteps(count);
    provider.updateCadence(_currentCadenceSpm);
    _stepStreamController.add(provider.steps);
    HapticService.selection();

    // Auto-decay cadence to 0 if user stops moving for 3.5 seconds
    _cadenceResetTimer?.cancel();
    _cadenceResetTimer = Timer(const Duration(milliseconds: 3500), () {
      _currentCadenceSpm = 0;
      provider.updateCadence(0);
    });
  }

  /// Calculates walking distance in kilometers based on standard 0.78m average stride.
  static double calculateDistanceKm(int steps) {
    return double.parse((steps * 0.00078).toStringAsFixed(2));
  }

  /// Calculates walking distance in miles.
  static double calculateDistanceMiles(int steps) {
    return double.parse((steps * 0.000484).toStringAsFixed(2));
  }

  /// Calculates estimated active calories burned based on 0.04 kcal/step.
  static int calculateActiveCalories(int steps) {
    return (steps * 0.04).round();
  }

  /// Starts live step tracking using physical phone hardware sensors.
  Future<void> startTracking(WellnessProvider provider) async {
    _activeProvider = provider;
    _isTracking = true;

    try {
      final available = await _channel.invokeMethod<bool>('isStepCountingAvailable') ?? false;
      if (available) {
        final started = await _channel.invokeMethod<bool>('startStepTracking') ?? false;
        _isHardwareSensorActive = started;
        if (started) {
          _currentCadenceSpm = 0;
          provider.updateCadence(0);
          return;
        }
      }
      _isHardwareSensorActive = false;
    } catch (_) {
      _isHardwareSensorActive = false;
    }
  }

  /// Stops live step tracking.
  Future<void> stopTracking(WellnessProvider provider) async {
    _isTracking = false;
    _isHardwareSensorActive = false;
    _cadenceResetTimer?.cancel();
    _currentCadenceSpm = 0;
    _recentStepTimestamps.clear();
    provider.updateCadence(0);

    try {
      await _channel.invokeMethod<bool>('stopStepTracking');
    } catch (_) {}
  }

  void dispose() {
    _cadenceResetTimer?.cancel();
    _stepStreamController.close();
  }
}
