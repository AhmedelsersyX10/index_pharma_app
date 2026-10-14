import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart' hide Timeout;
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/error_mapper.dart';

void main() {
  final testRequestOptions = RequestOptions(path: '/test');

  DioException createResponseException({
    required int statusCode,
    dynamic data,
  }) {
    return DioException(
      requestOptions: testRequestOptions,
      response: Response(
        requestOptions: testRequestOptions,
        statusCode: statusCode,
        data: data,
      ),
      type: DioExceptionType.badResponse,
    );
  }

  group('mapDioExceptionToFailure - Failure subtypes', () {
    test('maps connectionError to Network', () {
      final dioException = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionError,
        message: 'No internet connection',
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Network>());
      expect(failure.serverMessage, isNull);
    });

    test('maps unknown exception with SocketException to Network', () {
      final dioException = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.unknown,
        error: const SocketException('Connection refused'),
      );

      final failure = dioException.toFailure();

      expect(failure, isA<Network>());
      expect(failure.serverMessage, isNull);
    });

    test('maps connectionTimeout to Timeout', () {
      final dioException = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Timeout>());
      expect(failure.serverMessage, isNull);
    });

    test('maps sendTimeout, receiveTimeout, and transformTimeout to Timeout', () {
      final sendTimeoutEx = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.sendTimeout,
      );
      final receiveTimeoutEx = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.receiveTimeout,
      );
      final transformTimeoutEx = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.transformTimeout,
      );

      expect(mapDioExceptionToFailure(sendTimeoutEx), isA<Timeout>());
      expect(mapDioExceptionToFailure(receiveTimeoutEx), isA<Timeout>());
      expect(mapDioExceptionToFailure(transformTimeoutEx), isA<Timeout>());
    });

    test('maps 400 to Validation and extracts message', () {
      final dioException = createResponseException(
        statusCode: 400,
        data: {'success': false, 'message': 'بيانات الإدخال غير صالحة'},
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Validation>());
      expect(failure.serverMessage, 'بيانات الإدخال غير صالحة');
    });

    test('maps 401 to Unauthorized and extracts message', () {
      final dioException = createResponseException(
        statusCode: 401,
        data: {'message': 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً'},
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Unauthorized>());
      expect(failure.serverMessage, 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً');
    });

    test('maps 403 to Forbidden and extracts message', () {
      final dioException = createResponseException(
        statusCode: 403,
        data: {'message': 'ليس لديك صلاحية لتنفيذ هذا الإجراء'},
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Forbidden>());
      expect(failure.serverMessage, 'ليس لديك صلاحية لتنفيذ هذا الإجراء');
    });

    test('maps 404 to NotFound and extracts message', () {
      final dioException = createResponseException(
        statusCode: 404,
        data: {'message': 'الصنف غير موجود'},
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<NotFound>());
      expect(failure.serverMessage, 'الصنف غير موجود');
    });

    test('maps 409 to Conflict and extracts message', () {
      final dioException = createResponseException(
        statusCode: 409,
        data: {'message': 'تم تسجيل هذا الدواء مسبقاً'},
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Conflict>());
      expect(failure.serverMessage, 'تم تسجيل هذا الدواء مسبقاً');
    });

    test('maps 429 to RateLimit and extracts message', () {
      final dioException = createResponseException(
        statusCode: 429,
        data: {'message': 'لقد تجاوزت الحد المسموح من الطلبات'},
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<RateLimit>());
      expect(failure.serverMessage, 'لقد تجاوزت الحد المسموح من الطلبات');
    });

    test('maps 500..599 to Server and extracts message', () {
      final dioException500 = createResponseException(
        statusCode: 500,
        data: {'message': 'حدث خطأ في الخادم الداخلي'},
      );
      final dioException503 = createResponseException(
        statusCode: 503,
        data: {'message': 'الخدمة غير متوفرة حالياً'},
      );

      final failure500 = mapDioExceptionToFailure(dioException500);
      final failure503 = mapDioExceptionToFailure(dioException503);

      expect(failure500, isA<Server>());
      expect(failure500.serverMessage, 'حدث خطأ في الخادم الداخلي');
      expect(failure503, isA<Server>());
      expect(failure503.serverMessage, 'الخدمة غير متوفرة حالياً');
    });

    test('maps unhandled status code (e.g. 418) to Unexpected', () {
      final dioException = createResponseException(
        statusCode: 418,
        data: {'message': "I'm a teapot"},
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Unexpected>());
      expect(failure.serverMessage, "I'm a teapot");
    });

    test('maps cancel, badCertificate, and unknown to Unexpected', () {
      final cancelEx = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.cancel,
      );
      final badCertEx = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.badCertificate,
      );
      final unknownEx = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.unknown,
      );

      expect(mapDioExceptionToFailure(cancelEx), isA<Unexpected>());
      expect(mapDioExceptionToFailure(badCertEx), isA<Unexpected>());
      expect(mapDioExceptionToFailure(unknownEx), isA<Unexpected>());
    });
  });

  group('mapDioExceptionToFailure - Body edge cases', () {
    test('handles body that has no message key', () {
      final dioException = createResponseException(
        statusCode: 400,
        data: {'success': false, 'error': 'some_code'},
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Validation>());
      expect(failure.serverMessage, isNull);
    });

    test('handles empty Map body', () {
      final dioException = createResponseException(
        statusCode: 500,
        data: <String, dynamic>{},
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Server>());
      expect(failure.serverMessage, isNull);
    });

    test('handles message key that is not a String', () {
      final dioException = createResponseException(
        statusCode: 400,
        data: {
          'message': ['error1', 'error2'],
        },
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Validation>());
      expect(failure.serverMessage, isNull);
    });

    test('handles null body', () {
      final dioException = createResponseException(
        statusCode: 404,
        data: null,
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<NotFound>());
      expect(failure.serverMessage, isNull);
    });

    test('handles non-Map body: plain String', () {
      final dioException = createResponseException(
        statusCode: 502,
        data: 'Bad Gateway: upstream failed',
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Server>());
      expect(failure.serverMessage, isNull);
    });

    test('handles non-Map body: List', () {
      final dioException = createResponseException(
        statusCode: 400,
        data: ['item1', 'item2'],
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Validation>());
      expect(failure.serverMessage, isNull);
    });

    test('handles non-Map body: int', () {
      final dioException = createResponseException(
        statusCode: 500,
        data: 500,
      );

      final failure = mapDioExceptionToFailure(dioException);

      expect(failure, isA<Server>());
      expect(failure.serverMessage, isNull);
    });
  });
}
