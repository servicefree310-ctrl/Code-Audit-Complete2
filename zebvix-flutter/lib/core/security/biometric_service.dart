import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/secure_storage.dart';

// ─── Provider ────────────────────────────────────────────────
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService(ref.read(secureStorageProvider));
});

// ─── Biometric type ───────────────────────────────────────────
enum ZebBiometricType { fingerprint, faceId, iris, passkey, none }

// ─── Auth result ──────────────────────────────────────────────
class BiometricResult {
  final bool success;
  final String? errorMessage;
  final ZebBiometricError? error;

  const BiometricResult._({required this.success, this.errorMessage, this.error});

  factory BiometricResult.success() => const BiometricResult._(success: true);
  factory BiometricResult.failure(ZebBiometricError err, [String? msg]) =>
      BiometricResult._(success: false, error: err, errorMessage: msg);
}

enum ZebBiometricError {
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  userCancelled,
  passcodeNotSet,
  unknown,
}

// ═══════════════════════════════════════════════════════════
//  BiometricService
// ═══════════════════════════════════════════════════════════
class BiometricService {
  final SecureStorage _storage;
  final _auth = LocalAuthentication();

  // SharedPreferences keys for lockout counters (non-sensitive data)
  static const _kFailCount  = 'zeb_bio_fail_count';
  static const _kLockUntil  = 'zeb_bio_lock_until';

  static const int _maxFails        = 5;
  static const int _lockDurationSec = 30;

  BiometricService(this._storage);

  // ─── Capability checks ────────────────────────────────────
  Future<bool> isDeviceSupported() => _auth.isDeviceSupported();

  Future<bool> canCheckBiometrics() async {
    try { return await _auth.canCheckBiometrics; }
    catch (_) { return false; }
  }

  Future<List<ZebBiometricType>> getAvailableTypes() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      return types.map((t) => switch (t) {
        BiometricType.face        => ZebBiometricType.faceId,
        BiometricType.fingerprint => ZebBiometricType.fingerprint,
        BiometricType.iris        => ZebBiometricType.iris,
        _                         => ZebBiometricType.none,
      }).where((t) => t != ZebBiometricType.none).toList();
    } catch (_) { return []; }
  }

  Future<ZebBiometricType> getPrimaryType() async {
    final types = await getAvailableTypes();
    if (types.contains(ZebBiometricType.faceId))       return ZebBiometricType.faceId;
    if (types.contains(ZebBiometricType.fingerprint))  return ZebBiometricType.fingerprint;
    if (types.contains(ZebBiometricType.iris))         return ZebBiometricType.iris;
    return ZebBiometricType.none;
  }

  // ─── Settings ─────────────────────────────────────────────
  Future<bool> isBiometricEnabled() => _storage.isBiometricEnabled();
  Future<void> setBiometricEnabled(bool v) => _storage.setBiometricEnabled(v);

  // ─── Lockout ──────────────────────────────────────────────
  Future<bool> isLockedOut() async {
    final until = await _getLockUntil();
    if (until == 0) return false;
    if (DateTime.now().millisecondsSinceEpoch < until) return true;
    // Expired — clear
    await _clearLockout();
    return false;
  }

  Future<Duration?> lockoutRemaining() async {
    final until = await _getLockUntil();
    if (until == 0) return null;
    final ms = until - DateTime.now().millisecondsSinceEpoch;
    if (ms <= 0) { await _clearLockout(); return null; }
    return Duration(milliseconds: ms);
  }

  Future<void> _recordFailure() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_kFailCount) ?? 0) + 1;
    await prefs.setInt(_kFailCount, count);
    if (count >= _maxFails) {
      final until = DateTime.now()
          .add(const Duration(seconds: _lockDurationSec))
          .millisecondsSinceEpoch;
      await prefs.setInt(_kLockUntil, until);
      await prefs.setInt(_kFailCount, 0);
    }
  }

  Future<void> _clearLockout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFailCount, 0);
    await prefs.setInt(_kLockUntil, 0);
  }

  Future<int> _getLockUntil() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kLockUntil) ?? 0;
  }

  // ─── Main authenticate ────────────────────────────────────
  Future<BiometricResult> authenticate({
    String reason = 'Verify your identity to open Zebvix',
    bool biometricOnly = false,
    bool stickyAuth = true,
  }) async {
    if (await isLockedOut()) {
      final rem = await lockoutRemaining();
      return BiometricResult.failure(
        ZebBiometricError.lockedOut,
        'Too many attempts. Try again in ${rem?.inSeconds ?? 0}s',
      );
    }
    if (!await isDeviceSupported()) {
      return BiometricResult.failure(
        ZebBiometricError.notAvailable,
        'Biometrics not available on this device',
      );
    }
    if (!await canCheckBiometrics()) {
      return BiometricResult.failure(
        ZebBiometricError.notEnrolled,
        'No biometrics enrolled. Go to Settings → Security → Biometrics',
      );
    }
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
      if (ok) {
        await _clearLockout();
        return BiometricResult.success();
      } else {
        await _recordFailure();
        return BiometricResult.failure(ZebBiometricError.userCancelled, 'Authentication cancelled');
      }
    } on PlatformException catch (e) {
      debugPrint('BiometricService error: ${e.code} — ${e.message}');
      await _recordFailure();
      return _mapError(e);
    } catch (e) {
      await _recordFailure();
      return BiometricResult.failure(ZebBiometricError.unknown, e.toString());
    }
  }

  // ─── For sensitive transactions (withdraw, 2FA bypass) ────
  Future<BiometricResult> authenticateForTransaction(String description) =>
      authenticate(
        reason: 'Confirm: $description',
        biometricOnly: true,
        stickyAuth: false,
      );

  Future<void> stopAuthentication() async {
    try { await _auth.stopAuthentication(); } catch (_) {}
  }

  // ─── Error mapping ────────────────────────────────────────
  BiometricResult _mapError(PlatformException e) => switch (e.code) {
    auth_error.notAvailable         => BiometricResult.failure(ZebBiometricError.notAvailable, 'Biometric hardware unavailable'),
    auth_error.notEnrolled          => BiometricResult.failure(ZebBiometricError.notEnrolled, 'No biometrics enrolled. Set up fingerprint/Face ID in Settings'),
    auth_error.lockedOut            => BiometricResult.failure(ZebBiometricError.lockedOut, 'Too many attempts. Try again shortly'),
    auth_error.permanentlyLockedOut => BiometricResult.failure(ZebBiometricError.permanentlyLockedOut, 'Biometric permanently locked. Unlock device first'),
    auth_error.passcodeNotSet       => BiometricResult.failure(ZebBiometricError.passcodeNotSet, 'No device passcode set. Go to Settings → Security'),
    _                               => BiometricResult.failure(ZebBiometricError.unknown, e.message ?? 'Authentication failed'),
  };
}
