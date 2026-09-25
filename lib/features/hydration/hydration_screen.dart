import 'package:flutter/material.dart';
import '../../core/glass/platform_glass_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/circular_progress_ring.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';

/// Hydration Screen with liquid intake visualizer and quick loggers.
class HydrationScreen extends StatelessWidget {
  final VoidCallback onBack;

  const HydrationScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final litres = (provider.waterGlasses * 0.250).toStringAsFixed(2);
    final progress = (provider.waterGlasses / provider.waterGoal.toDouble()).clamp(0.0, 1.5);

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
            top: AppSpacing.sm,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PlatformGlassButton(
                    icon: Icons.chevron_left_rounded,
                    size: 42,
                    iconSize: 24,
                    tooltip: 'Back',
                    onTap: onBack,
                  ),
                  Text('Hydration Tracker', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                  const SizedBox(width: 42),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Main Hydration Hero
              SolidWellnessCard(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                child: Column(
                  children: [
                    CircularProgressRing(
                      progress: progress.clamp(0.0, 1.0),
                      size: 150,
                      strokeWidth: 14,
                      progressColor: AppColors.waterBlue,
                      trackColor: isDark ? const Color(0xFF1E303B) : const Color(0xFFE3F3FC),
                      centerPrimaryText: '$litres',
                      centerSecondaryText: 'Litres',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '${provider.waterGlasses} of ${provider.waterGoal} glasses',
                      style: AppTypography.h2(isDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: 3.0 Litres per day',
                      style: AppTypography.caption(isDark).copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quick Add Buttons
              Text('Quick Add Water', style: AppTypography.h3(isDark)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickButton(
                      context: context,
                      label: '+250 ml',
                      sublabel: '1 glass',
                      onTap: () {
                        HapticService.success();
                        provider.addWaterGlass(1);
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: _buildQuickButton(
                      context: context,
                      label: '+500 ml',
                      sublabel: 'Bottle',
                      onTap: () {
                        HapticService.success();
                        provider.addWaterGlass(2);
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Hydration Benefits Card
              SolidWellnessCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.waterBlueTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wb_sunny_rounded, color: AppColors.waterBlue, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Optimal Hydration', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('Proper hydration stabilizes energy levels and boosts cognitive clarity.', style: AppTypography.caption(isDark)),
                        ],
                      ),
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

  Widget _buildQuickButton({
    required BuildContext context,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return SolidWellnessCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Icon(Icons.local_drink_rounded, color: AppColors.waterBlue, size: 28),
          const SizedBox(height: 6),
          Text(label, style: AppTypography.h3(isDark).copyWith(fontSize: 16)),
          Text(sublabel, style: AppTypography.caption(isDark)),
        ],
      ),
    );
  }
}
