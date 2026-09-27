import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/state/wellness_provider.dart';
import '../../core/services/notification_service.dart';

class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationSettingsSheet(),
    );
  }

  @override
  State<NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  @override
  Widget build(BuildContext context) {
    final provider = WellnessStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          height: MediaQuery.of(context).size.height * 0.75,
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
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: brandEmerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune_rounded, color: brandEmerald, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Settings',
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Control telemetry alerts & reminders',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: subtitleColor,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24, thickness: 0.6),
              // Toggle Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSectionHeader('TELEMETRY REMINDERS', isDark),
                    _buildToggleTile(
                      icon: Icons.water_drop_rounded,
                      color: const Color(0xFF2EB5FA),
                      title: 'Hydration Pacing',
                      subtitle: 'Remind me to drink water during active waking hours',
                      value: provider.isHydrationNotificationEnabled,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        provider.updateNotificationPreferences(hydration: val);
                      },
                      isDark: isDark,
                    ),
                    if (provider.gender.toLowerCase() != 'male')
                      _buildToggleTile(
                        icon: Icons.auto_awesome_rounded,
                        color: const Color(0xFFF43F5E),
                        title: 'Cycle & Reproductive Insights',
                        subtitle: 'Phase transitions, ovulation, and symptom advisories',
                        value: provider.isPeriodReminderEnabled,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          provider.updateNotificationPreferences(period: val);
                        },
                        isDark: isDark,
                      ),
                    _buildToggleTile(
                      icon: Icons.bedtime_rounded,
                      color: const Color(0xFF8B5CF6),
                      title: 'Rest & Sleep Summaries',
                      subtitle: 'Morning sleep quality score and bedtime countdown',
                      value: provider.isSleepReminderEnabled,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        provider.updateNotificationPreferences(sleep: val);
                      },
                      isDark: isDark,
                    ),
                    _buildToggleTile(
                      icon: Icons.directions_run_rounded,
                      color: const Color(0xFF10B981),
                      title: 'Activity Milestones',
                      subtitle: 'Step targets reached and hourly movement reminders',
                      value: provider.isActivityRemindersEnabled,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        provider.updateNotificationPreferences(activity: val);
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('DISPLAY & SOUND', isDark),
                    _buildToggleTile(
                      icon: Icons.view_compact_alt_rounded,
                      color: const Color(0xFFF59E0B),
                      title: 'In-App Glass Banners',
                      subtitle: 'Show floating luxury cards when new telemetry alerts arrive',
                      value: provider.isInAppBannersEnabled,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        provider.updateNotificationPreferences(inAppBanners: val);
                      },
                      isDark: isDark,
                    ),
                    _buildToggleTile(
                      icon: Icons.volume_up_rounded,
                      color: const Color(0xFF06B6D4),
                      title: 'Haptic & Chimes',
                      subtitle: 'Subtle haptic tap when alerts are displayed',
                      value: provider.isSystemSoundEnabled,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        provider.updateNotificationPreferences(sound: val);
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    // Test notification button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            brandEmerald.withValues(alpha: 0.15),
                            const Color(0xFF2EB5FA).withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: brandEmerald.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          NotificationService.instance.dispatchNotification(
                            context,
                            WellnestNotification(
                              id: 'test-${DateTime.now().millisecondsSinceEpoch}',
                              title: 'Vitals Synced & Optimal',
                              message: 'All sensor telemetry synchronized. Cellular recovery readiness is currently at 94%.',
                              timestamp: DateTime.now(),
                              category: NotificationCategory.insights,
                              type: NotificationType.milestone,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bolt_rounded, color: brandEmerald, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Send Test Notification',
                                style: TextStyle(
                                  color: brandEmerald,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF19221C) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF263329) : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: const Color(0xFF10B981),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
