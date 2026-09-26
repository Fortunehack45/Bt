import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/circular_progress_ring.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/state/wellness_provider.dart';
import '../../pregnancy_tracking/pregnancy_tracking_screen.dart';
import '../../pregnancy_tracking/widgets/log_pregnancy_wellness_sheet.dart';
import '../../pregnancy_tracking/widgets/pregnancy_setup_sheet.dart';

/// Dynamic Hero Card displayed on the Home Dashboard when the user has enabled Pregnancy Tracking.
class PregnancyJourneyHeroCard extends StatelessWidget {
  const PregnancyJourneyHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final preg = provider.pregnancyData;

    return SolidWellnessCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        HapticService.selection();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (ctx) => PregnancyTrackingScreen(
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFA855F7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pregnancy Journey',
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
                  color: const Color(0xFFA855F7).withOpacity(0.18),
                  borderRadius: AppRadii.roundedPill,
                ),
                child: Text(
                  preg != null ? preg.trimesterLabel : 'Setup Needed',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFA855F7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (preg == null) ...[
            // Prompt to configure timeline
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7).withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Color(0xFFA855F7), size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Your Pregnancy Timeline',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Enter last period or due date to see gestational milestones.',
                        style: AppTypography.caption(isDark).copyWith(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                HapticService.selection();
                showPregnancySetupSheet(context, provider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
              ),
              child: const Text('Configure Dates'),
            ),
          ] else ...[
            // Configured Main Visual Row
            Row(
              children: [
                SizedBox(
                  width: 74,
                  height: 74,
                  child: CircularProgressRing(
                    progress: preg.progressRatio,
                    strokeWidth: 7.0,
                    progressColor: const Color(0xFFA855F7),
                    backgroundColor: isDark ? const Color(0xFF26332C) : const Color(0xFFE2EBE5),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Wk',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          '${preg.currentWeek}',
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
                        'Week ${preg.currentWeek}, Day ${preg.currentDayOfCurrentWeek}',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Baby is the ${preg.babySizeComparison}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption(isDark).copyWith(fontSize: 11.5, height: 1.25),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${preg.daysUntilDueDate > 0 ? '${preg.daysUntilDueDate} days' : 'Due now'} until due date',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA855F7),
                        ),
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
                    showLogPregnancyWellnessSheet(context, provider);
                  },
                  icon: const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFA855F7)),
                  label: const Text(
                    'Log Wellbeing',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFA855F7)),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    backgroundColor: const Color(0xFFA855F7).withOpacity(0.12),
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
        ],
      ),
    );
  }
}
