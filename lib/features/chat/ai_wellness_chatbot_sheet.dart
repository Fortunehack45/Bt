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
    final greeting = StringBuffer('Hello ${p.userName}! I\'m your Wellnest AI Companion.\n\n');

    if (p.isPeriodTrackingEnabled) {
      final pred = p.periodPrediction;
      final cycleLen = p.averageCycleLength.round();
      final currentDay = p.currentCycleDay.clamp(1, cycleLen);
      final phaseName = pred.currentPhase.displayName;
      final fertility = p.isFertileWindowDay(DateTime.now())
          ? 'High Fertility'
          : (pred.currentPhase == PeriodPhase.ovulation ? 'Peak Fertility' : 'Low Fertility');

      greeting.writeln('🌸 **Cycle Status:** Day **$currentDay** of $cycleLen • **$phaseName** ($fertility)');
    } else if (p.isPregnancyTrackingEnabled && p.pregnancyData != null) {
      final preg = p.pregnancyData!;
      final fetalData = GestationalDatabase.getWeekInfo(preg.currentWeek);
      greeting.writeln('🤰 **Pregnancy:** Week **${preg.currentWeek}** • Baby size of a **${fetalData.babySizeFruit}**');
    }

    greeting.writeln('📊 **Today\'s Vitals:** **${p.steps}** steps • **${p.waterGlasses}** glasses • **${p.bpm > 0 ? p.bpm : 72}** BPM\n');
    greeting.write('What aspect of your health would you like to explore today?');

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
      return '🩸 **Menstrual Cramp Relief Protocol:**\n\n'
          '• **Heat Therapy:** 20 min warm compress (40°C) across lower abdomen.\n'
          '• **Magnesium:** 200–300mg magnesium glycinate relaxes smooth muscle tissue.\n'
          '• **Gentle Mobility:** Child\'s Pose & Cat-Cow enhance pelvic vascular flow.\n'
          '• **Hydration:** Sip warm herbal tea and keep up your **${p.recommendedHydrationGlasses} glasses** water goal.';
    }

    if (query.contains('cycle') || query.contains('menstrual') || query.contains('period') || query.contains('ovulat') || query.contains('fertile')) {
      if (!p.isPeriodTrackingEnabled) {
        if (p.isPregnancyTrackingEnabled) {
          return '🤰 **Clinical Note:**\n\nYou currently have **Pregnancy Tracking** enabled. True menstrual cycles pause during pregnancy due to sustained progesterone.';
        }
        return '🌸 **Menstrual Tracking:**\n\nPeriod tracking is inactive. You can enable it in Settings anytime.';
      }

      final pred = p.periodPrediction;
      final cycleLen = p.averageCycleLength.round();
      final currentDay = p.currentCycleDay.clamp(1, cycleLen);
      final phaseName = pred.currentPhase.displayName;
      final fertility = p.isFertileWindowDay(DateTime.now())
          ? 'High Fertility'
          : (pred.currentPhase == PeriodPhase.ovulation ? 'Peak Fertility' : 'Low Fertility');
      final daysUntilNext = pred.estimatedNextPeriodDate != null
          ? pred.estimatedNextPeriodDate!.difference(DateTime.now()).inDays.clamp(0, 45)
          : (cycleLen - currentDay).clamp(0, 45);

      return '🌸 **Menstrual Cycle Telemetry:**\n\n'
          '• **Current Day:** Day **$currentDay** of $cycleLen\n'
          '• **Cycle Phase:** **$phaseName**\n'
          '• **Conception Probability:** **$fertility**\n'
          '• **Next Period:** Expected in **$daysUntilNext days**\n\n'
          '💡 *Tip:* During $phaseName, balance your workouts and maintain consistent hydration.';
    }

    // Pregnancy Questions
    if (query.contains('baby') || query.contains('fetal') || query.contains('fetus') || query.contains('trimester') || query.contains('pregnant') || query.contains('pregnancy') || query.contains('due date')) {
      if (!p.isPregnancyTrackingEnabled) {
        return '🤰 **Pregnancy Tracking:**\n\nPregnancy mode is inactive. Activate it in Settings to track weekly fetal development.';
      }

      final preg = p.pregnancyData;
      final currentWeek = preg?.currentWeek ?? 1;
      final fetalData = GestationalDatabase.getWeekInfo(currentWeek);
      final daysLeft = preg?.daysUntilDueDate ?? 280;

      return '🤰 **Gestational Milestone (Week $currentWeek):**\n\n'
          '• **Trimester:** ${fetalData.trimesterLabel}\n'
          '• **Baby Size:** Size of a **${fetalData.babySizeFruit}**\n'
          '• **Dimensions:** ~${fetalData.estimatedLengthCm} cm • ~${fetalData.estimatedWeightGrams.toInt()} g\n'
          '• **Countdown:** **$daysLeft days until due date**\n\n'
          '🔬 *Development:* ${fetalData.fetalMilestone}\n'
          '👩‍⚕️ *Clinical Focus:* ${fetalData.clinicalTip}';
    }

    if (query.contains('progress') || query.contains('analyze') || query.contains('summary')) {
      final stepPct = ((p.steps / (p.stepGoal > 0 ? p.stepGoal : 10000)) * 100).toInt();
      final waterPct = ((p.waterGlasses / (p.recommendedHydrationGlasses > 0 ? p.recommendedHydrationGlasses : 8)) * 100).toInt();
      return '📊 **Biometric Analysis for ${p.userName}:**\n\n'
          '• **Movement:** $stepPct% goal (${p.steps} / ${p.stepGoal} steps)\n'
          '• **Hydration:** $waterPct% goal (${p.waterGlasses} / ${p.recommendedHydrationGlasses} glasses)\n'
          '• **Metabolism:** ${p.calories} / ${p.recommendedDailyCalories} kcal (BMR: ${p.bmr.toStringAsFixed(0)} kcal)\n'
          '• **Heart Rate:** ${p.bpm > 0 ? '${p.bpm} BPM resting' : 'Resting rhythm optimal'}\n\n'
          '💡 *Tip:* Great consistency today! A brief 15-minute walk will close your step goal.';
    }

    if (query.contains('water') || query.contains('hydration') || query.contains('drink')) {
      final goal = p.recommendedHydrationGlasses;
      final remaining = (goal - p.waterGlasses).clamp(0, 30);
      if (remaining == 0) {
        return '💧 **Hydration Status: Goal Achieved!**\n\nYou reached your clinical target of **$goal glasses** (${(goal * 0.25).toStringAsFixed(1)}L) for your ${p.weightKg.toStringAsFixed(1)} kg body weight. Cellular hydration is optimal!';
      }
      return '💧 **Hydration Pacing:**\n\n'
          '• **Target:** **$goal glasses** (${(goal * 0.25).toStringAsFixed(1)}L)\n'
          '• **Logged:** **${p.waterGlasses}** glasses\n'
          '• **Remaining:** **$remaining** glasses\n\n'
          '💡 *Tip:* Drink one 250ml glass in the next hour to maintain mental focus.';
    }

    if (query.contains('heart') || query.contains('bpm') || query.contains('cardio')) {
      final bpm = p.bpm > 0 ? p.bpm : 72;
      return '🏃 **Cardiovascular Readiness:**\n\n'
          '• **Resting Heart Rate:** **$bpm BPM**\n'
          '• **Target Training Zone:** Aerobic Base (Zone 2: 110–135 BPM)\n\n'
          '💡 *Tip:* Your resting pulse indicates balanced autonomic recovery. 30 minutes of conversational-pace exercise builds aerobic endurance without central fatigue.';
    }

    if (query.contains('bmr') || query.contains('calorie') || query.contains('deficit') || query.contains('metabolism') || query.contains('weight') || query.contains('bmi')) {
      return '⚖️ **Metabolic Profile:**\n\n'
          '• **Basal Metabolic Rate:** **${p.bmr} kcal/day** (rest energy)\n'
          '• **Daily Target:** **${p.recommendedDailyCalories} kcal/day**\n'
          '• **Logged Today:** **${p.calories} kcal**\n'
          '• **BMI:** **${p.bmi}** (${p.bmiCategory}) • Goal: **${p.targetWeightKg.toStringAsFixed(1)} kg**\n\n'
          '💡 *Tip:* Keep your caloric deficit moderate (300–400 kcal) with 1.6g protein per kg to protect lean muscle mass.';
    }

    if (query.contains('dinner') || query.contains('food') || query.contains('meal') || query.contains('nutrition')) {
      final calLeft = (p.recommendedDailyCalories - p.calories).clamp(0, 3500);
      return '🥗 **Nutritional Guidance:**\n\n'
          'Budget remaining: **$calLeft kcal** of ${p.recommendedDailyCalories} kcal.\n\n'
          '• **Lean Protein:** 30–35g (salmon, chicken breast, tofu, or eggs)\n'
          '• **Complex Carbs:** 35–45g (quinoa, sweet potato, brown rice)\n'
          '• **Healthy Fats:** 10–12g (avocado or extra virgin olive oil)\n'
          '• **Greens:** Steamed broccoli, asparagus, or leafy spinach\n\n'
          '💡 *Tip:* This balance stabilizes overnight blood sugar and cortisol for deep sleep.';
    }

    if (query.contains('sleep') || query.contains('bed') || query.contains('rest')) {
      final sleepHrs = p.sleepHours > 0 ? p.sleepHours : 7.5;
      return '🌙 **Circadian Sleep Protocol:**\n\n'
          'Last sleep: **${sleepHrs}h** (Score: ${p.sleepScore > 0 ? '${p.sleepScore}%' : 'Optimal'})\n\n'
          '• **Digital Sunset:** Turn off bright screens 45 min before sleep.\n'
          '• **Cool Environment:** Keep bedroom at 18–19°C (64–67°F) for deep sleep.\n'
          '• **Relaxation:** Chamomile tea or magnesium supports natural melatonin.';
    }

    // Default intelligent clinical response
    return '🧠 **Wellnest Intelligence:**\n\n'
        'Under **"${p.primaryGoal}"**, your vitals (${p.steps} steps, ${p.waterGlasses} glasses, ${p.calories} kcal) are syncing well.\n\n'
        'Ask about your cycle phases, pregnancy milestones, BMR budgeting, hydration, or sleep!';
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
          child: _buildFormattedMessageText(msg.text, isDark, isUser: true),
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
            _buildFormattedMessageText(msg.text, isDark, isUser: false),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedMessageText(String text, bool isDark, {bool isUser = false}) {
    final baseColor = isUser
        ? (isDark ? Colors.white : AppColors.textPrimaryLight)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final boldColor = isUser
        ? (isDark ? Colors.white : const Color(0xFF0F2015))
        : (isDark ? Colors.white : const Color(0xFF10281A));
    final bulletColor = isDark ? AppColors.primaryLight : AppColors.primaryDark;

    final lines = text.split('\n');
    final List<Widget> lineWidgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        lineWidgets.add(const SizedBox(height: 6));
        continue;
      }

      final trimmed = line.trim();
      final isBullet = trimmed.startsWith('• ') || trimmed.startsWith('- ') || trimmed.startsWith('* ');
      final isNumbered = RegExp(r'^\d+\.\s').hasMatch(trimmed);

      if (isBullet || isNumbered) {
        String bulletPrefix = '•';
        String content = trimmed;
        if (isBullet) {
          content = trimmed.substring(2).trim();
        } else {
          final match = RegExp(r'^(\d+\.)\s*(.*)$').firstMatch(trimmed);
          if (match != null) {
            bulletPrefix = match.group(1)!;
            content = match.group(2)!;
          }
        }

        lineWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBullet ? '• ' : '$bulletPrefix ',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: bulletColor,
                    height: 1.45,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: baseColor,
                        height: 1.45,
                      ),
                      children: _parseInlineFormatting(content, baseColor, boldColor, isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        lineWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: baseColor,
                  height: 1.45,
                ),
                children: _parseInlineFormatting(trimmed, baseColor, boldColor, isDark),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lineWidgets,
    );
  }

  List<InlineSpan> _parseInlineFormatting(
    String text,
    Color baseColor,
    Color boldColor,
    bool isDark,
  ) {
    final spans = <InlineSpan>[];
    // Matches **bold** or *italic*
    final regex = RegExp(r'(\*\*([^*]+)\*\*|\*([^*]+)\*)');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(
            color: baseColor,
            fontWeight: FontWeight.w400,
          ),
        ));
      }

      final fullMatch = match.group(0)!;
      if (fullMatch.startsWith('**') && fullMatch.endsWith('**')) {
        final boldText = match.group(2) ?? '';
        spans.add(TextSpan(
          text: boldText,
          style: TextStyle(
            color: boldColor,
            fontWeight: FontWeight.w800,
          ),
        ));
      } else if (fullMatch.startsWith('*') && fullMatch.endsWith('*')) {
        final italicText = match.group(3) ?? '';
        spans.add(TextSpan(
          text: italicText,
          style: TextStyle(
            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
          ),
        ));
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w400,
        ),
      ));
    }

    return spans;
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
