import 'dart:io';

import 'package:dio/dio.dart';
import 'package:index_pharma/core/errors/failure.dart';

/// Maps a [DioException] to the corresponding domain [Failure].
Failure mapDioExceptionToFailure(DioException exception) {
  final serverMessage = _extractServerMessage(exception.response?.data);
  final statusCode = exception.response?.statusCode;

  if (statusCode != null) {
    return switch (statusCode) {
      400 => Validation(serverMessage: serverMessage),
      401 => Unauthorized(serverMessage: serverMessage),
      403 => Forbidden(serverMessage: serverMessage),
      404 => NotFound(serverMessage: serverMessage),
      409 => Conflict(serverMessage: serverMessage),
      429 => RateLimit(serverMessage: serverMessage),
      >= 500 && <= 599 => Server(serverMessage: serverMessage),
      _ => Unexpected(serverMessage: serverMessage),
    };
  }

  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout =>
      Timeout(serverMessage: serverMessage),
    DioExceptionType.connectionError =>
      Network(serverMessage: serverMessage),
    DioExceptionType.unknown when exception.error is SocketException =>
      Network(serverMessage: serverMessage),
    DioExceptionType.badResponse ||
    DioExceptionType.badCertificate ||
    DioExceptionType.cancel ||
    DioExceptionType.unknown =>
      Unexpected(serverMessage: serverMessage),
  };
}

/// Extension on [DioException] for idiomatic error mapping.
extension DioExceptionToFailureX on DioException {
  Failure toFailure() => mapDioExceptionToFailure(this);
}

/// Safely extracts the 'message' field from the response body if it is a Map
/// containing a String message. Tolerates missing, null, or non-Map bodies.
String? _extractServerMessage(dynamic data) {
  if (data is Map) {
    final message = data['message'];
    if (message is String) {
      return message;
    }
  }
  return null;
}
