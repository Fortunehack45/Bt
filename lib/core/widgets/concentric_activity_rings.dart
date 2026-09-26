import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Data model representing the progress and goals across the 4 core dimensions:
/// 1. Steps (Orange)
/// 2. Water (Cyan)
/// 3. Sleep (Indigo)
/// 4. Nutrition (Lime)
class ActivityRingsData {
  final double stepsRatio; // e.g. steps / stepGoal
  final double waterRatio; // e.g. waterGlasses / waterGoal
  final double sleepRatio; // e.g. sleepHours / sleepGoal
  final double nutritionRatio; // e.g. calories / calorieTarget

  const ActivityRingsData({
    required this.stepsRatio,
    required this.waterRatio,
    required this.sleepRatio,
    required this.nutritionRatio,
  });

  factory ActivityRingsData.fromValues({
    required int steps,
    required int stepGoal,
    required int waterGlasses,
    required int waterGoal,
    required double sleepHours,
    required double sleepGoalHours,
    required int calories,
    required int targetCalories,
  }) {
    return ActivityRingsData(
      stepsRatio: stepGoal > 0 ? (steps / stepGoal).clamp(0.0, 2.0) : 0.0,
      waterRatio: waterGoal > 0 ? (waterGlasses / waterGoal).clamp(0.0, 2.0) : 0.0,
      sleepRatio: sleepGoalHours > 0 ? (sleepHours / sleepGoalHours).clamp(0.0, 2.0) : 0.0,
      nutritionRatio: targetCalories > 0 ? (calories / targetCalories).clamp(0.0, 2.0) : 0.0,
    );
  }

  double get averageProgress {
    return ((stepsRatio.clamp(0.0, 1.0) +
            waterRatio.clamp(0.0, 1.0) +
            sleepRatio.clamp(0.0, 1.0) +
            nutritionRatio.clamp(0.0, 1.0)) /
        4.0);
  }

  double ratioForIndex(int index) {
    switch (index) {
      case 0:
        return stepsRatio;
      case 1:
        return waterRatio;
      case 2:
        return sleepRatio;
      case 3:
        return nutritionRatio;
      default:
        return 0.0;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityRingsData &&
        other.stepsRatio == stepsRatio &&
        other.waterRatio == waterRatio &&
        other.sleepRatio == sleepRatio &&
        other.nutritionRatio == nutritionRatio;
  }

  @override
  int get hashCode => Object.hash(stepsRatio, waterRatio, sleepRatio, nutritionRatio);
}

/// A luxury concentric 4-circle activity ring widget.
/// The 4 rings represent:
/// 1. Outer Ring: Steps walked (Orange)
/// 2. Second Ring: Water drank (Cyan)
/// 3. Third Ring: Sleep & Rest (Indigo)
/// 4. Inner Ring: Nutrition meals (Lime)
///
/// Features:
/// - Staggered, cascading sweep animation with athletic cubic easing
/// - Smooth tweening when switching days or updating targets
/// - Uniform physical channel opening so icons never get pinched on inner rings
/// - Mathematically exact icon centering at 6 o'clock (opposite of top)
/// - Solid Biothrix luxury palette (zero glowing blurs or gradients)
class ConcentricActivityRings extends StatefulWidget {
  final ActivityRingsData data;
  final double size;
  final double? strokeWidth;
  final double? ringGap;
  final bool showIcons;
  final bool animate;

  // The 4 standardized Biothrix telemetry dimension colors
  static const Color stepsColor = Color(0xFFFF9442); // Warm athletic orange
  static const Color waterColor = Color(0xFF2EB5FA); // Vital hydration cyan
  static const Color sleepColor = Color(0xFF818CF8); // Restorative circadian indigo
  static const Color nutritionColor = AppColors.primary; // Biothrix lime (#CCFF00)

  const ConcentricActivityRings({
    super.key,
    required this.data,
    this.size = 145.0,
    this.strokeWidth,
    this.ringGap,
    this.showIcons = true,
    this.animate = true,
  });

