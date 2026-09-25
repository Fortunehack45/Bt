import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Mini bar sparkline showing exercise/activity distribution.
/// Matches Exercise card in Reference Image 1 Screen 2.
class SparklineBarChart extends StatelessWidget {
  final List<double> values;
  final double height;
  final Color barColor;
  final Color activeBarColor;

  const SparklineBarChart({
    super.key,
    this.values = const [0.3, 0.6, 0.4, 0.9, 0.7, 0.5, 0.8, 0.2, 0.5],
    this.height = 32.0,
    this.barColor = const Color(0xFFC7EBCB),
    this.activeBarColor = AppColors.exerciseGreen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final val = values[index];
          final isPeak = val >= 0.8;
          return Container(
            width: 4.5,
            height: (height * val).clamp(6.0, height),
            decoration: BoxDecoration(
              color: isPeak ? activeBarColor : barColor,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
