import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/models/wellness_models.dart';

/// Meal cards matching Reference Image 1 Screen 1:
/// - Displays logged meals with calorie badges and quick actions
/// - Displays a clean, welcoming state when no meals have been logged yet
class MealTrackerSection extends StatelessWidget {
  final List<MealEntry> meals;
  final VoidCallback onAddMeal;

  const MealTrackerSection({
    super.key,
    required this.meals,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (meals.isEmpty) {
      return SolidWellnessCard(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.nutritionGoldTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppColors.nutritionGold,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No meals logged today',
                    style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap + to log breakfast, lunch, or a healthy snack',
                    style: AppTypography.caption(isDark),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticService.lightImpact();
                onAddMeal();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.roundedSm,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 22,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: meals.map((meal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: SolidWellnessCard(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.mealType,
                        style: AppTypography.h3(isDark).copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.nutritionGoldTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_fire_department_rounded,
                              size: 14,
                              color: AppColors.nutritionGold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${meal.calories} kcal • ${meal.name}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildMealAvatars(isDark, meal.mealType),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () {
                    HapticService.lightImpact();
                    onAddMeal();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                      borderRadius: AppRadii.roundedSm,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMealAvatars(bool isDark, String mealType) {
    final icons = mealType.toLowerCase().contains('breakfast')
        ? [Icons.egg_alt_rounded, Icons.bakery_dining_rounded]
        : [Icons.restaurant_rounded, Icons.ramen_dining_rounded];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _avatarCircle(icons[0], const Color(0xFFFFE0B2), const Color(0xFFF57C00)),
        const SizedBox(width: 6),
        _avatarCircle(icons[1], const Color(0xFFC8E6C9), const Color(0xFF388E3C)),
      ],
    );
  }

  Widget _avatarCircle(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}
