// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppException {
  String get message => throw _privateConstructorUsedError;
  int? get statusCode => throw _privateConstructorUsedError;
  String? get errorCode => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? errorCode)
        network,
    required TResult Function(String message, int? statusCode, String? errorCode)
        server,
    required TResult Function(String message, int? statusCode, String? errorCode)
        unauthorized,
    required TResult Function(String message, int? statusCode, String? errorCode)
        forbidden,
    required TResult Function(String message, int? statusCode, String? errorCode)
        notFound,
    required TResult Function(String message, int? statusCode, String? errorCode)
        validation,
    required TResult Function(String message, int? statusCode, String? errorCode)
        timeout,
    required TResult Function(String message, int? statusCode, String? errorCode)
        cancelled,
    required TResult Function(String message, int? statusCode, String? errorCode)
        unknown,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        unauthorized,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        forbidden,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        notFound,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        validation,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        timeout,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        cancelled,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        unknown,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult Function(String message, int? statusCode, String? errorCode)?
        unauthorized,
    TResult Function(String message, int? statusCode, String? errorCode)?
        forbidden,
    TResult Function(String message, int? statusCode, String? errorCode)?
        notFound,
    TResult Function(String message, int? statusCode, String? errorCode)?
        validation,
    TResult Function(String message, int? statusCode, String? errorCode)?
        timeout,
    TResult Function(String message, int? statusCode, String? errorCode)?
        cancelled,
    TResult Function(String message, int? statusCode, String? errorCode)?
        unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NetworkException value) network,
    required TResult Function(_ServerException value) server,
    required TResult Function(_UnauthorizedException value) unauthorized,
    required TResult Function(_ForbiddenException value) forbidden,
    required TResult Function(_NotFoundException value) notFound,
    required TResult Function(_ValidationException value) validation,
    required TResult Function(_TimeoutException value) timeout,
    required TResult Function(_CancelledException value) cancelled,
    required TResult Function(_UnknownException value) unknown,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NetworkException value)? network,
    TResult? Function(_ServerException value)? server,
    TResult? Function(_UnauthorizedException value)? unauthorized,
    TResult? Function(_ForbiddenException value)? forbidden,
    TResult? Function(_NotFoundException value)? notFound,
    TResult? Function(_ValidationException value)? validation,
    TResult? Function(_TimeoutException value)? timeout,
    TResult? Function(_CancelledException value)? cancelled,
    TResult? Function(_UnknownException value)? unknown,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NetworkException value)? network,
    TResult Function(_ServerException value)? server,
    TResult Function(_UnauthorizedException value)? unauthorized,
    TResult Function(_ForbiddenException value)? forbidden,
    TResult Function(_NotFoundException value)? notFound,
    TResult Function(_ValidationException value)? validation,
    TResult Function(_TimeoutException value)? timeout,
    TResult Function(_CancelledException value)? cancelled,
    TResult Function(_UnknownException value)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppExceptionCopyWith<AppException> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $AppExceptionCopyWith<$Res> {
  factory $AppExceptionCopyWith(
          AppException value, $Res Function(AppException) then) =
      _$AppExceptionCopyWithImpl<$Res, AppException>;
  @useResult
  $Res call({String message, int? statusCode, String? errorCode});
}

class _$AppExceptionCopyWithImpl<$Res, $Val extends AppException>
    implements $AppExceptionCopyWith<$Res> {
  _$AppExceptionCopyWithImpl(this._value, this._then);
  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message as String,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode as int?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode as String?,
    ) as $Val);
  }
}

// ─── Network ────────────────────────────────────────────────────────────────

abstract class _$$NetworkExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$NetworkExceptionImplCopyWith(_$NetworkExceptionImpl value,
          $Res Function(_$NetworkExceptionImpl) then) =
      __$$NetworkExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode, String? errorCode});
}

class __$$NetworkExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$NetworkExceptionImpl>
    implements _$$NetworkExceptionImplCopyWith<$Res> {
  __$$NetworkExceptionImplCopyWithImpl(_$NetworkExceptionImpl _value,
      $Res Function(_$NetworkExceptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_$NetworkExceptionImpl(
      message: null == message ? _value.message : message as String,
      statusCode: freezed == statusCode ? _value.statusCode : statusCode as int?,
      errorCode: freezed == errorCode ? _value.errorCode : errorCode as String?,
    ));
  }
}

class _$NetworkExceptionImpl extends _NetworkException {
  const _$NetworkExceptionImpl(
      {required this.message, this.statusCode, this.errorCode})
      : super._();

  @override
  final String message;
  @override
  final int? statusCode;
  @override
  final String? errorCode;

