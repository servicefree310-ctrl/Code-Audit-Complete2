import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/utils/formatters.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _referralInfo;
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

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
        dio.get(AppConstants.referralInfoPath).catchError((_) => null),
        dio.get(AppConstants.rewardsTasksPath).catchError((_) => null),
      ]);
      setState(() {
        _referralInfo = results[0]?.data as Map<String, dynamic>?;
        final tasksData = results[1]?.data;
        if (tasksData is List) _tasks = tasksData.cast<Map<String, dynamic>>();
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
      appBar: const ZebAppBar(title: 'Rewards & Referrals'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [Tab(text: 'Referral'), Tab(text: 'Tasks'), Tab(text: 'Coupons'), Tab(text: 'Leaderboard')],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildReferral(), _buildTasks(), _buildCoupons(), _buildLeaderboard()],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReferral() {
    final code = _referralInfo?['referralCode']?.toString() ?? '--';
    final totalEarnings = (_referralInfo?['totalEarnings'] as num?)?.toDouble() ?? 0;
    final totalReferrals = _referralInfo?['totalReferrals'] ?? 0;
    final commissionRate = (_referralInfo?['commissionRate'] as num?)?.toDouble() ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A1F00), Color(0xFF1E2329)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
                child: Text('REFERRAL PROGRAM', style: AppTextStyles.captionSemiBold.copyWith(color: Colors.white, letterSpacing: 2)),
              ),
              const SizedBox(height: 16),
              Text('Earn $commissionRate% commission\non every trade your friends make',
                  style: AppTextStyles.h4, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ReferralStat(label: 'Total Referrals', value: totalReferrals.toString()),
                  _ReferralStat(label: 'Total Earnings', value: '\$${Formatters.compact(totalEarnings)}'),
                  _ReferralStat(label: 'Commission', value: '$commissionRate%'),
                ],
              ),
              const SizedBox(height: 20),
              Text('Your Referral Code', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(code, style: AppTextStyles.h4.copyWith(color: AppColors.primary, letterSpacing: 4)),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied!'), backgroundColor: AppColors.bullish));
                      },
                      child: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share Link'),
                  )),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: const Text('QR Code'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Referral History', style: AppTextStyles.h5),
        const SizedBox(height: 10),
        FutureBuilder(
          future: ref.read(dioProvider).get(AppConstants.referralHistoryPath),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            final data = (snapshot.data?.data as List?)?.cast<Map<String, dynamic>>() ?? [];
            if (data.isEmpty) return Center(child: Text('No referral history yet', style: AppTextStyles.caption));
            return Column(children: data.take(10).map((r) => ListTile(
              title: Text(r['name']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
              subtitle: Text(Formatters.relativeTime(DateTime.tryParse(r['joinedAt']?.toString() ?? '') ?? DateTime.now()), style: AppTextStyles.micro),
              trailing: Text('+\$${Formatters.price((r['commission'] as num?)?.toDouble() ?? 0)}',
                  style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.bullish)),
            )).toList());
          },
        ),
      ],
    );
  }

  Widget _buildTasks() {
    if (_tasks.isEmpty) return const Center(child: Text('No tasks available', style: AppTextStyles.caption));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tasks.length,
      itemBuilder: (_, i) {
        final task = _tasks[i];
        final isDone = task['isCompleted'] as bool? ?? false;
        final reward = (task['reward'] as num?)?.toDouble() ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDone ? AppColors.bullish.withOpacity(0.2) : AppColors.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: (isDone ? AppColors.bullish : AppColors.primary).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(isDone ? Icons.check_circle_rounded : Icons.task_alt_rounded,
                    color: isDone ? AppColors.bullish : AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(task['title']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
                Text(task['description']?.toString() ?? '', style: AppTextStyles.micro, maxLines: 1),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('+\$${Formatters.price(reward)}',
                    style: AppTextStyles.captionSemiBold.copyWith(color: AppColors.primary)),
                Text(isDone ? 'Claimed' : 'Pending',
                    style: AppTextStyles.micro.copyWith(color: isDone ? AppColors.bullish : AppColors.textHint)),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoupons() {
    return FutureBuilder(
      future: ref.read(dioProvider).get(AppConstants.rewardsCouponsPath),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final data = (snapshot.data?.data as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (data.isEmpty) return const Center(child: Text('No coupons available', style: AppTextStyles.caption));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (_, i) {
            final coupon = data[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(coupon['title']?.toString() ?? '', style: AppTextStyles.bodySemiBold.copyWith(color: Colors.black87)),
                    Text(coupon['description']?.toString() ?? '', style: AppTextStyles.micro.copyWith(color: Colors.black54)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(6)),
                    child: Text(coupon['code']?.toString() ?? '', style: AppTextStyles.captionSemiBold.copyWith(color: Colors.black87)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboard() {
    return FutureBuilder(
      future: ref.read(dioProvider).get(AppConstants.leaderboardPath),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final data = (snapshot.data?.data as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (data.isEmpty) return const Center(child: Text('No data', style: AppTextStyles.caption));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (_, i) {
            final entry = data[i];
            final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '${i + 1}';
            return ListTile(
              leading: Text(medal, style: const TextStyle(fontSize: 20)),
              title: Text(entry['name']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
              trailing: Text('\$${Formatters.compact((entry['earnings'] as num?)?.toDouble() ?? 0)}',
                  style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primary)),
            );
          },
        );
      },
    );
  }
}

class _ReferralStat extends StatelessWidget {
  final String label;
  final String value;
  const _ReferralStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: AppTextStyles.h4.copyWith(color: AppColors.primary)),
      Text(label, style: AppTextStyles.micro),
    ]);
  }
}
