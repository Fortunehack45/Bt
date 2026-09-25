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

/// Floating Platform-Adaptive Glass Bottom Navigation Bar.
/// Implements the exact layout from Reference Image 1 with the central
/// elevated wellness green action button.
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
    // Center is Action Button
    NavItemData(
      icon: Icons.track_changes_outlined,
      activeIcon: Icons.track_changes_rounded,
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
          constraints: const BoxConstraints(maxWidth: 420),
          child: PlatformGlassSurface(
            borderRadius: AppRadii.roundedNav,
            height: AppSpacing.floatingNavHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Item 0: Home
                _buildNavItem(0, _items[0], isDark),

                // Item 1: Statistics
                _buildNavItem(1, _items[1], isDark),

                // Central Elevated Action Button [+]
                _buildCentralFab(),

                // Item 2: Habits
                _buildNavItem(2, _items[2], isDark),

                // Item 3: Profile
                _buildNavItem(3, _items[3], isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, NavItemData item, bool isDark) {
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticService.selection();
          widget.onIndexChanged(index);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 24,
                  color: isSelected
                      ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
                      : (isDark
                          ? AppColors.textMutedDark
                          : AppColors.textSecondaryLight),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
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

  Widget _buildCentralFab() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: GestureDetector(
        onTap: _onFabTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.fabGlow,
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: AppColors.textPrimaryLight,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
