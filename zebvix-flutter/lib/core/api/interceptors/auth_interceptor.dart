import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';

// Backend uses server-side sessions (14-day expiry).
// The "token" returned on login IS the session token — there is no
// separate refresh token or refresh endpoint on this backend.
// On 401 we simply clear local storage and let the router redirect to login.
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final Dio _dio;

  AuthInterceptor(this._secureStorage, this._dio);

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
      // Session expired or revoked — clear local credentials so the
      // app navigates back to the login screen on the next route guard check.
      await _secureStorage.clearAll();
    }
    handler.next(err);
  }
}
