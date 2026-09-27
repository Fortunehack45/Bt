import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/state/wellness_provider.dart';
import 'log_period_sheet.dart';

/// Truly Interactive, Biologically Accurate Menstrual Cycle Wheel Hero.
///
/// Features:
/// - 360-degree interactive finger-scrubbing across all days of the menstrual cycle
/// - Bi-directional synchronization between the circular dial and the 7-day calendar strip
/// - Real-time biological phase computation (Menstrual, Follicular, Fertile/Ovulation, Luteal)
/// - Real-time conception probability and physiological hormone guidance
/// - 1-tap "Return to Today" action
/// - Tactile haptic detents on every cycle day boundary
class InteractiveCycleWheelHero extends StatefulWidget {
  final VoidCallback? onCycleDetailsTap;

  const InteractiveCycleWheelHero({
    super.key,
    this.onCycleDetailsTap,
  });

  @override
  State<InteractiveCycleWheelHero> createState() => _InteractiveCycleWheelHeroState();
}

class _InteractiveCycleWheelHeroState extends State<InteractiveCycleWheelHero> {
  // Selected date being inspected
  DateTime _viewDate = DateTime.now();

  // Inspected cycle day (1 to cycleLength). If null, defaults to today's cycle day.
  int? _inspectedCycleDay;
  int _slideDirection = 1; // -1 = leftward / previous, 1 = rightward / next

  static const List<String> _weekDayNames = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  void _onDialTouch(Offset localPos, Size size, int cycleLength, int todayCycleDay) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;

    // Angle starting from top (-pi/2) going clockwise [0, 2*pi]
    double angle = math.atan2(dy, dx) + (math.pi / 2);
    if (angle < 0) angle += 2 * math.pi;

    final frac = angle / (2 * math.pi);
    final newDay = ((frac * cycleLength).floor() + 1).clamp(1, cycleLength);

