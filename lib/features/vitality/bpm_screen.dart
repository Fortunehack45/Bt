import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/state/wellness_provider.dart';
import 'widgets/log_bpm_sheet.dart';

/// Dedicated Heart Rate & Cardiovascular Vitality Hub.
class BpmScreen extends StatefulWidget {
  final VoidCallback onBack;

  const BpmScreen({super.key, required this.onBack});

  @override
  State<BpmScreen> createState() => _BpmScreenState();
}

class _BpmScreenState extends State<BpmScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final currentBpm = provider.bpm > 0 ? provider.bpm : 72;

    String zoneLabel = 'Normal Resting';
    Color zoneColor = const Color(0xFF10B981);
    if (currentBpm < 60) {
      zoneLabel = 'Athletic / Bradycardia';
      zoneColor = AppColors.waterBlue;
    } else if (currentBpm > 100) {
      zoneLabel = 'Elevated / Active';
      zoneColor = AppColors.stepsOrange;
    }

    return Scaffold(
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.pageMargin,
            right: AppSpacing.pageMargin,
            top: AppSpacing.xs,
            bottom: AppSpacing.contentBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Unified Standardized Header
              ScreenHeader(
                title: 'Heart Rate & Vitals',
                subtitle: 'Cardiovascular Vitality',
                onBack: widget.onBack,
                trailing: ElevatedButton.icon(
                  onPressed: () => showLogBpmSheet(context, provider),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Log', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.heartRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Heart Pulse Hero Card
              SolidWellnessCard(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.heartRed.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.heartRed,
                          size: 52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$currentBpm',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 54,
                        fontWeight: FontWeight.w800,
                        color: AppColors.heartRed,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'BEATS PER MINUTE (BPM)',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: zoneColor.withOpacity(0.18),
                        borderRadius: AppRadii.roundedPill,
                      ),
                      child: Text(
                        zoneLabel,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: zoneColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Heart Rate Zones Breakdown
              Text('Heart Rate Zones', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              _buildZoneRow('Resting Zone', '< 60 bpm', 'Sleep, meditation, deep rest', AppColors.waterBlue, isDark),
              const SizedBox(height: 8),
              _buildZoneRow('Normal Rhythm', '60 – 100 bpm', 'Everyday calm activities', const Color(0xFF10B981), isDark),
              const SizedBox(height: 8),
              _buildZoneRow('Cardio Burn', '100 – 140 bpm', 'Brisk walking, cycling, endurance', AppColors.stepsOrange, isDark),
              const SizedBox(height: 8),
              _buildZoneRow('Peak Performance', '140+ bpm', 'HIIT, sprints, heavy lifting', AppColors.heartRed, isDark),
              const SizedBox(height: AppSpacing.lg),

              // 4. Quick Log Action
              SolidWellnessCard(
                padding: const EdgeInsets.all(18.0),
                onTap: () => showLogBpmSheet(context, provider),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.heartRed.withOpacity(0.15),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: const Icon(Icons.monitor_heart_rounded, color: AppColors.heartRed, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Record Heart Reading', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
                            Text('Tap to update current pulse', style: AppTypography.caption(isDark)),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneRow(String title, String range, String desc, Color color, bool isDark) {
    return SolidWellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLarge(isDark).copyWith(fontWeight: FontWeight.w700)),
                Text(desc, style: AppTypography.caption(isDark)),
              ],
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
