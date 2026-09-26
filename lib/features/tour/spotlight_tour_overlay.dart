import 'package:flutter/material.dart';
import '../../core/constants/tour_target_keys.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';

class TourStepInfo {
  final String title;
  final String category;
  final IconData icon;
  final String description;
  final bool isCircle;
  final GlobalKey targetKey;

  const TourStepInfo({
    required this.title,
    required this.category,
    required this.icon,
    required this.description,
    required this.targetKey,
    this.isCircle = false,
  });
}

/// A luxury Apple-grade spotlight guided tour overlay for Biothrix.
/// Punches a crisp, non-glowing window directly over live interactive widgets
/// and displays a perfectly proportioned, solid explanation card that never
/// cuts into the screen edges.
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

class _SpotlightTourOverlayState extends State<SpotlightTourOverlay> {
  int _currentStep = 0;

  static final List<TourStepInfo> _steps = [
    // Step 0: 4-Ring Concentric Activity Engine (First Hero Card)
    TourStepInfo(
      title: '4-Ring Concentric Activity Engine',
      category: 'CONCENTRIC VITALITY RINGS',
      icon: Icons.donut_large_rounded,
      description:
          'Your 4 concentric activity rings monitor Steps, Hydration, Sleep, and Nutrition. Tap this card anytime to slide up your deep 7-day Activity Details & historical charts.',
      targetKey: TourTargetKeys.ringsHeroKey,
      isCircle: false,
    ),

    // Step 1: Weekly Progress Engine (Second Card)
    TourStepInfo(
      title: 'Weekly Progress & Daily Intake',
      category: 'METABOLIC ADHERENCE',
      icon: Icons.bolt_rounded,
      description:
          'Tracks your comprehensive metabolic intake, active caloric burn, and adherence streak across the current 7-day cycle.',
      targetKey: TourTargetKeys.heroCardKey,
      isCircle: false,
    ),

    // Step 2: Swipeable Dual-Action Core (FAB)
    TourStepInfo(
      title: 'Swipeable Dual-Action Core',
      category: 'GESTURE COMMAND',
      icon: Icons.swipe_vertical_rounded,
      description:
          'Swipe UP or DOWN on this circular button to fluidly switch between 1-Tap Quick Action Logging (+) and your Biothrix AI Intelligence Core.',
      targetKey: TourTargetKeys.fabKey,
      isCircle: true,
    ),

    // Step 3: Biothrix AI Health Companion
    TourStepInfo(
      title: 'Clinical AI Companion',
      category: 'REAL-TIME INTELLIGENCE',
      icon: Icons.auto_awesome_rounded,
      description:
          'Tap the AI Core for real-time guidance. Synced live to your biometric sensors for tailored cardio pacing, nutrition, and circadian sleep protocols.',
      targetKey: TourTargetKeys.fabKey,
      isCircle: true,
    ),

    // Step 4: Profile & Clinical Dossier
    TourStepInfo(
      title: 'Profile & Clinical Dossier',
      category: 'EXECUTIVE EXPORT',
      icon: Icons.person_rounded,
      description:
          'Tap your avatar to manage biometric targets, calibrate preferences, and export physician-ready clinical PDF dossiers and structured JSON archives.',
      targetKey: TourTargetKeys.avatarKey,
      isCircle: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Schedule a frame tick so RenderBoxes have finished layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
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

  Rect? _getTargetRect(GlobalKey key, {double inflate = 5.0}) {
    final context = key.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final offset = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height).inflate(inflate);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = _steps[_currentStep];
    final screenSize = MediaQuery.of(context).size;
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Retrieve live widget bounds
    final targetRect = _getTargetRect(step.targetKey);

    // If target is in the lower 48% of screen (e.g. FAB at bottom), anchor card to TOP.
    // Otherwise, anchor card to the BOTTOM with safe insets.
    final bool placeAtTop = targetRect != null && targetRect.center.dy > (screenSize.height * 0.52);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Dark semi-transparent scrim with transparent cutout hole over the target widget
          // Tap anywhere outside the card advances to the next step
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _nextStep,
              child: CustomPaint(
                painter: SpotlightHolePainter(
                  targetRect: targetRect,
                  isCircle: step.isCircle,
                  overlayColor: Colors.black.withOpacity(0.72),
                  borderColor: AppColors.primary,
                  borderRadius: 20.0,
                ),
              ),
            ),
          ),

