import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';

class P2POrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const P2POrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<P2POrderDetailScreen> createState() => _P2POrderDetailScreenState();
}

class _P2POrderDetailScreenState extends ConsumerState<P2POrderDetailScreen> {
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  final _messageCtrl = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('${AppConstants.p2pOrdersPath}/${widget.orderId}');
      setState(() { _order = response.data as Map<String, dynamic>?; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageCtrl.text.isEmpty) return;
    final msg = _messageCtrl.text;
    _messageCtrl.clear();
    setState(() => _messages.add({'text': msg, 'isSelf': true, 'time': DateTime.now().toIso8601String()}));
    try {
      final dio = ref.read(dioProvider);
      await dio.post('${AppConstants.p2pChatPath}/${widget.orderId}', data: {'message': msg});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(
        title: 'P2P Order #${widget.orderId.substring(0, 8)}',
        actions: [
          IconButton(icon: const Icon(Icons.flag_outlined, color: AppColors.bearish), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildOrderInfo(),
                const Divider(color: AppColors.borderColor),
                Expanded(child: _buildChat()),
                _buildChatInput(),
                _buildActions(),
              ],
            ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(children: [
            const Icon(Icons.timer_outlined, size: 16, color: AppColors.warning),
            const SizedBox(width: 6),
            Text('Time remaining: 15:00', style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.warning)),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(label: 'Amount', value: '${_order?['amount'] ?? '--'} USDT'),
              _InfoChip(label: 'Price', value: '₹${_order?['price'] ?? '--'}'),
              _InfoChip(label: 'Total', value: '₹${_order?['total'] ?? '--'}'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment Method', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(_order?['paymentMethod']?.toString() ?? 'UPI', style: AppTextStyles.bodySemiBold),
                Text(_order?['paymentDetail']?.toString() ?? '', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChat() {
    if (_messages.isEmpty) {
      return const Center(child: Text('No messages yet. Start the conversation.', style: AppTextStyles.caption));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        final isSelf = msg['isSelf'] as bool? ?? false;
        return Align(
          alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelf ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(msg['text']?.toString() ?? '', style: AppTextStyles.body),
          ),
        );
      },
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageCtrl,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                filled: true, fillColor: AppColors.surfaceLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 38, height: 38,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: AppColors.textDark, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
            child: const Text('Dispute'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.bullish),
            child: Text('Paid – Release', style: AppTextStyles.button.copyWith(color: Colors.white)),
          )),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(
      children: [
        Text(label, style: AppTextStyles.micro),
        Text(value, style: AppTextStyles.captionSemiBold),
      ],
    ));
  }
}
