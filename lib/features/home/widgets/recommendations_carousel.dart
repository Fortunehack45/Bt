import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/solid_wellness_card.dart';

class RecommendationItem {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const RecommendationItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class RecommendationsCarousel extends StatelessWidget {
  const RecommendationsCarousel({super.key});

  static const List<RecommendationItem> items = [
    RecommendationItem(
      title: 'Hydration Habit',
      desc: 'Drinking your first 250ml upon waking boosts metabolic focus.',
      icon: Icons.water_drop_rounded,
      color: AppColors.waterBlue,
      bgColor: AppColors.waterBlueTint,
    ),
    RecommendationItem(
      title: 'Daily Movement',
      desc: 'A gentle 15-minute walk helps activate daily calorie burn.',
      icon: Icons.directions_walk_rounded,
      color: AppColors.stepsOrange,
      bgColor: AppColors.stepsOrangeTint,
    ),
    RecommendationItem(
      title: 'Mindful Sleep',
      desc: 'Wind-down 30 minutes before bedtime supports optimal deep sleep.',
      icon: Icons.bedtime_rounded,
      color: AppColors.sleepPurple,
      bgColor: AppColors.sleepPurpleTint,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = items[index];

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
                          color: isDark ? item.color.withOpacity(0.18) : item.bgColor,
                          borderRadius: AppRadii.roundedMd,
                        ),
                        child: Icon(item.icon, color: item.color, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.h3(isDark).copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.desc,
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