  @override
  String toString() =>
      'AppException.network(message: $message, statusCode: $statusCode, errorCode: $errorCode)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkExceptionImplCopyWith<_$NetworkExceptionImpl> get copyWith =>
      __$$NetworkExceptionImplCopyWithImpl<_$NetworkExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? errorCode) network,
    required TResult Function(String message, int? statusCode, String? errorCode) server,
    required TResult Function(String message, int? statusCode, String? errorCode) unauthorized,
    required TResult Function(String message, int? statusCode, String? errorCode) forbidden,
    required TResult Function(String message, int? statusCode, String? errorCode) notFound,
    required TResult Function(String message, int? statusCode, String? errorCode) validation,
    required TResult Function(String message, int? statusCode, String? errorCode) timeout,
    required TResult Function(String message, int? statusCode, String? errorCode) cancelled,
    required TResult Function(String message, int? statusCode, String? errorCode) unknown,
  }) =>
      network(message, statusCode, errorCode);

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)? network,
    TResult? Function(String message, int? statusCode, String? errorCode)? server,
    TResult? Function(String message, int? statusCode, String? errorCode)? unauthorized,
    TResult? Function(String message, int? statusCode, String? errorCode)? forbidden,
    TResult? Function(String message, int? statusCode, String? errorCode)? notFound,
    TResult? Function(String message, int? statusCode, String? errorCode)? validation,
    TResult? Function(String message, int? statusCode, String? errorCode)? timeout,
    TResult? Function(String message, int? statusCode, String? errorCode)? cancelled,
    TResult? Function(String message, int? statusCode, String? errorCode)? unknown,
  }) =>
      network?.call(message, statusCode, errorCode);

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)? network,
    TResult Function(String message, int? statusCode, String? errorCode)? server,
    TResult Function(String message, int? statusCode, String? errorCode)? unauthorized,
    TResult Function(String message, int? statusCode, String? errorCode)? forbidden,
    TResult Function(String message, int? statusCode, String? errorCode)? notFound,
    TResult Function(String message, int? statusCode, String? errorCode)? validation,
    TResult Function(String message, int? statusCode, String? errorCode)? timeout,
    TResult Function(String message, int? statusCode, String? errorCode)? cancelled,
    TResult Function(String message, int? statusCode, String? errorCode)? unknown,
    required TResult orElse(),
  }) =>
      network != null ? network(message, statusCode, errorCode) : orElse();

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NetworkException value) network,
    required TResult Function(_ServerException value) server,
    required TResult Function(_UnauthorizedException value) unauthorized,
    required TResult Function(_ForbiddenException value) forbidden,
    required TResult Function(_NotFoundException value) notFound,
    required TResult Function(_ValidationException value) validation,
    required TResult Function(_TimeoutException value) timeout,
    required TResult Function(_CancelledException value) cancelled,
    required TResult Function(_UnknownException value) unknown,
  }) =>
      network(this);

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NetworkException value)? network,
    TResult? Function(_ServerException value)? server,
    TResult? Function(_UnauthorizedException value)? unauthorized,
    TResult? Function(_ForbiddenException value)? forbidden,
    TResult? Function(_NotFoundException value)? notFound,
    TResult? Function(_ValidationException value)? validation,
    TResult? Function(_TimeoutException value)? timeout,
    TResult? Function(_CancelledException value)? cancelled,
    TResult? Function(_UnknownException value)? unknown,
  }) =>
      network?.call(this);

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NetworkException value)? network,
    TResult Function(_ServerException value)? server,
    TResult Function(_UnauthorizedException value)? unauthorized,
    TResult Function(_ForbiddenException value)? forbidden,
    TResult Function(_NotFoundException value)? notFound,
    TResult Function(_ValidationException value)? validation,
    TResult Function(_TimeoutException value)? timeout,
    TResult Function(_CancelledException value)? cancelled,
    TResult Function(_UnknownException value)? unknown,
    required TResult orElse(),
  }) =>
      network != null ? network(this) : orElse();
}

abstract class _NetworkException extends AppException {
  const factory _NetworkException(
      {required final String message,
      final int? statusCode,
      final String? errorCode}) = _$NetworkExceptionImpl;
  const _NetworkException._() : super._();

  @override
  String get message;
  @override
  int? get statusCode;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$NetworkExceptionImplCopyWith<_$NetworkExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// ─── Server ─────────────────────────────────────────────────────────────────

abstract class _$$ServerExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$ServerExceptionImplCopyWith(_$ServerExceptionImpl value,
          $Res Function(_$ServerExceptionImpl) then) =
      __$$ServerExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode, String? errorCode});
}

class __$$ServerExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$ServerExceptionImpl>
    implements _$$ServerExceptionImplCopyWith<$Res> {
  __$$ServerExceptionImplCopyWithImpl(
      _$ServerExceptionImpl _value, $Res Function(_$ServerExceptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_$ServerExceptionImpl(
      message: null == message ? _value.message : message as String,
      statusCode: freezed == statusCode ? _value.statusCode : statusCode as int?,
      errorCode: freezed == errorCode ? _value.errorCode : errorCode as String?,
    ));
  }
}

class _$ServerExceptionImpl extends _ServerException {
  const _$ServerExceptionImpl(
      {required this.message, this.statusCode, this.errorCode})
      : super._();

  @override
  final String message;
  @override
  final int? statusCode;
  @override
  final String? errorCode;

  @override
  String toString() =>
      'AppException.server(message: $message, statusCode: $statusCode, errorCode: $errorCode)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerExceptionImplCopyWith<_$ServerExceptionImpl> get copyWith =>
      __$$ServerExceptionImplCopyWithImpl<_$ServerExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? errorCode) network,
    required TResult Function(String message, int? statusCode, String? errorCode) server,
    required TResult Function(String message, int? statusCode, String? errorCode) unauthorized,
    required TResult Function(String message, int? statusCode, String? errorCode) forbidden,
    required TResult Function(String message, int? statusCode, String? errorCode) notFound,
    required TResult Function(String message, int? statusCode, String? errorCode) validation,
    required TResult Function(String message, int? statusCode, String? errorCode) timeout,
    required TResult Function(String message, int? statusCode, String? errorCode) cancelled,
    required TResult Function(String message, int? statusCode, String? errorCode) unknown,
  }) =>
      server(message, statusCode, errorCode);

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)? network,
    TResult? Function(String message, int? statusCode, String? errorCode)? server,
    TResult? Function(String message, int? statusCode, String? errorCode)? unauthorized,
    TResult? Function(String message, int? statusCode, String? errorCode)? forbidden,
    TResult? Function(String message, int? statusCode, String? errorCode)? notFound,
    TResult? Function(String message, int? statusCode, String? errorCode)? validation,
    TResult? Function(String message, int? statusCode, String? errorCode)? timeout,
    TResult? Function(String message, int? statusCode, String? errorCode)? cancelled,
    TResult? Function(String message, int? statusCode, String? errorCode)? unknown,
  }) =>
      server?.call(message, statusCode, errorCode);

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)? network,
    TResult Function(String message, int? statusCode, String? errorCode)? server,
    TResult Function(String message, int? statusCode, String? errorCode)? unauthorized,
    TResult Function(String message, int? statusCode, String? errorCode)? forbidden,
    TResult Function(String message, int? statusCode, String? errorCode)? notFound,
    TResult Function(String message, int? statusCode, String? errorCode)? validation,
    TResult Function(String message, int? statusCode, String? errorCode)? timeout,
    TResult Function(String message, int? statusCode, String? errorCode)? cancelled,
    TResult Function(String message, int? statusCode, String? errorCode)? unknown,
    required TResult orElse(),
  }) =>
      server != null ? server(message, statusCode, errorCode) : orElse();

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NetworkException value) network,
    required TResult Function(_ServerException value) server,
    required TResult Function(_UnauthorizedException value) unauthorized,
    required TResult Function(_ForbiddenException value) forbidden,
    required TResult Function(_NotFoundException value) notFound,
    required TResult Function(_ValidationException value) validation,
    required TResult Function(_TimeoutException value) timeout,
    required TResult Function(_CancelledException value) cancelled,
    required TResult Function(_UnknownException value) unknown,
  }) =>
      server(this);

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NetworkException value)? network,
    TResult? Function(_ServerException value)? server,
    TResult? Function(_UnauthorizedException value)? unauthorized,
    TResult? Function(_ForbiddenException value)? forbidden,
    TResult? Function(_NotFoundException value)? notFound,
    TResult? Function(_ValidationException value)? validation,
    TResult? Function(_TimeoutException value)? timeout,
    TResult? Function(_CancelledException value)? cancelled,
    TResult? Function(_UnknownException value)? unknown,
  }) =>
      server?.call(this);

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NetworkException value)? network,
    TResult Function(_ServerException value)? server,
    TResult Function(_UnauthorizedException value)? unauthorized,
    TResult Function(_ForbiddenException value)? forbidden,
    TResult Function(_NotFoundException value)? notFound,
    TResult Function(_ValidationException value)? validation,
    TResult Function(_TimeoutException value)? timeout,
    TResult Function(_CancelledException value)? cancelled,
    TResult Function(_UnknownException value)? unknown,
    required TResult orElse(),
  }) =>
      server != null ? server(this) : orElse();
}

