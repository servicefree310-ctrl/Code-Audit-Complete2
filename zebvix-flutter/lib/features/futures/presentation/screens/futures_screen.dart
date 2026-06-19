import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../../../core/utils/formatters.dart';

class FuturesScreen extends ConsumerStatefulWidget {
  final String pair;
  const FuturesScreen({super.key, required this.pair});

  @override
  ConsumerState<FuturesScreen> createState() => _FuturesScreenState();
}

class _FuturesScreenState extends ConsumerState<FuturesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _marginType = 'Cross';
  int _leverage = 10;
  bool _isBuy = true;
  String _orderType = 'Market';
  final _amountCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _isSubmitting = false;
  Map<String, dynamic>? _ticker;
  List<Map<String, dynamic>> _positions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final dio = ref.read(dioProvider);
      final results = await Future.wait([
        dio.get('${AppConstants.tickerPath}/${widget.pair}').catchError((_) => null),
        dio.get(AppConstants.futuresPositionsPath).catchError((_) => null),
      ]);
      setState(() {
        _ticker = results[0]?.data as Map<String, dynamic>?;
        final pos = results[1]?.data;
        if (pos is List) _positions = pos.cast<Map<String, dynamic>>();
      });
    } catch (_) {}
  }

  Future<void> _placeOrder() async {
    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(AppConstants.futuresOrderPath, data: {
        'symbol': widget.pair,
        'side': _isBuy ? 'BUY' : 'SELL',
        'type': _orderType.toUpperCase(),
        'quantity': double.tryParse(_amountCtrl.text) ?? 0,
        'leverage': _leverage,
        'marginType': _marginType.toUpperCase(),
        if (_orderType == 'Limit') 'price': double.tryParse(_priceCtrl.text) ?? 0,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position opened!'), backgroundColor: AppColors.bullish));
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order failed.'), backgroundColor: AppColors.error));
    }
    setState(() => _isSubmitting = false);
  }

  @override
  void dispose() { _tabController.dispose(); _amountCtrl.dispose(); _priceCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final price = (_ticker?['price'] as num?)?.toDouble() ?? 0;
    final change = (_ticker?['changePercent'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => context.pop()),
        title: Row(
          children: [
            Text(widget.pair, style: AppTextStyles.h5),
            const SizedBox(width: 8),
            PriceChangeBadge(change: change),
          ],
        ),
        actions: [
          // Margin type toggle
          GestureDetector(
            onTap: () => setState(() => _marginType = _marginType == 'Cross' ? 'Isolated' : 'Cross'),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_marginType, style: AppTextStyles.micro.copyWith(color: AppColors.primary)),
            ),
          ),
          // Leverage
          GestureDetector(
            onTap: _showLeverageSheet,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${_leverage}x', style: AppTextStyles.micro.copyWith(color: AppColors.warning)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surface,
            child: Row(
              children: [
                Text('\$${Formatters.price(price)}',
                    style: AppTextStyles.h4.copyWith(color: change >= 0 ? AppColors.bullish : AppColors.bearish)),
                const SizedBox(width: 8),
                Text('Mark: \$${Formatters.price((_ticker?['markPrice'] as num?)?.toDouble() ?? price)}',
                    style: AppTextStyles.micro),
                const Spacer(),
                Text('Funding: ${(_ticker?['fundingRate']?.toString() ?? '0.01')}%',
                    style: AppTextStyles.micro.copyWith(color: AppColors.warning)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Order book placeholder
                Container(
                  width: 120,
                  color: AppColors.background,
                  child: const Center(child: Text('Order Book', style: AppTextStyles.micro)),
                ),
                Container(width: 0.5, color: AppColors.borderColor),
                Expanded(child: _buildOrderPanel()),
              ],
            ),
          ),
          // Positions tab
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Positions (${_positions.length})'),
                    const Tab(text: 'Open Orders'),
                    const Tab(text: 'History'),
                    const Tab(text: 'Trade History'),
                  ],
                  isScrollable: true,
                ),
                SizedBox(
                  height: 160,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPositions(),
                      const Center(child: Text('No open orders', style: AppTextStyles.caption)),
                      const Center(child: Text('History', style: AppTextStyles.caption)),
                      const Center(child: Text('Trade History', style: AppTextStyles.caption)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: ['Market', 'Limit', 'Stop Market'].map((t) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() => _orderType = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _orderType == t ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _orderType == t ? AppColors.primary : AppColors.borderColor),
                  ),
                  child: Text(t, style: AppTextStyles.micro.copyWith(
                    color: _orderType == t ? AppColors.primary : AppColors.textSecondary)),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _isBuy = true),
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: _isBuy ? AppColors.bullish : AppColors.surfaceLight,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                  child: Center(child: Text('Long', style: AppTextStyles.captionSemiBold.copyWith(
                    color: _isBuy ? Colors.white : AppColors.textSecondary))),
                ),
              )),
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _isBuy = false),
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: !_isBuy ? AppColors.bearish : AppColors.surfaceLight,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                  ),
                  child: Center(child: Text('Short', style: AppTextStyles.captionSemiBold.copyWith(
                    color: !_isBuy ? Colors.white : AppColors.textSecondary))),
                ),
              )),
            ],
          ),
          const SizedBox(height: 10),
          if (_orderType == 'Limit') ...[
            TextField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(labelText: 'Price (USDT)', suffixText: 'USDT'),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(labelText: 'Quantity (Cont)', suffixText: 'CONT'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Avail: -- USDT', style: AppTextStyles.micro),
              const Spacer(),
              Text('Liq.Price: --', style: AppTextStyles.micro),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBuy ? AppColors.bullish : AppColors.bearish,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text('${_isBuy ? 'Long' : 'Short'} ${_leverage}x', style: AppTextStyles.button),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _TpSlChip(label: 'TP', onTap: () {}),
              const SizedBox(width: 8),
              _TpSlChip(label: 'SL', onTap: () {}),
              const SizedBox(width: 8),
              _TpSlChip(label: 'Reduce Only', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPositions() {
    if (_positions.isEmpty) {
      return const Center(child: Text('No open positions', style: AppTextStyles.caption));
    }
    return ListView.builder(
      itemCount: _positions.length,
      itemBuilder: (_, i) {
        final pos = _positions[i];
        final pnl = (pos['unrealizedPnl'] as num?)?.toDouble() ?? 0;
        return ListTile(
          dense: true,
          title: Text(pos['symbol']?.toString() ?? '', style: AppTextStyles.captionSemiBold),
          subtitle: Text('${pos['size']} @ ${pos['entryPrice']}', style: AppTextStyles.micro),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\$${Formatters.price(pnl.abs())}',
                  style: AppTextStyles.captionSemiBold.copyWith(color: pnl >= 0 ? AppColors.bullish : AppColors.bearish)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 20)),
                child: Text('Close', style: AppTextStyles.micro.copyWith(color: AppColors.bearish)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLeverageSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Leverage: ${_leverage}x', style: AppTextStyles.h4),
              Slider(
                value: _leverage.toDouble(),
                min: 1, max: 125,
                onChanged: (v) { setSheetState(() => _leverage = v.toInt()); setState(() {}); },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['1x', '10x', '25x', '50x', '100x', '125x'].map((v) => GestureDetector(
                  onTap: () { setSheetState(() => _leverage = int.parse(v.replaceAll('x', ''))); setState(() {}); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(v, style: AppTextStyles.micro),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TpSlChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TpSlChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: AppTextStyles.micro),
      ),
    );
  }
}
