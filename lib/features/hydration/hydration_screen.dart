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

/// Hydration Screen with liquid intake gauge, quick log presets, hourly milestones,
/// and optimal hydration coaching.
class HydrationScreen extends StatefulWidget {
  final VoidCallback onBack;

  const HydrationScreen({super.key, required this.onBack});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  double _customMl = 250.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final litres = (provider.waterGlasses * 0.250).toStringAsFixed(2);
    final targetLitres = (provider.waterGoal * 0.250).toStringAsFixed(1);
    final remainingLitres = ((provider.waterGoal - provider.waterGlasses) * 0.250).clamp(0.0, 10.0).toStringAsFixed(2);
    final progress = (provider.waterGlasses / provider.waterGoal.toDouble()).clamp(0.0, 1.5);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
              // 1. Top Bar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PlatformGlassButton(
                    icon: Icons.chevron_left_rounded,
                    size: 42,
                    iconSize: 24,
                    tooltip: 'Back',
                    onTap: widget.onBack,
                  ),
                  Text('Hydration Tracker', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 22),
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    tooltip: 'Reset Day',
                    onPressed: () {
                      HapticService.lightImpact();
                      provider.resetWater();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hydration count reset for today'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Main Hydration Hero Card
              SolidWellnessCard(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    CircularProgressRing(
                      progress: progress.clamp(0.0, 1.0),
                      size: 140,
                      strokeWidth: 14,
                      progressColor: AppColors.waterBlue,
                      trackColor: isDark ? const Color(0xFF1E303B) : const Color(0xFFE3F3FC),
                      centerPrimaryText: litres,
                      centerSecondaryText: 'Litres',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${provider.waterGlasses} of ${provider.waterGoal} glasses',
                      style: AppTypography.h2(isDark).copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.waterGlasses >= provider.waterGoal
                          ? '🎉 Daily Hydration Goal Reached!'
                          : '$remainingLitres L remaining to reach $targetLitres L goal',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: provider.waterGlasses >= provider.waterGoal ? AppColors.primaryDark : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Section: Quick Add Presets
              Text('Quick Log Presets', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildPresetCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.local_cafe_rounded,
                      amountLabel: '+150 ml',
                      typeLabel: 'Small Cup',
                      onTap: () {
                        HapticService.success();
                        provider.addWaterGlass(1);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildPresetCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.water_drop_rounded,
                      amountLabel: '+250 ml',
                      typeLabel: 'Standard Glass',
                      onTap: () {
                        HapticService.success();
                        provider.addWaterGlass(1);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildPresetCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.water_rounded,
                      amountLabel: '+500 ml',
                      typeLabel: 'Water Bottle',
                      onTap: () {
                        HapticService.success();
                        provider.addWaterGlass(2);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildPresetCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.sports_tennis_rounded,
                      amountLabel: '+750 ml',
                      typeLabel: 'Sports Flask',
                      onTap: () {
                        HapticService.success();
                        provider.addWaterGlass(3);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Section: Custom Amount Logger
              Text('Custom Water Volume', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              SolidWellnessCard(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Custom Amount', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                        Text('${_customMl.toInt()} ml', style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.waterBlue,
                        )),
                      ],
                    ),
                    Slider(
                      value: _customMl,
                      min: 100,
                      max: 1000,
                      divisions: 18,
                      activeColor: AppColors.waterBlue,
                      inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      onChanged: (val) => setState(() => _customMl = val),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticService.success();
                          provider.addWaterAmount(_customMl.toInt());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added ${_customMl.toInt()} ml of water!'), duration: const Duration(seconds: 1)),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text('Log ${_customMl.toInt()} ml', style: const TextStyle(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.waterBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5. Section: Hydration Milestones
              Text('Daily Rhythm Milestones', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              _buildMilestoneRow(isDark, 'Morning Kickstart', '0.75 L by 12:00 PM', provider.waterGlasses >= 3),
              const SizedBox(height: AppSpacing.xs),
              _buildMilestoneRow(isDark, 'Midday Focus', '1.75 L by 4:00 PM', provider.waterGlasses >= 7),
              const SizedBox(height: AppSpacing.xs),
              _buildMilestoneRow(isDark, 'Evening Wind-down', '3.00 L by 8:00 PM', provider.waterGlasses >= 12),
              const SizedBox(height: AppSpacing.lg),

              // 6. Section: Hydration Science Tip
              SolidWellnessCard(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE3F3FC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wb_twilight_rounded, color: AppColors.waterBlue, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Optimal Hydration Routine', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('Drinking 500ml of water right upon waking jumpstarts your metabolism and clears sleep grogginess.', style: AppTypography.caption(isDark)),
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

  Widget _buildPresetCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String amountLabel,
    required String typeLabel,
    required VoidCallback onTap,
  }) {
    return SolidWellnessCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.waterBlue.withOpacity(0.18) : const Color(0xFFE3F3FC),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.waterBlue, size: 24),
          ),
          const SizedBox(height: 10),
          Text(amountLabel, style: AppTypography.h3(isDark).copyWith(fontSize: 16)),
          const SizedBox(height: 2),
          Text(typeLabel, style: AppTypography.caption(isDark)),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow(bool isDark, String title, String subtitle, bool isCompleted) {
    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isCompleted ? AppColors.primary : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
                Text(subtitle, style: AppTypography.caption(isDark)),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C382A) : AppColors.primaryTint,
                borderRadius: AppRadii.roundedPill,
              ),
              child: const Text('Met', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
            ),
        ],
      ),
    );
  }
}
