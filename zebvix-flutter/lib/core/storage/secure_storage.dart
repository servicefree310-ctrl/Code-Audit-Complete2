import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Backend uses 14-day server-side sessions — one token, no refresh flow.
  // "refreshToken" param is accepted for API compatibility but ignored (stored as empty).
  Future<void> saveTokens({
    required String accessToken,
    String refreshToken = '',
  }) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  // Always returns null — backend has no refresh token endpoint.
  Future<String?> getRefreshToken() async => null;

  Future<void> saveUserData(Map<String, dynamic> userData) =>
      _storage.write(key: AppConstants.userDataKey, value: jsonEncode(userData));

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: AppConstants.userDataKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> savePin(String pin) =>
      _storage.write(key: AppConstants.pinKey, value: pin);

  Future<String?> getPin() => _storage.read(key: AppConstants.pinKey);

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: AppConstants.biometricKey, value: enabled.toString());

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: AppConstants.biometricKey);
    return value == 'true';
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
