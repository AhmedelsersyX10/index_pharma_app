import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/account/presentation/widgets/account_preferences_section.dart';
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

class FakeStorageService implements StorageService {
  String? _themeMode;
  String? _locale = 'ar';
  bool _onboardingSeen = true;

  @override
  String? get themeMode => _themeMode;

  @override
  Future<bool> setThemeMode(String mode) async {
    _themeMode = mode;
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

  @override
  String? selectedBranchId = 'branch-1';

  @override
  Future<bool> clearSelectedBranchId() async => true;

  @override
  Future<bool> setSelectedBranchId(String branchId) async => true;
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

  late FakeStorageService fakeStorageService;
  late ThemeCubit themeCubit;

  setUp(() {
    fakeStorageService = FakeStorageService();
    themeCubit = ThemeCubit(storageService: fakeStorageService);
  });

  tearDown(() {
    themeCubit.close();
  });

  Widget buildTestWidget({Locale locale = const Locale('ar')}) {
    return EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: locale,
      assetLoader: const SynchronousDiskAssetLoader(),
      child: Builder(
        builder: (context) {
          return BlocProvider<ThemeCubit>.value(
            value: themeCubit,
            child: MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeCubit.state,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: AccountPreferencesSection(
                    storageService: fakeStorageService,
                    themeCubit: themeCubit,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  group('AccountPreferencesSection - Theme Toggle Widget Tests', () {
    testWidgets('renders theme card and 3 mode options with localized labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Theme section header title
      expect(find.text('مظهر التطبيق'), findsOneWidget);
      expect(find.text('اختر الوضع الفاتح أو الداكن أو التلقائي'), findsOneWidget);

      // Verify the 3 theme option buttons
      expect(find.byKey(const ValueKey('account_theme_option_light')), findsOneWidget);
      expect(find.byKey(const ValueKey('account_theme_option_dark')), findsOneWidget);
      expect(find.byKey(const ValueKey('account_theme_option_system')), findsOneWidget);

      expect(find.text('فاتح'), findsOneWidget);
      expect(find.text('داكن'), findsOneWidget);
      expect(find.text('تلقائي'), findsOneWidget);
    });

    testWidgets('defaults to system mode and persists when tapping dark mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(themeCubit.state, equals(ThemeMode.system));

      // Tap dark mode option
      final darkButton = find.byKey(const ValueKey('account_theme_option_dark'));
      await tester.tap(darkButton);
      await tester.pumpAndSettle();

      expect(themeCubit.state, equals(ThemeMode.dark));
      expect(fakeStorageService.themeMode, equals('dark'));
    });

    testWidgets('switching between dark, light, and system updates cubit and storage', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Light
      final lightButton = find.byKey(const ValueKey('account_theme_option_light'));
      await tester.tap(lightButton);
      await tester.pumpAndSettle();

      expect(themeCubit.state, equals(ThemeMode.light));
      expect(fakeStorageService.themeMode, equals('light'));

      // Tap System
      final systemButton = find.byKey(const ValueKey('account_theme_option_system'));
      await tester.tap(systemButton);
      await tester.pumpAndSettle();

      expect(themeCubit.state, equals(ThemeMode.system));
      expect(fakeStorageService.themeMode, equals('system'));
    });
  });
}
