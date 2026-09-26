import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/glass/platform_glass_bottom_sheet.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/utils/wellness_report_exporter.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/state/wellness_provider.dart';

/// Opens the Executive Health Record & Telemetry Export sheet.
void showExportReportSheet(BuildContext context, WellnessProvider provider) {
  showPlatformGlassBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return ExportReportSheet(provider: provider);
    },
  );
}

class ExportReportSheet extends StatelessWidget {
  final WellnessProvider provider;

  const ExportReportSheet({super.key, required this.provider});

  void _exportPdf(BuildContext context) {
    HapticService.heavyImpact();
    final pdfBytes = WellnessReportExporter.generatePdfBytes(provider);

    // Open executive in-app preview modal
    Navigator.of(context).pop();
    _showPdfPreviewDialog(context, pdfBytes);
  }

  void _exportJson(BuildContext context) {
    HapticService.success();
    final jsonStr = WellnessReportExporter.generateJsonArchive(provider);
    Clipboard.setData(ClipboardData(text: jsonStr));

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Complete JSON telemetry for ${provider.userName} copied to clipboard!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _viewRawJson(BuildContext context) {
    HapticService.selection();
    final jsonStr = WellnessReportExporter.generateJsonArchive(provider);
    Navigator.of(context).pop();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF141A17) : Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Structured JSON Archive', style: AppTypography.h3(isDark).copyWith(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonStr));
                  HapticService.success();
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('JSON archive copied to clipboard!')),
                  );
                },
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SelectableText(
                jsonStr,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: isDark ? const Color(0xFFC0D0C5) : const Color(0xFF1E2822),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showPdfPreviewDialog(BuildContext context, Uint8List pdfBytes) {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.90,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1512) : const Color(0xFFF8FAF9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF33423A) : const Color(0xFFD2DCD5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Clinical PDF Dossier', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                        Text(
                          '${pdfBytes.lengthInBytes} bytes  •  Standard %PDF-1.4 (A4)',
                          style: AppTypography.caption(isDark),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Visual Document Reader Simulation
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F1D),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PDF Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131D18),
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(
                              top: BorderSide(color: AppColors.primary, width: 3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'BIOTHRIX CLINICAL DOSSIER',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'VERIFIED',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'OFFICIAL BIOMETRIC TELEMETRY & HEALTH PERFORMANCE RECORD  •  ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9EABA2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Patient Profile Block
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121A15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PATIENT / ATHLETE PROFILE',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Name: ${provider.userName}    DOB: ${provider.dateOfBirth.year}-${provider.dateOfBirth.month.toString().padLeft(2, '0')}-${provider.dateOfBirth.day.toString().padLeft(2, '0')}    Age: ${provider.age} yrs    Sex: ${provider.gender}',
                                style: const TextStyle(fontSize: 11, color: Colors.white, height: 1.4),
                              ),
                              Text(
                                'Height: ${provider.heightCm.toStringAsFixed(1)} cm    Target Weight: ${provider.targetWeightKg.toStringAsFixed(1)} kg    BMI: ${provider.bmi} [${provider.bmiCategory}]',
                                style: const TextStyle(fontSize: 11, color: Color(0xFFB0BEB4), height: 1.4),
                              ),
                              Text(
                                'Primary Objective: ${provider.primaryGoal}    Activity Tier: ${provider.activityLevel}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFFB0BEB4), height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Scorecard Preview
                        Row(
                          children: [
                            _buildPdfScorecardTile('DAILY STEPS', '${provider.steps}', 'Goal: ${provider.stepGoal}', const Color(0xFFFF9442)),
                            const SizedBox(width: 8),
                            _buildPdfScorecardTile('HYDRATION', '${(provider.waterGlasses * 0.25).toStringAsFixed(1)}L', '${provider.waterGlasses} glasses', const Color(0xFF2EB5FA)),
                            const SizedBox(width: 8),
                            _buildPdfScorecardTile('CALORIES', '${provider.calories}', 'Target: ${provider.targetCalories}', const Color(0xFF10B981)),
                            const SizedBox(width: 8),
                            _buildPdfScorecardTile('RESTING HR', '${provider.bpm > 0 ? provider.bpm : 72} BPM', 'Sleep: ${provider.sleepHours}h', const Color(0xFFEF4444)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // AI Clinical Observation
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121A15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BIOTHRIX AI CLINICAL OBSERVATION',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Patient demonstrates steady autonomic homeostasis with optimal resting cardiovascular frequency. Hydration volume and movement index align with active longevity benchmarks. Ready for clinical consultation.',
                                style: TextStyle(fontSize: 11, color: Color(0xFFCCD6CF), height: 1.45),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Footer seal
                        const Center(
                          child: Text(
                            'CONFIDENTIAL BIOMETRIC TELEMETRY RECORD  •  CRYPTOGRAPHICALLY SIGNED',
                            style: TextStyle(fontSize: 9, color: Color(0xFF708076), letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Confirmation Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161F1A) : Colors.white,
                  border: Border(top: BorderSide(color: isDark ? const Color(0xFF24332B) : const Color(0xFFE2E8E4))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('Share PDF'),
                        onPressed: () {
                          HapticService.selection();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Clinical PDF Dossier packaged for secure sharing!')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.download_done_rounded, color: Colors.black, size: 20),
                        label: const Text('Save to Device', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                        onPressed: () {
                          HapticService.success();
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved Biothrix Clinical PDF to on-device Downloads!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPdfScorecardTile(String title, String val, String sub, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF121A15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: accent)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Color(0xFF88978D))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF33423A) : const Color(0xFFD2DCD5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF26332C) : AppColors.primaryTint,
                  borderRadius: AppRadii.roundedSm,
                ),
                child: const Icon(Icons.file_download_outlined, color: AppColors.primaryDark, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export Health Records', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                    Text('Clinical PDF and structured JSON archives', style: AppTypography.caption(isDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Executive Preview Teaser Card
          SolidWellnessCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Clinical Dossier (PDF)',
                          style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: AppRadii.roundedPill,
                      ),
                      child: const Text(
                        'A4 READY',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Formatted in Biothrix dark slate styling with lime accents. Contains patient biometrics, BMI classification, daily scores, 7-day adherence table, and AI clinical summaries.',
                  style: AppTypography.caption(isDark).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Primary Button: Export Clinical PDF
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
            ),
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.black, size: 20),
            label: const Text(
              'Generate & Preview Clinical PDF',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            onPressed: () => _exportPdf(context),
          ),
          const SizedBox(height: 10),

          // Secondary Action: Copy JSON Archive
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
              side: BorderSide(
                color: isDark ? const Color(0xFF33423A) : const Color(0xFFC0CEC4),
              ),
            ),
            icon: const Icon(Icons.data_object_rounded, size: 20),
            label: const Text(
              'Copy Complete JSON Data Archive',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => _exportJson(context),
          ),
          const SizedBox(height: 8),

          // Tertiary Action: View Raw JSON
          TextButton(
            onPressed: () => _viewRawJson(context),
            child: Text(
              'Inspect Raw JSON Telemetry',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
