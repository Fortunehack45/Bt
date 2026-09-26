import 'package:flutter/material.dart';

/// Supported smart wearable and health peripheral device types.
enum DeviceType {
  smartRing,
  smartWatch,
  bloodPressureCuff,
  thermometer,
  genericBle,
}

extension DeviceTypeExtension on DeviceType {
  String get label {
    switch (this) {
      case DeviceType.smartRing:
        return 'Smart Ring';
      case DeviceType.smartWatch:
        return 'Smart Watch';
      case DeviceType.bloodPressureCuff:
        return 'Blood Pressure Monitor';
      case DeviceType.thermometer:
        return 'Smart Thermometer';
      case DeviceType.genericBle:
        return 'Health Sensor';
    }
  }

  IconData get icon {
    switch (this) {
      case DeviceType.smartRing:
        return Icons.circle_outlined;
      case DeviceType.smartWatch:
        return Icons.watch_rounded;
      case DeviceType.bloodPressureCuff:
        return Icons.monitor_heart_rounded;
      case DeviceType.thermometer:
        return Icons.device_thermostat_rounded;
      case DeviceType.genericBle:
        return Icons.bluetooth_audio_rounded;
    }
  }
}

/// Popular device brands supported for specialized telemetry.
enum DeviceBrand {
  oura,
  apple,
  samsung,
  ultrahuman,
  whoop,
  garmin,
  fitbit,
  withings,
  generic,
}

extension DeviceBrandExtension on DeviceBrand {
  String get displayName {
    switch (this) {
      case DeviceBrand.oura:
        return 'Oura';
      case DeviceBrand.apple:
        return 'Apple';
      case DeviceBrand.samsung:
        return 'Samsung';
      case DeviceBrand.ultrahuman:
        return 'Ultrahuman';
      case DeviceBrand.whoop:
        return 'WHOOP';
      case DeviceBrand.garmin:
        return 'Garmin';
      case DeviceBrand.fitbit:
        return 'Fitbit';
      case DeviceBrand.withings:
        return 'Withings';
      case DeviceBrand.generic:
        return 'BLE Health';
    }
  }
}

/// Real-time connection status of a paired smart device.
enum DeviceConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
}

/// Representation of a paired or discoverable smart health device.
class SmartDevice {
  final String id;
  final String name;
  final DeviceType type;
  final DeviceBrand brand;
  final DeviceConnectionState connectionState;
  final int batteryLevel; // 0 to 100%
  final DateTime? lastSyncedAt;
  final String? macAddressOrUuid;
  final String? firmwareVersion;
  final List<String> supportedMetrics;

  const SmartDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    this.connectionState = DeviceConnectionState.disconnected,
    this.batteryLevel = 100,
    this.lastSyncedAt,
    this.macAddressOrUuid,
    this.firmwareVersion,
    this.supportedMetrics = const ['Heart Rate', 'Steps', 'Temperature'],
  });

  bool get isConnected => connectionState == DeviceConnectionState.connected;

  SmartDevice copyWith({
    String? id,
    String? name,
    DeviceType? type,
    DeviceBrand? brand,
    DeviceConnectionState? connectionState,
    int? batteryLevel,
    DateTime? lastSyncedAt,
    String? macAddressOrUuid,
    String? firmwareVersion,
    List<String>? supportedMetrics,
  }) {
    return SmartDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      connectionState: connectionState ?? this.connectionState,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      macAddressOrUuid: macAddressOrUuid ?? this.macAddressOrUuid,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      supportedMetrics: supportedMetrics ?? this.supportedMetrics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'brand': brand.name,
      'connectionState': connectionState.name,
      'batteryLevel': batteryLevel,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'macAddressOrUuid': macAddressOrUuid,
      'firmwareVersion': firmwareVersion,
      'supportedMetrics': supportedMetrics,
    };
  }

  factory SmartDevice.fromJson(Map<String, dynamic> json) {
    return SmartDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      type: DeviceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DeviceType.genericBle,
      ),
      brand: DeviceBrand.values.firstWhere(
        (e) => e.name == json['brand'],
        orElse: () => DeviceBrand.generic,
      ),
      connectionState: DeviceConnectionState.values.firstWhere(
        (e) => e.name == json['connectionState'],
        orElse: () => DeviceConnectionState.disconnected,
      ),
      batteryLevel: (json['batteryLevel'] as num?)?.toInt() ?? 100,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.tryParse(json['lastSyncedAt'] as String)
          : null,
      macAddressOrUuid: json['macAddressOrUuid'] as String?,
      firmwareVersion: json['firmwareVersion'] as String?,
      supportedMetrics: (json['supportedMetrics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Heart Rate', 'Steps', 'Temperature'],
    );
  }
}

