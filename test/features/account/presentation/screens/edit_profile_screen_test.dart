import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/account/presentation/screens/edit_profile_screen.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
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
  ApiResult<UserEntity>? updateProfileResult;
  String? lastUpdateName;
  String? lastUpdatePhone;
  String? lastUpdateAddress;
  int updateProfileCalls = 0;

  @override
  Future<ApiResult<UserEntity>> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<UserEntity>> getMe() => throw UnimplementedError();

  @override
  Future<ApiResult<void>> logout() => throw UnimplementedError();

  @override
  Future<ApiResult<UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    updateProfileCalls++;
    lastUpdateName = name;
    lastUpdatePhone = phone;
    lastUpdateAddress = address;
    return updateProfileResult!;
  }
}

void main() {
  setUpAll(() async {
    final arRaw = await File('assets/translations/ar.json').readAsString();
    final enRaw = await File('assets/translations/en.json').readAsString();
    _arTranslations = jsonDecode(arRaw) as Map<String, dynamic>;
    _enTranslations = jsonDecode(enRaw) as Map<String, dynamic>;

    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  late FakeAuthRepository fakeAuthRepository;
  late AuthCubit authCubit;

  const initialUser = UserEntity(
    id: 'user-001',
    name: 'أحمد محمود',
    email: 'ahmed@example.com',
    role: UserRole.customer,
    phone: '01012345678',
    address: 'مدينة نصر، القاهرة',
  );

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    authCubit = AuthCubit(authRepository: fakeAuthRepository);
    authCubit.emit(const AuthAuthenticated(initialUser));
  });

  tearDown(() {
    authCubit.close();
  });

  Widget buildTestApp() {
    return EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      assetLoader: const SynchronousDiskAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: EditProfileScreen(
              authCubit: authCubit,
            ),
          );
        },
      ),
    );
  }

  group('EditProfileScreen (Stitch D6)', () {
    testWidgets('pre-fills user data into text fields', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final nameField = find.byKey(const ValueKey('edit_profile_name_field'));
      final phoneField = find.byKey(const ValueKey('edit_profile_phone_field'));
      final addressField = find.byKey(const ValueKey('edit_profile_address_field'));

      expect(nameField, findsOneWidget);
      expect(phoneField, findsOneWidget);
      expect(addressField, findsOneWidget);

      expect(find.text('أحمد محمود'), findsOneWidget);
      expect(find.text('01012345678'), findsOneWidget);
      expect(find.text('مدينة نصر، القاهرة'), findsOneWidget);
    });

    testWidgets('shows validation errors when name is empty or phone is invalid', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Clear name and enter invalid phone
      await tester.enterText(find.byKey(const ValueKey('edit_profile_name_field')), '');
      await tester.enterText(find.byKey(const ValueKey('edit_profile_phone_field')), '12345');
      await tester.pumpAndSettle();

      // Tap save
      final saveBtn = find.byKey(const ValueKey('edit_profile_save_btn'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('يرجى إدخال اسمك بالكامل'), findsOneWidget);
      expect(find.text('رقم الهاتف يجب أن يتكون من 11 رقماً ويبدأ بـ 01'), findsOneWidget);
      expect(fakeAuthRepository.updateProfileCalls, 0);
    });

    testWidgets('saves valid profile changes and emits updated user', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const updatedUser = UserEntity(
        id: 'user-001',
        name: 'أحمد محمود إبراهيم',
        email: 'ahmed@example.com',
        role: UserRole.customer,
        phone: '01198765432',
        address: 'التجمع الخامس، القاهرة',
      );
      fakeAuthRepository.updateProfileResult = const Success(updatedUser);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('edit_profile_name_field')),
        'أحمد محمود إبراهيم',
      );
      await tester.enterText(
        find.byKey(const ValueKey('edit_profile_phone_field')),
        '01198765432',
      );
      await tester.enterText(
        find.byKey(const ValueKey('edit_profile_address_field')),
        'التجمع الخامس، القاهرة',
      );
      await tester.pumpAndSettle();

      final saveBtn = find.byKey(const ValueKey('edit_profile_save_btn'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump(); // Start saving

      expect(fakeAuthRepository.updateProfileCalls, 1);
      expect(fakeAuthRepository.lastUpdateName, 'أحمد محمود إبراهيم');
      expect(fakeAuthRepository.lastUpdatePhone, '01198765432');
      expect(fakeAuthRepository.lastUpdateAddress, 'التجمع الخامس، القاهرة');

      await tester.pumpAndSettle();

      // AuthCubit state is updated
      expect(authCubit.state, const AuthAuthenticated(updatedUser));
      expect(find.text('تم تحديث الملف الشخصي بنجاح'), findsOneWidget);
    });

    testWidgets('displays error message when updateProfile fails', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      fakeAuthRepository.updateProfileResult = const Err(
        Validation(serverMessage: 'الاسم لا يمكن أن يكون فارغاً'),
      );

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final saveBtn = find.byKey(const ValueKey('edit_profile_save_btn'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(fakeAuthRepository.updateProfileCalls, 1);
      expect(find.text('الاسم لا يمكن أن يكون فارغاً'), findsOneWidget);
      // Session is preserved
      expect(authCubit.state, const AuthAuthenticated(initialUser));
    });
  });
}
