import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/constants/app_config.dart';
import 'package:index_pharma/core/network/api_client.dart';

class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ApiClient', () {
    late CookieJar cookieJar;

    setUp(() {
      cookieJar = CookieJar();
    });

    test('default configuration uses AppConfig.baseUrl and 30s timeouts', () {
      final client = ApiClient(
        cookieJar: cookieJar,
        enableLogging: false,
      );

      expect(client.dio.options.baseUrl, AppConfig.baseUrl);
      expect(client.dio.options.connectTimeout, const Duration(seconds: 30));
      expect(client.dio.options.receiveTimeout, const Duration(seconds: 30));
      expect(client.dio.options.sendTimeout, const Duration(seconds: 30));
    });

    test('uploadOptions provides 60s timeout for multipart uploads', () {
      expect(ApiClient.uploadOptions.sendTimeout, const Duration(seconds: 60));
      expect(
        ApiClient.uploadOptions.receiveTimeout,
        const Duration(seconds: 60),
      );
    });

    group('401 Session Expiration Interceptor', () {
      test('invokes onSessionExpired callback when receiving 401', () async {
        var sessionExpiredCalled = false;

        final client = ApiClient(
          cookieJar: cookieJar,
          onSessionExpired: () {
            sessionExpiredCalled = true;
          },
          enableLogging: false,
        );

        client.dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          return ResponseBody.fromString(
            '{"message": "Unauthorized"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        await expectLater(
          client.dio.get<dynamic>('/test-auth'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              401,
            ),
          ),
        );

        expect(sessionExpiredCalled, isTrue);
      });

      test('does not invoke onSessionExpired on non-401 error', () async {
        var sessionExpiredCalled = false;

        final client = ApiClient(
          cookieJar: cookieJar,
          onSessionExpired: () {
            sessionExpiredCalled = true;
          },
          enableLogging: false,
        );

        client.dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          return ResponseBody.fromString(
            '{"message": "Internal Server Error"}',
            500,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        await expectLater(
          client.dio.get<dynamic>('/server-error'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              500,
            ),
          ),
        );

        expect(sessionExpiredCalled, isFalse);
      });

      test('handles 401 gracefully without error when onSessionExpired is null', () async {
        final client = ApiClient(
          cookieJar: cookieJar,
          onSessionExpired: null,
          enableLogging: false,
        );

        client.dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          return ResponseBody.fromString(
            '{"message": "Unauthorized"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        await expectLater(
          client.dio.get<dynamic>('/test-no-callback'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              401,
            ),
          ),
        );
      });

      test('invokes onSessionExpired callback on POST request with 401', () async {
        var sessionExpiredCalled = false;

        final client = ApiClient(
          cookieJar: cookieJar,
          onSessionExpired: () {
            sessionExpiredCalled = true;
          },
          enableLogging: false,
        );

        client.dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          return ResponseBody.fromString(
            '{"message": "Session expired"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        await expectLater(
          client.dio.post<dynamic>('/store/orders', data: {'item': 'sample'}),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              401,
            ),
          ),
        );

        expect(sessionExpiredCalled, isTrue);
      });
    });

    group('Branch Header Interceptor', () {
      test('attaches X-Branch-Id header when branchIdProvider returns a valid id',
          () async {
        RequestOptions? capturedOptions;

        final client = ApiClient(
          cookieJar: cookieJar,
          branchIdProvider: () => 'branch-xyz-987',
          enableLogging: false,
        );

        client.dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          capturedOptions = options;
          return ResponseBody.fromString('{"success": true}', 200);
        });

        await client.dio.get<dynamic>('/store/products');

        expect(capturedOptions, isNotNull);
        expect(
          capturedOptions!.headers[ApiClient.branchHeaderKey],
          'branch-xyz-987',
        );
      });

      test('trims whitespace when attaching X-Branch-Id header', () async {
        RequestOptions? capturedOptions;

        final client = ApiClient(
          cookieJar: cookieJar,
          branchIdProvider: () => '  branch-padded-01  ',
          enableLogging: false,
        );

        client.dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          capturedOptions = options;
          return ResponseBody.fromString('{"success": true}', 200);
        });

        await client.dio.get<dynamic>('/store/products');

        expect(capturedOptions, isNotNull);
        expect(
          capturedOptions!.headers[ApiClient.branchHeaderKey],
          'branch-padded-01',
        );
      });

      test(
          'does not attach X-Branch-Id header when branchIdProvider returns empty or whitespace',
          () async {
        RequestOptions? capturedOptions;

        final client = ApiClient(
          cookieJar: cookieJar,
          branchIdProvider: () => '    ',
          enableLogging: false,
        );

        client.dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          capturedOptions = options;
          return ResponseBody.fromString('{"success": true}', 200);
        });

        await client.dio.get<dynamic>('/store/products');

        expect(capturedOptions, isNotNull);
        expect(
          capturedOptions!.headers.containsKey(ApiClient.branchHeaderKey),
          isFalse,
        );
      });

      test('does not attach X-Branch-Id header when branchIdProvider returns null',
          () async {
        RequestOptions? capturedOptions;

        final client = ApiClient(
          cookieJar: cookieJar,
          branchIdProvider: () => null,
          enableLogging: false,
        );

        client.dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          capturedOptions = options;
          return ResponseBody.fromString('{"success": true}', 200);
        });

        await client.dio.get<dynamic>('/store/products');

        expect(capturedOptions, isNotNull);
        expect(
          capturedOptions!.headers.containsKey(ApiClient.branchHeaderKey),
          isFalse,
        );
      });

      test(
          'does not attach X-Branch-Id header when branchIdProvider is not set (null)',
          () async {
        RequestOptions? capturedOptions;

        final client = ApiClient(
          cookieJar: cookieJar,
          enableLogging: false,
        );

        client.dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          capturedOptions = options;
          return ResponseBody.fromString('{"success": true}', 200);
        });

        await client.dio.get<dynamic>('/store/products');

        expect(capturedOptions, isNotNull);
        expect(
          capturedOptions!.headers.containsKey(ApiClient.branchHeaderKey),
          isFalse,
        );
      });
    });

    group('Interceptors & Logging Configuration', () {
      test('adds debug log interceptor when enableLogging is true', () {
        final client = ApiClient(
          cookieJar: cookieJar,
          enableLogging: true,
        );

        expect(
          client.dio.interceptors.any((i) => i.runtimeType.toString() == '_DebugLogInterceptor'),
          isTrue,
        );
      });

      test('omits debug log interceptor when enableLogging is false', () {
        final client = ApiClient(
          cookieJar: cookieJar,
          enableLogging: false,
        );

        expect(
          client.dio.interceptors.any((i) => i.runtimeType.toString() == '_DebugLogInterceptor'),
          isFalse,
        );
      });
    });
  });
}
