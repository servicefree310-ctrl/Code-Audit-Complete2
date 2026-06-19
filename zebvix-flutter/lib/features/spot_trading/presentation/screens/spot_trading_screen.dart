import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../../../core/utils/formatters.dart';

class SpotTradingScreen extends ConsumerStatefulWidget {
  final String pair;
  const SpotTradingScreen({super.key, required this.pair});

  @override
  ConsumerState<SpotTradingScreen> createState() => _SpotTradingScreenState();
}

class _SpotTradingScreenState extends ConsumerState<SpotTradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _orderType = 'Limit';
  bool _isBuy = true;
  final _priceCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  double _sliderValue = 0.0;
  bool _isSubmitting = false;
  Map<String, dynamic>? _ticker;

  // FIX: Separate real order book lists (bids + asks from API)
  List<Map<String, dynamic>> _asks = [];
  List<Map<String, dynamic>> _bids = [];
  bool _isOrderBookLoading = true;

  List<Map<String, dynamic>> _openOrders = [];
  bool _isLoading = true;
  double _availableBalance = 0;

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
        // Ticker: /v1/ticker/:symbol does not exist — use markets search instead
        dio.get(AppConstants.marketsPath, queryParameters: {'search': widget.pair, 'limit': 1})
            .catchError((_) => null),
        // Orderbook: uses query param ?symbol=, NOT path param /symbol
        dio.get(AppConstants.orderBookPath, queryParameters: {'symbol': widget.pair, 'limit': 10})
            .catchError((_) => null),
        dio.get(AppConstants.spotOpenOrdersPath, queryParameters: {'symbol': widget.pair})
            .catchError((_) => null),
        dio.get(AppConstants.walletBalancePath, queryParameters: {'coin': 'USDT'})
            .catchError((_) => null),
      ]);

      setState(() {
        // Markets search returns {"markets": [...]} — normalize first item
        // to include 'price' and 'changePercent' keys the UI expects
        final marketData = results[0]?.data as Map<String, dynamic>?;
        final market = (marketData?['markets'] as List?)
            ?.cast<Map<String, dynamic>?>()
            .whereType<Map<String, dynamic>>()
            .where((m) => m['symbol'] == widget.pair)
            .firstOrNull;
        if (market != null) {
          _ticker = {
            ...market,
            'price': market['lastPrice'],           // normalize: lastPrice → price
            'changePercent': market['change24h'],    // normalize: change24h → changePercent
          };
        }

        // Orderbook: {"symbol","bids":[{price,qty}],"asks":[{price,qty}]}
        final obData = results[1]?.data;
        if (obData is Map<String, dynamic>) {
          final rawAsks = obData['asks'] as List?;
          final rawBids = obData['bids'] as List?;
          _asks = rawAsks?.cast<Map<String, dynamic>>() ?? [];
          _bids = rawBids?.cast<Map<String, dynamic>>() ?? [];
        }
        _isOrderBookLoading = false;

        final ordersData = results[2]?.data;
        if (ordersData is List) _openOrders = ordersData.cast<Map<String, dynamic>>();

        final balanceData = results[3]?.data as Map<String, dynamic>?;
        _availableBalance = (balanceData?['available'] as num?)?.toDouble() ?? 0;

        _isLoading = false;
        if (_ticker != null && _priceCtrl.text.isEmpty) {
          _priceCtrl.text = Formatters.price((_ticker!['price'] as num?)?.toDouble() ?? 0);
        }
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _isOrderBookLoading = false;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_priceCtrl.text.isEmpty || _amountCtrl.text.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(AppConstants.spotOrderPath, data: {
        'symbol': widget.pair,
        'side': _isBuy ? 'BUY' : 'SELL',
        'type': _orderType.toUpperCase().replaceAll(' ', '_'),
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'quantity': double.tryParse(_amountCtrl.text) ?? 0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: AppColors.bullish,
          ),
        );
        _amountCtrl.clear();
        _sliderValue = 0;
        _fetchData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _priceCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = (_ticker?['price'] as num?)?.toDouble() ?? 0;
    final change = (_ticker?['changePercent'] as num?)?.toDouble() ?? 0;
    final baseAsset = widget.pair.replaceAll('USDT', '').replaceAll('BTC', '');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Text(widget.pair, style: AppTextStyles.h5),
            const SizedBox(width: 8),
            PriceChangeBadge(change: change),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.candlestick_chart_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Price strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surface,
            child: Row(
              children: [
                Text(
                  '\$${Formatters.price(price)}',
                  style: AppTextStyles.h4.copyWith(
                    color: change >= 0 ? AppColors.bullish : AppColors.bearish,
                  ),
                ),
                const Spacer(),
                _StatChip(label: '24h', value: Formatters.percent(change)),
                const SizedBox(width: 12),
                _StatChip(
                    label: 'High',
                    value: Formatters.price((_ticker?['high24h'] as num?)?.toDouble() ?? 0)),
                const SizedBox(width: 12),
                _StatChip(
                    label: 'Low',
                    value: Formatters.price((_ticker?['low24h'] as num?)?.toDouble() ?? 0)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // FIX: Real order book data from API
                SizedBox(width: 130, child: _buildOrderBook(price)),
                Container(width: 0.5, color: AppColors.borderColor),
                Expanded(child: _buildTradePanel(baseAsset)),
              ],
            ),
          ),
          // Bottom tabs
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Open Orders (${_openOrders.length})'),
                    const Tab(text: 'History'),
                    const Tab(text: 'Trade History'),
                  ],
                  isScrollable: true,
                ),
                SizedBox(
                  height: 180,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOpenOrders(),
                      const Center(
                          child: Text('Order History', style: AppTextStyles.caption)),
                      const Center(
                          child: Text('Trade History', style: AppTextStyles.caption)),
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

  // FIX: Uses real bids/asks from API — no more hardcoded generated data
  Widget _buildOrderBook(double lastPrice) {
    if (_isOrderBookLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      );
    }

    final displayAsks = _asks.take(10).toList();
    final displayBids = _bids.take(10).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Text('Price', style: AppTextStyles.micro),
              const Spacer(),
              Text('Amount', style: AppTextStyles.micro),
            ],
          ),
        ),
        Expanded(
          child: displayAsks.isEmpty
              ? const Center(
                  child: Text('No asks', style: AppTextStyles.micro))
              : ListView.builder(
                  itemCount: displayAsks.length,
                  reverse: true,
                  itemBuilder: (_, i) {
                    final ask = displayAsks[i];
                    return _OrderBookRow(
                      price: double.tryParse(ask['price']?.toString() ?? '0') ?? 0,
                      amount: double.tryParse(ask['quantity']?.toString() ?? ask['amount']?.toString() ?? '0') ?? 0,
                      isBid: false,
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            '\$${Formatters.price(lastPrice)}',
            style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.bullish),
          ),
        ),
        Expanded(
          child: displayBids.isEmpty
              ? const Center(
                  child: Text('No bids', style: AppTextStyles.micro))
              : ListView.builder(
                  itemCount: displayBids.length,
                  itemBuilder: (_, i) {
                    final bid = displayBids[i];
                    return _OrderBookRow(
                      price: double.tryParse(bid['price']?.toString() ?? '0') ?? 0,
                      amount: double.tryParse(bid['quantity']?.toString() ?? bid['amount']?.toString() ?? '0') ?? 0,
                      isBid: true,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTradePanel(String baseAsset) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order type selector
          Row(
            children: ['Limit', 'Market', 'Stop Limit'].map((type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _orderType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _orderType == type
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _orderType == type ? AppColors.primary : AppColors.borderColor,
                    ),
                  ),
                  child: Text(
                    type,
                    style: AppTextStyles.micro.copyWith(
                      color: _orderType == type
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: _orderType == type ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),

          // Buy/Sell toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isBuy = true),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: _isBuy ? AppColors.bullish : AppColors.surfaceLight,
                      borderRadius:
                          const BorderRadius.horizontal(left: Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text(
                        'Buy',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          color: _isBuy ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isBuy = false),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: !_isBuy ? AppColors.bearish : AppColors.surfaceLight,
                      borderRadius:
                          const BorderRadius.horizontal(right: Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text(
                        'Sell',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          color: !_isBuy ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_orderType != 'Market') ...[
            TextField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Price (USDT)',
                suffixText: 'USDT',
              ),
            ),
            const SizedBox(height: 10),
          ],

          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyMedium,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Amount',
              suffixText: baseAsset,
            ),
          ),
          const SizedBox(height: 10),

          // Percentage slider
          Slider(
            value: _sliderValue,
            onChanged: (v) {
              setState(() {
                _sliderValue = v;
                if (_availableBalance > 0) {
                  final price = double.tryParse(_priceCtrl.text) ?? 0;
                  if (price > 0 && _isBuy) {
                    final qty = (_availableBalance * v) / price;
                    _amountCtrl.text = qty.toStringAsFixed(6);
                  } else if (!_isBuy) {
                    _amountCtrl.text = (_availableBalance * v).toStringAsFixed(6);
                  }
                }
              });
            },
            divisions: 4,
            label: '${(_sliderValue * 100).toInt()}%',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['0%', '25%', '50%', '75%', '100%'].map((p) {
              final pct = int.parse(p.replaceAll('%', '')) / 100;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _sliderValue = pct;
                    if (_availableBalance > 0) {
                      final price = double.tryParse(_priceCtrl.text) ?? 0;
                      if (price > 0 && _isBuy) {
                        final qty = (_availableBalance * pct) / price;
                        _amountCtrl.text = qty.toStringAsFixed(6);
                      } else if (!_isBuy) {
                        _amountCtrl.text = (_availableBalance * pct).toStringAsFixed(6);
                      }
                    }
                  });
                },
                child: Text(
                  p,
                  style: AppTextStyles.micro.copyWith(
                    color: _sliderValue == pct ? AppColors.primary : AppColors.textHint,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Text('Avail: ', style: AppTextStyles.micro),
              Text(
                _isLoading
                    ? '--'
                    : '${_availableBalance.toStringAsFixed(4)} ${_isBuy ? 'USDT' : baseAsset}',
                style: AppTextStyles.micro.copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              Text('Fee: 0.1%', style: AppTextStyles.micro),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size.fromHeight(44),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      '${_isBuy ? 'Buy' : 'Sell'} $baseAsset',
                      style: AppTextStyles.button,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenOrders() {
    if (_openOrders.isEmpty) {
      return const Center(
          child: Text('No open orders', style: AppTextStyles.caption));
    }
    return ListView.builder(
      itemCount: _openOrders.length,
      itemBuilder: (_, i) {
        final order = _openOrders[i];
        final isBuy = order['side']?.toString().toUpperCase() == 'BUY';
        return ListTile(
          dense: true,
          title: Row(
            children: [
              Text(order['symbol']?.toString() ?? '', style: AppTextStyles.captionSemiBold),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isBuy ? AppColors.bullish : AppColors.bearish).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isBuy ? 'BUY' : 'SELL',
                  style: AppTextStyles.micro.copyWith(
                      color: isBuy ? AppColors.bullish : AppColors.bearish),
                ),
              ),
            ],
          ),
          subtitle: Text(
              '${order['quantity']} @ ${order['price']}',
              style: AppTextStyles.micro),
          trailing: IconButton(
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
            onPressed: () => _cancelOrder(order['id']?.toString() ?? ''),
          ),
        );
      },
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('${AppConstants.spotCancelOrderPath}/$orderId');
      _fetchData();
    } catch (_) {}
  }
}

class _OrderBookRow extends StatelessWidget {
  final double price;
  final double amount;
  final bool isBid;
  const _OrderBookRow(
      {required this.price, required this.amount, required this.isBid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Text(
            Formatters.price(price),
            style: AppTextStyles.micro.copyWith(
                color: isBid ? AppColors.bullish : AppColors.bearish),
          ),
          const Spacer(),
          Text(Formatters.compact(amount), style: AppTextStyles.micro),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.micro),
        Text(value,
            style: AppTextStyles.micro.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}
