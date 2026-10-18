import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/auth/data/datasources/auth_remote_data_source_impl.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this.handler);

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
  late Dio dio;
  late AuthRemoteDataSourceImpl dataSource;
  late RequestOptions capturedOptions;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000/api'));
    dataSource = AuthRemoteDataSourceImpl(dio: dio);
  });

  ResponseBody jsonResponse(Map<String, dynamic> body, int statusCode) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  group('AuthRemoteDataSourceImpl - login', () {
    test('sends POST /auth/login with credentials and parses user key', () async {
      dio.httpClientAdapter = _FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return jsonResponse(
          {
            'success': true,
            'user': {
              'id': 'cbf82a14-8742-4f11-9a7c-179326d91012',
              'name': 'Test Pharmacist',
              'email': 'pharmacist@test.com',
              'role': 'pharmacist',
              'phone': null,
              'address': null,
              'permissions': null,
              'branchId': 'b18f3a22-3118-4089-9e8c-529a6e118901',
            },
          },
          200,
        );
      });

      final user = await dataSource.login(
        email: 'pharmacist@test.com',
        password: 'Password123',
      );

      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, '/auth/login');
      expect(capturedOptions.data, {
        'email': 'pharmacist@test.com',
        'password': 'Password123',
      });
      expect(user.id, 'cbf82a14-8742-4f11-9a7c-179326d91012');
      expect(user.name, 'Test Pharmacist');
      expect(user.role, 'pharmacist');
      expect(user.branchId, 'b18f3a22-3118-4089-9e8c-529a6e118901');
    });

    test('throws FormatException if user key is missing in response', () async {
      dio.httpClientAdapter = _FakeHttpClientAdapter((options) async {
        return jsonResponse({'success': true}, 200);
      });

      expect(
        () => dataSource.login(email: 'a@b.com', password: '123'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('AuthRemoteDataSourceImpl - register', () {
    test('sends POST /auth/register with all fields and parses user key', () async {
      dio.httpClientAdapter = _FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return jsonResponse(
          {
            'success': true,
            'user': {
              'id': 'reg-1',
              'name': 'New Customer',
              'email': 'new@test.com',
              'role': 'customer',
              'phone': '01011112222',
              'address': 'Cairo',
            },
          },
          201,
        );
      });

      final user = await dataSource.register(
        name: 'New Customer',
        email: 'new@test.com',
        password: 'Password123',
        phone: '01011112222',
        address: 'Cairo',
      );

      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, '/auth/register');
      expect(capturedOptions.data, {
        'name': 'New Customer',
        'email': 'new@test.com',
        'password': 'Password123',
        'phone': '01011112222',
        'address': 'Cairo',
      });
      expect(user.id, 'reg-1');
      expect(user.role, 'customer');
    });

    test('omits phone and address when null in register payload', () async {
      dio.httpClientAdapter = _FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return jsonResponse(
          {
            'success': true,
            'user': {
              'id': 'reg-2',
              'name': 'Customer Only',
              'email': 'customer@test.com',
              'role': 'customer',
            },
          },
          201,
        );
      });

      await dataSource.register(
        name: 'Customer Only',
        email: 'customer@test.com',
        password: 'Password123',
      );

      expect(capturedOptions.data, {
        'name': 'Customer Only',
        'email': 'customer@test.com',
        'password': 'Password123',
      });
      expect((capturedOptions.data as Map).containsKey('phone'), isFalse);
      expect((capturedOptions.data as Map).containsKey('address'), isFalse);
    });
  });

  group('AuthRemoteDataSourceImpl - getMe', () {
    test('sends GET /auth/me and parses data key', () async {
      dio.httpClientAdapter = _FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return jsonResponse(
          {
            'success': true,
            'data': {
              'id': 'e98df12a-3312-40bb-97dc-712891bcfa10',
              'name': 'Ahmed Mostafa',
              'email': 'customer@test.com',
              'phone': '01012345678',
              'address': null,
              'role': 'customer',
              'isActive': true,
              'permissions': null,
              'monthlyTarget': 0,
              'branchId': null,
              'createdAt': '2026-10-10T12:00:00.000Z',
            },
          },
          200,
        );
      });

      final user = await dataSource.getMe();

      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, '/auth/me');
      expect(user.id, 'e98df12a-3312-40bb-97dc-712891bcfa10');
      expect(user.name, 'Ahmed Mostafa');
      expect(user.role, 'customer');
      expect(user.isActive, isTrue);
      expect(user.createdAt, '2026-10-10T12:00:00.000Z');
    });

    test('throws FormatException if data key is missing in getMe response', () async {
      dio.httpClientAdapter = _FakeHttpClientAdapter((options) async {
        return jsonResponse({'success': true}, 200);
      });

      expect(
        () => dataSource.getMe(),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
