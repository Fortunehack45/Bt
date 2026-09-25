import 'package:flutter/material.dart';
import '../../../core/glass/platform_glass_button.dart';
import '../../../core/theme/app_typography.dart';

/// Top navigation header for Statistics matching Reference Image 1 Screen 2:
/// - Floating glass back button (<)
/// - "Statistic" centered title
/// - Floating glass more button (...)
class StatisticsHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMore;

  const StatisticsHeader({
    super.key,
    required this.onBack,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PlatformGlassButton(
          icon: Icons.chevron_left_rounded,
          size: 42,
          iconSize: 24,
          tooltip: 'Back',
          onTap: onBack,
        ),
        Text(
          'Statistic',
          style: AppTypography.h2(isDark).copyWith(fontSize: 18),
        ),
        PlatformGlassButton(
          icon: Icons.more_horiz_rounded,
          size: 42,
          iconSize: 22,
          tooltip: 'More options',
          onTap: onMore,
        ),
      ],
    );
  }
}
