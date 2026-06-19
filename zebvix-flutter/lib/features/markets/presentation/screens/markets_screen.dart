import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_shimmer.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/markets_provider.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'volume';

  final _pagingController = PagingController<int, Map<String, dynamic>>(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int page) async {
    try {
      final notifier = ref.read(marketsProvider.notifier);
      final items = await notifier.fetchMarkets(
        page: page,
        category: _tabController.index,
        search: _searchQuery,
        sortBy: _sortBy,
      );
      final isLast = items.length < AppConstants.pageSize;
      if (isLast) {
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, page + 1);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  void _onSearchChanged(String q) {
    _searchQuery = q;
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Text('Markets', style: AppTextStyles.h4),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
            onPressed: _showSortSheet,
          ),
          IconButton(
            icon: const Icon(Icons.add_alert_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: 'Search coins...',
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () { _searchController.clear(); _onSearchChanged(''); })
                        : null,
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All'), Tab(text: 'Spot'),
                  Tab(text: 'Futures'), Tab(text: 'ETF'), Tab(text: 'Watch'),
                ],
                isScrollable: true,
                onTap: (_) => _pagingController.refresh(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(5, (_) => _buildMarketList()),
      ),
    );
  }

  Widget _buildMarketList() {
    return PagedListView<int, Map<String, dynamic>>(
      pagingController: _pagingController,
      padding: const EdgeInsets.all(16),
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (ctx, item, index) => _MarketItem(
          coin: item,
          onTap: () => ctx.push('/coin/${item['symbol']}'),
        ),
        firstPageProgressIndicatorBuilder: (_) => const ZebShimmerList(),
        newPageProgressIndicatorBuilder: (_) => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
        ),
        noItemsFoundIndicatorBuilder: (_) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, color: AppColors.textSecondary, size: 48),
              const SizedBox(height: 8),
              Text('No coins found', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort by', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            ...['volume', 'price', 'change', 'market_cap'].map((s) => ListTile(
              title: Text(s.replaceAll('_', ' ').toUpperCase(), style: AppTextStyles.body),
              trailing: _sortBy == s ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _sortBy = s);
                Navigator.pop(context);
                _pagingController.refresh();
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _MarketItem extends StatelessWidget {
  final Map<String, dynamic> coin;
  final VoidCallback onTap;
  const _MarketItem({required this.coin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final change = (coin['changePercent'] as num?)?.toDouble() ?? 0;
    final price = (coin['price'] as num?)?.toDouble() ?? 0;
    final volume = (coin['volume24h'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor, width: 0.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceLight,
              child: Text(
                (coin['symbol']?.toString() ?? '?').substring(0, 1),
                style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coin['symbol']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
                  Text('Vol: ${Formatters.compact(volume)}',
                      style: AppTextStyles.micro),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.price(price), style: AppTextStyles.bodySemiBold),
                  Text('${Formatters.compact(volume)}', style: AppTextStyles.micro),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: (change >= 0 ? AppColors.bullish : AppColors.bearish).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                Formatters.percent(change),
                textAlign: TextAlign.center,
                style: AppTextStyles.captionSemiBold.copyWith(
                  color: change >= 0 ? AppColors.bullish : AppColors.bearish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
