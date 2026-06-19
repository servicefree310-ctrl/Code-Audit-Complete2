import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class P2PScreen extends ConsumerStatefulWidget {
  const P2PScreen({super.key});

  @override
  ConsumerState<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends ConsumerState<P2PScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _offers = [];
  bool _isLoading = true;
  String _selectedCoin = 'USDT';
  String _selectedFiat = 'INR';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(AppConstants.p2pOffersPath, queryParameters: {
        'coin': _selectedCoin,
        'fiat': _selectedFiat,
        'side': _tabController.index == 0 ? 'BUY' : 'SELL',
      });
      final data = response.data;
      setState(() {
        if (data is List) _offers = data.cast<Map<String, dynamic>>();
        else if (data is Map && data['data'] is List) _offers = (data['data'] as List).cast<Map<String, dynamic>>();
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.pop()),
        title: Text('P2P Trading', style: AppTextStyles.h4),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Buy'), Tab(text: 'Sell')],
          onTap: (_) { setState(() => _isLoading = true); _fetchOffers(); },
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOfferList(isBuy: true),
                      _buildOfferList(isBuy: false),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          _FilterChip(label: _selectedCoin, onTap: () {}),
          const SizedBox(width: 8),
          _FilterChip(label: _selectedFiat, onTap: () {}),
          const Spacer(),
          _FilterChip(label: 'Payment', icon: Icons.payment_rounded, onTap: () {}),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOfferList({required bool isBuy}) {
    if (_offers.isEmpty) {
      return const Center(child: Text('No offers available', style: AppTextStyles.caption));
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchOffers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _offers.length,
        itemBuilder: (_, i) => _P2POfferCard(
          offer: _offers[i],
          isBuy: isBuy,
          onTap: () => context.push('/p2p/order/${_offers[i]['id']}'),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  const _FilterChip({required this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4)],
            Text(label, style: AppTextStyles.captionSemiBold),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _P2POfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final bool isBuy;
  final VoidCallback onTap;
  const _P2POfferCard({required this.offer, required this.isBuy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final price = (offer['price'] as num?)?.toDouble() ?? 0;
    final available = (offer['available'] as num?)?.toDouble() ?? 0;
    final merchant = offer['merchant'] as Map<String, dynamic>? ?? {};
    final completionRate = (merchant['completionRate'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 16, backgroundColor: AppColors.surfaceLight,
                  child: Text((merchant['name']?.toString() ?? '?').substring(0, 1),
                      style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.primary))),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(merchant['name']?.toString() ?? 'Merchant', style: AppTextStyles.captionSemiBold),
                  Text('${merchant['orders'] ?? 0} orders | ${completionRate.toStringAsFixed(1)}% completion',
                      style: AppTextStyles.micro),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bullish.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 10, color: AppColors.bullish),
                    SizedBox(width: 2),
                    Text('Verified', style: TextStyle(fontSize: 10, color: AppColors.bullish, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price', style: AppTextStyles.micro),
                  Text('₹${Formatters.price(price)}', style: AppTextStyles.h5.copyWith(color: AppColors.primary)),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available', style: AppTextStyles.micro),
                  Text(Formatters.compact(available), style: AppTextStyles.captionSemiBold),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBuy ? AppColors.bullish : AppColors.bearish,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(isBuy ? 'Buy' : 'Sell', style: AppTextStyles.captionSemiBold.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: ((offer['paymentMethods'] as List?) ?? ['UPI', 'IMPS']).map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(m.toString(), style: AppTextStyles.micro),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
