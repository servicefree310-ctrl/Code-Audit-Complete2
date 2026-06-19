import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  final String? coin;
  const WithdrawScreen({super.key, this.coin});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  String _selectedCoin = '';
  String _selectedNetwork = '';
  final _addressCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  List<Map<String, dynamic>> _networks = [];
  double _fee = 0;
  double _availableBalance = 0;
  double _minWithdraw = 0;
  bool _isLoadingBalance = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCoin = widget.coin ?? 'USDT';
    _fetchNetworksAndBalance();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _memoCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  // FIX: Fetch real available balance and network info together
  Future<void> _fetchNetworksAndBalance() async {
    setState(() => _isLoadingBalance = true);
    try {
      final dio = ref.read(dioProvider);
      final results = await Future.wait([
        dio.get('${AppConstants.networkListPath}?coin=$_selectedCoin').catchError((_) => null),
        dio.get('${AppConstants.walletBalancePath}?coin=$_selectedCoin').catchError((_) => null),
      ]);

      final nets = (results[0]?.data as List?)?.cast<Map<String, dynamic>>() ?? [];
      final balanceData = results[1]?.data as Map<String, dynamic>?;

      setState(() {
        _networks = nets;
        if (nets.isNotEmpty) {
          _selectedNetwork = nets[0]['network']?.toString() ?? '';
          _fee = (nets[0]['withdrawFee'] as num?)?.toDouble() ?? 0;
          _minWithdraw = (nets[0]['minWithdraw'] as num?)?.toDouble() ?? 0;
        }
        _availableBalance = (balanceData?['available'] as num?)?.toDouble() ?? 0;
        _isLoadingBalance = false;
      });
    } catch (_) {
      setState(() => _isLoadingBalance = false);
    }
  }

  // FIX: Biometric/PIN confirmation required before any withdrawal
  Future<void> _withdraw() async {
    if (_addressCtrl.text.isEmpty || _amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in address and amount.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.'), backgroundColor: AppColors.warning),
      );
      return;
    }
    if (amount > _availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount exceeds available balance.'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_minWithdraw > 0 && amount < _minWithdraw) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimum withdrawal is $_minWithdraw $_selectedCoin'), backgroundColor: AppColors.warning),
      );
      return;
    }

    // FIX: Require biometric/PIN before submitting withdrawal
    final biometricService = ref.read(biometricServiceProvider);
    final authResult = await biometricService.authenticateForTransaction(
      'Withdraw $amount $_selectedCoin to ${_addressCtrl.text.trim()}',
    );

    if (!authResult.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authResult.errorMessage ?? 'Authentication failed. Withdrawal cancelled.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(AppConstants.withdrawPath, data: {
        'coin': _selectedCoin,
        'network': _selectedNetwork,
        'address': _addressCtrl.text.trim(),
        'amount': amount,
        if (_memoCtrl.text.isNotEmpty) 'memo': _memoCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Withdrawal request submitted!'),
            backgroundColor: AppColors.bullish,
          ),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Withdrawal failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    setState(() => _isSubmitting = false);
  }

  double get _receiveAmount {
    final entered = double.tryParse(_amountCtrl.text) ?? 0;
    final receive = entered - _fee;
    return receive > 0 ? receive : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(title: 'Withdraw $_selectedCoin'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoinSelector(),
            const SizedBox(height: 16),
            _buildNetworkSelector(),
            const SizedBox(height: 16),
            _buildAddressInput(),
            const SizedBox(height: 16),
            _buildAmountInput(),
            const SizedBox(height: 16),
            _buildFeeSummary(),
            const SizedBox(height: 16),
            // FIX: Biometric confirmation notice
            _buildAuthNotice(),
            const SizedBox(height: 16),
            _buildWarning(),
            const SizedBox(height: 24),
            ZebButton(
              label: 'Withdraw',
              onPressed: _isSubmitting ? null : _withdraw,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinSelector() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceLight,
              child: Text(
                _selectedCoin.isNotEmpty ? _selectedCoin.substring(0, 1) : 'C',
                style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Text(_selectedCoin, style: AppTextStyles.bodySemiBold),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkSelector() {
    if (_networks.isEmpty) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Network', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _networks.map((n) {
            final net = n['network']?.toString() ?? '';
            final isSelected = net == _selectedNetwork;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedNetwork = net;
                _fee = (n['withdrawFee'] as num?)?.toDouble() ?? 0;
                _minWithdraw = (n['minWithdraw'] as num?)?.toDouble() ?? 0;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderColor),
                ),
                child: Text(
                  net,
                  style: AppTextStyles.captionSemiBold.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddressInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Withdrawal Address', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 8),
        TextField(
          controller: _addressCtrl,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Enter or paste address',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
              onPressed: () {},
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _memoCtrl,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Memo / Tag (if required)',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Amount', style: AppTextStyles.bodySemiBold),
            const Spacer(),
            // FIX: Show real available balance
            _isLoadingBalance
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                  )
                : Text(
                    'Available: ${_availableBalance.toStringAsFixed(6)} $_selectedCoin',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.body,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            // FIX: Show real minimum withdrawal amount
            hintText: _minWithdraw > 0 ? 'Min: $_minWithdraw' : 'Enter amount',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
            suffixIcon: TextButton(
              // FIX: MAX button now fills in the real available balance
              onPressed: _availableBalance > 0
                  ? () {
                      final maxAmount = (_availableBalance - _fee).clamp(0.0, _availableBalance);
                      _amountCtrl.text = maxAmount.toStringAsFixed(6);
                      setState(() {});
                    }
                  : null,
              child: Text(
                'MAX',
                style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Row(children: [
            Text('Network Fee', style: AppTextStyles.caption),
            const Spacer(),
            Text('$_fee $_selectedCoin', style: AppTextStyles.captionSemiBold),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text('You will receive', style: AppTextStyles.caption),
            const Spacer(),
            // FIX: Shows real calculated receive amount
            Text(
              _amountCtrl.text.isEmpty
                  ? '-- $_selectedCoin'
                  : '${_receiveAmount.toStringAsFixed(6)} $_selectedCoin',
              style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.primary),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildAuthNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Biometric / PIN verification will be required to confirm this withdrawal.',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Text(
        '⚠️ Please double-check the withdrawal address. Withdrawals to incorrect addresses cannot be reversed.',
        style: AppTextStyles.caption.copyWith(color: AppColors.warning),
      ),
    );
  }
}
