import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_shimmer.dart';
import '../../../../core/utils/formatters.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _balanceVisible = true;
  bool _isLoading = true;
  Map<String, dynamic>? _walletData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchWallet();
  }

  Future<void> _fetchWallet() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(AppConstants.walletOverviewPath);
      setState(() { _walletData = response.data as Map<String, dynamic>?; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final totalBalance = (_walletData?['totalBalance'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchWallet,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              floating: true,
              automaticallyImplyLeading: false,
              title: Text('Wallet', style: AppTextStyles.h4),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.textSecondary),
                  onPressed: () => context.push('/bank'),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildTotalBalance(totalBalance),
                  _buildActions(),
                  _buildTabBar(),
                ],
              ),
            ),
            SliverFillRemaining(
              child: _isLoading
                  ? const ZebShimmerList()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAssetList('spot'),
                        _buildAssetList('funding'),
                        _buildAssetList('earn'),
                        _buildAssetList('futures'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalance(double total) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Total Balance (USDT)', style: AppTextStyles.caption),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary, size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _balanceVisible ? '\$${Formatters.compact(total)}' : '••••••••',
            style: AppTextStyles.price,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BalanceChip(label: 'Spot', amount: (_walletData?['spot'] as num?)?.toDouble() ?? 0, visible: _balanceVisible),
              _BalanceChip(label: 'Funding', amount: (_walletData?['funding'] as num?)?.toDouble() ?? 0, visible: _balanceVisible),
              _BalanceChip(label: 'Earn', amount: (_walletData?['earn'] as num?)?.toDouble() ?? 0, visible: _balanceVisible),
              _BalanceChip(label: 'Futures', amount: (_walletData?['futures'] as num?)?.toDouble() ?? 0, visible: _balanceVisible),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final actions = [
      {'label': 'Deposit', 'icon': Icons.arrow_downward_rounded, 'color': AppColors.bullish, 'route': '/deposit'},
      {'label': 'Withdraw', 'icon': Icons.arrow_upward_rounded, 'color': AppColors.bearish, 'route': '/withdraw'},
      {'label': 'Transfer', 'icon': Icons.swap_horiz_rounded, 'color': AppColors.info, 'route': '/transfer'},
      {'label': 'Convert', 'icon': Icons.currency_exchange_rounded, 'color': AppColors.warning, 'route': '/convert'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) => GestureDetector(
          onTap: () => context.push(a['route'] as String),
          child: Column(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: (a['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(a['label'] as String, style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TabBar(
        controller: _tabController,
        tabs: const [Tab(text: 'Spot'), Tab(text: 'Funding'), Tab(text: 'Earn'), Tab(text: 'Futures')],
      ),
    );
  }

  Widget _buildAssetList(String type) {
    final assets = (_walletData?['assets'] as List?)
        ?.where((a) => (a as Map)['walletType'] == type)
        .cast<Map<String, dynamic>>()
        .toList() ?? [];

    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, color: AppColors.textHint, size: 48),
            const SizedBox(height: 8),
            Text('No assets in $type wallet', style: AppTextStyles.caption),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assets.length,
      itemBuilder: (_, i) => _AssetItem(
        asset: assets[i],
        onDeposit: () => context.push('/deposit', extra: {'coin': assets[i]['symbol']}),
        onWithdraw: () => context.push('/withdraw', extra: {'coin': assets[i]['symbol']}),
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final String label;
  final double amount;
  final bool visible;
  const _BalanceChip({required this.label, required this.amount, required this.visible});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.micro),
        const SizedBox(height: 2),
        Text(visible ? Formatters.compact(amount) : '••',
            style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _AssetItem extends StatelessWidget {
  final Map<String, dynamic> asset;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  const _AssetItem({required this.asset, required this.onDeposit, required this.onWithdraw});

  @override
  Widget build(BuildContext context) {
    final balance = (asset['balance'] as num?)?.toDouble() ?? 0;
    final usdValue = (asset['usdValue'] as num?)?.toDouble() ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceLight,
            child: Text(
              (asset['symbol']?.toString() ?? '?').substring(0, 1),
              style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset['symbol']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
                Text(asset['name']?.toString() ?? '', style: AppTextStyles.micro),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.crypto(balance, asset['symbol']?.toString() ?? ''),
                  style: AppTextStyles.bodySemiBold),
              Text('\$${Formatters.compact(usdValue)}', style: AppTextStyles.micro),
            ],
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              GestureDetector(
                onTap: onDeposit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.bullish),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Deposit', style: AppTextStyles.micro.copyWith(color: AppColors.bullish)),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onWithdraw,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.bearish),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Withdraw', style: AppTextStyles.micro.copyWith(color: AppColors.bearish)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
