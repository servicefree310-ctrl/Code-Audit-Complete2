import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
class AppException with _$AppException implements Exception {
  const factory AppException.network({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = _NetworkException;

  const factory AppException.server({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = _ServerException;

  const factory AppException.unauthorized({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = _UnauthorizedException;

  const factory AppException.forbidden({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = _ForbiddenException;

  const factory AppException.notFound({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = _NotFoundException;

  const factory AppException.validation({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = _ValidationException;

  const factory AppException.timeout({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = _TimeoutException;

  const factory AppException.cancelled({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = _CancelledException;

  const factory AppException.unknown({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = _UnknownException;

  const AppException._();

  String get userMessage => when(
        network: (m, s, e) => m,
        server: (m, s, e) => m,
        unauthorized: (m, s, e) => m,
        forbidden: (m, s, e) => m,
        notFound: (m, s, e) => m,
        validation: (m, s, e) => m,
        timeout: (m, s, e) => m,
        cancelled: (m, s, e) => m,
        unknown: (m, s, e) => m,
      );
}
