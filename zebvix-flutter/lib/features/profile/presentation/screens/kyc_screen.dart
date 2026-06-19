import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  Map<String, dynamic>? _kycStatus;
  bool _isLoading = true;
  String _selectedDocType = 'Aadhaar';

  @override
  void initState() {
    super.initState();
    _fetchKycStatus();
  }

  Future<void> _fetchKycStatus() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(AppConstants.kycStatusPath);
      setState(() { _kycStatus = response.data as Map<String, dynamic>?; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = _kycStatus?['level']?.toString() ?? '0';
    final status = _kycStatus?['status']?.toString() ?? 'pending';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZebAppBar(title: 'KYC Verification'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(level, status),
                  const SizedBox(height: 20),
                  _buildLevelProgress(level),
                  const SizedBox(height: 24),
                  if (level == '0') _buildBasicKYC(),
                  if (level == '1') _buildAdvancedKYC(),
                  if (level == '2') _buildCompleted(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(String level, String status) {
    final color = status == 'approved' ? AppColors.bullish : status == 'pending' ? AppColors.warning : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), AppColors.surface],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(
              status == 'approved' ? Icons.verified_rounded : status == 'pending' ? Icons.hourglass_bottom_rounded : Icons.error_outline_rounded,
              color: color, size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('KYC Level $level', style: AppTextStyles.h5),
            Text(status == 'approved' ? 'Verification complete' : status == 'pending' ? 'Under review' : 'Action required',
                style: AppTextStyles.caption.copyWith(color: color)),
          ])),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(String level) {
    final levelInt = int.tryParse(level) ?? 0;
    final levels = [
      {'label': 'Email Verified', 'done': levelInt >= 1},
      {'label': 'Basic KYC', 'done': levelInt >= 1},
      {'label': 'Advanced KYC', 'done': levelInt >= 2},
    ];
    return Column(
      children: levels.asMap().entries.map((e) {
        final isDone = e.value['done'] as bool;
        return Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isDone ? AppColors.bullish.withOpacity(0.15) : AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? AppColors.bullish : AppColors.borderColor),
              ),
              child: Icon(isDone ? Icons.check_rounded : Icons.circle_outlined,
                  color: isDone ? AppColors.bullish : AppColors.textHint, size: 16),
            ),
            const SizedBox(width: 10),
            Text(e.value['label'] as String, style: AppTextStyles.body.copyWith(
                color: isDone ? AppColors.textPrimary : AppColors.textSecondary)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBasicKYC() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Basic KYC (Level 1)', style: AppTextStyles.h4),
        const SizedBox(height: 4),
        Text('Unlock higher limits and all trading features', style: AppTextStyles.caption),
        const SizedBox(height: 16),
        Text('Document Type', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['Aadhaar', 'PAN', 'Passport', 'Driving License'].map((doc) => GestureDetector(
            onTap: () => setState(() => _selectedDocType = doc),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedDocType == doc ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _selectedDocType == doc ? AppColors.primary : AppColors.borderColor),
              ),
              child: Text(doc, style: AppTextStyles.captionSemiBold.copyWith(
                  color: _selectedDocType == doc ? AppColors.primary : AppColors.textPrimary)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 20),
        _DocumentUploadBox(label: 'Front Side'),
        const SizedBox(height: 10),
        _DocumentUploadBox(label: 'Back Side'),
        const SizedBox(height: 10),
        _DocumentUploadBox(label: 'Selfie with Document'),
        const SizedBox(height: 24),
        ZebButton(label: 'Submit for Verification', onPressed: () {}),
      ],
    );
  }

  Widget _buildAdvancedKYC() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Advanced KYC (Level 2)', style: AppTextStyles.h4),
        const SizedBox(height: 4),
        Text('Required for large withdrawals and all features', style: AppTextStyles.caption),
        const SizedBox(height: 16),
        _DocumentUploadBox(label: 'Face Verification / Selfie Video'),
        const SizedBox(height: 10),
        _DocumentUploadBox(label: 'Proof of Address'),
        const SizedBox(height: 24),
        ZebButton(label: 'Submit for Advanced Verification', onPressed: () {}),
      ],
    );
  }

  Widget _buildCompleted() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.bullish, size: 80),
          const SizedBox(height: 16),
          Text('Fully Verified!', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text('You have completed all KYC levels.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _DocumentUploadBox extends StatelessWidget {
  final String label;
  const _DocumentUploadBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.captionSemiBold),
            Text('Tap to upload', style: AppTextStyles.micro),
          ],
        ),
      ),
    );
  }
}
