import 'auth_user_model.dart';

/// Single chat message within a support inquiry.
class SupportMessage {
  final String id;
  final String senderRole; // 'user' or 'support'
  final String senderName;
  final String content;
  final DateTime timestamp;

  const SupportMessage({
    required this.id,
    required this.senderRole,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });

  bool get isFromUser => senderRole == 'user';

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderRole': senderRole,
        'senderName': senderName,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SupportMessage.fromJson(Map<String, dynamic> map) => SupportMessage(
        id: map['id'] as String? ?? '',
        senderRole: map['senderRole'] as String? ?? 'user',
        senderName: map['senderName'] as String? ?? 'User',
        content: map['content'] as String? ?? '',
        timestamp: map['timestamp'] != null
            ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// Represents a customer support inquiry ticket.
class SupportTicket {
  final String ticketId;
  final String userId;
  final UserPlanTier userPlan;
  final String subject;
  final String category; // 'General', 'Wearable Sync', 'Premium Billing', 'Vitals Question'
  final String status; // 'open', 'in_progress', 'resolved'
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SupportMessage> messages;

  const SupportTicket({
    required this.ticketId,
    required this.userId,
    required this.userPlan,
    required this.subject,
    required this.category,
    this.status = 'open',
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  SupportTicket copyWith({
    String? status,
    DateTime? updatedAt,
    List<SupportMessage>? messages,
  }) {
    return SupportTicket(
      ticketId: ticketId,
      userId: userId,
      userPlan: userPlan,
      subject: subject,
      category: category,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() => {
        'ticketId': ticketId,
        'userId': userId,
        'userPlan': userPlan.name,
        'subject': subject,
        'category': category,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory SupportTicket.fromJson(Map<String, dynamic> map) {
    return SupportTicket(
      ticketId: map['ticketId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userPlan: UserPlanTier.fromString(map['userPlan'] as String?),
      subject: map['subject'] as String? ?? 'Support Inquiry',
      category: map['category'] as String? ?? 'General',
      status: map['status'] as String? ?? 'open',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      messages: (map['messages'] as List<dynamic>?)
              ?.map((m) => SupportMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
