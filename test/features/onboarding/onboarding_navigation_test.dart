import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/screens/login_screen.dart';
import 'package:index_pharma/features/auth/presentation/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class FakeAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<UserEntity>> getMe() async => const Err(Unauthorized());

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
}

class FakeStorageService implements StorageService {
  FakeStorageService({this.onboardingSeen = false});

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
}

Widget createTestApp(RouterConfig<Object> routerConfig) {
  return EasyLocalization(
    key: UniqueKey(),
    supportedLocales: const [Locale('ar'), Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('ar'),
    startLocale: const Locale('ar'),
    saveLocale: false,
    useOnlyLangCode: true,
    assetLoader: const SynchronousDiskAssetLoader(),
    child: Builder(
      builder: (context) {
        return MaterialApp.router(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: AppTheme.lightTheme,
          routerConfig: routerConfig,
        );
      },
    ),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    _arTranslations = jsonDecode(
      File('assets/translations/ar.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    _enTranslations = jsonDecode(
      File('assets/translations/en.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    await EasyLocalization.ensureInitialized();
  });

  group('Onboarding Navigation Tests', () {
    late FakeAuthRepository authRepo;
    late AuthCubit authCubit;

    setUp(() {
      authRepo = FakeAuthRepository();
      authCubit = AuthCubit(authRepository: authRepo);
    });

    tearDown(() async {
      await authCubit.close();
    });

    testWidgets(
        'Tapping Sign In on onboarding navigates to LoginScreen and marks onboarding seen',
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
        initialLocation: AppRouter.kOnboardingView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pumpAndSettle();

      // Tap Skip in TopBar to jump to the last page immediately
      final skipFinder = find.text('تخطي');
      expect(skipFinder, findsOneWidget);
      await tester.tap(skipFinder);
      await tester.pumpAndSettle();

      // Find and tap "تسجيل الدخول"
      final signInFinder = find.text('تسجيل الدخول');
      expect(signInFinder, findsOneWidget);
      await tester.tap(signInFinder);
      await tester.pumpAndSettle();

      // Verify navigated to /login
      expect(appRouter.router.state.matchedLocation, equals(AppRouter.kLoginView));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(storage.onboardingSeen, isTrue);
    });

    testWidgets(
        'Tapping Create Account on onboarding navigates to RegisterScreen and marks onboarding seen',
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
        initialLocation: AppRouter.kOnboardingView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pumpAndSettle();

      // Tap Skip in TopBar to jump to the last page
      final skipFinder = find.text('تخطي');
      expect(skipFinder, findsOneWidget);
      await tester.tap(skipFinder);
      await tester.pumpAndSettle();

      // Find and tap "إنشاء حساب جديد"
      final registerFinder = find.text('إنشاء حساب جديد');
      expect(registerFinder, findsOneWidget);
      await tester.tap(registerFinder);
      await tester.pumpAndSettle();

      // Verify navigated to /register
      expect(
        appRouter.router.state.matchedLocation,
        equals(AppRouter.kRegisterView),
      );
      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(storage.onboardingSeen, isTrue);
    });

    testWidgets(
        'Tapping Start Exploring navigates to Store and marks onboarding seen',
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
        initialLocation: AppRouter.kOnboardingView,
      );

      await tester.pumpWidget(createTestApp(appRouter.router));
      await tester.pumpAndSettle();

      // Tap Skip to go to last page
      await tester.tap(find.text('تخطي'));
      await tester.pumpAndSettle();

      // Find and tap "ابدأ الاستكشاف"
      final exploreFinder = find.text('ابدأ الاستكشاف');
      expect(exploreFinder, findsOneWidget);
      await tester.tap(exploreFinder);
      await tester.pumpAndSettle();

      // Verify navigated to /store
      expect(appRouter.router.state.matchedLocation, equals(AppRouter.kStoreView));
      expect(storage.onboardingSeen, isTrue);
    });
  });
}
