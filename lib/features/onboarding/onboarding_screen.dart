import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/state/wellness_provider.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to\nBiothrix',
      'desc': 'Your modern, personal wellness companion. Clean solid metrics and intuitive tracking without the clutter.',
      'icon': Icons.spa_rounded,
      'color': AppColors.primaryDark,
      'bgColor': AppColors.primaryTint,
    },
    {
      'title': 'Platform-Adaptive\nGlass Interface',
      'desc': 'Frosted glass navigation on Android and fluid liquid-glass depth on iOS designed for effortless focus.',
      'icon': Icons.layers_rounded,
      'color': AppColors.waterBlue,
      'bgColor': AppColors.waterBlueTint,
    },
    {
      'title': 'Build Consistency\nFrom Scratch',
      'desc': 'Set your personalized habits, hydration goals, and workouts. You start fresh today.',
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.stepsOrange,
      'bgColor': AppColors.stepsOrangeTint,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _finishOnboarding(WellnessProvider provider) {
    if (_nameController.text.trim().isNotEmpty) {
      provider.setUserName(_nameController.text.trim());
    }
    widget.onGetStarted();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final isLastPage = _currentPage == _pages.length;

    return Scaffold(
      body: ResponsiveLayout.pageContainer(
        context: context,
        topSafeArea: true,
        bottomSafeArea: true,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  HapticService.lightImpact();
                  _finishOnboarding(provider);
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  ..._pages.map((page) {
                    final icon = page['icon'] as IconData;
                    final color = page['color'] as Color;
                    final bgColor = page['bgColor'] as Color;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: isDark ? color.withOpacity(0.18) : bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 56, color: color),
                          ),
                          const SizedBox(height: 38),
                          Text(
                            page['title'] as String,
                            textAlign: TextAlign.center,
                            style: AppTypography.displayMedium(isDark).copyWith(fontSize: 26),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            page['desc'] as String,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLarge(isDark).copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Final Setup Page: Personalize Profile
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primary.withOpacity(0.2) : AppColors.primaryTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_outline_rounded, size: 44, color: AppColors.primaryDark),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'What should we\ncall you?',
                          textAlign: TextAlign.center,
                          style: AppTypography.displayMedium(isDark).copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Personalize your daily dashboard',
                          style: AppTypography.caption(isDark).copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            border: OutlineInputBorder(
                              borderRadius: AppRadii.roundedMd,
                              borderSide: BorderSide(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadii.roundedMd,
                              borderSide: BorderSide(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadii.roundedMd,
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Page Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length + 1, (index) {
                final isSelected = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorderStrong),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Continue / Get Started Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  HapticService.mediumImpact();
                  if (_currentPage < _pages.length) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _finishOnboarding(provider);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimaryLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.roundedMd,
                  ),
                ),
                child: Text(
                  isLastPage ? 'Start My Journey' : 'Continue',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
