import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_card.dart';
import '../../../../core/widgets/zeb_logo.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _balanceVisible = true;
  final _scrollCtrl = ScrollController();
  bool _titleShrunk = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final shrunk = _scrollCtrl.offset > 80;
      if (shrunk != _titleShrunk) setState(() => _titleShrunk = shrunk);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.refresh(homeProvider.future),
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildPortfolioCard(homeState)),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildMarketTabBar()),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildMarketTickers(homeState)),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildSectionHeader('Top Gainers 🚀', onSeeAll: () => context.go('/markets'))),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildGainersList(homeState)),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildBannerCard()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildSectionHeader('Recent Activity', onSeeAll: () => context.go('/wallet'))),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildRecentTransactions(homeState)),
            SliverToBoxAdapter(child: const SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  // ── Sliver AppBar ────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      toolbarHeight: 60,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _titleShrunk
            ? const AppBarLogo(key: ValueKey('logo'))
            : Row(
                key: const ValueKey('greeting'),
                children: [
                  const AppBarLogo(),
                  const Spacer(),
                  _buildLiveBadge(),
                ],
              ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 22),
          onPressed: () => context.push('/markets'),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22),
              onPressed: () => context.push('/notifications'),
            ),
            Positioned(
              right: 10, top: 10,
              child: Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.bearish, shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bullish.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bullish.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(color: AppColors.bullish, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text('LIVE', style: AppTextStyles.micro.copyWith(color: AppColors.bullish, fontWeight: FontWeight.w700, fontSize: 10)),
        ],
      ),
    );
  }

  // ── Portfolio card ───────────────────────────────────────
  Widget _buildPortfolioCard(AsyncValue homeState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: FadeInDown(
        duration: const Duration(milliseconds: 600),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1C2236), Color(0xFF1A1F2C), Color(0xFF0F1318)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 40, spreadRadius: -5, offset: const Offset(0, 10)),
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: homeState.when(
            loading: () => _buildPortfolioSkeleton(),
            error: (_, __) => _buildPortfolioError(),
            data: (data) => _buildPortfolioData(data),
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioData(Map<String, dynamic> data) {
    final totalBalance = (data['totalBalance'] as num?)?.toDouble() ?? 0;
    final pnl = (data['todayPnl'] as num?)?.toDouble() ?? 0;
    final pnlPct = (data['todayPnlPercent'] as num?)?.toDouble() ?? 0;
    final isPositive = pnl >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Total Portfolio', style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary)),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _balanceVisible = !_balanceVisible);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary, size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Balance
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _balanceVisible
              ? Text('\$${Formatters.compact(totalBalance)}', key: const ValueKey('visible'), style: AppTextStyles.price.copyWith(fontSize: 36))
              : Text('••••••••', key: const ValueKey('hidden'), style: AppTextStyles.price.copyWith(fontSize: 36, color: AppColors.textSecondary)),
        ),

        const SizedBox(height: 8),

        // PNL row
        Row(
          children: [
            Text("Today's PnL  ", style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isPositive ? AppColors.bullish : AppColors.bearish).withOpacity(0.14),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: isPositive ? AppColors.bullish : AppColors.bearish,
                    size: 16,
                  ),
                  Text(
                    '${pnlPct.abs().toStringAsFixed(2)}%',
                    style: AppTextStyles.micro.copyWith(
                      color: isPositive ? AppColors.bullish : AppColors.bearish,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _balanceVisible ? '${isPositive ? '+' : '-'}\$${Formatters.price(pnl.abs())}' : '••••',
              style: AppTextStyles.caption.copyWith(color: isPositive ? AppColors.bullish : AppColors.bearish),
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(color: Colors.white10, height: 1),
        const SizedBox(height: 16),

        // Wallet chips
        Row(
          children: [
            _WalletChip(label: 'Spot', icon: Icons.account_balance_wallet_outlined,
                amount: (data['spotBalance'] as num?)?.toDouble() ?? 0, visible: _balanceVisible, color: AppColors.primary),
            const SizedBox(width: 10),
            _WalletChip(label: 'Futures', icon: Icons.trending_up_rounded,
                amount: (data['futuresBalance'] as num?)?.toDouble() ?? 0, visible: _balanceVisible, color: const Color(0xFF4A90E2)),
            const SizedBox(width: 10),
            _WalletChip(label: 'Earn', icon: Icons.savings_outlined,
                amount: (data['earnBalance'] as num?)?.toDouble() ?? 0, visible: _balanceVisible, color: AppColors.bullish),
          ],
        ),
      ],
    );
  }

  Widget _buildPortfolioSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmer(80, 12), const SizedBox(height: 14),
        _shimmer(200, 38), const SizedBox(height: 12),
        _shimmer(140, 18), const SizedBox(height: 20),
        Row(children: List.generate(3, (_) => Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _shimmer(double.infinity, 52),
        )))),
      ],
    );
  }

  Widget _buildPortfolioError() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.textHint, size: 32),
          const SizedBox(height: 8),
          Text('Could not load portfolio', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _shimmer(double w, double h) => Container(
    width: w, height: h,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // ── Quick actions ────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _QA(icon: Icons.arrow_downward_rounded,      label: 'Deposit',  color: AppColors.bullish,           route: '/deposit',       push: true),
      _QA(icon: Icons.arrow_upward_rounded,         label: 'Withdraw', color: AppColors.bearish,           route: '/withdraw',      push: true),
      _QA(icon: Icons.swap_horiz_rounded,           label: 'Transfer', color: const Color(0xFF4A90E2),     route: '/transfer',      push: true),
      _QA(icon: Icons.add_shopping_cart_rounded,    label: 'Buy',      color: AppColors.primary,           route: '/spot/BTCUSDT',  push: true),
      _QA(icon: Icons.currency_exchange_rounded,    label: 'Convert',  color: const Color(0xFFE67E22),     route: '/convert',       push: true),
      _QA(icon: Icons.people_alt_rounded,           label: 'P2P',      color: const Color(0xFF9B59B6),     route: '/p2p',           push: true),
      _QA(icon: Icons.auto_graph_rounded,           label: 'AI Trade', color: const Color(0xFF1DA2B4),     route: '/ai-trading',    push: true),
      _QA(icon: Icons.savings_outlined,             label: 'Earn',     color: const Color(0xFF27AE60),     route: '/earn',          push: true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FadeInUp(
        delay: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: actions.take(4).map(_buildQAItem).toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: actions.skip(4).map(_buildQAItem).toList(),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQAItem(_QA a) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (a.push) { context.push(a.route); } else { context.go(a.route); }
      },
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: a.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: a.color.withOpacity(0.18)),
              ),
              child: Icon(a.icon, color: a.color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(a.label, style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary, fontSize: 10.5), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Market tab bar ───────────────────────────────────────
  Widget _buildMarketTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('Markets', style: AppTextStyles.h5),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go('/markets'),
            child: Text('See all →', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ── Market tickers ───────────────────────────────────────
  Widget _buildMarketTickers(AsyncValue homeState) {
    return SizedBox(
      height: 108,
      child: homeState.when(
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => _shimmerCard(130, 108),
        ),
        error: (_, __) => const SizedBox(),
        data: (data) {
          final tickers = (data['tickers'] as List?)?.cast<Map<String, dynamic>>() ?? _mockTickers;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tickers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _TickerCard(ticker: tickers[i]),
          );
        },
      ),
    );
  }

  // ── Section header ───────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.h5),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text('See all →', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  // ── Gainers list ────────────────────────────────────────
  Widget _buildGainersList(AsyncValue homeState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: homeState.when(
        loading: () => Column(children: List.generate(4, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _shimmerCard(double.infinity, 64),
        ))),
        error: (_, __) => const SizedBox(),
        data: (data) {
          final gainers = (data['gainers'] as List?)?.cast<Map<String, dynamic>>() ?? _mockGainers;
          return Column(
            children: gainers.take(5).map((c) => _CoinListItem(
              coin: c,
              onTap: () => context.push('/coin/${c['symbol']}'),
            )).toList(),
          );
        },
      ),
    );
  }

  // ── Promo banner ────────────────────────────────────────
  Widget _buildBannerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FadeInLeft(
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A2A1A), Color(0xFF0B1A14)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bullish.withOpacity(0.2)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10, bottom: -20,
                child: Icon(Icons.percent_rounded, size: 100, color: AppColors.bullish.withOpacity(0.06)),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.bullish.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('LIMITED OFFER', style: AppTextStyles.micro.copyWith(color: AppColors.bullish, fontWeight: FontWeight.w700, fontSize: 9)),
                          ),
                          const SizedBox(height: 6),
                          Text('Zero fees on USDT deposits', style: AppTextStyles.bodySemiBold),
                          Text('For Verified users. Ends soon.', style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/deposit'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.bullish,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Claim', style: AppTextStyles.captionSemiBold.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Recent transactions ─────────────────────────────────
  Widget _buildRecentTransactions(AsyncValue homeState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: homeState.when(
        loading: () => Column(children: List.generate(3, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _shimmerCard(double.infinity, 64),
        ))),
        error: (_, __) => const SizedBox(),
        data: (data) {
          final txs = (data['recentTransactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          if (txs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textHint),
                    const SizedBox(height: 10),
                    Text('No recent transactions', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
            );
          }
          return Column(children: txs.take(5).map((tx) => _TransactionItem(tx: tx)).toList());
        },
      ),
    );
  }

  Widget _shimmerCard(double w, double h) => Container(
    width: w, height: h,
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
  );

  final _mockTickers = [
    {'symbol': 'BTC', 'price': 67234.50, 'changePercent': 2.34},
    {'symbol': 'ETH', 'price': 3421.80, 'changePercent': -1.22},
    {'symbol': 'BNB', 'price': 598.40, 'changePercent': 0.87},
    {'symbol': 'SOL', 'price': 178.20, 'changePercent': 5.12},
    {'symbol': 'XRP', 'price': 0.621, 'changePercent': -0.45},
  ];

  final _mockGainers = [
    {'symbol': 'PEPE', 'name': 'Pepe', 'price': 0.0000123, 'changePercent': 28.4},
    {'symbol': 'WIF', 'name': 'dogwifhat', 'price': 3.21, 'changePercent': 15.6},
    {'symbol': 'BONK', 'name': 'Bonk', 'price': 0.0000278, 'changePercent': 12.3},
    {'symbol': 'FET', 'name': 'Fetch.ai', 'price': 2.14, 'changePercent': 9.8},
    {'symbol': 'RNDR', 'name': 'Render', 'price': 9.45, 'changePercent': 7.2},
  ];
}

