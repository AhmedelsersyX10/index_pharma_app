import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/screens/login_screen.dart';
import 'package:index_pharma/features/auth/presentation/widgets/auth_failure_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final Map<String, dynamic> _arTranslations;

class _TestAssetLoader extends AssetLoader {
  const _TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    return Future.value(_arTranslations);
  }
}

class TrackingFakeAuthRepository implements AuthRepository {
  int loginCallCount = 0;
  String? lastEmail;
  String? lastPassword;
  ApiResult<UserEntity> loginResult = const Err(Unauthorized());

  @override
  Future<ApiResult<UserEntity>> login({required String email, required String password}) async {
    loginCallCount++;
    lastEmail = email;
    lastPassword = password;
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
    return const Err(Unauthorized());
  }

  @override
  Future<ApiResult<UserEntity>> getMe() async => const Err(Unauthorized());

  @override
  Future<ApiResult<void>> logout() async => const Success(null);

  @override
  Future<ApiResult<UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async => const Err(Unauthorized());
}

Widget createTestApp({required Widget child}) {
  return EasyLocalization(
    supportedLocales: const [Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('ar'),
    startLocale: const Locale('ar'),
    saveLocale: false,
    useOnlyLangCode: true,
    assetLoader: const _TestAssetLoader(),
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
    _arTranslations = jsonDecode(await arFile.readAsString()) as Map<String, dynamic>;
  });

  group('LoginForm Auto-submit Prevention & Field Error Tests', () {
    late TrackingFakeAuthRepository fakeRepo;
    late AuthCubit cubit;

    setUp(() {
      fakeRepo = TrackingFakeAuthRepository();
      cubit = AuthCubit(authRepository: fakeRepo);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('Typing into email and password fields does NOT trigger auto-submission', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(child: LoginScreen(authCubit: cubit)));
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      // Type email
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();
      expect(fakeRepo.loginCallCount, equals(0));

      // Type password character-by-character
      await tester.enterText(passwordField, '1');
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, '12');
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, '123');
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, '1234');
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, '12345');
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, '123456'); // Meets min length >= 6
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, '12345678');
      await tester.pumpAndSettle();

      // Crucial assertion: login must NOT have been called during typing!
      expect(fakeRepo.loginCallCount, equals(0));
    });

    testWidgets('Tapping submit button triggers login with entered credentials', (tester) async {
      await tester.pumpWidget(createTestApp(child: LoginScreen(authCubit: cubit)));
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'customer@indexpharma.com');
      await tester.enterText(passwordField, 'Secret123');
      await tester.pumpAndSettle();

      // Submit via button
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(fakeRepo.loginCallCount, equals(1));
      expect(fakeRepo.lastEmail, equals('customer@indexpharma.com'));
      expect(fakeRepo.lastPassword, equals('Secret123'));
    });

    testWidgets('Submitting via keyboard Done action triggers login', (tester) async {
      await tester.pumpWidget(createTestApp(child: LoginScreen(authCubit: cubit)));
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'customer@indexpharma.com');
      await tester.enterText(passwordField, 'Secret123');
      await tester.pumpAndSettle();

      // Submit via keyboard Done action
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(fakeRepo.loginCallCount, equals(1));
    });

    testWidgets(
      '401 error shows message on password field, suppresses banner, and editing email clears it',
      (tester) async {
        fakeRepo.loginResult = const Err(Unauthorized());

        await tester.pumpWidget(createTestApp(child: LoginScreen(authCubit: cubit)));
        await tester.pumpAndSettle();

        final emailField = find.byType(TextFormField).at(0);
        final passwordField = find.byType(TextFormField).at(1);

        await tester.enterText(emailField, 'wrong@user.com');
        await tester.enterText(passwordField, 'wrongpass');
        await tester.pumpAndSettle();

        await tester.tap(find.text('تسجيل الدخول'));
        await tester.pumpAndSettle();

        // Banner is suppressed
        expect(find.byType(AuthFailureBanner), findsNothing);

        // Error message shown on field
        const expectedError = 'البريد أو كلمة المرور غير صحيحة، يرجى إعادة المحاولة.';
        expect(find.text(expectedError), findsOneWidget);

        // Editing email field clears the error
        await tester.enterText(emailField, 'fixed@user.com');
        await tester.pumpAndSettle();
        expect(find.text(expectedError), findsNothing);
      },
    );

    testWidgets('Editing password field clears field error message', (tester) async {
      fakeRepo.loginResult = const Err(Unauthorized());

      await tester.pumpWidget(createTestApp(child: LoginScreen(authCubit: cubit)));
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'wrong@user.com');
      await tester.enterText(passwordField, 'wrongpass');
      await tester.pumpAndSettle();

      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      const expectedError = 'البريد أو كلمة المرور غير صحيحة، يرجى إعادة المحاولة.';
      expect(find.text(expectedError), findsOneWidget);

      // Editing password field clears the error
      await tester.enterText(passwordField, 'newpass');
      await tester.pumpAndSettle();
      expect(find.text(expectedError), findsNothing);
    });
  });
}