abstract class _ServerException extends AppException {
  const factory _ServerException(
      {required final String message,
      final int? statusCode,
      final String? errorCode}) = _$ServerExceptionImpl;
  const _ServerException._() : super._();

  @override
  String get message;
  @override
  int? get statusCode;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$ServerExceptionImplCopyWith<_$ServerExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// ─── Unauthorized ────────────────────────────────────────────────────────────

abstract class _$$UnauthorizedExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$UnauthorizedExceptionImplCopyWith(
          _$UnauthorizedExceptionImpl value,
          $Res Function(_$UnauthorizedExceptionImpl) then) =
      __$$UnauthorizedExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode, String? errorCode});
}

class __$$UnauthorizedExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$UnauthorizedExceptionImpl>
    implements _$$UnauthorizedExceptionImplCopyWith<$Res> {
  __$$UnauthorizedExceptionImplCopyWithImpl(_$UnauthorizedExceptionImpl _value,
      $Res Function(_$UnauthorizedExceptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_$UnauthorizedExceptionImpl(
      message: null == message ? _value.message : message as String,
      statusCode: freezed == statusCode ? _value.statusCode : statusCode as int?,
      errorCode: freezed == errorCode ? _value.errorCode : errorCode as String?,
    ));
  }
}

class _$UnauthorizedExceptionImpl extends _UnauthorizedException {
  const _$UnauthorizedExceptionImpl(
      {required this.message, this.statusCode, this.errorCode})
      : super._();

  @override
  final String message;
  @override
  final int? statusCode;
  @override
  final String? errorCode;

  @override
  String toString() =>
      'AppException.unauthorized(message: $message, statusCode: $statusCode, errorCode: $errorCode)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnauthorizedExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnauthorizedExceptionImplCopyWith<_$UnauthorizedExceptionImpl>
      get copyWith =>
          __$$UnauthorizedExceptionImplCopyWithImpl<_$UnauthorizedExceptionImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? errorCode) network,
    required TResult Function(String message, int? statusCode, String? errorCode) server,
    required TResult Function(String message, int? statusCode, String? errorCode) unauthorized,
    required TResult Function(String message, int? statusCode, String? errorCode) forbidden,
    required TResult Function(String message, int? statusCode, String? errorCode) notFound,
    required TResult Function(String message, int? statusCode, String? errorCode) validation,
    required TResult Function(String message, int? statusCode, String? errorCode) timeout,
    required TResult Function(String message, int? statusCode, String? errorCode) cancelled,
    required TResult Function(String message, int? statusCode, String? errorCode) unknown,
  }) =>
      unauthorized(message, statusCode, errorCode);

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)? network,
    TResult? Function(String message, int? statusCode, String? errorCode)? server,
    TResult? Function(String message, int? statusCode, String? errorCode)? unauthorized,
    TResult? Function(String message, int? statusCode, String? errorCode)? forbidden,
    TResult? Function(String message, int? statusCode, String? errorCode)? notFound,
    TResult? Function(String message, int? statusCode, String? errorCode)? validation,
    TResult? Function(String message, int? statusCode, String? errorCode)? timeout,
    TResult? Function(String message, int? statusCode, String? errorCode)? cancelled,
    TResult? Function(String message, int? statusCode, String? errorCode)? unknown,
  }) =>
      unauthorized?.call(message, statusCode, errorCode);

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)? network,
    TResult Function(String message, int? statusCode, String? errorCode)? server,
    TResult Function(String message, int? statusCode, String? errorCode)? unauthorized,
    TResult Function(String message, int? statusCode, String? errorCode)? forbidden,
    TResult Function(String message, int? statusCode, String? errorCode)? notFound,
    TResult Function(String message, int? statusCode, String? errorCode)? validation,
    TResult Function(String message, int? statusCode, String? errorCode)? timeout,
    TResult Function(String message, int? statusCode, String? errorCode)? cancelled,
    TResult Function(String message, int? statusCode, String? errorCode)? unknown,
    required TResult orElse(),
  }) =>
      unauthorized != null
          ? unauthorized(message, statusCode, errorCode)
          : orElse();

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NetworkException value) network,
    required TResult Function(_ServerException value) server,
    required TResult Function(_UnauthorizedException value) unauthorized,
    required TResult Function(_ForbiddenException value) forbidden,
    required TResult Function(_NotFoundException value) notFound,
    required TResult Function(_ValidationException value) validation,
    required TResult Function(_TimeoutException value) timeout,
    required TResult Function(_CancelledException value) cancelled,
    required TResult Function(_UnknownException value) unknown,
  }) =>
      unauthorized(this);

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NetworkException value)? network,
    TResult? Function(_ServerException value)? server,
    TResult? Function(_UnauthorizedException value)? unauthorized,
    TResult? Function(_ForbiddenException value)? forbidden,
    TResult? Function(_NotFoundException value)? notFound,
    TResult? Function(_ValidationException value)? validation,
    TResult? Function(_TimeoutException value)? timeout,
    TResult? Function(_CancelledException value)? cancelled,
    TResult? Function(_UnknownException value)? unknown,
  }) =>
      unauthorized?.call(this);

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NetworkException value)? network,
    TResult Function(_ServerException value)? server,
    TResult Function(_UnauthorizedException value)? unauthorized,
    TResult Function(_ForbiddenException value)? forbidden,
    TResult Function(_NotFoundException value)? notFound,
    TResult Function(_ValidationException value)? validation,
    TResult Function(_TimeoutException value)? timeout,
    TResult Function(_CancelledException value)? cancelled,
    TResult Function(_UnknownException value)? unknown,
    required TResult orElse(),
  }) =>
      unauthorized != null ? unauthorized(this) : orElse();
}

