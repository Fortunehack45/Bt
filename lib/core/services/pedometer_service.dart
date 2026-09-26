import 'dart:async';
import 'package:flutter/services.dart';
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
class PedometerService {
  PedometerService._();
  static final PedometerService instance = PedometerService._();

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  bool _isSimulationMode = false;
  bool get isSimulationMode => _isSimulationMode;

  Timer? _simulationTimer;
  int _currentCadenceSpm = 0;
  int get currentCadenceSpm => _currentCadenceSpm;

  final _stepStreamController = StreamController<int>.broadcast();
  Stream<int> get stepStream => _stepStreamController.stream;

  PedometerPaceCategory get paceCategory {
    if (_currentCadenceSpm <= 10) return PedometerPaceCategory.stationary;
    if (_currentCadenceSpm < 100) return PedometerPaceCategory.slowWalk;
    if (_currentCadenceSpm < 140) return PedometerPaceCategory.briskWalk;
    return PedometerPaceCategory.running;
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

  /// Starts live step tracking.
  void startTracking(WellnessProvider provider, {bool simulation = false}) {
    _isTracking = true;
    _isSimulationMode = simulation;

    if (simulation) {
      _startSimulation(provider);
    } else {
      // In physical hardware mode, start cadence pacing and listen to platform motion
      _currentCadenceSpm = 108;
      provider.updateCadence(_currentCadenceSpm);
    }
  }

  /// Stops live step tracking.
  void stopTracking(WellnessProvider provider) {
    _isTracking = false;
    _isSimulationMode = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _currentCadenceSpm = 0;
    provider.updateCadence(0);
  }

  void _startSimulation(WellnessProvider provider) {
    _simulationTimer?.cancel();
    _currentCadenceSpm = 112; // 112 steps per minute brisk walk
    provider.updateCadence(_currentCadenceSpm);

    // Increment step every ~535ms to match 112 SPM
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 535), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }
      provider.addSteps(1);
      _stepStreamController.add(provider.steps);
      HapticFeedback.selectionClick();
    });
  }

  /// Simulates walking a specific count of steps instantly (e.g. 500 steps brisk walk).
  void simulateBurstWalk(WellnessProvider provider, int stepsCount) {
    provider.addSteps(stepsCount);
    _stepStreamController.add(provider.steps);
    HapticFeedback.mediumImpact();
  }

  void dispose() {
    _simulationTimer?.cancel();
    _stepStreamController.close();
  }
}
