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

  group('AppBadge', () {
    testWidgets('renders all 5 WCAG AAA status tones with correct tokens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppBadge.warning(label: 'قيد الانتظار'),
                AppBadge.info(label: 'جاري التحضير'),
                AppBadge.purple(label: 'تم التجهيز'),
                AppBadge.success(label: 'تم التوصيل'),
                AppBadge.error(label: 'ملغي'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('قيد الانتظار'), findsOneWidget);
      expect(find.text('جاري التحضير'), findsOneWidget);
      expect(find.text('تم التجهيز'), findsOneWidget);
      expect(find.text('تم التوصيل'), findsOneWidget);
      expect(find.text('ملغي'), findsOneWidget);

      final warningContainer = tester.widget<Container>(find.ancestor(
        of: find.text('قيد الانتظار'),
        matching: find.byType(Container),
      ));
      expect((warningContainer.decoration as BoxDecoration).color, AppColors.badgeWarningBg);

      final infoContainer = tester.widget<Container>(find.ancestor(
        of: find.text('جاري التحضير'),
        matching: find.byType(Container),
      ));
      expect((infoContainer.decoration as BoxDecoration).color, AppColors.badgeInfoBg);

      final purpleContainer = tester.widget<Container>(find.ancestor(
        of: find.text('تم التجهيز'),
        matching: find.byType(Container),
      ));
      expect((purpleContainer.decoration as BoxDecoration).color, AppColors.badgePurpleBg);

      final successContainer = tester.widget<Container>(find.ancestor(
        of: find.text('تم التوصيل'),
        matching: find.byType(Container),
      ));
      expect((successContainer.decoration as BoxDecoration).color, AppColors.badgeSuccessBg);

      final errorContainer = tester.widget<Container>(find.ancestor(
        of: find.text('ملغي'),
        matching: find.byType(Container),
      ));
      expect((errorContainer.decoration as BoxDecoration).color, AppColors.badgeErrorBg);
    });

    testWidgets('renders trust, offer, urgent and neutral badges', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppBadge.trust(label: '100% أصلي'),
                AppBadge.neutral(label: '500 ملجم'),
                AppBadge.offer(label: 'خصم'),
                AppBadge.urgent(label: 'روشتة مطلوبة'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('100% أصلي'), findsOneWidget);
      expect(find.text('500 ملجم'), findsOneWidget);
      expect(find.text('خصم'), findsOneWidget);
      expect(find.text('روشتة مطلوبة'), findsOneWidget);
    });

    testWidgets('renders icon and responds to RTL and LTR directionality', (tester) async {
      // English LTR
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('en'),
          child: const AppBadge.info(
            label: 'Processing',
            icon: Icon(Icons.sync_rounded),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.ltr);
      expect(find.text('Processing'), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);

      // Arabic RTL
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: const AppBadge.info(
            label: 'جاري التحضير',
            icon: Icon(Icons.sync_rounded),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.rtl);
      expect(find.text('جاري التحضير'), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    });
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

    testWidgets('renders dedicated offline state in Arabic (RTL)', (tester) async {
      var retryTapped = false;

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: AppErrorView.offline(
            errorCode: 'ERR_TIMEOUT_503',
            onRetry: () => retryTapped = true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.rtl);
      expect(find.text('انقطع الاتصال بالشبكة'), findsOneWidget);
      expect(find.text('تعذر الاتصال بالخادم بسبب انقطاع الإنترنت. تم حفظ العمليات في الذاكرة المحلية.'), findsOneWidget);
      expect(find.text('غير متصل'), findsOneWidget);
      expect(find.text('بياناتك في أمان'), findsOneWidget);
      expect(find.text('ERR_TIMEOUT_503'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pump();

      expect(retryTapped, isTrue);
    });

    testWidgets('renders dedicated offline state in English (LTR)', (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('en'),
          child: const AppErrorView.offline(),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.ltr);
      expect(find.text('Network Connection Lost'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('Your Data is Safe'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('renders custom secondary action in error view', (tester) async {
      var secondaryTapped = false;

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: AppErrorView(
            title: 'خطأ مخصص',
            message: 'رسالة مخصصة',
            secondaryAction: AppButton.outlined(
              text: 'العودة للرئيسية',
              onPressed: () => secondaryTapped = true,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('خطأ مخصص'), findsOneWidget);
      expect(find.text('العودة للرئيسية'), findsOneWidget);

      await tester.tap(find.text('العودة للرئيسية'));
      await tester.pump();

      expect(secondaryTapped, isTrue);
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

    testWidgets('renders custom title, message, badge, and reassurance widget', (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: const AppEmptyState(
            badge: AppBadge.trust(label: 'طابور التجهيز مكتمل 100%'),
            title: 'صندوق الطلبات فارغ حالياً',
            message: 'تمت معالجة جميع الطلبات بنجاح',
            reassuranceWidget: Text('النظام متزامن ومستعد'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('طابور التجهيز مكتمل 100%'), findsOneWidget);
      expect(find.text('صندوق الطلبات فارغ حالياً'), findsOneWidget);
      expect(find.text('تمت معالجة جميع الطلبات بنجاح'), findsOneWidget);
      expect(find.text('النظام متزامن ومستعد'), findsOneWidget);
    });

    testWidgets('renders both primary and secondary actions and handles interaction', (tester) async {
      var primaryTapped = false;
      var secondaryTapped = false;

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: AppEmptyState(
            title: 'لا توجد أدوية',
            message: 'تصفح قائمة الأدوية أو حدث القائمة',
            action: AppButton.primary(
              text: 'تحديث القائمة',
              isFullWidth: false,
              onPressed: () => primaryTapped = true,
            ),
            secondaryAction: AppButton.outlined(
              text: 'تصفح الأدوية',
              isFullWidth: false,
              onPressed: () => secondaryTapped = true,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('تحديث القائمة'), findsOneWidget);
      expect(find.text('تصفح الأدوية'), findsOneWidget);

      await tester.tap(find.text('تحديث القائمة'));
      await tester.pump();
      expect(primaryTapped, isTrue);

      await tester.tap(find.text('تصفح الأدوية'));
      await tester.pump();
      expect(secondaryTapped, isTrue);
    });
  });
}
