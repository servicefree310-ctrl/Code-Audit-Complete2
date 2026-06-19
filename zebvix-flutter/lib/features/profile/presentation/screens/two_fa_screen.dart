import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';

class TwoFaScreen extends ConsumerStatefulWidget {
  const TwoFaScreen({super.key});

  @override
  ConsumerState<TwoFaScreen> createState() => _TwoFaScreenState();
}

class _TwoFaScreenState extends ConsumerState<TwoFaScreen> {
  Map<String, dynamic>? _setupData;
  bool _isLoading = true;
  String _otp = '';
  bool _isSubmitting = false;
  bool _is2FAEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetch2FASetup();
  }

  Future<void> _fetch2FASetup() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(AppConstants.setup2faPath);
      setState(() {
        _setupData = response.data as Map<String, dynamic>?;
        _is2FAEnabled = _setupData?['isEnabled'] as bool? ?? false;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enable2FA() async {
    if (_otp.length != 6) return;
    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(AppConstants.verify2faPath, data: {'otp': _otp});
      setState(() => _is2FAEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('2FA enabled!'), backgroundColor: AppColors.bullish));
    } catch (_) {}
    setState(() => _isSubmitting = false);
  }

  Future<void> _disable2FA() async {
    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(AppConstants.disable2faPath, data: {'otp': _otp});
      setState(() => _is2FAEnabled = false);
    } catch (_) {}
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZebAppBar(title: '2FA Authentication'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatus(),
                  const SizedBox(height: 20),
                  if (!_is2FAEnabled) ...[
                    Text('Step 1: Scan QR Code', style: AppTextStyles.h5),
                    const SizedBox(height: 8),
                    Text('Open Google Authenticator or Authy and scan this QR code.', style: AppTextStyles.caption),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: _setupData?['qrUri'] != null
                            ? QrImageView(data: _setupData!['qrUri']!, version: QrVersions.auto, size: 180, backgroundColor: Colors.white)
                            : const SizedBox(width: 180, height: 180, child: Center(child: Text('QR Loading...', style: AppTextStyles.caption))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Manual Entry Code', style: AppTextStyles.bodySemiBold),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _setupData?['secret'] ?? ''));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.borderColor)),
                        child: Row(
                          children: [
                            Expanded(child: Text(_setupData?['secret']?.toString() ?? '', style: AppTextStyles.mono, overflow: TextOverflow.ellipsis)),
                            const Icon(Icons.copy_rounded, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Step 2: Enter Code', style: AppTextStyles.h5),
                    const SizedBox(height: 8),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: 52, fieldWidth: 46,
                        activeFillColor: AppColors.surfaceLight, inactiveFillColor: AppColors.surface, selectedFillColor: AppColors.surface,
                        activeColor: AppColors.primary, inactiveColor: AppColors.borderColor, selectedColor: AppColors.primary,
                      ),
                      enableActiveFill: true,
                      onChanged: (v) => setState(() => _otp = v),
                    ),
                    const SizedBox(height: 20),
                    ZebButton(label: 'Enable 2FA', onPressed: _enable2FA, isLoading: _isSubmitting),
                  ] else ...[
                    Text('2FA is enabled on your account.', style: AppTextStyles.body),
                    const SizedBox(height: 24),
                    ZebButton(label: 'Disable 2FA', onPressed: _disable2FA, isLoading: _isSubmitting, variant: ZebButtonVariant.danger),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatus() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (_is2FAEnabled ? AppColors.bullish : AppColors.warning).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: (_is2FAEnabled ? AppColors.bullish : AppColors.warning).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_is2FAEnabled ? Icons.shield_rounded : Icons.shield_outlined,
              color: _is2FAEnabled ? AppColors.bullish : AppColors.warning, size: 24),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_is2FAEnabled ? '2FA Enabled' : '2FA Disabled', style: AppTextStyles.bodySemiBold),
            Text(_is2FAEnabled ? 'Your account is protected with 2FA' : 'Enable 2FA to protect your account',
                style: AppTextStyles.caption),
          ])),
        ],
      ),
    );
  }
}
