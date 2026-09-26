import 'package:flutter/material.dart';
import '../../core/glass/platform_glass_surface.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';

class TourStepData {
  final String title;
  final String category;
  final IconData icon;
  final Color accentColor;
  final String description;
  final String proTip;
  // Position specifications for the spotlight window
  final double? targetTop;
  final double? targetBottom;
  final double? targetLeft;
  final double? targetRight;
  final double? targetWidth;
  final double targetHeight;
  final bool isCircle;
  // Position for the tour card
  final bool cardAtBottom;

  const TourStepData({
    required this.title,
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.description,
    required this.proTip,
    this.targetTop,
    this.targetBottom,
    this.targetLeft,
    this.targetRight,
    this.targetWidth,
    required this.targetHeight,
    this.isCircle = false,
    this.cardAtBottom = true,
  });
}

/// A luxury Apple-grade spotlight guided tour overlay for Biothrix.
/// Highlights live interactive app components with smooth animated apertures,
/// glowing specular rims, and detailed clinical explanations of how to use the app.
class SpotlightTourOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback? onOpenAiChatbot;

  const SpotlightTourOverlay({
    super.key,
    required this.onDismiss,
    this.onOpenAiChatbot,
  });

  @override
  State<SpotlightTourOverlay> createState() => _SpotlightTourOverlayState();
}

