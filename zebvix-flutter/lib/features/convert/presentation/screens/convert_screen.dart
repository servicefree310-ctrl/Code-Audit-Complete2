import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../../../../core/utils/formatters.dart';

class ConvertScreen extends ConsumerStatefulWidget {
  const ConvertScreen({super.key});

  @override
  ConsumerState<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends ConsumerState<ConvertScreen> {
  String _fromCoin = 'BTC';
  String _toCoin = 'USDT';
  final _amountCtrl = TextEditingController();
  Map<String, dynamic>? _preview;
  bool _isLoading = false;
  bool _isConverting = false;
  int _countdown = 0;

  Future<void> _getPreview() async {
    if (_amountCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(AppConstants.convertPreviewPath, data: {
        'fromCoin': _fromCoin,
        'toCoin': _toCoin,
        'fromAmount': double.tryParse(_amountCtrl.text) ?? 0,
      });
      setState(() { _preview = response.data as Map<String, dynamic>?; _isLoading = false; _countdown = 10; });
      _startCountdown();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      return _countdown > 0;
    });
  }

  Future<void> _convert() async {
    if (_preview == null) return;
    setState(() => _isConverting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(AppConstants.convertPath, data: {
        'quoteId': _preview?['quoteId'],
        'fromCoin': _fromCoin,
        'toCoin': _toCoin,
        'fromAmount': double.tryParse(_amountCtrl.text) ?? 0,
      });
      setState(() { _preview = null; _amountCtrl.clear(); });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversion successful!'), backgroundColor: AppColors.bullish));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversion failed.'), backgroundColor: AppColors.error));
    }
    setState(() => _isConverting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(
        title: 'Convert',
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
            label: Text('History', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // From
            _buildCoinInput(label: 'From', coin: _fromCoin, controller: _amountCtrl,
                onCoinTap: () {}),
            // Swap button
            Center(
              child: GestureDetector(
                onTap: () => setState(() { final tmp = _fromCoin; _fromCoin = _toCoin; _toCoin = tmp; }),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                ),
              ),
            ),
            // To
            _buildCoinInput(label: 'To', coin: _toCoin, readOnly: true,
                amountText: _preview != null ? Formatters.price((_preview!['toAmount'] as num?)?.toDouble() ?? 0) : '--',
                onCoinTap: () {}),
            const SizedBox(height: 20),
            if (_preview != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    _PreviewRow(label: 'Rate',
                        value: '1 $_fromCoin ≈ ${Formatters.price((_preview!['rate'] as num?)?.toDouble() ?? 0)} $_toCoin'),
                    _PreviewRow(label: 'Fee', value: '${_preview?['fee'] ?? 0} $_fromCoin'),
                    _PreviewRow(label: 'Rate valid', value: '$_countdown seconds'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ZebButton(
                label: _countdown > 0 ? 'Convert (Rate valid: ${_countdown}s)' : 'Refresh Rate',
                onPressed: _countdown > 0 ? _convert : _getPreview,
                isLoading: _isConverting,
              ),
            ] else
              ZebButton(label: 'Get Quote', onPressed: _getPreview, isLoading: _isLoading),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinInput({
    required String label, required String coin, TextEditingController? controller,
    bool readOnly = false, String? amountText, required VoidCallback onCoinTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: onCoinTap,
                child: Row(
                  children: [
                    CircleAvatar(radius: 14, backgroundColor: AppColors.surfaceLight,
                        child: Text(coin.substring(0, 1),
                            style: AppTextStyles.micro.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 6),
                    Text(coin, style: AppTextStyles.bodySemiBold),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const Spacer(),
              if (!readOnly && controller != null)
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.h4,
                    decoration: const InputDecoration(
                      border: InputBorder.none, enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none, contentPadding: EdgeInsets.zero,
                      hintText: '0.00',
                    ),
                  ),
                )
              else
                Text(amountText ?? '--', style: AppTextStyles.h4),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.caption),
          const Spacer(),
          Text(value, style: AppTextStyles.captionSemiBold),
        ],
      ),
    );
  }
}
