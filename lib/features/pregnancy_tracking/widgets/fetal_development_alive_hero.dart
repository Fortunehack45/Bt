import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/state/wellness_provider.dart';
import 'log_pregnancy_wellness_sheet.dart';

/// Luxury Gestational Progress Hero Portal for Pregnancy Tracking.
/// Features a wide, solid multi-trimester circular dial, active week floating badge,
/// maternal heartbeat glow, live gestational age readout, and developmental baby size card.
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
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;
  late Animation<double> _sweepAnimation;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _sweepAnimation = CurvedAnimation(
      parent: _sweepController,
      curve: Curves.easeOutCubic,
    );
    _sweepController.forward();
  }

  @override
  void dispose() {
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

    final week = preg?.currentWeek ?? 22;
    final day = preg?.currentDayOfCurrentWeek ?? 2;
    final due = preg?.dueDate ?? DateTime.now().add(const Duration(days: 131));
    final daysUntilDue = preg?.daysUntilDueDate ?? 131;
    final fruit = preg?.babySizeFruit ?? 'Papaya';
    final lengthCm = preg?.estimatedLengthCm ?? 27.8;
    final weightG = preg?.estimatedWeightGrams ?? 430.0;
    final comparison = preg?.babySizeComparison ?? 'Size of a golden papaya (~27.8cm)';

    final progressRatio = (week / 40.0).clamp(0.0, 1.0);

    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        children: [
          // 1. Trimester Phase Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Trimester 1', const Color(0xFFF43F5E)),
              const SizedBox(width: 16),
              _buildLegendItem('Trimester 2', const Color(0xFFA855F7)),
              const SizedBox(width: 16),
              _buildLegendItem('Trimester 3', const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Wide Luxury Gestational Dial with Center Sanctuary
          AnimatedBuilder(
            animation: _sweepAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(250, 250),
                      painter: _GestationalDialPainter(
                        currentWeek: week,
                        sweepProgress: _sweepAnimation.value,
                        isDark: isDark,
                      ),
                    ),

                    // Center Informational Sanctuary
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Soft maternal icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA855F7).withOpacity(0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 22,
                            color: Color(0xFFA855F7),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Week Readout
                        Text(
                          'Week $week',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.6,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 3),

                        // Day & Trimester
                        Text(
                          'Day $day • ${preg?.trimesterLabel ?? 'Second Trimester'}',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFA855F7),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Percentage & Total Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2),
                            borderRadius: AppRadii.roundedPill,
                            border: Border.all(
                              color: isDark ? const Color(0xFF2C3931) : const Color(0xFFDEE7E1),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '${(progressRatio * 100).toInt()}% • 40 Weeks Total',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // 3. Due Date Countdown Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2),
              borderRadius: AppRadii.roundedPill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_rounded, size: 14, color: Color(0xFFA855F7)),
                const SizedBox(width: 6),
                Text(
                  '$daysUntilDue ${daysUntilDue == 1 ? 'day' : 'days'} until estimated due date (${_months[due.month - 1]} ${due.day})',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withOpacity(0.14),
                        borderRadius: AppRadii.roundedPill,
                      ),
                      child: Text(
                        '${(progressRatio * 100).toInt()}% • 40 Wks',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA855F7),
                        ),
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

/// Custom painter for the wide luxury Gestational Dial.
/// Features a 22px solid background channel with embedded interval markers,
/// segmented trimester progress arcs, and an elevated floating active-week thumb.
class _GestationalDialPainter extends CustomPainter {
  final int currentWeek;
  final double sweepProgress;
  final bool isDark;

  _GestationalDialPainter({
    required this.currentWeek,
    required this.sweepProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 22.0;
    final radius = (size.width - strokeWidth - 8) / 2;

    // 1. Broad solid background track channel
    final trackPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Subtle 40-week division tick dots embedded in the track
    final dotPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3931) : const Color(0xFFDEE7E1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      final angle = -math.pi / 2 + (i / 40.0) * 2 * math.pi;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.8, dotPaint);
    }

    // 2. Segment 1: Trimester 1 (Weeks 1–12) — Rose arc
    const t1Sweep = (12.0 / 40.0) * 2 * math.pi;
    final t1Progress = currentWeek >= 12 ? 1.0 : (currentWeek / 12.0);
    final t1Paint = Paint()
      ..color = const Color(0xFFF43F5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      t1Sweep * t1Progress * sweepProgress,
      false,
      t1Paint,
    );

    // 3. Segment 2: Trimester 2 (Weeks 13–27) — Royal Violet arc
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

    // 4. Segment 3: Trimester 3 (Weeks 28–40) — Golden Amber arc
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

    // 5. Active Current Week Elevated Floating Thumb
    final weekFraction = (currentWeek / 40.0).clamp(0.0, 1.0);
    final thumbAngle = -math.pi / 2 + weekFraction * 2 * math.pi;
    final thumbX = center.dx + radius * math.cos(thumbAngle);
    final thumbY = center.dy + radius * math.sin(thumbAngle);

    // Floating drop shadow under thumb
    final thumbShadow = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(thumbX, thumbY + 1.5), 15.0, thumbShadow);

    // Solid circular disc
    final thumbFill = Paint()
      ..color = isDark ? const Color(0xFF231B30) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, thumbY), 15.0, thumbFill);

    // Violet ring border
    final thumbBorder = Paint()
      ..color = const Color(0xFFA855F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(thumbX, thumbY), 15.0, thumbBorder);

    // Two-line clean label: 'Wk' on top, '$currentWeek' below
    final labelTop = TextPainter(
      text: const TextSpan(
        text: 'Wk',
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFFA855F7),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelTop.paint(canvas, Offset(thumbX - labelTop.width / 2, thumbY - 10));

    final labelBottom = TextPainter(
      text: TextSpan(
        text: '$currentWeek',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelBottom.paint(canvas, Offset(thumbX - labelBottom.width / 2, thumbY - 1));
  }

  @override
  bool shouldRepaint(_GestationalDialPainter oldDelegate) {
    return oldDelegate.currentWeek != currentWeek ||
        oldDelegate.sweepProgress != sweepProgress ||
        oldDelegate.isDark != isDark;
  }
}
