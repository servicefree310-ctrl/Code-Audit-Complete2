import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_emailCtrl.text.isEmpty) return;
    final notifier = ref.read(authProvider.notifier);
    final success = await notifier.forgotPassword(_emailCtrl.text.trim());
    if (success && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildSuccess() : _buildForm(authState),
      ),
    );
  }

  Widget _buildForm(authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.lock_reset_outlined, color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: 24),
        Text('Reset Password', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text("Enter your email and we'll send you a reset link.",
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 32),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.body,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 24),
        ZebButton(label: 'Send Reset Link', onPressed: _submit, isLoading: authState.isLoading),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 40),
        ),
        const SizedBox(height: 24),
        Text('Email Sent!', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text('Check your email for a password reset link.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        ZebButton(label: 'Back to Login', onPressed: () => context.go('/auth/login')),
      ],
    );
  }
}
