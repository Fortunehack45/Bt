import 'package:flutter/material.dart';
import '../../core/glass/platform_frosted_container.dart';
import '../../core/services/firebase_sync_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/models/shared_goal_model.dart';
import '../../domain/state/wellness_provider.dart';

/// Screen where two or more Wellnest users come together to achieve wellness goals
/// and send real-time reminders/nudges to each other.
class SharedGoalsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SharedGoalsScreen({super.key, required this.onBack});

  @override
  State<SharedGoalsScreen> createState() => _SharedGoalsScreenState();
}

class _SharedGoalsScreenState extends State<SharedGoalsScreen> {
  final FirebaseSyncService _syncService = FirebaseSyncService.instance;

  void _openCreateGoalModal() {
    HapticService.selection();
    final titleCtrl = TextEditingController(text: '10,000 Steps Pact');
    final targetCtrl = TextEditingController(text: '10000');
    String metric = 'steps';
    String unit = 'steps';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: PlatformFrostedContainer(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Create Collaborative Goal', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(hintText: 'Challenge Title'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: metric,
                            items: const [
                              DropdownMenuItem(value: 'steps', child: Text('Daily Steps')),
                              DropdownMenuItem(value: 'water', child: Text('Hydration (Glasses)')),
                              DropdownMenuItem(value: 'sleep', child: Text('Sleep (Hours)')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  metric = val;
                                  unit = val == 'steps' ? 'steps' : (val == 'water' ? 'glasses' : 'hrs');
                                  if (val == 'water') targetCtrl.text = '8';
                                  if (val == 'sleep') targetCtrl.text = '8';
                                  if (val == 'steps') targetCtrl.text = '10000';
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: targetCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: 'Target ($unit)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final val = double.tryParse(targetCtrl.text.trim()) ?? 10000.0;
                        await _syncService.createSharedGoal(
                          title: titleCtrl.text.trim(),
                          metricType: metric,
                          targetValue: val,
                          unit: unit,
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimaryLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Start Challenge', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openJoinGoalModal() {
    HapticService.selection();
    final codeCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return PlatformFrostedContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Join Partner Challenge', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Text('Enter the 6-character challenge invite code shared by your friend.', style: AppTypography.caption(isDark)),
              const SizedBox(height: 14),
              TextField(
                controller: codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(hintText: 'e.g. GOAL-STEP8'),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () async {
                  final code = codeCtrl.text.trim();
                  final success = await _syncService.joinSharedGoal(code);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Joined challenge successfully!' : 'Invalid challenge code.'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: success ? AppColors.primary : AppColors.errorRed,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Connect to Challenge', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendReminderNudge(SharedGoal goal) {
    HapticService.mediumImpact();
    final messages = [
      'Time to hit the target! Let\'s keep going strong!',
      'Drink a glass of water and stay energized!',
      'Almost at our daily goal, let\'s finish it together!',
      'Great progress today! Keep the momentum alive!',
    ];
    final randomMsg = messages[DateTime.now().second % messages.length];
    _syncService.sendGoalReminder(goal.goalId, randomMsg);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent reminder to partners: "$randomMsg"'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final goals = provider.sharedGoals;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            HapticService.lightImpact();
            widget.onBack();
          },
        ),
        title: Text(
          'Partner Challenges',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Join with Code',
            icon: const Icon(Icons.group_add_outlined, color: AppColors.emeraldTeal),
            onPressed: _openJoinGoalModal,
          ),
        ],
      ),
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: false,
        bottomSafeArea: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Intro Action Card
              PlatformFrostedContainer(
                borderRadius: BorderRadius.circular(22),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.handshake_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Achieve Together', style: AppTypography.h3(isDark).copyWith(fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('Team up with friends or partners and hold each other accountable.', style: AppTypography.caption(isDark)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openCreateGoalModal,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('New Goal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimaryLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openJoinGoalModal,
                      icon: const Icon(Icons.qr_code_rounded, size: 18, color: AppColors.emeraldTeal),
                      label: const Text('Join Code', style: TextStyle(color: AppColors.emeraldTeal)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.emeraldTeal.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'ACTIVE COLLABORATIVE CHALLENGES',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),

              if (goals.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131D16) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'No active challenges. Tap "New Goal" or "Join Code" to team up.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 13),
                    ),
                  ),
                )
              else
                ...goals.map((g) => _buildGoalCard(g, isDark)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(SharedGoal goal, bool isDark) {
    final progress = goal.collectiveProgressRatio;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141E17) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF243427) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Target: ${goal.targetValue.toInt()} ${goal.unit} per person • Code: ${goal.goalId}',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Team Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          const SizedBox(height: 16),

          // Participants Avatars & Breakdown
          ...goal.participants.values.map((p) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.emeraldTeal.withOpacity(0.25),
                    child: Text(
                      p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.emeraldTeal),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p.displayName,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  Text(
                    '${p.currentProgress.toInt()} / ${goal.targetValue.toInt()} ${goal.unit}',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 14),

          // Reminder Nudge Button & Latest Cheer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => _sendReminderNudge(goal),
                icon: const Icon(Icons.notifications_active_outlined, size: 16, color: AppColors.primary),
                label: const Text('Nudge Partner', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              if (goal.reminders.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Last nudge: "${goal.reminders.first.message}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
