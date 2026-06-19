import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/utils/formatters.dart';

class AutoInvestScreen extends ConsumerStatefulWidget {
  const AutoInvestScreen({super.key});

  @override
  ConsumerState<AutoInvestScreen> createState() => _AutoInvestScreenState();
}

class _AutoInvestScreenState extends ConsumerState<AutoInvestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _portfolio;
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;

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
        dio.get(AppConstants.autoInvestPortfolioPath).catchError((_) => null),
        dio.get(AppConstants.autoInvestPlansPath).catchError((_) => null),
      ]);
      setState(() {
        _portfolio = results[0]?.data as Map<String, dynamic>?;
        final plansData = results[1]?.data;
        if (plansData is List) _plans = plansData.cast<Map<String, dynamic>>();
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
      appBar: ZebAppBar(
        title: 'Auto Invest',
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.primary), onPressed: _showCreatePlan),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildPortfolioCard(),
                TabBar(
                  controller: _tabController,
                  tabs: const [Tab(text: 'Plans'), Tab(text: 'Portfolio'), Tab(text: 'History')],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildPlans(), _buildPortfolio(), _buildHistory()],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPortfolioCard() {
    final total = (_portfolio?['totalValue'] as num?)?.toDouble() ?? 0;
    final earnings = (_portfolio?['totalEarnings'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2D3A), Color(0xFF1E2329)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Value', style: AppTextStyles.caption),
            Text('\$${Formatters.compact(total)}', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.bullish),
              const SizedBox(width: 4),
              Text('+\$${Formatters.compact(earnings)} earnings', style: AppTextStyles.caption.copyWith(color: AppColors.bullish)),
            ]),
          ])),
          Column(children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info.withOpacity(0.2),
                foregroundColor: AppColors.info,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text('Deposit', style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.info)),
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceLight,
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Withdraw', style: AppTextStyles.captionSemiBold),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPlans() {
    if (_plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_mosaic_rounded, color: AppColors.textHint, size: 64),
            const SizedBox(height: 12),
            Text('No investment plans yet', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreatePlan,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Plan'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plans.length,
      itemBuilder: (_, i) => _InvestPlanCard(plan: _plans[i]),
    );
  }

  Widget _buildPortfolio() {
    final assets = (_portfolio?['assets'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (assets.isEmpty) return const Center(child: Text('No assets', style: AppTextStyles.caption));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assets.length,
      itemBuilder: (_, i) {
        final asset = assets[i];
        final value = (asset['value'] as num?)?.toDouble() ?? 0;
        final change = (asset['changePercent'] as num?)?.toDouble() ?? 0;
        return ListTile(
          leading: CircleAvatar(radius: 18, backgroundColor: AppColors.surfaceLight,
              child: Text((asset['coin']?.toString() ?? '?').substring(0, 1),
                  style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.primary))),
          title: Text(asset['coin']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
          subtitle: Text('${asset['amount']} ${asset['coin']}', style: AppTextStyles.micro),
          trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('\$${Formatters.compact(value)}', style: AppTextStyles.captionSemiBold),
            Text(Formatters.percent(change),
                style: AppTextStyles.micro.copyWith(color: change >= 0 ? AppColors.bullish : AppColors.bearish)),
          ]),
        );
      },
    );
  }

  Widget _buildHistory() {
    return FutureBuilder(
      future: ref.read(dioProvider).get(AppConstants.autoInvestHistoryPath),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final data = (snapshot.data?.data as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (data.isEmpty) return const Center(child: Text('No history', style: AppTextStyles.caption));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(data[i]['type']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
            subtitle: Text(Formatters.relativeTime(DateTime.tryParse(data[i]['createdAt']?.toString() ?? '') ?? DateTime.now()),
                style: AppTextStyles.micro),
            trailing: Text('\$${Formatters.price((data[i]['amount'] as num?)?.toDouble() ?? 0)}',
                style: AppTextStyles.captionSemiBold),
          ),
        );
      },
    );
  }

  void _showCreatePlan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create Investment Plan', style: AppTextStyles.h4),
              const SizedBox(height: 16),
              const Text('Configure your recurring investment plan with your preferred coins and frequency.'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Coming Soon')),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvestPlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  const _InvestPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isActive = plan['isActive'] as bool? ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? AppColors.bullish.withOpacity(0.3) : AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(plan['name']?.toString() ?? 'Investment Plan', style: AppTextStyles.bodySemiBold),
            Text('${plan['frequency'] ?? 'Daily'} · \$${plan['amount'] ?? 0}', style: AppTextStyles.caption),
            Text('Coins: ${(plan['coins'] as List?)?.join(', ') ?? '--'}', style: AppTextStyles.micro),
          ])),
          Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isActive ? AppColors.bullish : AppColors.error).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(isActive ? 'Active' : 'Paused',
                  style: AppTextStyles.micro.copyWith(color: isActive ? AppColors.bullish : AppColors.error, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
          ]),
        ],
      ),
    );
  }
}
