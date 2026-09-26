import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import 'platform_glass_surface.dart';

/// Opens a platform-adaptive glass bottom sheet.
Future<T?> showPlatformGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.35),
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;

      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: PlatformGlassSurface(
          borderRadius: AppRadii.roundedSheet,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Container(
                  width: 36,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorderStrong
                        : AppColors.lightBorderStrong,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(child: builder(context)),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
            ],
          ),
        ),
      );
    },
  );
}