abstract class _UnauthorizedException extends AppException {
  const factory _UnauthorizedException(
      {required final String message,
      final int? statusCode,
      final String? errorCode}) = _$UnauthorizedExceptionImpl;
  const _UnauthorizedException._() : super._();

  @override
  String get message;
  @override
  int? get statusCode;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$UnauthorizedExceptionImplCopyWith<_$UnauthorizedExceptionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

// ─── Forbidden ───────────────────────────────────────────────────────────────

class _$ForbiddenExceptionImpl extends _ForbiddenException {
  const _$ForbiddenExceptionImpl(
      {required this.message, this.statusCode, this.errorCode})
      : super._();
  @override
  final String message;
  @override
  final int? statusCode;
  @override
  final String? errorCode;

  @override
  String toString() =>
      'AppException.forbidden(message: $message, statusCode: $statusCode, errorCode: $errorCode)';
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is _$ForbiddenExceptionImpl &&
          other.message == message &&
          other.statusCode == statusCode &&
          other.errorCode == errorCode);
  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ForbiddenExceptionImplCopyWith<_$ForbiddenExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String, int?, String?) network,
    required TResult Function(String, int?, String?) server,
    required TResult Function(String, int?, String?) unauthorized,
    required TResult Function(String, int?, String?) forbidden,
    required TResult Function(String, int?, String?) notFound,
    required TResult Function(String, int?, String?) validation,
    required TResult Function(String, int?, String?) timeout,
    required TResult Function(String, int?, String?) cancelled,
    required TResult Function(String, int?, String?) unknown,
  }) =>
      forbidden(message, statusCode, errorCode);

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String, int?, String?)? network,
    TResult? Function(String, int?, String?)? server,
    TResult? Function(String, int?, String?)? unauthorized,
    TResult? Function(String, int?, String?)? forbidden,
    TResult? Function(String, int?, String?)? notFound,
    TResult? Function(String, int?, String?)? validation,
    TResult? Function(String, int?, String?)? timeout,
    TResult? Function(String, int?, String?)? cancelled,
    TResult? Function(String, int?, String?)? unknown,
  }) =>
      forbidden?.call(message, statusCode, errorCode);

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String, int?, String?)? network,
    TResult Function(String, int?, String?)? server,
    TResult Function(String, int?, String?)? unauthorized,
    TResult Function(String, int?, String?)? forbidden,
    TResult Function(String, int?, String?)? notFound,
    TResult Function(String, int?, String?)? validation,
    TResult Function(String, int?, String?)? timeout,
    TResult Function(String, int?, String?)? cancelled,
    TResult Function(String, int?, String?)? unknown,
    required TResult orElse(),
  }) =>
      forbidden != null ? forbidden(message, statusCode, errorCode) : orElse();

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NetworkException) network,
    required TResult Function(_ServerException) server,
    required TResult Function(_UnauthorizedException) unauthorized,
    required TResult Function(_ForbiddenException) forbidden,
    required TResult Function(_NotFoundException) notFound,
    required TResult Function(_ValidationException) validation,
    required TResult Function(_TimeoutException) timeout,
    required TResult Function(_CancelledException) cancelled,
    required TResult Function(_UnknownException) unknown,
  }) =>
      forbidden(this);

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NetworkException)? network,
    TResult? Function(_ServerException)? server,
    TResult? Function(_UnauthorizedException)? unauthorized,
    TResult? Function(_ForbiddenException)? forbidden,
    TResult? Function(_NotFoundException)? notFound,
    TResult? Function(_ValidationException)? validation,
    TResult? Function(_TimeoutException)? timeout,
    TResult? Function(_CancelledException)? cancelled,
    TResult? Function(_UnknownException)? unknown,
  }) =>
      forbidden?.call(this);

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NetworkException)? network,
    TResult Function(_ServerException)? server,
    TResult Function(_UnauthorizedException)? unauthorized,
    TResult Function(_ForbiddenException)? forbidden,
    TResult Function(_NotFoundException)? notFound,
    TResult Function(_ValidationException)? validation,
    TResult Function(_TimeoutException)? timeout,
    TResult Function(_CancelledException)? cancelled,
    TResult Function(_UnknownException)? unknown,
    required TResult orElse(),
  }) =>
      forbidden != null ? forbidden(this) : orElse();
}

abstract class _$$ForbiddenExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$ForbiddenExceptionImplCopyWith(_$ForbiddenExceptionImpl v,
      $Res Function(_$ForbiddenExceptionImpl) t) = __$$ForbiddenExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode, String? errorCode});
}

class __$$ForbiddenExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$ForbiddenExceptionImpl>
    implements _$$ForbiddenExceptionImplCopyWith<$Res> {
  __$$ForbiddenExceptionImplCopyWithImpl(
      _$ForbiddenExceptionImpl _v, $Res Function(_$ForbiddenExceptionImpl) _t)
      : super(_v, _t);
  @override
  $Res call({Object? message = null, Object? statusCode = freezed, Object? errorCode = freezed}) =>
      _then(_$ForbiddenExceptionImpl(
        message: null == message ? _value.message : message as String,
        statusCode: freezed == statusCode ? _value.statusCode : statusCode as int?,
        errorCode: freezed == errorCode ? _value.errorCode : errorCode as String?,
      ));
}

