import 'package:flutter/material.dart';
import '../../core/glass/platform_glass_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/circular_progress_ring.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../core/widgets/wellness_bottom_sheet.dart';
import '../../domain/state/wellness_provider.dart';
import '../widgets/widget_studio_screen.dart';
import 'personal_profile_screen.dart';

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

  void _showEditNameSheet(BuildContext context, WellnessProvider provider) {
    final controller = TextEditingController(text: provider.userName);

    WellnessBottomSheet.show<void>(
      context: context,
      title: 'Edit Your Name',
      subtitle: 'Your name appears on greeting headers and reports',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your name',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      HapticService.success();
                      provider.setUserName(newName);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Name updated to "$newName"!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Save Name', style: TextStyle(color: AppColors.textPrimaryLight)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: false,
        child: Column(
          children: [
            // Standardized 56pt Header
            ScreenHeader(
              title: 'Profile',
              subtitle: 'Account & Biometric Overview',
              trailing: PlatformGlassButton(
                icon: Icons.settings_outlined,
                size: 42,
                iconSize: 22,
                tooltip: 'Settings',
                onTap: onOpenSettings,
              ),
            ),

            // Scrollable Content
            Expanded(
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
                    // Profile Hero Card
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(20.0),
                      onTap: () {
                        HapticService.selection();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => PersonalProfileScreen(onBack: () => Navigator.of(context).pop()),
                          ),
                        );
                      },
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
                                GestureDetector(
                                  onTap: () => _showEditNameSheet(context, provider),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          provider.userName,
                                          style: AppTypography.h2(isDark).copyWith(fontSize: 18),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.edit_rounded, size: 16, color: AppColors.primaryDark),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  provider.isDemoMode ? 'Demo Pitch Active' : 'Active Member',
                                  style: AppTypography.caption(isDark),
                                ),
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
                      icon: Icons.badge_outlined,
                      color: AppColors.primaryDark,
                      bgColor: AppColors.primaryTint,
                      title: 'Personal Biometrics & BMI',
                      subtitle: 'Age ${provider.age} • ${provider.bmi} BMI (${provider.bmiCategory})',
                      onTap: () {
                        HapticService.selection();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => PersonalProfileScreen(onBack: () => Navigator.of(context).pop()),
                          ),
                        );
                      },
                    ),
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
                      title: 'Sleep Architecture',
                      subtitle: '${provider.sleepHours} hrs • Score ${provider.sleepScore}%',
                      onTap: onOpenSleep,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildHubTile(
                      isDark: isDark,
                      icon: Icons.restaurant_rounded,
                      color: AppColors.nutritionGold,
                      bgColor: AppColors.nutritionGoldTint,
                      title: 'Nutrition & Energy',
                      subtitle: '${provider.calories} kcal of ${provider.targetCalories} target',
                      onTap: onOpenNutrition,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Devices & Hardware Sync
                    Text('Connected Hardware', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                    const SizedBox(height: AppSpacing.sm),
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                              borderRadius: AppRadii.roundedMd,
                            ),
                            child: const Icon(Icons.watch_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Apple Health / Health Connect', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                                const SizedBox(height: 2),
                                Text('Background telemetry synchronized', style: AppTypography.caption(isDark)),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Android Home Widgets & Studio
                    Text('Android System & Launcher', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                    const SizedBox(height: AppSpacing.sm),
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(16.0),
                      onTap: () {
                        HapticService.selection();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => WidgetStudioScreen(onBack: () => Navigator.of(context).pop()),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.18),
                              borderRadius: AppRadii.roundedMd,
                            ),
                            child: const Icon(Icons.widgets_rounded, color: AppColors.primaryDark, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Widget Studio & Shortcuts', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                                const SizedBox(height: 2),
                                Text('7 responsive Android widgets & launcher actions', style: AppTypography.caption(isDark)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
