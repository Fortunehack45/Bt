import 'package:flutter_test/flutter_test.dart';
import 'package:wellnest/core/services/pedometer_service.dart';
import 'package:wellnest/domain/models/smart_device_models.dart';
import 'package:wellnest/domain/state/wellness_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Smart Device & Vitals Telemetry Tests', () {
    test('SmartDevice model serialization and properties', () {
      const device = SmartDevice(
        id: 'test-ring',
        name: 'Oura Horizon',
        type: DeviceType.smartRing,
        brand: DeviceBrand.oura,
        batteryLevel: 85,
        macAddressOrUuid: 'AA:BB:CC:DD:EE:FF',
      );

      expect(device.isConnected, false);
      expect(device.brand.displayName, 'Oura');
      expect(device.type.label, 'Smart Ring');

      final json = device.toJson();
      final revived = SmartDevice.fromJson(json);

      expect(revived.id, 'test-ring');
      expect(revived.name, 'Oura Horizon');
      expect(revived.type, DeviceType.smartRing);
      expect(revived.brand, DeviceBrand.oura);
      expect(revived.batteryLevel, 85);
    });

    test('VitalsTelemetry clinical BP categorization and calculations', () {
      final optimalBp = VitalsTelemetry(
        systolicBp: 115,
        diastolicBp: 75,
        timestamp: DateTime.now(),
      );
      expect(optimalBp.bpCategory, BloodPressureCategory.optimal);
      expect(optimalBp.pulsePressure, 40);

      final elevatedBp = VitalsTelemetry(
        systolicBp: 124,
        diastolicBp: 78,
        timestamp: DateTime.now(),
      );
      expect(elevatedBp.bpCategory, BloodPressureCategory.elevated);

      final stage1Bp = VitalsTelemetry(
        systolicBp: 134,
        diastolicBp: 84,
        timestamp: DateTime.now(),
      );
      expect(stage1Bp.bpCategory, BloodPressureCategory.stage1Hypertension);

      final crisisBp = VitalsTelemetry(
        systolicBp: 185,
        diastolicBp: 110,
        timestamp: DateTime.now(),
      );
      expect(crisisBp.bpCategory, BloodPressureCategory.hypertensiveCrisis);
    });

    test('VitalsTelemetry temperature and Basal Body Temp calculations', () {
      final reading = VitalsTelemetry(
        bodyTemperatureCelsius: 36.6,
        timestamp: DateTime.now(),
      );

      expect(reading.bodyTemperatureCelsius, 36.6);
      expect(reading.bodyTemperatureFahrenheit, closeTo(97.88, 0.1));
      expect(reading.bbtDeviationCelsius, closeTo(0.1, 0.05));
    });

    test('PedometerService distance, calories, and cadence calculations', () async {
      expect(PedometerService.calculateDistanceKm(10000), 7.8);
      expect(PedometerService.calculateDistanceMiles(10000), 4.84);
      expect(PedometerService.calculateActiveCalories(10000), 400);

      final provider = WellnessProvider();
      expect(provider.steps, 0);

      PedometerService.instance.processHardwareStepEvent(provider, 300);
      expect(provider.steps, 300);

      await PedometerService.instance.startTracking(provider);
      expect(PedometerService.instance.isTracking, true);
      await PedometerService.instance.stopTracking(provider);
      expect(PedometerService.instance.isTracking, false);
    });

    test('WellnessProvider manages vitals and smart wearables state', () {
      final provider = WellnessProvider();

      // Check initial clean zero-state (no fake pre-seeded hardware)
      expect(provider.connectedDevices.isEmpty, true);
      expect(provider.activeDevice, isNull);

      // Record BP
      provider.recordBloodPressure(120, 78);
      expect(provider.systolicBp, 120);
      expect(provider.diastolicBp, 78);
      expect(provider.bpCategory, BloodPressureCategory.elevated);

      // Record Temperature
      provider.recordBodyTemperature(36.9);
      expect(provider.bodyTemperatureCelsius, 36.9);
      expect(provider.bodyTemperatureFahrenheit, closeTo(98.42, 0.1));

      // Record SpO2 & HRV
      provider.recordBloodOxygen(99);
      expect(provider.bloodOxygenSpO2, 99);
      provider.recordHrv(58);
      expect(provider.hrvMs, 58);

      // Pair a new watch
      const appleWatch = SmartDevice(
        id: 'apple-watch-ultra',
        name: 'Apple Watch Ultra',
        type: DeviceType.smartWatch,
        brand: DeviceBrand.apple,
        batteryLevel: 95,
      );
      provider.pairDevice(appleWatch);

      expect(provider.activeDevice?.id, 'apple-watch-ultra');
      expect(provider.connectedDevices.any((d) => d.id == 'apple-watch-ultra'), true);

      // Disconnect
      provider.disconnectDevice('apple-watch-ultra');
      expect(provider.activeDevice, isNull);
    });

    test('Clinical health score dynamic calculation and tier evaluation', () {
      final provider = WellnessProvider();
      expect(provider.healthScoreTier, '🎯 Foundation Phase Tier');

      // Add biometrics to achieve optimal health tier
      provider.addSteps(10000);
      provider.addWaterGlass(8);
      provider.logSleep(8.0);
      provider.addMeal('Balanced Lunch', 'Lunch', 2000, 'Nutrient dense');
      provider.recordBpm(65);
      provider.recordBloodPressure(118, 76);

      expect(provider.healthScore, greaterThanOrEqualTo(85));
      expect(provider.healthScoreTier, '🌟 Optimal Health Tier');
      expect(provider.healthScoreProgress, greaterThanOrEqualTo(0.85));
    });
  });
}
