import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../../../../core/utils/formatters.dart';

class DepositScreen extends ConsumerStatefulWidget {
  final String? coin;
  const DepositScreen({super.key, this.coin});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen> {
  String _selectedCoin = '';
  String _selectedNetwork = '';
  String? _depositAddress;
  String? _memo;
  List<Map<String, dynamic>> _networks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCoin = widget.coin ?? 'USDT';
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    if (_selectedCoin.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final netResponse = await dio.get('${AppConstants.networkListPath}?coin=$_selectedCoin');
      final nets = (netResponse.data as List?)?.cast<Map<String, dynamic>>() ?? [];
      setState(() {
        _networks = nets;
        if (nets.isNotEmpty && _selectedNetwork.isEmpty) _selectedNetwork = nets[0]['network']?.toString() ?? '';
      });

      if (_selectedNetwork.isNotEmpty) {
        final addrResponse = await dio.post(AppConstants.depositAddressPath, data: {
          'coin': _selectedCoin,
          'network': _selectedNetwork,
        });
        final data = addrResponse.data as Map<String, dynamic>?;
        setState(() {
          _depositAddress = data?['address']?.toString();
          _memo = data?['memo']?.toString();
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _copyAddress() {
    if (_depositAddress == null) return;
    Clipboard.setData(ClipboardData(text: _depositAddress!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied!'), backgroundColor: AppColors.bullish));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(title: 'Deposit $_selectedCoin'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 16, backgroundColor: AppColors.surfaceLight,
                      child: Text(_selectedCoin.substring(0, 1), style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.primary))),
                  const SizedBox(width: 10),
                  Text(_selectedCoin, style: AppTextStyles.bodySemiBold),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Network selector
            if (_networks.isNotEmpty) ...[
              Text('Network', style: AppTextStyles.bodySemiBold),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _networks.map((n) {
                  final net = n['network']?.toString() ?? '';
                  final isSelected = net == _selectedNetwork;
                  return GestureDetector(
                    onTap: () { setState(() => _selectedNetwork = net); _fetchAddress(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderColor),
                      ),
                      child: Column(
                        children: [
                          Text(net, style: AppTextStyles.captionSemiBold.copyWith(
                              color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                          Text(n['arrivalTime']?.toString() ?? '~2 min', style: AppTextStyles.micro),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (_depositAddress != null) ...[
              // QR Code
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: _depositAddress!,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Deposit Address', style: AppTextStyles.bodySemiBold),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(
                      Formatters.truncateAddress(_depositAddress!, chars: 12),
                      style: AppTextStyles.body.copyWith(fontFamily: 'monospace'),
                    )),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 18),
                      onPressed: _copyAddress,
                    ),
                  ],
                ),
              ),
              if (_memo != null) ...[
                const SizedBox(height: 12),
                Text('Memo / Tag', style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_memo!, style: AppTextStyles.body)),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 18),
                        onPressed: () => Clipboard.setData(ClipboardData(text: _memo!)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⚠️ This coin requires both an address and memo/tag. Missing the memo may result in permanent loss of funds.',
                    style: AppTextStyles.micro.copyWith(color: AppColors.warning),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ZebButton(
                label: 'Share Address',
                variant: ZebButtonVariant.secondary,
                icon: Icons.share_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Important', style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.warning)),
                    const SizedBox(height: 8),
                    Text('• Send only $_selectedCoin to this address\n• Minimum deposit: --\n• Expected arrival: ${_networks.isNotEmpty ? _networks[0]['arrivalTime'] ?? '~2 min' : '~10 min'}',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
