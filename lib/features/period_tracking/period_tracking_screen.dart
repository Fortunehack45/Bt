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
import '../pregnancy_tracking/pregnancy_tracking_screen.dart';
import 'widgets/cycle_calendar_view.dart';
import 'widgets/interactive_cycle_wheel_hero.dart';
import 'widgets/log_period_sheet.dart';

/// Full-featured Period Tracking & Menstrual Vitality Hub.
class PeriodTrackingScreen extends StatelessWidget {
  final VoidCallback onBack;

  const PeriodTrackingScreen({super.key, required this.onBack});

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final prediction = provider.periodPrediction;
    final lastPeriod = provider.lastRecordedPeriod;

    final cycleLen = provider.averageCycleLength.round();
    final periodDur = provider.averagePeriodDuration.round();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: true,
        child: Column(
          children: [
            // Standardized Screen Header matching exact 16px page margin of the app
            ScreenHeader(
              title: 'Menstrual Vitality',
              onBack: onBack,
              action: IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Log Flow or Symptoms',
                onPressed: () => showLogPeriodSheet(context, provider),
              ),
            ),

            // Scrollable Dashboard Content with aligned 16px horizontal margin
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
                    // Hero Interactive Cycle Wheel (Reference Image 1)
                    const InteractiveCycleWheelHero(),
                    const SizedBox(height: AppSpacing.md),

              // 2x2 Telemetry Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Avg Cycle Length',
                      value: '$cycleLen days',
                      sub: 'Historical rhythm',
                      icon: Icons.repeat_rounded,
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Avg Period Length',
                      value: '$periodDur days',
                      sub: 'Flow window',
                      icon: Icons.timer_outlined,
                      color: const Color(0xFFF43F5E),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Last Period Started',
                      value: lastPeriod != null
                          ? '${_months[lastPeriod.startDate.month - 1]} ${lastPeriod.startDate.day}'
                          : 'Not logged',
                      sub: lastPeriod != null ? '${lastPeriod.flow.displayName} flow' : 'Tap to start',
                      icon: Icons.calendar_today_rounded,
                      color: const Color(0xFF818CF8),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Estimated Next Period',
                      value: prediction.estimatedNextPeriodDate != null
                          ? '${_months[prediction.estimatedNextPeriodDate!.month - 1]} ${prediction.estimatedNextPeriodDate!.day}'
                          : 'Learning...',
                      sub: prediction.isLearningPhase ? 'More data needed' : 'Based on past cycles',
                      icon: Icons.event_available_rounded,
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Cycle Calendar
              CycleCalendarView(provider: provider),
              const SizedBox(height: AppSpacing.md),

              // Algorithmic Uncertainty & Safety Disclaimer Card
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
                    const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cycle Estimates & Health Notice',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            prediction.confidenceMessage,
                            style: AppTypography.caption(isDark).copyWith(fontSize: 11.5, height: 1.3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Wellnest is designed for wellness journaling and trend tracking. It is not a diagnostic device and should not be used as contraception or medical guidance.',
                            style: AppTypography.caption(isDark).copyWith(fontSize: 10.5, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Cycle History List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recorded Cycles',
                    style: AppTypography.h3(isDark),
                  ),
                  Text(
                    '${provider.periodCycles.length} logged',
                    style: AppTypography.caption(isDark),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (provider.periodCycles.isEmpty)
                EmptyStateView(
                  icon: Icons.water_drop_outlined,
                  title: 'No cycle records yet',
                  description: 'Log your first period to start tracking your cycle history and predicted phases.',
                  actionLabel: 'Log First Period',
                  onAction: () => showLogPeriodSheet(context, provider),
                )
              else
                ...provider.periodCycles.map((cycle) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: SolidWellnessCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF43F5E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_months[cycle.startDate.month - 1]} ${cycle.startDate.day} - ${cycle.endDate != null ? '${_months[cycle.endDate!.month - 1]} ${cycle.endDate!.day}' : 'Ongoing'}',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF43F5E).withOpacity(0.16),
                                  borderRadius: AppRadii.roundedPill,
                                ),
                                child: Text(
                                  '${cycle.periodDurationDays} days • ${cycle.flow.displayName}',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFF43F5E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (cycle.symptoms.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: cycle.symptoms.map((s) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF26332C) : const Color(0xFFE2EBE5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    s.displayName,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          if (cycle.notes.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '"${cycle.notes}"',
                              style: AppTypography.caption(isDark).copyWith(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.lg),

              // Seamless Pregnancy Transition Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF201B2E) : const Color(0xFFF7F3FF),
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.child_care_rounded, color: Color(0xFFA855F7), size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Expecting a Baby?',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF4A148C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Seamlessly transition your dashboard to Pregnancy Tracking. Your cycle history will remain safely preserved.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        HapticService.selection();
                        provider.transitionToPregnancyFromLastPeriod();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (ctx) => PregnancyTrackingScreen(
                              onBack: () => Navigator.of(ctx).pop(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA855F7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                      ),
                      child: const Text('Switch to Pregnancy Journey'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
);
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return SolidWellnessCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10.5,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
