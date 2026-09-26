import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../domain/models/reproductive_health_models.dart';
import '../../domain/state/wellness_provider.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController(text: 'Fortune');

  int _currentPage = 0;

  // Total pages expands dynamically from 5 to 6 when a female user chooses Period or Pregnancy tracking
  int get _totalPages =>
      (_selectedGender == 'Female' && (_trackPeriod || _trackPregnancy)) ? 6 : 5;

  // Biometric state gathered during onboarding
  String _selectedGender = 'Male';
  DateTime _selectedDob = DateTime(1998, 6, 14);
  int _selectedAge = 26;
  double _selectedHeightCm = 178.0;
  double _selectedWeightKg = 70.0;
  String _selectedGoal = 'Vitality & Daily Energy';
  bool _trackPeriod = false;
  bool _trackPregnancy = false;

  // Specialized Period Tracking Questionnaire State
  DateTime _periodLastStartDate = DateTime.now().subtract(const Duration(days: 14));
  int _periodDurationDays = 5;
  int _cycleLengthDays = 28;
  String _cycleRegularity = 'Regular (26–32 days)';
  String _periodGoal = 'Predict upcoming periods & avoid surprises';
  bool _showPeriodDatePicker = false;

  // Specialized Pregnancy Tracking Questionnaire State
  PregnancyReferenceType _pregnancyReferenceType = PregnancyReferenceType.estimatedDueDate;
  DateTime _pregnancyReferenceDate = DateTime.now().add(const Duration(days: 131));
  bool _isFirstPregnancy = true;
  String _pregnancyGoal = 'Week-by-week baby growth & size milestones';
  bool _showPregnancyDatePicker = false;

  static const List<String> _fullMonthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  void _onDobChanged(DateTime newDob) {
    HapticService.tick();
    setState(() {
      _selectedDob = newDob;
      final now = DateTime.now();
      int age = now.year - newDob.year;
      if (now.month < newDob.month || (now.month == newDob.month && now.day < newDob.day)) {
        age--;
      }
      _selectedAge = age.clamp(1, 120);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _finish(WellnessProvider provider) {
    HapticService.celebrate();
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      provider.setUserName(name);
    }
    provider.updateBiometrics(
      dateOfBirth: _selectedDob,
      age: _selectedAge,
      gender: _selectedGender,
      heightCm: _selectedHeightCm,
      weightKg: _selectedWeightKg,
      targetWeightKg: (_selectedWeightKg * 0.96),
      primaryGoal: _selectedGoal,
      isPeriodTrackingEnabled: _selectedGender == 'Female' && _trackPeriod,
      isPregnancyTrackingEnabled: _selectedGender == 'Female' && _trackPregnancy,
    );

    // Persist rich answers from the reproductive health questionnaire
    if (_selectedGender == 'Female' && _trackPeriod) {
      provider.configureInitialPeriodTracking(
        lastPeriodStartDate: _periodLastStartDate,
        periodDurationDays: _periodDurationDays,
        cycleLengthDays: _cycleLengthDays,
        regularity: _cycleRegularity,
        trackingGoal: _periodGoal,
      );
    } else if (_selectedGender == 'Female' && _trackPregnancy) {
      provider.setupPregnancy(
        type: _pregnancyReferenceType,
        date: _pregnancyReferenceDate,
        notes: 'Goal: $_pregnancyGoal • First-time mom: $_isFirstPregnancy',
      );
    }

    widget.onGetStarted();
  }

  void _nextPage(WellnessProvider provider) {
    HapticService.mediumImpact();
    if (_currentPage < _totalPages - 1) {
      if (_currentPage == _totalPages - 2) {
        HapticService.celebrate();
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish(provider);
    }
  }

  void _prevPage() {
    HapticService.selection();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  double get _currentBmi {
    final hMeters = _selectedHeightCm / 100.0;
    return double.parse((_selectedWeightKg / (hMeters * hMeters)).toStringAsFixed(1));
  }

  String get _currentBmiCategory {
    final b = _currentBmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Optimal Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese Range';
  }

  Color get _currentBmiColor {
    final b = _currentBmi;
    if (b < 18.5) return AppColors.waterBlue;
    if (b < 25.0) return const Color(0xFF10B981);
    if (b < 30.0) return const Color(0xFFF59E0B);
    return AppColors.heartRed;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);

    final showReproductiveStep =
        _selectedGender == 'Female' && (_trackPeriod || _trackPregnancy);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
          child: Column(
            children: [
              // Top Progress Header
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      GestureDetector(
                        onTap: _prevPage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_rounded, size: 20),
                        ),
                      )
                    else
                      const SizedBox(width: 36),

                    // Progress Dots (dynamically 5 or 6)
                    Row(
                      children: List.generate(_totalPages, (index) {
                        final isSel = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isSel ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorderStrong),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),

                    // Skip Button
                    TextButton(
                      onPressed: () => _finish(provider),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Multi-step PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildStep1Name(isDark),
                    _buildStep2Bio(isDark),
                    _buildStep3Composition(isDark),
                    _buildStep4Goals(isDark),
                    if (showReproductiveStep) ...[
                      if (_trackPeriod)
                        _buildStep4bPeriodQuestionnaire(isDark)
                      else
                        _buildStep4bPregnancyQuestionnaire(isDark),
                    ],
                    _buildStep5Blueprint(isDark),
                  ],
                ),
              ),

              // Bottom Continue Action Button
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _nextPage(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimaryLight,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                    ),
                    child: Text(
                      _currentPage == _totalPages - 1 ? 'Start My Wellness Journey' : 'Continue',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 1: Name & Personal Welcome
  Widget _buildStep1Name(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: isDark ? AppColors.primary.withOpacity(0.18) : AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline_rounded, size: 48, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 28),
          Text(
            'What should we\ncall you?',
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium(isDark).copyWith(fontSize: 28, height: 1.2),
          ),
          const SizedBox(height: 10),
          Text(
            'We will personalize your daily metrics and AI recommendations.',
            textAlign: TextAlign.center,
            style: AppTypography.caption(isDark).copyWith(fontSize: 14),
          ),
          const SizedBox(height: 36),
          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            autofocus: false,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your preferred name',
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(borderRadius: AppRadii.roundedMd, borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: AppRadii.roundedMd, borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              focusedBorder: const OutlineInputBorder(borderRadius: AppRadii.roundedMd, borderSide: BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Biological Profile (Sex & Age)
  Widget _buildStep2Bio(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: isDark ? AppColors.waterBlue.withOpacity(0.16) : AppColors.waterBlueTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.biotech_rounded, size: 40, color: AppColors.waterBlue),
          ),
          const SizedBox(height: 20),
          Text(
            'Biological Profile',
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium(isDark).copyWith(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Text(
            'Used to benchmark heart rate zones and metabolic rest rate.',
            textAlign: TextAlign.center,
            style: AppTypography.caption(isDark).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 28),

          // Biological Sex Selector
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Biological Sex', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSexOption('Male', Icons.male_rounded, isDark),
              const SizedBox(width: 10),
              _buildSexOption('Female', Icons.female_rounded, isDark),
              const SizedBox(width: 10),
              _buildSexOption('Other', Icons.person_rounded, isDark),
            ],
          ),
          const SizedBox(height: 28),

          // Date of Birth & Biological Age Selector
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Date of Birth', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          ),
          const SizedBox(height: 10),
          _buildDobSelector(isDark),
        ],
      ),
    );
  }

  Widget _buildDobSelector(bool isDark) {
    return SolidWellnessCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF26332C) : AppColors.primaryTint,
                      borderRadius: AppRadii.roundedSm,
                    ),
                    child: const Icon(Icons.cake_rounded, color: AppColors.primaryDark, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_fullMonthNames[_selectedDob.month - 1]} ${_selectedDob.day}, ${_selectedDob.year}',
                        style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                      ),
                      Text(
                        'Biological Date of Birth',
                        style: AppTypography.caption(isDark).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.roundedPill,
                ),
                child: Text(
                  '$_selectedAge yrs old',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            height: 145,
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
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDob,
                  minimumDate: DateTime(1930, 1, 1),
                  maximumDate: DateTime(DateTime.now().year - 10, 12, 31),
                  onDateTimeChanged: (newDate) {
                    _onDobChanged(newDate);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexOption(String label, IconData icon, bool isDark) {
    final isSel = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.selection();
          setState(() {
            _selectedGender = label;
            if (_selectedGender != 'Female') {
              _trackPeriod = false;
              _trackPregnancy = false;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSel
                ? AppColors.primary
                : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated),
            borderRadius: AppRadii.roundedMd,
            border: Border.all(
              color: isSel
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSel ? AppColors.textPrimaryLight : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isSel ? AppColors.textPrimaryLight : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 3: Body Composition (Height & Weight)
  Widget _buildStep3Composition(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Body Composition',
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium(isDark).copyWith(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(
            'Precision values calculate your live BMI & hydration requirements',
            textAlign: TextAlign.center,
            style: AppTypography.caption(isDark).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 18),

          SolidWellnessCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _currentBmiColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.speed_rounded, color: _currentBmiColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calculated BMI', style: AppTypography.caption(isDark)),
                        Text(
                          '$_currentBmi',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: _currentBmiColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _currentBmiColor.withOpacity(0.15),
                    borderRadius: AppRadii.roundedPill,
                  ),
                  child: Text(
                    _currentBmiCategory,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _currentBmiColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Height Slider
          SolidWellnessCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Height', style: AppTypography.bodyLarge(isDark).copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      '${_selectedHeightCm.toInt()} cm',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                Slider(
                  value: _selectedHeightCm,
                  min: 120,
                  max: 230,
                  activeColor: AppColors.primary,
                  inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  onChanged: (val) {
                    if (val.toInt() != _selectedHeightCm.toInt()) HapticService.tick();
                    setState(() => _selectedHeightCm = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Weight Slider
          SolidWellnessCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Weight', style: AppTypography.bodyLarge(isDark).copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      '${_selectedWeightKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.stepsOrange),
                    ),
                  ],
                ),
                Slider(
                  value: _selectedWeightKg,
                  min: 40,
                  max: 180,
                  activeColor: AppColors.stepsOrange,
                  inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  onChanged: (val) {
                    final rounded = double.parse(val.toStringAsFixed(1));
                    if ((rounded * 2).toInt() != (_selectedWeightKg * 2).toInt()) HapticService.tick();
                    setState(() => _selectedWeightKg = rounded);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: Goals & Aspiration
  Widget _buildStep4Goals(bool isDark) {
    final goals = [
      {
        'title': 'Vitality & Daily Energy',
        'desc': 'Circadian rhythm alignment, sustained stamina & daily focus',
        'icon': Icons.bolt_rounded,
        'color': AppColors.nutritionGold,
      },
      {
        'title': 'Healthy Weight Management',
        'desc': 'Calorie precision tracking, balanced hydration & nutrition',
        'icon': Icons.monitor_weight_rounded,
        'color': AppColors.stepsOrange,
      },
      {
        'title': 'Deep Sleep & Recovery',
        'desc': 'Optimal sleep architecture, REM tracking & rest debt repayment',
        'icon': Icons.bedtime_rounded,
        'color': const Color(0xFF818CF8),
      },
      {
        'title': 'Cardiovascular Fitness',
        'desc': 'Lower resting heart rate, zone cardio & aerobic capacity',
        'icon': Icons.favorite_rounded,
        'color': AppColors.heartRed,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Primary Aspiration',
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium(isDark).copyWith(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your core wellness objective to tune your daily targets.',
            textAlign: TextAlign.center,
            style: AppTypography.caption(isDark).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 18),

          ...goals.map((g) {
            final title = g['title'] as String;
            final desc = g['desc'] as String;
            final icon = g['icon'] as IconData;
            final color = g['color'] as Color;
            final isSel = _selectedGoal == title;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _selectedGoal = title);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSel
                        ? (isDark ? const Color(0xFF263324) : const Color(0xFFEBF6E4))
                        : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated),
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: isSel
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSel ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: AppRadii.roundedSm,
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(desc, style: AppTypography.caption(isDark).copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isSel)
                        const Icon(Icons.check_circle_rounded, color: AppColors.primaryDark, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Specialized Health Focus for Female users
          if (_selectedGender == 'Female') ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Specialized Health Focus (Optional)',
                    style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Select to unlock deep cycle predictions or maternal pregnancy guidance',
                    style: AppTypography.caption(isDark).copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Option 1: Track my period
            _buildSpecializedGoalCard(
              title: 'Track my period',
              desc: 'Predict upcoming cycle phases, fertile window & log symptoms',
              icon: Icons.water_drop_outlined,
              accentColor: const Color(0xFFF43F5E),
              isSelected: _trackPeriod,
              onTap: () {
                HapticService.selection();
                setState(() {
                  _trackPeriod = !_trackPeriod;
                  if (_trackPeriod) _trackPregnancy = false;
                });
              },
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            // Option 2: Track my pregnancy
            _buildSpecializedGoalCard(
              title: 'Track my pregnancy',
              desc: 'Week-by-week milestones, estimated due date & maternal wellness',
              icon: Icons.child_care_rounded,
              accentColor: const Color(0xFFA855F7),
              isSelected: _trackPregnancy,
              onTap: () {
                HapticService.selection();
                setState(() {
                  _trackPregnancy = !_trackPregnancy;
                  if (_trackPregnancy) _trackPeriod = false;
                });
              },
              isDark: isDark,
            ),
            const SizedBox(height: 6),
            Text(
              'Note: Selecting either mode unlocks a quick personalization step next.',
              style: AppTypography.caption(isDark).copyWith(fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  // STEP 4b: In-Depth Period Tracking Questionnaire
  Widget _buildStep4bPeriodQuestionnaire(bool isDark) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysSinceStart = today.difference(_periodLastStartDate).inDays;

    final regularityOptions = [
      (
        title: 'Regular (26–32 days)',
        desc: 'Consistent monthly cycle with predictable timing',
        icon: Icons.sync_rounded,
      ),
      (
        title: 'Somewhat irregular',
        desc: 'Varies by 3 to 6 days from month to month',
        icon: Icons.shuffle_rounded,
      ),
      (
        title: 'Irregular or variable',
        desc: 'Hard to anticipate; length fluctuates substantially',
        icon: Icons.tune_rounded,
      ),
      (
        title: 'I\'m not sure yet',
        desc: 'Biothrix will analyze your logged cycles over time',
        icon: Icons.auto_awesome_rounded,
      ),
    ];

    final goalOptions = [
      (
        title: 'Predict upcoming periods & avoid surprises',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFFF43F5E),
      ),
      (
        title: 'Track fertile window & natural conception',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFA855F7),
      ),
      (
        title: 'Monitor PMS, cramps & hormonal mood changes',
        icon: Icons.psychology_alt_rounded,
        color: const Color(0xFF06B6D4),
      ),
      (
        title: 'Holistic reproductive & menstrual vitality',
        icon: Icons.spa_rounded,
        color: const Color(0xFF10B981),
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFF43F5E).withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.water_drop_rounded, size: 36, color: Color(0xFFF43F5E)),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Menstrual Cycle Profile',
              textAlign: TextAlign.center,
              style: AppTypography.displayMedium(isDark).copyWith(fontSize: 24),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Calibrate accurate predictions, fertile windows, and hormonal health.',
              textAlign: TextAlign.center,
              style: AppTypography.caption(isDark).copyWith(fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 20),

          // Question 1: When did your last period start?
          Text('1. When did your last period start?', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          const SizedBox(height: 8),
          SolidWellnessCard(
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E).withOpacity(0.14),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: const Icon(Icons.calendar_today_rounded, color: Color(0xFFF43F5E), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_fullMonthNames[_periodLastStartDate.month - 1]} ${_periodLastStartDate.day}, ${_periodLastStartDate.year}',
                              style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                            ),
                            Text(
                              daysSinceStart == 0
                                  ? 'Started today'
                                  : '$daysSinceStart ${daysSinceStart == 1 ? 'day' : 'days'} ago',
                              style: AppTypography.caption(isDark).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        HapticService.selection();
                        setState(() => _showPeriodDatePicker = !_showPeriodDatePicker);
                      },
                      child: Text(
                        _showPeriodDatePicker ? 'Done' : 'Change',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFF43F5E)),
                      ),
                    ),
                  ],
                ),

                // Quick selector buttons
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildQuickDateChip('Today', today, isDark),
                    _buildQuickDateChip('3 days ago', today.subtract(const Duration(days: 3)), isDark),
                    _buildQuickDateChip('1 week ago', today.subtract(const Duration(days: 7)), isDark),
                    _buildQuickDateChip('2 weeks ago', today.subtract(const Duration(days: 14)), isDark),
                  ],
                ),

                if (_showPeriodDatePicker) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141C18) : const Color(0xFFF3F7F4),
                      borderRadius: AppRadii.roundedMd,
                      border: Border.all(color: isDark ? const Color(0xFF26362D) : const Color(0xFFDEE7E1)),
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
                          initialDateTime: _periodLastStartDate,
                          minimumDate: today.subtract(const Duration(days: 120)),
                          maximumDate: today,
                          onDateTimeChanged: (d) {
                            HapticService.tick();
                            setState(() => _periodLastStartDate = d);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Question 2: How long does your period usually last?
          Text('2. How long does your period usually last?', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          const SizedBox(height: 8),
          SolidWellnessCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Period duration', style: AppTypography.bodyMedium(isDark)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withOpacity(0.15),
                        borderRadius: AppRadii.roundedPill,
                      ),
                      child: Text(
                        '$_periodDurationDays ${_periodDurationDays == 1 ? 'day' : 'days'}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFF43F5E), fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(7, (idx) {
                    final d = idx + 3; // 3 to 9 days
                    final isSel = _periodDurationDays == d;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.selection();
                          setState(() => _periodDurationDays = d);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFFF43F5E)
                                : (isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F5F2)),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$d',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Question 3: Typical cycle length & regularity
          Text('3. How typical & regular is your cycle?', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          const SizedBox(height: 8),
          SolidWellnessCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cycle length', style: AppTypography.bodyMedium(isDark)),
                    Text(
                      '$_cycleLengthDays days',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFF43F5E), fontSize: 15),
                    ),
                  ],
                ),
                Slider(
                  value: _cycleLengthDays.toDouble(),
                  min: 21,
                  max: 42,
                  divisions: 21,
                  activeColor: const Color(0xFFF43F5E),
                  inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  onChanged: (val) {
                    final rounded = val.round();
                    if (rounded != _cycleLengthDays) HapticService.tick();
                    setState(() => _cycleLengthDays = rounded);
                  },
                ),
                const SizedBox(height: 8),
                Text('Cycle Regularity Pattern', style: AppTypography.caption(isDark).copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...regularityOptions.map((reg) {
                  final isSel = _cycleRegularity == reg.title;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: GestureDetector(
                      onTap: () {
                        HapticService.selection();
                        setState(() => _cycleRegularity = reg.title);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel
                              ? const Color(0xFFF43F5E).withOpacity(0.12)
                              : (isDark ? const Color(0xFF19231E) : const Color(0xFFF8FAF9)),
                          borderRadius: AppRadii.roundedSm,
                          border: Border.all(
                            color: isSel ? const Color(0xFFF43F5E) : (isDark ? const Color(0xFF2B3A31) : const Color(0xFFDEE7E1)),
                            width: isSel ? 1.5 : 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(reg.icon, size: 18, color: isSel ? const Color(0xFFF43F5E) : (isDark ? Colors.white60 : Colors.black54)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reg.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  Text(reg.desc, style: AppTypography.caption(isDark).copyWith(fontSize: 11)),
                                ],
                              ),
                            ),
                            if (isSel)
                              const Icon(Icons.check_circle_rounded, color: Color(0xFFF43F5E), size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Question 4: Primary cycle tracking intention
          Text('4. What is your primary cycle tracking goal?', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          const SizedBox(height: 8),
          ...goalOptions.map((opt) {
            final isSel = _periodGoal == opt.title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _periodGoal = opt.title);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSel
                        ? opt.color.withOpacity(0.14)
                        : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated),
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: isSel ? opt.color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSel ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: opt.color.withOpacity(0.16),
                          borderRadius: AppRadii.roundedSm,
                        ),
                        child: Icon(opt.icon, color: opt.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt.title,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      if (isSel)
                        Icon(Icons.check_circle_rounded, color: opt.color, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickDateChip(String label, DateTime targetDate, bool isDark) {
    final isSel = _periodLastStartDate.year == targetDate.year &&
        _periodLastStartDate.month == targetDate.month &&
        _periodLastStartDate.day == targetDate.day;

    return GestureDetector(
      onTap: () {
        HapticService.selection();
        setState(() {
          _periodLastStartDate = targetDate;
          _showPeriodDatePicker = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSel
              ? const Color(0xFFF43F5E)
              : (isDark ? const Color(0xFF223028) : const Color(0xFFE8F0EB)),
          borderRadius: AppRadii.roundedPill,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
            color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  // STEP 4b: In-Depth Pregnancy Tracking Questionnaire
  Widget _buildStep4bPregnancyQuestionnaire(bool isDark) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime calculatedDueDate;
    DateTime lmpDate;

    if (_pregnancyReferenceType == PregnancyReferenceType.estimatedDueDate) {
      calculatedDueDate = DateTime(_pregnancyReferenceDate.year, _pregnancyReferenceDate.month, _pregnancyReferenceDate.day);
      lmpDate = calculatedDueDate.subtract(const Duration(days: 280));
    } else {
      lmpDate = DateTime(_pregnancyReferenceDate.year, _pregnancyReferenceDate.month, _pregnancyReferenceDate.day);
      calculatedDueDate = lmpDate.add(const Duration(days: 280));
    }

    final elapsedDays = today.difference(lmpDate).inDays.clamp(0, 300);
    final week = ((elapsedDays ~/ 7) + 1).clamp(1, 42);
    final day = elapsedDays % 7;
    final daysUntilDue = calculatedDueDate.difference(today).inDays;
    final trimester = week <= 12 ? 1 : (week <= 27 ? 2 : 3);
    final trimesterLabel = trimester == 1 ? 'First Trimester' : (trimester == 2 ? 'Second Trimester' : 'Third Trimester');

    final pregnancyGoals = [
      (
        title: 'Week-by-week baby size & fruit development',
        icon: Icons.child_care_rounded,
        color: const Color(0xFFA855F7),
      ),
      (
        title: 'Trimester symptom tracking & kick counter',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFF43F5E),
      ),
      (
        title: 'Doctor appointments & prenatal checklist reminders',
        icon: Icons.event_note_rounded,
        color: const Color(0xFF06B6D4),
      ),
      (
        title: 'Maternal nutrition & hydration guidance',
        icon: Icons.local_dining_rounded,
        color: const Color(0xFF10B981),
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.child_care_rounded, size: 36, color: Color(0xFFA855F7)),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Pregnancy Journey Setup',
              textAlign: TextAlign.center,
              style: AppTypography.displayMedium(isDark).copyWith(fontSize: 24),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Track week-by-week fetal growth, estimated due date, and maternal telemetry.',
              textAlign: TextAlign.center,
              style: AppTypography.caption(isDark).copyWith(fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 20),

          // Question 1: Calculation method
          Text('1. How would you like to set your timeline?', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPregnancyTypeTab(
                  'Estimated Due Date',
                  PregnancyReferenceType.estimatedDueDate,
                  Icons.event_available_rounded,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPregnancyTypeTab(
                  'Last Period (LMP)',
                  PregnancyReferenceType.lastMenstrualPeriod,
                  Icons.calendar_month_rounded,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question 2: Selected Date & Live Gestational Age
          Text('2. Milestone Date', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          const SizedBox(height: 8),
          SolidWellnessCard(
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA855F7).withOpacity(0.14),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: const Icon(Icons.cake_rounded, color: Color(0xFFA855F7), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_fullMonthNames[_pregnancyReferenceDate.month - 1]} ${_pregnancyReferenceDate.day}, ${_pregnancyReferenceDate.year}',
                              style: AppTypography.h3(isDark).copyWith(fontSize: 15),
                            ),
                            Text(
                              _pregnancyReferenceType == PregnancyReferenceType.estimatedDueDate
                                  ? 'Estimated Delivery Date'
                                  : 'First day of last period',
                              style: AppTypography.caption(isDark).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        HapticService.selection();
                        setState(() => _showPregnancyDatePicker = !_showPregnancyDatePicker);
                      },
                      child: Text(
                        _showPregnancyDatePicker ? 'Done' : 'Change Date',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFA855F7)),
                      ),
                    ),
                  ],
                ),

                if (_showPregnancyDatePicker) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141C18) : const Color(0xFFF3F7F4),
                      borderRadius: AppRadii.roundedMd,
                      border: Border.all(color: isDark ? const Color(0xFF26362D) : const Color(0xFFDEE7E1)),
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
                          initialDateTime: _pregnancyReferenceDate,
                          minimumDate: _pregnancyReferenceType == PregnancyReferenceType.estimatedDueDate
                              ? today
                              : today.subtract(const Duration(days: 280)),
                          maximumDate: _pregnancyReferenceType == PregnancyReferenceType.estimatedDueDate
                              ? today.add(const Duration(days: 280))
                              : today,
                          onDateTimeChanged: (d) {
                            HapticService.tick();
                            setState(() => _pregnancyReferenceDate = d);
                          },
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Live Reactive Gestational Calculation Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7).withOpacity(0.12),
                    borderRadius: AppRadii.roundedSm,
                    border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFA855F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Week $week, Day $day • $trimesterLabel',
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Color(0xFFA855F7),
                              ),
                            ),
                            Text(
                              daysUntilDue > 0
                                  ? '$daysUntilDue ${daysUntilDue == 1 ? 'day' : 'days'} until estimated due date'
                                  : 'Due window reached',
                              style: AppTypography.caption(isDark).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Question 3: Is this your first pregnancy?
          Text('3. Is this your first pregnancy?', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFirstPregnancyOption('First-time Mother', true, Icons.sentiment_satisfied_alt_rounded, isDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFirstPregnancyOption('Experienced Mother', false, Icons.family_restroom_rounded, isDark),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Question 4: Primary pregnancy intention
          Text('4. What is your primary pregnancy focus?', style: AppTypography.h3(isDark).copyWith(fontSize: 15)),
          const SizedBox(height: 8),
          ...pregnancyGoals.map((opt) {
            final isSel = _pregnancyGoal == opt.title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _pregnancyGoal = opt.title);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSel
                        ? opt.color.withOpacity(0.14)
                        : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated),
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: isSel ? opt.color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSel ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: opt.color.withOpacity(0.16),
                          borderRadius: AppRadii.roundedSm,
                        ),
                        child: Icon(opt.icon, color: opt.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt.title,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      if (isSel)
                        Icon(Icons.check_circle_rounded, color: opt.color, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPregnancyTypeTab(
    String label,
    PregnancyReferenceType type,
    IconData icon,
    bool isDark,
  ) {
    final isSel = _pregnancyReferenceType == type;
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        setState(() {
          _pregnancyReferenceType = type;
          if (type == PregnancyReferenceType.estimatedDueDate) {
            _pregnancyReferenceDate = DateTime.now().add(const Duration(days: 131));
          } else {
            _pregnancyReferenceDate = DateTime.now().subtract(const Duration(days: 149));
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSel
              ? const Color(0xFFA855F7)
              : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated),
          borderRadius: AppRadii.roundedMd,
          border: Border.all(
            color: isSel ? const Color(0xFFA855F7) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                  color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstPregnancyOption(String label, bool isFirst, IconData icon, bool isDark) {
    final isSel = _isFirstPregnancy == isFirst;
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        setState(() => _isFirstPregnancy = isFirst);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSel
              ? const Color(0xFFA855F7).withOpacity(0.14)
              : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated),
          borderRadius: AppRadii.roundedMd,
          border: Border.all(
            color: isSel ? const Color(0xFFA855F7) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSel ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSel ? const Color(0xFFA855F7) : (isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializedGoalCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? accentColor.withOpacity(0.18) : accentColor.withOpacity(0.08))
              : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceElevated),
          borderRadius: AppRadii.roundedMd,
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: AppRadii.roundedSm,
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: AppTypography.caption(isDark).copyWith(fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? accentColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? accentColor : (isDark ? Colors.white38 : Colors.black26),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // STEP 5: Calibrated Blueprint Summary
  Widget _buildStep5Blueprint(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_rounded, size: 44, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Blueprint\nis Calibrated!',
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium(isDark).copyWith(fontSize: 26, height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Customized for ${_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'you'} based on your biometrics.',
            textAlign: TextAlign.center,
            style: AppTypography.caption(isDark).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 24),

          SolidWellnessCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _buildTargetSummaryTile('Daily Hydration Target', '8 glasses (2,000 ml)', Icons.water_drop_rounded, AppColors.waterBlue, isDark),
                const Divider(height: 20),
                _buildTargetSummaryTile('Active Movement', '10,000 steps (~7.5 km)', Icons.directions_walk_rounded, AppColors.stepsOrange, isDark),
                const Divider(height: 20),
                _buildTargetSummaryTile('Nutrition Intake', '2,000 kcal daily balance', Icons.local_fire_department_rounded, AppColors.nutritionGold, isDark),
                if (_selectedGender == 'Female' && _trackPeriod) ...[
                  const Divider(height: 20),
                  _buildTargetSummaryTile(
                    'Menstrual Cycle',
                    '$_cycleLengthDays-day cycle • $_periodDurationDays days flow',
                    Icons.water_drop_outlined,
                    const Color(0xFFF43F5E),
                    isDark,
                  ),
                  const Divider(height: 20),
                  _buildTargetSummaryTile(
                    'Cycle Strategy',
                    _periodGoal,
                    Icons.psychology_rounded,
                    const Color(0xFFF43F5E),
                    isDark,
                  ),
                ],
                if (_selectedGender == 'Female' && _trackPregnancy) ...[
                  const Divider(height: 20),
                  _buildTargetSummaryTile(
                    'Pregnancy Journey',
                    'Due ${_fullMonthNames[_pregnancyReferenceDate.month - 1]} ${_pregnancyReferenceDate.day}, ${_pregnancyReferenceDate.year}',
                    Icons.child_care_rounded,
                    const Color(0xFFA855F7),
                    isDark,
                  ),
                  const Divider(height: 20),
                  _buildTargetSummaryTile(
                    'Maternal Focus',
                    _pregnancyGoal,
                    Icons.favorite_rounded,
                    const Color(0xFFA855F7),
                    isDark,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSubtle : AppColors.primaryTint,
              borderRadius: AppRadii.roundedSm,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.primaryDark, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All telemetry and goals sync seamlessly with Biothrix health widgets and app shortcuts.',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.5,
                      color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1E2F1E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSummaryTile(String title, String subtitle, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.caption(isDark)),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
