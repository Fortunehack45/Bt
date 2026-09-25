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

/// Comprehensive Nutrition Screen with dedicated meal sections, macro distribution,
/// and full meal management.
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
    final remainingKcal = (provider.targetCalories - provider.calories).clamp(0, 99999);

    // Group meals by meal type
    final breakfastMeals = provider.meals.where((m) => m.mealType.toLowerCase().contains('breakfast')).toList();
    final lunchMeals = provider.meals.where((m) => m.mealType.toLowerCase().contains('lunch')).toList();
    final dinnerMeals = provider.meals.where((m) => m.mealType.toLowerCase().contains('dinner')).toList();
    final snackMeals = provider.meals.where((m) => m.mealType.toLowerCase().contains('snack')).toList();

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
                    onTap: onBack,
                  ),
                  Text('Nutrition & Meals', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: onAddMeal,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Log Meal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimaryLight,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Calorie Energy Intake Hero Card
              SolidWellnessCard(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DAILY ENERGY INTAKE', style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          )),
                          const SizedBox(height: 6),
                          Text('${provider.calories} kcal', style: AppTypography.displayMedium(isDark).copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          )),
                          const SizedBox(height: 4),
                          Text('Target: ${provider.targetCalories} kcal', style: AppTypography.bodyMedium(isDark)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C382A) : AppColors.primaryTint,
                              borderRadius: AppRadii.roundedPill,
                            ),
                            child: Text(
                              '$remainingKcal kcal remaining',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
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
                      centerSecondaryText: 'Goal',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Macronutrient Targets
              Row(
                children: [
                  Expanded(child: _buildMacroCard(isDark, 'Carbohydrates', '142g', '45%', AppColors.primary, 0.45)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _buildMacroCard(isDark, 'Protein', '94g', '30%', AppColors.heartRed, 0.30)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _buildMacroCard(isDark, 'Healthy Fats', '48g', '25%', AppColors.nutritionGold, 0.25)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Section: Breakfast
              _buildMealSection(
                context: context,
                isDark: isDark,
                provider: provider,
                title: 'Breakfast',
                icon: Icons.wb_sunny_rounded,
                iconColor: AppColors.nutritionGold,
                bgColor: AppColors.nutritionGoldTint,
                targetKcalHint: 'Target: ~500 kcal',
                meals: breakfastMeals,
                onAdd: onAddMeal,
              ),
              const SizedBox(height: AppSpacing.md),

              // 5. Section: Lunch
              _buildMealSection(
                context: context,
                isDark: isDark,
                provider: provider,
                title: 'Lunch',
                icon: Icons.lunch_dining_rounded,
                iconColor: AppColors.primaryDark,
                bgColor: AppColors.primaryTint,
                targetKcalHint: 'Target: ~700 kcal',
                meals: lunchMeals,
                onAdd: onAddMeal,
              ),
              const SizedBox(height: AppSpacing.md),

              // 6. Section: Dinner
              _buildMealSection(
                context: context,
                isDark: isDark,
                provider: provider,
                title: 'Dinner',
                icon: Icons.dinner_dining_rounded,
                iconColor: AppColors.waterBlue,
                bgColor: const Color(0xFFE3F3FC),
                targetKcalHint: 'Target: ~600 kcal',
                meals: dinnerMeals,
                onAdd: onAddMeal,
              ),
              const SizedBox(height: AppSpacing.md),

              // 7. Section: Healthy Snacks
              _buildMealSection(
                context: context,
                isDark: isDark,
                provider: provider,
                title: 'Healthy Snacks',
                icon: Icons.apple_rounded,
                iconColor: AppColors.stepsOrange,
                bgColor: AppColors.stepsOrangeTint,
                targetKcalHint: 'Target: ~200 kcal',
                meals: snackMeals,
                onAdd: onAddMeal,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 8. Nutrition Insight Card
              SolidWellnessCard(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryDark, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mindful Fueling Tip', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('Pairing protein and complex carbs at breakfast stabilizes glucose and prevents afternoon energy crashes.', style: AppTypography.caption(isDark)),
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

  Widget _buildMacroCard(bool isDark, String label, String grams, String percent, Color color, double ratio) {
    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(percent, style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              )),
            ],
          ),
          const SizedBox(height: 6),
          Text(grams, style: AppTypography.h3(isDark).copyWith(fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.caption(isDark).copyWith(fontSize: 11)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection({
    required BuildContext context,
    required bool isDark,
    required WellnessProvider provider,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String targetKcalHint,
    required List<dynamic> meals,
    required VoidCallback onAdd,
  }) {
    final sectionCalories = meals.fold<int>(0, (sum, m) => sum + (m.calories as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withOpacity(0.2) : bgColor,
                    borderRadius: AppRadii.roundedSm,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(title, style: AppTypography.h3(isDark).copyWith(fontSize: 16)),
              ],
            ),
            Row(
              children: [
                Text(
                  sectionCalories > 0 ? '$sectionCalories kcal' : targetKcalHint,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: sectionCalories > 0 ? FontWeight.w700 : FontWeight.w500,
                    color: sectionCalories > 0
                        ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
                        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    HapticService.lightImpact();
                    onAdd();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_rounded, size: 18, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Meal Items or Clean Empty State for this category
        if (meals.isEmpty)
          SolidWellnessCard(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            onTap: onAdd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('No $title logged today', style: AppTypography.caption(isDark).copyWith(fontSize: 13)),
                const Text('+ Add', style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                )),
              ],
            ),
          )
        else
          ...meals.map((meal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SolidWellnessCard(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meal.name, style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('${meal.description}', style: AppTypography.caption(isDark)),
                        ],
                      ),
                    ),
                    Text('${meal.calories} kcal', style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    )),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      onPressed: () {
                        HapticService.selection();
                        provider.removeMeal(meal.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