          // 2. Solid, perfectly proportioned tour card (zero gradients, zero glow, no overflow)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            left: 16,
            right: 16,
            top: placeAtTop ? (topInset + 16) : null,
            bottom: !placeAtTop ? (bottomInset + 16) : null,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B241E) : Colors.white,
                borderRadius: AppRadii.roundedCard,
                border: Border.all(
                  color: isDark ? const Color(0xFF2C3930) : const Color(0xFFE2EBE5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
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
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticService.selection();
                          widget.onDismiss();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF26332A) : const Color(0xFFEAEFEA),
                            borderRadius: AppRadii.roundedPill,
                          ),
                          child: Text(
                            'Skip',
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
                  const SizedBox(height: 12),

                  // Title Row with Icon
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: AppRadii.roundedSm,
                        ),
                        child: Icon(step.icon, color: AppColors.primaryDark, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          step.title,
                          style: AppTypography.h3(isDark).copyWith(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Concise Walkthrough Description (Max 2-3 lines)
                  Text(
                    step.description,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      height: 1.42,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Bottom Row: Segmented Progress Indicator on Left, Actions on Right
                  Row(
                    children: [
                      // Segmented Progress Line
                      Expanded(
                        child: Row(
                          children: List.generate(_steps.length, (index) {
                            final isDone = index <= _currentStep;
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 3.5,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF2C3930) : const Color(0xFFDCE5DF)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Back Button (shown from step 2 onwards)
                      if (_currentStep > 0) ...[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _prevStep,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF243028) : const Color(0xFFE5EDE7),
                              borderRadius: AppRadii.roundedPill,
                            ),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Next / Finish Button (Solid Lime, Zero Glow)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _nextStep,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadii.roundedPill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentStep == _steps.length - 1 ? 'Get Started 🚀' : 'Next',
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 14),
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
        ],
      ),
    );
  }
}

/// A crisp, flat hole puncher for the spotlight overlay.
/// Combines the full screen rect with the target shape via [PathOperation.difference]
/// to leave an unobstructed transparent viewport over the live widget,
/// surrounded by a razor-sharp 2.0px solid border (zero blur, zero glow).
class SpotlightHolePainter extends CustomPainter {
  final Rect? targetRect;
  final bool isCircle;
  final Color overlayColor;
  final Color borderColor;
  final double borderRadius;

  SpotlightHolePainter({
    required this.targetRect,
    required this.isCircle,
    required this.overlayColor,
    required this.borderColor,
    this.borderRadius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPath = Path()..addRect(screenRect);

    if (targetRect != null) {
      final holePath = Path();
      if (isCircle) {
        final radius = targetRect!.width / 2;
        holePath.addOval(Rect.fromCircle(center: targetRect!.center, radius: radius));
      } else {
        holePath.addRRect(RRect.fromRectAndRadius(
          targetRect!,
          Radius.circular(borderRadius),
        ));
      }

      // Punch transparent hole through the background scrim
      final combinedPath = Path.combine(PathOperation.difference, backgroundPath, holePath);
      canvas.drawPath(combinedPath, Paint()..color = overlayColor);

      // Draw crisp solid border around the cut-out (Zero glow / blur / gradient)
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      if (isCircle) {
        final radius = targetRect!.width / 2;
        canvas.drawCircle(targetRect!.center, radius, borderPaint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(targetRect!, Radius.circular(borderRadius)),
          borderPaint,
        );
      }
    } else {
      canvas.drawPath(backgroundPath, Paint()..color = overlayColor);
    }
  }

  @override
  bool shouldRepaint(covariant SpotlightHolePainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.isCircle != isCircle;
  }
}
