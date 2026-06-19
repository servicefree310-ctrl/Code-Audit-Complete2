import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/security/app_lock_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_button.dart';

// ═══════════════════════════════════════════════════════════
//  BiometricScreen — first-run biometric setup / re-auth
//  Handles: Fingerprint, Face ID, Iris, Passkey
// ═══════════════════════════════════════════════════════════
class BiometricScreen extends ConsumerStatefulWidget {
  /// If true, this is initial setup (Save preference)
  /// If false, this is authentication (unlock / confirm)
  final bool isSetup;
  const BiometricScreen({super.key, this.isSetup = false});

  @override
  ConsumerState<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends ConsumerState<BiometricScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  bool _isAuthenticating = false;
  bool _supported = false;
  bool _enrolled = false;
  ZebBiometricType _primaryType = ZebBiometricType.fingerprint;
  List<ZebBiometricType> _availableTypes = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _checkBiometrics();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    final svc = ref.read(biometricServiceProvider);
    final supported = await svc.isDeviceSupported();
    final canCheck = await svc.canCheckBiometrics();
    final types = await svc.getAvailableTypes();
    final primary = await svc.getPrimaryType();

    if (mounted) {
      setState(() {
        _supported = supported;
        _enrolled = canCheck && types.isNotEmpty;
        _availableTypes = types;
        _primaryType = primary;
      });
      // Auto-trigger auth if not setup mode
      if (!widget.isSetup && _enrolled) {
        await Future.delayed(const Duration(milliseconds: 600));
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() { _isAuthenticating = true; _errorMessage = null; });

    final svc = ref.read(biometricServiceProvider);
    final result = await svc.authenticate(
      reason: widget.isSetup
          ? 'Verify your biometric to enable app lock'
          : 'Authenticate to access Zebvix Exchange',
      biometricOnly: false,
      stickyAuth: true,
    );

    if (!mounted) return;
    setState(() => _isAuthenticating = false);

    if (result.success) {
      if (widget.isSetup) {
        await svc.setBiometricEnabled(true);
        // Mark app as unlocked
        ref.read(appLockProvider.notifier).skipLock();
        context.go('/home');
      } else {
        ref.read(appLockProvider.notifier).skipLock();
        context.go('/home');
      }
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  // ─── Biometric icon & label ──────────────────────────────
  IconData get _biometricIcon => switch (_primaryType) {
    ZebBiometricType.faceId     => Icons.face_retouching_natural_rounded,
    ZebBiometricType.iris       => Icons.remove_red_eye_outlined,
    ZebBiometricType.passkey    => Icons.vpn_key_rounded,
    _                           => Icons.fingerprint_rounded,
  };

  String get _biometricLabel => switch (_primaryType) {
    ZebBiometricType.faceId  => 'Face ID',
    ZebBiometricType.iris    => 'Iris Scan',
    ZebBiometricType.passkey => 'Passkey',
    _                        => 'Fingerprint',
  };

  Color get _biometricColor => _primaryType == ZebBiometricType.faceId
      ? const Color(0xFF4A90E2)
      : AppColors.primary;

  // ─── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0E11), Color(0xFF151A21), Color(0xFF0B0E11)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // ── Top bar ───────────────────────────────
                if (!widget.isSetup)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go('/auth/pin'),
                      child: Text('Use PIN', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                    ),
                  ),

                const Spacer(flex: 2),

                // ── Logo + title ──────────────────────────
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      // App logo
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('Z',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Zebvix Exchange', style: AppTextStyles.h3),
                      const SizedBox(height: 6),
                      Text(
                        widget.isSetup
                            ? 'Enable biometric login for\nfast & secure access'
                            : 'Welcome back!\nVerify to continue',
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Biometric button (pulsing ring) ───────
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: _supported
                      ? _enrolled
                          ? _buildBiometricButton()
                          : _buildNotEnrolledUI()
                      : _buildNotSupportedUI(),
                ),

                const Spacer(),

                // ── Available types row ───────────────────
                if (_availableTypes.length > 1)
                  FadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: _buildTypeChips(),
                  ),

                const SizedBox(height: 20),

                // ── Bottom options ─────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      if (!widget.isSetup) ...[
                        TextButton.icon(
                          onPressed: () => context.go('/auth/pin'),
                          icon: Icon(Icons.pin_outlined, size: 16, color: AppColors.textSecondary),
                          label: Text('Use PIN instead', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (widget.isSetup) ...[
                        TextButton(
                          onPressed: () => context.go('/auth/pin'),
                          child: Text('Skip for now', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 6),
                          Text(
                            'Biometric data stays on your device',
                            style: AppTextStyles.micro.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Pulsing biometric button ────────────────────────────
  Widget _buildBiometricButton() {
    return Column(
      children: [
        // Tap area
        GestureDetector(
          onTap: _isAuthenticating ? null : _authenticate,
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                // Outermost ring
                Container(
                  width: 160 + 24 * _pulseCtrl.value,
                  height: 160 + 24 * _pulseCtrl.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _biometricColor.withOpacity(0.08 * (1 - _pulseCtrl.value)),
                      width: 2,
                    ),
                  ),
                ),
                // Middle ring
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _biometricColor.withOpacity(0.18 + 0.1 * _pulseCtrl.value),
                      width: 1.5,
                    ),
                  ),
                ),
                // Inner ring
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _biometricColor.withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                ),
                // Core icon button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: _biometricColor,
                      width: _isAuthenticating ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _biometricColor.withOpacity(0.25 + 0.15 * _pulseCtrl.value),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: _isAuthenticating
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: _biometricColor,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(_biometricIcon, color: _biometricColor, size: 44),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // State label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _isAuthenticating ? 'Verifying $_biometricLabel...' : 'Touch to authenticate',
            key: ValueKey(_isAuthenticating),
            style: AppTextStyles.h5.copyWith(
              color: _isAuthenticating ? _biometricColor : AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Error message
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: _errorMessage != null
              ? Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bearish.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.bearish.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.bearish, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.bearish),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 28),

        // Retry button
        if (!_isAuthenticating)
          SizedBox(
            width: double.infinity,
            child: ZebButton(
              label: widget.isSetup ? 'Enable $_biometricLabel Login' : 'Unlock with $_biometricLabel',
              onPressed: _authenticate,
              icon: _biometricIcon,
            ),
          ),
      ],
    );
  }

