import 'package:flutter/material.dart';
import '../glass/platform_glass_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Universal, pixel-perfect top header ensuring 100% identical top measurement,
/// alignment, and typography across all Biothrix screens.
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onBack;
  final VoidCallback? onLeadingTap;
  final double height;
  final EdgeInsetsGeometry padding;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onBack,
    this.onLeadingTap,
    this.height = 56.0,
    this.padding = const EdgeInsets.only(
      left: AppSpacing.pageMargin,
      right: AppSpacing.pageMargin,
      top: 10.0,
      bottom: 8.0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backAction = onBack ?? onLeadingTap;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && backAction != null) {
      leadingWidget = PlatformGlassButton(
        icon: Icons.chevron_left_rounded,
        size: 42,
        iconSize: 24,
        tooltip: 'Back',
        onTap: backAction,
      );
    }

    return Padding(
      padding: padding,
      child: SizedBox(
        height: height,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingWidget != null) ...[
            leadingWidget,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: subtitle != null ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    ),
  );
}

}
