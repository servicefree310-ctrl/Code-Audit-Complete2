import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../../../core/utils/formatters.dart';

class CoinDetailScreen extends ConsumerStatefulWidget {
  final String symbol;
  const CoinDetailScreen({super.key, required this.symbol});

  @override
  ConsumerState<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends ConsumerState<CoinDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _coinData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchCoinDetail();
  }

  Future<void> _fetchCoinDetail() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('${AppConstants.coinDetailPath}/${widget.symbol}');
      setState(() { _coinData = response.data as Map<String, dynamic>?; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // API returns 'currentPrice' as a string and 'priceUsd' as double
    final price = double.tryParse(_coinData?['currentPrice']?.toString() ?? '')
        ?? (_coinData?['priceUsd'] as num?)?.toDouble()
        ?? 0.0;
    // API returns 'change24h', not 'changePercent'
    final change = (_coinData?['change24h'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.symbol, style: AppTextStyles.h5),
            Text(_coinData?['name']?.toString() ?? '',
                style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.star_border_rounded, color: AppColors.textSecondary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Formatters.price(price), style: AppTextStyles.price),
                          const SizedBox(height: 4),
                          PriceChangeBadge(change: change),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('24h High', style: AppTextStyles.micro),
                          Text(Formatters.price((_coinData?['high24h'] as num?)?.toDouble() ?? 0),
                              style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.bullish)),
                          const SizedBox(height: 4),
                          Text('24h Low', style: AppTextStyles.micro),
                          Text(Formatters.price((_coinData?['low24h'] as num?)?.toDouble() ?? 0),
                              style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.bearish)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Placeholder chart area
                Container(
                  height: 220,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor, width: 0.5),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.candlestick_chart_rounded, color: AppColors.textSecondary, size: 48),
                        const SizedBox(height: 8),
                        Text('Price Chart (TradingView)', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  tabs: const [Tab(text: 'Overview'), Tab(text: 'Order Book'), Tab(text: 'Trades'), Tab(text: 'Info')],
                  isScrollable: true,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverview(),
                      _buildOrderBook(),
                      _buildTrades(),
                      _buildInfo(),
                    ],
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildOverview() {
    final stats = [
      {'label': 'Market Cap', 'value': Formatters.compact((_coinData?['marketCap'] as num?)?.toDouble() ?? 0)},
      {'label': '24h Volume', 'value': Formatters.compact((_coinData?['volume24h'] as num?)?.toDouble() ?? 0)},
      {'label': 'Circulating Supply', 'value': Formatters.compact((_coinData?['circulatingSupply'] as num?)?.toDouble() ?? 0)},
      {'label': 'All Time High', 'value': '\$${Formatters.price((_coinData?['ath'] as num?)?.toDouble() ?? 0)}'},
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: stats.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Text(s['label']!, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            const Spacer(),
            Text(s['value']!, style: AppTextStyles.bodySemiBold),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildOrderBook() => const Center(child: Text('Order Book', style: AppTextStyles.caption));
  Widget _buildTrades() => const Center(child: Text('Recent Trades', style: AppTextStyles.caption));
  Widget _buildInfo() => const Center(child: Text('Coin Info', style: AppTextStyles.caption));

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.push('/spot/${widget.symbol}USDT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bullish,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Buy', style: AppTextStyles.button),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.push('/spot/${widget.symbol}USDT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bearish,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Sell', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}