  // ─── Not enrolled UI ────────────────────────────────────
  Widget _buildNotEnrolledUI() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.warning.withOpacity(0.1),
            border: Border.all(color: AppColors.warning, width: 2),
          ),
          child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 44),
        ),
        const SizedBox(height: 20),
        Text('No Biometrics Enrolled', style: AppTextStyles.h5),
        const SizedBox(height: 8),
        Text(
          'Go to your phone Settings →\nSecurity → Biometrics / Face ID\nand enroll your fingerprint.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        ZebButton(
          label: 'Use PIN Instead',
          variant: ZebButtonVariant.outline,
          onPressed: () => context.go('/auth/pin'),
          icon: Icons.pin_outlined,
        ),
      ],
    );
  }

  // ─── Not supported UI ────────────────────────────────────
  Widget _buildNotSupportedUI() {
    return Column(
      children: [
        const Icon(Icons.no_cell_rounded, color: AppColors.textSecondary, size: 64),
        const SizedBox(height: 16),
        Text('Biometrics Not Available', style: AppTextStyles.h5),
        const SizedBox(height: 8),
        Text(
          'This device does not support biometric authentication.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        ZebButton(label: 'Continue with PIN', onPressed: () => context.go('/auth/pin')),
      ],
    );
  }

  // ─── Type chips ──────────────────────────────────────────
  Widget _buildTypeChips() {
    return Wrap(
      spacing: 8,
      children: _availableTypes.map((t) {
        final isActive = t == _primaryType;
        final label = switch (t) {
          ZebBiometricType.faceId     => 'Face ID',
          ZebBiometricType.fingerprint => 'Fingerprint',
          ZebBiometricType.iris       => 'Iris',
          _                           => 'Passkey',
        };
        return GestureDetector(
          onTap: () => setState(() => _primaryType = t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
