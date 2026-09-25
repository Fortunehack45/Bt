import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';
import 'widgets/log_weight_sheet.dart';

/// Dedicated Body Weight & Composition Tracking Hub.
class WeightScreen extends StatelessWidget {
  final VoidCallback onBack;

  const WeightScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final weight = provider.weightKg > 0 ? provider.weightKg : 70.0;
    const targetWeight = 68.0;
    final delta = weight - targetWeight;

    // Estimate BMI for average 1.75m height
    final bmi = weight / (1.75 * 1.75);
    String bmiCategory = 'Healthy Weight';
    Color bmiColor = const Color(0xFF10B981);
    if (bmi < 18.5) {
      bmiCategory = 'Underweight';
      bmiColor = AppColors.waterBlue;
    } else if (bmi >= 25.0 && bmi < 30.0) {
      bmiCategory = 'Overweight';
      bmiColor = const Color(0xFFF59E0B);
    } else if (bmi >= 30.0) {
      bmiCategory = 'Obesity Range';
      bmiColor = AppColors.heartRed;
    }

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
              // 1. Unified Standardized Header
              ScreenHeader(
                title: 'Weight & Body Mass',
                subtitle: 'Body Composition Tracker',
                onBack: onBack,
                trailing: ElevatedButton.icon(
                  onPressed: () => showLogWeightSheet(context, provider),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Log', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Weight Hero Card
              SolidWellnessCard(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.monitor_weight_rounded,
                        color: Color(0xFFF59E0B),
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 50,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF59E0B),
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      delta > 0
                          ? '+${delta.toStringAsFixed(1)} kg to target ($targetWeight kg)'
                          : 'Target weight reached! 🎉',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: bmiColor.withOpacity(0.18),
                        borderRadius: AppRadii.roundedPill,
                      ),
                      child: Text(
                        'Estimated BMI: ${bmi.toStringAsFixed(1)} • $bmiCategory',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: bmiColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Body Health Insights
              Text('Health Benchmarks', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              _buildInsightCard('Weekly Trend', 'Stable (±0.2 kg)', Icons.trending_flat_rounded, AppColors.waterBlue, isDark),
              const SizedBox(height: 8),
              _buildInsightCard('Estimated Lean Mass', '78.5%', Icons.accessibility_new_rounded, const Color(0xFF10B981), isDark),
              const SizedBox(height: 8),
              _buildInsightCard('Hydration Balance', 'Healthy cellular fluid', Icons.water_drop_rounded, AppColors.waterBlue, isDark),
              const SizedBox(height: AppSpacing.lg),

              // 4. Quick Action Card
              SolidWellnessCard(
                padding: const EdgeInsets.all(18.0),
                onTap: () => showLogWeightSheet(context, provider),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: const Icon(Icons.scale_rounded, color: Color(0xFFF59E0B), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Record Weigh-In', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                            Text('Precision decimal measurement', style: AppTypography.caption(isDark)),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String val, IconData icon, Color color, bool isDark) {
    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Text(title, style: AppTypography.bodyLarge(isDark).copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          Text(
            val,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
