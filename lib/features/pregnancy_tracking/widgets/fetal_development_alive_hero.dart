import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/models/reproductive_health_models.dart';
import '../../../domain/state/wellness_provider.dart';
import 'log_pregnancy_wellness_sheet.dart';
import 'pregnancy_setup_sheet.dart';

/// Fetal Development "Alive" Hero Card matching Reference Image 4.
/// Features a multi-arc gestational progression portal, animated "alive" floating/breathing fetus
/// with natural blinking and heartbeat pulse, curved trimester milestone timeline, and live baby metrics.
class FetalDevelopmentAliveHero extends StatefulWidget {
  final VoidCallback? onTrimesterDetailsTap;

  const FetalDevelopmentAliveHero({
    super.key,
    this.onTrimesterDetailsTap,
  });

  @override
  State<FetalDevelopmentAliveHero> createState() => _FetalDevelopmentAliveHeroState();
}

class _FetalDevelopmentAliveHeroState extends State<FetalDevelopmentAliveHero>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late AnimationController _sweepController;

  late Animation<double> _breatheAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _sweepAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Rhythmic breathing / heartbeat pulse (~1.8 second soothing cycle)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );

    // 2. Gentle amniotic fluid floating motion (3.2 second cycle)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutQuad),
    );

    // 3. Natural occasional eye blink (~3.6 second interval)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
    _blinkAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 88), // Open
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 6), // Close
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 6), // Reopen
    ]).animate(_blinkController);

    // 4. Entrance sweep on initial load
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _sweepAnimation = CurvedAnimation(
      parent: _sweepController,
      curve: Curves.easeOutCubic,
    );
    _sweepController.forward();
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _floatController.dispose();
    _blinkController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final preg = provider.pregnancyData;

    final week = preg?.currentWeek ?? 21;
    final day = preg?.currentDayOfCurrentWeek ?? 0;
    final trimester = preg?.trimester ?? 2;
    final due = preg?.dueDate ?? DateTime.now().add(const Duration(days: 133));
    final daysUntilDue = preg?.daysUntilDueDate ?? 133;
    final fruit = preg?.babySizeFruit ?? 'Papaya';
    final lengthCm = preg?.estimatedLengthCm ?? 27.8;
    final weightG = preg?.estimatedWeightGrams ?? 430.0;
    final comparison = preg?.babySizeComparison ?? 'Size of a golden papaya (~27.8cm)';

    final progressRatio = (week / 40.0).clamp(0.0, 1.0);

    return SolidWellnessCard(
      padding: const EdgeInsets.only(top: 14, bottom: 18, left: 16, right: 16),
      child: Column(
        children: [
          // 1. Top Phase Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Trimester 1', const Color(0xFFF43F5E)),
              const SizedBox(width: 14),
              _buildLegendItem('Trimester 2', const Color(0xFFA855F7)),
              const SizedBox(width: 14),
              _buildLegendItem('Trimester 3', const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Large Circular Fetal Development Portal with "Alive" Fetus
          AnimatedBuilder(
            animation: Listenable.merge([
              _breatheAnimation,
              _floatAnimation,
              _blinkAnimation,
              _sweepAnimation,
            ]),
            builder: (context, child) {
              return SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Segmented Perimeter Arcs for the 3 Trimesters
                    CustomPaint(
                      size: const Size(250, 250),
                      painter: _PregnancyPortalPainter(
                        currentWeek: week,
                        sweepProgress: _sweepAnimation.value,
                        isDark: isDark,
                      ),
                    ),

                    // Amniotic Fluid Radiant Glow & Floating Alive Fetus
                    Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Transform.scale(
                        scale: _breatheAnimation.value,
                        child: CustomPaint(
                          size: const Size(180, 180),
                          painter: _AliveFetusPainter(
                            week: week,
                            blinkRatio: _blinkAnimation.value,
                            breatheRatio: _breatheAnimation.value,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // 3. Floating Week Pill & Curved Trimester Milestone Arc
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF261D33) : const Color(0xFFF3E8FF),
              borderRadius: AppRadii.roundedPill,
              border: Border.all(
                color: const Color(0xFFA855F7).withOpacity(0.35),
                width: 1.0,
              ),
            ),
            child: Text(
              'Week $week • Day $day',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFFA855F7),
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Curved Trimester Arc with Milestone Beads
          SizedBox(
            width: 260,
            height: 38,
            child: CustomPaint(
              painter: _CurvedTrimesterTimelinePainter(
                currentWeek: week,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 4. Baby Developmental Metrics Readout
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141C17) : const Color(0xFFF4F8F5),
              borderRadius: AppRadii.roundedMd,
              border: Border.all(
                color: isDark ? const Color(0xFF243329) : const Color(0xFFE2EBE5),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Baby is the Size of a $fruit',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      '${(progressRatio * 100).toInt()}% • 40 Wks',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA855F7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comparison,
                  style: AppTypography.caption(isDark).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Length: ~${lengthCm.toStringAsFixed(1)} cm',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA855F7),
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      'Weight: ~${weightG >= 1000 ? (weightG / 1000).toStringAsFixed(1) : weightG.toInt()} ${weightG >= 1000 ? 'kg' : 'g'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA855F7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$daysUntilDue days until estimated due date (${_months[due.month - 1]} ${due.day})',
                  style: AppTypography.caption(isDark).copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Primary Action: Log Today's Maternal Wellbeing
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticService.selection();
                showLogPregnancyWellnessSheet(context, provider);
              },
              icon: const Icon(Icons.favorite_rounded, size: 16, color: Colors.white),
              label: const Text(
                "Log Today's Maternal Wellbeing",
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the 3 segmented perimeter arcs (Trimester 1: Rose, Trimester 2: Purple,
/// Trimester 3: Gold) with minute 40-week tick dots and active glowing week thumb bead.
class _PregnancyPortalPainter extends CustomPainter {
  final int currentWeek;
  final double sweepProgress;
  final bool isDark;

  _PregnancyPortalPainter({
    required this.currentWeek,
    required this.sweepProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    // Background track ring
    final trackPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2822) : const Color(0xFFE5EDE8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw 40 minute tick dots along the perimeter
    final dotPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3931) : const Color(0xFFCBD6CF)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      final angle = -math.pi / 2 + (i / 40.0) * 2 * math.pi;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.8, dotPaint);
    }

    // Segment 1: Trimester 1 (Weeks 1–12) — Rose arc
    const t1Sweep = (12.0 / 40.0) * 2 * math.pi;
    final t1Paint = Paint()
      ..color = const Color(0xFFF43F5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      t1Sweep * (currentWeek >= 12 ? sweepProgress : (currentWeek / 12.0) * sweepProgress),
      false,
      t1Paint,
    );

    // Segment 2: Trimester 2 (Weeks 13–27) — Purple arc
    const t2Start = -math.pi / 2 + t1Sweep;
    const t2Sweep = (15.0 / 40.0) * 2 * math.pi;
    final t2Progress = currentWeek <= 12
        ? 0.0
        : (currentWeek >= 27 ? 1.0 : (currentWeek - 12) / 15.0);

    final t2Paint = Paint()
      ..color = const Color(0xFFA855F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (t2Progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        t2Start,
        t2Sweep * t2Progress * sweepProgress,
        false,
        t2Paint,
      );
    }

    // Segment 3: Trimester 3 (Weeks 28–40) — Champagne / Amber arc
    const t3Start = t2Start + t2Sweep;
    const t3Sweep = (13.0 / 40.0) * 2 * math.pi;
    final t3Progress = currentWeek <= 27
        ? 0.0
        : ((currentWeek - 27) / 13.0).clamp(0.0, 1.0);

    final t3Paint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (t3Progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        t3Start,
        t3Sweep * t3Progress * sweepProgress,
        false,
        t3Paint,
      );
    }

    // Active Week Thumb Indicator on the perimeter
    final weekFraction = (currentWeek / 40.0).clamp(0.0, 1.0);
    final thumbAngle = -math.pi / 2 + weekFraction * 2 * math.pi;
    final thumbX = center.dx + radius * math.cos(thumbAngle);
    final thumbY = center.dy + radius * math.sin(thumbAngle);

    final glowPaint = Paint()
      ..color = const Color(0xFFA855F7).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawCircle(Offset(thumbX, thumbY), 12.0, glowPaint);

    final thumbFill = Paint()
      ..color = isDark ? const Color(0xFF1E2822) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, thumbY), 10.0, thumbFill);

    final thumbBorder = Paint()
      ..color = const Color(0xFFA855F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(thumbX, thumbY), 10.0, thumbBorder);
  }

  @override
  bool shouldRepaint(_PregnancyPortalPainter oldDelegate) {
    return oldDelegate.currentWeek != currentWeek ||
        oldDelegate.sweepProgress != sweepProgress ||
        oldDelegate.isDark != isDark;
  }
}

/// Custom painter rendering the "Alive" developing fetus with soothing amniotic aura,
/// breathing rhythmic pulse, soft eyelid blink, and glowing heartbeat micro-gesture.
class _AliveFetusPainter extends CustomPainter {
  final int week;
  final double blinkRatio;
  final double breatheRatio;
  final bool isDark;

  _AliveFetusPainter({
    required this.week,
    required this.blinkRatio,
    required this.breatheRatio,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Amniotic Fluid Warm Ambient Halo
    final auraGradient = RadialGradient(
      colors: [
        const Color(0xFFA855F7).withOpacity(isDark ? 0.22 : 0.14),
        const Color(0xFFF43F5E).withOpacity(isDark ? 0.12 : 0.08),
        Colors.transparent,
      ],
      stops: const [0.35, 0.70, 1.0],
    );

    final auraPaint = Paint()
      ..shader = auraGradient.createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, size.width / 2, auraPaint);

    // 2. Curled Fetal Anatomy Vector (Warm maternal terracotta / peach palette)
    final fetusColor = isDark ? const Color(0xFFE89A7E) : const Color(0xFFE0886C);
    final fetusShadeColor = isDark ? const Color(0xFFC7785F) : const Color(0xFFBF6E54);

    final fetusPaint = Paint()
      ..color = fetusColor
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx - 10, center.dy - 10);

    // A. Head (Peaceful circular fetal cranial curve)
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(16, -22), width: 44, height: 46),
      fetusPaint,
    );

    // B. Arched Back & Torso Path
    final bodyPath = Path()
      ..moveTo(28, -6)
      ..cubicTo(44, 4, 42, 32, 24, 48) // Arched spinal curve
      ..cubicTo(10, 60, -14, 52, -22, 36) // Curled pelvis / bottom
      ..cubicTo(-28, 22, -18, 6, -2, 2) // Inner abdomen
      ..close();
    canvas.drawPath(bodyPath, fetusPaint);

    // C. Curled Legs & Tiny Feet
    final legPath = Path()
      ..moveTo(-18, 38)
      ..cubicTo(-32, 44, -36, 26, -26, 16)
      ..cubicTo(-20, 10, -10, 18, -14, 28)
      ..close();
    canvas.drawPath(legPath, fetusPaint);

    // Tiny foot pad
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-28, 14), width: 10, height: 7),
      Paint()..color = fetusShadeColor,
    );

    // D. Soft Resting Arms near Chest
    final armPath = Path()
      ..moveTo(8, 6)
      ..cubicTo(-2, 14, -8, 22, -2, 26)
      ..cubicTo(4, 28, 10, 20, 12, 12)
      ..close();
    canvas.drawPath(armPath, Paint()..color = fetusShadeColor);

    // E. Eyelid with Natural Blinking Micro-Gesture
    final eyeCenter = const Offset(26, -20);
    if (blinkRatio > 0.3) {
      // Eyelid line curved peacefully downward in sleep
      final eyeArcPaint = Paint()
        ..color = isDark ? const Color(0xFF5A2A1E) : const Color(0xFF6B3326)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * blinkRatio
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCenter(center: eyeCenter, width: 9, height: 7),
        0.1,
        math.pi * 0.9,
        false,
        eyeArcPaint,
      );
    } else {
      // Fully closed gentle crease during blink
      final blinkPaint = Paint()
        ..color = isDark ? const Color(0xFF5A2A1E) : const Color(0xFF6B3326)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(eyeCenter.dx - 4, eyeCenter.dy),
        Offset(eyeCenter.dx + 4, eyeCenter.dy),
        blinkPaint,
      );
    }

    // F. Gentle Glowing Heartbeat Pulse in Chest
    final heartCenter = const Offset(8, 14);
    final heartGlow = Paint()
      ..color = const Color(0xFFF43F5E).withOpacity(0.55 * (breatheRatio - 0.94) / 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(heartCenter, 5.0, heartGlow);

    final heartDot = Paint()
      ..color = const Color(0xFFF43F5E).withOpacity(0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(heartCenter, 2.5, heartDot);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_AliveFetusPainter oldDelegate) {
    return oldDelegate.week != week ||
        oldDelegate.blinkRatio != blinkRatio ||
        oldDelegate.breatheRatio != breatheRatio ||
        oldDelegate.isDark != isDark;
  }
}

