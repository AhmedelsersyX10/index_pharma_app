import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/screens/login_screen.dart';
import 'package:index_pharma/features/auth/presentation/screens/register_screen.dart';

import '../../helpers/pump_with_providers.dart';

void main() {
  setUpAll(() async {
    await initTestEnvironment();
  });

  group('Onboarding Navigation Tests', () {
    late FakeTestAuthRepository authRepo;
    late AuthCubit authCubit;
    late FakeTestStorageService storage;

    setUp(() {
      getIt.reset();
      authRepo = FakeTestAuthRepository();
      authCubit = AuthCubit(authRepository: authRepo);
      storage = FakeTestStorageService(onboardingSeen: false);
      registerDefaultTestFactories(storageService: storage);
    });

    tearDown(() async {
      await authCubit.close();
      await getIt.reset();
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

      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storage,
        initialLocation: AppRouter.kOnboardingView,
      );

      await tester.pumpWidget(
        buildAppWithProviders(
          routerConfig: appRouter.router,
          authCubit: authCubit,
          storageService: storage,
        ),
      );
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

      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storage,
        initialLocation: AppRouter.kOnboardingView,
      );

      await tester.pumpWidget(
        buildAppWithProviders(
          routerConfig: appRouter.router,
          authCubit: authCubit,
          storageService: storage,
        ),
      );
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

      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storage,
        initialLocation: AppRouter.kOnboardingView,
      );

      await tester.pumpWidget(
        buildAppWithProviders(
          routerConfig: appRouter.router,
          authCubit: authCubit,
          storageService: storage,
        ),
      );
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
