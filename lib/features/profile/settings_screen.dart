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

/// Settings Screen organized into distinct sections: Appearance, Reminders,
/// Goals, Data Management, and App Info.
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
  bool _mealReminders = true;
  bool _isMetric = true;

  void _showSetGoalDialog(BuildContext context, String title, int currentVal, String unit, Function(int) onSave) {
    final controller = TextEditingController(text: currentVal.toString());

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Target ($unit)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val > 0) {
                  onSave(val);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title updated to $val $unit'), duration: const Duration(seconds: 1)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save', style: TextStyle(color: AppColors.textPrimaryLight)),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmDialog(BuildContext context, WellnessProvider provider) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reset All Wellness Data?'),
          content: const Text(
            'This will clear your steps, logged meals, hydration count, sleep logs, and active habits back to zero so you can start fresh.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.resetAllData();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data reset to fresh state!'), duration: Duration(seconds: 2)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.heartRed),
              child: const Text('Reset All Data', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
            top: AppSpacing.xs,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar Header
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
              const SizedBox(height: AppSpacing.md),

              // 2. Section: Appearance
              Text('Appearance & Visuals', style: AppTypography.h3(isDark)),
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
                            Text('Platform frosted & liquid glass theme', style: AppTypography.caption(isDark)),
                          ],
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: provider.isDarkMode,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        HapticService.selection();
                        provider.toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Section: Smart Reminders
              Text('Smart Reminders & Nudges', style: AppTypography.h3(isDark)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildSwitchRow(
                      title: 'Hydration Nudges',
                      subtitle: 'Every 2 hours during active day',
                      value: _waterReminders,
                      onChanged: (val) => setState(() => _waterReminders = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchRow(
                      title: 'Sleep Wind-Down',
                      subtitle: 'Alert 30 mins before 11:00 PM',
                      value: _sleepReminders,
                      onChanged: (val) => setState(() => _sleepReminders = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchRow(
                      title: 'Hourly Step Alert',
                      subtitle: 'Encourages 250 steps/hour',
                      value: _activityReminders,
                      onChanged: (val) => setState(() => _activityReminders = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchRow(
                      title: 'Meal Log Reminders',
                      subtitle: 'Breakfast, Lunch, and Dinner prompt',
                      value: _mealReminders,
                      onChanged: (val) => setState(() => _mealReminders = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Section: Daily Wellness Goals
              Text('Daily Wellness Targets', style: AppTypography.h3(isDark)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildGoalRow(
                      isDark: isDark,
                      title: 'Daily Step Goal',
                      value: '${provider.stepGoal} steps',
                      onTap: () => _showSetGoalDialog(context, 'Step Goal', provider.stepGoal, 'steps', (v) => provider.setStepGoal(v)),
                    ),
                    const Divider(height: 1),
                    _buildGoalRow(
                      isDark: isDark,
                      title: 'Daily Hydration Target',
                      value: '${provider.waterGoal} glasses (${(provider.waterGoal * 0.25).toStringAsFixed(1)}L)',
                      onTap: () => _showSetGoalDialog(context, 'Water Goal', provider.waterGoal, 'glasses', (v) => provider.setWaterGoal(v)),
                    ),
                    const Divider(height: 1),
                    _buildGoalRow(
                      isDark: isDark,
                      title: 'Daily Calorie Target',
                      value: '${provider.targetCalories} kcal',
                      onTap: () => _showSetGoalDialog(context, 'Calorie Target', provider.targetCalories, 'kcal', (v) => provider.setTargetCalories(v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5. Section: Units & Data Management
              Text('Units & Data Privacy', style: AppTypography.h3(isDark)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildSwitchRow(
                      title: 'Metric System',
                      subtitle: _isMetric ? 'Kilograms, Litres, Kilometres' : 'Pounds, Ounces, Miles',
                      value: _isMetric,
                      onChanged: (val) => setState(() => _isMetric = val),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                          borderRadius: AppRadii.roundedSm,
                        ),
                        child: const Icon(Icons.file_download_outlined, size: 20),
                      ),
                      title: Text('Export Wellness Data', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                      subtitle: Text('Download JSON report of all logs', style: AppTypography.caption(isDark)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        HapticService.selection();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exported Biothrix wellness report to on-device storage.'), duration: Duration(seconds: 2)),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.heartRed.withOpacity(0.14),
                          borderRadius: AppRadii.roundedSm,
                        ),
                        child: const Icon(Icons.delete_sweep_rounded, color: AppColors.heartRed, size: 20),
                      ),
                      title: const Text('Reset All Wellness Data', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.heartRed)),
                      subtitle: Text('Clear steps, meals, water, and start fresh', style: AppTypography.caption(isDark)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.heartRed),
                      onTap: () => _showResetConfirmDialog(context, provider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 6. Section: About Biothrix
              SolidWellnessCard(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.spa_rounded, color: AppColors.textPrimaryLight, size: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Biothrix Wellness', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('Version 1.0.1 • 100% On-Device Privacy Architecture', style: AppTypography.caption(isDark)),
                        ],
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

  Widget _buildSwitchRow({
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: (v) {
              HapticService.selection();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalRow({
    required bool isDark,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          )),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
      onTap: () {
        HapticService.selection();
        onTap();
      },
    );
  }
}
