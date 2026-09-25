import 'package:flutter/material.dart';
import '../../core/glass/platform_glass_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/circular_progress_ring.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';

/// Sleep Screen with sleep architecture breakdown, circadian rhythm schedule,
/// and recovery tracking.
class SleepScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SleepScreen({super.key, required this.onBack});

  void _showLogSleepDialog(BuildContext context, WellnessProvider provider) {
    final controller = TextEditingController(
      text: provider.sleepHours > 0 ? provider.sleepHours.toString() : '7.5',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Log Last Night Sleep'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Hours Slept',
                  hintText: 'e.g. 7.5',
                ),
              ),
              const SizedBox(height: 8),
              const Text('Typical restorative sleep is between 7.0 and 9.0 hours.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final hrs = double.tryParse(controller.text) ?? 7.0;
                provider.logSleep(hrs);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged $hrs hours of sleep!'), duration: const Duration(seconds: 1)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.sleepPurple),
              child: const Text('Save Sleep', style: TextStyle(color: Colors.white)),
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
    final hours = provider.sleepHours;
    final sleepScore = provider.sleepScore;

    // Dynamically calculate sleep stages from logged hours (or 0 if unlogged)
    final deepHours = (hours * 0.22).toStringAsFixed(1);
    final remHours = (hours * 0.28).toStringAsFixed(1);
    final lightHours = (hours * 0.50).toStringAsFixed(1);

    String statusLabel = 'No Sleep Logged';
    Color statusColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    if (hours >= 7.5) {
      statusLabel = 'Optimal Rest Quality';
      statusColor = AppColors.primaryDark;
    } else if (hours >= 6.0) {
      statusLabel = 'Moderate Rest';
      statusColor = AppColors.nutritionGold;
    } else if (hours > 0) {
      statusLabel = 'Sleep Debt Detected';
      statusColor = AppColors.heartRed;
    }

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
                    onTap: onBack,
                  ),
                  Text('Sleep & Recovery', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => _showLogSleepDialog(context, provider),
                    icon: const Icon(Icons.bedtime_rounded, size: 16),
                    label: const Text('Log', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sleepPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Sleep Hero Card
              SolidWellnessCard(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LAST NIGHT DURATION', style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          )),
                          const SizedBox(height: 6),
                          Text('${hours.toStringAsFixed(1)} hrs', style: AppTypography.displayMedium(isDark).copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          )),
                          const SizedBox(height: 4),
                          Text(hours > 0 ? '11:15 PM – 7:03 AM' : 'Tap "+ Log" to record sleep', style: AppTypography.bodyMedium(isDark)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.sleepPurple.withOpacity(0.2) : AppColors.sleepPurpleTint,
                              borderRadius: AppRadii.roundedPill,
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressRing(
                      progress: (hours / 8.0).clamp(0.0, 1.0),
                      size: 96,
                      strokeWidth: 10,
                      progressColor: AppColors.sleepPurple,
                      trackColor: isDark ? const Color(0xFF282838) : AppColors.sleepPurpleTint,
                      centerPrimaryText: '$sleepScore%',
                      centerSecondaryText: 'Quality',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Section: Sleep Architecture (Stages)
              Text('Sleep Architecture (Stages)', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    _buildStageRow(isDark, 'Deep Sleep', '$deepHours hrs (22%)', 'Cellular repair & physical recovery', const Color(0xFF6B58F8), 0.22),
                    const Divider(height: 24),
                    _buildStageRow(isDark, 'REM Sleep', '$remHours hrs (28%)', 'Memory consolidation & emotional processing', const Color(0xFF38BDF8), 0.28),
                    const Divider(height: 24),
                    _buildStageRow(isDark, 'Light Sleep', '$lightHours hrs (50%)', 'Mental reset & motor skills enhancement', const Color(0xFF818CF8), 0.50),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Section: Circadian Rhythm Schedule
              Text('Circadian Rhythm Schedule', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildRhythmCard(
                      isDark: isDark,
                      icon: Icons.nightlight_round,
                      iconColor: AppColors.sleepPurple,
                      title: 'Target Bedtime',
                      time: '11:00 PM',
                      subtitle: 'Ideal for 8h target',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildRhythmCard(
                      isDark: isDark,
                      icon: Icons.alarm_rounded,
                      iconColor: AppColors.nutritionGold,
                      title: 'Natural Wake',
                      time: '7:00 AM',
                      subtitle: 'Optimal cycle end',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5. Section: Restorative Hygiene Coaching
              SolidWellnessCard(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.sleepPurple.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_moon_rounded, color: AppColors.sleepPurple, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Wind-down Protocol', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('A dark, quiet room kept at 18°C (65°F) triggers natural melatonin synthesis for deeper slow-wave sleep.', style: AppTypography.caption(isDark)),
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

  Widget _buildStageRow(bool isDark, String title, String duration, String desc, Color color, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(title, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
              ],
            ),
            Text(duration, style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            )),
          ],
        ),
        const SizedBox(height: 4),
        Text(desc, style: AppTypography.caption(isDark)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 4,
            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildRhythmCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required String subtitle,
  }) {
    return SolidWellnessCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.caption(isDark)),
          const SizedBox(height: 2),
          Text(time, style: AppTypography.h3(isDark).copyWith(fontSize: 17)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.caption(isDark).copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
