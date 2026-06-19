import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_shimmer.dart';
import '../../../../core/utils/formatters.dart';

class EarnScreen extends ConsumerStatefulWidget {
  const EarnScreen({super.key});

  @override
  ConsumerState<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends ConsumerState<EarnScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(AppConstants.earnProductsPath);
      final data = response.data;
      setState(() {
        if (data is List) _products = data.cast<Map<String, dynamic>>();
        else if (data is Map && data['data'] is List) _products = (data['data'] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Earn', style: AppTextStyles.h4),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
            label: Text('History', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Flexible'), Tab(text: 'Locked'),
            Tab(text: 'Staking'), Tab(text: 'Launchpool'), Tab(text: 'Dual Invest'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Portfolio summary
          _buildPortfolioSummary(),
          Expanded(
            child: _isLoading
                ? const ZebShimmerList()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductList('flexible'),
                      _buildProductList('locked'),
                      _buildProductList('staking'),
                      _buildProductList('launchpool'),
                      _buildProductList('dual'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A2A), Color(0xFF1E2329)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bullish.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Earn Portfolio', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text('-- USDT', style: AppTextStyles.h4.copyWith(color: AppColors.bullish)),
                const SizedBox(height: 4),
                Text('Today\'s Earnings: -- USDT', style: AppTextStyles.caption),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/auto-invest'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bullish, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text('Auto Invest', style: AppTextStyles.captionSemiBold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(String type) {
    final filtered = _products.where((p) => (p['type']?.toString() ?? 'flexible') == type).toList();
    if (filtered.isEmpty) {
      return _buildEmptyProducts(type);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _EarnProductCard(product: filtered[i]),
    );
  }

  Widget _buildEmptyProducts(String type) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchProducts,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                const Icon(Icons.savings_outlined, color: AppColors.textHint, size: 64),
                const SizedBox(height: 12),
                Text('No ${type.toUpperCase()} products', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _EarnProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final apy = (product['apy'] as num?)?.toDouble() ?? 0;
    final minAmount = (product['minAmount'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: AppColors.surfaceLight,
              child: Text((product['coin']?.toString() ?? '?').substring(0, 1),
                  style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primary))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['coin']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
                Text(product['type']?.toString().toUpperCase() ?? '', style: AppTextStyles.micro),
                if (minAmount > 0) Text('Min: ${Formatters.compact(minAmount)}', style: AppTextStyles.micro),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${apy.toStringAsFixed(2)}% APY',
                  style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.bullish)),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text('Subscribe', style: AppTextStyles.micro.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
