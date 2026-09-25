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

/// Nutrition Screen tracking meals, daily calories, and macronutrient distribution.
class NutritionScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAddMeal;

  const NutritionScreen({
    super.key,
    required this.onBack,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final calorieRatio = (provider.calories / provider.targetCalories.toDouble()).clamp(0.0, 1.0);

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
                  Text('Nutrition & Meals', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                  ElevatedButton(
                    onPressed: onAddMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimaryLight,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16),
                        SizedBox(width: 4),
                        Text('Log', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Calorie Balance Hero
              SolidWellnessCard(
                padding: const EdgeInsets.all(22.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Energy Intake', style: AppTypography.caption(isDark)),
                          const SizedBox(height: 4),
                          Text('${provider.calories} kcal', style: AppTypography.h1(isDark).copyWith(fontSize: 26)),
                          const SizedBox(height: 4),
                          Text('Target: ${provider.targetCalories} kcal', style: AppTypography.bodyMedium(isDark)),
                          const SizedBox(height: 8),
                          Text('${provider.targetCalories - provider.calories} kcal remaining', style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          )),
                        ],
                      ),
                    ),
                    CircularProgressRing(
                      progress: calorieRatio,
                      size: 96,
                      strokeWidth: 10,
                      progressColor: AppColors.nutritionGold,
                      trackColor: isDark ? const Color(0xFF383120) : AppColors.nutritionGoldTint,
                      centerPrimaryText: '${(calorieRatio * 100).toInt()}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Macro Distribution
              Row(
                children: [
                  Expanded(child: _buildMacroCard(isDark, 'Carbs', '142g', '45%', AppColors.primary)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _buildMacroCard(isDark, 'Protein', '94g', '30%', AppColors.heartRed)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _buildMacroCard(isDark, 'Fats', '48g', '25%', AppColors.nutritionGold)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Meals History
              Text('Logged Meals', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              ...provider.meals.map((meal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SolidWellnessCard(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.nutritionGoldTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.restaurant_rounded, color: AppColors.nutritionGold, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meal.name, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                              const SizedBox(height: 2),
                              Text('${meal.mealType} • ${meal.description}', style: AppTypography.caption(isDark)),
                            ],
                          ),
                        ),
                        Text('${meal.calories} kcal', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroCard(bool isDark, String label, String grams, String percent, Color color) {
    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTypography.caption(isDark)),
          const SizedBox(height: 2),
          Text(grams, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          Text(percent, style: AppTypography.caption(isDark)),
        ],
      ),
    );
  }
}
