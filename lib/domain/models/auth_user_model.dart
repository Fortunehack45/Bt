/// Subscription tier for Wellnest users.
enum UserPlanTier {
  freemium('Freemium', 'Essential wellness telemetry & device syncing'),
  premium('Premium', 'Advanced clinical insights, AI coaching & priority support');

  final String label;
  final String description;
  const UserPlanTier(this.label, this.description);

  static UserPlanTier fromString(String? val) {
    if (val?.toLowerCase() == 'premium') return UserPlanTier.premium;
    return UserPlanTier.freemium;
  }
}

/// Represents an authenticated Wellnest user profile.
/// Strictly segregates public account metadata from private health records.
class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final UserPlanTier plan;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool isEmailVerified;
  final String platform; // 'android', 'ios', 'web'
  final String? bloodGroup; // 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'
  final bool hasCompletedOnboarding;
  final Map<String, dynamic>? healthProfile;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.plan = UserPlanTier.freemium,
    required this.createdAt,
    required this.lastActiveAt,
    this.isEmailVerified = false,
    this.platform = 'android',
    this.bloodGroup,
    this.hasCompletedOnboarding = false,
    this.healthProfile,
  });

  /// Anonymized ID safe for Admin and Support dashboards (e.g. "USR-A83F")
  String get anonymizedId {
    if (uid.length < 6) return 'USR-$uid'.toUpperCase();
    return 'USR-${uid.substring(uid.length - 6).toUpperCase()}';
  }

  /// Whether user was active in the last 7 days.
  bool get isActive {
    final diff = DateTime.now().difference(lastActiveAt);
    return diff.inDays <= 7;
  }

  /// Whether this user is an unauthenticated guest explorer.
  bool get isGuest => email.isEmpty;

  AuthUser copyWith({
    String? displayName,
    String? photoUrl,
    UserPlanTier? plan,
    DateTime? lastActiveAt,
    bool? isEmailVerified,
    String? bloodGroup,
    bool? hasCompletedOnboarding,
    Map<String, dynamic>? healthProfile,
  }) {
    return AuthUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      plan: plan ?? this.plan,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      platform: platform,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      healthProfile: healthProfile ?? this.healthProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'plan': plan.name,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'platform': platform,
      'bloodGroup': bloodGroup,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'healthProfile': healthProfile,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> map) {
    return AuthUser(
      uid: map['uid'] as String? ?? 'guest_user',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Wellness Explorer',
      photoUrl: map['photoUrl'] as String?,
      plan: UserPlanTier.fromString(map['plan'] as String?),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastActiveAt: map['lastActiveAt'] != null
          ? DateTime.tryParse(map['lastActiveAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      platform: map['platform'] as String? ?? 'android',
      bloodGroup: map['bloodGroup'] as String?,
      hasCompletedOnboarding: map['hasCompletedOnboarding'] as bool? ?? false,
      healthProfile: map['healthProfile'] != null
          ? Map<String, dynamic>.from(map['healthProfile'] as Map)
          : null,
    );
  }

  static AuthUser createGuest() {
    final now = DateTime.now();
    return AuthUser(
      uid: 'guest_${now.millisecondsSinceEpoch}',
      email: '',
      displayName: 'Wellness Explorer',
      plan: UserPlanTier.freemium,
      createdAt: now,
      lastActiveAt: now,
      isEmailVerified: false,
      hasCompletedOnboarding: false,
    );
  }
}
