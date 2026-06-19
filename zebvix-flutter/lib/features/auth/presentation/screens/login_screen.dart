import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_button.dart';
import '../../../../core/widgets/zeb_card.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  // FIX: Remember me is now persisted via SharedPreferences
  bool _rememberMe = false;

  static const _kRememberMeKey = 'zeb_remember_me';
  static const _kSavedEmailKey = 'zeb_saved_email';

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getBool(_kRememberMeKey) ?? false;
    if (remembered) {
      final savedEmail = prefs.getString(_kSavedEmailKey) ?? '';
      if (savedEmail.isNotEmpty && mounted) {
        setState(() {
          _rememberMe = true;
          _emailCtrl.text = savedEmail;
        });
      }
    }
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool(_kRememberMeKey, true);
      await prefs.setString(_kSavedEmailKey, _emailCtrl.text.trim());
    } else {
      await prefs.setBool(_kRememberMeKey, false);
      await prefs.remove(_kSavedEmailKey);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await _saveRememberMe();
    final notifier = ref.read(authProvider.notifier);
    final success = await notifier.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  FadeInDown(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('Z',
                                style: AppTextStyles.h3
                                    .copyWith(color: AppColors.textDark)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('ZEBVIX',
                            style:
                                AppTextStyles.h3.copyWith(letterSpacing: 3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back', style: AppTextStyles.h2),
                        const SizedBox(height: 6),
                        Text('Sign in to your account',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Error message
                  if (authState.error != null)
                    FadeIn(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(authState.error!,
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.error)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  FadeInLeft(
                    delay: const Duration(milliseconds: 300),
                    child: TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.body,
                      decoration: const InputDecoration(
                        labelText: 'Email / Phone',
                        prefixIcon: Icon(Icons.person_outline_rounded,
                            color: AppColors.textSecondary),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Please enter your email' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 400),
                    child: TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Please enter your password' : null,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // FIX: Remember me now saves email to SharedPreferences
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) => setState(
                                    () => _rememberMe = v ?? false),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Remember me',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            context.push('/auth/forgot-password'),
                        child: Text('Forgot password?',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: ZebButton(
                      label: 'Sign In',
                      onPressed: _login,
                      isLoading: authState.isLoading,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(color: AppColors.borderColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or continue with',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textHint)),
                      ),
                      const Expanded(
                          child: Divider(color: AppColors.borderColor)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          icon: 'assets/icons/google.svg',
                          label: 'Google',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          icon: 'assets/icons/apple.svg',
                          label: 'Apple',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push('/auth/register'),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: 'Register',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.primary),
                            ),
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
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ZebCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.login, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodySemiBold),
        ],
      ),
    );
  }
}
