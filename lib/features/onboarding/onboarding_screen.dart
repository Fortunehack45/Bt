import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/solid_wellness_card.dart';
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
  final int _totalPages = 5;

  // Biometric state gathered during onboarding
  String _selectedGender = 'Male';
  DateTime _selectedDob = DateTime(1998, 6, 14);
  int _selectedAge = 26;
  double _selectedHeightCm = 178.0;
  double _selectedWeightKg = 70.0;
  String _selectedGoal = 'Vitality & Daily Energy';

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> _fullMonthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  void _onDobChanged(DateTime newDob) {
    HapticService.selection();
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
    HapticService.mediumImpact();
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
    );
    widget.onGetStarted();
  }

  void _nextPage(WellnessProvider provider) {
    HapticService.selection();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
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

                    // Progress Dots
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
                  physics: const NeverScrollableScrollPhysics(), // Controlled via buttons for consistency
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildStep1Name(isDark),
                    _buildStep2Bio(isDark),
                    _buildStep3Composition(isDark),
                    _buildStep4Goals(isDark),
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
    final daysInCurrentMonth = DateUtils.getDaysInMonth(_selectedDob.year, _selectedDob.month);

    return SolidWellnessCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner with formatted date & calculated age
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
                decoration: BoxDecoration(
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
          const SizedBox(height: 16),

          // 3 Segmented Pickers (Month, Day, Year)
          Row(
            children: [
              // Month Selector
              Expanded(
                flex: 4,
                child: _buildPickerDropdown<int>(
                  isDark: isDark,
                  label: 'Month',
                  value: _selectedDob.month,
                  items: List.generate(12, (index) => index + 1),
                  itemLabel: (m) => _monthNames[m - 1],
                  onChanged: (newMonth) {
                    if (newMonth != null) {
                      final maxDays = DateUtils.getDaysInMonth(_selectedDob.year, newMonth);
                      final safeDay = _selectedDob.day.clamp(1, maxDays);
                      _onDobChanged(DateTime(_selectedDob.year, newMonth, safeDay));
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Day Selector
              Expanded(
                flex: 3,
                child: _buildPickerDropdown<int>(
                  isDark: isDark,
                  label: 'Day',
                  value: _selectedDob.day.clamp(1, daysInCurrentMonth),
                  items: List.generate(daysInCurrentMonth, (index) => index + 1),
                  itemLabel: (d) => d.toString().padLeft(2, '0'),
                  onChanged: (newDay) {
                    if (newDay != null) {
                      _onDobChanged(DateTime(_selectedDob.year, _selectedDob.month, newDay));
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Year Selector
              Expanded(
                flex: 4,
                child: _buildPickerDropdown<int>(
                  isDark: isDark,
                  label: 'Year',
                  value: _selectedDob.year,
                  items: List.generate(85, (index) => DateTime.now().year - 10 - index),
                  itemLabel: (y) => y.toString(),
                  onChanged: (newYear) {
                    if (newYear != null) {
                      final maxDays = DateUtils.getDaysInMonth(newYear, _selectedDob.month);
                      final safeDay = _selectedDob.day.clamp(1, maxDays);
                      _onDobChanged(DateTime(newYear, _selectedDob.month, safeDay));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Calendar Modal Quick Launcher
          GestureDetector(
            onTap: () async {
              HapticService.selection();
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDob,
                firstDate: DateTime(1930),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                builder: (context, child) {
                  return Theme(
                    data: isDark
                        ? ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.primary,
                              onPrimary: Colors.black,
                              surface: Color(0xFF141A17),
                            ),
                          )
                        : ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primaryDark,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                            ),
                          ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                _onDobChanged(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 15,
                    color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pick from visual calendar',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerDropdown<T>({
    required bool isDark,
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF19221D) : const Color(0xFFF2F6F3),
        borderRadius: AppRadii.roundedSm,
        border: Border.all(
          color: isDark ? const Color(0xFF2C3C32) : const Color(0xFFDAE2DC),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
              dropdownColor: isDark ? const Color(0xFF1E2823) : Colors.white,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
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
          setState(() => _selectedGender = label);
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

  // STEP 3: Height, Weight & Live BMI
  Widget _buildStep3Composition(bool isDark) {
    return SingleChildScrollView(
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

          // Live Dynamic BMI Meter
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
                    setState(() => _selectedWeightKg = double.parse(val.toStringAsFixed(1)));
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
        ],
      ),
    );
  }

  // STEP 5: Calibrated Blueprint Summary
  Widget _buildStep5Blueprint(bool isDark) {
    return SingleChildScrollView(
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
