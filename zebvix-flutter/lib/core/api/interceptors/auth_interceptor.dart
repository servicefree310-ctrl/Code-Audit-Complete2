import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../storage/secure_storage.dart';

// Lazy import to avoid circular dependency at creation time.
// authProvider is only read when a 401 actually fires (not on init).
import '../../../features/auth/presentation/providers/auth_provider.dart';

// Backend uses server-side sessions (14-day expiry).
// The "token" returned on login IS the session token — there is no
// separate refresh token or refresh endpoint on this backend.
// On 401 we clear local storage AND update authProvider state so
// the router's refreshListenable triggers a redirect to login.
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  // ignore: unused_field
  final Dio _dio;
  final Ref _ref;

  AuthInterceptor(this._secureStorage, this._dio, this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Clear stored credentials
      await _secureStorage.clearAll();
      // Update in-memory auth state — this triggers the router's
      // refreshListenable and automatically redirects to /auth/login
      _ref.read(authProvider.notifier).onSessionExpired();
    }
    handler.next(err);
  }
}
