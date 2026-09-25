import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_shadows.dart';
import '../theme/glass_tokens.dart';

/// Platform-adaptive glass surface widget.
/// - On Android: Renders soft frosted glass with subtle blur and diffused tint.
/// - On iOS: Renders liquid-glass-inspired material with multi-layered specular highlights,
///   fluid translucency, and squircle curvature.
class PlatformGlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool enableShadow;

  const PlatformGlassSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.enableShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isIos = theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;

    final blurSigma =
        isIos ? GlassTokens.iosBlurSigma : GlassTokens.androidBlurSigma;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: _buildDecoration(isIos, isDark),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: Colors.white.withOpacity(0.15),
          highlightColor: Colors.white.withOpacity(0.08),
          child: content,
        ),
      );
    }

    return Container(
      decoration: enableShadow
          ? BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: AppShadows.floatingGlass(isDark: isDark, isIos: isIos),
            )
          : null,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isIos, bool isDark) {
    if (isIos) {
      // iOS Liquid-Glass-Inspired Treatment
      return BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? GlassTokens.iosDarkGradient
              : GlassTokens.iosLightGradient,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.18)
              : Colors.white.withOpacity(0.70),
          width: 0.8,
        ),
      );
    } else {
      // Android Frosted Glass Treatment
      return BoxDecoration(
        color: isDark
            ? GlassTokens.androidDarkBackground
            : GlassTokens.androidLightBackground,
        borderRadius: borderRadius,
        border: Border.all(
          color: isDark
              ? GlassTokens.androidDarkBorder
              : GlassTokens.androidLightBorder,
          width: 0.6,
        ),
      );
    }
  }
}
