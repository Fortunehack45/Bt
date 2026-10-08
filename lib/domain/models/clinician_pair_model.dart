/// Record of an unauthorized or detected screenshot captured during an examiner session.
class ScreenshotAuditEntry {
  final String id;
  final String examinerCode;
  final String sectionName;
  final DateTime timestamp;

  const ScreenshotAuditEntry({
    required this.id,
    required this.examinerCode,
    required this.sectionName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'examinerCode': examinerCode,
        'sectionName': sectionName,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ScreenshotAuditEntry.fromJson(Map<String, dynamic> map) => ScreenshotAuditEntry(
        id: map['id'] as String? ?? '',
        examinerCode: map['examinerCode'] as String? ?? '',
        sectionName: map['sectionName'] as String? ?? 'General View',
        timestamp: map['timestamp'] != null
            ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// Represents a secure clinician/doctor pairing session.
class ClinicianPairGrant {
  final String pairCode; // e.g. "DOC-7842"
  final String patientId;
  final String patientDisplayName;
  final String securityQuestion1; // e.g. "Patient Full Legal Name"
  final String securityAnswer1;
  final String securityQuestion2; // e.g. "Patient Favorite Color"
  final String securityAnswer2;
  final List<String> permittedSections; // e.g. ['vitals', 'sleep', 'steps', 'water']
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final List<ScreenshotAuditEntry> screenshotAuditLog;

  const ClinicianPairGrant({
    required this.pairCode,
    required this.patientId,
    required this.patientDisplayName,
    required this.securityQuestion1,
    required this.securityAnswer1,
    required this.securityQuestion2,
    required this.securityAnswer2,
    required this.permittedSections,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
    this.screenshotAuditLog = const [],
  });

  /// Whether session has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Remaining duration until session auto-terminates.
  Duration get remainingTime {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Alias for remainingTime
  Duration get remainingDuration => remainingTime;

  /// Whether a specific health category is permitted to be viewed.
  bool canAccessSection(String sectionKey) {
    if (isExpired || !isActive) return false;
    return permittedSections.contains(sectionKey.toLowerCase());
  }

  /// Verifies clinician security answers case-insensitively.
  bool verifyAnswers(String ans1, String ans2) {
    final a1 = ans1.trim().toLowerCase();
    final a2 = ans2.trim().toLowerCase();
    final expected1 = securityAnswer1.trim().toLowerCase();
    final expected2 = securityAnswer2.trim().toLowerCase();
    return a1 == expected1 && a2 == expected2;
  }

  ClinicianPairGrant copyWith({
    bool? isActive,
    List<ScreenshotAuditEntry>? screenshotAuditLog,
    DateTime? expiresAt,
  }) {
    return ClinicianPairGrant(
      pairCode: pairCode,
      patientId: patientId,
      patientDisplayName: patientDisplayName,
      securityQuestion1: securityQuestion1,
      securityAnswer1: securityAnswer1,
      securityQuestion2: securityQuestion2,
      securityAnswer2: securityAnswer2,
      permittedSections: permittedSections,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      screenshotAuditLog: screenshotAuditLog ?? this.screenshotAuditLog,
    );
  }

  Map<String, dynamic> toJson() => {
        'pairCode': pairCode,
        'patientId': patientId,
        'patientDisplayName': patientDisplayName,
        'securityQuestion1': securityQuestion1,
        'securityAnswer1': securityAnswer1,
        'securityQuestion2': securityQuestion2,
        'securityAnswer2': securityAnswer2,
        'permittedSections': permittedSections,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'isActive': isActive,
        'screenshotAuditLog': screenshotAuditLog.map((e) => e.toJson()).toList(),
      };

  factory ClinicianPairGrant.fromJson(Map<String, dynamic> map) {
    return ClinicianPairGrant(
      pairCode: map['pairCode'] as String? ?? '',
      patientId: map['patientId'] as String? ?? '',
      patientDisplayName: map['patientDisplayName'] as String? ?? 'Patient',
      securityQuestion1: map['securityQuestion1'] as String? ?? 'Patient Name',
      securityAnswer1: map['securityAnswer1'] as String? ?? '',
      securityQuestion2: map['securityQuestion2'] as String? ?? 'Favorite Color',
      securityAnswer2: map['securityAnswer2'] as String? ?? '',
      permittedSections: (map['permittedSections'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['vitals', 'sleep', 'steps'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: map['expiresAt'] != null
          ? DateTime.tryParse(map['expiresAt'] as String) ?? DateTime.now()
          : DateTime.now().add(const Duration(hours: 24)),
      isActive: map['isActive'] as bool? ?? true,
      screenshotAuditLog: (map['screenshotAuditLog'] as List<dynamic>?)
              ?.map((e) => ScreenshotAuditEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
