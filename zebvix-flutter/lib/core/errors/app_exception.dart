import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
class AppException with _$AppException implements Exception {
  const factory AppException.network(String message) = NetworkException;
  const factory AppException.unauthorized(String message) = UnauthorizedException;
  const factory AppException.forbidden(String message) = ForbiddenException;
  const factory AppException.notFound(String message) = NotFoundException;
  const factory AppException.badRequest(String message) = BadRequestException;
  const factory AppException.validation(String message, [dynamic errors]) = ValidationException;
  const factory AppException.tooManyRequests(String message) = TooManyRequestsException;
  const factory AppException.server(String message) = ServerException;
  const factory AppException.unknown(String message) = UnknownException;

  const AppException._();

  String get userMessage => when(
    network: (m) => m,
    unauthorized: (m) => m,
    forbidden: (m) => m,
    notFound: (m) => m,
    badRequest: (m) => m,
    validation: (m, _) => m,
    tooManyRequests: (m) => m,
    server: (m) => m,
    unknown: (m) => m,
  );
}
