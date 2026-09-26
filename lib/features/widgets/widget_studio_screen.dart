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
import '../../domain/state/wellness_provider.dart';

enum WidgetPreviewTheme { dark, light, mint }
enum WidgetPreviewSize { compact2x2, banner4x2, executive4x4 }

class WidgetStudioScreen extends StatefulWidget {
  final VoidCallback onBack;

  const WidgetStudioScreen({super.key, required this.onBack});

  @override
  State<WidgetStudioScreen> createState() => _WidgetStudioScreenState();
}

class _WidgetStudioScreenState extends State<WidgetStudioScreen> {
  WidgetPreviewTheme _selectedTheme = WidgetPreviewTheme.dark;
  WidgetPreviewSize _selectedSize = WidgetPreviewSize.banner4x2;
  int _selectedWidgetIndex = 0;

  final List<String> _widgetNames = [
    'Heart Rate & Vitals',
    'Hydration Balance',
    'Calorie & Nutrition',
    'Sleep Architecture',
    'Daily Habits Tracker',
    'Steps & Movement',
    'Master Vitals Hub (4-in-1)',
  ];

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
            ScreenHeader(
              title: 'Widget Studio',
              subtitle: '7 Executive Android & iOS Widgets',
              onBack: widget.onBack,
              trailing: PlatformGlassButton(
                icon: Icons.info_outline_rounded,
                size: 42,
                iconSize: 20,
                tooltip: 'Widget Info',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Long-press your phone home screen to place Wellnest widgets.'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
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
                    // Widget Picker Horizontal Chips
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _widgetNames.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final isSel = _selectedWidgetIndex == i;
                          return ChoiceChip(
                            label: Text(
                              _widgetNames[i],
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                color: isSel ? Colors.black : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                            ),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            backgroundColor: isDark ? const Color(0xFF1E2721) : const Color(0xFFE8EFEA),
                            onSelected: (val) {
                              if (val) {
                                HapticService.selection();
                                setState(() => _selectedWidgetIndex = i);
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Live Interactive Preview Canvas
                    Center(
                      child: _buildLiveWidgetCard(provider),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Controls: Theme Selector
                    Text('Widget Surface Theme', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                    const SizedBox(height: AppSpacing.sm),
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _buildThemeOption('Obsidian Dark', WidgetPreviewTheme.dark, const Color(0xFF161F18)),
                          const SizedBox(width: 8),
                          _buildThemeOption('Porcelain Light', WidgetPreviewTheme.light, Colors.white),
                          const SizedBox(width: 8),
                          _buildThemeOption('Electric Mint', WidgetPreviewTheme.mint, const Color(0xFFD6F5C6)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Controls: Size Selector
                    Text('Widget Dimensions & Grid Format', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                    const SizedBox(height: AppSpacing.sm),
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _buildSizeOption('Compact 2x2', WidgetPreviewSize.compact2x2),
                          const SizedBox(width: 8),
                          _buildSizeOption('Banner 4x2', WidgetPreviewSize.banner4x2),
                          const SizedBox(width: 8),
                          _buildSizeOption('Executive 4x4', WidgetPreviewSize.executive4x4),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Pro Tip Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF16231A) : const Color(0xFFEDF7EE),
                        borderRadius: AppRadii.roundedMd,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryDark, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Continuous Background Telemetry',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Widgets auto-synchronize with your device sensor cache every 15 minutes, preserving battery while delivering up-to-the-minute metabolic telemetry.',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, WidgetPreviewTheme theme, Color sampleColor) {
    final isSel = _selectedTheme == theme;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.selection();
          setState(() => _selectedTheme = theme);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
            borderRadius: AppRadii.roundedSm,
            border: Border.all(
              color: isSel ? AppColors.primary : Colors.grey.withOpacity(0.25),
              width: isSel ? 1.8 : 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: sampleColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeOption(String label, WidgetPreviewSize size) {
    final isSel = _selectedSize == size;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.selection();
          setState(() => _selectedSize = size);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary : Colors.transparent,
            borderRadius: AppRadii.roundedSm,
            border: Border.all(
              color: isSel ? AppColors.primary : Colors.grey.withOpacity(0.25),
              width: isSel ? 1.8 : 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: isSel ? Colors.black : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveWidgetCard(WellnessProvider provider) {
    LinearGradient bgGradient;
    Color textColor;
    Color subTextColor;
    Color borderColor;

    switch (_selectedTheme) {
      case WidgetPreviewTheme.dark:
        bgGradient = const LinearGradient(
          colors: [Color(0xFF19251E), Color(0xFF0F1712)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        textColor = Colors.white;
        subTextColor = const Color(0xFF9FB2A5);
        borderColor = AppColors.primary.withOpacity(0.35);
        break;
      case WidgetPreviewTheme.light:
        bgGradient = const LinearGradient(
          colors: [Colors.white, Color(0xFFF2F7F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        textColor = const Color(0xFF101913);
        subTextColor = const Color(0xFF5E6E63);
        borderColor = const Color(0xFFD4E2D8);
        break;
      case WidgetPreviewTheme.mint:
        bgGradient = const LinearGradient(
          colors: [Color(0xFFE8F8DE), Color(0xFFD4F3C4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        textColor = const Color(0xFF122310);
        subTextColor = const Color(0xFF3B5738);
        borderColor = AppColors.primaryDark.withOpacity(0.4);
        break;
    }

    double width = 345;
    double height = 158;

    if (_selectedSize == WidgetPreviewSize.compact2x2) {
      width = 175;
      height = 175;
    } else if (_selectedSize == WidgetPreviewSize.executive4x4) {
      width = 345;
      height = 290;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _renderWidgetContent(provider, textColor, subTextColor),
      ),
    );
  }

  Widget _renderWidgetContent(WellnessProvider provider, Color textColor, Color subColor) {
    final isCompact = _selectedSize == WidgetPreviewSize.compact2x2;

    switch (_selectedWidgetIndex) {
      case 0: // Heart Rate
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.heartRed.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded, color: AppColors.heartRed, size: 14),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'HEART RATE',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.6,
                        color: AppColors.heartRed,
                      ),
                    ),
                  ],
                ),
                Text(
                  'WELLNEST',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: subColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${provider.bpm > 0 ? provider.bpm : (provider.isDemoMode ? 74 : 72)}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w900,
                    fontSize: isCompact ? 32 : 36,
                    color: textColor,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'BPM',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.heartRed,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.heartRed.withOpacity(0.12),
                borderRadius: AppRadii.roundedPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(
                    'Optimal Resting • 56-118 BPM Range',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 1: // Hydration
        final ratio = (provider.waterGlasses / provider.waterGoal).clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.waterBlue.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.water_drop_rounded, color: AppColors.waterBlue, size: 14),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'HYDRATION',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.6,
                        color: AppColors.waterBlue,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(ratio * 100).toInt()}% MET',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.waterBlue,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  (provider.waterGlasses * 0.25).toStringAsFixed(1),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w900,
                    fontSize: isCompact ? 30 : 34,
                    color: textColor,
                  ),
                ),
                Text(
                  ' / ${(provider.waterGoal * 0.25).toStringAsFixed(1)}L',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: subColor,
                  ),
                ),
              ],
            ),
            // 8 Segments Water Glass Bar
            Row(
              children: List.generate(8, (i) {
                final isFilled = i < provider.waterGlasses;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    height: 6,
                    decoration: BoxDecoration(
                      color: isFilled ? AppColors.waterBlue : subColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ],
        );

      case 2: // Calorie & Nutrition
        return Row(
          children: [
            CircularProgressRing(
              progress: 0.88,
              size: isCompact ? 54 : 64,
              strokeWidth: 6,
              progressColor: AppColors.primary,
              trackColor: subColor.withOpacity(0.2),
              centerPrimaryText: '${provider.calories > 0 ? provider.calories : 1775}',
              centerSecondaryText: 'kcal',
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'CALORIC METABOLISM',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Target: ${provider.targetCalories} kcal',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Deficit: -325 kcal (On Track)',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 3: // Sleep Architecture
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFF818CF8).withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bedtime_rounded, color: Color(0xFF818CF8), size: 14),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'SLEEP RECOVERY',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.6,
                        color: Color(0xFF818CF8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withOpacity(0.2),
                    borderRadius: AppRadii.roundedPill,
                  ),
                  child: const Text(
                    '92 SCORE',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF818CF8),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${provider.sleepHours > 0 ? provider.sleepHours.toStringAsFixed(1) : "7.8"} hrs',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w900,
                fontSize: isCompact ? 28 : 32,
                color: textColor,
              ),
            ),
            Text(
              'Deep: 1h 45m • REM: 2h 10m • 94% Efficiency',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: subColor,
              ),
            ),
          ],
        );

      case 4: // Habits
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.task_alt_rounded, color: Color(0xFF10B981), size: 14),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'DAILY PROTOCOLS',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.6,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const Text(
                  '4 / 5 DONE',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                const SizedBox(width: 6),
                Text(
                  '14-Day Morning Sunlight Streak',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Text(
              'Next: Evening Wind-down protocol (Pending)',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                color: subColor,
              ),
            ),
          ],
        );

      case 5: // Steps
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.stepsOrange.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_walk_rounded, color: AppColors.stepsOrange, size: 14),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'CADENCE & STEPS',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.6,
                        color: AppColors.stepsOrange,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${((provider.steps / provider.stepGoal) * 100).toInt()}% OF GOAL',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.stepsOrange,
                  ),
                ),
              ],
            ),
            Text(
              '${provider.steps > 0 ? provider.steps : 8420}',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w900,
                fontSize: isCompact ? 30 : 34,
                color: textColor,
                letterSpacing: -1.0,
              ),
            ),
            Text(
              '6.4 km • 420 active kcal • 42 active mins',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: subColor,
              ),
            ),
          ],
        );

      case 6: // Master Vitals
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hub_rounded, color: AppColors.primaryDark, size: 14),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'MASTER VITALS MATRIX',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.6,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'LIVE SYNC',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildMiniVital('PULSE', '${provider.bpm > 0 ? provider.bpm : 74}', 'BPM', AppColors.heartRed, textColor)),
                Expanded(child: _buildMiniVital('WATER', '${provider.waterGlasses}', 'GLS', AppColors.waterBlue, textColor)),
                Expanded(child: _buildMiniVital('STEPS', '${provider.steps > 0 ? (provider.steps / 1000).toStringAsFixed(1) : "8.4"}k', 'STP', AppColors.stepsOrange, textColor)),
                Expanded(child: _buildMiniVital('SLEEP', provider.sleepHours > 0 ? provider.sleepHours.toStringAsFixed(1) : '7.8', 'HRS', const Color(0xFF818CF8), textColor)),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildMiniVital(String label, String value, String unit, Color accent, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: AppRadii.roundedSm,
        border: Border.all(color: accent.withOpacity(0.3), width: 0.8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: textColor,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 7,
              fontWeight: FontWeight.w700,
              color: accent.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
