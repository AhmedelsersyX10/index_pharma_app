import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart' hide Timeout;
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  ApiResult<UserEntity>? loginResult;
  ApiResult<UserEntity>? registerResult;
  ApiResult<UserEntity>? getMeResult;
  ApiResult<void>? logoutResult;

  String? lastLoginEmail;
  String? lastLoginPassword;

  String? lastRegisterName;
  String? lastRegisterEmail;
  String? lastRegisterPassword;
  String? lastRegisterPhone;
  String? lastRegisterAddress;

  int logoutCallCount = 0;

  @override
  Future<ApiResult<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
    return loginResult!;
  }

  @override
  Future<ApiResult<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    lastRegisterName = name;
    lastRegisterEmail = email;
    lastRegisterPassword = password;
    lastRegisterPhone = phone;
    lastRegisterAddress = address;
    return registerResult!;
  }

  @override
  Future<ApiResult<UserEntity>> getMe() async {
    return getMeResult!;
  }

  @override
  Future<ApiResult<void>> logout() async {
    logoutCallCount++;
    return logoutResult!;
  }
}

void main() {
  late FakeAuthRepository fakeRepository;
  late ApiClient fakeApiClient;
  late AuthCubit cubit;

  const testUser = UserEntity(
    id: 'user-001',
    name: 'Ahmed Elsherbiny',
    email: 'ahmed@indexpharma.com',
    role: UserRole.customer,
    phone: '01000000000',
    address: 'Cairo, Egypt',
  );

  setUp(() {
    fakeRepository = FakeAuthRepository();
    fakeApiClient = ApiClient(
      dio: Dio(),
      cookieJar: CookieJar(),
      enableLogging: false,
    );
    cubit = AuthCubit(
      authRepository: fakeRepository,
      apiClient: fakeApiClient,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('AuthCubit - Initial State', () {
    test('has AuthInitial as initial state', () {
      expect(cubit.state, const AuthInitial());
    });
  });

  group('AuthCubit - restoreSession', () {
    test('emits [AuthLoading, AuthAuthenticated] when getMe succeeds', () async {
      fakeRepository.getMeResult = const Success(testUser);

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.restoreSession();
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
      );
    });

    test('emits [AuthLoading, AuthGuest] when getMe fails with Unauthorized (HTTP 401)', () async {
      // 401 on app start means not logged in (guest), not an error.
      fakeRepository.getMeResult = const Err(Unauthorized(serverMessage: 'غير مصرح'));

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.restoreSession();
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthGuest(),
        ],
      );
    });

    test('emits [AuthLoading, AuthFailure] when getMe fails with Server error (HTTP 500)', () async {
      const serverFailure = Server(serverMessage: 'خطأ في السيرفر');
      fakeRepository.getMeResult = const Err(serverFailure);

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.restoreSession();
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthFailure(serverFailure),
        ],
      );
    });

    test('emits [AuthLoading, AuthFailure] when getMe fails with Network error', () async {
      const networkFailure = Network(serverMessage: 'لا يوجد اتصال بالإنترنت');
      fakeRepository.getMeResult = const Err(networkFailure);

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.restoreSession();
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthFailure(networkFailure),
        ],
      );
    });
  });

  group('AuthCubit - login', () {
    test('emits [AuthLoading, AuthAuthenticated] when login succeeds', () async {
      fakeRepository.loginResult = const Success(testUser);

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.login(
        email: 'ahmed@indexpharma.com',
        password: 'Password123',
      );
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
      );
      expect(fakeRepository.lastLoginEmail, 'ahmed@indexpharma.com');
      expect(fakeRepository.lastLoginPassword, 'Password123');
    });

    test('emits [AuthLoading, AuthFailure] when login fails with Unauthorized', () async {
      const authFailure = Unauthorized(serverMessage: 'بيانات الدخول غير صحيحة');
      fakeRepository.loginResult = const Err(authFailure);

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.login(
        email: 'ahmed@indexpharma.com',
        password: 'WrongPassword',
      );
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthFailure(authFailure),
        ],
      );
    });

    test('emits [AuthLoading, AuthFailure] when login fails with Validation', () async {
      const valFailure = Validation(serverMessage: 'البريد الإلكتروني مطلوب');
      fakeRepository.loginResult = const Err(valFailure);

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.login(
        email: '',
        password: '123',
      );
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthFailure(valFailure),
        ],
      );
    });
  });

  group('AuthCubit - register', () {
    test('emits [AuthLoading, AuthAuthenticated] when register succeeds', () async {
      fakeRepository.registerResult = const Success(testUser);

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.register(
        name: 'Ahmed Elsherbiny',
        email: 'ahmed@indexpharma.com',
        password: 'Password123',
        phone: '01000000000',
        address: 'Cairo, Egypt',
      );
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
      );
      expect(fakeRepository.lastRegisterName, 'Ahmed Elsherbiny');
      expect(fakeRepository.lastRegisterEmail, 'ahmed@indexpharma.com');
      expect(fakeRepository.lastRegisterPassword, 'Password123');
      expect(fakeRepository.lastRegisterPhone, '01000000000');
      expect(fakeRepository.lastRegisterAddress, 'Cairo, Egypt');
    });

    test('emits [AuthLoading, AuthFailure] when register fails with Conflict (HTTP 409)', () async {
      const conflictFailure = Conflict(serverMessage: 'البريد الإلكتروني مسجل بالفعل');
      fakeRepository.registerResult = const Err(conflictFailure);

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.register(
        name: 'Ahmed',
        email: 'existing@indexpharma.com',
        password: 'Password123',
      );
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthFailure(conflictFailure),
        ],
      );
    });
  });

  group('AuthCubit - logout', () {
    test('emits [AuthLoading, AuthGuest] when logout succeeds', () async {
      fakeRepository.logoutResult = const Success(null);

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.logout();
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthGuest(),
        ],
      );
      expect(fakeRepository.logoutCallCount, 1);
    });

    test('emits [AuthLoading, AuthFailure] when logout encounters Server failure', () async {
      const serverFailure = Server(serverMessage: 'فشل تسجيل الخروج في السيرفر');
      fakeRepository.logoutResult = const Err(serverFailure);

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.logout();
      await pumpEventQueue();

      expect(
        states,
        [
          const AuthLoading(),
          const AuthFailure(serverFailure),
        ],
      );
      expect(fakeRepository.logoutCallCount, 1);
    });
  });

  group('AuthCubit - onSessionExpired & ApiClient Integration', () {
    test('emits AuthGuest when onSessionExpired is directly called', () async {
      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      cubit.onSessionExpired();
      await pumpEventQueue();

      expect(states, [const AuthGuest()]);
    });

    test('emits AuthGuest when ApiClient triggers onSessionExpired', () async {
      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      expect(fakeApiClient.onSessionExpired, isNotNull);
      fakeApiClient.onSessionExpired!();
      await pumpEventQueue();

      expect(states, [const AuthGuest()]);
    });

    test('cleans up ApiClient listener when cubit is closed', () async {
      expect(fakeApiClient.onSessionExpired, isNotNull);
      await cubit.close();
      expect(fakeApiClient.onSessionExpired, isNull);
    });
  });

  group('AuthState - Sealed Hierarchy & Exhaustiveness', () {
    test('exhaustive switch pattern matching covers all sealed cases', () {
      const states = <AuthState>[
        AuthInitial(),
        AuthLoading(),
        AuthAuthenticated(testUser),
        AuthGuest(),
        AuthFailure(Network()),
      ];

      for (final state in states) {
        final description = switch (state) {
          AuthInitial() => 'initial',
          AuthLoading() => 'loading',
          AuthAuthenticated(:final user) => 'authenticated: ${user.name}',
          AuthGuest() => 'guest',
          AuthFailure(:final failure) => 'failure: ${failure.runtimeType}',
        };
        expect(description, isNotEmpty);
      }
    });

    test('equality and hashCode work as expected across state instances', () {
      expect(const AuthInitial(), const AuthInitial());
      expect(const AuthLoading(), const AuthLoading());
      expect(const AuthGuest(), const AuthGuest());

      expect(
        const AuthAuthenticated(testUser),
        const AuthAuthenticated(testUser),
      );

      const fail1 = AuthFailure(Network(serverMessage: 'Net Err'));
      const fail2 = AuthFailure(Network(serverMessage: 'Net Err'));
      expect(fail1, fail2);
      expect(fail1.hashCode, fail2.hashCode);

      expect(const AuthInitial().toString(), 'AuthInitial()');
      expect(const AuthLoading().toString(), 'AuthLoading()');
      expect(const AuthGuest().toString(), 'AuthGuest()');
      expect(const AuthAuthenticated(testUser).toString(), contains('user-001'));
      expect(fail1.toString(), contains('AuthFailure'));
    });
  });
}
