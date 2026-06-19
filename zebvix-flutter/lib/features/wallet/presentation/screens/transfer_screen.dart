import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  String _from = 'Spot';
  String _to = 'Futures';
  final _amountCtrl = TextEditingController();
  String _selectedCoin = 'USDT';
  bool _isSubmitting = false;

  final _wallets = ['Spot', 'Funding', 'Futures', 'Earn'];

  Future<void> _transfer() async {
    if (_amountCtrl.text.isEmpty || _from == _to) return;
    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(AppConstants.transferPath, data: {
        'from': _from.toLowerCase(),
        'to': _to.toLowerCase(),
        'coin': _selectedCoin,
        'amount': double.tryParse(_amountCtrl.text) ?? 0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer successful!'), backgroundColor: AppColors.bullish));
        context.pop();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer failed.'), backgroundColor: AppColors.error));
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZebAppBar(title: 'Transfer'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _WalletDropdown(label: 'From', value: _from, options: _wallets,
                    onChanged: (v) => setState(() => _from = v))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GestureDetector(
                    onTap: () => setState(() { final tmp = _from; _from = _to; _to = tmp; }),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 18),
                    ),
                  ),
                ),
                Expanded(child: _WalletDropdown(label: 'To', value: _to, options: _wallets,
                    onChanged: (v) => setState(() => _to = v))),
              ],
            ),
            const SizedBox(height: 20),
            Text('Coin', style: AppTextStyles.bodySemiBold),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    Text(_selectedCoin, style: AppTextStyles.bodySemiBold),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Amount', style: AppTextStyles.bodySemiBold),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
                suffixText: _selectedCoin,
                suffixStyle: AppTextStyles.captionSemiBold,
                suffixIcon: TextButton(
                  onPressed: () {},
                  child: Text('MAX', style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.primary)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Available: -- $_selectedCoin', style: AppTextStyles.caption),
            const Spacer(),
            ZebButton(label: 'Transfer', onPressed: _transfer, isLoading: _isSubmitting),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _WalletDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final void Function(String) onChanged;
  const _WalletDropdown({required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: AppTextStyles.bodySemiBold,
            dropdownColor: AppColors.surface,
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ),
      ],
    );
  }
}