/// Clinical classification of Blood Pressure readings.
enum BloodPressureCategory {
  optimal,
  normal,
  elevated,
  stage1Hypertension,
  stage2Hypertension,
  hypertensiveCrisis,
}

extension BloodPressureCategoryExtension on BloodPressureCategory {
  String get label {
    switch (this) {
      case BloodPressureCategory.optimal:
        return 'Optimal Normal';
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.stage1Hypertension:
        return 'Stage 1 Hypertension';
      case BloodPressureCategory.stage2Hypertension:
        return 'Stage 2 Hypertension';
      case BloodPressureCategory.hypertensiveCrisis:
        return 'Hypertensive Advisory';
    }
  }

  Color get color {
    switch (this) {
      case BloodPressureCategory.optimal:
        return const Color(0xFF10B981); // Emerald
      case BloodPressureCategory.normal:
        return const Color(0xFF34D399); // Mint
      case BloodPressureCategory.elevated:
        return const Color(0xFFF59E0B); // Amber
      case BloodPressureCategory.stage1Hypertension:
        return const Color(0xFFFB923C); // Orange
      case BloodPressureCategory.stage2Hypertension:
      case BloodPressureCategory.hypertensiveCrisis:
        return const Color(0xFFEF4444); // Red
    }
  }
}

/// Live snapshot of telemetry streaming from connected wearables.
class VitalsTelemetry {
  final int steps;
  final int cadenceSpm; // Steps per minute
  final int heartRateBpm;
  final int restingHeartRate;
  final int hrvMs; // Heart Rate Variability (RMSSD in ms)
  final int systolicBp; // mmHg (e.g. 118)
  final int diastolicBp; // mmHg (e.g. 76)
  final double bodyTemperatureCelsius; // e.g. 36.6
  final int spo2Percentage; // e.g. 98%
  final DateTime timestamp;

  const VitalsTelemetry({
    this.steps = 0,
    this.cadenceSpm = 0,
    this.heartRateBpm = 72,
    this.restingHeartRate = 62,
    this.hrvMs = 54,
    this.systolicBp = 118,
    this.diastolicBp = 76,
    this.bodyTemperatureCelsius = 36.6,
    this.spo2Percentage = 98,
    required this.timestamp,
  });

  /// Blood pressure category derived from American Heart Association guidelines.
  BloodPressureCategory get bpCategory {
    if (systolicBp < 120 && diastolicBp < 80) {
      return BloodPressureCategory.optimal;
    } else if (systolicBp >= 120 && systolicBp <= 129 && diastolicBp < 80) {
      return BloodPressureCategory.elevated;
    } else if ((systolicBp >= 130 && systolicBp <= 139) ||
        (diastolicBp >= 80 && diastolicBp <= 89)) {
      return BloodPressureCategory.stage1Hypertension;
    } else if (systolicBp >= 180 || diastolicBp >= 120) {
      return BloodPressureCategory.hypertensiveCrisis;
    } else {
      return BloodPressureCategory.stage2Hypertension;
    }
  }

  /// Mean Arterial Pressure (MAP) calculation: Diastolic + (1/3 * (Systolic - Diastolic)).
  double get meanArterialPressure {
    return diastolicBp + ((systolicBp - diastolicBp) / 3.0);
  }

  /// Pulse pressure: Systolic - Diastolic.
  int get pulsePressure => systolicBp - diastolicBp;

  /// Body temperature converted to Fahrenheit.
  double get bodyTemperatureFahrenheit {
    return (bodyTemperatureCelsius * 9 / 5) + 32.0;
  }

  /// Basal Body Temperature deviation relative to 36.5°C baseline.
  double get bbtDeviationCelsius {
    return double.parse((bodyTemperatureCelsius - 36.5).toStringAsFixed(2));
  }

  VitalsTelemetry copyWith({
    int? steps,
    int? cadenceSpm,
    int? heartRateBpm,
    int? restingHeartRate,
    int? hrvMs,
    int? systolicBp,
    int? diastolicBp,
    double? bodyTemperatureCelsius,
    int? spo2Percentage,
    DateTime? timestamp,
  }) {
    return VitalsTelemetry(
      steps: steps ?? this.steps,
      cadenceSpm: cadenceSpm ?? this.cadenceSpm,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      hrvMs: hrvMs ?? this.hrvMs,
      systolicBp: systolicBp ?? this.systolicBp,
      diastolicBp: diastolicBp ?? this.diastolicBp,
      bodyTemperatureCelsius:
          bodyTemperatureCelsius ?? this.bodyTemperatureCelsius,
      spo2Percentage: spo2Percentage ?? this.spo2Percentage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