abstract class _ForbiddenException extends AppException {
  const factory _ForbiddenException(
      {required final String message,
      final int? statusCode,
      final String? errorCode}) = _$ForbiddenExceptionImpl;
  const _ForbiddenException._() : super._();
  @override
  String get message;
  @override
  int? get statusCode;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$ForbiddenExceptionImplCopyWith<_$ForbiddenExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// ─── NotFound ────────────────────────────────────────────────────────────────

class _$NotFoundExceptionImpl extends _NotFoundException {
  const _$NotFoundExceptionImpl({required this.message, this.statusCode, this.errorCode}) : super._();
  @override final String message;
  @override final int? statusCode;
  @override final String? errorCode;
  @override String toString() => 'AppException.notFound(message: $message)';
  @override bool operator ==(Object o) => identical(this, o) || (o.runtimeType == runtimeType && o is _$NotFoundExceptionImpl && o.message == message && o.statusCode == statusCode && o.errorCode == errorCode);
  @override int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);
  @override @optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(String,int?,String?) network,required TResult Function(String,int?,String?) server,required TResult Function(String,int?,String?) unauthorized,required TResult Function(String,int?,String?) forbidden,required TResult Function(String,int?,String?) notFound,required TResult Function(String,int?,String?) validation,required TResult Function(String,int?,String?) timeout,required TResult Function(String,int?,String?) cancelled,required TResult Function(String,int?,String?) unknown}) => notFound(message,statusCode,errorCode);
  @override @optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(String,int?,String?)? network,TResult? Function(String,int?,String?)? server,TResult? Function(String,int?,String?)? unauthorized,TResult? Function(String,int?,String?)? forbidden,TResult? Function(String,int?,String?)? notFound,TResult? Function(String,int?,String?)? validation,TResult? Function(String,int?,String?)? timeout,TResult? Function(String,int?,String?)? cancelled,TResult? Function(String,int?,String?)? unknown}) => notFound?.call(message,statusCode,errorCode);
  @override @optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(String,int?,String?)? network,TResult Function(String,int?,String?)? server,TResult Function(String,int?,String?)? unauthorized,TResult Function(String,int?,String?)? forbidden,TResult Function(String,int?,String?)? notFound,TResult Function(String,int?,String?)? validation,TResult Function(String,int?,String?)? timeout,TResult Function(String,int?,String?)? cancelled,TResult Function(String,int?,String?)? unknown,required TResult orElse()}) => notFound != null ? notFound(message,statusCode,errorCode) : orElse();
  @override @optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function(_NetworkException) network,required TResult Function(_ServerException) server,required TResult Function(_UnauthorizedException) unauthorized,required TResult Function(_ForbiddenException) forbidden,required TResult Function(_NotFoundException) notFound,required TResult Function(_ValidationException) validation,required TResult Function(_TimeoutException) timeout,required TResult Function(_CancelledException) cancelled,required TResult Function(_UnknownException) unknown}) => notFound(this);
  @override @optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function(_NetworkException)? network,TResult? Function(_ServerException)? server,TResult? Function(_UnauthorizedException)? unauthorized,TResult? Function(_ForbiddenException)? forbidden,TResult? Function(_NotFoundException)? notFound,TResult? Function(_ValidationException)? validation,TResult? Function(_TimeoutException)? timeout,TResult? Function(_CancelledException)? cancelled,TResult? Function(_UnknownException)? unknown}) => notFound?.call(this);
  @override @optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function(_NetworkException)? network,TResult Function(_ServerException)? server,TResult Function(_UnauthorizedException)? unauthorized,TResult Function(_ForbiddenException)? forbidden,TResult Function(_NotFoundException)? notFound,TResult Function(_ValidationException)? validation,TResult Function(_TimeoutException)? timeout,TResult Function(_CancelledException)? cancelled,TResult Function(_UnknownException)? unknown,required TResult orElse()}) => notFound != null ? notFound(this) : orElse();
  @JsonKey(ignore: true)
  @override @pragma('vm:prefer-inline') _$$NotFoundExceptionImplCopyWith<_$NotFoundExceptionImpl> get copyWith => throw _privateConstructorUsedError;
}

abstract class _$$NotFoundExceptionImplCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory _$$NotFoundExceptionImplCopyWith(_$NotFoundExceptionImpl v, $Res Function(_$NotFoundExceptionImpl) t) = __$$NotFoundExceptionImplCopyWithImpl<$Res>;
  @override @useResult $Res call({String message, int? statusCode, String? errorCode});
}

class __$$NotFoundExceptionImplCopyWithImpl<$Res> extends _$AppExceptionCopyWithImpl<$Res, _$NotFoundExceptionImpl> implements _$$NotFoundExceptionImplCopyWith<$Res> {
  __$$NotFoundExceptionImplCopyWithImpl(_$NotFoundExceptionImpl _v, $Res Function(_$NotFoundExceptionImpl) _t) : super(_v, _t);
  @override $Res call({Object? message = null, Object? statusCode = freezed, Object? errorCode = freezed}) => _then(_$NotFoundExceptionImpl(message: null == message ? _value.message : message as String, statusCode: freezed == statusCode ? _value.statusCode : statusCode as int?, errorCode: freezed == errorCode ? _value.errorCode : errorCode as String?));
}

abstract class _NotFoundException extends AppException {
  const factory _NotFoundException({required final String message, final int? statusCode, final String? errorCode}) = _$NotFoundExceptionImpl;
  const _NotFoundException._() : super._();
  @override String get message;
  @override int? get statusCode;
  @override String? get errorCode;
  @override @JsonKey(ignore: true) _$$NotFoundExceptionImplCopyWith<_$NotFoundExceptionImpl> get copyWith => throw _privateConstructorUsedError;
}

// ─── Validation ──────────────────────────────────────────────────────────────

