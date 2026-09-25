import 'package:flutter/material.dart';
import '../theme/app_radii.dart';

/// Small rounded pill/circle badge for metric icons with soft tinted backgrounds.
/// As seen in Reference Image 1 (footprint, water drop, heart, exercise sparkles).
class MetricBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  const MetricBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.size = 36.0,
    this.iconSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.roundedPill,
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}
