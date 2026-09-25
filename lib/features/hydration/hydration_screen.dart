import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/circular_progress_ring.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';
import 'widgets/log_water_sheet.dart';

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
        child: Column(
          children: [
            // Standardized 56pt Header
            ScreenHeader(
              title: 'Hydration Tracker',
              subtitle: 'Daily Water Balance',
              onLeadingTap: widget.onBack,
              trailing: ElevatedButton.icon(
                onPressed: () => showLogWaterSheet(context, provider),
                icon: const Icon(Icons.water_drop_rounded, size: 16),
                label: const Text('Log', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.waterBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
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
                    // 1. Main Hydration Hero Card (Spans full width)
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
                              color: provider.waterGlasses >= provider.waterGoal
                                  ? AppColors.primaryDark
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 2. Section: Quick Add Presets
                    Text('Quick Log Presets', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Tap any container to customize amount and drink type', style: AppTypography.caption(isDark)),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPresetCard(
                            context: context,
                            isDark: isDark,
                            icon: Icons.local_cafe_rounded,
                            amountLabel: '150 ml',
                            typeLabel: 'Small Cup',
                            onTap: () {
                              showLogWaterSheet(context, provider, initialMl: 150);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildPresetCard(
                            context: context,
                            isDark: isDark,
                            icon: Icons.water_drop_rounded,
                            amountLabel: '250 ml',
                            typeLabel: 'Standard Glass',
                            onTap: () {
                              showLogWaterSheet(context, provider, initialMl: 250);
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
                            amountLabel: '500 ml',
                            typeLabel: 'Water Bottle',
                            onTap: () {
                              showLogWaterSheet(context, provider, initialMl: 500);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildPresetCard(
                            context: context,
                            isDark: isDark,
                            icon: Icons.sports_tennis_rounded,
                            amountLabel: '750 ml',
                            typeLabel: 'Sports Flask',
                            onTap: () {
                              showLogWaterSheet(context, provider, initialMl: 750);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 3. Section: Custom Amount Slider
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
                              Text('Adjust Exact Volume', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                              Text('${_customMl.toInt()} ml', style: const TextStyle(
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
                            onChanged: (val) {
                              HapticService.selection();
                              setState(() => _customMl = val);
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticService.success();
                                provider.addWaterAmount(_customMl.toInt());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${_customMl.toInt()} ml to daily hydration!'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: Text('Log ${_customMl.toInt()} ml', style: const TextStyle(fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.waterBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
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
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 14.0),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.waterBlue.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.waterBlue, size: 24),
          ),
          const SizedBox(height: 10),
          Text(amountLabel, style: AppTypography.h3(isDark).copyWith(fontSize: 16, color: AppColors.waterBlue)),
          const SizedBox(height: 2),
          Text(typeLabel, style: AppTypography.caption(isDark).copyWith(fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSubtle : AppColors.waterBlueTint,
              borderRadius: AppRadii.roundedPill,
            ),
            child: const Text('Configure', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.waterBlue)),
          ),
        ],
      ),
    );
  }
}
