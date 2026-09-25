import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/circular_progress_ring.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';
import 'widgets/log_sleep_sheet.dart';

/// Sleep Screen with sleep architecture breakdown, circadian rhythm schedule,
/// and recovery tracking.
class SleepScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SleepScreen({super.key, required this.onBack});

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
        child: Column(
          children: [
            // Standardized 56pt Header
            ScreenHeader(
              title: 'Sleep & Recovery',
              subtitle: 'Circadian Rest & Quality',
              onBack: onBack,
              trailing: ElevatedButton.icon(
                onPressed: () => showLogSleepSheet(context, provider),
                icon: const Icon(Icons.bedtime_rounded, size: 16),
                label: const Text('Log', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sleepPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
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
                    // 1. Sleep Hero Card
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('LAST NIGHT REST', style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                )),
                                const SizedBox(height: 6),
                                Text(
                                  hours > 0 ? '$hours hrs' : '0.0 hrs',
                                  style: AppTypography.displayMedium(isDark).copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Target: 8.0 hrs restorative sleep', style: AppTypography.caption(isDark)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.14),
                                    borderRadius: AppRadii.roundedPill,
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircularProgressRing(
                            progress: sleepScore > 0 ? (sleepScore / 100.0) : 0.0,
                            size: 78,
                            strokeWidth: 8.5,
                            progressColor: AppColors.sleepPurple,
                            trackColor: isDark ? AppColors.darkBorder : AppColors.sleepPurpleTint,
                            centerPrimaryText: '$sleepScore%',
                            centerSecondaryText: 'Score',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 2. Section: Circadian Rhythm Target Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildRhythmCard(
                            isDark: isDark,
                            icon: Icons.nightlight_round,
                            iconColor: AppColors.sleepPurple,
                            title: 'Bedtime Window',
                            time: '10:45 PM',
                            subtitle: 'Consistent schedule',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildRhythmCard(
                            isDark: isDark,
                            icon: Icons.wb_sunny_rounded,
                            iconColor: AppColors.nutritionGold,
                            title: 'Wake-Up Window',
                            time: '06:45 AM',
                            subtitle: 'Light alarm optimal',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 3. Section: Sleep Architecture Stages
                    Text('Sleep Stages & Architecture', style: AppTypography.h3(isDark)),
                    const SizedBox(height: AppSpacing.sm),
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          _buildStageRow(
                            isDark,
                            'Deep (Slow Wave)',
                            '$deepHours hrs',
                            'Physical repair, cellular renewal, growth hormone surge',
                            AppColors.sleepPurple,
                            hours > 0 ? 0.22 : 0.0,
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                          _buildStageRow(
                            isDark,
                            'REM (Rapid Eye Movement)',
                            '$remHours hrs',
                            'Cognitive restoration, emotional processing & memory consolidation',
                            AppColors.waterBlue,
                            hours > 0 ? 0.28 : 0.0,
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                          _buildStageRow(
                            isDark,
                            'Light Sleep',
                            '$lightHours hrs',
                            'Heart rate decrescendo, transitional maintenance',
                            AppColors.primary,
                            hours > 0 ? 0.50 : 0.0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 4. Section: Restorative Hygiene Coaching
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
          ],
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
