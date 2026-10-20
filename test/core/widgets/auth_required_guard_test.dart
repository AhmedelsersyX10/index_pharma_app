import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/utils/go_router_refresh_stream.dart';
import 'package:index_pharma/core/widgets/auth_required_guard.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/widgets/login_required_prompt.dart';
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
  ApiResult<UserEntity> loginResult = const Success(
    UserEntity(
      id: 'cust_1',
      name: 'Test Customer',
      email: 'customer@index.com',
      role: UserRole.customer,
    ),
  );

  @override
  Future<ApiResult<UserEntity>> login({required String email, required String password}) async {
    return loginResult;
  }

  @override
  Future<ApiResult<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    return loginResult;
  }

  @override
  Future<ApiResult<UserEntity>> getMe() async => const Err(Unauthorized());

  @override
  Future<ApiResult<void>> logout() async => const Success(null);
}

Widget createTestLocalizedApp({
  required Locale locale,
  required Widget child,
}) {
  return EasyLocalization(
    key: ValueKey('EasyLocalization_${locale.languageCode}'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('ar'),
    startLocale: locale,
    saveLocale: false,
    useOnlyLangCode: true,
    assetLoader: const SynchronousDiskAssetLoader(),
    child: Builder(
      builder: (context) {
        return MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: AppTheme.lightTheme,
          home: child,
        );
      },
    ),
  );
}

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    final arFile = File('assets/translations/ar.json');
    final enFile = File('assets/translations/en.json');
    _arTranslations = jsonDecode(await arFile.readAsString()) as Map<String, dynamic>;
    _enTranslations = jsonDecode(await enFile.readAsString()) as Map<String, dynamic>;
  });

  group('AuthRequiredGuard Widget Tests', () {
    late FakeAuthRepository fakeRepo;
    late AuthCubit authCubit;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      authCubit = AuthCubit(authRepository: fakeRepo);
    });

    tearDown(() {
      authCubit.close();
    });

    testWidgets('Guest is blocked: shows LoginRequiredPrompt screen and hides child', (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: BlocProvider.value(
            value: authCubit,
            child: const AuthRequiredGuard(
              routePath: '/orders',
              child: Text('Secret Protected Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Child must NOT be rendered for guests
      expect(find.text('Secret Protected Content'), findsNothing);

      // LoginRequiredPrompt screen elements must be visible
      expect(find.byType(LoginRequiredPrompt), findsOneWidget);
      expect(find.text('تسجيل الدخول مطلوب'), findsOneWidget);
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.text('إنشاء حساب جديد'), findsOneWidget);
      expect(find.text('الاستمرار في التصفح كضيف'), findsOneWidget);
    });

    testWidgets('Authenticated customer passes: renders child and hides prompt', (tester) async {
      // Simulate authenticated state
      await authCubit.login(email: 'test@index.com', password: 'password123');

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: BlocProvider.value(
            value: authCubit,
            child: const AuthRequiredGuard(
              routePath: '/orders',
              child: Text('Secret Protected Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Protected child must be rendered
      expect(find.text('Secret Protected Content'), findsOneWidget);
      expect(find.byType(LoginRequiredPrompt), findsNothing);
    });

    testWidgets('Custom fallback is rendered when user is guest', (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: BlocProvider.value(
            value: authCubit,
            child: const AuthRequiredGuard(
              routePath: '/checkout',
              fallback: Text('Custom Guest Fallback'),
              child: Text('Checkout Form'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Guest Fallback'), findsOneWidget);
      expect(find.text('Checkout Form'), findsNothing);
    });
  });

  group('LoginRequiredPrompt Unit & Interaction Tests', () {
    testWidgets('Buttons trigger expected callbacks when tapped', (tester) async {
      bool loginTapped = false;
      bool registerTapped = false;
      bool dismissTapped = false;

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: Scaffold(
            body: LoginRequiredPrompt(
              returnRoute: '/orders',
              isBottomSheet: false,
              onLoginTap: () => loginTapped = true,
              onRegisterTap: () => registerTapped = true,
              onDismiss: () => dismissTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Sign In button
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();
      expect(loginTapped, isTrue);

      // Tap Register button
      await tester.tap(find.text('إنشاء حساب جديد'));
      await tester.pumpAndSettle();
      expect(registerTapped, isTrue);

      // Tap Continue as Guest button
      await tester.tap(find.text('الاستمرار في التصفح كضيف'));
      await tester.pumpAndSettle();
      expect(dismissTapped, isTrue);
    });

    testWidgets('RTL Arabic layout: Directionality is RTL and no insurance or English text', (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: const Scaffold(
            body: LoginRequiredPrompt(
              returnRoute: '/prescription',
              isBottomSheet: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final directionality = Directionality.of(tester.element(find.byType(LoginRequiredPrompt)));
      expect(directionality, equals(TextDirection.rtl));

      // Arabic verified badges and labels
      expect(find.text('منصة صيدلانية معتمدة وقانونية'), findsOneWidget);
      expect(find.text('تسجيل الدخول مطلوب'), findsOneWidget);
      expect(find.text('حفظ الروشتات'), findsOneWidget);
      expect(find.text('تتبع الطلبات'), findsOneWidget);
      expect(find.text('أدوية أصلية 100%'), findsOneWidget);

      // Verify no insurance wording is present
      expect(find.textContaining('تأمين'), findsNothing);
      expect(find.textContaining('Insurance'), findsNothing);

      // Verify no English acronym like HIPAA in Arabic mode
      expect(find.textContaining('HIPAA'), findsNothing);

      // Verify privacy text in Arabic
      expect(
        find.text('بياناتك الصحية والطبية مشفرة ومحمية بأعلى معايير الخصوصية والأمان'),
        findsOneWidget,
      );
    });

    testWidgets('LTR English layout: Directionality is LTR and renders English keys', (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('en'),
          child: const Scaffold(
            body: LoginRequiredPrompt(
              returnRoute: '/account',
              isBottomSheet: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final directionality = Directionality.of(tester.element(find.byType(LoginRequiredPrompt)));
      expect(directionality, equals(TextDirection.ltr));

      expect(find.text('Login Required'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create New Account'), findsOneWidget);
      expect(find.text('Continue Browsing as Guest'), findsOneWidget);
      expect(find.text('Save Prescriptions'), findsOneWidget);
      expect(find.text('Track Orders'), findsOneWidget);
      expect(find.text('100% Genuine Meds'), findsOneWidget);
    });
  });

  group('GoRouter End-to-End: Return to Original Route After Login', () {
    late FakeAuthRepository fakeRepo;
    late AuthCubit authCubit;
    late AppRouter appRouter;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      authCubit = AuthCubit(authRepository: fakeRepo);
      appRouter = AppRouter(
        authCubit: authCubit,
        refreshListenable: GoRouterRefreshStream(authCubit.stream),
      );
    });

    tearDown(() {
      authCubit.close();
    });

    testWidgets('Guest navigating to /orders is blocked; after login, returns to /orders', (tester) async {
      await tester.pumpWidget(
        EasyLocalization(
          key: const ValueKey('EasyLocalization_RouterTest'),
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
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                theme: AppTheme.lightTheme,
                routerConfig: appRouter.router,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Navigate to /orders as a guest
      appRouter.router.go(AppRouter.kOrdersView);
      await tester.pumpAndSettle();

      // Verified: guest is blocked, A4 prompt is rendered, MyOrdersPlaceholder is NOT rendered
      expect(find.text('My Orders Screen (Placeholder)'), findsNothing);
      expect(find.byType(LoginRequiredPrompt), findsOneWidget);
      expect(find.text('تسجيل الدخول مطلوب'), findsOneWidget);

      // 2. Tap Sign In button inside the prompt
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      // Now on /login?from=/orders
      expect(find.text('تسجيل الدخول الحسابي'), findsOneWidget);

      // 3. User logs in successfully
      await authCubit.login(email: 'user@index.com', password: 'password123');
      await tester.pumpAndSettle();

      // 4. GoRouter should redirect customer directly to originally requested route (/orders)!
      expect(find.text('My Orders Screen (Placeholder)'), findsOneWidget);
      expect(find.byType(LoginRequiredPrompt), findsNothing);
    });
  });
}
