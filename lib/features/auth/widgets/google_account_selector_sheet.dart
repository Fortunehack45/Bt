import 'package:flutter/material.dart';
import '../../../core/glass/platform_frosted_container.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';

/// Authentic Google Account Chooser bottom sheet.
/// Allows user to select an existing remembered Google account with 1-tap,
/// or enter their own custom Google / Gmail account address and display name.
class GoogleAccountSelectorSheet extends StatefulWidget {
  final Future<void> Function(String email, String displayName) onAccountSelected;

  const GoogleAccountSelectorSheet({
    super.key,
    required this.onAccountSelected,
  });

  @override
  State<GoogleAccountSelectorSheet> createState() => _GoogleAccountSelectorSheetState();
}

class _GoogleAccountSelectorSheetState extends State<GoogleAccountSelectorSheet> {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<Map<String, String>> _savedAccounts = [];
  bool _isLoadingAccounts = true;
  bool _showCustomForm = false;
  bool _isSubmitting = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final list = await _authService.getSavedGoogleAccounts();
    if (mounted) {
      setState(() {
        _savedAccounts = list;
        _isLoadingAccounts = false;
        // If no accounts remembered yet, show the input fields immediately
        if (list.isEmpty) {
          _showCustomForm = true;
        }
      });
    }
  }

  Future<void> _chooseAccount(String email, String name) async {
    HapticService.selection();
    setState(() => _isSubmitting = true);
    try {
      await widget.onAccountSelected(email, name);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleSubmitCustom() async {
    HapticService.mediumImpact();
    setState(() => _validationError = null);

    final email = _emailController.text.trim().toLowerCase();
    final name = _nameController.text.trim();

    if (email.isEmpty) {
      setState(() => _validationError = 'Please enter your Google email address.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _validationError = 'Please enter a valid Google email.');
      return;
    }

    final displayName = name.isNotEmpty ? name : email.split('@').first.capitalize();

    await _chooseAccount(email, displayName);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: PlatformFrostedContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Google Header
              Row(
                children: [
                  _buildGoogleIcon(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Choose an account to continue to Wellnest',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Saved accounts list
              if (!_isLoadingAccounts && _savedAccounts.isNotEmpty) ...[
                Text(
                  'SAVED ACCOUNTS ON THIS DEVICE',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                ..._savedAccounts.map((acc) {
                  final email = acc['email'] ?? '';
                  final name = acc['name'] ?? email.split('@').first;
                  return _buildAccountTile(
                    name: name,
                    email: email,
                    isDark: isDark,
                    onTap: () => _chooseAccount(email, name),
                  );
                }),
                const SizedBox(height: 14),
              ],

              // Toggle or Custom account entry
              if (!_showCustomForm && _savedAccounts.isNotEmpty) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    HapticService.selection();
                    setState(() => _showCustomForm = true);
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('Use another Google account'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ] else ...[
                if (_savedAccounts.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ENTER GOOGLE ACCOUNT',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _showCustomForm = false),
                        child: const Text('Choose saved', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                // Email input
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131D16) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: _savedAccounts.isEmpty,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                      hintText: 'yourname@gmail.com',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Name input
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131D16) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                      hintText: 'Display name (e.g. Fortune)',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                if (_validationError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _validationError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmitCustom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8), // Google Brand Blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Continue with this Google Account',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                ),
              ],

              const SizedBox(height: 20),

              // Disclaimer
              Text(
                'To continue, Google will share your name, email address, and profile picture with Wellnest. See Wellnest Privacy Policy and Terms of Service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10.5,
                  height: 1.4,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile({
    required String name,
    required String email,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141E17) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: ListTile(
        onTap: _isSubmitting ? null : onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          email,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CustomPaint(
            painter: _GoogleLogoPainter(),
          ),
        ),
      ),
    );
  }
}

/// Official 4-color Google "G" vector painter
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Google Blue
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    // Google Green
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;

    // Google Yellow
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;

    // Google Red
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;

    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Blue horizontal bar
    final barRect = Rect.fromLTWH(w * 0.45, h * 0.40, w * 0.55, h * 0.20);
    canvas.drawRect(barRect, bluePaint);

    // Blue right arc
    final bluePath = Path()
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -0.5,
        1.1,
        false,
      )
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Green bottom arc
    final greenPath = Path()
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        0.6,
        1.5,
        false,
      )
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Yellow left arc
    final yellowPath = Path()
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        2.1,
        1.5,
        false,
      )
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Red top arc
    final redPath = Path()
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        3.6,
        1.4,
        false,
      )
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Inner cutout
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.58, holePaint);

    // Center re-bar
    canvas.drawRect(
      Rect.fromLTWH(w * 0.48, h * 0.40, w * 0.48, h * 0.20),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
