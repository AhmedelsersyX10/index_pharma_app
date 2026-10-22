import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/utils/go_router_refresh_stream.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';

import '../../helpers/pump_with_providers.dart';

// --- Fakes & Mocks ---

late final Map<String, dynamic> _arTranslations;
late final Map<String, dynamic> _enTranslations;

class SynchronousDiskAssetLoader extends AssetLoader {
  const SynchronousDiskAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    if (locale.languageCode == 'en') {
      return Future.value(_enTranslations);
    }
    return Future.value(_arTranslations);
  }
}

class FakeStorageService implements StorageService {
  FakeStorageService({this.onboardingSeen = false, this.locale});

  @override
  bool onboardingSeen;

  @override
  String? locale;

  @override
  String? selectedBranchId;

  @override
  Future<bool> clearSelectedBranchId() async => true;

  @override
  Future<bool> setLocale(String locale) async => true;

  @override
  Future<bool> setOnboardingSeen(bool seen) async {
    onboardingSeen = seen;
    return true;
  }

  @override
  Future<bool> setSelectedBranchId(String branchId) async => true;

  @override
  String? themeMode;

  @override
  Future<bool> setThemeMode(String mode) async {
    themeMode = mode;
    return true;
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.getMeResult});

  ApiResult<UserEntity>? getMeResult;
  int restoreSessionCalls = 0;

  @override
  Future<ApiResult<UserEntity>> getMe() async {
    restoreSessionCalls++;
    return getMeResult ?? const Err(Unauthorized());
  }

  @override
  Future<ApiResult<UserEntity>> login({
    required String email,
    required String password,
  }) async =>
      const Err(Unauthorized());

  @override
  Future<ApiResult<void>> logout() async => const Success(null);

  @override
  Future<ApiResult<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async =>
      const Err(Unauthorized());

  @override
  Future<ApiResult<UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async =>
      const Err(Unauthorized());
}

UserEntity _createUser({
  required String id,
  required String email,
  required UserRole role,
}) {
  return UserEntity(
    id: id,
    name: 'Test User',
    email: email,
    role: role,
  );
}

Widget createTestApp(RouterConfig<Object> routerConfig) {
  return buildAppWithProviders(
    routerConfig: routerConfig,
  );
}

