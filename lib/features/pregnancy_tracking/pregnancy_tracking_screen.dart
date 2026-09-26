import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';
import 'widgets/add_prenatal_checkup_sheet.dart';
import 'widgets/fetal_development_alive_hero.dart';
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
        child: Column(
          children: [
            // 1. Standardized Screen Header matching exact 16px page margin of the app
            ScreenHeader(
              title: 'Pregnancy Journey',
              onBack: onBack,
              action: IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Configure Dates',
                onPressed: () => showPregnancySetupSheet(context, provider),
              ),
            ),

            // 2. Scrollable Dashboard Content with aligned 16px horizontal margin
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: AppSpacing.pageMargin,
                  right: AppSpacing.pageMargin,
                  top: 4.0,
                  bottom: AppSpacing.contentBottomPadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      // 1. Fetal Development "Alive" Hero Portal (Reference Image 4)
                      const FetalDevelopmentAliveHero(),
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
                              isCompleted: false,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // 3. Clinical Wellness Guidance Notice
                      SolidWellnessCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFFA855F7)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wellness Guidance Notice',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
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
                      const SizedBox(height: AppSpacing.md),

                      // 4. Prenatal Checkups Section (Detailed Slide-Up Sheet)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prenatal Checkups',
                            style: AppTypography.h3(isDark),
                          ),
                          TextButton.icon(
                            onPressed: () => showAddPrenatalCheckupSheet(context, provider),
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
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: appt.type.color.withOpacity(0.14),
                                      borderRadius: AppRadii.roundedSm,
                                    ),
                                    child: Icon(appt.type.icon, size: 16, color: appt.type.color),
                                  ),
                                  const SizedBox(width: 10),
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
                                        Row(
                                          children: [
                                            Text(
                                              '${_months[appt.date.month - 1]} ${appt.date.day} • ${appt.timeString}',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: appt.type.color,
                                              ),
                                            ),
                                            if (appt.providerOrLocation.isNotEmpty) ...[
                                              Text(' • ', style: AppTypography.caption(isDark)),
                                              Expanded(
                                                child: Text(
                                                  appt.providerOrLocation,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTypography.caption(isDark).copyWith(fontSize: 11),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (appt.preparation.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Prep: ${appt.preparation}',
                                            style: AppTypography.caption(isDark).copyWith(
                                              fontSize: 10.5,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 16),
                                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                    onPressed: () {
                                      HapticService.selection();
                                      provider.deletePregnancyAppointment(appt.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: AppSpacing.md),

                      // 5. Recent Reflections & Maternal Logs Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Reflections & Logs',
                            style: AppTypography.h3(isDark),
                          ),
                          TextButton.icon(
                            onPressed: () => showLogPregnancyWellnessSheet(context, provider),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Reflection'),
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFFA855F7)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

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
                                        '${_months[log.date.month - 1]} ${log.date.day}, ${log.date.year}',
                                        style: TextStyle(
                                          fontFamily: AppTypography.fontFamily,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      if (log.mood != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFA855F7).withOpacity(0.14),
                                            borderRadius: AppRadii.roundedPill,
                                          ),
                                          child: Text(
                                            log.mood!,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFA855F7)),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (log.symptoms.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: log.symptoms.map((s) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF26332C) : const Color(0xFFE2EBE5),
                                            borderRadius: AppRadii.roundedPill,
                                          ),
                                          child: Text(
                                            s,
                                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                  if (log.notes.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      log.notes,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                      ),
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
          ],
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
    Color stepColor = isCurrent
        ? const Color(0xFFA855F7)
        : (isCompleted ? const Color(0xFF10B981) : (isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: stepColor.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: stepColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFF10B981))
              : Text(
                  '$number',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: stepColor,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withOpacity(0.2),
                        borderRadius: AppRadii.roundedPill,
                      ),
                      child: const Text(
                        'Current',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFA855F7)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.caption(isDark).copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
