import 'package:flutter/material.dart';
import '../constants/tour_target_keys.dart';
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
/// - Standalone floating circular action button (+) beside the main capsule
/// - Vertical swipe (up/down) on the FAB smoothly morphs between Quick Action (+) mode
///   and Biothrix AI Chatbot mode with rotation and gradient feedback
class PlatformGlassNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onCentralActionPressed;
  final VoidCallback? onOpenAiChatbot;

  const PlatformGlassNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onCentralActionPressed,
    this.onOpenAiChatbot,
  });

  @override
  State<PlatformGlassNavigationBar> createState() =>
      _PlatformGlassNavigationBarState();
}

class _PlatformGlassNavigationBarState extends State<PlatformGlassNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnimation;

  late AnimationController _morphAnimController;
  late Animation<double> _rotationAnimation;

  bool _isChatbotMode = false;

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

    _morphAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _morphAnimController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    _morphAnimController.dispose();
    super.dispose();
  }

  void _toggleFabMode() {
    HapticService.selection();
    setState(() {
      _isChatbotMode = !_isChatbotMode;
    });
    if (_isChatbotMode) {
      _morphAnimController.forward();
    } else {
      _morphAnimController.reverse();
    }
  }

  void _onFabTap() async {
    HapticService.mediumImpact();
    await _fabAnimController.forward();
    await _fabAnimController.reverse();
    if (_isChatbotMode) {
      widget.onOpenAiChatbot?.call();
    } else {
      widget.onCentralActionPressed();
    }
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
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < _items.length; i++)
                        _buildNavItem(i, _items[i], isDark),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 2. Standalone Floating Circular Action Button (+ / AI Chatbot) beside the bar
              _buildBesideFab(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, NavItemData item, bool isDark) {
    final isSelected = widget.currentIndex == index;
    final isFirst = index == 0;
    final isLast = index == _items.length - 1;

    // Concentric pill radius: 64 outer height - 8 padding = 56 inner height.
    // 56 / 2 = 28 radius creates a true stadium capsule that concentrically echoes
    // the outer capsule's 32 radius (32 - 4 = 28).
    final margin = EdgeInsets.only(
      left: isFirst ? 0 : 2,
      right: isLast ? 0 : 2,
    );

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
          margin: margin,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF242F2A) : const Color(0xFFE5EBE7))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            border: isSelected
                ? Border.all(
                    color: isDark
                        ? AppColors.primary.withOpacity(0.24)
                        : AppColors.primary.withOpacity(0.18),
                    width: 1.0,
                  )
                : Border.all(color: Colors.transparent, width: 1.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.18)
                          : AppColors.primary.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textMutedDark
                          : AppColors.textSecondaryLight),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
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
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        key: TourTargetKeys.fabKey,
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 60) {
            _toggleFabMode();
          }
        },
        onTap: _onFabTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
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
            child: RotationTransition(
              turns: _rotationAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      _isChatbotMode ? Icons.auto_awesome_rounded : Icons.add_rounded,
                      key: ValueKey(_isChatbotMode),
                      color: AppColors.textPrimaryLight,
                      size: _isChatbotMode ? 20 : 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