/// Custom painter for the curved trimester timeline with milestone beads
class _CurvedTrimesterTimelinePainter extends CustomPainter {
  final int currentWeek;
  final bool isDark;

  _CurvedTrimesterTimelinePainter({
    required this.currentWeek,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(12, 10)
      ..quadraticBezierTo(size.width / 2, size.height + 6, size.width - 12, 10);

    final trackPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3931) : const Color(0xFFDCE5E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, trackPaint);

    // Milestone beads at Trimester 1 (Week 12), Trimester 2 (Week 27), Trimester 3 (Week 40)
    final milestones = [
      (week: 12, label: 'T1', fraction: 0.28, color: const Color(0xFFF43F5E)),
      (week: 27, label: 'T2', fraction: 0.65, color: const Color(0xFFA855F7)),
      (week: 40, label: 'T3', fraction: 0.95, color: const Color(0xFFF59E0B)),
    ];

    for (final m in milestones) {
      final isReached = currentWeek >= m.week;
      final x = 12 + (size.width - 24) * m.fraction;
      // Quadratic Bezier y coordinate at fraction t
      final t = m.fraction;
      final y = (1 - t) * (1 - t) * 10 + 2 * (1 - t) * t * (size.height + 6) + t * t * 10;

      final beadPaint = Paint()
        ..color = isReached ? m.color : (isDark ? const Color(0xFF243028) : const Color(0xFFCCD7D1))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 5.5, beadPaint);

      final beadBorder = Paint()
        ..color = isReached ? Colors.white : (isDark ? const Color(0xFF3B4D42) : Colors.white)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(x, y), 5.5, beadBorder);
    }
  }

  @override
  bool shouldRepaint(_CurvedTrimesterTimelinePainter oldDelegate) {
    return oldDelegate.currentWeek != currentWeek || oldDelegate.isDark != isDark;
  }
}
