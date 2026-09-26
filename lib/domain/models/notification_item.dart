import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Categories of health and wellness notifications supported by Wellnest.
enum NotificationCategory {
  all(displayName: 'All', label: 'All'),
  reminders(displayName: 'Reminders', label: 'Reminder'),
  insights(displayName: 'Insights', label: 'Insight'),
  reproductive(displayName: 'Reproductive', label: 'Cycle & Baby'),
  system(displayName: 'System', label: 'System');

  final String displayName;
  final String label;
  const NotificationCategory({required this.displayName, required this.label});
}

/// Specific type of telemetry alert or milestone.
enum NotificationType {
  hydration(
    displayName: 'Hydration',
    category: NotificationCategory.reminders,
    icon: Icons.water_drop_rounded,
    accentColor: AppColors.waterBlue,
  ),
  activity(
    displayName: 'Movement',
    category: NotificationCategory.insights,
    icon: Icons.directions_walk_rounded,
    accentColor: AppColors.stepsOrange,
  ),
  sleep(
    displayName: 'Sleep & Recovery',
    category: NotificationCategory.reminders,
    icon: Icons.bedtime_rounded,
    accentColor: AppColors.sleepIndigo,
  ),
  nutrition(
    displayName: 'Nutrition & Fuel',
    category: NotificationCategory.reminders,
    icon: Icons.restaurant_rounded,
    accentColor: AppColors.nutritionGreen,
  ),
  menstrual(
    displayName: 'Cycle Forecast',
    category: NotificationCategory.reproductive,
    icon: Icons.spa_rounded,
    accentColor: Color(0xFFF43F5E), // Rose
  ),
  period(
    displayName: 'Cycle Forecast',
    category: NotificationCategory.reproductive,
    icon: Icons.spa_rounded,
    accentColor: Color(0xFFF43F5E), // Rose
  ),
  pregnancy(
    displayName: 'Fetal Milestone',
    category: NotificationCategory.reproductive,
    icon: Icons.child_care_rounded,
    accentColor: Color(0xFFA855F7), // Purple
  ),
  milestone(
    displayName: 'Milestone & Achievement',
    category: NotificationCategory.insights,
    icon: Icons.emoji_events_rounded,
    accentColor: Color(0xFF92DF2B), // Lime
  ),
  system(
    displayName: 'Vitality Insight',
    category: NotificationCategory.insights,
    icon: Icons.auto_awesome_rounded,
    accentColor: AppColors.primary,
  );

  final String displayName;
  final NotificationCategory category;
  final IconData icon;
  final Color accentColor;

  const NotificationType({
    required this.displayName,
    required this.category,
    required this.icon,
    required this.accentColor,
  });
}

/// A luxury in-app notification item with live deep-linking and action chips.
class WellnestNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionRoute; // e.g. 'log_water', 'open_cycle', 'open_pregnancy', 'log_meal'
  final String? actionLabel; // e.g. '+1 Glass', 'View Cycle', 'Inspect Baby'
  final NotificationCategory? explicitCategory;

  const WellnestNotification({
    required this.id,
    required this.title,
    String? body,
    String? message,
    required this.timestamp,
    required this.type,
    NotificationCategory? category,
    this.isRead = false,
    this.actionRoute,
    this.actionLabel,
  })  : body = body ?? message ?? '',
        explicitCategory = category;

  String get message => body;
  NotificationCategory get category => explicitCategory ?? type.category;
  IconData get icon => type.icon;
  Color get accentColor => type.accentColor;

  WellnestNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    NotificationCategory? category,
    bool? isRead,
    String? actionRoute,
    String? actionLabel,
  }) {
    return WellnestNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? message ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      category: category ?? explicitCategory,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }

  /// Relative time formatted cleanly for UI (e.g. "Just now", "12m ago", "3h ago", "Yesterday")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
