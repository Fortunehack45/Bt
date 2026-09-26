import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated circular progress ring matching the hero card in Reference Image 1.
/// Displays progress percentage and center label (e.g., "6 days" or "72%").
class CircularProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;
  final String? centerPrimaryText;
  final String? centerSecondaryText;
  final Color? primaryTextColor;
  final Color? secondaryTextColor;
  final Widget? center;

  const CircularProgressRing({
    super.key,
    required this.progress,
    this.size = 88.0,
    this.strokeWidth = 9.0,
    this.progressColor = AppColors.primary,
    Color? trackColor,
    Color? backgroundColor,
    this.centerPrimaryText,
    this.centerSecondaryText,
    this.primaryTextColor,
    this.secondaryTextColor,
    this.center,
  }) : trackColor = backgroundColor ?? trackColor ?? const Color(0xFFE2F7B0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                  progressColor: progressColor,
                  trackColor: trackColor,
                ),
              );
            },
          ),
          if (center != null)
            center!
          else if (centerPrimaryText != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerPrimaryText!,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    color: primaryTextColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ),
                ),
                if (centerSecondaryText != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    centerSecondaryText!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: size * 0.125,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: secondaryTextColor ?? (isDark ? AppColors.textSecondaryDark : const Color(0xFF263326)),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
