import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/glass/platform_frosted_container.dart';
import '../../core/services/firebase_sync_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/models/clinician_pair_model.dart';
import '../../domain/state/wellness_provider.dart';

/// Restricted Clinical Telemetry View rendered when a doctor/examiner logs in
/// via Pair Code and verified security answers.
class ClinicianViewScreen extends StatefulWidget {
  final ClinicianPairGrant grant;

  const ClinicianViewScreen({
    super.key,
    required this.grant,
  });

  @override
  State<ClinicianViewScreen> createState() => _ClinicianViewScreenState();
}

class _ClinicianViewScreenState extends State<ClinicianViewScreen> {
  Timer? _countdownTimer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.grant.remainingTime;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final remaining = widget.grant.remainingTime;
      if (remaining <= Duration.zero) {
        timer.cancel();
        _handleSessionExpired();
      } else {
        setState(() => _timeLeft = remaining);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _handleSessionExpired() {
    FirebaseSyncService.instance.exitClinicianSession();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clinician consultation session has expired and terminated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _triggerSimulatedScreenshotAlert(String section) async {
    HapticService.error();
    await FirebaseSyncService.instance.reportScreenshotCaptured(section);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Screenshot detected on $section! Patient alerted immediately.'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final grant = widget.grant;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111913) : Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctor Consultation View',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Patient: ${grant.patientDisplayName} (${grant.pairCode})',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.emeraldTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Simulate/Test Screenshot Capture Detection',
            icon: const Icon(Icons.camera_alt_outlined, color: AppColors.warningAmber),
            onPressed: () => _triggerSimulatedScreenshotAlert('Vitals & ECG Summary'),
          ),
          TextButton(
            onPressed: () {
              FirebaseSyncService.instance.exitClinicianSession();
              Navigator.of(context).pop();
            },
            child: const Text('Exit', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w700)),
          ),
        ],
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
              // Top Live Expiration Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.emeraldTeal.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.emeraldTeal.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.emeraldTeal, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SESSION TIME REMAINING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: AppColors.emeraldTeal,
                            ),
                          ),
                          Text(
                            _formatDuration(_timeLeft),
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldTeal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Patient Clinical Demographics Card
              PlatformFrostedContainer(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PATIENT CLINICAL SUMMARY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildClinicalStat('Age', '28 yrs', isDark),
                        _buildClinicalStat('Blood Group', 'O+', isDark),
                        _buildClinicalStat('Weight', '${provider.weight.toStringAsFixed(1)} kg', isDark),
                        _buildClinicalStat('Height', '${provider.height.toStringAsFixed(0)} cm', isDark),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Permitted Category 1: Vitals & Heart Rate (BPM)
              if (grant.canAccessSection('vitals')) ...[
                _buildSectionHeader('CARDIAC VITALS & HEART RATE', isDark),
                const SizedBox(height: 8),
                PlatformFrostedContainer(
                  borderRadius: BorderRadius.circular(18),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.favorite_rounded, color: AppColors.errorRed, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'Resting Heart Rate',
                                style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                              ),
                            ],
                          ),
                          Text(
                            '${provider.currentBpm} BPM',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.errorRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Clinical assessment: Normal sinus rhythm. Telemetry acquired via connected wearable hardware.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Permitted Category 2: Activity & Daily Steps
              if (grant.canAccessSection('steps')) ...[
                _buildSectionHeader('PHYSICAL MOBILITY & STEP TELEMETRY', isDark),
                const SizedBox(height: 8),
                PlatformFrostedContainer(
                  borderRadius: BorderRadius.circular(18),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Step Count',
                            style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Goal: ${provider.stepGoal} steps',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${provider.steps}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Permitted Category 3: Sleep Architecture
              if (grant.canAccessSection('sleep')) ...[
                _buildSectionHeader('SLEEP RESTORATION', isDark),
                const SizedBox(height: 8),
                PlatformFrostedContainer(
                  borderRadius: BorderRadius.circular(18),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Last Sleep Duration',
                        style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                      ),
                      Text(
                        '${provider.sleepHours.toStringAsFixed(1)} hrs',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.purpleSleep,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Permitted Category 4: Hydration
              if (grant.canAccessSection('water')) ...[
                _buildSectionHeader('HYDRATION BALANCE', isDark),
                const SizedBox(height: 8),
                PlatformFrostedContainer(
                  borderRadius: BorderRadius.circular(18),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Water Intake Today',
                        style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                      ),
                      Text(
                        '${provider.waterGlasses} / ${provider.waterGoal} glasses',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.hydrationBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Restricted Sections Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141C15) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF222F24) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 20, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Patient privacy controls are active. Any unselected categories (such as reproductive health and private journals) remain securely locked from examiner view.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClinicalStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
      ),
    );
  }
}
