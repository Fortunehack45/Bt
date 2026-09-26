import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/models/gestational_database.dart';
import '../../../domain/state/wellness_provider.dart';
import 'log_pregnancy_wellness_sheet.dart';

/// Truly Interactive, Biologically Accurate 40-Week Gestational Progress Hero Portal.
///
/// Features:
/// - Tactile circular dial scrubbing across all 40 weeks of human pregnancy
/// - Real-time medical data lookup from [GestationalDatabase] (fetal dimensions, milestones, maternal guidance)
/// - Trimester segmented color arcs (T1 Rose, T2 Purple, T3 Amber) with boundary dividers
/// - Guaranteed overflow-proof cards and metrics displays
/// - Quick trimester jumping and 1-tap "Jump to Current Week" return action
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
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  // Selected week being actively inspected on the dial (1 to 40)
  int? _inspectedWeek;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  void _onDialTouch(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;

    // Angle starting from top (-pi/2) going clockwise [0, 2*pi]
    double angle = math.atan2(dy, dx) + (math.pi / 2);
    if (angle < 0) angle += 2 * math.pi;

    final weekFrac = angle / (2 * math.pi);
    final newWeek = (weekFrac * 40).round().clamp(1, 40);

    if (newWeek != _inspectedWeek) {
      HapticService.tick();
      setState(() => _inspectedWeek = newWeek);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final preg = provider.pregnancyData;

    final actualWeek = preg?.currentWeek ?? 12;
    final currentDay = preg?.currentDayOfCurrentWeek ?? 0;
    final due = preg?.dueDate ?? DateTime.now().add(const Duration(days: 196));
    final daysUntilDue = preg?.daysUntilDueDate ?? 196;

    final activeWeek = (_inspectedWeek ?? actualWeek).clamp(1, 40);
    final isViewingDifferentWeek = activeWeek != actualWeek;

    final weekInfo = GestationalDatabase.getWeekInfo(activeWeek);
    final progressRatio = (activeWeek / 40.0).clamp(0.0, 1.0);

    // Dynamic accent color based on the active week's trimester
    final Color trimesterColor;
    if (weekInfo.trimester == 1) {
      trimesterColor = const Color(0xFFF43F5E); // First Trimester Rose
    } else if (weekInfo.trimester == 2) {
      trimesterColor = const Color(0xFFA855F7); // Second Trimester Orchid
    } else {
      trimesterColor = const Color(0xFFF59E0B); // Third Trimester Amber
    }

    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Trimester Phase Legend & Interactive Jump Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTrimesterTab(
                label: 'T1: W1–12',
                trimesterNum: 1,
                color: const Color(0xFFF43F5E),
                isSelected: weekInfo.trimester == 1,
                isDark: isDark,
                onTap: () {
                  HapticService.selection();
                  setState(() => _inspectedWeek = 6);
                },
              ),
              _buildTrimesterTab(
                label: 'T2: W13–27',
                trimesterNum: 2,
                color: const Color(0xFFA855F7),
                isSelected: weekInfo.trimester == 2,
                isDark: isDark,
                onTap: () {
                  HapticService.selection();
                  setState(() => _inspectedWeek = 20);
                },
              ),
              _buildTrimesterTab(
                label: 'T3: W28–40',
                trimesterNum: 3,
                color: const Color(0xFFF59E0B),
                isSelected: weekInfo.trimester == 3,
                isDark: isDark,
                onTap: () {
                  HapticService.selection();
                  setState(() => _inspectedWeek = 34);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Interactive Gestational Dial with Week Scrubbing
          LayoutBuilder(
            builder: (context, constraints) {
              final dialSize = math.min(constraints.maxWidth, 260.0);

              return Center(
                child: SizedBox(
                  width: dialSize,
                  height: dialSize,
                  child: GestureDetector(
                    onPanStart: (details) => _onDialTouch(details.localPosition, Size(dialSize, dialSize)),
                    onPanUpdate: (details) => _onDialTouch(details.localPosition, Size(dialSize, dialSize)),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circular Custom Painter
                        CustomPaint(
                          size: Size(dialSize, dialSize),
                          painter: _GestationalDialPainter(
                            currentWeek: activeWeek,
                            actualWeek: actualWeek,
                            isDark: isDark,
                            accentColor: trimesterColor,
                          ),
                        ),

                        // Center Informational Hub
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Heart icon with subtle pulse
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: trimesterColor.withOpacity(0.14),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: 20,
                                  color: trimesterColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Week Readout
                            Text(
                              'Week $activeWeek',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -0.6,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),

                            // Trimester & Day Description
                            Text(
                              isViewingDifferentWeek
                                  ? weekInfo.trimesterLabel
                                  : 'Day $currentDay • ${weekInfo.trimesterLabel}',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: trimesterColor,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Percentage & Total Progress Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
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
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ],
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
                tooltip: 'Previous Week',
                onPressed: activeWeek > 1
                    ? () {
                        HapticService.tick();
                        setState(() => _inspectedWeek = activeWeek - 1);
                      }
                    : null,
              ),
              const SizedBox(width: 4),

              if (isViewingDifferentWeek)
                TextButton.icon(
                  onPressed: () {
                    HapticService.selection();
                    setState(() => _inspectedWeek = actualWeek);
                  },
                  icon: const Icon(Icons.my_location_rounded, size: 14),
                  label: Text(
                    'Return to Current Week ($actualWeek)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: trimesterColor,
                    backgroundColor: trimesterColor.withOpacity(0.12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2),
                    borderRadius: AppRadii.roundedPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 14, color: trimesterColor),
                      const SizedBox(width: 6),
                      Text(
                        'Touch or drag dial to explore weeks',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.arrow_right_rounded, size: 28),
                tooltip: 'Next Week',
                onPressed: activeWeek < 40
                    ? () {
                        HapticService.tick();
                        setState(() => _inspectedWeek = activeWeek + 1);
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Due Date Countdown Banner (Flexible with no overflow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A241E) : const Color(0xFFF3F7F4),
              borderRadius: AppRadii.roundedPill,
              border: Border.all(
                color: isDark ? const Color(0xFF26362C) : const Color(0xFFE2EBE5),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available_rounded, size: 15, color: trimesterColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '$daysUntilDue ${daysUntilDue == 1 ? 'day' : 'days'} until estimated due date (${_months[due.month - 1]} ${due.day})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Baby Developmental Size Card (Completely Overflow-Proof)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141C17) : const Color(0xFFF8FAF9),
              borderRadius: AppRadii.roundedMd,
              border: Border.all(
                color: isDark ? const Color(0xFF243329) : const Color(0xFFE2EBE5),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title + Progress Badge (Fixed overflow with Expanded)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Baby is the Size of a ${weekInfo.babySizeFruit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: trimesterColor.withOpacity(0.14),
                        borderRadius: AppRadii.roundedPill,
                      ),
                      child: Text(
                        '${(progressRatio * 100).toInt()}% • 40 Wks',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: trimesterColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  weekInfo.babySizeComparison,
                  style: AppTypography.caption(isDark).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 10),

                // Metrics Chips: Length & Weight
                Row(
                  children: [
                    _buildMetricChip(
                      icon: Icons.straighten_rounded,
                      label: '~${weekInfo.estimatedLengthCm} cm (${weekInfo.estimatedLengthInches} in)',
                      color: trimesterColor,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      icon: Icons.scale_rounded,
                      label: '~${weekInfo.estimatedWeightGrams.toInt()} g (${weekInfo.formattedWeightImperial})',
                      color: trimesterColor,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Fetal Milestone Readout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.child_care_rounded, size: 16, color: trimesterColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        weekInfo.fetalMilestone,
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
                const SizedBox(height: 8),

                // Maternal Change Insight
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.spa_rounded, size: 16, color: isDark ? AppColors.primary : AppColors.primaryDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        weekInfo.maternalChanges,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 6. Action Button: Log Today's Maternal Wellbeing
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

  Widget _buildTrimesterTab({
    required String label,
    required int trimesterNum,
    required Color color,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.16)
              : (isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2)),
          borderRadius: AppRadii.roundedPill,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? color
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1D2621) : const Color(0xFFEFF4F1),
          borderRadius: AppRadii.roundedPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the 40-week Gestational Dial.
/// Accurately renders 3 continuous trimester segments with divider ticks,
/// 40 micro-graduation dots, and a responsive active-week thumb badge.
class _GestationalDialPainter extends CustomPainter {
  final int currentWeek;
  final int actualWeek;
  final bool isDark;
  final Color accentColor;

  _GestationalDialPainter({
    required this.currentWeek,
    required this.actualWeek,
    required this.isDark,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 20.0;
    final radius = (size.width - strokeWidth - 10) / 2;

    // 1. Base Track Channel
    final baseTrackPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, baseTrackPaint);

    // 2. Micro dots for each of the 40 weeks
    final dotPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3931) : const Color(0xFFDEE7E1)
      ..style = PaintingStyle.fill;

    for (int w = 1; w <= 40; w++) {
      final angle = -math.pi / 2 + (w / 40.0) * 2 * math.pi;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.4, dotPaint);
    }

    // 3. Segmented Trimester Arcs up to currentWeek
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Trimester 1 (Weeks 1 to 12)
    final t1Weeks = currentWeek.clamp(0, 12);
    if (t1Weeks > 0) {
      final t1Sweep = (t1Weeks / 40.0) * 2 * math.pi;
      final t1Paint = Paint()
        ..color = const Color(0xFFF43F5E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = currentWeek <= 12 ? StrokeCap.round : StrokeCap.butt;
      canvas.drawArc(rect, -math.pi / 2, t1Sweep, false, t1Paint);
    }

    // Trimester 2 (Weeks 13 to 27)
    if (currentWeek > 12) {
      final t2Weeks = (currentWeek - 12).clamp(0, 15);
      final t2StartAngle = -math.pi / 2 + (12 / 40.0) * 2 * math.pi;
      final t2Sweep = (t2Weeks / 40.0) * 2 * math.pi;
      final t2Paint = Paint()
        ..color = const Color(0xFFA855F7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = currentWeek <= 27 ? StrokeCap.round : StrokeCap.butt;
      canvas.drawArc(rect, t2StartAngle, t2Sweep, false, t2Paint);
    }

    // Trimester 3 (Weeks 28 to 40)
    if (currentWeek > 27) {
      final t3Weeks = (currentWeek - 27).clamp(0, 13);
      final t3StartAngle = -math.pi / 2 + (27 / 40.0) * 2 * math.pi;
      final t3Sweep = (t3Weeks / 40.0) * 2 * math.pi;
      final t3Paint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, t3StartAngle, t3Sweep, false, t3Paint);
    }

    // 4. Trimester dividing notches at Week 12 and Week 27
    _drawTrimesterDivider(canvas, center, radius, strokeWidth, 12);
    _drawTrimesterDivider(canvas, center, radius, strokeWidth, 27);

    // 5. Active Floating Week Thumb Badge
    final thumbAngle = -math.pi / 2 + (currentWeek / 40.0) * 2 * math.pi;
    final thumbX = center.dx + radius * math.cos(thumbAngle);
    final thumbY = center.dy + radius * math.sin(thumbAngle);

    // Outer glow aura
    final glowPaint = Paint()
      ..color = accentColor.withOpacity(0.35)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(thumbX, thumbY), 16.0, glowPaint);

    // White core thumb
    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, thumbY), 13.0, thumbPaint);

    // Border ring
    final borderPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(thumbX, thumbY), 13.0, borderPaint);

    // Week text inside thumb
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$currentWeek',
        style: TextStyle(
          fontSize: currentWeek >= 10 ? 9.5 : 11,
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

  void _drawTrimesterDivider(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
    int week,
  ) {
    final angle = -math.pi / 2 + (week / 40.0) * 2 * math.pi;
    final rInner = radius - (strokeWidth / 2) - 2;
    final rOuter = radius + (strokeWidth / 2) + 2;

    final p1 = Offset(center.dx + rInner * math.cos(angle), center.dy + rInner * math.sin(angle));
    final p2 = Offset(center.dx + rOuter * math.cos(angle), center.dy + rOuter * math.sin(angle));

    final dividerPaint = Paint()
      ..color = isDark ? Colors.white54 : Colors.black45
      ..strokeWidth = 1.5;
    canvas.drawLine(p1, p2, dividerPaint);
  }

  @override
  bool shouldRepaint(covariant _GestationalDialPainter oldDelegate) {
    return oldDelegate.currentWeek != currentWeek ||
        oldDelegate.actualWeek != actualWeek ||
        oldDelegate.isDark != isDark ||
        oldDelegate.accentColor != accentColor;
  }
}
