import 'dart:convert';

/// Participant in a collaborative wellness challenge.
class GoalParticipant {
  final String userId;
  final String displayName;
  final double currentProgress;
  final DateTime lastUpdated;

  const GoalParticipant({
    required this.userId,
    required this.displayName,
    required this.currentProgress,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'currentProgress': currentProgress,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory GoalParticipant.fromJson(Map<String, dynamic> map) => GoalParticipant(
        userId: map['userId'] as String? ?? '',
        displayName: map['displayName'] as String? ?? 'Partner',
        currentProgress: (map['currentProgress'] as num?)?.toDouble() ?? 0.0,
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.tryParse(map['lastUpdated'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// A friendly reminder / nudge sent between goal partners.
class GoalReminderNudge {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;

  const GoalReminderNudge({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GoalReminderNudge.fromJson(Map<String, dynamic> map) => GoalReminderNudge(
        id: map['id'] as String? ?? '',
        senderId: map['senderId'] as String? ?? '',
        senderName: map['senderName'] as String? ?? 'Partner',
        message: map['message'] as String? ?? 'Stay hydrated and keep moving!',
        timestamp: map['timestamp'] != null
            ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// A collaborative goal shared between two or more Wellnest users.
class SharedGoal {
  final String goalId;
  final String title;
  final String metricType; // 'steps', 'water', 'sleep', 'calories'
  final double targetValue;
  final String unit; // 'steps', 'glasses', 'hrs', 'kcal'
  final String creatorId;
  final Map<String, GoalParticipant> participants;
  final DateTime startDate;
  final DateTime endDate;
  final List<GoalReminderNudge> reminders;

  const SharedGoal({
    required this.goalId,
    required this.title,
    required this.metricType,
    required this.targetValue,
    required this.unit,
    required this.creatorId,
    required this.participants,
    required this.startDate,
    required this.endDate,
    this.reminders = const [],
  });

  /// Overall collective progress ratio (0.0 to 1.0)
  double get collectiveProgressRatio {
    if (participants.isEmpty || targetValue <= 0) return 0.0;
    double total = 0.0;
    for (final p in participants.values) {
      total += p.currentProgress;
    }
    final collectiveTarget = targetValue * participants.length;
    return (total / collectiveTarget).clamp(0.0, 1.0);
  }

  SharedGoal copyWith({
    Map<String, GoalParticipant>? participants,
    List<GoalReminderNudge>? reminders,
  }) {
    return SharedGoal(
      goalId: goalId,
      title: title,
      metricType: metricType,
      targetValue: targetValue,
      unit: unit,
      creatorId: creatorId,
      participants: participants ?? this.participants,
      startDate: startDate,
      endDate: endDate,
      reminders: reminders ?? this.reminders,
    );
  }

  Map<String, dynamic> toJson() => {
        'goalId': goalId,
        'title': title,
        'metricType': metricType,
        'targetValue': targetValue,
        'unit': unit,
        'creatorId': creatorId,
        'participants': participants.map((k, v) => MapEntry(k, v.toJson())),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'reminders': reminders.map((r) => r.toJson()).toList(),
      };

  factory SharedGoal.fromJson(Map<String, dynamic> map) {
    final participantsMap = <String, GoalParticipant>{};
    if (map['participants'] is Map) {
      (map['participants'] as Map).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          participantsMap[k.toString()] = GoalParticipant.fromJson(v);
        }
      });
    }

    return SharedGoal(
      goalId: map['goalId'] as String? ?? '',
      title: map['title'] as String? ?? 'Shared Challenge',
      metricType: map['metricType'] as String? ?? 'steps',
      targetValue: (map['targetValue'] as num?)?.toDouble() ?? 10000.0,
      unit: map['unit'] as String? ?? 'steps',
      creatorId: map['creatorId'] as String? ?? '',
      participants: participantsMap,
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'] as String) ?? DateTime.now().add(const Duration(days: 7))
          : DateTime.now().add(const Duration(days: 7)),
      reminders: (map['reminders'] as List<dynamic>?)
              ?.map((r) => GoalReminderNudge.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
