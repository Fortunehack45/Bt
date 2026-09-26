import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/widgets/solid_wellness_card.dart';
import '../../../domain/models/reproductive_health_models.dart';
import '../../../domain/state/wellness_provider.dart';

/// Shows the slide-up sheet to configure or edit pregnancy reference dates.
void showPregnancySetupSheet(BuildContext context, WellnessProvider provider) {
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
      final topMargin = math.max(rawTop, 48.0) + 16.0;

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
              child: PregnancySetupSheet(provider: provider),
            ),
          ),
        ),
      );
    },
  );
}

class PregnancySetupSheet extends StatefulWidget {
  final WellnessProvider provider;

  const PregnancySetupSheet({super.key, required this.provider});

  @override
  State<PregnancySetupSheet> createState() => _PregnancySetupSheetState();
}

class _PregnancySetupSheetState extends State<PregnancySetupSheet> {
  PregnancyReferenceType _referenceType = PregnancyReferenceType.lastMenstrualPeriod;
  late DateTime _selectedDate;
  final TextEditingController _notesController = TextEditingController();

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.provider.pregnancyData;
    if (existing != null) {
      _referenceType = existing.referenceType;
      _selectedDate = existing.referenceDate;
      _notesController.text = existing.notes;
    } else {
      final lastPeriod = widget.provider.lastRecordedPeriod;
      _selectedDate = lastPeriod?.startDate ?? DateTime.now().subtract(const Duration(days: 70)); // Defaults to ~10 weeks
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    HapticService.success();
    widget.provider.setupPregnancy(
      type: _referenceType,
      date: _selectedDate,
      notes: _notesController.text.trim(),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pregnancy tracking configured successfully!'),
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
            // Drag Handle
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

            // Header
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
                      child: const Icon(Icons.child_care_rounded, color: Color(0xFFA855F7), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure Pregnancy',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'Set your reference timeline method',
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

            // Calculation Method Selector
            Text(
              'Calculation Method',
              style: AppTypography.h3(isDark).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...PregnancyReferenceType.values.map((type) {
              final isSel = _referenceType == type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () {
                    HapticService.selection();
                    setState(() => _referenceType = type);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0xFFA855F7).withOpacity(0.15)
                          : (isDark ? const Color(0xFF1E2822) : const Color(0xFFF3F7F4)),
                      borderRadius: AppRadii.roundedSm,
                      border: Border.all(
                        color: isSel
                            ? const Color(0xFFA855F7)
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13.5,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            color: isSel
                                ? (isDark ? Colors.white : const Color(0xFF4A148C))
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                        ),
                        if (isSel)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFFA855F7), size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 14),

            // Date Picker Card with Cupertino Wheel
            Text(
              _referenceType == PregnancyReferenceType.lastMenstrualPeriod
                  ? 'First Day of Last Period'
                  : (_referenceType == PregnancyReferenceType.estimatedDueDate
                      ? 'Estimated Due Date'
                      : 'Estimated Conception Date'),
              style: AppTypography.h3(isDark).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),

            SolidWellnessCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFA855F7),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA855F7).withOpacity(0.16),
                          borderRadius: AppRadii.roundedPill,
                        ),
                        child: const Text(
                          'Selected',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFA855F7)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141C18) : const Color(0xFFF3F7F4),
                      borderRadius: AppRadii.roundedMd,
                      border: Border.all(
                        color: isDark ? const Color(0xFF26362D) : const Color(0xFFDEE7E1),
                        width: 0.8,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadii.roundedMd,
                      child: CupertinoTheme(
                        data: CupertinoThemeData(
                          brightness: isDark ? Brightness.dark : Brightness.light,
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: _selectedDate,
                          minimumDate: DateTime.now().subtract(const Duration(days: 300)),
                          maximumDate: DateTime.now().add(const Duration(days: 300)),
                          onDateTimeChanged: (newDate) {
                            HapticService.selection();
                            setState(() => _selectedDate = newDate);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Optional Notes
            Text(
              'Optional Notes / Clinical Details',
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
                hintText: 'Doctor notes, hospital details, personal observations...',
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
            const SizedBox(height: 18),

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
                  'Save Pregnancy Timeline',
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
