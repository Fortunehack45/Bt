import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/state/wellness_provider.dart';
import 'notification_settings_sheet.dart';

class NotificationCenterSheet extends StatefulWidget {
  const NotificationCenterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationCenterSheet(),
    );
  }

  @override
  State<NotificationCenterSheet> createState() => _NotificationCenterSheetState();
}

class _NotificationCenterSheetState extends State<NotificationCenterSheet> {
  NotificationCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final provider = WellnessStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allNotifications = provider.notifications;

    final filteredList = _selectedCategory == null
        ? allNotifications
        : allNotifications.where((n) => n.category == _selectedCategory).toList();

    final bgColor = isDark ? const Color(0xFF131A15) : Colors.white;
    final borderColor = isDark ? const Color(0xFF233025) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    const brandEmerald = Color(0xFF10B981);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: isDark ? 0.94 : 0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (provider.unreadNotificationCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: brandEmerald.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: brandEmerald.withOpacity(0.4), width: 1),
                        ),
                        child: Text(
                          '${provider.unreadNotificationCount} new',
                          style: const TextStyle(
                            color: brandEmerald,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      color: subtitleColor,
                      tooltip: 'Preferences',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        NotificationSettingsSheet.show(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: subtitleColor,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Unread Action Strip (resilient to large notification counts)
              if (provider.unreadNotificationCount > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 6),
                  child: Row(
                    children: [
                      Text(
                        '${provider.unreadNotificationCount} unread alert${provider.unreadNotificationCount > 1 ? "s" : ""}',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          provider.markAllNotificationsAsRead();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: brandEmerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: brandEmerald.withOpacity(0.25), width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.done_all_rounded, size: 14, color: brandEmerald),
                              SizedBox(width: 5),
                              Text(
                                'Mark all as read',
                                style: TextStyle(
                                  color: brandEmerald,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Category Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All (${allNotifications.length})',
                        isSelected: _selectedCategory == null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = null);
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Reminders',
                        isSelected: _selectedCategory == NotificationCategory.reminders,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = NotificationCategory.reminders);
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Insights',
                        isSelected: _selectedCategory == NotificationCategory.insights,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = NotificationCategory.insights);
                        },
                        isDark: isDark,
                      ),
                      if (provider.gender.toLowerCase() != 'male') ...[
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Reproductive',
                          isSelected: _selectedCategory == NotificationCategory.reproductive,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCategory = NotificationCategory.reproductive);
                          },
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Divider(height: 12, thickness: 0.5),

              // Notification List
              Expanded(
                child: filteredList.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return _buildNotificationCard(context, item, isDark, provider);
                        },
                      ),
              ),

              // Bottom Clear All button
              if (allNotifications.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          provider.clearAllNotifications();
                        },
                        icon: Icon(
                          Icons.delete_sweep_rounded,
                          size: 18,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        label: Text(
                          'Clear All Notifications',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    const brandEmerald = Color(0xFF10B981);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? brandEmerald.withValues(alpha: 0.16)
              : (isDark ? const Color(0xFF19221C) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? brandEmerald
                : (isDark ? const Color(0xFF263329) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? brandEmerald
                : (isDark ? Colors.white70 : const Color(0xFF475569)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WellnestNotification item,
    bool isDark,
    WellnessProvider provider,
  ) {
    final accent = item.accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
          ),
          onDismissed: (_) {
            HapticFeedback.lightImpact();
            provider.clearNotification(item.id);
          },
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              provider.markNotificationAsRead(item.id);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? (item.isRead ? const Color(0xFF161E18) : const Color(0xFF1C2720))
                    : (item.isRead ? const Color(0xFFF8FAFC) : Colors.white),
                borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: !item.isRead
                  ? accent.withValues(alpha: 0.4)
                  : (isDark ? const Color(0xFF233025) : const Color(0xFFE2E8F0)),
              width: !item.isRead ? 1.2 : 0.8,
            ),
            boxShadow: !item.isRead
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(item.icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.category.label.toUpperCase(),
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.relativeTime,
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.message,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Unread dot
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF19221C) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'All Caught Up',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No new alerts. Your biometric telemetry is pacing normally.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
