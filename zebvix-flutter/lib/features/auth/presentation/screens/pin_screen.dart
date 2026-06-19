import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/secure_storage.dart';

class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  final _ctrl = TextEditingController();
  String _pin = '';
  bool _error = false;

  Future<void> _verify() async {
    final storage = ref.read(secureStorageProvider);
    final savedPin = await storage.getPin();
    if (savedPin == _pin) {
      if (mounted) context.go('/home');
    } else {
      setState(() { _error = true; _pin = ''; _ctrl.clear(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                child: Center(child: Text('Z', style: AppTextStyles.h2.copyWith(color: AppColors.textDark))),
              ),
              const SizedBox(height: 32),
              Text('Enter PIN', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text('Enter your 6-digit PIN to continue',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _ctrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.circle,
                  fieldHeight: 52,
                  fieldWidth: 52,
                  activeFillColor: AppColors.surfaceLight,
                  inactiveFillColor: AppColors.surface,
                  selectedFillColor: AppColors.surfaceLight,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.borderColor,
                  selectedColor: AppColors.primary,
                ),
                enableActiveFill: true,
                onChanged: (v) => setState(() { _pin = v; _error = false; }),
                onCompleted: (_) => _verify(),
              ),
              if (_error)
                Text('Incorrect PIN. Please try again.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.error)),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () async {
                  final storage = ref.read(secureStorageProvider);
                  await storage.clearAll();
                  if (mounted) context.go('/auth/login');
                },
                child: Text('Forgot PIN? Sign in again', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
