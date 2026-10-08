import 'package:flutter/material.dart';
import '../../core/glass/platform_frosted_container.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/services/firebase_sync_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/models/clinician_pair_model.dart';
import '../../domain/state/wellness_provider.dart';

/// Patient settings screen to generate Pair Codes for doctors, configure security
/// questions, select permitted telemetry categories, and view real-time screenshot alerts.
class ClinicianSharingSettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ClinicianSharingSettingsScreen({super.key, required this.onBack});

  @override
  State<ClinicianSharingSettingsScreen> createState() => _ClinicianSharingSettingsScreenState();
}

class _ClinicianSharingSettingsScreenState extends State<ClinicianSharingSettingsScreen> {
  final FirebaseSyncService _syncService = FirebaseSyncService.instance;

  void _openGenerateCodeModal() {
    HapticService.selection();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GeneratePairCodeSheet(
        onCodeCreated: (grant) {
          Navigator.of(ctx).pop();
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Doctor Pair Code ${grant.pairCode} generated successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final grants = provider.clinicianGrants;

    // Collect all screenshot alerts across all grants
    final allScreenshotAlerts = <ScreenshotAuditEntry>[];
    for (final g in grants) {
      allScreenshotAlerts.addAll(g.screenshotAuditLog);
    }
    allScreenshotAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            HapticService.lightImpact();
            widget.onBack();
          },
        ),
        title: Text(
          'Doctor & Examiner Access',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: false,
        bottomSafeArea: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Explanation Card
              PlatformFrostedContainer(
                borderRadius: BorderRadius.circular(22),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldTeal.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_person_rounded,
                            color: AppColors.emeraldTeal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Controlled Clinician Sharing',
                                style: AppTypography.h3(isDark).copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Zero-email pair code with mandatory security Q&A and instant screenshot alerts.',
                                style: AppTypography.caption(isDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _openGenerateCodeModal,
                      icon: const Icon(Icons.add_link_rounded, size: 20),
                      label: const Text('Generate New Clinician Pair Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimaryLight,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Active Grants Section
              Text(
                'ACTIVE CLINICIAN PASSES',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 10),

              if (grants.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131C15) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF202C22) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'No active clinician passes. Tap above to create one.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ),
                )
              else
                ...grants.map((grant) => _buildGrantCard(grant, isDark)),

              const SizedBox(height: 24),

              // Screenshot Audit Alerts Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SECURITY & SCREENSHOT AUDIT LOG',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (allScreenshotAlerts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${allScreenshotAlerts.length} Captured',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.errorRed,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (allScreenshotAlerts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131C15) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF202C22) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No unauthorized screenshots detected. Your telemetry is secure.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...allScreenshotAlerts.map((alert) => _buildAlertCard(alert, isDark)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrantCard(ClinicianPairGrant grant, bool isDark) {
    final isExpired = grant.isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141E17) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired
              ? (isDark ? Colors.white10 : Colors.black12)
              : AppColors.emeraldTeal.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? Colors.grey.withOpacity(0.2)
                          : AppColors.emeraldTeal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      grant.pairCode,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isExpired ? Colors.grey : AppColors.emeraldTeal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isExpired ? 'Expired' : 'Active Pass',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isExpired ? Colors.grey : AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (!isExpired && grant.isActive)
                TextButton(
                  onPressed: () {
                    HapticService.selection();
                    _syncService.revokePairGrant(grant.pairCode);
                  },
                  child: const Text('Revoke', style: TextStyle(color: AppColors.errorRed, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Permitted sections: ${grant.permittedSections.join(', ')}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isExpired
                ? 'Expired on ${grant.expiresAt.month}/${grant.expiresAt.day} at ${grant.expiresAt.hour}:${grant.expiresAt.minute.toString().padLeft(2, '0')}'
                : 'Auto-expires in ${grant.remainingTime.inHours}h ${grant.remainingTime.inMinutes % 60}m',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(ScreenshotAuditEntry alert, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notification_important_rounded, color: AppColors.errorRed, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Screenshot captured on ${alert.sectionName}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Examiner pass ${alert.examinerCode} • ${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal sheet for creating a doctor pair code with security answers and custom duration.
class _GeneratePairCodeSheet extends StatefulWidget {
  final Function(ClinicianPairGrant grant) onCodeCreated;

  const _GeneratePairCodeSheet({required this.onCodeCreated});

  @override
  State<_GeneratePairCodeSheet> createState() => _GeneratePairCodeSheetState();
}

class _GeneratePairCodeSheetState extends State<_GeneratePairCodeSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();

  Duration _selectedDuration = const Duration(hours: 24);
  bool _allowVitals = true;
  bool _allowSteps = true;
  bool _allowSleep = true;
  bool _allowWater = true;
  bool _allowReproductive = false; // Intimacy guard: off by default

  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuthService.instance.currentUser;
    _nameController.text = (user != null && !user.isGuest && user.displayName.isNotEmpty)
        ? user.displayName
        : '';
    _secretController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    HapticService.mediumImpact();
    setState(() => _isCreating = true);

    final permitted = <String>[];
    if (_allowVitals) permitted.add('vitals');
    if (_allowSteps) permitted.add('steps');
    if (_allowSleep) permitted.add('sleep');
    if (_allowWater) permitted.add('water');
    if (_allowReproductive) permitted.add('reproductive');

    final grant = await FirebaseSyncService.instance.createClinicianPairGrant(
      patientName: _nameController.text.trim(),
      securityQuestion1: 'Patient Legal Name',
      securityAnswer1: _nameController.text.trim(),
      securityQuestion2: 'Patient Secret / Favorite Color',
      securityAnswer2: _secretController.text.trim(),
      permittedSections: permitted,
      duration: _selectedDuration,
    );

    if (mounted) {
      setState(() => _isCreating = false);
      widget.onCodeCreated(grant);
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
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 16),
              Text(
                'Generate Doctor Pair Pass',
                style: AppTypography.h2(isDark).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'Set security verification answers and allowed telemetry categories.',
                style: AppTypography.caption(isDark),
              ),
              const SizedBox(height: 18),

              // Q1: Name
              Text('QUESTION 1: PATIENT NAME', style: _labelStyle(isDark)),
              const SizedBox(height: 6),
              _buildInput(_nameController, 'e.g. Your Full Name', isDark),

              const SizedBox(height: 14),

              // Q2: Secret
              Text('QUESTION 2: SECRET ANSWER / FAVORITE COLOR', style: _labelStyle(isDark)),
              const SizedBox(height: 6),
              _buildInput(_secretController, 'e.g. Blue, Emerald, etc.', isDark),

              const SizedBox(height: 16),

              // Duration Choices
              Text('PASS DURATION (AUTO-EXPIRES AFTER)', style: _labelStyle(isDark)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _durationChip('1 Hour', const Duration(hours: 1)),
                  _durationChip('4 Hours', const Duration(hours: 4)),
                  _durationChip('24 Hours', const Duration(hours: 24)),
                  _durationChip('7 Days', const Duration(days: 7)),
                ],
              ),

              const SizedBox(height: 16),

              // Permitted Categories
              Text('PERMITTED HEALTH CATEGORIES', style: _labelStyle(isDark)),
              const SizedBox(height: 6),
              _checkbox('Cardiac Vitals & Heart Rate (BPM)', _allowVitals, (v) => setState(() => _allowVitals = v!)),
              _checkbox('Activity & Daily Step Count', _allowSteps, (v) => setState(() => _allowSteps = v!)),
              _checkbox('Sleep Duration & Metrics', _allowSleep, (v) => setState(() => _allowSleep = v!)),
              _checkbox('Hydration Intake Logs', _allowWater, (v) => setState(() => _allowWater = v!)),
              _checkbox('Reproductive & Cycle Health (Opt-in)', _allowReproductive, (v) => setState(() => _allowReproductive = v!)),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isCreating ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimaryLight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Generate Pair Pass', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _durationChip(String label, Duration dur) {
    final isSelected = _selectedDuration == dur;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? AppColors.textPrimaryLight : null,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedDuration = dur);
      },
    );
  }

  Widget _checkbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
    );
  }

  TextStyle _labelStyle(bool isDark) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
      );

  Widget _buildInput(TextEditingController controller, String hint, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D16) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF223024) : const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
