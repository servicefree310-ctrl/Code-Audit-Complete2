import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'biometric_service.dart';
import '../storage/secure_storage.dart';

// ─── Lock state ───────────────────────────────────────────────
enum AppLockState { unlocked, locked, authenticating, lockedOut }

// ═══════════════════════════════════════════════════════════
//  AppLockNotifier
// ═══════════════════════════════════════════════════════════
class AppLockNotifier extends StateNotifier<AppLockState> {
  final BiometricService _biometricService;
  final SecureStorage _storage;

  static const _bgThresholdSecs = 30;
  DateTime? _backgroundedAt;
  Timer? _autoLockTimer;

  AppLockNotifier(this._biometricService, this._storage)
      : super(AppLockState.locked);

  // ─── Auth method ──────────────────────────────────────────
  Future<String> getAuthMethod() async {
    final biometricOn = await _storage.isBiometricEnabled();
    if (biometricOn) return 'biometric';
    final pin = await _storage.getPin();
    if (pin != null && pin.isNotEmpty) return 'pin';
    return 'none';
  }

  // ─── Lifecycle ────────────────────────────────────────────
  void onAppResumed() {
    _autoLockTimer?.cancel();
    final bg = _backgroundedAt;
    _backgroundedAt = null;
    if (bg == null) return;
    if (DateTime.now().difference(bg).inSeconds >= _bgThresholdSecs) {
      state = AppLockState.locked;
    }
  }

  void onAppPaused() {
    _backgroundedAt = DateTime.now();
    _autoLockTimer?.cancel();
    _autoLockTimer = Timer(
      const Duration(seconds: _bgThresholdSecs),
      () { if (mounted) state = AppLockState.locked; },
    );
  }

  void onAppDetached() => state = AppLockState.locked;

  // ─── Unlock ───────────────────────────────────────────────
  Future<BiometricResult> unlock() async {
    if (state == AppLockState.authenticating) {
      return BiometricResult.failure(ZebBiometricError.unknown, 'Already authenticating');
    }
    if (await _biometricService.isLockedOut()) {
      state = AppLockState.lockedOut;
      final rem = await _biometricService.lockoutRemaining();
      return BiometricResult.failure(ZebBiometricError.lockedOut, 'Locked out for ${rem?.inSeconds ?? 0}s');
    }

    state = AppLockState.authenticating;
    final result = await _biometricService.authenticate(
      reason: 'Unlock Zebvix Exchange',
      biometricOnly: false,
      stickyAuth: true,
    );

    if (!mounted) return result;
    state = result.success
        ? AppLockState.unlocked
        : (result.error == ZebBiometricError.lockedOut ||
               result.error == ZebBiometricError.permanentlyLockedOut)
            ? AppLockState.lockedOut
            : AppLockState.locked;
    return result;
  }

  void lockNow() {
    _autoLockTimer?.cancel();
    state = AppLockState.locked;
  }

  /// Call when biometrics not set up — skip lock
  void skipLock() => state = AppLockState.unlocked;

  @override
  void dispose() {
    _autoLockTimer?.cancel();
    super.dispose();
  }
}

// ─── Provider ────────────────────────────────────────────────
final appLockProvider =
    StateNotifierProvider<AppLockNotifier, AppLockState>((ref) {
  return AppLockNotifier(
    ref.read(biometricServiceProvider),
    ref.read(secureStorageProvider),
  );
});
