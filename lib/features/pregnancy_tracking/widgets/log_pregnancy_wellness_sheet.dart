import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../domain/state/wellness_provider.dart';

/// Shows the slide-up sheet to log pregnancy wellness, symptoms, and daily reflections.
void showLogPregnancyWellnessSheet(BuildContext context, WellnessProvider provider) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (sheetContext) {
      final topPadding = MediaQuery.of(sheetContext).padding.top;
      return Container(
        margin: EdgeInsets.only(top: topPadding + 20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height - (topPadding + 20),
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141C17) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: LogPregnancyWellnessSheet(provider: provider),
        ),
      );
    },
  );
}

class LogPregnancyWellnessSheet extends StatefulWidget {
  final WellnessProvider provider;

  const LogPregnancyWellnessSheet({super.key, required this.provider});

  @override
  State<LogPregnancyWellnessSheet> createState() => _LogPregnancyWellnessSheetState();
}

class _LogPregnancyWellnessSheetState extends State<LogPregnancyWellnessSheet> {
  final Set<String> _selectedSymptoms = {};
  String? _selectedMood;
  final TextEditingController _notesController = TextEditingController();

  static const List<String> _commonSymptoms = [
    'Morning Sickness',
    'Fatigue',
    'Heartburn',
    'Lower Back Aches',
    'Pelvic Pressure',
    'Swollen Ankles',
    'Food Cravings',
    'Food Aversions',
    'Sleep Changes',
    'Braxton Hicks',
    'Mood Shifts',
    'Headache',
  ];

  static const List<({String label, String emoji})> _moods = [
    (label: 'Blissful & Peaceful', emoji: '🌸'),
    (label: 'Grounded & Content', emoji: '😌'),
    (label: 'Emotional / Sensitive', emoji: '🥺'),
    (label: 'Fatigued / Sleepy', emoji: '😴'),
    (label: 'Anxious / Nesting', emoji: '🕊️'),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    HapticService.success();
    widget.provider.logPregnancyWellness(
      DateTime.now(),
      symptoms: _selectedSymptoms.toList(),
      mood: _selectedMood,
      notes: _notesController.text.trim(),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged maternal wellbeing for today!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.pageMargin,
        right: AppSpacing.pageMargin,
        top: 12.0,
        bottom: bottomInset > 0 ? bottomInset + 16 : MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2.25),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withOpacity(0.18),
                        borderRadius: AppRadii.roundedSm,
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Color(0xFFA855F7), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maternal Wellbeing',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'Log daily observations & wellness symptoms',
                          style: AppTypography.caption(isDark).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Symptoms Wrap
            Text(
              'Symptoms Experienced Today',
              style: AppTypography.h3(isDark).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSymptoms.map((sym) {
                final isSel = _selectedSymptoms.contains(sym);
                return GestureDetector(
                  onTap: () {
                    HapticService.selection();
                    setState(() {
                      if (isSel) {
                        _selectedSymptoms.remove(sym);
                      } else {
                        _selectedSymptoms.add(sym);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0xFFA855F7).withOpacity(0.18)
                          : (isDark ? const Color(0xFF1C2520) : const Color(0xFFEDF3EE)),
                      borderRadius: AppRadii.roundedPill,
                      border: Border.all(
                        color: isSel
                            ? const Color(0xFFA855F7)
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: Text(
                      sym,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel
                            ? (isDark ? const Color(0xFFE9D5FF) : const Color(0xFF7E22CE))
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Mood
            Text(
              'Emotional State',
              style: AppTypography.h3(isDark).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moods.map((m) {
                final isSel = _selectedMood == m.label;
                return GestureDetector(
                  onTap: () {
                    HapticService.selection();
                    setState(() {
                      _selectedMood = isSel ? null : m.label;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primary.withOpacity(0.18)
                          : (isDark ? const Color(0xFF1C2520) : const Color(0xFFEDF3EE)),
                      borderRadius: AppRadii.roundedPill,
                      border: Border.all(
                        color: isSel
                            ? AppColors.primary
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(m.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          m.label,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel
                                ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Notes / Journal
            Text(
              'Personal Journal & Reflections',
              style: AppTypography.h3(isDark).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'How are you and baby feeling today?...',
                filled: true,
                fillColor: isDark ? const Color(0xFF1C2520) : const Color(0xFFEDF3EE),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: AppRadii.roundedSm,
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadii.roundedSm,
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: AppRadii.roundedSm,
                  borderSide: BorderSide(color: Color(0xFFA855F7), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA855F7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                ),
                child: const Text(
                  'Save Entry',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
