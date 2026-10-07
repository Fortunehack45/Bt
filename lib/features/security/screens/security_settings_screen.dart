import 'package:flutter/material.dart';
import '../../../core/services/app_lock_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import 'app_lock_screen.dart';

/// Screen managing App Lock, 6-digit passcode setup/change, and local Biometric unlock.
class SecuritySettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SecuritySettingsScreen({super.key, required this.onBack});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final AppLockService _service = AppLockService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  void _startSetupPinFlow() {
    HapticService.selection();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => AppLockScreen(
          mode: AppLockMode.setup,
          canCancel: true,
          onCancelled: () => Navigator.of(ctx).pop(),
          onPinCreated: (newPin) {
            Navigator.of(ctx).pop();
            _startConfirmPinFlow(newPin);
          },
        ),
      ),
    );
  }

  void _startConfirmPinFlow(String newPin) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => AppLockScreen(
          mode: AppLockMode.confirm,
          initialPin: newPin,
          canCancel: true,
          onCancelled: () => Navigator.of(ctx).pop(),
          onPinCreated: (confirmedPin) async {
            Navigator.of(ctx).pop();
            await _service.setPin(confirmedPin);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('6-digit passcode set successfully. App lock is now enabled.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _startChangePinFlow() {
    HapticService.selection();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => AppLockScreen(
          mode: AppLockMode.verifyCurrent,
          canCancel: true,
          onCancelled: () => Navigator.of(ctx).pop(),
          onPinCreated: (_) {
            Navigator.of(ctx).pop();
            _startSetupPinFlow();
          },
        ),
      ),
    );
  }

  void _disablePinFlow() {
    HapticService.selection();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => AppLockScreen(
          mode: AppLockMode.verifyCurrent,
          canCancel: true,
          onCancelled: () => Navigator.of(ctx).pop(),
          onPinCreated: (_) async {
            Navigator.of(ctx).pop();
            await _service.removePin();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App lock has been disabled.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = _service.isLockEnabled && _service.hasPinSet;
    final bioStatus = _service.biometricStatus;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: true,
        child: Column(
          children: [
            ScreenHeader(
              title: 'Security & Privacy',
              subtitle: 'Passcode & Biometrics',
              onLeadingTap: widget.onBack,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin, vertical: 12),
                children: [
                  // Hero Status Card
                  SolidWellnessCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isEnabled
                                ? AppColors.primary.withOpacity(0.18)
                                : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isEnabled ? AppColors.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            isEnabled ? Icons.lock_rounded : Icons.lock_open_rounded,
                            color: isEnabled
                                ? AppColors.primary
                                : (isDark ? Colors.white60 : Colors.black45),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnabled ? 'App Protection Active' : 'App Lock Disabled',
                                style: AppTypography.h3(isDark).copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isEnabled
                                    ? 'Locked with 6-digit PIN${_service.isBiometricsEnabled ? " & Fingerprint" : ""}'
                                    : 'Protect clinical metrics, habits and private biometrics',
                                style: AppTypography.caption(isDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Section 1: Master Lock Switch
                  Text(
                    'APP LOCK CONTROLS',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),

                  SolidWellnessCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: isEnabled,
                      activeColor: AppColors.primary,
                      title: Text(
                        'Enable 6-Digit App Lock',
                        style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Require passcode to access Wellnest',
                        style: AppTypography.caption(isDark),
                      ),
                      onChanged: (value) {
                        if (value) {
                          _startSetupPinFlow();
                        } else {
                          _disablePinFlow();
                        }
                      },
                    ),
                  ),

                  if (isEnabled) ...[
                    const SizedBox(height: 8),

                    // Change PIN button
                    SolidWellnessCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: _startChangePinFlow,
                      child: Row(
                        children: [
                          Icon(
                            Icons.pin_rounded,
                            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Change 6-Digit Passcode',
                                  style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Update your security passcode',
                                  style: AppTypography.caption(isDark),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Section 2: Biometrics
                    Text(
                      'BIOMETRIC AUTHENTICATION',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),

                    SolidWellnessCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _service.isBiometricsEnabled,
                        activeColor: AppColors.primary,
                        title: Text(
                          'Fingerprint / Biometric Unlock',
                          style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                        ),
                        subtitle: Text(
                          bioStatus.hasHardware
                              ? (bioStatus.isEnrolled
                                  ? 'Device sensor enrolled and ready'
                                  : 'No fingerprint enrolled in system settings')
                              : 'Use phone fingerprint sensor for instant access',
                          style: AppTypography.caption(isDark),
                        ),
                        onChanged: (value) async {
                          HapticService.selection();
                          if (value) {
                            // Test biometric authentication immediately with force: true
                            final verified = await _service.authenticateWithBiometrics(
                              title: 'Enable Biometrics',
                              subtitle: 'Verify your fingerprint to enable biometric unlock',
                              force: true,
                            );
                            if (verified) {
                              await _service.setBiometricsEnabled(true);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Biometric verification failed or was cancelled'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            await _service.setBiometricsEnabled(false);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Section 3: Auto-Lock Timeout
                    Text(
                      'AUTO-LOCK TIMEOUT',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),

                    SolidWellnessCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lock automatically when leaving app:',
                            style: AppTypography.caption(isDark),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: AutoLockTimeout.values.map((timeout) {
                              final isSelected = _service.timeout == timeout;
                              return ChoiceChip(
                                label: Text(timeout.label),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                backgroundColor: isDark
                                    ? const Color(0xFF233025)
                                    : const Color(0xFFF1F5F9),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.textPrimaryLight
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    HapticService.selection();
                                    _service.setAutoLockTimeout(timeout);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Quick Lock Button
                    SolidWellnessCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: () {
                        HapticService.mediumImpact();
                        _service.lock();
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.screen_lock_portrait_rounded, color: AppColors.primary, size: 22),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Lock Wellnest Now',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const Icon(Icons.lock_rounded, size: 18, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Local Security Privacy Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141C16)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF223025)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '100% Local Security Enclave',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your 6-digit passcode is salted and hashed locally using SHA-256. Fingerprint authentication runs strictly through your device\'s hardware enclave. No credentials or biometric data are ever shared or transmitted.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
