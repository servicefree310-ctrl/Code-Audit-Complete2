import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final Dio _dio;
  bool _isRefreshing = false;

  // FIX: Use Completer-based queue so pending requests get resolved/rejected correctly
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _pendingQueue = [];

  AuthInterceptor(this._secureStorage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // While a refresh is in progress, queue this request
    if (_isRefreshing) {
      _pendingQueue.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _clearAndRejectAll(err, handler);
        return;
      }

      final response = await _dio.post(
        AppConstants.refreshTokenPath,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final newAccessToken = response.data['accessToken'] as String?;
      final newRefreshToken = response.data['refreshToken'] as String?;

      if (newAccessToken == null) {
        await _clearAndRejectAll(err, handler);
        return;
      }

      await _secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );

      // FIX: Retry queued requests and resolve each handler with its response
      for (final pending in _pendingQueue) {
        try {
          pending.options.headers['Authorization'] = 'Bearer $newAccessToken';
          final retried = await _dio.fetch(pending.options);
          pending.handler.resolve(retried);
        } catch (e) {
          pending.handler.next(err);
        }
      }
      _pendingQueue.clear();

      // Retry the original request
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _clearAndRejectAll(err, handler);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _clearAndRejectAll(DioException err, ErrorInterceptorHandler handler) async {
    await _secureStorage.clearAll();
    // Reject all pending requests so their callers get an error response
    for (final pending in _pendingQueue) {
      pending.handler.next(err);
    }
    _pendingQueue.clear();
    handler.next(err);
  }
}
