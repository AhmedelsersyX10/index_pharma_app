import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/screens/login_screen.dart';
import 'package:index_pharma/features/auth/presentation/screens/register_screen.dart';
import 'package:index_pharma/features/auth/presentation/widgets/auth_failure_banner.dart';
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
  ApiResult<UserEntity> loginResult = const Err(Unauthorized());
  ApiResult<UserEntity> registerResult = const Err(Conflict());

  @override
  Future<ApiResult<UserEntity>> login({
    required String email,
    required String password,
  }) async {
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
    return registerResult;
  }

  @override
  Future<ApiResult<UserEntity>> getMe() async {
    return const Err(Unauthorized());
  }

  @override
  Future<ApiResult<void>> logout() async {
    return const Success(null);
  }

  @override
  Future<ApiResult<UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    return const Err(Unauthorized());
  }
}

Widget createTestLocalizedApp({required Locale locale, required Widget child}) {
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
    _arTranslations =
        jsonDecode(await arFile.readAsString()) as Map<String, dynamic>;
    _enTranslations =
        jsonDecode(await enFile.readAsString()) as Map<String, dynamic>;
  });

  group('LoginScreen RTL/LTR & Behavior Tests', () {
    late FakeAuthRepository fakeRepo;
    late AuthCubit cubit;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      cubit = AuthCubit(authRepository: fakeRepo);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets(
      'LoginScreen renders correctly in Arabic with RTL Directionality',
      (tester) async {
        await tester.pumpWidget(
          createTestLocalizedApp(
            locale: const Locale('ar'),
            child: LoginScreen(authCubit: cubit),
          ),
        );
        await tester.pumpAndSettle();

        final directionality = Directionality.of(
          tester.element(find.byType(LoginScreen)),
        );
        expect(directionality, equals(TextDirection.rtl));

        // Verify Arabic localized titles
        expect(find.text('إندكس فارما'), findsOneWidget);
        expect(find.text('سجل الدخول لمتابعة طلباتك وروشتاتك'), findsOneWidget);
        expect(find.text('تسجيل الدخول الحسابي'), findsOneWidget);
        expect(find.text('البريد الإلكتروني'), findsOneWidget);
        expect(find.text('كلمة المرور'), findsOneWidget);
        expect(find.text('تصفح كضيف'), findsOneWidget);
      },
    );

    testWidgets(
      'LoginScreen renders correctly in English with LTR Directionality',
      (tester) async {
        await tester.pumpWidget(
          createTestLocalizedApp(
            locale: const Locale('en'),
            child: LoginScreen(authCubit: cubit),
          ),
        );
        await tester.pumpAndSettle();

        final directionality = Directionality.of(
          tester.element(find.byType(LoginScreen)),
        );
        expect(directionality, equals(TextDirection.ltr));

        // Verify English localized titles
        expect(find.text('Index Pharma'), findsOneWidget);
        expect(
          find.text('Sign in to follow your orders and prescriptions'),
          findsOneWidget,
        );
        expect(find.text('Member Access'), findsOneWidget);
        expect(find.text('Email Address'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Browse as Guest'), findsOneWidget);
      },
    );

    testWidgets('Submitting empty form triggers validation errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: LoginScreen(authCubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      // Tap submit button without entering input
      final submitBtn = find.text('تسجيل الدخول');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Validation errors must be displayed
      expect(find.text('البريد الإلكتروني مطلوب'), findsOneWidget);
      expect(find.text('كلمة المرور مطلوبة'), findsOneWidget);
    });

    testWidgets(
      'Invalid credentials failure displays error on text fields instead of AuthFailureBanner, and typing clears it',
      (tester) async {
        fakeRepo.loginResult = const Err(Unauthorized());

        await tester.pumpWidget(
          createTestLocalizedApp(
            locale: const Locale('ar'),
            child: LoginScreen(authCubit: cubit),
          ),
        );
        await tester.pumpAndSettle();

        // Enter valid format credentials
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'user@example.com',
        );
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');

        // Submit
        await tester.tap(find.text('تسجيل الدخول'));
        await tester.pumpAndSettle();

        // AuthFailureBanner must NOT be shown for credential errors
        expect(find.byType(AuthFailureBanner), findsNothing);
        expect(find.text('تعذر تسجيل الدخول'), findsNothing);

        // Error message is displayed on the password field
        expect(
          find.text('البريد أو كلمة المرور غير صحيحة، يرجى إعادة المحاولة.'),
          findsOneWidget,
        );
        // Ensure no raw Exception text is ever shown
        expect(find.textContaining('Exception'), findsNothing);

        // Typing in password field immediately clears the error
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'password1234',
        );
        await tester.pumpAndSettle();
        expect(
          find.text('البريد أو كلمة المرور غير صحيحة، يرجى إعادة المحاولة.'),
          findsNothing,
        );
      },
    );

    testWidgets('Network failure displays localized AuthFailureBanner', (
      tester,
    ) async {
      fakeRepo.loginResult = const Err(Network());

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: LoginScreen(authCubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid format credentials
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Submit
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      // Banner must be displayed for network failures
      expect(find.byType(AuthFailureBanner), findsOneWidget);
      expect(find.text('تعذر تسجيل الدخول'), findsOneWidget);
      expect(
        find.text('يرجى التحقق من اتصالك بالإنترنت والمحاولة مجدداً.'),
        findsOneWidget,
      );
    });
  });

  group('RegisterScreen RTL/LTR & Behavior Tests', () {
    late FakeAuthRepository fakeRepo;
    late AuthCubit cubit;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      cubit = AuthCubit(authRepository: fakeRepo);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets(
      'RegisterScreen renders customer registration fields in Arabic (RTL)',
      (tester) async {
        await tester.pumpWidget(
          createTestLocalizedApp(
            locale: const Locale('ar'),
            child: RegisterScreen(authCubit: cubit),
          ),
        );
        await tester.pumpAndSettle();

        final directionality = Directionality.of(
          tester.element(find.byType(RegisterScreen)),
        );
        expect(directionality, equals(TextDirection.rtl));

        // Verify portal header & fields
        expect(find.text(AppLocaleKeys.authRegisterBadge.tr()), findsOneWidget);
        expect(find.text('إنشاء حساب عميل جديد'), findsOneWidget);
        expect(find.text('الاسم بالكامل'), findsOneWidget);
        expect(find.text('البريد الإلكتروني'), findsOneWidget);
        expect(find.text('رقم الهاتف المحمول'), findsOneWidget);
        expect(find.text('العنوان ومقر الاستلام'), findsOneWidget);
        expect(
          find.text('اختياري'),
          findsNWidgets(2),
        ); // Phone and Address badges
        expect(find.text('كلمة المرور'), findsOneWidget);
        expect(
          find.text('*'),
          findsNWidgets(3),
        ); // Name, Email, Password required asterisks
        expect(find.text('يجب ألا تقل عن 8 أحرف'), findsOneWidget);
      },
    );

    testWidgets(
      'RegisterScreen renders customer registration fields in English (LTR)',
      (tester) async {
        await tester.pumpWidget(
          createTestLocalizedApp(
            locale: const Locale('en'),
            child: RegisterScreen(authCubit: cubit),
          ),
        );
        await tester.pumpAndSettle();

        final directionality = Directionality.of(
          tester.element(find.byType(RegisterScreen)),
        );
        expect(directionality, equals(TextDirection.ltr));

        expect(find.text('New account'), findsOneWidget);
        expect(find.text('Create Customer Account'), findsOneWidget);
        expect(find.text('Full Name'), findsOneWidget);
        expect(find.text('Email Address'), findsOneWidget);
        expect(find.text('Mobile Phone Number'), findsOneWidget);
        expect(find.text('Delivery Address'), findsOneWidget);
        expect(find.text('Optional'), findsNWidgets(2));
        expect(find.text('*'), findsNWidgets(3));
      },
    );

    testWidgets('Registering with already used email displays conflict alert', (
      tester,
    ) async {
      fakeRepo.registerResult = const Err(Conflict());

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: RegisterScreen(authCubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      // Enter required fields (leave optional empty)
      await tester.enterText(find.byType(TextFormField).at(0), 'أحمد محمود');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'ahmed@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(4), 'Secret1234');

      // Submit
      final registerBtn = find.text('إنشاء الحساب');
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      // Check conflict banner
      expect(find.text('البريد الإلكتروني مستخدم بالفعل'), findsOneWidget);
      expect(
        find.text(
          'هذا الحساب مسجل لدينا مسبقاً في شبكة إندكس فارما. يمكنك تسجيل الدخول مباشرة أو استعادة كلمة المرور.',
        ),
        findsOneWidget,
      );
    });
  });
}
