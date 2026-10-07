import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/services/app_lock_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/utils/responsive_layout.dart';

enum AppLockMode {
  unlock,
  setup,
  confirm,
  verifyCurrent,
}

/// Ultra-premium 6-digit PIN and Biometric Lock Screen.
/// Built with platform-adaptive frosted glass, animated 6-dot indicators,
/// tactile numeric keypad, and biometric hardware trigger.
class AppLockScreen extends StatefulWidget {
  final AppLockMode mode;
  final String? initialPin;
  final VoidCallback? onUnlocked;
  final ValueChanged<String>? onPinCreated;
  final VoidCallback? onCancelled;
  final bool canCancel;

  const AppLockScreen({
    super.key,
    this.mode = AppLockMode.unlock,
    this.initialPin,
    this.onUnlocked,
    this.onPinCreated,
    this.onCancelled,
    this.canCancel = false,
  });

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String? _errorMessage;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _isAuthenticatingBiometrics = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    // Auto-prompt biometrics if in unlock mode and enabled
    if (widget.mode == AppLockMode.unlock &&
        AppLockService.instance.isBiometricsEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerBiometricAuth();
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerBiometricAuth() async {
    if (_isAuthenticatingBiometrics) return;
    setState(() => _isAuthenticatingBiometrics = true);

    try {
      final success = await AppLockService.instance.authenticateWithBiometrics(
        title: 'Unlock Wellnest',
        subtitle: 'Scan your fingerprint to access your wellness dashboard',
      );

      if (mounted && success) {
        HapticService.mediumImpact();
        widget.onUnlocked?.call();
      }
    } catch (_) {
      // Graceful fallback to PIN
    } finally {
      if (mounted) {
        setState(() => _isAuthenticatingBiometrics = false);
      }
    }
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length >= 6) return;

    HapticService.selection();
    setState(() {
      _errorMessage = null;
      _enteredPin += digit;
    });

    if (_enteredPin.length == 6) {
      _processEnteredPin();
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isEmpty) return;
    HapticService.selection();
    setState(() {
      _errorMessage = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  void _onBackspaceLongPressed() {
    if (_enteredPin.isEmpty) return;
    HapticService.lightImpact();
    setState(() {
      _errorMessage = null;
      _enteredPin = '';
    });
  }

  void _triggerErrorShake(String message) {
    HapticService.error();
    setState(() {
      _errorMessage = message;
      _enteredPin = '';
    });
    _shakeController.forward(from: 0.0);
  }

  void _processEnteredPin() {
    switch (widget.mode) {
      case AppLockMode.unlock:
        final isValid = AppLockService.instance.verifyPin(_enteredPin);
        if (isValid) {
          HapticService.mediumImpact();
          widget.onUnlocked?.call();
        } else {
          _triggerErrorShake('Incorrect passcode. Please try again.');
        }
        break;

      case AppLockMode.setup:
        widget.onPinCreated?.call(_enteredPin);
        break;

      case AppLockMode.confirm:
        if (_enteredPin == widget.initialPin) {
          HapticService.mediumImpact();
          widget.onPinCreated?.call(_enteredPin);
        } else {
          _triggerErrorShake('Passcodes do not match. Try again.');
        }
        break;

      case AppLockMode.verifyCurrent:
        final isValid = AppLockService.instance.verifyPin(_enteredPin);
        if (isValid) {
          HapticService.mediumImpact();
          widget.onPinCreated?.call(_enteredPin);
        } else {
          _triggerErrorShake('Current passcode is incorrect.');
        }
        break;
    }
  }

  void _onForgotPin() {
    HapticService.lightImpact();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1B231F) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Forgot Passcode?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'For your medical and wellness privacy, passcode authentication protects sensitive biometric data.\n\nWould you like to reset your passcode using device security?',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                // Attempt biometric authorization to clear PIN
                final verified = await AppLockService.instance.authenticateWithBiometrics(
                  title: 'Authorize Passcode Reset',
                  subtitle: 'Scan your fingerprint to reset your 6-digit passcode',
                );
                if (verified) {
                  await AppLockService.instance.removePin();
                  if (mounted) {
                    widget.onUnlocked?.call();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reset Passcode'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title;
    String subtitle;
    switch (widget.mode) {
      case AppLockMode.unlock:
        title = 'Enter Passcode';
        subtitle = 'Enter your 6-digit passcode to unlock Wellnest';
        break;
      case AppLockMode.setup:
        title = 'Create Passcode';
        subtitle = 'Choose a secure 6-digit passcode for your wellness telemetry';
        break;
      case AppLockMode.confirm:
        title = 'Confirm Passcode';
        subtitle = 'Re-enter your 6-digit passcode to confirm';
        break;
      case AppLockMode.verifyCurrent:
        title = 'Verify Current Passcode';
        subtitle = 'Enter your current 6-digit passcode to continue';
        break;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: true,
        child: Column(
          children: [
            // Top App Bar / Cancel Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.canCancel)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () {
                        HapticService.lightImpact();
                        widget.onCancelled?.call();
                      },
                    )
                  else
                    const SizedBox(width: 48),
                  Text(
                    'WELLNEST SECURITY',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const Spacer(),

            // Lock Shield Hero Badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E2822) : Colors.white,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.35),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_rounded,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title & Subtitle
            Text(
              title,
              style: AppTypography.h1(isDark).copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.body(isDark).copyWith(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 6-Dot PIN Indicator with Error Shake Animation
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final offset = _shakeController.isAnimating
                    ? math.sin(_shakeController.value * math.pi * 6) * _shakeAnimation.value
                    : 0.0;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final isFilled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: isFilled ? 16 : 14,
                    height: isFilled ? 16 : 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? AppColors.primary
                          : (_errorMessage != null
                              ? AppColors.errorRed.withOpacity(0.3)
                              : Colors.transparent),
                      border: Border.all(
                        color: _errorMessage != null
                            ? AppColors.errorRed
                            : (isFilled
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkBorderStrong
                                    : AppColors.lightBorderStrong)),
                        width: 2.0,
                      ),
                      boxShadow: isFilled
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ),

            // Error Message
            const SizedBox(height: 14),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _errorMessage != null ? 1.0 : 0.0,
              child: Text(
                _errorMessage ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorRed,
                ),
              ),
            ),

            const Spacer(),

            // Tactile Numeric Keypad
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3'], ['', 'ABC', 'DEF'], isDark),
                  const SizedBox(height: 14),
                  _buildKeypadRow(['4', '5', '6'], ['GHI', 'JKL', 'MNO'], isDark),
                  const SizedBox(height: 14),
                  _buildKeypadRow(['7', '8', '9'], ['PQRS', 'TUV', 'WXYZ'], isDark),
                  const SizedBox(height: 14),
                  _buildBottomKeypadRow(isDark),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Forgot Passcode Link (in Unlock Mode)
            if (widget.mode == AppLockMode.unlock)
              TextButton(
                onPressed: _onForgotPin,
                child: Text(
                  'Forgot Passcode?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              )
            else
              const SizedBox(height: 48),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits, List<String> letters, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (i) {
        return _buildKeypadButton(
          label: digits[i],
          subLabel: letters[i],
          isDark: isDark,
          onTap: () => _onDigitPressed(digits[i]),
        );
      }),
    );
  }

  Widget _buildBottomKeypadRow(bool isDark) {
    final showBiometric = widget.mode == AppLockMode.unlock &&
        AppLockService.instance.isBiometricsEnabled;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Bottom Left: Biometric Button or Blank
        if (showBiometric)
          _buildActionButton(
            icon: Icons.fingerprint_rounded,
            isDark: isDark,
            onTap: _triggerBiometricAuth,
          )
        else
          const SizedBox(width: 72, height: 72),

        // Bottom Center: Digit 0
        _buildKeypadButton(
          label: '0',
          subLabel: '',
          isDark: isDark,
          onTap: () => _onDigitPressed('0'),
        ),

        // Bottom Right: Delete / Backspace
        _buildActionButton(
          icon: Icons.backspace_outlined,
          isDark: isDark,
          onTap: _onBackspacePressed,
          onLongPress: _onBackspaceLongPressed,
        ),
      ],
    );
  }

  Widget _buildKeypadButton({
    required String label,
    required String subLabel,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        splashColor: AppColors.primary.withOpacity(0.2),
        highlightColor: AppColors.primary.withOpacity(0.1),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E2822).withOpacity(0.85) : Colors.white.withOpacity(0.85),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3D34).withOpacity(0.7) : Colors.white.withOpacity(0.65),
              width: 1.0,
            ),
            boxShadow: AppShadows.floatingGlass(isDark: isDark, isIos: false),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              if (subLabel.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(36),
        splashColor: AppColors.primary.withOpacity(0.2),
        highlightColor: AppColors.primary.withOpacity(0.1),
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 26,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
