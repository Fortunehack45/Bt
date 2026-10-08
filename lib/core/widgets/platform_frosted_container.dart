import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable cross-platform frosted glass container widget with backdrop blur,
/// subtle translucent surface gradient, and luminous border highlight.
class PlatformFrostedContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blur;
  final VoidCallback? onTap;

  const PlatformFrostedContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.blur = 16.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isDark
        ? const Color(0xFF111A14).withOpacity(0.65)
        : Colors.white.withOpacity(0.75);

    final defaultBorder = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    Widget container = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBg,
            borderRadius: effectiveRadius,
            border: Border.all(
              color: borderColor ?? defaultBorder,
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      container = Padding(padding: margin!, child: container);
    }

    if (onTap != null) {
      container = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: container,
      );
    }

    return container;
  }
}
