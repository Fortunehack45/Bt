import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/circular_progress_ring.dart';
import '../../../core/widgets/solid_wellness_card.dart';

/// Weekly progress hero card directly matching Reference Image 1 Screen 1:
/// - Lime green gradient background
/// - "⚡ Daily intake" chip badge
/// - "Your Weekly Progress" title
/// - Dynamic circular progress ring showing completed days and percentage
class WeeklyProgressHeroCard extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int completedDays;
  final VoidCallback? onTap;

  const WeeklyProgressHeroCard({
    super.key,
    required this.progress,
    required this.completedDays,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A382A),
              Color(0xFF1E2820),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD6F57D),
              Color(0xFFE8FBA4),
            ],
          );

    return SolidWellnessCard(
      gradient: gradient,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      border: Border.all(
        color: isDark ? const Color(0xFF3F5440) : const Color(0xFFC7E86B),
        width: 1.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Daily intake" Chip Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF384B39) : Colors.white.withOpacity(0.92),
                    borderRadius: AppRadii.roundedPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Daily intake',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryLight : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Main Title
                Text(
                  'Your Weekly\nProgress',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.2,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Circular Progress Ring showing real user progress
          CircularProgressRing(
            progress: progress.clamp(0.0, 1.0),
            size: 92,
            strokeWidth: 9.5,
            progressColor: AppColors.primaryDark,
            trackColor: isDark ? const Color(0xFF364837) : const Color(0xFFC2E866),
            centerPrimaryText: '$completedDays',
            centerSecondaryText: 'days',
          ),
        ],
      ),
    );
  }
}
