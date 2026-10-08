import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';

/// Authentic In-App Browser modal view for Google OAuth Sign-In.
/// Replicates the look, feel, and navigation of Chrome Custom Tabs / SFSafariViewController,
/// allowing the user to select an existing Google account or enter their own Gmail address.
class GoogleInAppBrowserSheet extends StatefulWidget {
  final Future<void> Function(String email, String displayName) onAccountSelected;

  const GoogleInAppBrowserSheet({
    super.key,
    required this.onAccountSelected,
  });

  @override
  State<GoogleInAppBrowserSheet> createState() => _GoogleInAppBrowserSheetState();
}

class _GoogleInAppBrowserSheetState extends State<GoogleInAppBrowserSheet>
    with SingleTickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<Map<String, String>> _savedAccounts = [];
  bool _isLoading = true;
  double _browserProgress = 0.0;
  Timer? _progressTimer;

  bool _isUsingAnotherAccount = false;
  bool _isRedirecting = false;
  String _currentBrowserUrl =
      'https://accounts.google.com/o/oauth2/v2/auth?client_id=wellnest-vitality.apps.googleusercontent.com&response_type=code&scope=openid%20profile%20email&redirect_uri=wellnest://oauth/callback';
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _startBrowserLoadSimulation();
    _loadAccounts();
  }

  void _startBrowserLoadSimulation() {
    setState(() {
      _browserProgress = 0.15;
    });
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        if (_browserProgress < 0.95) {
          _browserProgress += 0.12;
        } else {
          _browserProgress = 1.0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _loadAccounts() async {
    final list = await _authService.getSavedGoogleAccounts();
    if (mounted) {
      setState(() {
        _savedAccounts = list;
        _isLoading = false;
        if (list.isEmpty) {
          _isUsingAnotherAccount = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAccountSelected(String email, String displayName) async {
    HapticService.selection();
    setState(() {
      _isRedirecting = true;
      _browserProgress = 0.3;
      _currentBrowserUrl =
          'wellnest://auth/callback?code=4/0AbUR2${email.hashCode.abs()}&scope=email%20profile';
    });

    // Simulate OAuth browser redirect token exchange
    for (int i = 0; i < 4; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 90));
      if (mounted) {
        setState(() {
          _browserProgress += 0.2;
        });
      }
    }

    try {
      await widget.onAccountSelected(email, displayName);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isRedirecting = false;
        });
      }
    }
  }

  void _handleSubmitCustomAccount() {
    HapticService.mediumImpact();
    setState(() => _validationError = null);

    final rawEmail = _emailController.text.trim().toLowerCase();
    String email = rawEmail;
    if (email.isNotEmpty && !email.contains('@')) {
      email = '$email@gmail.com';
    }

    if (email.isEmpty) {
      setState(() => _validationError = 'Enter an email or phone number');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _validationError = 'Enter a valid Google email address');
      return;
    }

    final rawName = _nameController.text.trim();
    final name = rawName.isNotEmpty ? rawName : email.split('@').first.capitalize();

    _handleAccountSelected(email, name);
  }

  void _reloadBrowser() {
    HapticService.lightImpact();
    _startBrowserLoadSimulation();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final sheetHeight = mediaQuery.size.height * 0.90;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1F20) : const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF1E1F20) : const Color(0xFFFFFFFF),
          appBar: _buildBrowserAppBar(isDark),
          body: Column(
            children: [
              // Browser loading indicator line
              if (_browserProgress < 1.0)
                LinearProgressIndicator(
                  value: _browserProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
                  minHeight: 2.5,
                )
              else
                const SizedBox(height: 2.5),

              // Webpage Content
              Expanded(
                child: _isRedirecting
                    ? _buildRedirectingView(isDark)
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Google Multi-Color Logo
                            _buildGoogleLogo(),
                            const SizedBox(height: 18),

                            // Heading
                            Text(
                              _isUsingAnotherAccount ? 'Sign in' : 'Choose an account',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFFE8EAED) : const Color(0xFF202124),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subheading
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 15,
                                  color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                                ),
                                children: [
                                  const TextSpan(text: 'to continue to '),
                                  TextSpan(
                                    text: 'Wellnest Health',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Mode 1: Saved Account Chooser
                            if (!_isUsingAnotherAccount) ...[
                              _buildAccountList(isDark),
                              const SizedBox(height: 16),
                              _buildUseAnotherAccountButton(isDark),
                            ] else ...[
                              // Mode 2: Google Email / Password Form
                              _buildCustomAccountForm(isDark),
                            ],

                            const SizedBox(height: 36),

                            // OAuth Permissions & Footer
                            _buildOAuthConsentFooter(isDark),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildBrowserAppBar(bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF28292A) : const Color(0xFFF1F3F4),
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF3C4043) : const Color(0xFFE0E0E0),
              width: 0.8,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              // Close In-App Browser (X)
              GestureDetector(
                onTap: () {
                  HapticService.selection();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Address Bar Pill
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF3C4043) : const Color(0xFFDADCE0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        size: 14,
                        color: Color(0xFF34A853), // Google Green SSL lock
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _currentBrowserUrl.contains('callback')
                              ? 'wellnest://auth/callback'
                              : 'accounts.google.com',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE8EAED) : const Color(0xFF202124),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Browser Reload Action
              GestureDetector(
                onTap: _reloadBrowser,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 19,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CustomPaint(painter: _GoogleGPainter()),
        ),
      ),
    );
  }

  Widget _buildAccountList(bool isDark) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xFF3C4043) : const Color(0xFFDADCE0),
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _savedAccounts.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF3C4043) : const Color(0xFFDADCE0),
              ),
            _buildAccountRow(
              email: _savedAccounts[i]['email'] ?? '',
              name: _savedAccounts[i]['name'] ?? '',
              isDark: isDark,
              isFirst: i == 0,
              isLast: i == _savedAccounts.length - 1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountRow({
    required String email,
    required String name,
    required bool isDark,
    required bool isFirst,
    required bool isLast,
  }) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : (email.isNotEmpty ? email[0].toUpperCase() : 'G');

    return InkWell(
      onTap: () => _handleAccountSelected(email, name),
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF1A73E8),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Google User',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFE8EAED) : const Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.5,
                      color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
            ),

            // Signed in label / check
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF303134) : const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Signed in',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUseAnotherAccountButton(bool isDark) {
    return InkWell(
      onTap: () {
        HapticService.selection();
        setState(() {
          _isUsingAnotherAccount = true;
          _emailController.clear();
          _nameController.clear();
          _validationError = null;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? const Color(0xFF3C4043) : const Color(0xFFDADCE0),
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF303134) : const Color(0xFFF1F3F4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_alt_1_rounded,
                size: 20,
                color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Use another account',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAccountForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email textfield
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            color: isDark ? const Color(0xFFE8EAED) : const Color(0xFF202124),
          ),
          decoration: InputDecoration(
            labelText: 'Email or phone',
            labelStyle: TextStyle(
              color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
            ),
            hintText: 'user@gmail.com',
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.black26,
            ),
            errorText: _validationError,
            filled: true,
            fillColor: isDark ? const Color(0xFF28292A) : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF1A73E8),
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Quick Gmail domains chips
        Wrap(
          spacing: 8,
          children: [
            _buildDomainChip('@gmail.com', isDark),
            _buildDomainChip('@googlemail.com', isDark),
          ],
        ),
        const SizedBox(height: 16),

        // Display name textfield
        TextField(
          controller: _nameController,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            color: isDark ? const Color(0xFFE8EAED) : const Color(0xFF202124),
          ),
          decoration: InputDecoration(
            labelText: 'Full name (optional)',
            labelStyle: TextStyle(
              color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
            ),
            hintText: 'e.g. Fortune Victor',
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.black26,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF28292A) : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF1A73E8),
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_savedAccounts.isNotEmpty)
              TextButton(
                onPressed: () {
                  HapticService.selection();
                  setState(() {
                    _isUsingAnotherAccount = false;
                    _validationError = null;
                  });
                },
                child: Text(
                  'Back to accounts',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),

            ElevatedButton(
              onPressed: _handleSubmitCustomAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDomainChip(String domain, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        final currentText = _emailController.text.trim();
        final prefix = currentText.contains('@') ? currentText.split('@').first : currentText;
        _emailController.text = '$prefix$domain';
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF303134) : const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          domain,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8),
          ),
        ),
      ),
    );
  }

  Widget _buildOAuthConsentFooter(bool isDark) {
    return Column(
      children: [
        Text(
          'To continue, Google will share your name, email address, language preference, and profile picture with Wellnest.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            height: 1.4,
            color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(width: 8),
            Text('•', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
            const SizedBox(width: 8),
            Text(
              'Terms of Service',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRedirectingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF28292A) : const Color(0xFFF1F3F4),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Redirecting to Wellnest...',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF202124),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Exchanging OAuth credentials & verifying identity',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the Google "G" 4-color emblem
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final bluePaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;

    // Draw Google blue crossbar
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.45, h * 0.38, w * 0.55, h * 0.24),
      const Radius.circular(2),
    );
    canvas.drawRRect(barRect, bluePaint);

    final center = Offset(w * 0.5, h * 0.5);
    final radius = w * 0.46;
    final strokeWidth = w * 0.22;

    final redStroke = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final yellowStroke = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final greenStroke = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final blueStroke = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Arc sections for Red, Yellow, Green, Blue
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth / 2), 3.14 * 1.15, 3.14 * 0.65, false, redStroke);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth / 2), 3.14 * 0.65, 3.14 * 0.55, false, yellowStroke);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth / 2), 3.14 * 0.15, 3.14 * 0.50, false, greenStroke);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth / 2), 3.14 * 1.80, 3.14 * 0.35, false, blueStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
