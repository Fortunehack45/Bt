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
import 'log_period_sheet.dart';

/// Interactive Menstrual Cycle Wheel Hero matching the reference design in Reference Image 1.
/// Features a top week day strip with teardrop pointer, multi-segmented circular phase arcs,
/// active cycle day position thumb, and live fertility window readout.
class InteractiveCycleWheelHero extends StatefulWidget {
  final VoidCallback? onCycleDetailsTap;

  const InteractiveCycleWheelHero({
    super.key,
    this.onCycleDetailsTap,
  });

  @override
  State<InteractiveCycleWheelHero> createState() => _InteractiveCycleWheelHeroState();
}

class _InteractiveCycleWheelHeroState extends State<InteractiveCycleWheelHero> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;
  DateTime _viewDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  static const List<String> _weekDayNames = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final prediction = provider.periodPrediction;
    final activePeriod = provider.activePeriod;
    final lastPeriod = provider.lastRecordedPeriod;

    final cycleLen = provider.averageCycleLength.round();
    final periodDur = provider.averagePeriodDuration.round();
    final currentDay = provider.currentCycleDay;

    // Relative day position on the wheel (0.0 to 1.0)
    final dayRatio = (currentDay / cycleLen).clamp(0.0, 1.0);

    // Days calculation for status headline
    String statusHeadline;
    String statusSubtitle;
    if (activePeriod != null) {
      statusHeadline = 'Period: Day $currentDay';
      statusSubtitle = 'Active Menstruation Flow';
    } else if (prediction.estimatedNextPeriodDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final next = DateTime(
        prediction.estimatedNextPeriodDate!.year,
        prediction.estimatedNextPeriodDate!.month,
        prediction.estimatedNextPeriodDate!.day,
      );
      final diff = next.difference(today).inDays;
      if (diff > 0) {
        statusHeadline = 'Period in $diff ${diff == 1 ? 'day' : 'days'}';
        statusSubtitle = prediction.currentPhase.displayName;
      } else if (diff == 0) {
        statusHeadline = 'Period Expected Today';
        statusSubtitle = 'Menstrual phase transition';
      } else {
        statusHeadline = 'Period: ${diff.abs()} ${diff.abs() == 1 ? 'day' : 'days'} late';
        statusSubtitle = 'Natural cycle variability';
      }
    } else {
      statusHeadline = 'Cycle Day $currentDay';
      statusSubtitle = 'Regular follicular phase';
    }

    // Fertility badge label and colors
    String fertilityLabel;
    Color fertilityColor;
    if (prediction.currentPhase == PeriodPhase.ovulation) {
      fertilityLabel = 'Peak Fertility Window';
      fertilityColor = const Color(0xFFA855F7);
    } else if (currentDay >= (cycleLen - 19) && currentDay <= (cycleLen - 11)) {
      fertilityLabel = 'High Fertility';
      fertilityColor = const Color(0xFF06B6D4);
    } else if (activePeriod != null) {
      fertilityLabel = 'Menstrual Flow Active';
      fertilityColor = const Color(0xFFF43F5E);
    } else {
      fertilityLabel = 'Low Fertility';
      fertilityColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    }

    // Generate 7-day strip centered on today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 3));
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return SolidWellnessCard(
      padding: const EdgeInsets.only(top: 14, bottom: 18, left: 16, right: 16),
      child: Column(
        children: [
          // 1. Horizontal Week Day Strip with Teardrop Drip Pointer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((d) {
              final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
              final isSelected = d.year == _viewDate.year && d.month == _viewDate.month && d.day == _viewDate.day;
              final isPeriod = provider.isPeriodDay(d);
              final isFertile = provider.isFertileWindowDay(d);

              return GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _viewDate = d);
                },
                child: Column(
                  children: [
                    Text(
                      isToday ? 'Today' : _weekDayNames[d.weekday - 1],
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: isToday ? 11 : 12,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isToday
                            ? (isDark ? AppColors.primary : AppColors.primaryDark)
                            : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF33423A) : const Color(0xFFD6E2DA))
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(color: isDark ? AppColors.primary : AppColors.primaryDark, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        '${d.day}',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: (isToday || isSelected) ? FontWeight.w800 : FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Indicators under day (pink for period, cyan/violet for fertile)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPeriod)
                          Container(
                            width: 4.5,
                            height: 4.5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF43F5E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (isFertile)
                          Container(
                            width: 4.5,
                            height: 4.5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: const BoxDecoration(
                              color: Color(0xFF06B6D4),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          // Teardrop / droplet pointer connecting today to the wheel
          CustomPaint(
            size: const Size(20, 10),
            painter: _TeardropPointerPainter(
              color: isDark ? const Color(0xFF26332C) : const Color(0xFFDEE7E1),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Main Circular Cycle Wheel with Multi-Segment Phase Arcs
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, child) {
              return SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(250, 250),
                      painter: _CycleWheelPainter(
                        cycleLength: cycleLen,
                        periodDuration: periodDur,
                        currentDay: currentDay,
                        animValue: _progressAnim.value,
                        isDark: isDark,
                      ),
                    ),

                    // Center Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticService.selection();
                            if (widget.onCycleDetailsTap != null) {
                              widget.onCycleDetailsTap!();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Current cycle',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFF43F5E) : const Color(0xFFE11D48),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: isDark ? const Color(0xFFF43F5E) : const Color(0xFFE11D48),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            statusHeadline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -0.5,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: fertilityColor.withOpacity(0.16),
                            borderRadius: AppRadii.roundedPill,
                            border: Border.all(
                              color: fertilityColor.withOpacity(0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            fertilityLabel,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: fertilityColor,
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
          const SizedBox(height: 12),

          // 3. Bottom Bar: "Today" Jump Pill & "Log Flow / Symptoms" Quick Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  HapticService.selection();
                  setState(() => _viewDate = DateTime.now());
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 13),
                label: const Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  backgroundColor: isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  HapticService.selection();
                  showLogPeriodSheet(context, provider);
                },
                icon: const Icon(Icons.water_drop_rounded, size: 14, color: Colors.white),
                label: const Text(
                  'Log Flow / Symptoms',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the teardrop pointer from the week strip down to the wheel
class _TeardropPointerPainter extends CustomPainter {
  final Color color;
  _TeardropPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TeardropPointerPainter oldDelegate) => oldDelegate.color != color;
}

/// Custom painter rendering the segmented biological phase arcs (Menstrual Rose arc,
/// Fertile Cyan/Violet arc, background dotted track, Day 14 ovulation badge, and Day thumb).
class _CycleWheelPainter extends CustomPainter {
  final int cycleLength;
  final int periodDuration;
  final int currentDay;
  final double animValue;
  final bool isDark;

  _CycleWheelPainter({
    required this.cycleLength,
    required this.periodDuration,
    required this.currentDay,
    required this.animValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    // 1. Background Track (Subtle circular track with minute interval dots)
    final trackPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2822) : const Color(0xFFE5EDE8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw small track dots for all days of the cycle
    final dotPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3931) : const Color(0xFFCBD6CF)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < cycleLength; i++) {
      final angle = -math.pi / 2 + (i / cycleLength) * 2 * math.pi;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.8, dotPaint);
    }

    // 2. Period Menstrual Phase Arc (Rose / Pink from Day 1 to periodDuration)
    final periodArcSweep = (periodDuration / cycleLength) * 2 * math.pi * animValue;
    final periodPaint = Paint()
      ..color = const Color(0xFFF43F5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      periodArcSweep,
      false,
      periodPaint,
    );

    // 3. Fertile Window & Ovulation Arc (Cyan / Violet)
    // Ovulation occurs approximately 14 days before end of cycle
    final ovulationDay = cycleLength - 14;
    final fertileStartDay = ovulationDay - 4;
    final fertileEndDay = ovulationDay + 1;
    final fertileDuration = fertileEndDay - fertileStartDay;

    final fertileStartAngle = -math.pi / 2 + (fertileStartDay / cycleLength) * 2 * math.pi;
    final fertileSweepAngle = (fertileDuration / cycleLength) * 2 * math.pi * animValue;

    final fertilePaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      fertileStartAngle,
      fertileSweepAngle,
      false,
      fertilePaint,
    );

    // 4. Ovulation Peak Indicator (Day 14 circular dashed badge)
    final ovAngle = -math.pi / 2 + (ovulationDay / cycleLength) * 2 * math.pi;
    final ovX = center.dx + radius * math.cos(ovAngle);
    final ovY = center.dy + radius * math.sin(ovAngle);

    final ovBadgePaint = Paint()
      ..color = const Color(0xFFA855F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(ovX, ovY), 10.0, ovBadgePaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '14',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Color(0xFFA855F7),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(ovX - textPainter.width / 2, ovY - textPainter.height / 2),
    );

    // 5. Active Current Day Thumb Indicator
    final currentDayFraction = (currentDay / cycleLength).clamp(0.0, 1.0);
    final thumbAngle = -math.pi / 2 + currentDayFraction * 2 * math.pi;
    final thumbX = center.dx + radius * math.cos(thumbAngle);
    final thumbY = center.dy + radius * math.sin(thumbAngle);

    // Glow under thumb
    final thumbGlowPaint = Paint()
      ..color = (isDark ? AppColors.primaryDark : AppColors.primary).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(thumbX, thumbY), 12.0, thumbGlowPaint);

    // Solid thumb badge with current day label
    final thumbFill = Paint()
      ..color = isDark ? const Color(0xFF1E2822) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, thumbY), 10.0, thumbFill);

    final thumbBorder = Paint()
      ..color = isDark ? AppColors.primary : AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(thumbX, thumbY), 10.0, thumbBorder);

    final dayText = TextPainter(
      text: TextSpan(
        text: '$currentDay',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    dayText.paint(
      canvas,
      Offset(thumbX - dayText.width / 2, thumbY - dayText.height / 2),
    );
  }

  @override
  bool shouldRepaint(_CycleWheelPainter oldDelegate) {
    return oldDelegate.cycleLength != cycleLength ||
        oldDelegate.periodDuration != periodDuration ||
        oldDelegate.currentDay != currentDay ||
        oldDelegate.animValue != animValue ||
        oldDelegate.isDark != isDark;
  }
}
