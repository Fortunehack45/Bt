import 'package:flutter/material.dart';
import '../../core/glass/platform_glass_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';

/// Dedicated Personal Biometrics & Account Profile Screen
class PersonalProfileScreen extends StatelessWidget {
  final VoidCallback onBack;

  const PersonalProfileScreen({super.key, required this.onBack});

  void _showEditBiometricsSheet(BuildContext context, WellnessProvider provider) {
    HapticService.selection();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nameController = TextEditingController(text: provider.userName);
    final ageController = TextEditingController(text: provider.age.toString());
    final heightController = TextEditingController(text: provider.heightCm.toStringAsFixed(0));
    final weightController = TextEditingController(text: (provider.weightKg > 0 ? provider.weightKg : 70.0).toStringAsFixed(1));
    final targetWeightController = TextEditingController(text: provider.targetWeightKg.toStringAsFixed(1));
    String selectedGender = provider.gender;
    String selectedGoal = provider.primaryGoal;
    bool selectedTrackPeriod = provider.isPeriodTrackingEnabled;
    bool selectedTrackPregnancy = provider.isPregnancyTrackingEnabled;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSheet),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.pageMargin,
                right: AppSpacing.pageMargin,
                top: 14.0,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorderStrong,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Edit Biometrics', style: AppTypography.h3(isDark)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Name
                    _buildInputField('Full Name', nameController, isDark, TextInputType.name),
                    const SizedBox(height: 12),

