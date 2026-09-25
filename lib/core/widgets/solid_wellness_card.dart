import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Solid, clean, highly readable wellness card.
/// IMPORTANT: Content cards are intentionally SOLID (not translucent glass)
/// to maintain peak readability and contrast, matching Reference Image 1.
class SolidWellnessCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Border? border;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const SolidWellnessCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveColor = gradient != null
        ? null
        : (backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface));

    final effectiveBorder = border ??
        Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        );

    Widget container = Container(
      width: width ?? double.infinity,
      height: height,
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: effectiveColor,
        gradient: gradient,
        borderRadius: AppRadii.roundedCard,
        border: effectiveBorder,
        boxShadow: gradient == null ? AppShadows.card(isDark) : null,
      ),
      child: child,
    );

    if (onTap != null) {
      container = Material(
        color: Colors.transparent,
        borderRadius: AppRadii.roundedCard,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.roundedCard,
          splashColor: AppColors.primary.withOpacity(0.12),
          highlightColor: AppColors.primary.withOpacity(0.06),
          child: container,
        ),
      );
    }

    return container;
  }
}
