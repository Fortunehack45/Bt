import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/circular_progress_ring.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';
import 'widgets/log_pregnancy_wellness_sheet.dart';
import 'widgets/pregnancy_setup_sheet.dart';

/// Full-featured Pregnancy Tracking & Maternal Wellness Dashboard.
class PregnancyTrackingScreen extends StatelessWidget {
  final VoidCallback onBack;

  const PregnancyTrackingScreen({super.key, required this.onBack});

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  void _showAddAppointmentDialog(BuildContext context, WellnessProvider provider) {
    HapticService.selection();
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime appointmentDate = DateTime.now().add(const Duration(days: 14));

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF141C17) : Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
              title: Text(
                'Add Prenatal Checkup',
                style: AppTypography.h3(isDark),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Appointment Title',
                      hintText: 'e.g. 20-Week Anatomy Ultrasound',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Doctor / Clinic',
                      hintText: 'e.g. Dr. Henderson, St. Jude Clinic',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      HapticService.success();
                      provider.addPregnancyAppointment(
                        title,
                        appointmentDate,
                        providerOrLocation: locationController.text.trim(),
                      );
                      Navigator.of(ctx).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA855F7)),
                  child: const Text('Save Checkup', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final preg = provider.pregnancyData;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.pageMargin,
            right: AppSpacing.pageMargin,
            top: 10.0,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              ScreenHeader(
                title: 'Pregnancy Journey',
                onBack: onBack,
                action: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Configure Dates',
                  onPressed: () => showPregnancySetupSheet(context, provider),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (preg == null) ...[
                // Unconfigured Empty State
                EmptyStateView(
                  icon: Icons.child_care_rounded,
                  title: 'Set up your pregnancy journey',
                  description: 'Enter your last period date or estimated due date to begin tracking gestational progress, milestones, and maternal wellbeing.',
                  actionLabel: '+ Configure Pregnancy Dates',
                  onAction: () => showPregnancySetupSheet(context, provider),
                ),
              ] else ...[
                // 1. Gestational Hero Card
                SolidWellnessCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFA855F7),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Week ${preg.currentWeek}',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                ' • Day ${preg.currentDayOfCurrentWeek}',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA855F7).withOpacity(0.18),
                              borderRadius: AppRadii.roundedPill,
                            ),
                            child: Text(
                              preg.trimesterLabel,
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFA855F7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Circular Progress & Development Description
                      Row(
                        children: [
                          SizedBox(
                            width: 86,
                            height: 86,
                            child: CircularProgressRing(
                              progress: preg.progressRatio,
                              strokeWidth: 8.0,
                              progressColor: const Color(0xFFA855F7),
                              backgroundColor: isDark ? const Color(0xFF26332C) : const Color(0xFFE2EBE5),
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(preg.progressRatio * 100).toInt()}%',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  Text(
                                    '40 Wks',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Baby is the ${preg.babySizeComparison}',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Length: ~${preg.estimatedLengthCm} cm • Weight: ~${preg.estimatedWeightGrams.toInt()} g',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFA855F7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${preg.daysUntilDueDate > 0 ? '${preg.daysUntilDueDate} days' : 'Due now'} until due date (${_months[preg.dueDate.month - 1]} ${preg.dueDate.day})',
                                  style: AppTypography.caption(isDark).copyWith(fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Log Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => showLogPregnancyWellnessSheet(context, provider),
                          icon: const Icon(Icons.favorite_border_rounded, size: 16),
                          label: const Text('Log Today\'s Maternal Wellbeing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA855F7),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 2. Trimester Milestone Stepper
                Text(
                  'Trimester Milestones',
                  style: AppTypography.h3(isDark),
                ),
                const SizedBox(height: 10),

                SolidWellnessCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTrimesterStep(
                        number: 1,
                        title: 'First Trimester (Weeks 1–12)',
                        description: 'Organogenesis, neural tube formation & early fetal development.',
                        isCurrent: preg.trimester == 1,
                        isCompleted: preg.trimester > 1,
                        isDark: isDark,
                      ),
                      const Divider(height: 24),
                      _buildTrimesterStep(
                        number: 2,
                        title: 'Second Trimester (Weeks 13–27)',
                        description: 'Rapid growth, movement perception, skeletal strengthening.',
                        isCurrent: preg.trimester == 2,
                        isCompleted: preg.trimester > 2,
                        isDark: isDark,
                      ),
                      const Divider(height: 24),
                      _buildTrimesterStep(
                        number: 3,
                        title: 'Third Trimester (Weeks 28–40)',
                        description: 'Lung maturation, antibody transfer & preparation for birth.',
                        isCurrent: preg.trimester == 3,
                        isCompleted: preg.currentWeek >= 40,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 3. Clinical Safety & Notice Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF19221C) : const Color(0xFFF3F7F4),
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: isDark ? const Color(0xFF26362D) : const Color(0xFFDEE7E1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFA855F7)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wellness Guidance Notice',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Gestational dates and size milestones are developmental benchmarks. Every pregnancy is unique. Always consult your obstetrician or midwife for clinical advice.',
                              style: AppTypography.caption(isDark).copyWith(fontSize: 11.5, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 4. Prenatal Appointments & Reminders
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prenatal Checkups',
                      style: AppTypography.h3(isDark),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddAppointmentDialog(context, provider),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Checkup'),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFA855F7)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                if (provider.pregnancyAppointments.isEmpty)
                  SolidWellnessCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note_rounded, color: Color(0xFFA855F7), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No prenatal visits scheduled. Tap "Add Checkup" to set reminders.',
                            style: AppTypography.caption(isDark),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...provider.pregnancyAppointments.map((appt) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SolidWellnessCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Checkbox(
                              value: appt.isCompleted,
                              activeColor: const Color(0xFFA855F7),
                              onChanged: (_) => provider.toggleAppointmentCompleted(appt.id),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appt.title,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      decoration: appt.isCompleted ? TextDecoration.lineThrough : null,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  if (appt.providerOrLocation.isNotEmpty)
                                    Text(
                                      appt.providerOrLocation,
                                      style: AppTypography.caption(isDark).copyWith(fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '${_months[appt.date.month - 1]} ${appt.date.day}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFA855F7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: AppSpacing.lg),

                // 5. Recent Journal & Symptoms
                Text(
                  'Recent Reflections & Logs',
                  style: AppTypography.h3(isDark),
                ),
                const SizedBox(height: 10),

                if (provider.pregnancyLogs.isEmpty)
                  SolidWellnessCard(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No daily entries logged yet. Tap "Log Today\'s Maternal Wellbeing" above.',
                      style: AppTypography.caption(isDark),
                    ),
                  )
                else
                  ...provider.pregnancyLogs.take(5).map((log) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SolidWellnessCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_months[log.date.month - 1]} ${log.date.day}',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                if (log.mood != null)
                                  Text(
                                    log.mood!,
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                                  ),
                              ],
                            ),
                            if (log.symptoms.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                children: log.symptoms.map((s) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA855F7).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 10.5, color: Color(0xFFA855F7), fontWeight: FontWeight.w600),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            if (log.notes.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                '"${log.notes}"',
                                style: AppTypography.caption(isDark).copyWith(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrimesterStep({
    required int number,
    required String title,
    required String description,
    required bool isCurrent,
    required bool isCompleted,
    required bool isDark,
  }) {
    Color badgeColor;
    if (isCompleted) {
      badgeColor = const Color(0xFF10B981);
    } else if (isCurrent) {
      badgeColor = const Color(0xFFA855F7);
    } else {
      badgeColor = isDark ? Colors.white24 : Colors.black26;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: badgeColor, width: 1.5),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 16)
                : Text(
                    '$number',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.5,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCurrent
                      ? (isDark ? Colors.white : const Color(0xFF4A148C))
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.caption(isDark).copyWith(fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
