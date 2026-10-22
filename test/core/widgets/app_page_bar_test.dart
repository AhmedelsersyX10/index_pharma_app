import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/theme/app_colors.dart';
import 'package:index_pharma/core/theme/app_theme.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
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

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('ar'),
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
          home: child,
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

  group('AppPageBar Widget Tests', () {
    testWidgets('renders single-line centered title with theme typography',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const Scaffold(
            appBar: AppPageBar(
              title: 'عنوان تجريبي',
              showBackButton: false,
            ),
            body: SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final titleFinder = find.text('عنوان تجريبي');
      expect(titleFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.maxLines, equals(1));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
      expect(appBar.elevation, equals(0));
      expect(appBar.scrolledUnderElevation, equals(0));
    });

    testWidgets('mirrors back button automatically to arrow_forward in Arabic (RTL)',
        (tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('ar'),
          child: Scaffold(
            appBar: AppPageBar(
              title: 'اختبار الرجوع',
              showBackButton: true,
              onBackPressed: () => backPressed = true,
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final iconFinder = find.byIcon(Icons.arrow_forward_rounded);
      expect(iconFinder, findsOneWidget);

      final buttonFinder = find.byType(IconButton);
      expect(buttonFinder, findsOneWidget);

      // Verify touch target >= 48dp
      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.width, greaterThanOrEqualTo(48.0));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));

      await tester.tap(buttonFinder);
      expect(backPressed, isTrue);
    });

    testWidgets('mirrors back button automatically to arrow_back in English (LTR)',
        (tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: Scaffold(
            appBar: AppPageBar(
              title: 'Back Test',
              showBackButton: true,
              onBackPressed: () => backPressed = true,
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final iconFinder = find.byIcon(Icons.arrow_back_rounded);
      expect(iconFinder, findsOneWidget);

      await tester.tap(find.byType(IconButton));
      expect(backPressed, isTrue);
    });

    testWidgets('AppPageBar.transparent renders transparent background without divider',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const Scaffold(
            appBar: AppPageBar.transparent(
              title: 'شفاف',
              showBackButton: false,
            ),
            body: SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(Colors.transparent));
      expect(appBar.shape, isNull);
    });

    testWidgets('AppPageBar.noBack suppresses back button',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const Scaffold(
            appBar: AppPageBar.noBack(
              title: 'الرئيسية',
            ),
            body: SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('renders custom actions slot', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: Scaffold(
            appBar: AppPageBar(
              title: 'مع أزرار',
              showBackButton: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => actionTapped = true,
                ),
              ],
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final shareFinder = find.byIcon(Icons.share);
      expect(shareFinder, findsOneWidget);

      await tester.tap(shareFinder);
      expect(actionTapped, isTrue);
    });

    testWidgets('standard AppPageBar renders thin bottom divider border',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const Scaffold(
            appBar: AppPageBar(
              title: 'مع خط سفلي',
              showBackButton: false,
            ),
            body: SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.shape, isA<Border>());
      final border = appBar.shape as Border;
      expect(border.bottom.width, equals(1.0));
      expect(border.bottom.color, equals(AppColors.borderSubtle));
    });
  });
}
