import 'package:flutter_test/flutter_test.dart';
import 'package:wellnest/domain/models/notification_item.dart';
import 'package:wellnest/domain/state/wellness_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notification System Tests', () {
    test('WellnestNotification data model properties and time formats', () {
      final now = DateTime.now();
      final n1 = WellnestNotification(
        id: 'test-1',
        title: 'Drink Water',
        message: 'Hydration window open',
        timestamp: now.subtract(const Duration(minutes: 5)),
        category: NotificationCategory.reminders,
        type: NotificationType.hydration,
      );

      expect(n1.relativeTime, '5m ago');
      expect(n1.isRead, false);
      expect(n1.category.label, 'Reminders');

      final n2 = n1.copyWith(isRead: true);
      expect(n2.isRead, true);
      expect(n2.id, 'test-1');
    });

    test('WellnessProvider seeds notifications and manages read state', () {
      final provider = WellnessProvider();

      expect(provider.notifications.isNotEmpty, true);
      final initialUnread = provider.unreadNotificationCount;
      expect(initialUnread, greaterThan(0));

      // Mark all read
      provider.markAllNotificationsAsRead();
      expect(provider.unreadNotificationCount, 0);

      // Add a new notification
      final fresh = WellnestNotification(
        id: 'fresh-1',
        title: 'New Vital Recorded',
        message: 'Heart rate sync optimal',
        timestamp: DateTime.now(),
        category: NotificationCategory.insights,
        type: NotificationType.milestone,
      );
      provider.addNotification(fresh);
      expect(provider.unreadNotificationCount, 1);
      expect(provider.notifications.first.id, 'fresh-1');

      // Clear specific notification
      provider.clearNotification('fresh-1');
      expect(provider.notifications.any((n) => n.id == 'fresh-1'), false);

      // Clear all
      provider.clearAllNotifications();
      expect(provider.notifications.isEmpty, true);
      expect(provider.unreadNotificationCount, 0);
    });

    test('WellnessProvider updates notification preferences', () {
      final provider = WellnessProvider();

      expect(provider.isHydrationNotificationEnabled, true);
      expect(provider.isInAppBannersEnabled, true);

      provider.updateNotificationPreferences(
        hydration: false,
        inAppBanners: false,
      );

      expect(provider.isHydrationNotificationEnabled, false);
      expect(provider.isInAppBannersEnabled, false);
    });
  });
}