class _SpotlightTourOverlayState extends State<SpotlightTourOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const List<TourStepData> _steps = [
    // STEP 1: Metabolic Engine & Goal Rings
    TourStepData(
      title: 'Vitality & Goal Progress Engine',
      category: 'CORE BIOMETRIC HUB',
      icon: Icons.donut_large_rounded,
      accentColor: AppColors.primary,
      description:
          'Your central command for holistic wellness. The multi-layer vitality ring synthesizes active calorie burn, hydration balance, and daily step volume into a unified metabolic score.\n\nTap any individual telemetry card (Steps, Water, Sleep, Meals) to open dedicated analytics dashboards with pacing protocols and historical trends.',
      proTip: 'Achieving 70%+ overall completion maintains your metabolic adherence streak.',
      targetTop: 80,
      targetLeft: 16,
      targetRight: 16,
      targetHeight: 250,
      cardAtBottom: true,
    ),

    // STEP 2: Interactive Calendar & Day Details Flip
    TourStepData(
      title: 'Interactive Calendar & Day Flip',
      category: 'TEMPORAL SCRUBBING',
      icon: Icons.calendar_today_rounded,
      accentColor: Color(0xFF2EB5FA),
      description:
          'Effortlessly inspect past days without leaving your flow. Tap any day pill to smoothly flip the card in-place into your Day Details breakdown (Steps, Water, Calories, Sleep) with zero screen jumping.\n\nTap "September 2026 ⌄" to open your compact monthly wellness calendar with 4-color activity dots.',
      proTip: 'Use the < and > chevrons on the flipped card to rapidly scrub between days.',
      targetTop: 345,
      targetLeft: 16,
      targetRight: 16,
      targetHeight: 140,
      cardAtBottom: true,
    ),

    // STEP 3: Swipeable Dual-Action Button (FAB)
    TourStepData(
      title: 'Swipeable Dual-Action Core',
      category: 'GESTURE COMMAND',
      icon: Icons.swipe_vertical_rounded,
      accentColor: Color(0xFFCCFF00),
      description:
          'One button, two superpowers. Swipe UP or DOWN directly on this circular button to morph between 1-Tap Quick Action Logging (+) and the Biothrix AI Intelligence Core.\n\nWhen in Quick Mode, tap it to log water, meals, sleep, or habits in under 2 seconds.',
      proTip: 'A quick vertical thumb swipe switches modes with crisp tactile haptics.',
      targetBottom: 22,
      targetRight: 16,
      targetWidth: 62,
      targetHeight: 62,
      isCircle: true,
      cardAtBottom: false,
    ),

    // STEP 4: Biothrix AI Companion
    TourStepData(
      title: 'Clinical AI Health Companion',
      category: 'INTELLIGENCE AGENT',
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFF10B981),
      description:
          'Slide up your AI Health Companion for real-time biometric analysis. Grounded directly in your live hardware sensors, Biothrix AI answers nutrition inquiries, calculates exact calorie deficits, recommends cardio pacing, and formulates circadian sleep hygiene protocols tailored to your primary goal.',
      proTip: 'Tap the horizontal prompt chips for instant 1-tap telemetry assessments.',
      targetBottom: 22,
      targetRight: 16,
      targetWidth: 62,
      targetHeight: 62,
      isCircle: true,
      cardAtBottom: false,
    ),

    // STEP 5: Clinical PDF & JSON Data Export
    TourStepData(
      title: 'Clinical PDF & Data Sovereignty',
      category: 'EXECUTIVE EXPORT',
      icon: Icons.picture_as_pdf_rounded,
      accentColor: Color(0xFFFF9442),
      description:
          'Own your complete health telemetry. Navigate to Profile > Settings to generate executive clinical PDF dossiers formatted with biometric scorecards, 7-day adherence tables, and physician-ready summaries, or export structured JSON archives with 1 tap.',
      proTip: 'Clinical PDFs are formatted to ISO standards, ideal for sharing with your doctor.',
      targetBottom: 22,
      targetLeft: 16,
      targetRight: 90,
      targetHeight: 62,
      cardAtBottom: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticService.selection();
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      HapticService.success();
      widget.onDismiss();
    }
  }

  void _prevStep() {
    HapticService.selection();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = _steps[_currentStep];
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Semi-transparent backdrop with tap-outside handler
          GestureDetector(
            onTap: _nextStep,
            child: Container(
              color: Colors.black.withOpacity(0.78),
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // 2. Animated Spotlight Target Aperture with Breathing Glow
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            top: step.targetTop,
            bottom: step.targetBottom,
            left: step.targetLeft,
            right: step.targetRight,
            width: step.targetWidth,
            height: step.targetHeight,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    shape: step.isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: step.isCircle ? null : AppRadii.roundedCard,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Floating Frosted Glass Tour Card
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            left: 16,
            right: 16,
            top: step.cardAtBottom ? (step.targetTop != null ? step.targetTop! + step.targetHeight + 14 : null) : null,
            bottom: !step.cardAtBottom ? (step.targetBottom != null ? step.targetBottom! + step.targetHeight + 14 : 95) : null,
            child: PlatformGlassSurface(
              borderRadius: AppRadii.roundedCard,
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Column(
                  key: ValueKey(_currentStep),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Step Pill, Category, and Skip Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadii.roundedPill,
                              ),
                              child: Text(
                                'STEP ${_currentStep + 1} OF ${_steps.length}',
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              step.category,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticService.selection();
                            widget.onDismiss();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF26322A) : const Color(0xFFE5EDE7),
                              borderRadius: AppRadii.roundedPill,
                            ),
                            child: Text(
                              'Skip Tour',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Feature Title with Icon Badge
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: step.accentColor.withOpacity(0.18),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: Icon(step.icon, color: step.accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step.title,
                            style: AppTypography.h3(isDark).copyWith(fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Detailed Walkthrough Description
                    Text(
                      step.description,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        height: 1.45,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pro Tip Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF16231A) : const Color(0xFFEDF7EE),
                        borderRadius: AppRadii.roundedSm,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryDark, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.proTip,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Segmented Progress Bar
                    Row(
                      children: List.generate(_steps.length, (index) {
                        final isPassed = index <= _currentStep;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: isPassed
                                  ? AppColors.primary
                                  : (isDark ? const Color(0xFF28362E) : const Color(0xFFD6DFD8)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons Row: Back and Next / Finish
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          GestureDetector(
                            onTap: _prevStep,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF222F26) : const Color(0xFFE2EBE4),
                                borderRadius: AppRadii.roundedPill,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_back_rounded, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Previous',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox(),
                        GestureDetector(
                          onTap: _nextStep,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadii.roundedPill,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _currentStep == _steps.length - 1 ? 'Start Exploring 🚀' : 'Next Step',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