// ─── Sub-widgets ──────────────────────────────────────────────

class _QA {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final bool push;
  const _QA({
    required this.icon, required this.label,
    required this.color, required this.route,
    this.push = false,
  });
}

class _WalletChip extends StatelessWidget {
  final String label; final IconData icon; final double amount; final bool visible; final Color color;
  const _WalletChip({required this.label, required this.icon, required this.amount, required this.visible, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 4),
          Text(
            visible ? '\$${Formatters.compact(amount)}' : '••••',
            style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.textPrimary, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _TickerCard extends StatelessWidget {
  final Map<String, dynamic> ticker;
  const _TickerCard({required this.ticker});

  @override
  Widget build(BuildContext context) {
    final change = (ticker['changePercent'] as num?)?.toDouble() ?? 0;
    final isUp = change >= 0;
    final price = (ticker['price'] as num?)?.toDouble() ?? 0;
    return GestureDetector(
      onTap: () => context.push('/coin/${ticker['symbol']}'),
      child: Container(
        width: 132,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: (isUp ? AppColors.bullish : AppColors.bearish).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      ticker['symbol']?.toString().substring(0, 1) ?? '?',
                      style: TextStyle(
                        color: isUp ? AppColors.bullish : AppColors.bearish,
                        fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(ticker['symbol']?.toString() ?? '', style: AppTextStyles.captionSemiBold, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('\$${Formatters.price(price)}', style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: (isUp ? AppColors.bullish : AppColors.bearish).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: isUp ? AppColors.bullish : AppColors.bearish, size: 14,
                  ),
                  Text(
                    '${change.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isUp ? AppColors.bullish : AppColors.bearish,
                      fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinListItem extends StatelessWidget {
  final Map<String, dynamic> coin; final VoidCallback onTap;
  const _CoinListItem({required this.coin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final change = (coin['changePercent'] as num?)?.toDouble() ?? 0;
    final isUp = change >= 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (isUp ? AppColors.bullish : AppColors.bearish).withOpacity(0.2),
                    (isUp ? AppColors.bullish : AppColors.bearish).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  coin['symbol']?.toString().substring(0, 1) ?? '?',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w800,
                    color: isUp ? AppColors.bullish : AppColors.bearish,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coin['symbol']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
                  Text(coin['name']?.toString() ?? '', style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${Formatters.price((coin['price'] as num?)?.toDouble() ?? 0)}', style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isUp ? AppColors.bullish : AppColors.bearish).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${isUp ? '+' : ''}${change.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w700,
                      color: isUp ? AppColors.bullish : AppColors.bearish,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _TransactionItem({required this.tx});

  @override
  Widget build(BuildContext context) {
    final type = tx['type']?.toString() ?? 'Transfer';
    final isDebit = type.toLowerCase().contains('withdraw') || type.toLowerCase().contains('sell');
    final color = isDebit ? AppColors.bearish : AppColors.bullish;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color, size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: AppTextStyles.bodySemiBold),
                Text(
                  Formatters.relativeTime(DateTime.tryParse(tx['createdAt']?.toString() ?? '') ?? DateTime.now()),
                  style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDebit ? '-' : '+'}\$${Formatters.price((tx['amount'] as num?)?.toDouble() ?? 0)}',
                style: AppTextStyles.bodySemiBold.copyWith(color: color),
              ),
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  tx['status']?.toString() ?? 'Completed',
                  style: AppTextStyles.micro.copyWith(color: AppColors.textHint, fontSize: 9.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
