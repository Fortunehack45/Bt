import 'package:flutter/material.dart';
import '../../core/glass/platform_frosted_container.dart';
import '../../core/services/firebase_sync_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/models/auth_user_model.dart';
import '../../domain/models/support_ticket_model.dart';
import '../../domain/state/wellness_provider.dart';

/// In-app Customer Support and inquiry chat screen for mobile users.
class SupportChatScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SupportChatScreen({super.key, required this.onBack});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseSyncService _syncService = FirebaseSyncService.instance;

  String? _selectedTicketId;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String ticketId) async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    HapticService.selection();
    _msgController.clear();
    await _syncService.sendTicketMessage(ticketId: ticketId, content: text, isSupport: false);

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Auto-reply simulation from support team
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _syncService.sendTicketMessage(
          ticketId: ticketId,
          content: 'Thank you for reaching out! Our team has received your inquiry regarding "$text" and is investigating. We will follow up shortly.',
          isSupport: true,
        );
      }
    });
  }

  void _createNewTicketModal(BuildContext context) {
    HapticService.selection();
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String category = 'General';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: PlatformFrostedContainer(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('New Support Inquiry', style: AppTypography.h2(isDark).copyWith(fontSize: 18)),
                const SizedBox(height: 14),
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(hintText: 'Inquiry Subject / Topic'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Describe how we can help you...'),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () async {
                    if (subjectCtrl.text.trim().isNotEmpty && messageCtrl.text.trim().isNotEmpty) {
                      final t = await _syncService.createSupportTicket(
                        subject: subjectCtrl.text.trim(),
                        category: category,
                        initialMessage: messageCtrl.text.trim(),
                      );
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        setState(() => _selectedTicketId = t.ticketId);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimaryLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Ticket', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final tickets = provider.supportTickets;

    // Pick active ticket or default to first
    SupportTicket? activeTicket;
    if (_selectedTicketId != null) {
      activeTicket = tickets.firstWhere(
        (t) => t.ticketId == _selectedTicketId,
        orElse: () => tickets.isNotEmpty ? tickets.first : _dummyTicket(),
      );
    } else if (tickets.isNotEmpty) {
      activeTicket = tickets.first;
    } else {
      activeTicket = _dummyTicket();
    }

    final isPremium = provider.isPremium;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF131D16) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            HapticService.lightImpact();
            widget.onBack();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wellnest Support Desk',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                ),
                const SizedBox(width: 6),
                Text(
                  isPremium ? 'Priority VIP Care Active' : 'Support Online',
                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New Ticket',
            icon: const Icon(Icons.add_comment_outlined, color: AppColors.primary),
            onPressed: () => _createNewTicketModal(context),
          ),
        ],
      ),
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: false,
        bottomSafeArea: true,
        child: Column(
          children: [
            // Plan Tier Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark ? const Color(0xFF18231B) : const Color(0xFFF1F5F9),
              child: Row(
                children: [
                  Icon(
                    isPremium ? Icons.workspace_premium_rounded : Icons.support_agent_rounded,
                    size: 18,
                    color: isPremium ? AppColors.warningAmber : AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isPremium
                          ? 'Premium Member: 24/7 dedicated clinical care assistance.'
                          : 'Freemium Member: Standard inquiry queue (average response < 2 hrs).',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Messages Stream
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: activeTicket.messages.length,
                itemBuilder: (context, i) {
                  final msg = activeTicket!.messages[i];
                  return _buildMessageBubble(msg, isDark);
                },
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141E17) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF233226) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B281F) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextField(
                          controller: _msgController,
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Message Support Team...',
                            hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(activeTicket!.ticketId),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                      onPressed: () => _sendMessage(activeTicket!.ticketId),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage msg, bool isDark) {
    final isMe = msg.isFromUser;
    final timeStr = '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 290),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : (isDark ? const Color(0xFF1F2D23) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  msg.senderName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emeraldTeal,
                  ),
                ),
              ),
            Text(
              msg.content,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: isMe ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeStr,
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.white60 : (isDark ? Colors.white38 : Colors.black45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SupportTicket _dummyTicket() {
    return SupportTicket(
      ticketId: 'TCK-NEW',
      userId: 'usr',
      userPlan: UserPlanTier.freemium,
      subject: 'General Inquiry',
      category: 'General',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );
  }
}
