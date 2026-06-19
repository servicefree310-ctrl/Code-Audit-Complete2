import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/utils/formatters.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(AppConstants.notificationsPath);
      final data = response.data;
      setState(() {
        if (data is List) _notifications = data.cast<Map<String, dynamic>>();
        else if (data is Map && data['data'] is List) _notifications = (data['data'] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post(AppConstants.notificationReadPath);
      _fetchNotifications();
    } catch (_) {}
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text('Mark all read', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [Tab(text: 'All'), Tab(text: 'Orders'), Tab(text: 'Price Alerts'), Tab(text: 'System')],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _notifications.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _fetchNotifications,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _notifications.length,
                          separatorBuilder: (_, __) => const Divider(color: AppColors.borderColor, height: 1),
                          itemBuilder: (_, i) => _NotificationItem(notification: _notifications[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none_rounded, color: AppColors.textHint, size: 64),
          const SizedBox(height: 12),
          Text('No notifications', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isRead = notification['isRead'] as bool? ?? false;
    final type = notification['type']?.toString() ?? 'system';

    final iconData = switch (type) {
      'order' => Icons.receipt_outlined,
      'price_alert' => Icons.show_chart_rounded,
      'deposit' => Icons.arrow_downward_rounded,
      'withdraw' => Icons.arrow_upward_rounded,
      'security' => Icons.security_rounded,
      _ => Icons.notifications_outlined,
    };

    final iconColor = switch (type) {
      'order' => AppColors.primary,
      'price_alert' => AppColors.warning,
      'deposit' => AppColors.bullish,
      'withdraw' => AppColors.bearish,
      'security' => AppColors.error,
      _ => AppColors.textSecondary,
    };

    return Container(
      color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.03),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(notification['title']?.toString() ?? '',
                          style: AppTextStyles.bodySemiBold.copyWith(
                            color: isRead ? AppColors.textSecondary : AppColors.textPrimary)),
                    ),
                    Text(
                      Formatters.relativeTime(DateTime.tryParse(notification['createdAt']?.toString() ?? '') ?? DateTime.now()),
                      style: AppTextStyles.micro,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification['body']?.toString() ?? '',
                    style: AppTextStyles.caption,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (!isRead)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              width: 8, height: 8,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
