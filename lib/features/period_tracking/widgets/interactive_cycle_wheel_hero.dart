import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/models/reproductive_health_models.dart';
import '../../../domain/state/wellness_provider.dart';
import 'log_period_sheet.dart';

/// Interactive Menstrual Cycle Wheel Hero matching the design in Reference Image 1.
/// Features a top week day strip with organic pointer, a wide 22px solid cycle track,
/// segmented phase arcs (Rose flow arc, Cyan fertile window), elevated floating Day thumb,
/// dashed Ovulation peak indicator, and medical-grade center typography.
class InteractiveCycleWheelHero extends StatefulWidget {
  final VoidCallback? onCycleDetailsTap;

  const InteractiveCycleWheelHero({
    super.key,
    this.onCycleDetailsTap,
  });

  @override
  State<InteractiveCycleWheelHero> createState() => _InteractiveCycleWheelHeroState();
}

class _InteractiveCycleWheelHeroState extends State<InteractiveCycleWheelHero>
    with SingleTickerProviderStateMixin {
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

    final cycleLen = provider.averageCycleLength.round();
    final periodDur = provider.averagePeriodDuration.round();
    final currentDay = provider.currentCycleDay;

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
          // 1. Horizontal Week Day Strip with Indicators
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
                    // Indicators under day (pink for period, cyan for fertile)
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
          const SizedBox(height: 6),

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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Current cycle',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF43F5E),
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: Color(0xFFF43F5E),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Text(
                            statusHeadline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              height: 1.12,
                              letterSpacing: -0.6,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          statusSubtitle,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
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
          const SizedBox(height: 14),

          // 3. Bottom Action Bar: "Today" Jump Pill & "Log Flow / Symptoms" CTA
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
                  foregroundColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  backgroundColor: isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  HapticService.selection();
                  showLogPeriodSheet(context, provider, initialDate: _viewDate);
                },
                icon: const Icon(Icons.water_drop_rounded, size: 14),
                label: const Text('Log Flow / Symptoms', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

/// Custom painter rendering the wide luxury Menstrual Cycle Wheel.
/// Features a broad 22px solid background channel with embedded interval markers,
/// segmented phase arcs (Menstrual Rose arc, Fertile Cyan arc), clean Dashed Ovulation indicator,
/// and an elevated floating active-day thumb badge.
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
    const strokeWidth = 22.0;
    final radius = (size.width - strokeWidth - 8) / 2;

    // 1. Broad solid background track channel
    final trackPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Subtle interval tick dots embedded inside the track channel
    final dotPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3931) : const Color(0xFFDEE7E1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < cycleLength; i++) {
      final angle = -math.pi / 2 + (i / cycleLength) * 2 * math.pi;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.6, dotPaint);
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

    // 3. Fertile Window Arc (Vivid Cyan / Turquoise)
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

    // 4. Ovulation Peak Indicator (Dashed circular badge on the fertile arc)
    final ovAngle = -math.pi / 2 + (ovulationDay / cycleLength) * 2 * math.pi;
    final ovX = center.dx + radius * math.cos(ovAngle);
    final ovY = center.dy + radius * math.sin(ovAngle);

    final ovFillPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ovX, ovY), 13.0, ovFillPaint);

    final ovBadgePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(Offset(ovX, ovY), 13.0, ovBadgePaint);

    final ovTop = TextPainter(
      text: const TextSpan(
        text: 'Day',
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    ovTop.paint(canvas, Offset(ovX - ovTop.width / 2, ovY - 9));

    final ovBottom = TextPainter(
      text: const TextSpan(
        text: '14',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    ovBottom.paint(canvas, Offset(ovX - ovBottom.width / 2, ovY));

    // 5. Active Current Day Elevated Floating Thumb Badge
    final currentDayFraction = (currentDay / cycleLength).clamp(0.0, 1.0);
    final thumbAngle = -math.pi / 2 + currentDayFraction * 2 * math.pi;
    final thumbX = center.dx + radius * math.cos(thumbAngle);
    final thumbY = center.dy + radius * math.sin(thumbAngle);

    // Soft drop shadow under thumb
    final thumbShadow = Paint()
      ..color = Colors.black.withOpacity(0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(thumbX, thumbY + 1.5), 15.0, thumbShadow);

    // Elevated white circular disc
    final thumbFill = Paint()
      ..color = isDark ? const Color(0xFF233129) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, thumbY), 15.0, thumbFill);

    // Crisp border matching theme
    final thumbBorder = Paint()
      ..color = isDark ? const Color(0xFF3B4E42) : const Color(0xFFDEE7E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(Offset(thumbX, thumbY), 15.0, thumbBorder);

    // Clean two-line label: 'Day' on top, '$currentDay' below
    final dayTop = TextPainter(
      text: TextSpan(
        text: 'Day',
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    dayTop.paint(canvas, Offset(thumbX - dayTop.width / 2, thumbY - 10));

    final dayBottom = TextPainter(
      text: TextSpan(
        text: '$currentDay',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    dayBottom.paint(canvas, Offset(thumbX - dayBottom.width / 2, thumbY - 1));
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
