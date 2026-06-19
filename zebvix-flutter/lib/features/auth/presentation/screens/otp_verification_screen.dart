import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String type;

  const OtpVerificationScreen({super.key, required this.email, required this.type});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  String _otp = '';
  int _countdown = 60;
  Timer? _timer;
  bool _isSendingResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length != 6) return;
    final notifier = ref.read(authProvider.notifier);
    final success = await notifier.verifyOtp(
      email: widget.email,
      otp: _otp,
      type: widget.type,
    );
    if (success && mounted) {
      context.go('/home');
    }
  }

  Future<void> _resendOtp() async {
    if (_isSendingResend) return;
    setState(() => _isSendingResend = true);
    final notifier = ref.read(authProvider.notifier);
    final sent = await notifier.resendOtp(email: widget.email, type: widget.type);
    if (mounted) {
      setState(() => _isSendingResend = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(sent ? 'Code resent to ${widget.email}' : 'Failed to resend. Please try again.'),
        backgroundColor: sent ? AppColors.bullish : AppColors.error,
      ));
      if (sent) _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.mark_email_unread_outlined, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 24),
            Text('Verify your email', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: 'Enter the 6-digit code sent to ',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                children: [
                  TextSpan(text: widget.email, style: AppTextStyles.bodySemiBold),
                ],
              ),
            ),
            const SizedBox(height: 36),
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _otpController,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 56,
                fieldWidth: 48,
                activeFillColor: AppColors.surfaceLight,
                inactiveFillColor: AppColors.surface,
                selectedFillColor: AppColors.surface,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.borderColor,
                selectedColor: AppColors.primary,
              ),
              enableActiveFill: true,
              onChanged: (v) => setState(() => _otp = v),
              onCompleted: (_) => _verify(),
            ),
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(authState.error!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
              ),
            const SizedBox(height: 32),
            ZebButton(label: 'Verify', onPressed: _otp.length == 6 ? _verify : null, isLoading: authState.isLoading),
            const SizedBox(height: 24),
            Center(
              child: _countdown > 0
                  ? Text('Resend code in ${_countdown}s',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))
                  : _isSendingResend
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : TextButton(
                          onPressed: _resendOtp,
                          child: Text('Resend Code', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