void main() {
  setUpAll(() async {
    await initTestEnvironment();
    _arTranslations = testArTranslations;
    _enTranslations = testEnTranslations;
  });

  group('AppRouter.redirectGuard Pure Logic Unit Tests', () {
    final customerUser = _createUser(
      id: 'c1',
      email: 'customer@index.com',
      role: UserRole.customer,
    );
    final pharmacistUser = _createUser(
      id: 'p1',
      email: 'pharmacist@index.com',
      role: UserRole.pharmacist,
    );
    final adminUser = _createUser(
      id: 'a1',
      email: 'admin@index.com',
      role: UserRole.admin,
    );
    final superadminUser = _createUser(
      id: 's1',
      email: 'superadmin@index.com',
      role: UserRole.superadmin,
    );

    test('Store routes are open to guests and customers (returns null)', () {
      expect(
        AppRouter.redirectGuard(
          authState: const AuthGuest(),
          location: AppRouter.kStoreView,
        ),
        isNull,
      );

      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kStoreView,
        ),
        isNull,
      );

      expect(
        AppRouter.redirectGuard(
          authState: const AuthInitial(),
          location: AppRouter.kStoreView,
        ),
        isNull,
      );

      expect(
        AppRouter.redirectGuard(
          authState: const AuthFailure(Network()),
          location: AppRouter.kStoreView,
        ),
        isNull,
      );
    });

    test('Staff routes requested by guest or customer redirect to store', () {
      // Guest accessing /staff
      expect(
        AppRouter.redirectGuard(
          authState: const AuthGuest(),
          location: AppRouter.kStaffDashboardView,
        ),
        equals(AppRouter.kStoreView),
      );

      // Guest accessing /staff/orders
      expect(
        AppRouter.redirectGuard(
          authState: const AuthGuest(),
          location: '${AppRouter.kStaffDashboardView}/orders',
        ),
        equals(AppRouter.kStoreView),
      );

      // Customer accessing /staff
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kStaffDashboardView,
        ),
        equals(AppRouter.kStoreView),
      );

      // AuthInitial accessing /staff
      expect(
        AppRouter.redirectGuard(
          authState: const AuthInitial(),
          location: AppRouter.kStaffDashboardView,
        ),
        equals(AppRouter.kStoreView),
      );
    });

    test('Staff routes requested by pharmacist, admin, superadmin are allowed', () {
      // Pharmacist
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(pharmacistUser),
          location: AppRouter.kStaffDashboardView,
        ),
        isNull,
      );

      // Admin
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(adminUser),
          location: '${AppRouter.kStaffDashboardView}/prescriptions',
        ),
        isNull,
      );

      // Superadmin
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(superadminUser),
          location: AppRouter.kStaffDashboardView,
        ),
        isNull,
      );
    });

    test('Branch-management routes requested by non-superadmin redirect to store', () {
      // Guest
      expect(
        AppRouter.redirectGuard(
          authState: const AuthGuest(),
          location: AppRouter.kBranchManagementView,
        ),
        equals(AppRouter.kStoreView),
      );

      // Customer
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kBranchManagementView,
        ),
        equals(AppRouter.kStoreView),
      );

      // Pharmacist
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(pharmacistUser),
          location: AppRouter.kBranchManagementView,
        ),
        equals(AppRouter.kStoreView),
      );

      // Admin
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(adminUser),
          location: '${AppRouter.kBranchManagementView}/new',
        ),
        equals(AppRouter.kStoreView),
      );
    });

    test('Branch-management routes are allowed for superadmin', () {
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(superadminUser),
          location: AppRouter.kBranchManagementView,
        ),
        isNull,
      );

      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(superadminUser),
          location: '${AppRouter.kBranchManagementView}/edit/123',
        ),
        isNull,
      );
    });

    test('Auth routes: guests are allowed; authenticated users are redirected', () {
      // Guest visits /login or /register -> allowed
      expect(
        AppRouter.redirectGuard(
          authState: const AuthGuest(),
          location: AppRouter.kLoginView,
        ),
        isNull,
      );
      expect(
        AppRouter.redirectGuard(
          authState: const AuthGuest(),
          location: AppRouter.kRegisterView,
        ),
        isNull,
      );

      // Customer visits /login -> redirected to /store
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kLoginView,
        ),
        equals(AppRouter.kStoreView),
      );

      // Pharmacist visits /login -> redirected to /staff
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(pharmacistUser),
          location: AppRouter.kLoginView,
        ),
        equals(AppRouter.kStaffDashboardView),
      );

      // Admin visits /login -> redirected to /staff
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(adminUser),
          location: AppRouter.kLoginView,
        ),
        equals(AppRouter.kStaffDashboardView),
      );

      // Superadmin visits /register -> redirected to /staff
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(superadminUser),
          location: AppRouter.kRegisterView,
        ),
        equals(AppRouter.kStaffDashboardView),
      );
    });

    test('Auth routes: authenticated customer is redirected to safe [from] return route', () {
      // Customer visits /login with from=/orders -> redirects to /orders
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kLoginView,
          from: AppRouter.kOrdersView,
        ),
        equals(AppRouter.kOrdersView),
      );

      // Customer visits /login with from=/prescription -> redirects to /prescription
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kLoginView,
          from: AppRouter.kPrescriptionView,
        ),
        equals(AppRouter.kPrescriptionView),
      );

      // Customer visits /register with from=/checkout -> redirects to /checkout
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kRegisterView,
          from: AppRouter.kCheckoutView,
        ),
        equals(AppRouter.kCheckoutView),
      );

      // Customer visits /login with from=/account -> redirects to /account
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kLoginView,
          from: AppRouter.kAccountView,
        ),
        equals(AppRouter.kAccountView),
      );

      // Unauthorized staff route in [from] for customer falls back to /store
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kLoginView,
          from: AppRouter.kStaffDashboardView,
        ),
        equals(AppRouter.kStoreView),
      );

      // Unauthorized branch management in [from] for customer falls back to /store
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kLoginView,
          from: AppRouter.kBranchManagementView,
        ),
        equals(AppRouter.kStoreView),
      );

      // Auth route in [from] (prevents infinite redirect loop) falls back to /store
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kLoginView,
          from: AppRouter.kLoginView,
        ),
        equals(AppRouter.kStoreView),
      );

      // External or invalid URL in [from] falls back to /store
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kLoginView,
          from: 'https://malicious.com',
        ),
        equals(AppRouter.kStoreView),
      );

      // Empty [from] falls back to /store
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kLoginView,
          from: '',
        ),
        equals(AppRouter.kStoreView),
      );

      // Staff user with safe staff [from] gets redirected to that staff route
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(pharmacistUser),
          location: AppRouter.kLoginView,
          from: '${AppRouter.kStaffDashboardView}/orders',
        ),
        equals('${AppRouter.kStaffDashboardView}/orders'),
      );
    });

    test('Splash and onboarding routes are allowed', () {
      expect(
        AppRouter.redirectGuard(
          authState: const AuthGuest(),
          location: AppRouter.kSplashView,
        ),
        isNull,
      );
      expect(
        AppRouter.redirectGuard(
          authState: AuthAuthenticated(customerUser),
          location: AppRouter.kOnboardingView,
        ),
        isNull,
      );
    });
  });

  group('GoRouterRefreshStream Tests', () {
    test('notifies listeners when stream emits new items', () async {
      final controller = StreamController<int>();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      int notifyCount = 0;
      refreshStream.addListener(() {
        notifyCount++;
      });

      controller.add(1);
      await pumpEventQueue();
      expect(notifyCount, equals(1));

      controller.add(2);
      await pumpEventQueue();
      expect(notifyCount, equals(2));

      refreshStream.dispose();
      await controller.close();
    });
  });

  group('AppRouter GoRouter Integration Tests', () {
    late FakeAuthRepository authRepo;
    late AuthCubit authCubit;

    setUp(() {
      getIt.reset();
      registerDefaultTestFactories();
      authRepo = FakeAuthRepository();
      authCubit = AuthCubit(authRepository: authRepo);
    });

    tearDown(() async {
      await authCubit.close();
      await getIt.reset();
    });

    testWidgets('unauthenticated user navigating to /staff is redirected to /store',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appRouter = AppRouter(
        authCubit: authCubit,
        initialLocation: AppRouter.kStoreView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pumpAndSettle();

      expect(appRouter.router.state.matchedLocation, equals(AppRouter.kStoreView));

      // Attempt navigating to /staff
      appRouter.router.go(AppRouter.kStaffDashboardView);
      await tester.pumpAndSettle();

      // Guard should redirect back to /store
      expect(appRouter.router.state.matchedLocation, equals(AppRouter.kStoreView));
    });

    testWidgets('pharmacist navigating to /staff is allowed', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final pharmacist = _createUser(
        id: 'p1',
        email: 'pharma@index.com',
        role: UserRole.pharmacist,
      );
      authRepo.getMeResult = Success(pharmacist);
      await authCubit.restoreSession();

      final appRouter = AppRouter(
        authCubit: authCubit,
        initialLocation: AppRouter.kStaffDashboardView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pumpAndSettle();

      expect(
        appRouter.router.state.matchedLocation,
        equals(AppRouter.kStaffDashboardView),
      );
    });

    testWidgets('pharmacist navigating to /admin/branches is redirected to /store',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final pharmacist = _createUser(
        id: 'p1',
        email: 'pharma@index.com',
        role: UserRole.pharmacist,
      );
      authRepo.getMeResult = Success(pharmacist);
      await authCubit.restoreSession();

      final appRouter = AppRouter(
        authCubit: authCubit,
        initialLocation: AppRouter.kStaffDashboardView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pumpAndSettle();

      // Attempt navigating to branch management
      appRouter.router.go(AppRouter.kBranchManagementView);
      await tester.pumpAndSettle();

      expect(appRouter.router.state.matchedLocation, equals(AppRouter.kStoreView));
    });

    testWidgets('superadmin navigating to /admin/branches is allowed',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final superadmin = _createUser(
        id: 's1',
        email: 'super@index.com',
        role: UserRole.superadmin,
      );
      authRepo.getMeResult = Success(superadmin);
      await authCubit.restoreSession();

      final appRouter = AppRouter(
        authCubit: authCubit,
        initialLocation: AppRouter.kBranchManagementView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pumpAndSettle();

      expect(
        appRouter.router.state.matchedLocation,
        equals(AppRouter.kBranchManagementView),
      );
    });
  });

  group('SplashView Session Restoration & Route Flow Tests', () {
    late FakeAuthRepository authRepo;
    late AuthCubit authCubit;

    setUp(() {
      getIt.reset();
      registerDefaultTestFactories();
      authRepo = FakeAuthRepository();
      authCubit = AuthCubit(authRepository: authRepo);
    });

    tearDown(() async {
      await authCubit.close();
      await getIt.reset();
    });

    testWidgets(
        'when onboardingSeen is false and locale is null, restores session and routes to language selection',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = FakeStorageService(onboardingSeen: false);

      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storage,
        initialLocation: AppRouter.kSplashView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(authRepo.restoreSessionCalls, equals(1));
      expect(
        appRouter.router.state.matchedLocation,
        equals(AppRouter.kLanguageSelectionView),
      );
    });

    testWidgets(
        'when onboardingSeen is false and locale is set, restores session and routes to onboarding',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = FakeStorageService(onboardingSeen: false, locale: 'ar');

      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storage,
        initialLocation: AppRouter.kSplashView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(authRepo.restoreSessionCalls, equals(1));
      expect(
        appRouter.router.state.matchedLocation,
        equals(AppRouter.kOnboardingView),
      );
    });

    testWidgets(
        'when onboardingSeen is true and session is customer, routes to store',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final customer = _createUser(
        id: 'c1',
        email: 'cust@index.com',
        role: UserRole.customer,
      );
      authRepo.getMeResult = Success(customer);
      final storage = FakeStorageService(onboardingSeen: true);

      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storage,
        initialLocation: AppRouter.kSplashView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(authRepo.restoreSessionCalls, equals(1));
      expect(
        appRouter.router.state.matchedLocation,
        equals(AppRouter.kStoreView),
      );
    });

    testWidgets(
        'when onboardingSeen is true and session is pharmacist, routes to staff',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final pharmacist = _createUser(
        id: 'p1',
        email: 'pharma@index.com',
        role: UserRole.pharmacist,
      );
      authRepo.getMeResult = Success(pharmacist);
      final storage = FakeStorageService(onboardingSeen: true);

      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storage,
        initialLocation: AppRouter.kSplashView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(authRepo.restoreSessionCalls, equals(1));
      expect(
        appRouter.router.state.matchedLocation,
        equals(AppRouter.kStaffDashboardView),
      );
    });

    testWidgets(
        'when onboardingSeen is true and session is unauthenticated (guest), routes to store',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      authRepo.getMeResult = const Err(Unauthorized());
      final storage = FakeStorageService(onboardingSeen: true);

      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storage,
        initialLocation: AppRouter.kSplashView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(authRepo.restoreSessionCalls, equals(1));
      expect(
        appRouter.router.state.matchedLocation,
        equals(AppRouter.kStoreView),
      );
    });
  });
}

