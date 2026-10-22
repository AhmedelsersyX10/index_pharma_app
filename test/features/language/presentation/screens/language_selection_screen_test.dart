import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/language/presentation/screens/language_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final Map<String, dynamic> _arTranslations;
late final Map<String, dynamic> _enTranslations;

class _SynchronousDiskAssetLoader extends AssetLoader {
  const _SynchronousDiskAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    if (locale.languageCode == 'en') {
      return Future.value(_enTranslations);
    }
    return Future.value(_arTranslations);
  }
}

class _MockStorageService implements StorageService {
  _MockStorageService({this.locale = 'ar'});

  @override
  String? locale;

  @override
  bool onboardingSeen = false;

  @override
  String? selectedBranchId;

  int setLocaleCallCount = 0;
  String? lastSavedLocale;

  @override
  Future<bool> clearSelectedBranchId() async => true;

  @override
  Future<bool> setLocale(String targetLocale) async {
    setLocaleCallCount++;
    lastSavedLocale = targetLocale;
    locale = targetLocale;
    return true;
  }

  @override
  Future<bool> setOnboardingSeen(bool seen) async {
    onboardingSeen = seen;
    return true;
  }

  @override
  Future<bool> setSelectedBranchId(String branchId) async {
    selectedBranchId = branchId;
    return true;
  }

  @override
  String? themeMode;

  @override
  Future<bool> setThemeMode(String mode) async {
    themeMode = mode;
    return true;
  }
}

