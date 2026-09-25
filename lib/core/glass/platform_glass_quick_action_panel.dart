import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/haptic_service.dart';

/// The polished quick-action interface triggered by the central [+] button.
/// Supports logging Water, Activity, Meal, Sleep, Habit, and Custom Metrics.
class PlatformGlassQuickActionPanel extends StatelessWidget {
  final VoidCallback onAddWater;
  final VoidCallback onLogActivity;
  final VoidCallback onAddMeal;
  final VoidCallback onLogSleep;
  final VoidCallback onAddHabit;

  const PlatformGlassQuickActionPanel({
    super.key,
    required this.onAddWater,
    required this.onLogActivity,
    required this.onAddMeal,
    required this.onLogSleep,
    required this.onAddHabit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Log',
                style: AppTypography.h1(isDark),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Record your wellness activity for today',
            style: AppTypography.bodyMedium(isDark),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action Grid
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context: context,
                  icon: Icons.water_drop_rounded,
                  color: AppColors.waterBlue,
                  bgColor: AppColors.waterBlueTint,
                  title: 'Add Water',
                  subtitle: '+250 ml glass',
                  onTap: () {
                    Navigator.of(context).pop();
                    onAddWater();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: _buildActionTile(
                  context: context,
                  icon: Icons.directions_run_rounded,
                  color: AppColors.exerciseGreen,
                  bgColor: AppColors.exerciseGreenTint,
                  title: 'Log Activity',
                  subtitle: 'Walk, run, workout',
                  onTap: () {
                    Navigator.of(context).pop();
                    onLogActivity();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gutter),

          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context: context,
                  icon: Icons.restaurant_rounded,
                  color: AppColors.nutritionGold,
                  bgColor: AppColors.nutritionGoldTint,
                  title: 'Add Meal',
                  subtitle: 'Breakfast, lunch, kcal',
                  onTap: () {
                    Navigator.of(context).pop();
                    onAddMeal();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: _buildActionTile(
                  context: context,
                  icon: Icons.bedtime_rounded,
                  color: AppColors.sleepPurple,
                  bgColor: AppColors.sleepPurpleTint,
                  title: 'Log Sleep',
                  subtitle: 'Duration & rest',
                  onTap: () {
                    Navigator.of(context).pop();
                    onLogSleep();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gutter),

          // Habit Builder Tile
          _buildActionTile(
            context: context,
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.primaryDark,
            bgColor: AppColors.primaryTint,
            title: 'Add New Habit',
            subtitle: 'Build consistent daily wellness routines',
            onTap: () {
              Navigator.of(context).pop();
              onAddHabit();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurfaceSubtle : Colors.white.withOpacity(0.85),
      borderRadius: AppRadii.roundedCard,
      child: InkWell(
        onTap: () {
          HapticService.selection();
          onTap();
        },
        borderRadius: AppRadii.roundedCard,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.roundedCard,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? color.withOpacity(0.18) : bgColor,
                  borderRadius: AppRadii.roundedMd,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h3(isDark).copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
