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

/// Profile Screen with health score, device sync, and account overview.
class ProfileScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenHydration;
  final VoidCallback onOpenActivity;
  final VoidCallback onOpenSleep;
  final VoidCallback onOpenNutrition;

  const ProfileScreen({
    super.key,
    required this.onOpenSettings,
    required this.onOpenHydration,
    required this.onOpenActivity,
    required this.onOpenSleep,
    required this.onOpenNutrition,
  });

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
            top: AppSpacing.xs,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profile', style: AppTypography.h1(isDark)),
                  PlatformGlassButton(
                    icon: Icons.settings_outlined,
                    size: 42,
                    iconSize: 22,
                    tooltip: 'Settings',
                    onTap: onOpenSettings,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Profile Hero Card
              SolidWellnessCard(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceSubtle : AppColors.primaryTint,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, size: 38, color: AppColors.primaryDark),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(provider.userName, style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                          const SizedBox(height: 2),
                          Text('Active Member • Level 4', style: AppTypography.caption(isDark)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C382A) : AppColors.primaryTint,
                              borderRadius: AppRadii.roundedPill,
                            ),
                            child: const Text(
                              '🌟 Optimal Health Tier',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressRing(
                      progress: 0.88,
                      size: 60,
                      strokeWidth: 6.5,
                      progressColor: AppColors.primary,
                      trackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      centerPrimaryText: '88',
                      centerSecondaryText: 'Score',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Wellness Modules Quick Access
              Text('Wellness Hub', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              _buildHubTile(
                isDark: isDark,
                icon: Icons.water_drop_rounded,
                color: AppColors.waterBlue,
                bgColor: AppColors.waterBlueTint,
                title: 'Hydration Intake',
                subtitle: '${provider.waterGlasses} glasses today',
                onTap: onOpenHydration,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildHubTile(
                isDark: isDark,
                icon: Icons.directions_walk_rounded,
                color: AppColors.stepsOrange,
                bgColor: AppColors.stepsOrangeTint,
                title: 'Activity & Movement',
                subtitle: '${provider.steps} steps • ${(provider.steps * 0.00078).toStringAsFixed(1)} km',
                onTap: onOpenActivity,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildHubTile(
                isDark: isDark,
                icon: Icons.bedtime_rounded,
                color: AppColors.sleepPurple,
                bgColor: AppColors.sleepPurpleTint,
                title: 'Sleep & Recovery',
                subtitle: '${provider.sleepHours} hrs • 88% quality',
                onTap: onOpenSleep,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildHubTile(
                isDark: isDark,
                icon: Icons.restaurant_rounded,
                color: AppColors.nutritionGold,
                bgColor: AppColors.nutritionGoldTint,
                title: 'Nutrition & Meals',
                subtitle: '${provider.calories} kcal logged',
                onTap: onOpenNutrition,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Connected Health Devices
              Text('Connected Devices', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  children: [
                    const Icon(Icons.watch_rounded, color: AppColors.primaryDark, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Smart Wearable Synced', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                          Text('Continuous heart rate, steps, and sleep telemetry', style: AppTypography.caption(isDark)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHubTile({
    required bool isDark,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SolidWellnessCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.18) : bgColor,
              borderRadius: AppRadii.roundedMd,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.caption(isDark)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
        ],
      ),
    );
  }
}
