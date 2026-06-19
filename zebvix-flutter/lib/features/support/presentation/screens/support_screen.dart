import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _faqs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final dio = ref.read(dioProvider);
      final results = await Future.wait([
        dio.get(AppConstants.supportTicketsPath).catchError((_) => null),
        dio.get(AppConstants.faqPath).catchError((_) => null),
      ]);
      setState(() {
        final ticketData = results[0]?.data;
        if (ticketData is List) _tickets = ticketData.cast<Map<String, dynamic>>();
        final faqData = results[1]?.data;
        if (faqData is List) _faqs = faqData.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(
        title: 'Support Center',
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
            label: Text('New Ticket', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            onPressed: _showCreateTicket,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildContactOptions(),
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'My Tickets'), Tab(text: 'FAQ'), Tab(text: 'Status')],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [_buildTickets(), _buildFAQ(), _buildStatus()],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOptions() {
    final contacts = [
      {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Live Chat', 'color': AppColors.bullish},
      {'icon': Icons.send_rounded, 'label': 'Telegram', 'color': const Color(0xFF2AABEE)},
      {'icon': Icons.email_outlined, 'label': 'Email', 'color': AppColors.primary},
      {'icon': Icons.phone_outlined, 'label': 'Phone', 'color': AppColors.info},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: contacts.map((c) => GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: (c['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(c['label'] as String, style: AppTextStyles.micro),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTickets() {
    if (_tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.support_agent_rounded, color: AppColors.textHint, size: 64),
            const SizedBox(height: 12),
            Text('No support tickets yet', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ZebButton(label: 'Submit a Ticket', onPressed: _showCreateTicket, isFullWidth: false),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tickets.length,
      itemBuilder: (_, i) => _TicketCard(
        ticket: _tickets[i],
        onTap: () => context.push('/support/ticket/${_tickets[i]['id']}'),
      ),
    );
  }

  Widget _buildFAQ() {
    if (_faqs.isEmpty) return const Center(child: Text('No FAQs available', style: AppTextStyles.caption));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faqs.length,
      itemBuilder: (_, i) => ExpansionTile(
        title: Text(_faqs[i]['question']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
        iconColor: AppColors.primary,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(_faqs[i]['answer']?.toString() ?? '', style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    return const Center(child: Text('All systems operational', style: AppTextStyles.body));
  }

  void _showCreateTicket() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateTicketSheet(onSubmit: (subject, message) async {
        try {
          final dio = ref.read(dioProvider);
          await dio.post(AppConstants.createTicketPath, data: {'subject': subject, 'message': message});
          if (mounted) { Navigator.pop(context); _fetchData(); }
        } catch (_) {}
      }),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onTap;
  const _TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = ticket['status']?.toString() ?? 'open';
    final statusColor = status == 'open' ? AppColors.bullish : status == 'pending' ? AppColors.warning : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket['subject']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 4),
                Text('#${ticket['id']?.toString() ?? ''}', style: AppTextStyles.micro),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(status.toUpperCase(),
                  style: AppTextStyles.micro.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTicketSheet extends StatefulWidget {
  final Future<void> Function(String subject, String message) onSubmit;
  const _CreateTicketSheet({required this.onSubmit});

  @override
  State<_CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<_CreateTicketSheet> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submit a Ticket', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            TextField(controller: _subjectCtrl, style: AppTextStyles.body,
                decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 12),
            TextField(controller: _messageCtrl, style: AppTextStyles.body, maxLines: 4,
                decoration: const InputDecoration(labelText: 'Describe your issue')),
            const SizedBox(height: 16),
            ZebButton(
              label: 'Submit',
              isLoading: _isSubmitting,
              onPressed: () async {
                setState(() => _isSubmitting = true);
                await widget.onSubmit(_subjectCtrl.text, _messageCtrl.text);
                setState(() => _isSubmitting = false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