class _$ValidationExceptionImpl extends _ValidationException {
  const _$ValidationExceptionImpl({required this.message, this.statusCode, this.errorCode}) : super._();
  @override final String message;
  @override final int? statusCode;
  @override final String? errorCode;
  @override String toString() => 'AppException.validation(message: $message)';
  @override bool operator ==(Object o) => identical(this, o) || (o is _$ValidationExceptionImpl && o.message == message && o.statusCode == statusCode && o.errorCode == errorCode);
  @override int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);
  @override @optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(String,int?,String?) network,required TResult Function(String,int?,String?) server,required TResult Function(String,int?,String?) unauthorized,required TResult Function(String,int?,String?) forbidden,required TResult Function(String,int?,String?) notFound,required TResult Function(String,int?,String?) validation,required TResult Function(String,int?,String?) timeout,required TResult Function(String,int?,String?) cancelled,required TResult Function(String,int?,String?) unknown}) => validation(message,statusCode,errorCode);
  @override @optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(String,int?,String?)? network,TResult? Function(String,int?,String?)? server,TResult? Function(String,int?,String?)? unauthorized,TResult? Function(String,int?,String?)? forbidden,TResult? Function(String,int?,String?)? notFound,TResult? Function(String,int?,String?)? validation,TResult? Function(String,int?,String?)? timeout,TResult? Function(String,int?,String?)? cancelled,TResult? Function(String,int?,String?)? unknown}) => validation?.call(message,statusCode,errorCode);
  @override @optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(String,int?,String?)? network,TResult Function(String,int?,String?)? server,TResult Function(String,int?,String?)? unauthorized,TResult Function(String,int?,String?)? forbidden,TResult Function(String,int?,String?)? notFound,TResult Function(String,int?,String?)? validation,TResult Function(String,int?,String?)? timeout,TResult Function(String,int?,String?)? cancelled,TResult Function(String,int?,String?)? unknown,required TResult orElse()}) => validation != null ? validation(message,statusCode,errorCode) : orElse();
  @override @optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function(_NetworkException) network,required TResult Function(_ServerException) server,required TResult Function(_UnauthorizedException) unauthorized,required TResult Function(_ForbiddenException) forbidden,required TResult Function(_NotFoundException) notFound,required TResult Function(_ValidationException) validation,required TResult Function(_TimeoutException) timeout,required TResult Function(_CancelledException) cancelled,required TResult Function(_UnknownException) unknown}) => validation(this);
  @override @optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function(_NetworkException)? network,TResult? Function(_ServerException)? server,TResult? Function(_UnauthorizedException)? unauthorized,TResult? Function(_ForbiddenException)? forbidden,TResult? Function(_NotFoundException)? notFound,TResult? Function(_ValidationException)? validation,TResult? Function(_TimeoutException)? timeout,TResult? Function(_CancelledException)? cancelled,TResult? Function(_UnknownException)? unknown}) => validation?.call(this);
  @override @optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function(_NetworkException)? network,TResult Function(_ServerException)? server,TResult Function(_UnauthorizedException)? unauthorized,TResult Function(_ForbiddenException)? forbidden,TResult Function(_NotFoundException)? notFound,TResult Function(_ValidationException)? validation,TResult Function(_TimeoutException)? timeout,TResult Function(_CancelledException)? cancelled,TResult Function(_UnknownException)? unknown,required TResult orElse()}) => validation != null ? validation(this) : orElse();
  @JsonKey(ignore: true)
  @override @pragma('vm:prefer-inline') _$$ValidationExceptionImplCopyWith<_$ValidationExceptionImpl> get copyWith => throw _privateConstructorUsedError;
}

abstract class _$$ValidationExceptionImplCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory _$$ValidationExceptionImplCopyWith(_$ValidationExceptionImpl v, $Res Function(_$ValidationExceptionImpl) t) = __$$ValidationExceptionImplCopyWithImpl<$Res>;
  @override @useResult $Res call({String message, int? statusCode, String? errorCode});
}

class __$$ValidationExceptionImplCopyWithImpl<$Res> extends _$AppExceptionCopyWithImpl<$Res, _$ValidationExceptionImpl> implements _$$ValidationExceptionImplCopyWith<$Res> {
  __$$ValidationExceptionImplCopyWithImpl(_$ValidationExceptionImpl _v, $Res Function(_$ValidationExceptionImpl) _t) : super(_v, _t);
  @override $Res call({Object? message = null, Object? statusCode = freezed, Object? errorCode = freezed}) => _then(_$ValidationExceptionImpl(message: null == message ? _value.message : message as String, statusCode: freezed == statusCode ? _value.statusCode : statusCode as int?, errorCode: freezed == errorCode ? _value.errorCode : errorCode as String?));
}

abstract class _ValidationException extends AppException {
  const factory _ValidationException({required final String message, final int? statusCode, final String? errorCode}) = _$ValidationExceptionImpl;
  const _ValidationException._() : super._();
  @override String get message;
  @override int? get statusCode;
  @override String? get errorCode;
  @override @JsonKey(ignore: true) _$$ValidationExceptionImplCopyWith<_$ValidationExceptionImpl> get copyWith => throw _privateConstructorUsedError;
}

// ─── Timeout ─────────────────────────────────────────────────────────────────

class _$TimeoutExceptionImpl extends _TimeoutException {
  const _$TimeoutExceptionImpl({required this.message, this.statusCode, this.errorCode}) : super._();
  @override final String message;
  @override final int? statusCode;
  @override final String? errorCode;
  @override String toString() => 'AppException.timeout(message: $message)';
  @override bool operator ==(Object o) => identical(this, o) || (o is _$TimeoutExceptionImpl && o.message == message);
  @override int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);
  @override @optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(String,int?,String?) network,required TResult Function(String,int?,String?) server,required TResult Function(String,int?,String?) unauthorized,required TResult Function(String,int?,String?) forbidden,required TResult Function(String,int?,String?) notFound,required TResult Function(String,int?,String?) validation,required TResult Function(String,int?,String?) timeout,required TResult Function(String,int?,String?) cancelled,required TResult Function(String,int?,String?) unknown}) => timeout(message,statusCode,errorCode);
  @override @optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(String,int?,String?)? network,TResult? Function(String,int?,String?)? server,TResult? Function(String,int?,String?)? unauthorized,TResult? Function(String,int?,String?)? forbidden,TResult? Function(String,int?,String?)? notFound,TResult? Function(String,int?,String?)? validation,TResult? Function(String,int?,String?)? timeout,TResult? Function(String,int?,String?)? cancelled,TResult? Function(String,int?,String?)? unknown}) => timeout?.call(message,statusCode,errorCode);
  @override @optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(String,int?,String?)? network,TResult Function(String,int?,String?)? server,TResult Function(String,int?,String?)? unauthorized,TResult Function(String,int?,String?)? forbidden,TResult Function(String,int?,String?)? notFound,TResult Function(String,int?,String?)? validation,TResult Function(String,int?,String?)? timeout,TResult Function(String,int?,String?)? cancelled,TResult Function(String,int?,String?)? unknown,required TResult orElse()}) => timeout != null ? timeout(message,statusCode,errorCode) : orElse();
  @override @optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function(_NetworkException) network,required TResult Function(_ServerException) server,required TResult Function(_UnauthorizedException) unauthorized,required TResult Function(_ForbiddenException) forbidden,required TResult Function(_NotFoundException) notFound,required TResult Function(_ValidationException) validation,required TResult Function(_TimeoutException) timeout,required TResult Function(_CancelledException) cancelled,required TResult Function(_UnknownException) unknown}) => timeout(this);
  @override @optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function(_NetworkException)? network,TResult? Function(_ServerException)? server,TResult? Function(_UnauthorizedException)? unauthorized,TResult? Function(_ForbiddenException)? forbidden,TResult? Function(_NotFoundException)? notFound,TResult? Function(_ValidationException)? validation,TResult? Function(_TimeoutException)? timeout,TResult? Function(_CancelledException)? cancelled,TResult? Function(_UnknownException)? unknown}) => timeout?.call(this);
  @override @optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function(_NetworkException)? network,TResult Function(_ServerException)? server,TResult Function(_UnauthorizedException)? unauthorized,TResult Function(_ForbiddenException)? forbidden,TResult Function(_NotFoundException)? notFound,TResult Function(_ValidationException)? validation,TResult Function(_TimeoutException)? timeout,TResult Function(_CancelledException)? cancelled,TResult Function(_UnknownException)? unknown,required TResult orElse()}) => timeout != null ? timeout(this) : orElse();
  @JsonKey(ignore: true)
  @override @pragma('vm:prefer-inline') _$$TimeoutExceptionImplCopyWith<_$TimeoutExceptionImpl> get copyWith => throw _privateConstructorUsedError;
}

