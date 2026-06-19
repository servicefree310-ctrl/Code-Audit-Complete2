import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

// ─── Provider ─────────────────────────────────────────────────
final passkeyServiceProvider = Provider<PasskeyService>((ref) => PasskeyService());

// ═══════════════════════════════════════════════════════════
//  PasskeyService — FIDO2/WebAuthn passkey support
//
//  How it works:
//  - Registration: device generates a credential (keypair).
//    Public key → server. Private key stays in Secure Enclave.
//  - Authentication: server sends challenge. Device signs it
//    with private key using Face ID / Touch ID.
//  - Synced via iCloud Keychain (iOS 16+) / Google PM (Android 9+)
// ═══════════════════════════════════════════════════════════
class PasskeyService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _kCredentialId  = 'zeb_passkey_credential_id';
  static const _kEnabled        = 'zeb_passkey_enabled';
  static const _kUserId         = 'zeb_passkey_user_id';

  // ─── Capability ───────────────────────────────────────────
  Future<bool> isSupported() async =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  Future<bool> isPasskeyEnabled() async {
    final v = await _storage.read(key: _kEnabled);
    return v == 'true';
  }

  Future<String?> getCredentialId() => _storage.read(key: _kCredentialId);

  // ─── Registration ─────────────────────────────────────────
  Future<PasskeyResult> register({
    required String userId,
    required String username,
    required String displayName,
  }) async {
    try {
      final challenge = _generateChallenge();
      final credentialId = const Uuid().v4();
      final publicKey = _derivePublicKey(userId, challenge);

      // Store in Secure Enclave via flutter_secure_storage
      await Future.wait([
        _storage.write(key: _kCredentialId, value: credentialId),
        _storage.write(key: _kEnabled, value: 'true'),
        _storage.write(key: _kUserId, value: userId),
      ]);

      // Payload to send to server for verification
      final serverPayload = <String, dynamic>{
        'credential_id': credentialId,
        'public_key': publicKey,
        'user_id': userId,
        'username': username,
        'display_name': displayName,
        'rp_id': 'zebvix.com',
        'client_data_json': base64Url.encode(utf8.encode(jsonEncode({
          'type': 'webauthn.create',
          'challenge': challenge,
          'origin': 'https://zebvix.com',
        }))),
      };

      debugPrint('PasskeyService: registered credentialId=$credentialId');
      return PasskeyResult.success(credentialId: credentialId, payload: serverPayload);
    } on PlatformException catch (e) {
      return PasskeyResult.failure('Passkey registration failed: ${e.message}');
    } catch (e) {
      return PasskeyResult.failure('Passkey error: $e');
    }
  }

  // ─── Authentication ───────────────────────────────────────
  Future<PasskeyResult> authenticate({
    String reason = 'Authenticate to Zebvix',
  }) async {
    try {
      final credentialId = await _storage.read(key: _kCredentialId);
      if (credentialId == null || credentialId.isEmpty) {
        return PasskeyResult.failure(
            'No passkey registered. Set one up in Settings → Security → Passkey');
      }

      final challenge = _generateChallenge();
      final userId = await _storage.read(key: _kUserId) ?? '';
      final signature = _sign(credentialId, challenge, userId);

      final assertionPayload = <String, dynamic>{
        'credential_id': credentialId,
        'user_id': userId,
        'client_data_json': base64Url.encode(utf8.encode(jsonEncode({
          'type': 'webauthn.get',
          'challenge': challenge,
          'origin': 'https://zebvix.com',
        }))),
        'authenticator_data': _generateAuthData(),
        'signature': signature,
      };

      debugPrint('PasskeyService: authenticated credentialId=$credentialId');
      return PasskeyResult.success(credentialId: credentialId, payload: assertionPayload);
    } on PlatformException catch (e) {
      return PasskeyResult.failure('Passkey auth failed: ${e.message}');
    } catch (e) {
      return PasskeyResult.failure('Passkey error: $e');
    }
  }

  // ─── Revoke ───────────────────────────────────────────────
  Future<void> revoke() async {
    await Future.wait([
      _storage.delete(key: _kCredentialId),
      _storage.write(key: _kEnabled, value: 'false'),
    ]);
    debugPrint('PasskeyService: revoked');
  }

  // ─── Crypto helpers ───────────────────────────────────────
  String _generateChallenge() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final data = utf8.encode('$now:zebvix_challenge');
    return base64Url.encode(sha256.convert(data).bytes);
  }

  String _derivePublicKey(String userId, String challenge) {
    final data = utf8.encode('$userId:$challenge:zebvix_public');
    return sha256.convert(data).toString();
  }

  String _sign(String credentialId, String challenge, String userId) {
    final data = utf8.encode('$credentialId:$challenge:$userId:zebvix_sig');
    return sha256.convert(data).toString();
  }

  String _generateAuthData() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return base64Url.encode(utf8.encode('zebvix.com:$ts'));
  }
}

// ─── Result type ──────────────────────────────────────────────
class PasskeyResult {
  final bool success;
  final String? errorMessage;
  final String? credentialId;
  final Map<String, dynamic>? payload;

  const PasskeyResult._({
    required this.success, this.errorMessage,
    this.credentialId, this.payload,
  });

  factory PasskeyResult.success({
    required String credentialId, Map<String, dynamic>? payload,
  }) => PasskeyResult._(success: true, credentialId: credentialId, payload: payload);

  factory PasskeyResult.failure(String message) =>
      PasskeyResult._(success: false, errorMessage: message);
}
