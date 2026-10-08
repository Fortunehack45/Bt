import 'package:flutter/material.dart';
import '../../core/glass/platform_frosted_container.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../onboarding/onboarding_screen.dart';
import 'clinician_login_sheet.dart';

/// Ultra-premium frosted glass authentication screen.
/// Supports Google Sign-In, Email/Password login/registration, and guest offline mode.
class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;

  bool _isSignUp = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _localError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSuccessfulAuth() {
    final user = _authService.currentUser;
    final needsOnboarding = user != null && !user.hasCompletedOnboarding;

    if (needsOnboarding) {
      // New user from Google or Email: must complete onboarding calibration questions!
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(
            onGetStarted: () {
              Navigator.of(context).pop();
              widget.onAuthenticated();
            },
          ),
        ),
      );
    } else {
      widget.onAuthenticated();
    }
  }

  Future<void> _handleEmailAuth() async {
    HapticService.mediumImpact();
    setState(() => _localError = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    bool success = false;
    if (_isSignUp) {
      if (name.isEmpty) {
        setState(() => _localError = 'Please enter your name.');
        return;
      }
      success = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );
    } else {
      success = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }

    if (mounted) {
      if (success) {
        HapticService.success();
        _onSuccessfulAuth();
      } else {
        HapticService.error();
        setState(() {
          _localError = _authService.lastAuthError ?? 'Authentication failed. Please check credentials.';
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    HapticService.selection();
    setState(() => _localError = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Triggering phone browser for Google Sign-In... Please select your account.'),
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final success = await _authService.signInWithGoogle();
    if (mounted) {
      if (success) {
        HapticService.success();
        _onSuccessfulAuth();
      } else {
        HapticService.error();
        setState(() {
          _localError = _authService.lastAuthError ?? 'Google sign-in was not completed in the browser.';
        });
      }
    }
  }

  void _handleContinueAsGuest() async {
    HapticService.lightImpact();
    await _authService.continueAsGuest();
    if (mounted) {
      widget.onAuthenticated();
    }
  }

  void _openClinicianLogin() {
    HapticService.selection();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClinicianLoginSheet(
        onClinicianVerified: () {
          Navigator.of(ctx).pop();
          widget.onAuthenticated();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = _authService.isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Brand Hero Emblem
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.emeraldTeal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color: AppColors.textPrimaryLight,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title & Subtitle
              Center(
                child: Text(
                  'Wellnest Wellness',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  _isSignUp
                      ? 'Create your personal clinical wellness cloud'
                      : 'Sign in to access your synchronized biometric telemetry',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Sign In / Create Account Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162019) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF233026) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.selection();
                          setState(() {
                            _isSignUp = false;
                            _localError = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isSignUp
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: !_isSignUp
                                  ? AppColors.textPrimaryLight
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.selection();
                          setState(() {
                            _isSignUp = true;
                            _localError = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isSignUp
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _isSignUp
                                  ? AppColors.textPrimaryLight
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Frosted Glass Auth Form Card
              PlatformFrostedContainer(
                borderRadius: BorderRadius.circular(22),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isSignUp) ...[
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                    ],

                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 14),

                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Password (min 6 characters)',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      isDark: isDark,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),

                    if (_localError != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.errorRed),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _localError!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Primary Email Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimaryLight,
                              ),
                            )
                          : Text(
                              _isSignUp ? 'Create Cloud Account' : 'Sign In',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Continue with Google Button
                    OutlinedButton(
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF2C3C30) : const Color(0xFFD1D5DB),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF131D15)
                            : Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Offline Guest Exploration
              TextButton(
                onPressed: _handleContinueAsGuest,
                child: Text(
                  'Continue as Guest (Offline Mode)',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Clinician & Doctor Access Link
              OutlinedButton.icon(
                onPressed: _openClinicianLogin,
                icon: const Icon(Icons.medical_services_outlined, size: 18, color: AppColors.emeraldTeal),
                label: const Text(
                  'Doctor / Examiner Access (Pair Code)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emeraldTeal,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: AppColors.emeraldTeal.withOpacity(0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141D16) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF263629) : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
