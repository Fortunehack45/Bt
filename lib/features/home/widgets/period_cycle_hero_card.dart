import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/circular_progress_ring.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/state/wellness_provider.dart';
import '../../period_tracking/period_tracking_screen.dart';
import '../../period_tracking/widgets/log_period_sheet.dart';

/// Dynamic Hero Card displayed on the Home Dashboard when the user has enabled Period Tracking.
class PeriodCycleHeroCard extends StatelessWidget {
  const PeriodCycleHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final prediction = provider.periodPrediction;
    final activePeriod = provider.activePeriod;

    final cycleLen = provider.averageCycleLength.round();
    final currentDay = provider.currentCycleDay;
    final progress = (currentDay / cycleLen).clamp(0.0, 1.0);

    return SolidWellnessCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        HapticService.selection();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (ctx) => PeriodTrackingScreen(
              onBack: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: prediction.currentPhase.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Menstrual Cycle',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: prediction.currentPhase.color.withOpacity(0.18),
                  borderRadius: AppRadii.roundedPill,
                ),
                child: Text(
                  prediction.currentPhase.displayName,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: prediction.currentPhase.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Visual Row: Circular Progress Ring & Summary Text
          Row(
            children: [
              SizedBox(
                width: 74,
                height: 74,
                child: CircularProgressRing(
                  progress: progress,
                  strokeWidth: 7.0,
                  progressColor: prediction.currentPhase.color,
                  backgroundColor: isDark ? const Color(0xFF26332C) : const Color(0xFFE2EBE5),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '$currentDay',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activePeriod != null
                          ? 'Period Active • Day $currentDay'
                          : (prediction.estimatedNextPeriodDate != null
                              ? 'Next period in ~${prediction.estimatedNextPeriodDate!.difference(DateTime.now()).inDays.abs()} days'
                              : 'Cycle Day $currentDay of $cycleLen'),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      prediction.currentPhase.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(isDark).copyWith(fontSize: 11.5, height: 1.25),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom Bar: Quick Log Button and Details Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  HapticService.selection();
                  showLogPeriodSheet(context, provider);
                },
                icon: const Icon(Icons.water_drop_rounded, size: 14, color: Color(0xFFF43F5E)),
                label: const Text(
                  'Log Flow / Symptoms',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF43F5E)),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor: const Color(0xFFF43F5E).withOpacity(0.12),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
