import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/circular_progress_ring.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../core/widgets/wellness_bottom_sheet.dart';
import '../../../domain/state/wellness_provider.dart';

void showAiWellnessInsightsSheet(BuildContext context, WellnessProvider provider) {
  HapticService.selection();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Compute readiness score from live data
  final int readinessScore = provider.isDemoMode
      ? 94
      : (provider.steps > 0 || provider.waterGlasses > 0 ? 88 : 78);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSheet),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          bool isSyncing = false;

          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.pageMargin,
              right: AppSpacing.pageMargin,
              top: 14.0,
              bottom: MediaQuery.of(sheetContext).padding.bottom + 18.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Grabber
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.16),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Health Pulse',
                              style: AppTypography.h3(isDark).copyWith(fontSize: 18),
                            ),
                            Text(
                              'Daily Biometric Readiness',
                              style: AppTypography.caption(isDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Hero Readiness Gauge Card
                SolidWellnessCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircularProgressRing(
                        progress: readinessScore / 100.0,
                        size: 72,
                        strokeWidth: 8,
                        progressColor: AppColors.primary,
                        backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        child: Text(
                          '$readinessScore%',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTint,
                                    borderRadius: AppRadii.roundedPill,
                                  ),
                                  child: const Text(
                                    'Peak Readiness',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Circadian system primed for optimal cognitive & physical output.',
                              style: AppTypography.bodyMedium(isDark).copyWith(fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Key Telemetry Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Resting Pulse',
                        value: '${provider.bpm > 0 ? provider.bpm : (provider.isDemoMode ? 74 : 70)} bpm',
                        status: 'Optimal',
                        color: AppColors.heartRed,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Hydration',
                        value: '${provider.waterGlasses} / ${provider.waterGoal} gl',
                        status: provider.waterGlasses >= provider.waterGoal ? 'Target met' : 'Balancing',
                        color: AppColors.waterBlue,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // AI Insight Quote Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceSubtle : const Color(0xFFF3F9EE),
                    borderRadius: AppRadii.roundedSm,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AI Recommendation: Metabolism is accelerated today. Maintain steady hydration balance and target outdoor activity before sundown to sync melatonin production.',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            height: 1.4,
                            color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1E2F1E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Instant Health Sync Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: isSyncing
                        ? null
                        : () {
                            HapticService.mediumImpact();
                            Navigator.of(sheetContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Biothrix AI & Sensor Telemetry Synchronized'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    label: const Text(
                      'Sync Health Telemetry',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimaryLight,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildMetricTile({
  required String title,
  required String value,
  required String status,
  required Color color,
  required bool isDark,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated,
      borderRadius: AppRadii.roundedSm,
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.caption(isDark).copyWith(fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          status,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    ),
  );
}