abstract class _$$TimeoutExceptionImplCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory _$$TimeoutExceptionImplCopyWith(_$TimeoutExceptionImpl v, $Res Function(_$TimeoutExceptionImpl) t) = __$$TimeoutExceptionImplCopyWithImpl<$Res>;
  @override @useResult $Res call({String message, int? statusCode, String? errorCode});
}

class __$$TimeoutExceptionImplCopyWithImpl<$Res> extends _$AppExceptionCopyWithImpl<$Res, _$TimeoutExceptionImpl> implements _$$TimeoutExceptionImplCopyWith<$Res> {
  __$$TimeoutExceptionImplCopyWithImpl(_$TimeoutExceptionImpl _v, $Res Function(_$TimeoutExceptionImpl) _t) : super(_v, _t);
  @override $Res call({Object? message = null, Object? statusCode = freezed, Object? errorCode = freezed}) => _then(_$TimeoutExceptionImpl(message: null == message ? _value.message : message as String, statusCode: freezed == statusCode ? _value.statusCode : statusCode as int?, errorCode: freezed == errorCode ? _value.errorCode : errorCode as String?));
}

abstract class _TimeoutException extends AppException {
  const factory _TimeoutException({required final String message, final int? statusCode, final String? errorCode}) = _$TimeoutExceptionImpl;
  const _TimeoutException._() : super._();
  @override String get message;
  @override int? get statusCode;
  @override String? get errorCode;
  @override @JsonKey(ignore: true) _$$TimeoutExceptionImplCopyWith<_$TimeoutExceptionImpl> get copyWith => throw _privateConstructorUsedError;
}

// ─── Cancelled ───────────────────────────────────────────────────────────────

class _$CancelledExceptionImpl extends _CancelledException {
  const _$CancelledExceptionImpl({required this.message, this.statusCode, this.errorCode}) : super._();
  @override final String message;
  @override final int? statusCode;
  @override final String? errorCode;
  @override String toString() => 'AppException.cancelled(message: $message)';
  @override bool operator ==(Object o) => identical(this, o) || (o is _$CancelledExceptionImpl && o.message == message);
  @override int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);
  @override @optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(String,int?,String?) network,required TResult Function(String,int?,String?) server,required TResult Function(String,int?,String?) unauthorized,required TResult Function(String,int?,String?) forbidden,required TResult Function(String,int?,String?) notFound,required TResult Function(String,int?,String?) validation,required TResult Function(String,int?,String?) timeout,required TResult Function(String,int?,String?) cancelled,required TResult Function(String,int?,String?) unknown}) => cancelled(message,statusCode,errorCode);
  @override @optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(String,int?,String?)? network,TResult? Function(String,int?,String?)? server,TResult? Function(String,int?,String?)? unauthorized,TResult? Function(String,int?,String?)? forbidden,TResult? Function(String,int?,String?)? notFound,TResult? Function(String,int?,String?)? validation,TResult? Function(String,int?,String?)? timeout,TResult? Function(String,int?,String?)? cancelled,TResult? Function(String,int?,String?)? unknown}) => cancelled?.call(message,statusCode,errorCode);
  @override @optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(String,int?,String?)? network,TResult Function(String,int?,String?)? server,TResult Function(String,int?,String?)? unauthorized,TResult Function(String,int?,String?)? forbidden,TResult Function(String,int?,String?)? notFound,TResult Function(String,int?,String?)? validation,TResult Function(String,int?,String?)? timeout,TResult Function(String,int?,String?)? cancelled,TResult Function(String,int?,String?)? unknown,required TResult orElse()}) => cancelled != null ? cancelled(message,statusCode,errorCode) : orElse();
  @override @optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function(_NetworkException) network,required TResult Function(_ServerException) server,required TResult Function(_UnauthorizedException) unauthorized,required TResult Function(_ForbiddenException) forbidden,required TResult Function(_NotFoundException) notFound,required TResult Function(_ValidationException) validation,required TResult Function(_TimeoutException) timeout,required TResult Function(_CancelledException) cancelled,required TResult Function(_UnknownException) unknown}) => cancelled(this);
  @override @optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function(_NetworkException)? network,TResult? Function(_ServerException)? server,TResult? Function(_UnauthorizedException)? unauthorized,TResult? Function(_ForbiddenException)? forbidden,TResult? Function(_NotFoundException)? notFound,TResult? Function(_ValidationException)? validation,TResult? Function(_TimeoutException)? timeout,TResult? Function(_CancelledException)? cancelled,TResult? Function(_UnknownException)? unknown}) => cancelled?.call(this);
  @override @optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function(_NetworkException)? network,TResult Function(_ServerException)? server,TResult Function(_UnauthorizedException)? unauthorized,TResult Function(_ForbiddenException)? forbidden,TResult Function(_NotFoundException)? notFound,TResult Function(_ValidationException)? validation,TResult Function(_TimeoutException)? timeout,TResult Function(_CancelledException)? cancelled,TResult Function(_UnknownException)? unknown,required TResult orElse()}) => cancelled != null ? cancelled(this) : orElse();
  @JsonKey(ignore: true)
  @override @pragma('vm:prefer-inline') _$$CancelledExceptionImplCopyWith<_$CancelledExceptionImpl> get copyWith => throw _privateConstructorUsedError;
}

abstract class _$$CancelledExceptionImplCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory _$$CancelledExceptionImplCopyWith(_$CancelledExceptionImpl v, $Res Function(_$CancelledExceptionImpl) t) = __$$CancelledExceptionImplCopyWithImpl<$Res>;
  @override @useResult $Res call({String message, int? statusCode, String? errorCode});
}

