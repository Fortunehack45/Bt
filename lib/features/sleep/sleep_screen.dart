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

/// Sleep Screen analyzing bedtime consistency, duration, and stages.
class SleepScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SleepScreen({super.key, required this.onBack});

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
                    onTap: onBack,
                  ),
                  Text('Sleep & Recovery', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                  const SizedBox(width: 42),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sleep Hero
              SolidWellnessCard(
                padding: const EdgeInsets.all(22.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Last Night', style: AppTypography.caption(isDark)),
                          const SizedBox(height: 4),
                          Text('${provider.sleepHours} hrs', style: AppTypography.h1(isDark).copyWith(fontSize: 26)),
                          const SizedBox(height: 4),
                          Text('11:15 PM – 7:03 AM', style: AppTypography.bodyMedium(isDark)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.sleepPurpleTint,
                              borderRadius: AppRadii.roundedPill,
                            ),
                            child: const Text(
                              'Optimal Rest Quality',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.sleepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressRing(
                      progress: (provider.sleepHours / 8.0).clamp(0.0, 1.0),
                      size: 96,
                      strokeWidth: 10,
                      progressColor: AppColors.sleepPurple,
                      trackColor: isDark ? const Color(0xFF282838) : AppColors.sleepPurpleTint,
                      centerPrimaryText: '${provider.sleepScore}%',
                      centerSecondaryText: 'Score',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sleep Stages Breakdown
              Text('Sleep Stages', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    _buildStageRow(isDark, 'Deep Sleep', '1h 45m', 0.22, AppColors.sleepPurple),
                    const Divider(height: 24),
                    _buildStageRow(isDark, 'REM Sleep', '2h 10m', 0.28, const Color(0xFF60A5FA)),
                    const Divider(height: 24),
                    _buildStageRow(isDark, 'Light Sleep', '3h 50m', 0.50, const Color(0xFF93C5FD)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageRow(bool isDark, String title, String duration, double ratio, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: AppTypography.bodyMedium(isDark).copyWith(fontWeight: FontWeight.w600)),
        ),
        Text(duration, style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
      ],
    );
  }
}
