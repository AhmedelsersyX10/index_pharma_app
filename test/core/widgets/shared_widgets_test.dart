import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final Map<String, dynamic> _arTranslations;
late final Map<String, dynamic> _enTranslations;

class _TestDiskAssetLoader extends AssetLoader {
  const _TestDiskAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    if (locale.languageCode == 'en') {
      return Future.value(_enTranslations);
    }
    return Future.value(_arTranslations);
  }
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
    assetLoader: const _TestDiskAssetLoader(),
    child: Builder(
      builder: (context) {
        return MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: AppTheme.lightTheme,
          home: Scaffold(body: child),
        );
      },
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    _arTranslations = json.decode(File('assets/translations/ar.json').readAsStringSync()) as Map<String, dynamic>;
    _enTranslations = json.decode(File('assets/translations/en.json').readAsStringSync()) as Map<String, dynamic>;
    await EasyLocalization.ensureInitialized();
  });

  group('AppLoadingIndicator', () {
    testWidgets('renders circular progress indicator with default styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingIndicator(),
          ),
        ),
      );

      final progressFinder = find.byType(CircularProgressIndicator);
      expect(progressFinder, findsOneWidget);

      final progress = tester.widget<CircularProgressIndicator>(progressFinder);
      expect(progress.strokeWidth, 3.0);
      expect(
        (progress.valueColor as AlwaysStoppedAnimation<Color>).value,
        AppColors.primaryBrand,
      );
    });

    testWidgets('renders custom message and respects custom color and size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingIndicator(
              size: 48.0,
              strokeWidth: 4.0,
              color: AppColors.brandEmeraldDark,
              message: 'Loading medication catalogue...',
            ),
          ),
        ),
      );

      expect(find.text('Loading medication catalogue...'), findsOneWidget);

      final progress = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(progress.strokeWidth, 4.0);
      expect(
        (progress.valueColor as AlwaysStoppedAnimation<Color>).value,
        AppColors.brandEmeraldDark,
      );
    });

    testWidgets('renders correctly in Arabic (RTL) and English (LTR)', (tester) async {
      // English (LTR)
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('en'),
          child: const AppLoadingIndicator(message: 'Loading...'),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.ltr);
      expect(find.text('Loading...'), findsOneWidget);

      // Arabic (RTL)
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: const AppLoadingIndicator(message: 'جاري التحميل...'),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.rtl);
      expect(find.text('جاري التحميل...'), findsOneWidget);
    });
  });

  group('AppErrorView', () {
    testWidgets('renders default localized error view in English (LTR)', (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('en'),
          child: const AppErrorView(),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.ltr);
      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.text('An unexpected error occurred. Please try again.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('renders default localized error view in Arabic (RTL)', (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: const AppErrorView(),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.rtl);
      expect(find.text('حدث خطأ ما'), findsOneWidget);
      expect(find.text('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders retry button and triggers callback when tapped', (tester) async {
      var retryTapped = false;

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('en'),
          child: AppErrorView(
            onRetry: () => retryTapped = true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryTapped, isTrue);
    });

    testWidgets('renders custom title, message, icon, and retry text in Arabic (RTL)', (tester) async {
      var customRetryTapped = false;

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: AppErrorView(
            title: 'لا يوجد اتصال بالإنترنت',
            message: 'تأكد من اتصالك بالشبكة وحاول مجدداً',
            retryText: 'حاول مجدداً',
            icon: const Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.error),
            onRetry: () => customRetryTapped = true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.rtl);
      expect(find.text('لا يوجد اتصال بالإنترنت'), findsOneWidget);
      expect(find.text('تأكد من اتصالك بالشبكة وحاول مجدداً'), findsOneWidget);
      expect(find.text('حاول مجدداً'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      await tester.tap(find.text('حاول مجدداً'));
      await tester.pump();

      expect(customRetryTapped, isTrue);
    });
  });

  group('AppEmptyState', () {
    testWidgets('renders default localized empty state in English (LTR)', (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('en'),
          child: const AppEmptyState(),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.ltr);
      expect(find.text('No Items Found'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('renders default localized empty state in Arabic (RTL)', (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: const AppEmptyState(),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.rtl);
      expect(find.text('لا توجد عناصر'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('renders custom title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'سلة المشتريات فارغة',
              message: 'أضف بعض المنتجات لبدء التسوق',
            ),
          ),
        ),
      );

      expect(find.text('سلة المشتريات فارغة'), findsOneWidget);
      expect(find.text('أضف بعض المنتجات لبدء التسوق'), findsOneWidget);
    });

    testWidgets('renders optional action widget and handles interaction', (tester) async {
      var actionTapped = false;

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: AppEmptyState(
            title: 'لا توجد أدوية مفضلة',
            message: 'يمكنك إضافة الأدوية إلى المفضلة للرجوع إليها لاحقاً',
            action: AppButton.primary(
              text: 'تصفح الأدوية',
              isFullWidth: false,
              onPressed: () => actionTapped = true,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('لا توجد أدوية مفضلة'), findsOneWidget);
      expect(find.text('يمكنك إضافة الأدوية إلى المفضلة للرجوع إليها لاحقاً'), findsOneWidget);
      expect(find.text('تصفح الأدوية'), findsOneWidget);

      await tester.tap(find.text('تصفح الأدوية'));
      await tester.pump();

      expect(actionTapped, isTrue);
    });
  });
}
