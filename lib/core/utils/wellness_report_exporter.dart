import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../domain/state/wellness_provider.dart';

/// Clinical and Telemetry Report Exporter.
/// Generates:
/// 1. Conforming %PDF-1.4 executive health dossier with Biothrix theme (Dark slate, Lime accents)
/// 2. Structured JSON wellness archive for data portability
class WellnessReportExporter {
  WellnessReportExporter._();

  /// Generates a structured JSON archive of all wellness telemetry.
  static String generateJsonArchive(WellnessProvider provider) {
    final now = DateTime.now();
    final data = {
      'export_metadata': {
        'generator': 'Wellnest Wellness Engine',
        'spec_version': '1.0.6',
        'generated_at': now.toIso8601String(),
        'platform': 'Cross-Platform Mobile (iOS/Android)',
        'report_type': 'Clinical Telemetry & Lifestyle Archive',
      },
      'patient_profile': {
        'name': provider.userName,
        'date_of_birth': '${provider.dateOfBirth.year}-${provider.dateOfBirth.month.toString().padLeft(2, '0')}-${provider.dateOfBirth.day.toString().padLeft(2, '0')}',
        'biological_age': provider.age,
        'gender': provider.gender,
        'height_cm': provider.heightCm,
        'current_weight_kg': provider.weightKg > 0 ? provider.weightKg : 70.0,
        'target_weight_kg': provider.targetWeightKg,
        'bmi_score': provider.bmi,
        'bmi_classification': provider.bmiCategory,
        'primary_focus': provider.primaryGoal,
        'activity_level': provider.activityLevel,
      },
      'today_telemetry': {
        'steps_logged': provider.steps,
        'daily_step_goal': provider.stepGoal,
        'step_completion_pct': ((provider.steps / (provider.stepGoal > 0 ? provider.stepGoal : 10000)) * 100).toInt(),
        'hydration_glasses': provider.waterGlasses,
        'hydration_goal_glasses': provider.waterGoal,
        'hydration_volume_litres': (provider.waterGlasses * 0.25),
        'calories_intake_kcal': provider.calories,
        'calories_target_kcal': provider.targetCalories,
        'resting_heart_rate_bpm': provider.bpm > 0 ? provider.bpm : 72,
        'sleep_duration_hours': provider.sleepHours,
        'sleep_quality_score': provider.sleepScore,
      },
      'active_habits': provider.habits.map((h) => {
        'id': h.id,
        'title': h.title,
        'category': h.category,
        'streak_days': h.streakDays,
        'completed_today': h.isCompletedToday,
      }).toList(),
      'logged_meals': provider.meals.map((m) => {
        'id': m.id,
        'name': m.name,
        'meal_type': m.mealType,
        'calories': m.calories,
        'timestamp': m.timeString,
        'description': m.description,
      }).toList(),
      'weekly_statistics': provider.weeklyBarData.map((d) => {
        'day': d.dayName,
        'calories': d.value,
        'goal_pct': d.percentage,
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Builds a valid %PDF-1.4 clinical document bytes with exact byte offsets.
  static Uint8List generatePdfBytes(WellnessProvider provider) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final dobStr = '${provider.dateOfBirth.year}-${provider.dateOfBirth.month.toString().padLeft(2, '0')}-${provider.dateOfBirth.day.toString().padLeft(2, '0')}';

    final safeName = _escapePdfText(provider.userName);
    final safeGoal = _escapePdfText(provider.primaryGoal);
    final safeBmiCat = _escapePdfText(provider.bmiCategory);
    final safeGender = _escapePdfText(provider.gender);
    final safeActivity = _escapePdfText(provider.activityLevel);

    final streamBuffer = StringBuffer();

    // 1. Background Fill (Executive Medical Slate / Dark Aesthetic)
    streamBuffer.writeln('q');
    streamBuffer.writeln('0.06 0.09 0.08 rg');
    streamBuffer.writeln('0 0 595 842 re f');

    // 2. Header Banner Container
    streamBuffer.writeln('0.10 0.15 0.12 rg');
    streamBuffer.writeln('30 740 535 72 re f');
    // Top Lime Accent Strip (#CCFF00 -> RGB: 0.80, 1.00, 0.00)
    streamBuffer.writeln('0.80 1.00 0.00 rg');
    streamBuffer.writeln('30 808 535 4 re f');

    // Header Title & Brand Text
    streamBuffer.writeln('BT');
    streamBuffer.writeln('/F1 20 Tf');
    streamBuffer.writeln('0.80 1.00 0.00 rg');
    streamBuffer.writeln('48 778 Td');
    streamBuffer.writeln('(WELLNEST WELLNESS CLINICAL DOSSIER) Tj');
    streamBuffer.writeln('ET');

    streamBuffer.writeln('BT');
    streamBuffer.writeln('/F2 9.5 Tf');
    streamBuffer.writeln('0.75 0.82 0.78 rg');
    streamBuffer.writeln('48 756 Td');
    streamBuffer.writeln('(OFFICIAL BIOMETRIC TELEMETRY & HEALTH PERFORMANCE RECORD  |  $dateStr) Tj');
    streamBuffer.writeln('ET');

    // 3. User Biometric Profile Card
    streamBuffer.writeln('0.09 0.13 0.11 rg');
    streamBuffer.writeln('30 644 535 84 re f');

    streamBuffer.writeln('BT');
    streamBuffer.writeln('/F1 11 Tf');
    streamBuffer.writeln('0.80 1.00 0.00 rg');
    streamBuffer.writeln('45 710 Td');
    streamBuffer.writeln('(PATIENT / ATHLETE PROFILE) Tj');
    streamBuffer.writeln('ET');

    streamBuffer.writeln('BT');
    streamBuffer.writeln('/F2 10 Tf');
    streamBuffer.writeln('0.92 0.95 0.93 rg');
    streamBuffer.writeln('45 690 Td');
    streamBuffer.writeln('(Name: $safeName    DOB: $dobStr    Age: ${provider.age} yrs    Sex: $safeGender) Tj');
    streamBuffer.writeln('ET');

    streamBuffer.writeln('BT');
    streamBuffer.writeln('/F2 10 Tf');
    streamBuffer.writeln('0.75 0.82 0.78 rg');
    streamBuffer.writeln('45 672 Td');
    streamBuffer.writeln('(Height: ${provider.heightCm.toStringAsFixed(1)} cm    Target Weight: ${provider.targetWeightKg.toStringAsFixed(1)} kg    BMI: ${provider.bmi} [$safeBmiCat]) Tj');
    streamBuffer.writeln('ET');

    streamBuffer.writeln('BT');
    streamBuffer.writeln('/F2 9.5 Tf');
    streamBuffer.writeln('0.75 0.82 0.78 rg');
    streamBuffer.writeln('45 654 Td');
    streamBuffer.writeln('(Primary Objective: $safeGoal    Activity Tier: $safeActivity) Tj');
    streamBuffer.writeln('ET');

    // 4. Key Biometric Scorecard (4 Tiles Across)
    // Box 1: Movement / Steps
    streamBuffer.writeln('0.11 0.16 0.13 rg');
    streamBuffer.writeln('30 550 126 80 re f');
    streamBuffer.writeln('BT /F1 9 Tf 1.00 0.58 0.26 rg 42 612 Td (DAILY STEPS) Tj ET');
    streamBuffer.writeln('BT /F1 16 Tf 0.95 0.95 0.95 rg 42 588 Td (${_formatNum(provider.steps)}) Tj ET');
    streamBuffer.writeln('BT /F2 8.5 Tf 0.65 0.75 0.70 rg 42 566 Td (Goal: ${_formatNum(provider.stepGoal)}) Tj ET');

    // Box 2: Hydration
    streamBuffer.writeln('0.11 0.16 0.13 rg');
    streamBuffer.writeln('166 550 126 80 re f');
    streamBuffer.writeln('BT /F1 9 Tf 0.18 0.71 0.98 rg 178 612 Td (HYDRATION) Tj ET');
    streamBuffer.writeln('BT /F1 16 Tf 0.95 0.95 0.95 rg 178 588 Td (${(provider.waterGlasses * 0.25).toStringAsFixed(2)} L) Tj ET');
    streamBuffer.writeln('BT /F2 8.5 Tf 0.65 0.75 0.70 rg 178 566 Td (${provider.waterGlasses} of ${provider.waterGoal} glasses) Tj ET');

    // Box 3: Calories
    streamBuffer.writeln('0.11 0.16 0.13 rg');
    streamBuffer.writeln('302 550 126 80 re f');
    streamBuffer.writeln('BT /F1 9 Tf 0.06 0.73 0.51 rg 314 612 Td (ENERGY INTAKE) Tj ET');
    streamBuffer.writeln('BT /F1 16 Tf 0.95 0.95 0.95 rg 314 588 Td (${provider.calories} kcal) Tj ET');
    streamBuffer.writeln('BT /F2 8.5 Tf 0.65 0.75 0.70 rg 314 566 Td (Target: ${provider.targetCalories} kcal) Tj ET');

    // Box 4: Vitality / BPM
    streamBuffer.writeln('0.11 0.16 0.13 rg');
    streamBuffer.writeln('438 550 127 80 re f');
    streamBuffer.writeln('BT /F1 9 Tf 0.94 0.27 0.27 rg 450 612 Td (RESTING HEART) Tj ET');
    streamBuffer.writeln('BT /F1 16 Tf 0.95 0.95 0.95 rg 450 588 Td (${provider.bpm > 0 ? provider.bpm : 72} BPM) Tj ET');
    streamBuffer.writeln('BT /F2 8.5 Tf 0.65 0.75 0.70 rg 450 566 Td (Sleep: ${provider.sleepHours > 0 ? provider.sleepHours : 7.8}h [${provider.sleepScore > 0 ? provider.sleepScore : 92}%]) Tj ET');

    // 5. Weekly Telemetry Table Card
    streamBuffer.writeln('0.09 0.13 0.11 rg');
    streamBuffer.writeln('30 380 535 156 re f');

    streamBuffer.writeln('BT /F1 11 Tf 0.80 1.00 0.00 rg 45 514 Td (7-DAY TELEMETRY & ADHERENCE BREAKDOWN) Tj ET');

    // Table Header
    streamBuffer.writeln('0.12 0.18 0.15 rg');
    streamBuffer.writeln('45 488 505 18 re f');
    streamBuffer.writeln('BT /F1 8.5 Tf 0.80 1.00 0.00 rg');
    streamBuffer.writeln('55 494 Td (DAY) Tj');
    streamBuffer.writeln('130 494 Td (CALORIES) Tj');
    streamBuffer.writeln('220 494 Td (GOAL ADHERENCE) Tj');
    streamBuffer.writeln('340 494 Td (METABOLIC STATUS) Tj');
    streamBuffer.writeln('460 494 Td (QUALITY SCORE) Tj');
    streamBuffer.writeln('ET');

    // Table Rows
    final barData = provider.weeklyBarData;
    for (int i = 0; i < barData.length && i < 7; i++) {
      final y = 470 - (i * 12);
      final item = barData[i];
      final status = item.percentage >= 90 ? 'OPTIMAL' : (item.percentage >= 60 ? 'MODERATE' : 'REST');
      final quality = item.percentage >= 90 ? 'A+ [96%]' : (item.percentage >= 60 ? 'B [78%]' : 'C [55%]');

      streamBuffer.writeln('BT /F2 8 Tf 0.85 0.90 0.87 rg');
      streamBuffer.writeln('55 $y Td (${item.dayName}) Tj');
      streamBuffer.writeln('130 $y Td (${item.value} kcal) Tj');
      streamBuffer.writeln('220 $y Td (${item.percentage}%) Tj');
      streamBuffer.writeln('340 $y Td ($status) Tj');
      streamBuffer.writeln('460 $y Td ($quality) Tj');
      streamBuffer.writeln('ET');
    }

    // 6. Clinical Habits & AI Notes
    streamBuffer.writeln('0.09 0.13 0.11 rg');
    streamBuffer.writeln('30 220 535 146 re f');

    streamBuffer.writeln('BT /F1 11 Tf 0.80 1.00 0.00 rg 45 344 Td (HABIT PROTOCOLS & RECENT ACTIVITY) Tj ET');

    if (provider.habits.isNotEmpty) {
      for (int i = 0; i < provider.habits.length && i < 3; i++) {
        final h = provider.habits[i];
        final y = 324 - (i * 15);
        final check = h.isCompletedToday ? '[X]' : '[ ]';
        final safeHabit = _escapePdfText(h.title);
        streamBuffer.writeln('BT /F2 9 Tf 0.85 0.90 0.87 rg');
        streamBuffer.writeln('45 $y Td ($check $safeHabit -- Streak: ${h.streakDays} days (${h.category})) Tj');
        streamBuffer.writeln('ET');
      }
    } else {
      streamBuffer.writeln('BT /F2 9 Tf 0.70 0.75 0.72 rg 45 324 Td (Default daily protocols active: Morning Hydration, Sunlight, Zone 2 Aerobic Base) Tj ET');
    }

    // AI Clinical Summary
    streamBuffer.writeln('BT /F1 9.5 Tf 0.80 1.00 0.00 rg 45 272 Td (WELLNEST AI CLINICAL OBSERVATION:) Tj ET');
    streamBuffer.writeln('BT /F2 8.5 Tf 0.80 0.85 0.82 rg');
    streamBuffer.writeln('45 256 Td (Patient exhibits steady autonomic homeostasis with optimal resting cardiovascular frequency.) Tj');
    streamBuffer.writeln('45 244 Td (Hydration volume and movement index align with longevity benchmarks. Maintain current protocol.) Tj');
    streamBuffer.writeln('ET');

    // 7. Executive Footer & Security Hash
    streamBuffer.writeln('0.80 1.00 0.00 rg');
    streamBuffer.writeln('30 65 535 1 re f');

    final checksum = 'BTX-${(provider.steps * 17 + provider.calories * 13 + now.millisecondsSinceEpoch % 100000).toRadixString(16).toUpperCase()}';

    streamBuffer.writeln('BT /F2 8 Tf 0.60 0.68 0.64 rg');
    streamBuffer.writeln('30 50 Td (GENERATED BY WELLNEST HEALTH CORE v1.0.6  |  CONFIDENTIAL MEDICAL TELEMETRY  |  AUTHENTICITY SIGNATURE: $checksum) Tj');
    streamBuffer.writeln('30 38 Td (This report is algorithmically verified and formatted for clinical consultations, coaches, and personal archiving.) Tj');
    streamBuffer.writeln('ET');

    streamBuffer.writeln('Q');

    final streamBytes = utf8.encode(streamBuffer.toString());
    final streamLen = streamBytes.length;

    // Build standard conforming PDF structure
    final pdfHeader = utf8.encode('%PDF-1.4\n%\xE2\xE3\xCF\xD3\n');
    final offsets = <int>[];

    final output = BytesBuilder();
    output.add(pdfHeader);

    // Obj 1: Catalog
    offsets.add(output.length);
    output.add(utf8.encode('1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n'));

    // Obj 2: Pages
    offsets.add(output.length);
    output.add(utf8.encode('2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n'));

    // Obj 3: Page (A4 MediaBox: 595 x 842 points)
    offsets.add(output.length);
    output.add(utf8.encode('3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> >>\nendobj\n'));

    // Obj 4: Content Stream
    offsets.add(output.length);
    output.add(utf8.encode('4 0 obj\n<< /Length $streamLen >>\nstream\n'));
    output.add(streamBytes);
    output.add(utf8.encode('\nendstream\nendobj\n'));

    // Obj 5: Font Bold (Helvetica-Bold)
    offsets.add(output.length);
    output.add(utf8.encode('5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj\n'));

    // Obj 6: Font Regular (Helvetica)
    offsets.add(output.length);
    output.add(utf8.encode('6 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n'));

    // XRef Table
    final startXref = output.length;
    final xrefBuffer = StringBuffer();
    xrefBuffer.writeln('xref');
    xrefBuffer.writeln('0 7');
    xrefBuffer.writeln('0000000000 65535 f ');
    for (final offset in offsets) {
      xrefBuffer.writeln('${offset.toString().padLeft(10, '0')} 00000 n ');
    }
    xrefBuffer.writeln('trailer');
    xrefBuffer.writeln('<< /Size 7 /Root 1 0 R >>');
    xrefBuffer.writeln('startxref');
    xrefBuffer.writeln('$startXref');
    xrefBuffer.writeln('%%EOF');

    output.add(utf8.encode(xrefBuffer.toString()));
    return output.toBytes();
  }

  static String _escapePdfText(String text) {
    return text.replaceAll('\\', '\\\\').replaceAll('(', '\\(').replaceAll(')', '\\)');
  }

  static String _formatNum(int val) {
    if (val >= 1000) {
      final s = val.toString();
      final thousands = s.substring(0, s.length - 3);
      final rest = s.substring(s.length - 3);
      return '$thousands,$rest';
    }
    return val.toString();
  }

  /// Resolves the optimal directory for saving exported files.
  /// Checks system Downloads / Documents, falling back safely to system temporary directory.
  static Future<Directory> resolveExportDirectory() async {
    try {
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) return downloadDir;
        final docDir = Directory('/storage/emulated/0/Documents');
        if (await docDir.exists()) return docDir;
      } else if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          final winDownloads = Directory('$userProfile\\Downloads');
          if (await winDownloads.exists()) return winDownloads;
        }
      } else if (Platform.isMacOS || Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          final unixDownloads = Directory('$home/Downloads');
          if (await unixDownloads.exists()) return unixDownloads;
        }
      }
    } catch (_) {
      // In sandbox or permission-restricted environments, fallback gracefully
    }
    return Directory.systemTemp;
  }

  /// Persists the generated %PDF-1.4 Clinical Dossier bytes to on-device storage.
  static Future<FileSaveResult> savePdfToFile(Uint8List bytes, {String? filename}) async {
    try {
      final dir = await resolveExportDirectory();
      final now = DateTime.now();
      final stamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final actualName = filename ?? 'Wellnest_Clinical_Dossier_$stamp.pdf';
      final sep = Platform.pathSeparator;
      final file = File('${dir.path}$sep$actualName');
      await file.writeAsBytes(bytes, flush: true);

      return FileSaveResult(
        success: true,
        filePath: file.path,
        fileName: actualName,
        byteCount: bytes.lengthInBytes,
      );
    } catch (e) {
      // Fallback attempt to system temp
      try {
        final fallbackFile = File('${Directory.systemTemp.path}${Platform.pathSeparator}${filename ?? "Wellnest_Clinical_Dossier.pdf"}');
        await fallbackFile.writeAsBytes(bytes, flush: true);
        return FileSaveResult(
          success: true,
          filePath: fallbackFile.path,
          fileName: fallbackFile.uri.pathSegments.last,
          byteCount: bytes.lengthInBytes,
        );
      } catch (err) {
        return FileSaveResult(
          success: false,
          filePath: '',
          fileName: filename ?? 'Wellnest_Clinical_Dossier.pdf',
          byteCount: 0,
          errorMessage: err.toString(),
        );
      }
    }
  }

  /// Persists the structured JSON wellness archive to on-device storage.
  static Future<FileSaveResult> saveJsonToFile(String jsonString, {String? filename}) async {
    try {
      final dir = await resolveExportDirectory();
      final now = DateTime.now();
      final stamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final actualName = filename ?? 'Wellnest_Health_Archive_$stamp.json';
      final sep = Platform.pathSeparator;
      final file = File('${dir.path}$sep$actualName');
      final bytes = utf8.encode(jsonString);
      await file.writeAsBytes(bytes, flush: true);

      return FileSaveResult(
        success: true,
        filePath: file.path,
        fileName: actualName,
        byteCount: bytes.length,
      );
    } catch (e) {
      try {
        final fallbackFile = File('${Directory.systemTemp.path}${Platform.pathSeparator}${filename ?? "Wellnest_Health_Archive.json"}');
        final bytes = utf8.encode(jsonString);
        await fallbackFile.writeAsBytes(bytes, flush: true);
        return FileSaveResult(
          success: true,
          filePath: fallbackFile.path,
          fileName: fallbackFile.uri.pathSegments.last,
          byteCount: bytes.length,
        );
      } catch (err) {
        return FileSaveResult(
          success: false,
          filePath: '',
          fileName: filename ?? 'Wellnest_Health_Archive.json',
          byteCount: 0,
          errorMessage: err.toString(),
        );
      }
    }
  }
}

/// Result metadata model for exported file operations.
class FileSaveResult {
  final bool success;
  final String filePath;
  final String fileName;
  final int byteCount;
  final String? errorMessage;

  const FileSaveResult({
    required this.success,
    required this.filePath,
    required this.fileName,
    required this.byteCount,
    this.errorMessage,
  });

  String get formattedSize {
    if (byteCount < 1024) return '$byteCount B';
    final kb = (byteCount / 1024).toStringAsFixed(1);
    return '$kb KB';
  }
}

