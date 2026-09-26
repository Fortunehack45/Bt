import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../domain/models/reproductive_health_models.dart';
import '../../../domain/state/wellness_provider.dart';

/// Opens the luxury slide-up sheet to schedule or edit a detailed prenatal checkup.
void showAddPrenatalCheckupSheet(
  BuildContext context,
  WellnessProvider provider,
) {
  HapticService.selection();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.65),
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
          border: Border.all(
            color: isDark ? const Color(0xFF26332C) : const Color(0xFFE2EBE5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
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
              child: AddPrenatalCheckupSheet(provider: provider),
            ),
          ),
        ),
      );
    },
  );
}

class AddPrenatalCheckupSheet extends StatefulWidget {
  final WellnessProvider provider;

  const AddPrenatalCheckupSheet({super.key, required this.provider});

  @override
  State<AddPrenatalCheckupSheet> createState() => _AddPrenatalCheckupSheetState();
}

class _AddPrenatalCheckupSheetState extends State<AddPrenatalCheckupSheet> {
  PrenatalAppointmentType _selectedType = PrenatalAppointmentType.ultrasoundScan;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 14));
  String _selectedTime = '10:00 AM';
  final Set<String> _selectedPrepTags = {};

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> _commonTimes = [
    '08:30 AM', '09:00 AM', '10:00 AM', '11:15 AM',
    '01:30 PM', '02:00 PM', '03:15 PM', '04:30 PM'
  ];

  static const List<String> _prepOptions = [
    'Full Bladder (Ultrasound)',
    'Fasting 8 Hours (Labs)',
    'Bring Ultrasound Journal',
    'Blood Pressure Log',
    'List of Questions',
    'Urine Sample Ready',
  ];

  @override
  void initState() {
    super.initState();
    _applyTypeDefaults(_selectedType);
  }

  void _applyTypeDefaults(PrenatalAppointmentType type) {
    switch (type) {
      case PrenatalAppointmentType.ultrasoundScan:
        _titleController.text = '20-Week Anatomy Ultrasound';
        _selectedPrepTags.add('Full Bladder (Ultrasound)');
        _selectedPrepTags.add('Bring Ultrasound Journal');
        break;
      case PrenatalAppointmentType.routineCheckup:
        _titleController.text = 'Routine Monthly Prenatal Visit';
        _selectedPrepTags.add('Blood Pressure Log');
        _selectedPrepTags.add('Urine Sample Ready');
        break;
      case PrenatalAppointmentType.labBloodwork:
        _titleController.text = 'Second Trimester Blood Panel';
        _selectedPrepTags.add('Fasting 8 Hours (Labs)');
        break;
      case PrenatalAppointmentType.glucoseTest:
        _titleController.text = 'Glucose Tolerance Screening';
        _selectedPrepTags.add('Fasting 8 Hours (Labs)');
        break;
      case PrenatalAppointmentType.fetalMonitoring:
        _titleController.text = 'Fetal Non-Stress Test (NST)';
        _selectedPrepTags.add('List of Questions');
        break;
      case PrenatalAppointmentType.consultation:
        _titleController.text = 'Midwife & Birth Plan Consultation';
        _selectedPrepTags.add('List of Questions');
        break;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _providerController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      HapticService.selection();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an appointment title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticService.success();
    final combinedLocation = [
      if (_providerController.text.trim().isNotEmpty) _providerController.text.trim(),
      if (_locationController.text.trim().isNotEmpty) _locationController.text.trim(),
    ].join(' • ');

    widget.provider.addPregnancyAppointment(
      title,
      _selectedDate,
      timeString: _selectedTime,
      type: _selectedType,
      providerOrLocation: combinedLocation,
      notes: _notesController.text.trim(),
      preparation: _selectedPrepTags.join(', '),
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved checkup for ${_months[_selectedDate.month - 1]} ${_selectedDate.day} at $_selectedTime'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFFA855F7);
    final daysUntil = _selectedDate.difference(DateTime.now()).inDays + 1;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF33423A) : const Color(0xFFD2DBD5),
                borderRadius: AppRadii.roundedPill,
              ),
            ),
          ),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: AppRadii.roundedSm,
                    ),
                    child: Icon(Icons.event_note_rounded, color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule Prenatal Checkup',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Clinical visits, ultrasounds & laboratory tests',
                        style: AppTypography.caption(isDark).copyWith(fontSize: 11.5),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Chips
          Text('Checkup Type', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PrenatalAppointmentType.values.map((type) {
              final isSel = _selectedType == type;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type.icon, size: 14, color: isSel ? Colors.white : type.color),
                    const SizedBox(width: 6),
                    Text(type.displayName),
                  ],
                ),
                selected: isSel,
                onSelected: (val) {
                  if (val) {
                    HapticService.selection();
                    setState(() {
                      _selectedType = type;
                      _applyTypeDefaults(type);
                    });
                  }
                },
                selectedColor: accent,
                backgroundColor: isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2),
                labelStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel
                      ? Colors.white
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                side: BorderSide.none,
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Appointment Title Field
          Text('Appointment Title', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. 20-Week Anatomy Ultrasound',
              prefixIcon: Icon(Icons.edit_note_rounded, color: accent, size: 20),
            ),
          ),
          const SizedBox(height: 14),

          // Date & Time Selectors Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        HapticService.selection();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 300)),
                          builder: (pickerCtx, child) {
                            return Theme(
                              data: Theme.of(pickerCtx).copyWith(
                                colorScheme: Theme.of(pickerCtx).colorScheme.copyWith(primary: accent),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2822) : const Color(0xFFF3F7F4),
                          borderRadius: AppRadii.roundedMd,
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E3D35) : const Color(0xFFDEE7E1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 16, color: accent),
                                const SizedBox(width: 8),
                                Text(
                                  '${_months[_selectedDate.month - 1]} ${_selectedDate.day}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.16),
                                borderRadius: AppRadii.roundedPill,
                              ),
                              child: Text(
                                daysUntil >= 0 ? 'in ${daysUntil}d' : '${daysUntil.abs()}d ago',
                                style: TextStyle(color: accent, fontSize: 10.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
                    const SizedBox(height: 6),
                    PopupMenuButton<String>(
                      initialValue: _selectedTime,
                      onSelected: (val) {
                        HapticService.selection();
                        setState(() => _selectedTime = val);
                      },
                      itemBuilder: (ctx) => _commonTimes.map((t) {
                        return PopupMenuItem<String>(value: t, child: Text(t));
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2822) : const Color(0xFFF3F7F4),
                          borderRadius: AppRadii.roundedMd,
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E3D35) : const Color(0xFFDEE7E1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 16, color: accent),
                                const SizedBox(width: 8),
                                Text(_selectedTime, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              ],
                            ),
                            const Icon(Icons.arrow_drop_down_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Provider & Location Fields
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _providerController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor / Clinician',
                    hintText: 'e.g. Dr. Vance',
                    prefixIcon: Icon(Icons.person_pin_rounded, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Facility / Room',
                    hintText: 'e.g. St. Jude Clinic',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preparation Checklist Chips
          Text('Clinical Preparation Requirements', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _prepOptions.map((tag) {
              final isSel = _selectedPrepTags.contains(tag);
              return FilterChip(
                label: Text(tag, style: TextStyle(fontSize: 11.5, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                selected: isSel,
                onSelected: (val) {
                  HapticService.selection();
                  setState(() {
                    if (val) {
                      _selectedPrepTags.add(tag);
                    } else {
                      _selectedPrepTags.remove(tag);
                    }
                  });
                },
                selectedColor: accent.withOpacity(0.2),
                checkmarkColor: accent,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Notes & Questions Field
          Text('Notes & Questions for Doctor', style: AppTypography.h3(isDark).copyWith(fontSize: 14)),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Questions regarding kicking movement, iron supplements, back stretches...',
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons: Subtle Neutral Cancel & Luxury Purple Save
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticService.selection();
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF33423A) : const Color(0xFFDEE7E1),
                    ),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Save Prenatal Checkup',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