Widget _buildTestApp({
  required Widget child,
  Locale startLocale = const Locale('ar'),
}) {
  return EasyLocalization(
    key: UniqueKey(),
    supportedLocales: const [Locale('ar'), Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('ar'),
    startLocale: startLocale,
    saveLocale: false,
    useOnlyLangCode: true,
    assetLoader: const _SynchronousDiskAssetLoader(),
    child: Builder(
      builder: (context) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
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

  group('LanguageSelectionScreen Widget Tests', () {
    testWidgets('renders Arabic in RTL directionality by default',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = _MockStorageService(locale: 'ar');

      await tester.pumpWidget(
        _buildTestApp(
          startLocale: const Locale('ar'),
          child: LanguageSelectionScreen(storageService: storage),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Directionality is RTL in Arabic mode
      final textDirection = Directionality.of(
        tester.element(find.byType(LanguageSelectionScreen)),
      );
      expect(textDirection, equals(ui.TextDirection.rtl));

      // Verify Arabic Card & English Card exist
      expect(find.byKey(const ValueKey('language_card_ar')), findsOneWidget);
      expect(find.byKey(const ValueKey('language_card_en')), findsOneWidget);

      // Verify Arabic headline is rendered without English counterpart
      expect(find.text('اختر لغة التطبيق'), findsOneWidget);
      expect(find.text('Select App Language'), findsNothing);

      // Verify Submit button exists with Arabic label
      expect(find.text('متابعة بالعربية'), findsOneWidget);
    });

    testWidgets('renders English in LTR directionality when locale is English',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = _MockStorageService(locale: 'en');

      await tester.pumpWidget(
        _buildTestApp(
          startLocale: const Locale('en'),
          child: LanguageSelectionScreen(storageService: storage),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Directionality is LTR in English mode
      final textDirection = Directionality.of(
        tester.element(find.byType(LanguageSelectionScreen)),
      );
      expect(textDirection, equals(ui.TextDirection.ltr));

      // Verify English headline is rendered
      expect(find.text('Select App Language'), findsOneWidget);

      // Verify Submit button exists with English label
      expect(find.text('Continue in English'), findsOneWidget);
    });

    testWidgets('tapping English card updates selection and button label',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = _MockStorageService(locale: 'ar');

      await tester.pumpWidget(
        _buildTestApp(
          startLocale: const Locale('ar'),
          child: LanguageSelectionScreen(storageService: storage),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('متابعة بالعربية'), findsOneWidget);

      // Tap on English Card
      await tester.tap(find.byKey(const ValueKey('language_card_en')));
      await tester.pumpAndSettle();

      // Button updates to reflect candidate selection in Arabic interface
      expect(find.text('المتابعة بالإنجليزية'), findsOneWidget);

      // Tap back on Arabic Card
      await tester.tap(find.byKey(const ValueKey('language_card_ar')));
      await tester.pumpAndSettle();

      expect(find.text('متابعة بالعربية'), findsOneWidget);
    });

    testWidgets(
        'confirming selection persists choice to StorageService and navigates',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = _MockStorageService(locale: 'ar');

      final router = GoRouter(
        initialLocation: AppRouter.kLanguageSelectionView,
        routes: [
          GoRoute(
            path: AppRouter.kLanguageSelectionView,
            builder: (context, state) => LanguageSelectionScreen(
              storageService: storage,
            ),
          ),
          GoRoute(
            path: AppRouter.kOnboardingView,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding Target Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        EasyLocalization(
          key: UniqueKey(),
          supportedLocales: const [Locale('ar'), Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ar'),
          startLocale: const Locale('ar'),
          saveLocale: false,
          useOnlyLangCode: true,
          assetLoader: const _SynchronousDiskAssetLoader(),
          child: Builder(
            builder: (context) {
              return MaterialApp.router(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: AppTheme.lightTheme,
                routerConfig: router,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select English
      await tester.tap(find.byKey(const ValueKey('language_card_en')));
      await tester.pumpAndSettle();

      // Tap Submit
      await tester.tap(find.byKey(const ValueKey('language_submit_button')));
      await tester.pumpAndSettle();

      // Verify persisted to storage
      expect(storage.setLocaleCallCount, equals(1));
      expect(storage.lastSavedLocale, equals('en'));
      expect(storage.locale, equals('en'));

      // Verify routed to onboarding
      expect(find.text('Onboarding Target Screen'), findsOneWidget);
    });

    testWidgets(
        'first-run skip button defaults to ar, persists, and navigates to onboarding',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = _MockStorageService(locale: null);

      final router = GoRouter(
        initialLocation: AppRouter.kLanguageSelectionView,
        routes: [
          GoRoute(
            path: AppRouter.kLanguageSelectionView,
            builder: (context, state) => LanguageSelectionScreen(
              storageService: storage,
            ),
          ),
          GoRoute(
            path: AppRouter.kOnboardingView,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding Target Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        EasyLocalization(
          key: UniqueKey(),
          supportedLocales: const [Locale('ar'), Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ar'),
          startLocale: const Locale('ar'),
          saveLocale: false,
          useOnlyLangCode: true,
          assetLoader: const _SynchronousDiskAssetLoader(),
          child: Builder(
            builder: (context) {
              return MaterialApp.router(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: AppTheme.lightTheme,
                routerConfig: router,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('language_skip_button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('language_skip_button')));
      await tester.pumpAndSettle();

      expect(storage.setLocaleCallCount, equals(1));
      expect(storage.lastSavedLocale, equals('ar'));
      expect(find.text('Onboarding Target Screen'), findsOneWidget);
    });

    testWidgets('shows Back button when opened from account and pops on tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = _MockStorageService(locale: 'ar');

      final router = GoRouter(
        initialLocation: AppRouter.kAccountView,
        routes: [
          GoRoute(
            path: AppRouter.kAccountView,
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('open_lang_btn'),
                  onPressed: () => context.push('${AppRouter.kLanguageSelectionView}?from=account'),
                  child: const Text('Open Language'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: AppRouter.kLanguageSelectionView,
            builder: (context, state) => LanguageSelectionScreen(
              storageService: storage,
              from: state.uri.queryParameters['from'],
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        EasyLocalization(
          key: UniqueKey(),
          supportedLocales: const [Locale('ar'), Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ar'),
          startLocale: const Locale('ar'),
          saveLocale: false,
          useOnlyLangCode: true,
          assetLoader: const _SynchronousDiskAssetLoader(),
          child: Builder(
            builder: (context) {
              return MaterialApp.router(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: AppTheme.lightTheme,
                routerConfig: router,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to open Language screen from account
      await tester.tap(find.byKey(const ValueKey('open_lang_btn')));
      await tester.pumpAndSettle();

      // Back button should be present, skip button should NOT be present
      expect(find.byKey(const ValueKey('language_back_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('language_skip_button')), findsNothing);

      // Tap back button
      await tester.tap(find.byKey(const ValueKey('language_back_button')));
      await tester.pumpAndSettle();

      // Should return back to Account screen
      expect(find.byKey(const ValueKey('open_lang_btn')), findsOneWidget);
    });
  });
}
