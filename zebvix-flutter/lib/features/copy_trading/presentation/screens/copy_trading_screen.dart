import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/utils/formatters.dart';

class CopyTradingScreen extends ConsumerStatefulWidget {
  const CopyTradingScreen({super.key});

  @override
  ConsumerState<CopyTradingScreen> createState() => _CopyTradingScreenState();
}

class _CopyTradingScreenState extends ConsumerState<CopyTradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _traders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTraders();
  }

  Future<void> _fetchTraders() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(AppConstants.copyTradersPath);
      final data = response.data;
      setState(() {
        if (data is List) _traders = data.cast<Map<String, dynamic>>();
        else if (data is Map && data['data'] is List) _traders = (data['data'] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _followTrader(String traderId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post(AppConstants.copyFollowPath, data: {'traderId': traderId});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Now following trader!'), backgroundColor: AppColors.bullish));
    } catch (_) {}
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(
        title: 'Copy Trading',
        actions: [
          IconButton(icon: const Icon(Icons.leaderboard_rounded, color: AppColors.textSecondary), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Top Traders'), Tab(text: 'Following'), Tab(text: 'My Copy')],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTraderList(_traders),
                      _buildFollowing(),
                      _buildMyCopy(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraderList(List<Map<String, dynamic>> traders) {
    if (traders.isEmpty) return const Center(child: Text('No traders found', style: AppTextStyles.caption));
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchTraders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: traders.length,
        itemBuilder: (_, i) => _TraderCard(
          trader: traders[i],
          onFollow: () => _followTrader(traders[i]['id']?.toString() ?? ''),
        ),
      ),
    );
  }

  Widget _buildFollowing() {
    return FutureBuilder(
      future: ref.read(dioProvider).get(AppConstants.copyPortfolioPath),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final data = (snapshot.data?.data as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (data.isEmpty) return const Center(child: Text('Not following any traders yet', style: AppTextStyles.caption));
        return _buildTraderList(data);
      },
    );
  }

  Widget _buildMyCopy() {
    return FutureBuilder(
      future: ref.read(dioProvider).get(AppConstants.copyHistoryPath),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final data = (snapshot.data?.data as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (data.isEmpty) return const Center(child: Text('No copy trading history', style: AppTextStyles.caption));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (_, i) {
            final trade = data[i];
            final pnl = (trade['pnl'] as num?)?.toDouble() ?? 0;
            return ListTile(
              title: Text(trade['symbol']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
              subtitle: Text('Copied from: ${trade['traderName'] ?? '--'}', style: AppTextStyles.micro),
              trailing: Text('${pnl >= 0 ? '+' : ''}\$${Formatters.price(pnl.abs())}',
                  style: AppTextStyles.captionSemiBold.copyWith(color: pnl >= 0 ? AppColors.bullish : AppColors.bearish)),
            );
          },
        );
      },
    );
  }
}

class _TraderCard extends StatelessWidget {
  final Map<String, dynamic> trader;
  final VoidCallback onFollow;
  const _TraderCard({required this.trader, required this.onFollow});

  @override
  Widget build(BuildContext context) {
    final roi = (trader['roi'] as num?)?.toDouble() ?? 0;
    final winRate = (trader['winRate'] as num?)?.toDouble() ?? 0;
    final followers = trader['followers'] ?? 0;
    final isFollowing = trader['isFollowing'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text((trader['name']?.toString() ?? 'T').substring(0, 1).toUpperCase(),
                    style: AppTextStyles.h5.copyWith(color: AppColors.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(trader['name']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, size: 14, color: AppColors.info),
                ]),
                Text('$followers followers', style: AppTextStyles.micro),
              ])),
              ElevatedButton(
                onPressed: isFollowing ? null : onFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? AppColors.surfaceLight : AppColors.primary,
                  foregroundColor: isFollowing ? AppColors.textSecondary : AppColors.textDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: Text(isFollowing ? 'Following' : 'Copy', style: AppTextStyles.captionSemiBold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MetricChip(label: 'ROI', value: '${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(2)}%',
                  color: roi >= 0 ? AppColors.bullish : AppColors.bearish),
              const SizedBox(width: 12),
              _MetricChip(label: 'Win Rate', value: '${winRate.toStringAsFixed(1)}%', color: AppColors.primary),
              const SizedBox(width: 12),
              _MetricChip(label: '30d Trades', value: '${trader['trades30d'] ?? 0}', color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.micro),
        Text(value, style: AppTextStyles.captionSemiBold.copyWith(color: color)),
      ],
    );
  }
}