  @override
  State<ConcentricActivityRings> createState() => _ConcentricActivityRingsState();
}

class _ConcentricActivityRingsState extends State<ConcentricActivityRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ActivityRingsData _fromData = const ActivityRingsData(
    stepsRatio: 0.0,
    waterRatio: 0.0,
    sleepRatio: 0.0,
    nutritionRatio: 0.0,
  );
  late ActivityRingsData _toData;

  @override
  void initState() {
    super.initState();
    _toData = widget.data;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ConcentricActivityRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      if (widget.animate) {
        _fromData = ActivityRingsData(
          stepsRatio: _currentRatio(0),
          waterRatio: _currentRatio(1),
          sleepRatio: _currentRatio(2),
          nutritionRatio: _currentRatio(3),
        );
        _toData = widget.data;
        _controller.forward(from: 0.0);
      } else {
        _fromData = widget.data;
        _toData = widget.data;
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _currentRatio(int ringIndex) {
    final start = _fromData.ratioForIndex(ringIndex);
    final end = _toData.ratioForIndex(ringIndex);
    // Staggered cascade: Outer ring starts first, inner rings follow
    final staggerOffset = ringIndex * 0.08;
    final staggeredProgress = ((_animation.value - staggerOffset) / (1.0 - staggerOffset)).clamp(0.0, 1.0);
    return start + (end - start) * staggeredProgress;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final effectiveStrokeWidth = widget.strokeWidth ?? (size * 0.076).clamp(3.0, 11.5);
    final effectiveGap = widget.ringGap ?? (size * 0.030).clamp(1.5, 4.5);

    // Calculate radii from outer to inner
    final outerRadius = (size / 2) - (effectiveStrokeWidth / 2) - 2.0;
    final r0 = outerRadius;
    final r1 = r0 - effectiveStrokeWidth - effectiveGap;
    final r2 = r1 - effectiveStrokeWidth - effectiveGap;
    final r3 = r2 - effectiveStrokeWidth - effectiveGap;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showIcons = widget.showIcons && size >= 80;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animatedData = widget.animate
              ? ActivityRingsData(
                  stepsRatio: _currentRatio(0),
                  waterRatio: _currentRatio(1),
                  sleepRatio: _currentRatio(2),
                  nutritionRatio: _currentRatio(3),
                )
              : widget.data;

          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Concentric Arcs Custom Painter
              CustomPaint(
                size: Size(size, size),
                painter: _ConcentricRingsPainter(
                  data: animatedData,
                  strokeWidth: effectiveStrokeWidth,
                  ringGap: effectiveGap,
                  isDark: isDark,
                  hasGap: showIcons,
                ),
              ),

              // 2. Embedded Dimension Icons centered at the bottom (6 o'clock)
              if (showIcons) ...[
                _buildIconAtRadius(
                  r0,
                  Icons.directions_walk_rounded,
                  ConcentricActivityRings.stepsColor,
                  effectiveStrokeWidth * 0.84,
                  0,
                ),
                _buildIconAtRadius(
                  r1,
                  Icons.water_drop_rounded,
                  ConcentricActivityRings.waterColor,
                  effectiveStrokeWidth * 0.80,
                  1,
                ),
                _buildIconAtRadius(
                  r2,
                  Icons.bedtime_rounded,
                  ConcentricActivityRings.sleepColor,
                  effectiveStrokeWidth * 0.76,
                  2,
                ),
                _buildIconAtRadius(
                  r3,
                  Icons.restaurant_rounded,
                  ConcentricActivityRings.nutritionColor,
                  effectiveStrokeWidth * 0.72,
                  3,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildIconAtRadius(
    double radius,
    IconData icon,
    Color color,
    double iconSize,
    int ringIndex,
  ) {
    final size = widget.size;
    final clampedIconSize = iconSize.clamp(7.5, 13.5);

    // Fade and scale in synchronized with animation
    final iconOpacity = widget.animate
        ? ((_animation.value - 0.25) / 0.75).clamp(0.0, 1.0)
        : 1.0;

    // Mathematical center of ring at 6 o'clock:
    // x = size / 2, y = (size / 2) + radius
    final leftPos = (size / 2) - (clampedIconSize / 2);
    final topPos = (size / 2) + radius - (clampedIconSize / 2);

    return Positioned(
      left: leftPos,
      top: topPos,
      width: clampedIconSize,
      height: clampedIconSize,
      child: Opacity(
        opacity: iconOpacity,
        child: Center(
          child: Icon(
            icon,
            size: clampedIconSize,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final ActivityRingsData data;
  final double strokeWidth;
  final double ringGap;
  final bool isDark;
  final bool hasGap;

  _ConcentricRingsPainter({
    required this.data,
    required this.strokeWidth,
    required this.ringGap,
    required this.isDark,
    required this.hasGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width / 2) - (strokeWidth / 2) - 2.0;

    final rings = [
      _RingConfig(
        radius: outerRadius,
        color: ConcentricActivityRings.stepsColor,
        ratio: data.stepsRatio,
      ),
      _RingConfig(
        radius: outerRadius - strokeWidth - ringGap,
        color: ConcentricActivityRings.waterColor,
        ratio: data.waterRatio,
      ),
      _RingConfig(
        radius: outerRadius - (2 * (strokeWidth + ringGap)),
        color: ConcentricActivityRings.sleepColor,
        ratio: data.sleepRatio,
      ),
      _RingConfig(
        radius: outerRadius - (3 * (strokeWidth + ringGap)),
        color: ConcentricActivityRings.nutritionColor,
        ratio: data.nutritionRatio,
      ),
    ];

    // Desired physical clear opening between the rounded stroke caps:
    // 1.5x stroke width ensures generous breathing room for the icons without crowded caps
    final openArcLinear = (strokeWidth * 1.55).clamp(10.0, 18.0);

    for (final ring in rings) {
      if (ring.radius <= 0) continue;

      // Uniform physical opening across all concentric rings:
      // Total arc length needed center-to-center = open clear distance + strokeWidth
      final totalArcNeeded = openArcLinear + strokeWidth;
      final gapRadians = hasGap
          ? (totalArcNeeded / ring.radius).clamp(0.20, 1.45)
          : 0.0;

      // The gap is centered at 6 o'clock (90 degrees, math.pi / 2)
      // Clockwise sweep starts at (pi / 2 + gapRadians / 2) and ends at (pi / 2 - gapRadians / 2)
      final startAngle = (math.pi / 2) + (gapRadians / 2);
      final maxSweep = (2 * math.pi) - gapRadians;

      // 1. Inactive Background Track
      final trackPaint = Paint()
        ..color = ring.color.withOpacity(isDark ? 0.16 : 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ring.radius),
        startAngle,
        maxSweep,
        false,
        trackPaint,
      );

      // 2. Active Progress Arc
      if (ring.ratio > 0.005) {
        final progressSweep = (ring.ratio.clamp(0.0, 1.0) * maxSweep);
        final activePaint = Paint()
          ..color = ring.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: ring.radius),
          startAngle,
          progressSweep,
          false,
          activePaint,
        );

        // 3. Overachievement Lap (> 100%)
        if (ring.ratio > 1.0) {
          final overSweep = ((ring.ratio - 1.0).clamp(0.0, 1.0) * maxSweep);
          final lapPaint = Paint()
            ..color = Colors.white.withOpacity(0.42)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth * 0.38
            ..strokeCap = StrokeCap.round;

          canvas.drawArc(
            Rect.fromCircle(center: center, radius: ring.radius),
            startAngle,
            overSweep,
            false,
            lapPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.ringGap != ringGap ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hasGap != hasGap;
  }
}

class _RingConfig {
  final double radius;
  final Color color;
  final double ratio;

  _RingConfig({
    required this.radius,
    required this.color,
    required this.ratio,
  });
}
