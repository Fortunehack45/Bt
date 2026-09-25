import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/solid_wellness_card.dart';

class RecommendationsCarousel extends StatelessWidget {
  const RecommendationsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recommendations = [
      {
        'title': 'Hydration on Track',
        'desc': 'You need only 2 more glasses to hit your optimal hydration goal today.',
        'icon': Icons.water_drop_rounded,
        'color': AppColors.waterBlue,
        'bgColor': AppColors.waterBlueTint,
      },
      {
        'title': 'Evening Recovery Walk',
        'desc': 'A gentle 15-minute walk before dinner will boost your metabolic recovery.',
        'icon': Icons.directions_walk_rounded,
        'color': AppColors.stepsOrange,
        'bgColor': AppColors.stepsOrangeTint,
      },
      {
        'title': 'Mindful Sleep Routine',
        'desc': 'Aim to begin wind-down 30 minutes before your 11:15 PM bedtime.',
        'icon': Icons.bedtime_rounded,
        'color': AppColors.sleepPurple,
        'bgColor': AppColors.sleepPurpleTint,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Daily Recommendations',
            style: AppTypography.h2(isDark).copyWith(fontSize: 18),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = recommendations[index];
              final color = item['color'] as Color;
              final bgColor = item['bgColor'] as Color;

              return SizedBox(
                width: 280,
                child: SolidWellnessCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? color.withOpacity(0.18) : bgColor,
                          borderRadius: AppRadii.roundedMd,
                        ),
                        child: Icon(item['icon'] as IconData, color: color, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['title'] as String,
                              style: AppTypography.h3(isDark).copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item['desc'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(isDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