    if (newDay != _inspectedCycleDay) {
      HapticService.tick();
      setState(() {
        _slideDirection = newDay >= (_inspectedCycleDay ?? todayCycleDay) ? 1 : -1;
        _inspectedCycleDay = newDay;
        // Sync _viewDate relative to today's cycle day
        final dayDiff = newDay - todayCycleDay;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        _viewDate = today.add(Duration(days: dayDiff));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

    final cycleLen = provider.averageCycleLength.round().clamp(21, 45);
    final periodDur = provider.averagePeriodDuration.round().clamp(3, 10);
    final todayCycleDay = provider.currentCycleDay.clamp(1, cycleLen);

    final activeCycleDay = (_inspectedCycleDay ?? todayCycleDay).clamp(1, cycleLen);
    final isInspectingDifferentDay = activeCycleDay != todayCycleDay;

    final ovulationDay = cycleLen - 14;
    final fertileStart = (ovulationDay - 4).clamp(1, cycleLen);
    final fertileEnd = (ovulationDay + 1).clamp(1, cycleLen);

    // Biological Phase Determination for the actively inspected cycle day
    final String phaseName;
    final Color phaseColor;
    final String statusHeadline;
    final String statusSubtitle;
    final String fertilityLabel;
    final String biologicalGuidance;
    final IconData phaseIcon;

    if (activeCycleDay <= periodDur) {
      // 1. Menstrual Phase (Days 1 to periodDur)
      phaseName = 'Menstrual Phase';
      phaseColor = const Color(0xFFF43F5E); // Rose
      phaseIcon = Icons.water_drop_rounded;
      statusHeadline = 'Period: Day $activeCycleDay';
      statusSubtitle = 'Active Menstruation Flow';
      fertilityLabel = 'Active Flow';
      biologicalGuidance = 'Uterine lining shedding. Rest, hydration, and soothing warmth prioritized.';
    } else if (activeCycleDay < fertileStart) {
      // 2. Follicular Phase (periodDur+1 to fertileStart-1)
      phaseName = 'Follicular Phase';
      phaseColor = const Color(0xFF10B981); // Emerald / Sage
      phaseIcon = Icons.spa_rounded;
      statusHeadline = 'Cycle Day $activeCycleDay of $cycleLen';
      statusSubtitle = 'Estrogen Rising & Renewal';
      fertilityLabel = 'Low Conception';
      biologicalGuidance = 'Estrogen rising. High physical stamina, mental clarity, and renewal.';
    } else if (activeCycleDay >= fertileStart && activeCycleDay <= fertileEnd) {
      // 3. Fertile Window & Ovulation (fertileStart to fertileEnd)
      if (activeCycleDay == ovulationDay) {
        phaseName = 'Ovulation Peak';
        phaseColor = const Color(0xFFA855F7); // Purple / Violet
        phaseIcon = Icons.wb_sunny_rounded;
        statusHeadline = 'Ovulation Day $activeCycleDay';
        statusSubtitle = 'LH Surge & Egg Release';
        fertilityLabel = 'Peak Fertility';
        biologicalGuidance = 'LH peak triggers egg release. Peak fertility and conception probability.';
      } else {
        phaseName = 'Fertile Window';
        phaseColor = const Color(0xFF06B6D4); // Cyan
        phaseIcon = Icons.flare_rounded;
        statusHeadline = 'Cycle Day $activeCycleDay of $cycleLen';
        statusSubtitle = 'High Fertility Window';
        fertilityLabel = 'High Fertility';
        biologicalGuidance = 'High conception probability leading to ovulation. Cervical fluid optimal.';
      }
    } else {
      // 4. Luteal Phase (fertileEnd+1 to cycleLen)
      phaseName = 'Luteal Phase';
      phaseColor = const Color(0xFFF59E0B); // Amber / Gold
      phaseIcon = Icons.bedtime_rounded;
      final daysUntilNext = cycleLen - activeCycleDay + 1;
      statusHeadline = 'Period in $daysUntilNext ${daysUntilNext == 1 ? 'day' : 'days'}';
      statusSubtitle = 'Progesterone Dominant';
      fertilityLabel = 'Low Fertility';
      biologicalGuidance = 'Progesterone dominant. Basal temperature elevates. Prioritize magnesium and restorative sleep.';
    }

    // Generate 7-day strip centered on today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final centerDate = _viewDate;
    final weekStart = centerDate.subtract(const Duration(days: 3));
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Horizontal 7-Day Strip with Interactive Day Tap
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
                  final dayDiff = d.difference(today).inDays;
                  int computedCycleDay = (todayCycleDay + dayDiff) % cycleLen;
                  if (computedCycleDay <= 0) computedCycleDay += cycleLen;

                  setState(() {
                    _slideDirection = d.isAfter(_viewDate) ? 1 : -1;
                    _viewDate = d;
                    _inspectedCycleDay = computedCycleDay;
                  });
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
          const SizedBox(height: 12),

          // 2. Interactive Biological Cycle Wheel (Touch & Scrub Capable)
          LayoutBuilder(
            builder: (context, constraints) {
              final dialSize = math.min(constraints.maxWidth, 272.0);

              return Center(
                child: SizedBox(
                  width: dialSize,
                  height: dialSize,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _onDialTouch(details.localPosition, Size(dialSize, dialSize), cycleLen, todayCycleDay),
                    onPanStart: (details) => _onDialTouch(details.localPosition, Size(dialSize, dialSize), cycleLen, todayCycleDay),
                    onPanUpdate: (details) => _onDialTouch(details.localPosition, Size(dialSize, dialSize), cycleLen, todayCycleDay),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(dialSize, dialSize),
                          painter: _TrulyInteractiveCyclePainter(
                            cycleLength: cycleLen,
                            periodDuration: periodDur,
                            activeCycleDay: activeCycleDay,
                            todayCycleDay: todayCycleDay,
                            ovulationDay: ovulationDay,
                            fertileStart: fertileStart,
                            fertileEnd: fertileEnd,
                            isDark: isDark,
                            phaseColor: phaseColor,
                          ),
                        ),

                        // Center Informational Core — Guaranteed generous breathing room with directional slide
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(_slideDirection * 0.35, 0.0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                child: FadeTransition(opacity: animation, child: child),
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey<int>(activeCycleDay),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Phase Pill & Link
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
                                        Icon(phaseIcon, size: 13, color: phaseColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          phaseName,
                                          style: TextStyle(
                                            fontFamily: AppTypography.fontFamily,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: phaseColor,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(Icons.chevron_right_rounded, size: 14, color: phaseColor),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 3),

                                  // Large Headline
                                  Text(
                                    statusHeadline,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      height: 1.15,
                                      letterSpacing: -0.4,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Subtitle
                                  Text(
                                    statusSubtitle,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 5),

                                  // Compact Fertility Badge (Short, crisp, never touching rim)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: phaseColor.withOpacity(0.14),
                                      borderRadius: AppRadii.roundedPill,
                                      border: Border.all(
                                        color: phaseColor.withOpacity(0.32),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      fertilityLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: phaseColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // 3. Quick Stepper & Return Navigation Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left_rounded, size: 28),
                tooltip: 'Previous Day',
                onPressed: activeCycleDay > 1
                    ? () {
                        HapticService.tick();
                        final newDay = activeCycleDay - 1;
                        setState(() {
                          _slideDirection = -1;
                          _inspectedCycleDay = newDay;
                          final diff = newDay - todayCycleDay;
                          _viewDate = today.add(Duration(days: diff));
                        });
                      }
                    : null,
              ),
              const SizedBox(width: 4),

              // Responsive Informational Day Pill + Return to Today reset chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.08),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(color: phaseColor.withOpacity(0.2), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: phaseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isInspectingDifferentDay
                          ? 'Inspecting • Day $activeCycleDay of $cycleLen'
                          : 'Today • Day $todayCycleDay of $cycleLen',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: phaseColor,
                      ),
                    ),
                    if (isInspectingDifferentDay) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticService.selection();
                          setState(() {
                            _slideDirection = activeCycleDay < todayCycleDay ? 1 : -1;
                            _inspectedCycleDay = todayCycleDay;
                            _viewDate = today;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: phaseColor.withOpacity(0.18),
                            borderRadius: AppRadii.roundedPill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded, size: 12, color: phaseColor),
                              const SizedBox(width: 2),
                              Text(
                                'Today',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: phaseColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.arrow_right_rounded, size: 28),
                tooltip: 'Next Day',
                onPressed: activeCycleDay < cycleLen
                    ? () {
                        HapticService.tick();
                        final newDay = activeCycleDay + 1;
                        setState(() {
                          _slideDirection = 1;
                          _inspectedCycleDay = newDay;
                          final diff = newDay - todayCycleDay;
                          _viewDate = today.add(Duration(days: diff));
                        });
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Biological Hormone & Symptom Guidance Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141C17) : const Color(0xFFF8FAF9),
              borderRadius: AppRadii.roundedMd,
              border: Border.all(
                color: isDark ? const Color(0xFF243329) : const Color(0xFFE2EBE5),
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights_rounded, size: 16, color: phaseColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    biologicalGuidance,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Bottom Action: "Today" Jump Pill & "Log Flow / Symptoms" CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  HapticService.selection();
                  setState(() {
                    _viewDate = DateTime.now();
                    _inspectedCycleDay = todayCycleDay;
                  });
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

/// Custom painter for the wide luxury Menstrual Cycle Wheel.
/// Renders 4 biological phase arcs with precision graduation dots,
/// ovulation peak beacon, curved background borders hugging rounded caps,
/// and a glowing draggable active-day thumb badge.
class _TrulyInteractiveCyclePainter extends CustomPainter {
  final int cycleLength;
  final int periodDuration;
  final int activeCycleDay;
  final int todayCycleDay;
  final int ovulationDay;
  final int fertileStart;
  final int fertileEnd;
  final bool isDark;
  final Color phaseColor;

  _TrulyInteractiveCyclePainter({
    required this.cycleLength,
    required this.periodDuration,
    required this.activeCycleDay,
    required this.todayCycleDay,
    required this.ovulationDay,
    required this.fertileStart,
    required this.fertileEnd,
    required this.isDark,
    required this.phaseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 17.5;
    final radius = (size.width - strokeWidth - 12) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final cardBg = isDark ? const Color(0xFF141C17) : Colors.white;

    // 1. Base Channel Track
    final trackPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Micro dots for each cycle day
    final dotPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3931) : const Color(0xFFDEE7E1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < cycleLength; i++) {
      final angle = -math.pi / 2 + (i / cycleLength) * 2 * math.pi;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.4, dotPaint);
    }

    // Helper: Draw arc segment with round caps and protective curved border mask
    // to strictly prevent adjacent arc bleed and render an elegant curved boundary contour
    void drawSegmentWithCurvedBorder({
      required double startAngle,
      required double sweepAngle,
      required Color color,
      double opacity = 1.0,
    }) {
      if (sweepAngle <= 0.001) return;
      const double gapAngle = 0.052; // ~3.0 degrees of clean separation
      final effectiveStart = startAngle + (gapAngle / 2);
      final effectiveSweep = sweepAngle - gapAngle;
      if (effectiveSweep <= 0.005) return;

      const capRadius = (strokeWidth / 2) + 2.5;

      // Start cap coordinates
      final startCapX = center.dx + radius * math.cos(effectiveStart);
      final startCapY = center.dy + radius * math.sin(effectiveStart);

      // End cap coordinates
      final endAngle = effectiveStart + effectiveSweep;
      final endCapX = center.dx + radius * math.cos(endAngle);
      final endCapY = center.dy + radius * math.sin(endAngle);

      // 1. Background Mask Circles at caps — creates the curved border hugging the end of the arc
      final maskPaint = Paint()
        ..color = cardBg
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(startCapX, startCapY), capRadius, maskPaint);
      canvas.drawCircle(Offset(endCapX, endCapY), capRadius, maskPaint);

      // 2. Draw the rounded phase arc
      final arcPaint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, effectiveStart, effectiveSweep, false, arcPaint);
    }

    // 3. Menstrual Phase Arc (Days 1 to periodDuration, Rose)
    final periodSweep = (periodDuration / cycleLength) * 2 * math.pi;
    drawSegmentWithCurvedBorder(
      startAngle: -math.pi / 2,
      sweepAngle: periodSweep,
      color: const Color(0xFFF43F5E),
    );

    // 4. Follicular Phase Arc (Muted Mint/Emerald #10B981)
    final follicularStartAngle = -math.pi / 2 + periodSweep;
    final follicularDays = (fertileStart - periodDuration - 1).clamp(0, cycleLength);
    final follicularSweep = (follicularDays / cycleLength) * 2 * math.pi;
    drawSegmentWithCurvedBorder(
      startAngle: follicularStartAngle,
      sweepAngle: follicularSweep,
      color: const Color(0xFF10B981),
      opacity: 0.40,
    );

    // 5. Fertile Window Arc (Cyan #06B6D4)
    final fertileStartAngle = -math.pi / 2 + ((fertileStart - 1) / cycleLength) * 2 * math.pi;
    final fertileDays = (fertileEnd - fertileStart + 1).clamp(0, cycleLength);
    final fertileSweep = (fertileDays / cycleLength) * 2 * math.pi;
    drawSegmentWithCurvedBorder(
      startAngle: fertileStartAngle,
      sweepAngle: fertileSweep,
      color: const Color(0xFF06B6D4),
    );

    // 6. Ovulation Peak Indicator (Day 14 Beacon)
    // Only render the beacon if not actively inspecting ovulation day,
    // as the active thumb already highlights and centers on that exact position.
    if (activeCycleDay != ovulationDay) {
      final ovAngle = -math.pi / 2 + ((ovulationDay - 0.5) / cycleLength) * 2 * math.pi;
      final ovX = center.dx + radius * math.cos(ovAngle);
      final ovY = center.dy + radius * math.sin(ovAngle);

      final ovBeaconPaint = Paint()
        ..color = const Color(0xFFA855F7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(ovX, ovY), 5.5, ovBeaconPaint);

      final ovBeaconBorder = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(ovX, ovY), 5.5, ovBeaconBorder);
    }

    // 7. Luteal Phase Arc (Warm Amber #F59E0B)
    final lutealStartAngle = -math.pi / 2 + (fertileEnd / cycleLength) * 2 * math.pi;
    final lutealDays = (cycleLength - fertileEnd).clamp(0, cycleLength);
    final lutealSweep = (lutealDays / cycleLength) * 2 * math.pi;
    drawSegmentWithCurvedBorder(
      startAngle: lutealStartAngle,
      sweepAngle: lutealSweep,
      color: const Color(0xFFF59E0B),
      opacity: 0.40,
    );

    // 8. Active Floating Thumb Badge
    final thumbAngle = -math.pi / 2 + ((activeCycleDay - 0.5) / cycleLength) * 2 * math.pi;
    final thumbX = center.dx + radius * math.cos(thumbAngle);
    final thumbY = center.dy + radius * math.sin(thumbAngle);

    // Outer glow aura
    final glowPaint = Paint()
      ..color = phaseColor.withOpacity(0.40)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(thumbX, thumbY), 16.0, glowPaint);

    // White core thumb
    final thumbCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, thumbY), 13.0, thumbCorePaint);

    // Ring border
    final thumbBorderPaint = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(thumbX, thumbY), 13.0, thumbBorderPaint);

    // Day number inside thumb
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$activeCycleDay',
        style: TextStyle(
          fontSize: activeCycleDay >= 10 ? 9.5 : 11,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1E293B),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(thumbX - textPainter.width / 2, thumbY - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _TrulyInteractiveCyclePainter oldDelegate) {
    return oldDelegate.activeCycleDay != activeCycleDay ||
        oldDelegate.todayCycleDay != todayCycleDay ||
        oldDelegate.cycleLength != cycleLength ||
        oldDelegate.periodDuration != periodDuration ||
        oldDelegate.isDark != isDark ||
        oldDelegate.phaseColor != phaseColor;
  }
}
