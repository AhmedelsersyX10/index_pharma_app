import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/account/presentation/screens/account_screen.dart';
import 'package:index_pharma/features/account/presentation/widgets/account_guest_view.dart';
import 'package:index_pharma/features/account/presentation/widgets/account_profile_card.dart';
import 'package:index_pharma/features/account/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
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
  ApiResult<void>? logoutResult = const Success(null);
  int logoutCalls = 0;

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
  Future<ApiResult<void>> logout() async {
    logoutCalls++;
    return logoutResult ?? const Success(null);
  }

  @override
  Future<ApiResult<UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) =>
      throw UnimplementedError();
}

class FakeBranchRepository implements BranchRepository {
  @override
  Future<ApiResult<List<BranchEntity>>> getBranches() async {
    return const Success([
      BranchEntity(
        id: 'branch-1',
        name: 'فرع مدينة نصر',
        address: 'شارع عباس العقاد',
        phone: '01012345678',
      ),
    ]);
  }
}

class FakeStorageService implements StorageService {
  String? _selectedBranchId = 'branch-1';
  String? _locale = 'ar';
  bool _onboardingSeen = true;

  @override
  String? get selectedBranchId => _selectedBranchId;

  @override
  Future<bool> setSelectedBranchId(String branchId) async {
    _selectedBranchId = branchId;
    return true;
  }

  @override
  Future<bool> clearSelectedBranchId() async {
    _selectedBranchId = null;
    return true;
  }

  @override
  String? get locale => _locale;

  @override
  Future<bool> setLocale(String locale) async {
    _locale = locale;
    return true;
  }

  @override
  bool get onboardingSeen => _onboardingSeen;

  @override
  Future<bool> setOnboardingSeen(bool seen) async {
    _onboardingSeen = seen;
    return true;
  }

  String? _themeMode;

  @override
  String? get themeMode => _themeMode;

  @override
  Future<bool> setThemeMode(String mode) async {
    _themeMode = mode;
    return true;
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
  late FakeBranchRepository fakeBranchRepository;
  late FakeStorageService fakeStorageService;
  late AuthCubit authCubit;
  late BranchCubit branchCubit;

  const testUser = UserEntity(
    id: 'user-001',
    name: 'أحمد محمود',
    email: 'ahmed@example.com',
    role: UserRole.customer,
    phone: '01012345678',
    address: 'مدينة نصر، القاهرة',
  );

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    fakeBranchRepository = FakeBranchRepository();
    fakeStorageService = FakeStorageService();

    authCubit = AuthCubit(authRepository: fakeAuthRepository);
    branchCubit = BranchCubit(
      branchRepository: fakeBranchRepository,
      storageService: fakeStorageService,
    );
  });

  tearDown(() {
    authCubit.close();
    branchCubit.close();
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
            home: AccountScreen(
              authCubit: authCubit,
              storageService: fakeStorageService,
              branchCubit: branchCubit,
            ),
          );
        },
      ),
    );
  }

  group('AccountScreen - Authenticated View (Stitch D5)', () {
    testWidgets('renders user profile details and action elements', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      authCubit.emit(const AuthAuthenticated(testUser));
      await branchCubit.fetchBranches();

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Verify Profile Card
      expect(find.byType(AccountProfileCard), findsOneWidget);
      expect(find.text('أحمد محمود'), findsOneWidget);
      expect(find.text('ahmed@example.com'), findsOneWidget);
      expect(find.text('01012345678'), findsOneWidget);
      expect(find.text('مدينة نصر، القاهرة'), findsOneWidget);
      expect(find.byKey(const ValueKey('edit_profile_button')), findsOneWidget);

      // Verify Orders & Prescriptions tiles
      expect(find.byKey(const ValueKey('account_orders_tile')), findsOneWidget);
      expect(find.byKey(const ValueKey('account_prescriptions_tile')), findsOneWidget);

      // Verify Assigned Branch
      expect(find.text('فرع مدينة نصر'), findsOneWidget);
      expect(find.byKey(const ValueKey('account_change_branch_btn')), findsOneWidget);

      // Verify Logout Button
      expect(find.byKey(const ValueKey('account_logout_button')), findsOneWidget);
    });

    testWidgets('toggles language and persists selection via StorageService', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      authCubit.emit(const AuthAuthenticated(testUser));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final switchTile = find.byKey(const ValueKey('account_language_switch_tile'));
      expect(switchTile, findsOneWidget);
      await tester.ensureVisible(switchTile);

      // Tap to toggle language (ar -> en)
      await tester.tap(switchTile);
      await tester.pumpAndSettle();

      expect(fakeStorageService.locale, equals('en'));

      // Tap again to toggle back (en -> ar)
      await tester.ensureVisible(switchTile);
      await tester.tap(switchTile);
      await tester.pumpAndSettle();

      expect(fakeStorageService.locale, equals('ar'));
    });

    testWidgets('shows logout dialog, cancelling preserves session, confirming logs out to guest', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      authCubit.emit(const AuthAuthenticated(testUser));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final logoutBtn = find.byKey(const ValueKey('account_logout_button'));
      await tester.ensureVisible(logoutBtn);

      // Tap logout
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Dialog is open
      expect(find.byType(LogoutConfirmationDialog), findsOneWidget);

      // Tap cancel
      await tester.tap(find.byKey(const ValueKey('logout_cancel_button')));
      await tester.pumpAndSettle();

      expect(find.byType(LogoutConfirmationDialog), findsNothing);
      expect(authCubit.state, isA<AuthAuthenticated>());
      expect(fakeAuthRepository.logoutCalls, 0);

      // Tap logout again and confirm
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('logout_confirm_button')));
      await tester.pumpAndSettle();

      expect(fakeAuthRepository.logoutCalls, 1);
      expect(authCubit.state, isA<AuthGuest>());

      // Screen now displays Guest View
      expect(find.byType(AccountGuestView), findsOneWidget);
      expect(find.byKey(const ValueKey('guest_login_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('guest_register_button')), findsOneWidget);
    });
  });

  group('AccountScreen - Guest View (Stitch D5)', () {
    testWidgets('renders guest welcome, sign-in, register buttons, and benefits', (tester) async {
      authCubit.emit(const AuthGuest());

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AccountGuestView), findsOneWidget);
      expect(find.byKey(const ValueKey('guest_login_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('guest_register_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('guest_language_switch_tile')), findsOneWidget);
    });
  });
}
