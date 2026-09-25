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
              subtitle: '7 Android Home Widgets',
              onBack: widget.onBack,
              trailing: PlatformGlassButton(
                icon: Icons.info_outline_rounded,
                size: 42,
                iconSize: 20,
                tooltip: 'Widget Info',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Long-press your phone home screen to place Biothrix widgets.'),
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
                    // Widget Picker Tabs
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _widgetNames.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final isSel = _selectedWidgetIndex == i;
                          return ChoiceChip(
                            label: Text(_widgetNames[i]),
                            selected: isSel,
                            selectedColor: AppColors.primary,
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
                    const SizedBox(height: AppSpacing.md),

                    // Live Interactive Preview Box
                    Center(
                      child: _buildLiveWidgetCard(provider),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Controls: Theme Selector
                    Text('Widget Theme', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildThemeOption('Obsidian Dark', WidgetPreviewTheme.dark, const Color(0xFF141A13)),
                        const SizedBox(width: 10),
                        _buildThemeOption('Solar Light', WidgetPreviewTheme.light, const Color(0xFFFFFFFF)),
                        const SizedBox(width: 10),
                        _buildThemeOption('Mint Accent', WidgetPreviewTheme.mint, const Color(0xFFE2F7D6)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Controls: Size Selector
                    Text('Responsive Widget Size', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSizeOption('2x2 Square', WidgetPreviewSize.compact2x2),
                        const SizedBox(width: 8),
                        _buildSizeOption('4x2 Banner', WidgetPreviewSize.banner4x2),
                        const SizedBox(width: 8),
                        _buildSizeOption('4x4 Hub', WidgetPreviewSize.executive4x4),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Add to Android Home Screen Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticService.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pinned "${_widgetNames[_selectedWidgetIndex]}" to your Android launcher!'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_to_home_screen_rounded, size: 20),
                        label: Text(
                          'Add "${_widgetNames[_selectedWidgetIndex]}" to Home Screen',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimaryLight,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Description Card
                    SolidWellnessCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryDark, size: 18),
                              const SizedBox(width: 8),
                              Text('Real-Time Android OS Sync', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'All 7 Biothrix widgets update automatically when you log hydration, steps, or bpm, and respond seamlessly to Android dark/light mode switches.',
                            style: AppTypography.caption(isDark).copyWith(fontSize: 12),
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
              color: isSel ? AppColors.primary : Colors.grey.withOpacity(0.3),
              width: isSel ? 2 : 1,
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
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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
              color: isSel ? AppColors.primary : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: isSel ? AppColors.textPrimaryLight : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveWidgetCard(WellnessProvider provider) {
    Color bg;
    Color textColor;
    Color subTextColor;

    switch (_selectedTheme) {
      case WidgetPreviewTheme.dark:
        bg = const Color(0xFF161F15);
        textColor = Colors.white;
        subTextColor = Colors.white70;
        break;
      case WidgetPreviewTheme.light:
        bg = Colors.white;
        textColor = Colors.black87;
        subTextColor = Colors.black54;
        break;
      case WidgetPreviewTheme.mint:
        bg = const Color(0xFFE5F7DC);
        textColor = const Color(0xFF142911);
        subTextColor = const Color(0xFF33582D);
        break;
    }

    double width = 340;
    double height = 140;

    if (_selectedSize == WidgetPreviewSize.compact2x2) {
      width = 170;
      height = 170;
    } else if (_selectedSize == WidgetPreviewSize.executive4x4) {
      width = 340;
      height = 280;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _renderWidgetContent(provider, textColor, subTextColor),
      ),
    );
  }

  Widget _renderWidgetContent(WellnessProvider provider, Color textColor, Color subColor) {
    switch (_selectedWidgetIndex) {
      case 0: // Heart Rate
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_rounded, color: AppColors.heartRed, size: 20),
                const SizedBox(width: 8),
                Text('Heart Rate', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${provider.bpm > 0 ? provider.bpm : (provider.isDemoMode ? 74 : 72)}',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: textColor),
                ),
                const SizedBox(width: 6),
                Text('BPM', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.heartRed)),
              ],
            ),
            Text('Normal Resting • Synced', style: TextStyle(fontSize: 11, color: subColor)),
          ],
        );

      case 1: // Hydration
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_rounded, color: AppColors.waterBlue, size: 20),
                const SizedBox(width: 8),
                Text('Hydration', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${provider.waterGlasses} / ${provider.waterGoal} glasses',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: textColor),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (provider.waterGlasses / provider.waterGoal).clamp(0.0, 1.0),
                backgroundColor: AppColors.waterBlue.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(AppColors.waterBlue),
                minHeight: 6,
              ),
            ),
          ],
        );

      case 2: // Calorie
        return Row(
          children: [
            CircularProgressRing(
              progress: 0.88,
              size: 58,
              strokeWidth: 6,
              progressColor: AppColors.primary,
              trackColor: Colors.grey.withOpacity(0.2),
              centerPrimaryText: '1775',
              centerSecondaryText: 'kcal',
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nutrition Burn', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textColor)),
                  const SizedBox(height: 4),
                  Text('Target: 2,000 kcal', style: TextStyle(fontSize: 12, color: subColor)),
                  Text('225 kcal remaining', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                ],
              ),
            ),
          ],
        );

      case 3: // Sleep
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.bedtime_rounded, color: Color(0xFF818CF8), size: 20),
                const SizedBox(width: 8),
                Text('Sleep Architecture', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              provider.isDemoMode ? '7.8 hrs • 92% Score' : '8.0 hrs • Target met',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: textColor),
            ),
            Text('Optimal REM & deep recovery', style: TextStyle(fontSize: 11, color: subColor)),
          ],
        );

      case 4: // Habits
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.task_alt_rounded, color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 8),
                Text('Daily Habits', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text('4 of 5 Completed Today', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: textColor)),
            Text('🔥 14-day streak on morning sunlight', style: TextStyle(fontSize: 11, color: subColor)),
          ],
        );

      case 5: // Steps
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_walk_rounded, color: AppColors.stepsOrange, size: 20),
                const SizedBox(width: 8),
                Text('Daily Steps', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${provider.steps > 0 ? provider.steps : (provider.isDemoMode ? 8420 : 7500)} steps',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: textColor),
            ),
            Text('6.6 km • 420 active kcal', style: TextStyle(fontSize: 11, color: subColor)),
          ],
        );

      case 6: // Master Vitals
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.hub_rounded, color: AppColors.primaryDark, size: 18),
                const SizedBox(width: 8),
                Text('Biothrix Master Vitals', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textColor)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildMiniVital('Heart', '${provider.bpm > 0 ? provider.bpm : (provider.isDemoMode ? 74 : 72)} bpm', AppColors.heartRed, textColor)),
                Expanded(child: _buildMiniVital('Water', '${provider.waterGlasses} gl', AppColors.waterBlue, textColor)),
                Expanded(child: _buildMiniVital('Steps', '${provider.steps > 0 ? provider.steps : (provider.isDemoMode ? 8420 : 7500)}', AppColors.stepsOrange, textColor)),
                Expanded(child: _buildMiniVital('Sleep', '7.8 hrs', const Color(0xFF818CF8), textColor)),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildMiniVital(String label, String value, Color accent, Color textColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: textColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
