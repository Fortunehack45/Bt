import 'package:flutter/material.dart';
import '../../core/glass/platform_glass_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';

/// Settings Screen organized by Account, Appearance, Preferences, and Privacy.
class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({super.key, required this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _waterReminders = true;
  bool _sleepReminders = true;
  bool _activityReminders = true;
  bool _isMetric = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

    return Scaffold(
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.pageMargin,
            right: AppSpacing.pageMargin,
            top: AppSpacing.sm,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PlatformGlassButton(
                    icon: Icons.chevron_left_rounded,
                    size: 42,
                    iconSize: 24,
                    tooltip: 'Back',
                    onTap: widget.onBack,
                  ),
                  Text('Settings', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                  const SizedBox(width: 42),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Appearance Section
              Text('Appearance', style: AppTypography.h3(isDark)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF323B36) : const Color(0xFFE8ECE9),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: isDark ? AppColors.primaryLight : AppColors.nutritionGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dark Mode', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                            Text('Platform frosted/liquid glass theme', style: AppTypography.caption(isDark)),
                          ],
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: provider.isDarkMode,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        HapticService.selection();
                        provider.toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Reminders & Notifications
              Text('Smart Reminders', style: AppTypography.h3(isDark)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      isDark: isDark,
                      title: 'Hydration Nudges',
                      subtitle: 'Every 2 hours during day',
                      value: _waterReminders,
                      onChanged: (val) => setState(() => _waterReminders = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      isDark: isDark,
                      title: 'Sleep Wind-Down',
                      subtitle: 'Alert 30 mins before 11:15 PM',
                      value: _sleepReminders,
                      onChanged: (val) => setState(() => _sleepReminders = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      isDark: isDark,
                      title: 'Hourly Step Alert',
                      subtitle: 'Encourages 250 steps/hour',
                      value: _activityReminders,
                      onChanged: (val) => setState(() => _activityReminders = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Units & Formats
              Text('Units & Data', style: AppTypography.h3(isDark)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      isDark: isDark,
                      title: 'Metric System',
                      subtitle: _isMetric ? 'Kilograms, Litres, Km' : 'Pounds, Ounces, Miles',
                      value: _isMetric,
                      onChanged: (val) => setState(() => _isMetric = val),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF323B36) : const Color(0xFFE8ECE9),
                          borderRadius: AppRadii.roundedSm,
                        ),
                        child: const Icon(Icons.file_download_outlined, color: AppColors.primaryDark, size: 20),
                      ),
                      title: Text('Export Wellness Data', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                      subtitle: Text('Download JSON or CSV report', style: AppTypography.caption(isDark)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        HapticService.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting complete wellness history...')),
                        );
                      },
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

  Widget _buildSwitchTile({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
              Text(subtitle, style: AppTypography.caption(isDark)),
            ],
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: (val) {
              HapticService.selection();
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }
}
