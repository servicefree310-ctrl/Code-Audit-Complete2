import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';

class FiatScreen extends ConsumerStatefulWidget {
  const FiatScreen({super.key});

  @override
  ConsumerState<FiatScreen> createState() => _FiatScreenState();
}

class _FiatScreenState extends ConsumerState<FiatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountCtrl = TextEditingController();
  String _selectedMethod = 'UPI';
  bool _isSubmitting = false;

  final _methods = [
    {'name': 'UPI', 'icon': Icons.payment_rounded, 'color': Color(0xFF6739B7)},
    {'name': 'IMPS', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF1565C0)},
    {'name': 'NEFT', 'icon': Icons.swap_horiz_rounded, 'color': Color(0xFF2E7D32)},
    {'name': 'RTGS', 'icon': Icons.speed_rounded, 'color': Color(0xFFE65100)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _submit(bool isDeposit) async {
    if (_amountCtrl.text.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(isDeposit ? AppConstants.fiatDepositPath : AppConstants.fiatWithdrawPath, data: {
        'amount': double.tryParse(_amountCtrl.text) ?? 0,
        'method': _selectedMethod,
        'currency': 'INR',
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${isDeposit ? 'Deposit' : 'Withdrawal'} request submitted!'),
        backgroundColor: AppColors.bullish,
      ));
      _amountCtrl.clear();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed. Please try again.'), backgroundColor: AppColors.error));
    }
    setState(() => _isSubmitting = false);
  }

  @override
  void dispose() { _tabController.dispose(); _amountCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(
        title: 'INR Fiat',
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.account_balance_outlined, size: 16, color: AppColors.primary),
            label: Text('Banks', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            onPressed: () => context.push('/bank'),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Deposit INR'), Tab(text: 'Withdraw INR')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildForm(isDeposit: true), _buildForm(isDeposit: false)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm({required bool isDeposit}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
            children: _methods.map((m) {
              final isSelected = _selectedMethod == m['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedMethod = m['name'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? (m['color'] as Color).withOpacity(0.15) : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? m['color'] as Color : AppColors.borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m['icon'] as IconData, color: m['color'] as Color, size: 22),
                      const SizedBox(height: 4),
                      Text(m['name'] as String, style: AppTextStyles.micro.copyWith(
                          color: isSelected ? m['color'] as Color : AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Text('Amount (INR)', style: AppTextStyles.bodySemiBold),
            const Spacer(),
            Text(isDeposit ? 'Min: ₹100' : 'Min: ₹500', style: AppTextStyles.caption),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.h4,
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
              hintText: '0.00',
              hintStyle: AppTextStyles.h4.copyWith(color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['100', '500', '1000', '5000', '10000'].map((a) => GestureDetector(
              onTap: () => _amountCtrl.text = a,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('₹$a', style: AppTextStyles.caption),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              _FeeRow(label: 'Processing Fee', value: '₹0'),
              _FeeRow(label: 'You will receive', value: '₹${_amountCtrl.text.isEmpty ? '0' : _amountCtrl.text} USDT ≈ ...'),
            ]),
          ),
          const SizedBox(height: 24),
          ZebButton(
            label: isDeposit ? 'Deposit INR' : 'Withdraw INR',
            onPressed: () => _submit(isDeposit),
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  const _FeeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text(label, style: AppTextStyles.caption),
      const Spacer(),
      Text(value, style: AppTextStyles.captionSemiBold),
    ]),
  );
}
