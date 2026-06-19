import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'app_lock_service.dart';
import 'biometric_service.dart';
import '../storage/secure_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/zeb_button.dart';

// ═══════════════════════════════════════════════════════════
//  AppLockWrapper — wraps whole app, shows lock screen
//  when AppLockState == locked AND user is logged in.
//  FIX: Do not show lock screen on splash/auth routes —
//  only logged-in users should see the biometric lock.
// ═══════════════════════════════════════════════════════════
class AppLockWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AppLockWrapper({super.key, required this.child});

  @override
  ConsumerState<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends ConsumerState<AppLockWrapper>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlockIfLoggedIn());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(appLockProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        lock.onAppResumed();
        if (ref.read(appLockProvider) == AppLockState.locked) {
          Future.delayed(const Duration(milliseconds: 300), _tryUnlockIfLoggedIn);
        }
      case AppLifecycleState.paused:
        lock.onAppPaused();
      case AppLifecycleState.detached:
        lock.onAppDetached();
      default:
        break;
    }
  }

  // FIX: Only attempt unlock if user is actually logged in —
  // unauthenticated users (splash / auth screens) must never see the lock overlay.
  Future<void> _tryUnlockIfLoggedIn() async {
    final storage = ref.read(secureStorageProvider);
    final isLoggedIn = await storage.isLoggedIn();
    if (!isLoggedIn) {
      // Not logged in — skip lock entirely
      ref.read(appLockProvider.notifier).skipLock();
      return;
    }
    final lockState = ref.read(appLockProvider);
    if (lockState == AppLockState.locked) {
      await ref.read(appLockProvider.notifier).unlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockProvider);

    return Stack(
      children: [
        widget.child,
        if (lockState == AppLockState.locked ||
            lockState == AppLockState.authenticating ||
            lockState == AppLockState.lockedOut)
          _LockScreen(
            lockState: lockState,
            onUnlock: _tryUnlockIfLoggedIn,
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Lock Screen UI
// ═══════════════════════════════════════════════════════════
class _LockScreen extends ConsumerStatefulWidget {
  final AppLockState lockState;
  final VoidCallback onUnlock;

  const _LockScreen({required this.lockState, required this.onUnlock});

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  String? _errorMessage;
  ZebBiometricType _primaryType = ZebBiometricType.fingerprint;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _detectBiometricType();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _detectBiometricType() async {
    final svc = ref.read(biometricServiceProvider);
    final type = await svc.getPrimaryType();
    if (mounted) setState(() => _primaryType = type);
  }

  Future<void> _authenticate() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(appLockProvider.notifier).unlock();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.success ? null : result.errorMessage;
      });
    }
  }

  IconData get _biometricIcon {
    switch (_primaryType) {
      case ZebBiometricType.faceId:
        return Icons.face_retouching_natural_rounded;
      case ZebBiometricType.iris:
        return Icons.remove_red_eye_rounded;
      case ZebBiometricType.fingerprint:
      default:
        return Icons.fingerprint_rounded;
    }
  }

  String get _biometricLabel {
    switch (_primaryType) {
      case ZebBiometricType.faceId:
        return 'Face ID';
      case ZebBiometricType.iris:
        return 'Iris Scan';
      case ZebBiometricType.fingerprint:
      default:
        return 'Fingerprint';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0E11), Color(0xFF1A1F27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                FadeInDown(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Z',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Zebvix Exchange', style: AppTextStyles.h3),
                      const SizedBox(height: 8),
                      Text(
                        'App is locked for your security',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                FadeInUp(
                  child: widget.lockState == AppLockState.lockedOut
                      ? _buildLockedOutUI()
                      : _buildBiometricUI(),
                ),

                const Spacer(),

                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Column(
                    children: [
                      // FIX: "Use PIN instead" now triggers PIN screen navigation
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/auth/pin');
                        },
                        icon: const Icon(Icons.pin_outlined,
                            size: 18, color: AppColors.textSecondary),
                        label: Text(
                          'Use PIN instead',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Secured by phone biometrics',
                        style: AppTextStyles.micro
                            .copyWith(color: AppColors.textHint),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricUI() {
    return Column(
      children: [
        GestureDetector(
          onTap: _authenticate,
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140 + 20 * _pulseCtrl.value,
                  height: 140 + 20 * _pulseCtrl.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary
                          .withOpacity(0.15 * (1 - _pulseCtrl.value)),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1.5),
                  ),
                ),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary
                            .withOpacity(0.2 + 0.1 * _pulseCtrl.value),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(28),
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2.5),
                        )
                      : Icon(_biometricIcon,
                          color: AppColors.primary, size: 48),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          _isLoading ? 'Verifying...' : 'Tap to use $_biometricLabel',
          style: AppTextStyles.h5.copyWith(
            color: _isLoading ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bearish.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.bearish.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.bearish, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.bearish),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            'Your biometric data stays on this device',
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 32),
        if (!_isLoading)
          SizedBox(
            width: double.infinity,
            child: ZebButton(
              label: 'Unlock with $_biometricLabel',
              onPressed: _authenticate,
              icon: _biometricIcon,
            ),
          ),
      ],
    );
  }

  Widget _buildLockedOutUI() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bearish.withOpacity(0.1),
            border: Border.all(color: AppColors.bearish, width: 2),
          ),
          child: const Icon(Icons.lock_outline_rounded,
              color: AppColors.bearish, size: 44),
        ),
        const SizedBox(height: 24),
        Text('Too Many Attempts',
            style: AppTextStyles.h4.copyWith(color: AppColors.bearish)),
        const SizedBox(height: 8),
        Text(
          'Too many failed attempts.\nPlease wait before trying again.',
          style:
              AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _LockoutCountdown(
          onExpired: () => ref.read(appLockProvider.notifier).lockNow(),
        ),
      ],
    );
  }
}

// ─── Lockout countdown timer ──────────────────────────────────
class _LockoutCountdown extends ConsumerStatefulWidget {
  final VoidCallback onExpired;
  const _LockoutCountdown({required this.onExpired});

  @override
  ConsumerState<_LockoutCountdown> createState() => _LockoutCountdownState();
}

class _LockoutCountdownState extends ConsumerState<_LockoutCountdown> {
  Timer? _timer;
  int _remaining = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final rem =
          await ref.read(biometricServiceProvider).lockoutRemaining();
      if (rem == null) {
        _timer?.cancel();
        widget.onExpired();
      } else {
        if (mounted) setState(() => _remaining = rem.inSeconds);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '0:${_remaining.toString().padLeft(2, '0')}',
          style: AppTextStyles.h2.copyWith(color: AppColors.bearish),
        ),
        const SizedBox(height: 8),
        Text('seconds remaining', style: AppTextStyles.caption),
      ],
    );
  }
}
