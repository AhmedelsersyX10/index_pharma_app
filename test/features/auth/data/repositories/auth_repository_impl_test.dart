import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart' hide Timeout;
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:index_pharma/features/auth/data/models/user_model.dart';
import 'package:index_pharma/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  UserModel? mockUser;
  Object? errorToThrow;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return mockUser!;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return mockUser!;
  }

  @override
  Future<UserModel> getMe() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return mockUser!;
  }
}

void main() {
  late FakeAuthRemoteDataSource fakeRemoteDataSource;
  late AuthRepositoryImpl repository;

  final testRequestOptions = RequestOptions(path: '/auth');

  const testUserModel = UserModel(
    id: 'user-123',
    name: 'Ahmed Mostafa',
    email: 'ahmed@example.com',
    role: 'customer',
    phone: '01012345678',
    address: 'Cairo, Egypt',
    isActive: true,
  );

  DioException createDioResponseException({
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

  setUp(() {
    fakeRemoteDataSource = FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: fakeRemoteDataSource);
  });

  group('AuthRepositoryImpl - login', () {
    test('returns Success<UserEntity> when data source succeeds', () async {
      fakeRemoteDataSource.mockUser = testUserModel;

      final result = await repository.login(
        email: 'ahmed@example.com',
        password: 'Password123',
      );

      expect(result, isA<Success<UserEntity>>());
      final success = result as Success<UserEntity>;
      expect(success.data.id, 'user-123');
      expect(success.data.name, 'Ahmed Mostafa');
      expect(success.data.email, 'ahmed@example.com');
      expect(success.data.role, UserRole.customer);
      expect(success.data.phone, '01012345678');
      expect(success.data.address, 'Cairo, Egypt');
    });

    test('returns Err<UserEntity> with Unauthorized on HTTP 401', () async {
      fakeRemoteDataSource.errorToThrow = createDioResponseException(
        statusCode: 401,
        data: {'success': false, 'message': 'بيانات الاعتماد غير صحيحة'},
      );

      final result = await repository.login(
        email: 'ahmed@example.com',
        password: 'WrongPassword',
      );

      expect(result, isA<Err<UserEntity>>());
      final err = result as Err<UserEntity>;
      expect(err.failure, isA<Unauthorized>());
      expect(err.failure.serverMessage, 'بيانات الاعتماد غير صحيحة');
    });

    test('returns Err<UserEntity> with Validation on HTTP 400', () async {
      fakeRemoteDataSource.errorToThrow = createDioResponseException(
        statusCode: 400,
        data: {'success': false, 'message': 'البريد الإلكتروني غير صالح'},
      );

      final result = await repository.login(
        email: 'invalid-email',
        password: '123',
      );

      expect(result, isA<Err<UserEntity>>());
      final err = result as Err<UserEntity>;
      expect(err.failure, isA<Validation>());
      expect(err.failure.serverMessage, 'البريد الإلكتروني غير صالح');
    });

    test('returns Err<UserEntity> with Network on connection error', () async {
      fakeRemoteDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionError,
      );

      final result = await repository.login(
        email: 'ahmed@example.com',
        password: 'Password123',
      );

      expect(result, isA<Err<UserEntity>>());
      final err = result as Err<UserEntity>;
      expect(err.failure, isA<Network>());
    });

    test('returns Err<UserEntity> with Unexpected on generic exception', () async {
      fakeRemoteDataSource.errorToThrow = const FormatException('Corrupt JSON');

      final result = await repository.login(
        email: 'ahmed@example.com',
        password: 'Password123',
      );

      expect(result, isA<Err<UserEntity>>());
      final err = result as Err<UserEntity>;
      expect(err.failure, isA<Unexpected>());
      expect(err.failure.serverMessage, contains('Corrupt JSON'));
    });
  });

  group('AuthRepositoryImpl - register', () {
    test('returns Success<UserEntity> when data source succeeds', () async {
      fakeRemoteDataSource.mockUser = testUserModel;

      final result = await repository.register(
        name: 'Ahmed Mostafa',
        email: 'ahmed@example.com',
        password: 'Password123',
        phone: '01012345678',
        address: 'Cairo, Egypt',
      );

      expect(result, isA<Success<UserEntity>>());
      final success = result as Success<UserEntity>;
      expect(success.data.id, 'user-123');
      expect(success.data.role, UserRole.customer);
    });

    test('returns Err<UserEntity> with Validation on HTTP 400', () async {
      fakeRemoteDataSource.errorToThrow = createDioResponseException(
        statusCode: 400,
        data: {'success': false, 'message': 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'},
      );

      final result = await repository.register(
        name: 'Ahmed Mostafa',
        email: 'ahmed@example.com',
        password: 'short',
      );

      expect(result, isA<Err<UserEntity>>());
      final err = result as Err<UserEntity>;
      expect(err.failure, isA<Validation>());
      expect(err.failure.serverMessage, 'كلمة المرور يجب أن تكون 8 أحرف على الأقل');
    });

    test('returns Err<UserEntity> with Unauthorized on HTTP 401', () async {
      fakeRemoteDataSource.errorToThrow = createDioResponseException(
        statusCode: 401,
        data: {'success': false, 'message': 'غير مصرح'},
      );

      final result = await repository.register(
        name: 'Ahmed Mostafa',
        email: 'ahmed@example.com',
        password: 'Password123',
      );

      expect(result, isA<Err<UserEntity>>());
      final err = result as Err<UserEntity>;
      expect(err.failure, isA<Unauthorized>());
      expect(err.failure.serverMessage, 'غير مصرح');
    });
  });

  group('AuthRepositoryImpl - getMe', () {
    test('returns Success<UserEntity> when data source succeeds', () async {
      fakeRemoteDataSource.mockUser = testUserModel;

      final result = await repository.getMe();

      expect(result, isA<Success<UserEntity>>());
      final success = result as Success<UserEntity>;
      expect(success.data.id, 'user-123');
      expect(success.data.email, 'ahmed@example.com');
    });

    test('returns Err<UserEntity> with Unauthorized on HTTP 401', () async {
      fakeRemoteDataSource.errorToThrow = createDioResponseException(
        statusCode: 401,
        data: {'success': false, 'message': 'انتهت الجلسة'},
      );

      final result = await repository.getMe();

      expect(result, isA<Err<UserEntity>>());
      final err = result as Err<UserEntity>;
      expect(err.failure, isA<Unauthorized>());
      expect(err.failure.serverMessage, 'انتهت الجلسة');
    });

    test('returns Err<UserEntity> with Validation on HTTP 400', () async {
      fakeRemoteDataSource.errorToThrow = createDioResponseException(
        statusCode: 400,
        data: {'success': false, 'message': 'طلب غير صالح'},
      );

      final result = await repository.getMe();

      expect(result, isA<Err<UserEntity>>());
      final err = result as Err<UserEntity>;
      expect(err.failure, isA<Validation>());
      expect(err.failure.serverMessage, 'طلب غير صالح');
    });
  });
}
