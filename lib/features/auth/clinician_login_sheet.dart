import 'package:flutter/material.dart';
import '../../core/glass/platform_frosted_container.dart';
import '../../core/services/firebase_sync_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../clinician/clinician_view_screen.dart';

/// Modal bottom sheet allowing doctors and examiners to access patient telemetry
/// via 6-digit Pair Code and security questions without needing a Google or email account.
class ClinicianLoginSheet extends StatefulWidget {
  final VoidCallback onClinicianVerified;

  const ClinicianLoginSheet({
    super.key,
    required this.onClinicianVerified,
  });

  @override
  State<ClinicianLoginSheet> createState() => _ClinicianLoginSheetState();
}

class _ClinicianLoginSheetState extends State<ClinicianLoginSheet> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _ans1Controller = TextEditingController();
  final TextEditingController _ans2Controller = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _ans1Controller.dispose();
    _ans2Controller.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    HapticService.mediumImpact();
    final code = _codeController.text.trim();
    final ans1 = _ans1Controller.text.trim();
    final ans2 = _ans2Controller.text.trim();

    if (code.isEmpty || ans1.isEmpty || ans2.isEmpty) {
      setState(() => _errorMessage = 'Please complete all pairing and security fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final grant = await FirebaseSyncService.instance.verifyClinicianAccess(
      pairCode: code,
      ans1: ans1,
      ans2: ans2,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (grant != null) {
        HapticService.success();
        widget.onClinicianVerified();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ClinicianViewScreen(grant: grant),
          ),
        );
      } else {
        HapticService.error();
        setState(() {
          _errorMessage = 'Invalid pair code, security answers mismatch, or session has expired.';
        });
      }
    }
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
              // Drag handle
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

              // Shield Icon & Title
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.emeraldTeal.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.emeraldTeal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinician & Doctor Portal',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Zero-email temporary consultation login',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Pair Code Input
              Text(
                'CLINICIAN PAIR CODE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 6),
              _buildInput(
                controller: _codeController,
                hint: 'e.g. DOC-7842',
                icon: Icons.vpn_key_rounded,
                isDark: isDark,
                textCapitalization: TextCapitalization.characters,
              ),

              const SizedBox(height: 14),

              // Security Answer 1: Patient Name
              Text(
                'SECURITY VERIFICATION 1: PATIENT NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 6),
              _buildInput(
                controller: _ans1Controller,
                hint: 'Enter patient full name or identifier',
                icon: Icons.person_outline_rounded,
                isDark: isDark,
              ),

              const SizedBox(height: 14),

              // Security Answer 2: Favorite Color / Secret
              Text(
                'SECURITY VERIFICATION 2: SECRET ANSWER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 6),
              _buildInput(
                controller: _ans2Controller,
                hint: 'Enter patient secret color or word',
                icon: Icons.lock_outline_rounded,
                isDark: isDark,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.errorRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.errorRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 22),

              // Verify & Connect Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Access Patient Telemetry',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // Privacy & Screenshot Warning Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131D16) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.privacy_tip_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Audit notice: Session is time-bound. Screen captures automatically alert the patient in real time.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C15) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF243227) : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: controller,
        textCapitalization: textCapitalization,
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
          prefixIcon: Icon(icon, size: 20, color: AppColors.emeraldTeal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