                    // Gender Choice
                    Text('Biological Sex', style: AppTypography.caption(isDark)),
                    const SizedBox(height: 6),
                    Row(
                      children: ['Male', 'Female', 'Other'].map((g) {
                        final isSel = selectedGender == g;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(g),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            onSelected: (val) {
                              if (val) setState(() => selectedGender = g);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Age & Height Row
                    Row(
                      children: [
                        Expanded(child: _buildInputField('Age (years)', ageController, isDark, TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInputField('Height (cm)', heightController, isDark, TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Weight & Target Weight Row
                    Row(
                      children: [
                        Expanded(child: _buildInputField('Weight (kg)', weightController, isDark, const TextInputType.numberWithOptions(decimal: true))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInputField('Target (kg)', targetWeightController, isDark, const TextInputType.numberWithOptions(decimal: true))),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Goal
                    Text('Primary Goal', style: AppTypography.caption(isDark)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Vitality & Longevity',
                        'Healthy Weight',
                        'Deep Sleep & Rest',
                        'Heart Fitness',
                      ].map((goal) {
                        final isSel = selectedGoal == goal;
                        return ChoiceChip(
                          label: Text(goal),
                          selected: isSel,
                          selectedColor: AppColors.primary,
                          onSelected: (val) {
                            if (val) setState(() => selectedGoal = goal);
                          },
                        );
                      }).toList(),
                    ),
                    if (selectedGender == 'Female') ...[
                      const SizedBox(height: 14),
                      Text('Reproductive Health Focus', style: AppTypography.caption(isDark)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          FilterChip(
                            label: const Text('Period Tracking'),
                            selected: selectedTrackPeriod,
                            selectedColor: const Color(0xFFF43F5E).withOpacity(0.2),
                            checkmarkColor: const Color(0xFFF43F5E),
                            onSelected: (val) {
                              setState(() {
                                selectedTrackPeriod = val;
                                if (val) selectedTrackPregnancy = false;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Pregnancy Tracking'),
                            selected: selectedTrackPregnancy,
                            selectedColor: const Color(0xFFA855F7).withOpacity(0.2),
                            checkmarkColor: const Color(0xFFA855F7),
                            onSelected: (val) {
                              setState(() {
                                selectedTrackPregnancy = val;
                                if (val) selectedTrackPeriod = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticService.mediumImpact();
                          if (nameController.text.trim().isNotEmpty) {
                            provider.setUserName(nameController.text.trim());
                          }
                          final parsedAge = int.tryParse(ageController.text.trim());
                          final parsedHeight = double.tryParse(heightController.text.trim());
                          final parsedWeight = double.tryParse(weightController.text.trim());
                          final parsedTarget = double.tryParse(targetWeightController.text.trim());

                          provider.updateBiometrics(
                            age: parsedAge,
                            gender: selectedGender,
                            heightCm: parsedHeight,
                            weightKg: parsedWeight,
                            targetWeightKg: parsedTarget,
                            primaryGoal: selectedGoal,
                            isPeriodTrackingEnabled: selectedGender == 'Female' ? selectedTrackPeriod : false,
                            isPregnancyTrackingEnabled: selectedGender == 'Female' ? selectedTrackPregnancy : false,
                          );

                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Biometrics updated successfully'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimaryLight,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                        ),
                        child: const Text('Save Biometrics', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, bool isDark, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption(isDark)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: AppRadii.roundedSm, borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: AppRadii.roundedSm, borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
            focusedBorder: const OutlineInputBorder(borderRadius: AppRadii.roundedSm, borderSide: BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

    final bmiVal = provider.bmi;
    final bmiCat = provider.bmiCategory;
    final bmiCol = provider.bmiColor;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: false,
        child: Column(
          children: [
            // Standardized 16px page-margin header
            ScreenHeader(
              title: 'Personal Biometrics',
              subtitle: 'Body Composition & Targets',
              onBack: onBack,
              trailing: PlatformGlassButton(
                icon: Icons.edit_outlined,
                size: 42,
                iconSize: 20,
                tooltip: 'Edit Biometrics',
                onTap: () => _showEditBiometricsSheet(context, provider),
              ),
            ),

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
                      child: Row(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceSubtle : AppColors.primaryTint,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.person_rounded, size: 40, color: AppColors.primaryDark),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.userName,
                                  style: AppTypography.h2(isDark).copyWith(fontSize: 20),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  provider.isDemoMode ? 'Demo Pitch Active' : 'Verified Member',
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
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Dynamic BMI Visual Meter
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Body Mass Index (BMI)', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text('Calculated from height & weight', style: AppTypography.caption(isDark)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: bmiCol.withOpacity(0.16),
                                  borderRadius: AppRadii.roundedPill,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '$bmiVal',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: bmiCol,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      bmiCat,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: bmiCol,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Visual Color-coded Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 10,
                              child: Row(
                                children: [
                                  Expanded(flex: 18, child: Container(color: AppColors.waterBlue)),
                                  Expanded(flex: 65, child: Container(color: const Color(0xFF10B981))),
                                  Expanded(flex: 50, child: Container(color: const Color(0xFFF59E0B))),
                                  Expanded(flex: 40, child: Container(color: AppColors.heartRed)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Bar Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLegendItem('< 18.5 Under', AppColors.waterBlue),
                              _buildLegendItem('18.5-24.9 Normal', const Color(0xFF10B981)),
                              _buildLegendItem('25-29.9 Over', const Color(0xFFF59E0B)),
                              _buildLegendItem('30+ Obese', AppColors.heartRed),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Biometrics 2x2 Grid
                    Text('Core Biometrics', style: AppTypography.h3(isDark).copyWith(fontSize: 16)),
                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      children: [
                        Expanded(
                          child: _buildBiometricTile(
                            label: 'Biological Age',
                            value: '${provider.age} yrs',
                            icon: Icons.cake_rounded,
                            color: AppColors.primaryDark,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBiometricTile(
                            label: 'Gender',
                            value: provider.gender,
                            icon: Icons.wc_rounded,
                            color: AppColors.waterBlue,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildBiometricTile(
                            label: 'Height',
                            value: '${provider.heightCm.toInt()} cm',
                            icon: Icons.height_rounded,
                            color: AppColors.nutritionGold,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBiometricTile(
                            label: 'Current Weight',
                            value: '${(provider.weightKg > 0 ? provider.weightKg : 70.0).toStringAsFixed(1)} kg',
                            icon: Icons.monitor_weight_rounded,
                            color: AppColors.stepsOrange,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildBiometricTile(
                            label: 'Target Weight',
                            value: '${provider.targetWeightKg.toStringAsFixed(1)} kg',
                            icon: Icons.flag_rounded,
                            color: const Color(0xFF10B981),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBiometricTile(
                            label: 'Activity Tier',
                            value: provider.activityLevel,
                            icon: Icons.directions_run_rounded,
                            color: AppColors.heartRed,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Primary Goal Card
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: AppRadii.roundedSm,
                            ),
                            child: const Icon(Icons.stars_rounded, color: AppColors.primaryDark, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Primary Wellness Focus', style: AppTypography.caption(isDark)),
                                const SizedBox(height: 2),
                                Text(provider.primaryGoal, style: AppTypography.h3(isDark).copyWith(fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Daily Calibrated Targets
                    Text('Calibrated Daily Targets', style: AppTypography.h3(isDark).copyWith(fontSize: 16)),
                    const SizedBox(height: AppSpacing.sm),

                    SolidWellnessCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTargetRow('Hydration Goal', '${provider.waterGoal} glasses (${provider.waterGoal * 250} ml)', Icons.water_drop_rounded, AppColors.waterBlue, isDark),
                          const Divider(height: 20),
                          _buildTargetRow('Daily Step Target', '${provider.stepGoal} steps (~7.5 km)', Icons.directions_walk_rounded, AppColors.stepsOrange, isDark),
                          const Divider(height: 20),
                          _buildTargetRow('Calorie Budget', '${provider.targetCalories} kcal / day', Icons.local_fire_department_rounded, AppColors.nutritionGold, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBiometricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated,
        borderRadius: AppRadii.roundedMd,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.caption(isDark).copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTargetRow(String label, String value, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: AppTypography.bodyMedium(isDark).copyWith(fontWeight: FontWeight.w600)),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }
}
