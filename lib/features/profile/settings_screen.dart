import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../core/widgets/wellness_bottom_sheet.dart';
import '../../domain/state/wellness_provider.dart';
import 'widgets/export_report_sheet.dart';
import '../widgets/widget_studio_screen.dart';
import '../wearables/wearables_hub_screen.dart';
import '../../core/widgets/circular_theme_reveal.dart';

/// Settings Screen organized into distinct sections: Investor Pitch Demo Mode,
/// Appearance, Reminders, Goals, Data Management, and App Info.
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
  bool _periodReminders = true;
  bool _pregnancyReminders = true;
  bool _isMetric = true;

  void _showSetGoalSheet(BuildContext context, String title, int currentVal, String unit, Function(int) onSave) {
    final controller = TextEditingController(text: currentVal.toString());

    WellnessBottomSheet.show<void>(
      context: context,
      title: 'Edit $title',
      subtitle: 'Customize your daily target ($unit)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Target ($unit)',
              hintText: currentVal.toString(),
              suffixText: unit,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final val = int.tryParse(controller.text);
                    if (val != null && val > 0) {
                      HapticService.success();
                      onSave(val);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$title updated to $val $unit'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Save Target', style: TextStyle(color: AppColors.textPrimaryLight)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetConfirmSheet(BuildContext context, WellnessProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    WellnessBottomSheet.show<void>(
      context: context,
      title: 'Reset All Data?',
      subtitle: 'Clear all tracked telemetry and start fresh',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.heartRed.withOpacity(0.08),
              borderRadius: AppRadii.roundedMd,
              border: Border.all(color: AppColors.heartRed.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.heartRed, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This clears steps, hydration, meals, sleep, and active habits back to zero. Your profile name (${provider.userName}) remains safe.',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticService.heavyImpact();
                    provider.resetAllData();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All wellness metrics reset to clean zero-state!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.heartRed),
                  child: const Text('Reset Data', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handlePeriodToggle(BuildContext context, WellnessProvider provider, bool newValue) {
    if (!newValue) {
      provider.setPeriodTrackingEnabled(false);
      return;
    }

    // Guard: Pregnancy and Period tracking are mutually exclusive
    if (provider.isPregnancyTrackingEnabled) {
      WellnessBottomSheet.show<void>(
        context: context,
        title: 'Switch to Period Tracking?',
        subtitle: 'Biological mutual exclusivity',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'True menstruation does not occur during pregnancy. Switching to menstrual cycle tracking will pause your active pregnancy journey while keeping all historical records safely stored.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                height: 1.4,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticService.selection();
                      provider.setPeriodTrackingEnabled(true);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E)),
                    child: const Text('Confirm Switch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      return;
    }

    // Age Guard: Perimenopause / Menopause Intelligence
    if (provider.age >= 48) {
      WellnessBottomSheet.show<void>(
        context: context,
        title: 'Perimenopause & Cycle Health',
        subtitle: 'Age-appropriate biological guidance',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'At age ${provider.age}, many women experience perimenopausal cycle irregularity or have reached natural menopause. How would you describe your cycle status?',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                height: 1.4,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () {
                HapticService.selection();
                provider.setPeriodTrackingEnabled(true);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E)),
              child: const Text('I am still having periods (Track Cycle)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                HapticService.selection();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Noted: Menopause profile active. Period tracking remains off.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('I have reached menopause (Periods stopped)'),
            ),
          ],
        ),
      );
      return;
    }

    provider.setPeriodTrackingEnabled(true);
  }

  void _handlePregnancyToggle(BuildContext context, WellnessProvider provider, bool newValue) {
    if (!newValue) {
      provider.setPregnancyTrackingEnabled(false);
      return;
    }

    // Age Confirmation: For age >= 50 or <= 15
    if (provider.age >= 50 || provider.age <= 15) {
      WellnessBottomSheet.show<void>(
        context: context,
        title: 'Pregnancy Confirmation',
        subtitle: 'Age ${provider.age} verification',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You are enabling pregnancy tracking at age ${provider.age}. Please confirm you wish to initiate a 40-week gestational monitoring session.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                height: 1.4,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticService.celebrate();
                      provider.setPregnancyTrackingEnabled(true);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA855F7)),
                    child: const Text("I'm sure I'm pregnant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      return;
    }

    // Guard: Pregnancy and Period tracking are mutually exclusive
    if (provider.isPeriodTrackingEnabled) {
      WellnessBottomSheet.show<void>(
        context: context,
        title: 'Switch to Pregnancy Mode?',
        subtitle: 'Biological mutual exclusivity',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'True menstrual bleeding naturally ceases during pregnancy. Activating pregnancy mode will pause cycle predictions and activate your gestational growth portal.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                height: 1.4,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticService.celebrate();
                      provider.setPregnancyTrackingEnabled(true);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA855F7)),
                    child: const Text('Confirm Switch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      return;
    }

    provider.setPregnancyTrackingEnabled(true);
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
        child: Column(
          children: [
            // Unified 56pt Standardized Screen Header
            ScreenHeader(
              title: 'Settings',
              subtitle: 'Preferences & Presentation',
              onLeadingTap: widget.onBack,
            ),

            // Scrollable Content
            Expanded(
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
                    // Section 1: Investor Presentation Demo Mode
                    Text('Investor Presentation', style: AppTypography.h3(isDark)),
                    const SizedBox(height: AppSpacing.sm),
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2C3930) : AppColors.primaryTint,
                                      borderRadius: AppRadii.roundedSm,
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: AppColors.primaryDark,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Investor Demo Mode',
                                        style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                                      ),
                                      Text(
                                        provider.isDemoMode ? 'Active (Demo data populated)' : 'Off (Clean zero state)',
                                        style: TextStyle(
                                          fontFamily: AppTypography.fontFamily,
                                          fontSize: 12,
                                          fontWeight: provider.isDemoMode ? FontWeight.w700 : FontWeight.w500,
                                          color: provider.isDemoMode ? AppColors.primaryDark : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: provider.isDemoMode,
                                activeColor: AppColors.primary,
                                onChanged: (val) {
                                  HapticService.selection();
                                  provider.toggleDemoMode(val);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        val
                                            ? 'Investor Demo Mode activated! Full telemetry loaded for ${provider.userName}.'
                                            : 'Investor Demo Mode deactivated. Clean state restored for ${provider.userName}.',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Populates vibrant sample telemetry (steps, meals, habits, sleep, BPM) for pitching to investors. Keeps your personal name intact. Can be switched off at any time.',
                            style: AppTypography.caption(isDark).copyWith(height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 2: Appearance & Visuals
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
                                  Text('Liquid glass ambient theme', style: AppTypography.caption(isDark)),
                                ],
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: provider.isDarkMode,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              HapticService.selection();
                              final themeReveal = ThemeReveal.of(context);
                              final size = MediaQuery.of(context).size;
                              // Top-right corner origin indicated in red reference drawing
                              final origin = Offset(size.width, 0);

                              if (themeReveal != null) {
                                themeReveal.changeTheme(
                                  origin: origin,
                                  onApplyTheme: () => provider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
                                );
                              } else {
                                provider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SolidWellnessCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      onTap: () {
                        HapticService.selection();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => WidgetStudioScreen(onBack: () => Navigator.of(context).pop()),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF323B36) : AppColors.primaryTint,
                                  borderRadius: AppRadii.roundedSm,
                                ),
                                child: const Icon(
                                  Icons.widgets_rounded,
                                  color: AppColors.primaryDark,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Android Home Widgets', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                                  Text('7 responsive widgets & launcher shortcuts', style: AppTypography.caption(isDark)),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SolidWellnessCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      onTap: () {
                        HapticService.selection();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => WearablesHubScreen(onBack: () => Navigator.of(context).pop()),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E2B22) : const Color(0xFFD1FAE5),
                                  borderRadius: AppRadii.roundedSm,
                                ),
                                child: const Icon(
                                  Icons.watch_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Smart Watches & Rings Hub', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                                  Text('Apple Watch, Wear OS, Oura Ring & BLE Cuffs', style: AppTypography.caption(isDark)),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SolidWellnessCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      onTap: () {
                        HapticService.selection();
                        provider.replaySpotlightTour();
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF323B36) : AppColors.primaryTint,
                                  borderRadius: AppRadii.roundedSm,
                                ),
                                child: const Icon(
                                  Icons.explore_rounded,
                                  color: AppColors.primaryDark,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Guided Spotlight Tour', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                                  Text('Replay 5-step clinical system walkthrough', style: AppTypography.caption(isDark)),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 3: Smart Reminders
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
                          if (provider.isPeriodTrackingEnabled) ...[
                            const Divider(height: 1),
                            _buildSwitchRow(
                              title: 'Cycle & Period Alerts',
                              subtitle: 'Phase transitions & symptom logging prompts',
                              value: _periodReminders,
                              onChanged: (val) => setState(() => _periodReminders = val),
                            ),
                          ],
                          if (provider.isPregnancyTrackingEnabled) ...[
                            const Divider(height: 1),
                            _buildSwitchRow(
                              title: 'Prenatal & Wellbeing Reminders',
                              subtitle: 'Upcoming checkups & hydration reminders',
                              value: _pregnancyReminders,
                              onChanged: (val) => setState(() => _pregnancyReminders = val),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 4: Daily Wellness Targets
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
                            onTap: () => _showSetGoalSheet(context, 'Step Goal', provider.stepGoal, 'steps', (v) => provider.setStepGoal(v)),
                          ),
                          const Divider(height: 1),
                          _buildGoalRow(
                            isDark: isDark,
                            title: 'Daily Hydration Target',
                            value: '${provider.waterGoal} glasses (${(provider.waterGoal * 0.25).toStringAsFixed(1)}L)',
                            onTap: () => _showSetGoalSheet(context, 'Water Goal', provider.waterGoal, 'glasses', (v) => provider.setWaterGoal(v)),
                          ),
                          const Divider(height: 1),
                          _buildGoalRow(
                            isDark: isDark,
                            title: 'Daily Calorie Target',
                            value: '${provider.targetCalories} kcal',
                            onTap: () => _showSetGoalSheet(context, 'Calorie Target', provider.targetCalories, 'kcal', (v) => provider.setTargetCalories(v)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section: Reproductive Health Focus
                    Text('Reproductive Health Focus', style: AppTypography.h3(isDark)),
                    const SizedBox(height: AppSpacing.sm),
                    if (!provider.isReproductiveTrackingEligible)
                      SolidWellnessCard(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2C3930) : AppColors.primaryTint,
                                borderRadius: AppRadii.roundedSm,
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                color: AppColors.primaryDark,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tailored for Female Biology',
                                    style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Your profile is set to Male. Menstrual cycle and pregnancy tracking are reserved exclusively for female biological profiles.',
                                    style: AppTypography.caption(isDark).copyWith(fontSize: 12, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      SolidWellnessCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            _buildSwitchRow(
                              title: 'Period Tracking',
                              subtitle: provider.isPeriodTrackingEnabled
                                  ? 'Active • Flow, symptoms & cycle calendar (data preserved)'
                                  : 'Disabled • Historical cycle logs remain safely stored',
                              value: provider.isPeriodTrackingEnabled,
                              onChanged: (val) {
                                HapticService.selection();
                                _handlePeriodToggle(context, provider, val);
                              },
                            ),
                            const Divider(height: 1),
                            _buildSwitchRow(
                              title: 'Pregnancy Tracking',
                              subtitle: provider.isPregnancyTrackingEnabled
                                  ? 'Active • Trimester milestones & maternal wellbeing'
                                  : 'Disabled • Historical pregnancy records remain safely stored',
                              value: provider.isPregnancyTrackingEnabled,
                              onChanged: (val) {
                                HapticService.selection();
                                _handlePregnancyToggle(context, provider, val);
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
                        child: Text(
                          'Note: True menstruation does not occur during pregnancy. Activating one mode automatically pauses the live status of the other while 100% of your historical records remain safely preserved.',
                          style: AppTypography.caption(isDark).copyWith(fontSize: 11.5, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),

                    // Section 5: Units & Data Management
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
                            subtitle: Text('Clinical PDF Dossier & JSON Archive', style: AppTypography.caption(isDark)),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              HapticService.selection();
                              showExportReportSheet(context, provider);
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
                            onTap: () => _showResetConfirmSheet(context, provider),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 6: About Wellnest
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
                                Text('Wellnest Wellness', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                                const SizedBox(height: 2),
                                Text('Version 1.0.2 • 100% On-Device Privacy Architecture', style: AppTypography.caption(isDark)),
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
          ],
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
