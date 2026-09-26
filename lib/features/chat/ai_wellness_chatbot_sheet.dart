import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/glass/platform_glass_bottom_sheet.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
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

  final List<String> _quickPrompts = [
    '📊 Analyze my daily progress',
    '💧 Check hydration pacing',
    '🏃 Heart rate & cardio readiness',
    '🥗 Healthy dinner ideas',
    '🌙 Optimize tonight\'s sleep',
    '🔥 Calorie balance & deficit',
  ];

  @override
  void initState() {
    super.initState();
    _initGreeting();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) _scrollToBottom();
        });
      }
    });
  }

  void _initGreeting() {
    final p = widget.provider;
    final hasTelemetry = p.steps > 0 || p.waterGlasses > 0 || p.calories > 0;

    final greeting = StringBuffer('Hello ${p.userName}! I\'m your Wellnest AI Health Companion, synced to your live biometric sensors.\n\n');

    if (hasTelemetry) {
      greeting.writeln('📈 **Today\'s Snapshot:**');
      greeting.writeln('• Steps: ${p.steps} / ${p.stepGoal} (${((p.steps / p.stepGoal) * 100).toInt()}% completed)');
      greeting.writeln('• Hydration: ${p.waterGlasses} glasses (${(p.waterGlasses * 0.25).toStringAsFixed(1)}L)');
      greeting.writeln('• Calories: ${p.calories} kcal logged');
      if (p.bpm > 0) greeting.writeln('• Heart Rate: ${p.bpm} BPM');
      if (p.sleepHours > 0) greeting.writeln('• Last Sleep: ${p.sleepHours} hrs (${p.sleepScore}% quality)');
      greeting.write('\nWhat aspect of your health would you like to explore or optimize right now?');
    } else {
      greeting.writeln('Your device is ready to track. You can ask me for nutrition guidance, sleep protocols, cardio pacing, or habit building tailored to your goal of "${p.primaryGoal}".');
    }

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

    if (query.contains('progress') || query.contains('analyze') || query.contains('summary')) {
      final stepPct = ((p.steps / (p.stepGoal > 0 ? p.stepGoal : 10000)) * 100).toInt();
      final waterPct = ((p.waterGlasses / (p.waterGoal > 0 ? p.waterGoal : 8)) * 100).toInt();
      return '📊 **Biometric Analysis for ${p.userName}:**\n\n'
          '• **Movement:** $stepPct% of your daily step goal achieved (${p.steps} / ${p.stepGoal} steps).\n'
          '• **Hydration:** $waterPct% of hydration goal (${p.waterGlasses} / ${p.waterGoal} glasses).\n'
          '• **Metabolism:** ${p.calories} kcal intake vs ${p.targetCalories} kcal budget.\n'
          '• **Vitality Score:** ${p.bpm > 0 ? 'Optimal resting heart rate at ${p.bpm} BPM.' : 'No recent BPM spike detected.'}\n\n'
          '💡 *Recommendation:* You have strong momentum today! A light 15-minute evening stroll will easily push your step count toward your goal.';
    }

    if (query.contains('water') || query.contains('hydration') || query.contains('drink')) {
      final remaining = (p.waterGoal - p.waterGlasses).clamp(0, 20);
      if (remaining == 0) {
        return '💧 **Hydration Status: Excellent!**\n\nYou have fully achieved your daily hydration target of ${p.waterGoal} glasses (${(p.waterGoal * 0.25).toStringAsFixed(1)}L). Your cellular hydration and blood volume are well supported. Continue sipping moderately as thirst dictates.';
      }
      return '💧 **Hydration Pacing:**\n\nYou have logged ${p.waterGlasses} of ${p.waterGoal} glasses. You need $remaining more glasses (${(remaining * 0.25).toStringAsFixed(1)}L) to hit today\'s target.\n\n'
          '💡 *Tip:* Drink one 250ml glass within the next 45 minutes to maintain steady kidney filtration and prevent afternoon energy slumps.';
    }

    if (query.contains('heart') || query.contains('bpm') || query.contains('cardio')) {
      final bpm = p.bpm > 0 ? p.bpm : 72;
      return '🏃 **Cardiovascular Readiness:**\n\n'
          '• Resting Heart Rate: **$bpm BPM**\n'
          '• Target Zone: Aerobic Base (Zone 2: 110–135 BPM)\n\n'
          'Your resting pulse of $bpm BPM indicates good autonomic recovery. For building aerobic endurance without metabolic burnout, aim for 30 minutes in Zone 2 where you can hold a steady conversation.';
    }

    if (query.contains('dinner') || query.contains('food') || query.contains('meal') || query.contains('nutrition')) {
      final calLeft = (p.targetCalories - p.calories).clamp(0, 3000);
      return '🥗 **Nutritional Prescription:**\n\n'
          'You have approximately **$calLeft kcal** remaining in your daily budget.\n\n'
          'Recommended dinner profile:\n'
          '• **Lean Protein:** 30–35g (e.g. Atlantic Salmon, Grilled Chicken Breast, or Tempeh)\n'
          '• **Complex Carbs:** 40g (e.g. Quinoa, Steamed Sweet Potato, or Brown Rice)\n'
          '• **Healthy Fats:** 10–12g (Avocado or Extra Virgin Olive Oil drizzle)\n'
          '• **Micronutrients:** Dark leafy greens (Spinach/Kale) with lemon.\n\n'
          'This macronutrient balance prevents evening glucose spikes and supports deep sleep!';
    }

    if (query.contains('sleep') || query.contains('bed') || query.contains('rest')) {
      final sleepHrs = p.sleepHours > 0 ? p.sleepHours : 7.5;
      return '🌙 **Circadian Sleep Protocol:**\n\n'
          'Last recorded sleep: **${sleepHrs}h** (Score: ${p.sleepScore > 0 ? '${p.sleepScore}%' : 'Healthy'}).\n\n'
          'Top 3 steps for tonight:\n'
          '1. **Digital Sunset:** Discontinue screens and blue light 45 minutes prior to bedtime.\n'
          '2. **Thermal Drop:** Cool your room to 18–20°C (65–68°F); core body temperature must drop to trigger REM/Deep sleep.\n'
          '3. **Magnesium & Glycine:** A chamomile tea with a pinch of salt helps calm cortical activity.';
    }

    if (query.contains('calorie') || query.contains('weight') || query.contains('bmi') || query.contains('deficit')) {
      return '⚖️ **Body Composition & Energy Balance:**\n\n'
          '• Current Weight: **${p.weightKg > 0 ? '${p.weightKg} kg' : '70.0 kg'}**\n'
          '• Target Weight: **${p.targetWeightKg} kg**\n'
          '• BMI: **${p.bmi}** (${p.bmiCategory})\n'
          '• Intake: **${p.calories} / ${p.targetCalories} kcal**\n\n'
          'To sustain fat oxidation while protecting lean muscle mass, prioritize 1.6–2.0g protein per kilogram of body weight alongside progressive resistance training.';
    }

    // Default intelligent clinical response
    return '🧠 **Wellnest Clinical Insight:**\n\n'
        'Under your primary focus of **"${p.primaryGoal}"**, every biometric datapoint works in harmony. Your body adapts best to consistent small habits rather than radical shifts.\n\n'
        'Would you like me to formulate a specific routine for your activity, hydration pacing, or nutritional timing?';
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
