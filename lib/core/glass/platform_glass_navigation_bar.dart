import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../utils/haptic_service.dart';
import 'platform_glass_surface.dart';

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Floating Platform-Adaptive Navigation Bar matching the user's reference:
/// - Oblong capsule on the left containing the 4 primary tabs (Home, Statistics, Habits, Profile)
/// - Active tab highlighted with a rounded pill background
/// - Standalone floating circular action button (+) positioned beside the main capsule
class PlatformGlassNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onCentralActionPressed;

  const PlatformGlassNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onCentralActionPressed,
  });

  @override
  State<PlatformGlassNavigationBar> createState() =>
      _PlatformGlassNavigationBarState();
}

class _PlatformGlassNavigationBarState extends State<PlatformGlassNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnimation;

  final List<NavItemData> _items = const [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItemData(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Statistics',
    ),
    NavItemData(
      icon: Icons.task_alt_outlined,
      activeIcon: Icons.task_alt_rounded,
      label: 'Habits',
    ),
    NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onFabTap() async {
    HapticService.mediumImpact();
    await _fabAnimController.forward();
    await _fabAnimController.reverse();
    widget.onCentralActionPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.pageMargin,
        right: AppSpacing.pageMargin,
        bottom: bottomInset > 0 ? bottomInset + 8.0 : 18.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Row(
            children: [
              // 1. Primary Navigation Capsule with 4 Tabs
              Expanded(
                child: PlatformGlassSurface(
                  borderRadius: AppRadii.roundedNav,
                  height: 64.0,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_items.length, (index) {
                      return _buildNavItem(index, _items[index], isDark);
                    }),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 2. Standalone Floating Circular Action Button (+) beside the bar
              _buildBesideFab(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, NavItemData item, bool isDark) {
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticService.selection();
          widget.onIndexChanged(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF242F2A) : const Color(0xFFE5EBE7))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 22,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textMutedDark
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textMutedDark
                          : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBesideFab(bool isDark) {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: GestureDetector(
        onTap: _onFabTap,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E2824) : AppColors.lightSurface,
            boxShadow: AppShadows.floating(isDark),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3D36) : AppColors.lightBorder,
              width: 1.2,
            ),
          ),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.textPrimaryLight,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
