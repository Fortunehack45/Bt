import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/glass/platform_glass_bottom_sheet.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../domain/models/gestational_database.dart';
import '../../domain/models/reproductive_health_models.dart';
import '../../domain/state/wellness_provider.dart';

/// Shows the full Biothrix AI Wellness Chatbot sliding bottom sheet.
void showAiWellnessChatbotSheet(BuildContext context, WellnessProvider provider) {
  showPlatformGlassBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    includeBottomPadding: false,
    builder: (sheetContext) {
      return AiWellnessChatbotSheet(provider: provider);
    },
  );
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? actionChips;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionChips,
  });
}

class AiWellnessChatbotSheet extends StatefulWidget {
  final WellnessProvider provider;

  const AiWellnessChatbotSheet({super.key, required this.provider});

  @override
  State<AiWellnessChatbotSheet> createState() => _AiWellnessChatbotSheetState();
}

class _AiWellnessChatbotSheetState extends State<AiWellnessChatbotSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickPrompts = [];

  @override
  void initState() {
    super.initState();
    _initQuickPrompts();
    _initGreeting();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) _scrollToBottom();
        });
      }
    });
  }

  void _initQuickPrompts() {
    final p = widget.provider;
    _quickPrompts.clear();
    if (p.isPeriodTrackingEnabled) {
      _quickPrompts.addAll([
        '🌸 Menstrual cycle & phase status',
        '🩸 Relieve cramps & symptoms',
        '✨ Fertile window & ovulation',
      ]);
    } else if (p.isPregnancyTrackingEnabled) {
      _quickPrompts.addAll([
        '🤰 Fetal development & baby size',
        '👶 Due date & trimester milestones',
        '🍼 Pregnancy nutrition & hydration',
      ]);
    }
    _quickPrompts.addAll([
      '📊 Analyze daily biometrics',
      '💧 Hydration pacing & goal',
      '🔥 BMR & caloric budget',
      '🏃 Cardiovascular readiness',
      '🌙 Optimize tonight\'s sleep',
      '🥗 Healthy meal suggestions',
    ]);
  }

  void _initGreeting() {
    final p = widget.provider;
    final greeting = StringBuffer('Hello ${p.userName}! I\'m your Wellnest AI Health Companion, synced to your profile and live biometric telemetry.\n\n');

    if (p.isPeriodTrackingEnabled) {
      greeting.writeln('🌸 **Reproductive Cycle Status:**');
      greeting.writeln('• Cycle Day: Day ${p.currentCycleDay} of ${p.cycleLength} (${p.currentCyclePhase.displayName})');
      greeting.writeln('• Fertility Window: ${p.fertilityStatus}');
      greeting.writeln('• Next Period Expected: In ${p.daysUntilNextPeriod} days\n');
    } else if (p.isPregnancyTrackingEnabled) {
      final fetalData = GestationalDatabase.getDataForWeek(p.currentGestationWeek);
      greeting.writeln('🤰 **Gestational Status:**');
      greeting.writeln('• Progress: Week ${p.currentGestationWeek} • Trimester ${p.currentTrimester}');
      greeting.writeln('• Baby Size: ${fetalData.fruitComparison} (~${fetalData.lengthCm} cm, ${fetalData.weightGrams} g)');
      greeting.writeln('• Due Date: In ${p.daysUntilDueDate} days\n');
    }

    greeting.writeln('📈 **Biometrics & Clinical Baselines:**');
    greeting.writeln('• Steps: ${p.steps} / ${p.stepGoal} (${((p.steps / (p.stepGoal > 0 ? p.stepGoal : 1)) * 100).toInt()}% completed)');
    greeting.writeln('• Hydration: ${p.waterGlasses} / ${p.recommendedHydrationGlasses} glasses (${(p.waterGlasses * 0.25).toStringAsFixed(1)}L logged)');
    greeting.writeln('• Basal Metabolic Rate (BMR): ${p.bmr} kcal/day');
    greeting.writeln('• Target Daily Calories: ${p.recommendedDailyCalories} kcal/day (${p.calories} kcal logged)');
    if (p.bpm > 0) greeting.writeln('• Resting Heart Rate: ${p.bpm} BPM');
    if (p.sleepHours > 0) greeting.writeln('• Last Sleep: ${p.sleepHours} hrs (${p.sleepScore}% quality score)');

    greeting.write('\nWhat aspect of your health would you like to explore or optimize right now?');

    _messages.add(
      ChatMessage(
        text: greeting.toString(),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 40,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleSend([String? presetText]) {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    HapticService.lightImpact();
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    if (presetText == null) {
      _textController.clear();
    }
    _scrollToBottom();

    // Generate intelligent AI response grounded in provider state
    Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      final reply = _generateAiResponse(text);
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
      HapticService.selection();
    });
  }

  String _generateAiResponse(String input) {
    final query = input.toLowerCase();
    final p = widget.provider;

    // Period / Menstrual Cycle Questions
    if (query.contains('cramp') || query.contains('symptom') || query.contains('period pain')) {
      return '🩸 **Clinical Protocol for Menstrual Cramp Relief:**\n\n'
          'Menstrual cramps (dysmenorrhea) are caused by uterine contractions triggered by prostaglandins ($PGF_{2\alpha}$). Here are evidence-based relief strategies:\n\n'
          '1. **Localized Heat Therapy:** Apply a heating pad or warm compress (approx. 40°C / 104°F) across the lower abdomen for 20 minutes to relax myometrial tension.\n'
          '2. **Magnesium & Anti-Inflammatory Nutrients:** Magnesium glycinate (200–300 mg) helps relax smooth muscle tissue. Hydrate with warm herbal chamomile or peppermint tea.\n'
          '3. **Gentle Pelvic Mobility:** Child\'s Pose, Cat-Cow, and light walking improve pelvic vascular flow and stimulate endogenous endorphin release.\n'
          '4. **Hydration Pacing:** Aim for your recommended **${p.recommendedHydrationGlasses} glasses** of water to counter fluid retention and bloating.';
    }

    if (query.contains('cycle') || query.contains('menstrual') || query.contains('period') || query.contains('ovulat') || query.contains('fertile')) {
      if (!p.isPeriodTrackingEnabled) {
        if (p.isPregnancyTrackingEnabled) {
          return '🤰 **Clinical Note:**\n\nYou currently have **Pregnancy Tracking** enabled. During gestation, true menstrual cycles do not occur because sustained progesterone halts the endometrial shed cycle. If you ever experience vaginal spotting or cramping during pregnancy, always consult your obstetrician promptly.';
        }
        return '🌸 **Menstrual Tracking:**\n\nPeriod tracking is currently inactive. If eligible, you can enable Period Tracking in Settings to receive cycle phase forecasts, ovulation windows, and symptom logging.';
      }

      return '🌸 **Menstrual Cycle Telemetry:**\n\n'
          '• **Current Day:** Day **${p.currentCycleDay}** of ${p.cycleLength}\n'
          '• **Cycle Phase:** **${p.currentCyclePhase.displayName}**\n'
          '• **Fertile Window:** **${p.fertilityStatus}**\n'
          '• **Next Period:** Expected in **${p.daysUntilNextPeriod} days**\n\n'
          '💡 *Phase Guidance:* During the ${p.currentCyclePhase.displayName.toLowerCase()}, your body experiences distinct hormonal shifts. In the follicular phase, rising estrogen supports higher strength training intensity and cognitive sharpness; in the luteal phase, rising progesterone elevates your resting body temperature and metabolic rate, making magnesium and steady hydration essential.';
    }

    // Pregnancy Questions
    if (query.contains('baby') || query.contains('fetal') || query.contains('fetus') || query.contains('trimester') || query.contains('pregnant') || query.contains('pregnancy') || query.contains('due date')) {
      if (!p.isPregnancyTrackingEnabled) {
        return '🤰 **Pregnancy Tracking:**\n\nPregnancy tracking is currently disabled. You can activate it in Settings to access weekly gestational milestones, baby size fruit comparisons, and trimester-specific guidance.';
      }

      final fetalData = GestationalDatabase.getDataForWeek(p.currentGestationWeek);
      return '🤰 **Gestational Milestone (Week ${p.currentGestationWeek}):**\n\n'
          '• **Trimester:** Trimester ${p.currentTrimester}\n'
          '• **Baby Size:** Size of a **${fetalData.fruitComparison}**\n'
          '• **Approx. Length:** ~${fetalData.lengthCm} cm (crown to heel)\n'
          '• **Approx. Weight:** ~${fetalData.weightGrams} g\n'
          '• **Due Date Countdown:** **${p.daysUntilDueDate} days remaining**\n\n'
          '🔬 **Development Highlights:**\n${fetalData.milestoneSummary}\n\n'
          '👩‍⚕️ **Clinical Focus:**\n${fetalData.medicalGuidance}';
    }

    if (query.contains('progress') || query.contains('analyze') || query.contains('summary')) {
      final stepPct = ((p.steps / (p.stepGoal > 0 ? p.stepGoal : 10000)) * 100).toInt();
      final waterPct = ((p.waterGlasses / (p.recommendedHydrationGlasses > 0 ? p.recommendedHydrationGlasses : 8)) * 100).toInt();
      return '📊 **Biometric Analysis for ${p.userName}:**\n\n'
          '• **Movement:** $stepPct% of your daily step goal achieved (${p.steps} / ${p.stepGoal} steps).\n'
          '• **Hydration:** $waterPct% of personalized clinical goal (${p.waterGlasses} / ${p.recommendedHydrationGlasses} glasses).\n'
          '• **Metabolism:** ${p.calories} kcal logged vs ${p.recommendedDailyCalories} kcal clinical target (BMR: ${p.bmr} kcal).\n'
          '• **Cardiovascular:** ${p.bpm > 0 ? 'Resting heart rate at ${p.bpm} BPM.' : 'No recent BPM spike detected.'}\n\n'
          '💡 *Recommendation:* You have strong consistency today! A light 15-minute evening stroll will easily push your step count toward your goal.';
    }

    if (query.contains('water') || query.contains('hydration') || query.contains('drink')) {
      final goal = p.recommendedHydrationGlasses;
      final remaining = (goal - p.waterGlasses).clamp(0, 30);
      if (remaining == 0) {
        return '💧 **Hydration Status: Fully Optimized!**\n\nYou have completed your clinically calculated hydration target of $goal glasses (${(goal * 0.25).toStringAsFixed(1)}L), perfectly matching your body mass of ${p.weightKg.toStringAsFixed(1)} kg. Cellular hydration and kidney filtration are optimal. Continue sipping as thirst indicates.';
      }
      return '💧 **Personalized Hydration Pacing:**\n\nBased on your body weight of ${p.weightKg.toStringAsFixed(1)} kg ($35\\text{ml}/\\text{kg}$ guideline), your clinical goal is **$goal glasses** (${(goal * 0.25).toStringAsFixed(1)}L).\n\n'
          '• **Logged:** ${p.waterGlasses} glasses\n'
          '• **Remaining:** $remaining glasses (${(remaining * 0.25).toStringAsFixed(1)}L)\n\n'
          '💡 *Tip:* Drink one 250ml glass within the next 45 minutes to maintain steady blood volume and cognitive alertness.';
    }

    if (query.contains('heart') || query.contains('bpm') || query.contains('cardio')) {
      final bpm = p.bpm > 0 ? p.bpm : 72;
      return '🏃 **Cardiovascular Readiness:**\n\n'
          '• Resting Heart Rate: **$bpm BPM**\n'
          '• Target Zone: Aerobic Base (Zone 2: 110–135 BPM)\n\n'
          'Your resting pulse of $bpm BPM indicates balanced autonomic tone. For building aerobic mitochondria without central nervous system fatigue, aim for 30 minutes in Zone 2 where you can hold a steady nasal conversation.';
    }

    if (query.contains('bmr') || query.contains('calorie') || query.contains('deficit') || query.contains('metabolism') || query.contains('weight') || query.contains('bmi')) {
      return '⚖️ **Clinical Energy & Metabolic Profile:**\n\n'
          'Calculated using the validated **Mifflin-St Jeor equation** with your profile (${p.gender}, ${p.age} yrs, ${p.heightCm.toInt()} cm, ${p.weightKg.toStringAsFixed(1)} kg):\n\n'
          '• **Basal Metabolic Rate (BMR):** **${p.bmr} kcal/day** (energy expended at complete rest)\n'
          '• **Daily Target with Activity:** **${p.recommendedDailyCalories} kcal/day**\n'
          '• **Current Logged Intake:** **${p.calories} kcal**\n'
          '• **Body Mass Index (BMI):** **${p.bmi}** (${p.bmiCategory})\n'
          '• **Target Weight:** **${p.targetWeightKg.toStringAsFixed(1)} kg**\n\n'
          '💡 *Guidance:* To support healthy body recomposition without suppressing thyroid activity, keep your caloric deficit to no more than 300–400 kcal below your daily target while consuming 1.6–2.0g protein per kg of body weight.';
    }

    if (query.contains('dinner') || query.contains('food') || query.contains('meal') || query.contains('nutrition')) {
      final calLeft = (p.recommendedDailyCalories - p.calories).clamp(0, 3500);
      return '🥗 **Nutritional Prescription:**\n\n'
          'You have approximately **$calLeft kcal** remaining in your recommended daily budget of ${p.recommendedDailyCalories} kcal.\n\n'
          'Recommended meal composition:\n'
          '• **Lean Protein:** 30–35g (e.g. Wild Salmon, Chicken Breast, Eggs, or Tofu)\n'
          '• **Complex Fibrous Carbs:** 35–45g (Quinoa, Sweet Potato, or Brown Rice)\n'
          '• **Healthy Lipids:** 10–12g (Extra Virgin Olive Oil or Avocado)\n'
          '• **Cruciferous Greens:** Steamed Broccoli, Asparagus, or Spinach\n\n'
          'This macronutrient balance stabilizes glycemic response, reduces midnight cortisol, and supports deep restorative slow-wave sleep.';
    }

    if (query.contains('sleep') || query.contains('bed') || query.contains('rest')) {
      final sleepHrs = p.sleepHours > 0 ? p.sleepHours : 7.5;
      return '🌙 **Circadian Sleep Protocol:**\n\n'
          'Last recorded sleep: **${sleepHrs}h** (Score: ${p.sleepScore > 0 ? '${p.sleepScore}%' : 'Optimal'}).\n\n'
          '3 Clinical Steps for Restorative Deep Sleep Tonight:\n'
          '1. **Digital Sunset:** Discontinue LED screens and high-intensity blue light 45–60 minutes before bed.\n'
          '2. **Thermal Drop:** Cool your sleeping room to 18–19°C (64–67°F); your core temperature must drop ~1°C to initiate deep slow-wave sleep.\n'
          '3. **Nutritional Wind-Down:** Avoid heavy carbohydrates within 2 hours of sleep; Chamomile or tart cherry extract supports endogenous melatonin.';
    }

    // Default intelligent clinical response
    return '🧠 **Wellnest Clinical Insight:**\n\n'
        'Under your primary focus of **"${p.primaryGoal}"**, your biometrics (${p.steps} steps, ${p.waterGlasses} glasses water, ${p.calories} kcal) work as an interconnected system.\n\n'
        'Ask me anything about your cycle phases, pregnancy milestones, BMR caloric budgeting, hydration timing, or sleep optimization!';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: screenHeight * 0.84,
      child: Column(
        children: [
          // Header (Drag handle is rendered cleanly by bottom sheet wrapper)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Wellnest AI Companion',
                            style: AppTypography.h3(isDark).copyWith(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: AppRadii.roundedPill,
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Live biometric telemetry & health intelligence',
                        style: AppTypography.caption(isDark).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
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
          ),

          const Divider(height: 1),

          // Quick Prompt Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return GestureDetector(
                  onTap: () => _handleSend(prompt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2822) : const Color(0xFFEAF1EC),
                      borderRadius: AppRadii.roundedPill,
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E3E34) : const Color(0xFFD2E0D6),
                        width: 0.8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        prompt,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Chat Messages Thread
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator(isDark);
                }
                return _buildMessageBubble(_messages[index], isDark);
              },
            ),
          ),

          // Message Input Field
          Container(
            padding: EdgeInsets.fromLTRB(
              14,
              10,
              14,
              bottomInset == 0 ? (safeBottom + 12) : 10,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141A17) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF232D28) : const Color(0xFFE5EDE8),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    minLines: 1,
                    onSubmitted: (_) => _handleSend(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask Wellnest AI anything...',
                      hintStyle: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E2823) : const Color(0xFFF1F6F2),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _handleSend(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_upward_rounded, color: Colors.black, size: 22),
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

  Widget _buildMessageBubble(ChatMessage msg, bool isDark) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2E3D35) : const Color(0xFFD8F287),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    // AI message
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 30),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A231F) : const Color(0xFFF5F9F6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF293830) : const Color(0xFFDEE8E1),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primaryDark),
                const SizedBox(width: 6),
                Text(
                  'Wellnest Intelligence',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg.text,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A231F) : const Color(0xFFF5F9F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Text(
              'Wellnest AI analyzing telemetry...',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
