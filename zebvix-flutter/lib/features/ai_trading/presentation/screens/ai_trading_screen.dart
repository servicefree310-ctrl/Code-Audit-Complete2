import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_card.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../../../../core/utils/formatters.dart';

class AiTradingScreen extends ConsumerStatefulWidget {
  const AiTradingScreen({super.key});

  @override
  ConsumerState<AiTradingScreen> createState() => _AiTradingScreenState();
}

class _AiTradingScreenState extends ConsumerState<AiTradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _dashboard;
  List<Map<String, dynamic>> _strategies = [];
  List<Map<String, dynamic>> _signals = [];
  bool _isLoading = true;
  bool _aiRunning = false;

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
        dio.get(AppConstants.aiDashboardPath).catchError((_) => null),
        dio.get(AppConstants.aiStrategiesPath).catchError((_) => null),
        dio.get(AppConstants.aiSignalsPath).catchError((_) => null),
      ]);
      setState(() {
        _dashboard = results[0]?.data as Map<String, dynamic>?;
        _aiRunning = _dashboard?['isRunning'] as bool? ?? false;
        final strats = results[1]?.data;
        if (strats is List) _strategies = strats.cast<Map<String, dynamic>>();
        final sigs = results[2]?.data;
        if (sigs is List) _signals = sigs.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAI() async {
    try {
      final dio = ref.read(dioProvider);
      if (_aiRunning) {
        await dio.post(AppConstants.aiStopPath);
      } else {
        await dio.post(AppConstants.aiStartPath);
      }
      setState(() => _aiRunning = !_aiRunning);
    } catch (_) {}
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(
        title: 'AI Trading',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: _toggleAI,
              style: ElevatedButton.styleFrom(
                backgroundColor: _aiRunning ? AppColors.bearish : AppColors.bullish,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
              ),
              icon: Icon(_aiRunning ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 16),
              label: Text(_aiRunning ? 'Stop AI' : 'Start AI', style: AppTextStyles.captionSemiBold.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildAIStatus(),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [Tab(text: 'Dashboard'), Tab(text: 'Signals'), Tab(text: 'Strategies'), Tab(text: 'History')],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboard(),
                      _buildSignals(),
                      _buildStrategies(),
                      _buildHistory(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAIStatus() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _aiRunning
              ? [const Color(0xFF0A2A1A), const Color(0xFF1E2329)]
              : [const Color(0xFF1E2329), const Color(0xFF2B3139)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _aiRunning ? AppColors.bullish.withOpacity(0.3) : AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: (_aiRunning ? AppColors.bullish : AppColors.textSecondary).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded,
                color: _aiRunning ? AppColors.bullish : AppColors.textSecondary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('AI Engine', style: AppTextStyles.bodySemiBold),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (_aiRunning ? AppColors.bullish : AppColors.error).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: _aiRunning ? AppColors.bullish : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(_aiRunning ? 'ACTIVE' : 'STOPPED',
                              style: AppTextStyles.micro.copyWith(
                                color: _aiRunning ? AppColors.bullish : AppColors.error,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  _aiRunning ? 'Analyzing market conditions...' : 'Start AI to begin automated trading',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Risk Score', style: AppTextStyles.micro),
              Text(_dashboard?['riskScore']?.toString() ?? '--',
                  style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.warning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final dayProfit = (_dashboard?['dailyProfit'] as num?)?.toDouble() ?? 0;
    final monthProfit = (_dashboard?['monthlyProfit'] as num?)?.toDouble() ?? 0;
    final winRate = (_dashboard?['winRate'] as num?)?.toDouble() ?? 0;
    final totalTrades = _dashboard?['totalTrades'] ?? 0;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _ProfitCard(label: "Today's Profit", amount: dayProfit, period: '24h')),
              const SizedBox(width: 10),
              Expanded(child: _ProfitCard(label: 'Monthly Profit', amount: monthProfit, period: '30d')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'Win Rate', value: '${winRate.toStringAsFixed(1)}%', color: AppColors.bullish)),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard(label: 'Total Trades', value: totalTrades.toString(), color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Performance', style: AppTextStyles.h5),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Center(child: Text('Profit Chart', style: AppTextStyles.caption)),
          ),
        ],
      ),
    );
  }

  Widget _buildSignals() {
    if (_signals.isEmpty) {
      return const Center(child: Text('No signals available', style: AppTextStyles.caption));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _signals.length,
      itemBuilder: (_, i) => _SignalCard(signal: _signals[i]),
    );
  }

  Widget _buildStrategies() {
    if (_strategies.isEmpty) {
      return const Center(child: Text('No strategies available', style: AppTextStyles.caption));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _strategies.length,
      itemBuilder: (_, i) => _StrategyCard(
        strategy: _strategies[i],
        onSubscribe: () {},
      ),
    );
  }

  Widget _buildHistory() {
    return FutureBuilder(
      future: ref.read(dioProvider).get(AppConstants.aiHistoryPath),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final data = (snapshot.data?.data as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (data.isEmpty) return const Center(child: Text('No trading history', style: AppTextStyles.caption));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (_, i) {
            final trade = data[i];
            final pnl = (trade['pnl'] as num?)?.toDouble() ?? 0;
            return ListTile(
              title: Text(trade['symbol']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
              subtitle: Text(trade['strategy']?.toString() ?? '', style: AppTextStyles.micro),
              trailing: Text('${pnl >= 0 ? '+' : ''}\$${Formatters.price(pnl.abs())}',
                  style: AppTextStyles.captionSemiBold.copyWith(color: pnl >= 0 ? AppColors.bullish : AppColors.bearish)),
            );
          },
        );
      },
    );
  }
}

class _ProfitCard extends StatelessWidget {
  final String label;
  final double amount;
  final String period;
  const _ProfitCard({required this.label, required this.amount, required this.period});

  @override
  Widget build(BuildContext context) {
    final isPos = amount >= 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isPos ? AppColors.greenGradient : AppColors.redGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (isPos ? AppColors.bullish : AppColors.bearish).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.micro),
          const SizedBox(height: 6),
          Text('${isPos ? '+' : '-'}\$${Formatters.price(amount.abs())}',
              style: AppTextStyles.bodySemiBold.copyWith(color: isPos ? AppColors.bullish : AppColors.bearish)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.micro),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.bodySemiBold.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  final Map<String, dynamic> signal;
  const _SignalCard({required this.signal});

  @override
  Widget build(BuildContext context) {
    final direction = signal['direction']?.toString().toUpperCase() ?? 'BUY';
    final isBuy = direction == 'BUY';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (isBuy ? AppColors.bullish : AppColors.bearish).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isBuy ? AppColors.bullish : AppColors.bearish).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(isBuy ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: isBuy ? AppColors.bullish : AppColors.bearish, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(signal['symbol']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
            Text(signal['reason']?.toString() ?? '', style: AppTextStyles.micro),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isBuy ? AppColors.bullish : AppColors.bearish).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(direction, style: AppTextStyles.captionSemiBold.copyWith(
                  color: isBuy ? AppColors.bullish : AppColors.bearish)),
            ),
            const SizedBox(height: 4),
            Text('Confidence: ${signal['confidence'] ?? 0}%', style: AppTextStyles.micro),
          ]),
        ],
      ),
    );
  }
}

class _StrategyCard extends StatelessWidget {
  final Map<String, dynamic> strategy;
  final VoidCallback onSubscribe;
  const _StrategyCard({required this.strategy, required this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    final roi = (strategy['roi'] as num?)?.toDouble() ?? 0;
    final isSubscribed = strategy['isSubscribed'] as bool? ?? false;
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
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(strategy['name']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
            Text(strategy['description']?.toString() ?? '', style: AppTextStyles.micro, maxLines: 2),
            const SizedBox(height: 4),
            Text('ROI: ${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(2)}%',
                style: AppTextStyles.captionSemiBold.copyWith(color: roi >= 0 ? AppColors.bullish : AppColors.bearish)),
          ])),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: isSubscribed ? null : onSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSubscribed ? AppColors.surfaceLight : AppColors.primary,
              foregroundColor: isSubscribed ? AppColors.textSecondary : AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isSubscribed ? 'Active' : 'Subscribe', style: AppTextStyles.captionSemiBold),
          ),
        ],
      ),
    );
  }
}
