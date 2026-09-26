import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../domain/models/reproductive_health_models.dart';
import '../../../domain/state/wellness_provider.dart';

/// Shows the slide-up sheet to log menstrual period flow, symptoms, mood, and notes.
void showLogPeriodSheet(
  BuildContext context,
  WellnessProvider provider, {
  DateTime? initialDate,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (sheetContext) {
      final mq = MediaQuery.of(sheetContext);
      final rawTop = math.max(mq.padding.top, mq.viewPadding.top);
      final topMargin = math.max(rawTop, 44.0) + 16.0;

      return Container(
        margin: EdgeInsets.only(top: topMargin),
        constraints: BoxConstraints(
          maxHeight: mq.size.height - topMargin,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141C17) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 32,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
              child: LogPeriodSheet(
                provider: provider,
                initialDate: initialDate ?? provider.selectedDate,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class LogPeriodSheet extends StatefulWidget {
  final WellnessProvider provider;
  final DateTime initialDate;

  const LogPeriodSheet({
    super.key,
    required this.provider,
    required this.initialDate,
  });

  @override
  State<LogPeriodSheet> createState() => _LogPeriodSheetState();
}

class _LogPeriodSheetState extends State<LogPeriodSheet> {
  late DateTime _selectedDate;
  late bool _isPeriodActive;
  PeriodFlowLevel _selectedFlow = PeriodFlowLevel.medium;
  final Set<PeriodSymptom> _selectedSymptoms = {};
  PeriodMood? _selectedMood;
  final TextEditingController _notesController = TextEditingController();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
    _isPeriodActive = widget.provider.isPeriodDay(_selectedDate) || widget.provider.activePeriod != null;

    final existingLog = widget.provider.getPeriodDailyLog(_selectedDate);
    if (existingLog != null) {
      if (existingLog.flow != null) _selectedFlow = existingLog.flow!;
      _selectedSymptoms.addAll(existingLog.symptoms);
      _selectedMood = existingLog.mood;
      _notesController.text = existingLog.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    HapticService.success();
    final p = widget.provider;

    if (_isPeriodActive) {
      if (!p.isPeriodDay(_selectedDate)) {
        p.startPeriod(
          _selectedDate,
          flow: _selectedFlow,
          symptoms: _selectedSymptoms.toList(),
          mood: _selectedMood,
          notes: _notesController.text.trim(),
        );
      } else {
        p.logDailyPeriodDetails(
          _selectedDate,
          flow: _selectedFlow,
          symptoms: _selectedSymptoms.toList(),
          mood: _selectedMood,
          notes: _notesController.text.trim(),
        );
      }
    } else {
      if (p.isPeriodDay(_selectedDate)) {
        p.endPeriod(_selectedDate);
      }
      p.logDailyPeriodDetails(
        _selectedDate,
        flow: null,
        symptoms: _selectedSymptoms.toList(),
        mood: _selectedMood,
        notes: _notesController.text.trim(),
      );
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged cycle details for ${_months[_selectedDate.month - 1]} ${_selectedDate.day}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Centered Drag Handle
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
                        color: const Color(0xFFF43F5E).withOpacity(0.16),
                        borderRadius: AppRadii.roundedSm,
                      ),
                      child: const Icon(Icons.water_drop_rounded, color: Color(0xFFF43F5E), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Log Cycle & Period',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          '${_months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}',
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

            // Period Active Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2822) : const Color(0xFFF3F7F4),
                borderRadius: AppRadii.roundedMd,
                border: Border.all(
                  color: isDark ? const Color(0xFF28362E) : const Color(0xFFDEE7E1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _isPeriodActive ? const Color(0xFFF43F5E) : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Period Active Today',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _isPeriodActive,
                    activeColor: const Color(0xFFF43F5E),
                    onChanged: (val) {
                      HapticService.selection();
                      setState(() => _isPeriodActive = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Flow Intensity Selector (visible if period active)
            if (_isPeriodActive) ...[
              Text(
                'Flow Intensity',
                style: AppTypography.h3(isDark).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: PeriodFlowLevel.values.map((flow) {
                  final isSel = _selectedFlow == flow;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: GestureDetector(
                        onTap: () {
                          HapticService.selection();
                          setState(() => _selectedFlow = flow);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFFF43F5E)
                                : (isDark ? const Color(0xFF1C2520) : const Color(0xFFEDF3EE)),
                            borderRadius: AppRadii.roundedSm,
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFFF43F5E)
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                flow.displayName,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],

            // Common Symptoms Multi-select
            Text(
              'Symptoms',
              style: AppTypography.h3(isDark).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PeriodSymptom.values.map((symptom) {
                final isSel = _selectedSymptoms.contains(symptom);
                return GestureDetector(
                  onTap: () {
                    HapticService.selection();
                    setState(() {
                      if (isSel) {
                        _selectedSymptoms.remove(symptom);
                      } else {
                        _selectedSymptoms.add(symptom);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0xFFF43F5E).withOpacity(0.18)
                          : (isDark ? const Color(0xFF1C2520) : const Color(0xFFEDF3EE)),
                      borderRadius: AppRadii.roundedPill,
                      border: Border.all(
                        color: isSel
                            ? const Color(0xFFF43F5E)
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          symptom.icon,
                          size: 15,
                          color: isSel ? const Color(0xFFF43F5E) : (isDark ? Colors.white60 : Colors.black54),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          symptom.displayName,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel
                                ? (isDark ? const Color(0xFFFDA4AF) : const Color(0xFFE11D48))
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

            // Mood Selector
            Text(
              'Mood & Emotional State',
              style: AppTypography.h3(isDark).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PeriodMood.values.map((mood) {
                final isSel = _selectedMood == mood;
                return GestureDetector(
                  onTap: () {
                    HapticService.selection();
                    setState(() {
                      _selectedMood = isSel ? null : mood;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primary.withOpacity(0.2)
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
                        Text(mood.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          mood.displayName,
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

            // Optional Free-text Notes
            Text(
              'Personal Notes',
              style: AppTypography.h3(isDark).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'Add optional observations, energy levels, or notes...',
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
                  borderSide: BorderSide(color: Color(0xFFF43F5E), width: 1.5),
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
                  backgroundColor: const Color(0xFFF43F5E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                ),
                child: const Text(
                  'Save Cycle Entry',
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
