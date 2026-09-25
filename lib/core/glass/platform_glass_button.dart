import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../utils/haptic_service.dart';
import 'platform_glass_surface.dart';

/// Floating glass icon button for back, more, filter, calendar, and refresh.
/// Matches the floating utility controls in Reference Image 1.
class PlatformGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final String? tooltip;
  final Color? iconColor;

  const PlatformGlassButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44.0,
    this.iconSize = 20.0,
    this.tooltip,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget button = PlatformGlassSurface(
      borderRadius: AppRadii.roundedMd,
      width: size,
      height: size,
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ??
              (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
