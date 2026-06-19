import 'package:dio/dio.dart';
import '../../errors/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = const AppException.timeout(
            message: 'Connection timed out. Please try again.');
        break;
      case DioExceptionType.connectionError:
        exception = const AppException.network(
            message: 'No internet connection. Please check your network.');
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _extractMessage(err.response?.data);
        switch (statusCode) {
          case 400:
            exception = AppException.unknown(
              message: message ?? 'Invalid request.',
              statusCode: statusCode,
            );
            break;
          case 401:
            exception = AppException.unauthorized(
              message: message ?? 'Session expired. Please login again.',
              statusCode: statusCode,
            );
            break;
          case 403:
            exception = AppException.forbidden(
              message: message ?? 'Access denied.',
              statusCode: statusCode,
            );
            break;
          case 404:
            exception = AppException.notFound(
              message: message ?? 'Resource not found.',
              statusCode: statusCode,
            );
            break;
          case 422:
            exception = AppException.validation(
              message: message ?? 'Validation failed.',
              statusCode: statusCode,
            );
            break;
          case 429:
            exception = const AppException.unknown(
              message: 'Too many requests. Please slow down.',
              statusCode: 429,
            );
            break;
          case 500:
          case 502:
          case 503:
            exception = AppException.server(
              message: message ?? 'Server error. Please try again later.',
              statusCode: statusCode,
            );
            break;
          default:
            exception = AppException.unknown(
              message: message ?? 'An unexpected error occurred.',
              statusCode: statusCode,
            );
        }
        break;
      default:
        exception = AppException.unknown(
            message: err.message ?? 'An unexpected error occurred.');
    }

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
      response: err.response,
      type: err.type,
    ));
  }

  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['msg']?.toString();
    }
    return data.toString();
  }
}
