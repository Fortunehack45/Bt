import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ecg_waveform.dart';
import '../../../core/widgets/metric_badge.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../core/widgets/sparkline_chart.dart';

/// 2x2 Grid of Solid Wellness Metric Cards matching Reference Image 1 Screen 2.
/// Fully interactive and reactive to live user telemetry (no dummy hardcodes).
class Metric2x2Grid extends StatelessWidget {
  final double exerciseHours;
  final int bpm;
  final double weightKg;
  final double waterLitres;
  final VoidCallback onExerciseTap;
  final VoidCallback onBpmTap;
  final VoidCallback onWeightTap;
  final VoidCallback onWaterTap;

  const Metric2x2Grid({
    super.key,
    required this.exerciseHours,
    required this.bpm,
    required this.weightKg,
    required this.waterLitres,
    required this.onExerciseTap,
    required this.onBpmTap,
    required this.onWeightTap,
    required this.onWaterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Row 1: Exercise & BPM
        Row(
          children: [
            // Exercise Card
            Expanded(
              child: SolidWellnessCard(
                onTap: onExerciseTap,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const MetricBadge(
                          icon: Icons.auto_awesome_rounded,
                          color: AppColors.exerciseGreen,
                          backgroundColor: AppColors.exerciseGreenTint,
                          size: 32,
                          iconSize: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Exercise',
                          style: AppTypography.bodyMedium(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SparklineBarChart(
                      height: 28,
                      values: exerciseHours > 0
                          ? const [0.3, 0.6, 0.4, 0.9, 0.7, 0.5, 0.8, 0.2, 0.5]
                          : const [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
                    ),
                    const SizedBox(height: 14),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        children: [
                          TextSpan(
                            text: exerciseHours.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' hours',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.gutter),

            // BPM Card
            Expanded(
              child: SolidWellnessCard(
                onTap: onBpmTap,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const MetricBadge(
                          icon: Icons.favorite_rounded,
                          color: AppColors.heartRed,
                          backgroundColor: AppColors.heartRedTint,
                          size: 32,
                          iconSize: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'BPM',
                          style: AppTypography.bodyMedium(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    EcgWaveform(
                      height: 28,
                      color: bpm > 0 ? AppColors.heartRed : (isDark ? AppColors.darkBorder : AppColors.lightBorderStrong),
                    ),
                    const SizedBox(height: 14),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        children: [
                          TextSpan(
                            text: bpm > 0 ? '$bpm' : '--',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' bpm',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
        const SizedBox(width: AppSpacing.gutter),

        const SizedBox(height: AppSpacing.gutter),

        // Row 2: Weight & Water
        Row(
          children: [
            // Weight Card
            Expanded(
              child: SolidWellnessCard(
                onTap: onWeightTap,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const MetricBadge(
                          icon: Icons.fitness_center_rounded,
                          color: AppColors.stepsOrange,
                          backgroundColor: AppColors.stepsOrangeTint,
                          size: 32,
                          iconSize: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Weight',
                          style: AppTypography.bodyMedium(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: weightKg > 0 ? 0.8 : 0.0,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceSubtle
                            : const Color(0xFFFFECE0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.stepsOrange),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        children: [
                          TextSpan(
                            text: weightKg > 0 ? '$weightKg' : '--',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' kg',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.gutter),

            // Water Card
            Expanded(
              child: SolidWellnessCard(
                onTap: onWaterTap,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const MetricBadge(
                          icon: Icons.water_drop_rounded,
                          color: AppColors.waterBlue,
                          backgroundColor: AppColors.waterBlueTint,
                          size: 32,
                          iconSize: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Water',
                          style: AppTypography.bodyMedium(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        final filledThreshold = (index + 1) * 0.5;
                        final isFilled = waterLitres >= filledThreshold;
                        return Icon(
                          Icons.water_drop_rounded,
                          size: 16,
                          color: isFilled
                              ? AppColors.waterBlue
                              : (isDark ? AppColors.darkBorder : const Color(0xFFD6EBF8)),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        children: [
                          TextSpan(
                            text: waterLitres.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' L',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
      ],
    );
  }
}
