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
        exception = const AppException.network('Connection timed out. Please try again.');
        break;
      case DioExceptionType.connectionError:
        exception = const AppException.network('No internet connection. Please check your network.');
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _extractMessage(err.response?.data);
        switch (statusCode) {
          case 400:
            exception = AppException.badRequest(message ?? 'Invalid request.');
            break;
          case 401:
            exception = AppException.unauthorized(message ?? 'Session expired. Please login again.');
            break;
          case 403:
            exception = AppException.forbidden(message ?? 'Access denied.');
            break;
          case 404:
            exception = AppException.notFound(message ?? 'Resource not found.');
            break;
          case 422:
            exception = AppException.validation(message ?? 'Validation failed.', err.response?.data);
            break;
          case 429:
            exception = const AppException.tooManyRequests('Too many requests. Please slow down.');
            break;
          case 500:
          case 502:
          case 503:
            exception = AppException.server(message ?? 'Server error. Please try again later.');
            break;
          default:
            exception = AppException.unknown(message ?? 'An unexpected error occurred.');
        }
        break;
      default:
        exception = AppException.unknown(err.message ?? 'An unexpected error occurred.');
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
