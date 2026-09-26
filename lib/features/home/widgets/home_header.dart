import 'package:flutter/material.dart';
import '../../../core/constants/tour_target_keys.dart';
import '../../../core/glass/platform_glass_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/time_of_day_helper.dart';
import '../../../domain/state/wellness_provider.dart';

/// Top header of the Home screen matching Reference Image 1 Screen 1:
/// - User avatar with presence badge
/// - "Good morning!" greeting
/// - User name "Sajibur Rahman"
/// - Floating glass action buttons (Calendar & Refresh)
class HomeHeader extends StatelessWidget {
  final VoidCallback onCalendarTap;
  final VoidCallback onRefreshTap;
  final VoidCallback? onProfileTap;

  const HomeHeader({
    super.key,
    required this.onCalendarTap,
    required this.onRefreshTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

    return Row(
      children: [
        // User Profile Avatar (Tapping navigates directly to Profile screen)
        GestureDetector(
          key: TourTargetKeys.avatarKey,
          behavior: HitTestBehavior.opaque,
          onTap: () {
            onProfileTap?.call();
          },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSubtle : AppColors.primaryTint,
              borderRadius: AppRadii.roundedPill,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primaryDark,
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting and User Name (Tapping also navigates to Profile screen)
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onProfileTap?.call();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TimeOfDayHelper.getGreeting(),
                  style: AppTypography.caption(isDark).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.userName,
                  style: AppTypography.h2(isDark).copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ),

        // Floating Glass Utility Buttons
        PlatformGlassButton(
          icon: Icons.calendar_today_outlined,
          size: 40,
          iconSize: 18,
          tooltip: 'Calendar',
          onTap: onCalendarTap,
        ),
        const SizedBox(width: 8),
        PlatformGlassButton(
          icon: Icons.auto_awesome_rounded,
          size: 40,
          iconSize: 19,
          tooltip: 'AI Health Pulse',
          onTap: onRefreshTap,
        ),
      ],
    );
  }
}
