import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true, _obscure2 = true;

  Future<void> _submit() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    final success = await ref.read(authProvider.notifier).resetPassword(
      token: widget.token, password: _passwordCtrl.text);
    if (success && mounted) context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0,
          title: Text('New Password', style: AppTextStyles.h4)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create a new password', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text('Must be at least 8 characters', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure1,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(_obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscure2,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(_obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ZebButton(label: 'Reset Password', onPressed: _submit, isLoading: authState.isLoading),
          ],
        ),
      ),
    );
  }
}