class __$$CancelledExceptionImplCopyWithImpl<$Res> extends _$AppExceptionCopyWithImpl<$Res, _$CancelledExceptionImpl> implements _$$CancelledExceptionImplCopyWith<$Res> {
  __$$CancelledExceptionImplCopyWithImpl(_$CancelledExceptionImpl _v, $Res Function(_$CancelledExceptionImpl) _t) : super(_v, _t);
  @override $Res call({Object? message = null, Object? statusCode = freezed, Object? errorCode = freezed}) => _then(_$CancelledExceptionImpl(message: null == message ? _value.message : message as String, statusCode: freezed == statusCode ? _value.statusCode : statusCode as int?, errorCode: freezed == errorCode ? _value.errorCode : errorCode as String?));
}

abstract class _CancelledException extends AppException {
  const factory _CancelledException({required final String message, final int? statusCode, final String? errorCode}) = _$CancelledExceptionImpl;
  const _CancelledException._() : super._();
  @override String get message;
  @override int? get statusCode;
  @override String? get errorCode;
  @override @JsonKey(ignore: true) _$$CancelledExceptionImplCopyWith<_$CancelledExceptionImpl> get copyWith => throw _privateConstructorUsedError;
}

// ─── Unknown ─────────────────────────────────────────────────────────────────

class _$UnknownExceptionImpl extends _UnknownException {
  const _$UnknownExceptionImpl({required this.message, this.statusCode, this.errorCode}) : super._();
  @override final String message;
  @override final int? statusCode;
  @override final String? errorCode;
  @override String toString() => 'AppException.unknown(message: $message)';
  @override bool operator ==(Object o) => identical(this, o) || (o is _$UnknownExceptionImpl && o.message == message);
  @override int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);
  @override @optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(String,int?,String?) network,required TResult Function(String,int?,String?) server,required TResult Function(String,int?,String?) unauthorized,required TResult Function(String,int?,String?) forbidden,required TResult Function(String,int?,String?) notFound,required TResult Function(String,int?,String?) validation,required TResult Function(String,int?,String?) timeout,required TResult Function(String,int?,String?) cancelled,required TResult Function(String,int?,String?) unknown}) => unknown(message,statusCode,errorCode);
  @override @optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(String,int?,String?)? network,TResult? Function(String,int?,String?)? server,TResult? Function(String,int?,String?)? unauthorized,TResult? Function(String,int?,String?)? forbidden,TResult? Function(String,int?,String?)? notFound,TResult? Function(String,int?,String?)? validation,TResult? Function(String,int?,String?)? timeout,TResult? Function(String,int?,String?)? cancelled,TResult? Function(String,int?,String?)? unknown}) => unknown?.call(message,statusCode,errorCode);
  @override @optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(String,int?,String?)? network,TResult Function(String,int?,String?)? server,TResult Function(String,int?,String?)? unauthorized,TResult Function(String,int?,String?)? forbidden,TResult Function(String,int?,String?)? notFound,TResult Function(String,int?,String?)? validation,TResult Function(String,int?,String?)? timeout,TResult Function(String,int?,String?)? cancelled,TResult Function(String,int?,String?)? unknown,required TResult orElse()}) => unknown != null ? unknown(message,statusCode,errorCode) : orElse();
  @override @optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function(_NetworkException) network,required TResult Function(_ServerException) server,required TResult Function(_UnauthorizedException) unauthorized,required TResult Function(_ForbiddenException) forbidden,required TResult Function(_NotFoundException) notFound,required TResult Function(_ValidationException) validation,required TResult Function(_TimeoutException) timeout,required TResult Function(_CancelledException) cancelled,required TResult Function(_UnknownException) unknown}) => unknown(this);
  @override @optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function(_NetworkException)? network,TResult? Function(_ServerException)? server,TResult? Function(_UnauthorizedException)? unauthorized,TResult? Function(_ForbiddenException)? forbidden,TResult? Function(_NotFoundException)? notFound,TResult? Function(_ValidationException)? validation,TResult? Function(_TimeoutException)? timeout,TResult? Function(_CancelledException)? cancelled,TResult? Function(_UnknownException)? unknown}) => unknown?.call(this);
  @override @optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function(_NetworkException)? network,TResult Function(_ServerException)? server,TResult Function(_UnauthorizedException)? unauthorized,TResult Function(_ForbiddenException)? forbidden,TResult Function(_NotFoundException)? notFound,TResult Function(_ValidationException)? validation,TResult Function(_TimeoutException)? timeout,TResult Function(_CancelledException)? cancelled,TResult Function(_UnknownException)? unknown,required TResult orElse()}) => unknown != null ? unknown(this) : orElse();
  @JsonKey(ignore: true)
  @override @pragma('vm:prefer-inline') _$$UnknownExceptionImplCopyWith<_$UnknownExceptionImpl> get copyWith => throw _privateConstructorUsedError;
}

abstract class _$$UnknownExceptionImplCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory _$$UnknownExceptionImplCopyWith(_$UnknownExceptionImpl v, $Res Function(_$UnknownExceptionImpl) t) = __$$UnknownExceptionImplCopyWithImpl<$Res>;
  @override @useResult $Res call({String message, int? statusCode, String? errorCode});
}

class __$$UnknownExceptionImplCopyWithImpl<$Res> extends _$AppExceptionCopyWithImpl<$Res, _$UnknownExceptionImpl> implements _$$UnknownExceptionImplCopyWith<$Res> {
  __$$UnknownExceptionImplCopyWithImpl(_$UnknownExceptionImpl _v, $Res Function(_$UnknownExceptionImpl) _t) : super(_v, _t);
  @override $Res call({Object? message = null, Object? statusCode = freezed, Object? errorCode = freezed}) => _then(_$UnknownExceptionImpl(message: null == message ? _value.message : message as String, statusCode: freezed == statusCode ? _value.statusCode : statusCode as int?, errorCode: freezed == errorCode ? _value.errorCode : errorCode as String?));
}

abstract class _UnknownException extends AppException {
  const factory _UnknownException({required final String message, final int? statusCode, final String? errorCode}) = _$UnknownExceptionImpl;
  const _UnknownException._() : super._();
  @override String get message;
  @override int? get statusCode;
  @override String? get errorCode;
  @override @JsonKey(ignore: true) _$$UnknownExceptionImplCopyWith<_$UnknownExceptionImpl> get copyWith => throw _privateConstructorUsedError;
}
