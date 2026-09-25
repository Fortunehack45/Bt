import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../utils/haptic_service.dart';

/// Shows a standardized Biothrix slide-up modal bottom sheet.
/// - Smooth entrance animation from the bottom
/// - Drag pill handle
/// - Automatic keyboard avoidance via viewInsets
/// - Responsive maximum content width
Future<T?> showWellnessBottomSheet<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required Widget Function(BuildContext sheetContext) builder,
  Widget? trailingAction,
  bool isScrollControlled = true,
}) {
  HapticService.selection();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (modalContext) {
      final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;
      final safeBottom = MediaQuery.of(modalContext).padding.bottom;

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(modalContext).size.height * 0.88,
        ),
        margin: EdgeInsets.only(bottom: bottomInset),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: AppRadii.roundedSheet,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3A4740) : const Color(0xFFD0D7D3),
                  borderRadius: AppRadii.roundedPill,
                ),
              ),
            ),

            // Header Row (Title, optional subtitle, and Close/Action button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailingAction != null)
                    trailingAction
                  else
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      onPressed: () => Navigator.of(modalContext).pop(),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Body Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: safeBottom > 0 ? safeBottom + 12 : 20,
                ),
                child: builder(modalContext),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Convenience class wrapper with static `show` method matching modal sheets
class WellnessBottomSheet {
  WellnessBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget child,
    Widget? trailingAction,
    bool isScrollControlled = true,
  }) {
    return showWellnessBottomSheet<T>(
      context: context,
      title: title,
      subtitle: subtitle,
      trailingAction: trailingAction,
      isScrollControlled: isScrollControlled,
      builder: (_) => child,
    );
  }
}

