import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom painted ECG / heartbeat waveform line for BPM metric card.
/// Matches Reference Image 1 Screen 2.
class EcgWaveform extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const EcgWaveform({
    super.key,
    this.height = 36.0,
    this.width = double.infinity,
    this.color = AppColors.heartRed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: _EcgPainter(color: color),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final Color color;

  _EcgPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final h = size.height;
    final w = size.width;
    final midY = h * 0.55;

    path.moveTo(0, midY);
    path.lineTo(w * 0.15, midY);

    // Minor dip
    path.lineTo(w * 0.20, midY - (h * 0.12));
    path.lineTo(w * 0.25, midY);

    // QRS complex 1
    path.lineTo(w * 0.32, midY + (h * 0.25));
    path.lineTo(w * 0.38, midY - (h * 0.45));
    path.lineTo(w * 0.44, midY + (h * 0.35));
    path.lineTo(w * 0.48, midY);

    // Baseline
    path.lineTo(w * 0.60, midY);

    // QRS complex 2
    path.lineTo(w * 0.65, midY + (h * 0.20));
    path.lineTo(w * 0.70, midY - (h * 0.42));
    path.lineTo(w * 0.75, midY + (h * 0.30));
    path.lineTo(w * 0.78, midY);

    // Tail
    path.lineTo(w, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) => oldDelegate.color != color;
}
