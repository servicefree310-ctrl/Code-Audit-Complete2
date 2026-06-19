import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/utils/formatters.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  Map<String, dynamic>? _ticket;
  bool _isLoading = true;
  final _replyCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchTicket();
  }

  Future<void> _fetchTicket() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('${AppConstants.supportTicketsPath}/${widget.ticketId}');
      setState(() { _ticket = response.data as Map<String, dynamic>?; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendReply() async {
    if (_replyCtrl.text.isEmpty) return;
    final msg = _replyCtrl.text;
    _replyCtrl.clear();
    setState(() => _isSending = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('${AppConstants.supportTicketsPath}/${widget.ticketId}/reply', data: {'message': msg});
      _fetchTicket();
    } catch (_) {}
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final messages = (_ticket?['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(title: _ticket?['subject']?.toString() ?? 'Ticket'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.surface,
                  child: Row(children: [
                    Text('Status: ', style: AppTextStyles.caption),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.bullish.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(_ticket?['status']?.toString().toUpperCase() ?? 'OPEN',
                          style: AppTextStyles.micro.copyWith(color: AppColors.bullish, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Text('#${widget.ticketId.substring(0, 8)}', style: AppTextStyles.micro),
                  ]),
                ),
                Expanded(
                  child: messages.isEmpty
                      ? const Center(child: Text('No messages', style: AppTextStyles.caption))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: messages.length,
                          itemBuilder: (_, i) {
                            final msg = messages[i];
                            final isUser = msg['isUser'] as bool? ?? true;
                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                decoration: BoxDecoration(
                                  color: isUser ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    if (!isUser) Text('Support Agent', style: AppTextStyles.micro.copyWith(color: AppColors.primary)),
                                    Text(msg['message']?.toString() ?? '', style: AppTextStyles.body),
                                    const SizedBox(height: 4),
                                    Text(Formatters.relativeTime(DateTime.tryParse(msg['createdAt']?.toString() ?? '') ?? DateTime.now()),
                                        style: AppTextStyles.micro),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      Expanded(child: TextField(
                        controller: _replyCtrl,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: 'Type your reply...',
                          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          filled: true, fillColor: AppColors.surfaceLight,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          isDense: true,
                        ),
                      )),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isSending ? null : _sendReply,
                        child: Container(
                          width: 38, height: 38,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: _isSending
                              ? const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark))
                              : const Icon(Icons.send_rounded, color: AppColors.textDark, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
