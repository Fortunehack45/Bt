import 'package:flutter/material.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/state/wellness_provider.dart';
import '../../features/notifications/widgets/notification_toast_banner.dart';
import '../../features/notifications/notification_center_sheet.dart';

import 'native_platform_service.dart';

/// Singleton service for managing and displaying in-app alerts and notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  OverlayEntry? _currentBannerEntry;

  /// Shows a floating in-app banner for a newly arrived notification.
  void showInAppBanner(BuildContext context, WellnestNotification notification) {
    _dismissCurrentBanner();

    final overlay = Overlay.of(context, rootOverlay: true);

    _currentBannerEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          type: MaterialType.transparency,
          child: NotificationToastBanner(
            notification: notification,
            onTap: () {
              _dismissCurrentBanner();
              NotificationCenterSheet.show(context);
            },
            onDismissed: () {
              _dismissCurrentBanner();
            },
          ),
        ),
      ),
    );

    overlay.insert(_currentBannerEntry!);
  }

  void _dismissCurrentBanner() {
    _currentBannerEntry?.remove();
    _currentBannerEntry = null;
  }

  /// Dispatches an alert into provider, shows in-app banner, and triggers real system status-bar notification.
  void dispatchNotification(BuildContext context, WellnestNotification notification) {
    final provider = WellnessStateScope.of(context);
    provider.addNotification(notification);

    if (provider.isInAppBannersEnabled) {
      showInAppBanner(context, notification);
    }

    // Trigger real Android & iOS system-level status-bar notification
    NativePlatformService.instance.showSystemNotification(
      title: notification.title,
      body: notification.message,
      id: notification.id.hashCode,
    );
  }

  /// Quick action: Dispatches a hydration pacing reminder.
  void sendHydrationReminder(BuildContext context) {
    final notification = WellnestNotification(
      id: 'hydro-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Optimal Hydration Window',
      message: 'Time to drink 250ml of water to keep physical endurance and cognitive clarity primed.',
      timestamp: DateTime.now(),
      category: NotificationCategory.reminders,
      type: NotificationType.hydration,
    );
    dispatchNotification(context, notification);
  }

  /// Quick action: Dispatches a reproductive cycle reminder.
  void sendCycleAdvisory(BuildContext context, {required String title, required String message}) {
    final notification = WellnestNotification(
      id: 'cycle-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      category: NotificationCategory.reproductive,
      type: NotificationType.period,
    );
    dispatchNotification(context, notification);
  }

  /// Quick action: Dispatches an activity milestone alert.
  void sendActivityMilestone(BuildContext context, {required String title, required String message}) {
    final notification = WellnestNotification(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      category: NotificationCategory.insights,
      type: NotificationType.milestone,
    );
    dispatchNotification(context, notification);
  }
}
