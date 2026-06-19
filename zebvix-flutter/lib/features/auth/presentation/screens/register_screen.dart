import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose(); _referralCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and conditions')));
      return;
    }
    final notifier = ref.read(authProvider.notifier);
    final success = await notifier.register(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      referralCode: _referralCtrl.text.trim().isEmpty ? null : _referralCtrl.text.trim(),
    );
    if (success && mounted) {
      context.push('/auth/otp', extra: {'email': _emailCtrl.text.trim(), 'type': 'email'});
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
        title: Text('Create Account', style: AppTextStyles.h4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Join Zebvix', style: AppTextStyles.h2),
              const SizedBox(height: 6),
              Text('Start trading crypto today', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              if (authState.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(authState.error!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                ),
              _buildField(controller: _nameCtrl, label: 'Full Name', icon: Icons.person_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Name is required' : null),
              const SizedBox(height: 14),
              _buildField(controller: _emailCtrl, label: 'Email Address', icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Email is required' : null),
              const SizedBox(height: 14),
              _buildField(controller: _phoneCtrl, label: 'Phone (optional)', icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Password is required';
                  if (v.length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Please confirm password';
                  if (v != _passwordCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildField(controller: _referralCtrl, label: 'Referral Code (optional)', icon: Icons.card_giftcard_outlined),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            children: [
                              TextSpan(text: 'Terms of Service', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                              TextSpan(text: ' and ', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                              TextSpan(text: 'Privacy Policy', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ZebButton(label: 'Create Account', onPressed: _register, isLoading: authState.isLoading),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(text: 'Sign In', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
      ),
      validator: validator,
    );
  }
}
