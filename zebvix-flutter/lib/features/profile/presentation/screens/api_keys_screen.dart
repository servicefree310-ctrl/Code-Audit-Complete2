import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../../../../core/utils/formatters.dart';

class ApiKeysScreen extends ConsumerStatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  ConsumerState<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends ConsumerState<ApiKeysScreen> {
  List<Map<String, dynamic>> _keys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKeys();
  }

  Future<void> _fetchKeys() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(AppConstants.apiKeysPath);
      final data = response.data;
      setState(() {
        if (data is List) _keys = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(
        title: 'API Keys',
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
            label: Text('Create', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            onPressed: _showCreateKey,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Never share your API keys. Store them securely.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.warning))),
                  ]),
                ),
                Expanded(
                  child: _keys.isEmpty
                      ? const Center(child: Text('No API keys created yet', style: AppTextStyles.caption))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _keys.length,
                          itemBuilder: (_, i) => _ApiKeyCard(apiKey: _keys[i], onDelete: () => _deleteKey(_keys[i]['id']?.toString() ?? '')),
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _deleteKey(String id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('${AppConstants.apiKeysPath}/$id');
      _fetchKeys();
    } catch (_) {}
  }

  void _showCreateKey() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create API Key', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Key Label')),
            const SizedBox(height: 16),
            ZebButton(label: 'Create API Key', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class _ApiKeyCard extends StatelessWidget {
  final Map<String, dynamic> apiKey;
  final VoidCallback onDelete;
  const _ApiKeyCard({required this.apiKey, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isActive = apiKey['isActive'] as bool? ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(apiKey['label']?.toString() ?? 'API Key', style: AppTextStyles.bodySemiBold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: (isActive ? AppColors.bullish : AppColors.error).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(isActive ? 'Active' : 'Inactive',
                  style: AppTextStyles.micro.copyWith(color: isActive ? AppColors.bullish : AppColors.error, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18), onPressed: onDelete),
          ]),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () { Clipboard.setData(ClipboardData(text: apiKey['key']?.toString() ?? '')); },
            child: Row(children: [
              Expanded(child: Text(Formatters.truncateAddress(apiKey['key']?.toString() ?? '', chars: 10),
                  style: AppTextStyles.mono.copyWith(color: AppColors.textSecondary))),
              const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
            ]),
          ),
          const SizedBox(height: 4),
          Text('Created: ${Formatters.relativeTime(DateTime.tryParse(apiKey['createdAt']?.toString() ?? '') ?? DateTime.now())}',
              style: AppTextStyles.micro),
        ],
      ),
    );
  }
}
