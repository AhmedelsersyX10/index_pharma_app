import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/onboarding/data/models/onboarding_model.dart';
import 'package:index_pharma/features/onboarding/presentation/widgets/onboarding_bottom_section.dart';
import 'package:index_pharma/features/onboarding/presentation/widgets/onboarding_page_item.dart';
import 'package:index_pharma/features/onboarding/presentation/widgets/onboarding_top_bar.dart';
import 'package:index_pharma/features/splash/presentation/widgets/splash_brand_text.dart';
import 'package:index_pharma/features/splash/presentation/widgets/splash_footer.dart';
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

  group('EasyLocalization & RTL/LTR Tests', () {
    testWidgets('Arabic Locale (ar) sets RTL directionality and renders Arabic strings',
        (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: Column(
            children: [
              SplashBrandText(
                textFade: const AlwaysStoppedAnimation(1.0),
                textSlide: const AlwaysStoppedAnimation(0.0),
              ),
              SplashFooter(
                footerFade: const AlwaysStoppedAnimation(1.0),
              ),
              OnboardingTopBar(
                currentPage: 0,
                totalPages: 3,
                onSkip: () {},
              ),
              OnboardingBottomSection(
                currentPage: 0,
                totalPages: 3,
                onNext: () {},
                onPrevious: () {},
                onDone: () {},
                onSignIn: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // App text direction inside MaterialApp must be RTL for Arabic
      final scaffoldElement = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(scaffoldElement), TextDirection.rtl);

      // Splash Arabic strings rendered
      expect(find.text('وضوح ورعاية'), findsOneWidget);
      expect(find.text('منصة رعاية صحية معتمدة'), findsOneWidget);

      // Onboarding Arabic strings rendered
      expect(find.text('تخطي'), findsOneWidget);
      expect(find.text('الخطوة 1 من 3'), findsOneWidget);
      expect(find.text('ابدأ الآن'), findsOneWidget);

      // Splash brand Latin logo row is kept LTR
      final ltrFinder = find.byWidgetPredicate(
        (widget) => widget is Directionality && widget.textDirection == TextDirection.ltr,
      );
      expect(ltrFinder, findsWidgets);

      // In RTL, the navigation forward arrow in OnboardingBottomSection is flipped (scaleX == -1)
      final arrowFinder = find.byIcon(Icons.arrow_forward_rounded);
      final transformWidget = tester.widget<Transform>(
        find.ancestor(of: arrowFinder, matching: find.byType(Transform)).first,
      );
      expect(transformWidget.transform.storage[0], -1.0);
    });

    testWidgets('English Locale (en) sets LTR directionality and renders English strings',
        (tester) async {
      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('en'),
          child: Column(
            children: [
              SplashBrandText(
                textFade: const AlwaysStoppedAnimation(1.0),
                textSlide: const AlwaysStoppedAnimation(0.0),
              ),
              SplashFooter(
                footerFade: const AlwaysStoppedAnimation(1.0),
              ),
              OnboardingTopBar(
                currentPage: 0,
                totalPages: 3,
                onSkip: () {},
              ),
              OnboardingBottomSection(
                currentPage: 0,
                totalPages: 3,
                onNext: () {},
                onPrevious: () {},
                onDone: () {},
                onSignIn: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // App text direction inside MaterialApp must be LTR for English
      final scaffoldElement = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(scaffoldElement), TextDirection.ltr);

      // Splash English strings rendered
      expect(find.text('Clinical Clarity & Care'), findsOneWidget);
      expect(find.text('Certified Healthcare Platform'), findsOneWidget);

      // Onboarding English strings rendered
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // In LTR, the navigation forward arrow in OnboardingBottomSection is not flipped (scaleX == 1)
      final arrowFinder = find.byIcon(Icons.arrow_forward_rounded);
      final transformWidget = tester.widget<Transform>(
        find.ancestor(of: arrowFinder, matching: find.byType(Transform)).first,
      );
      expect(transformWidget.transform.storage[0], 1.0);
    });

    testWidgets('OnboardingPageItem renders correct translations in Arabic',
        (tester) async {
      final page1 = OnboardingModel.defaultPages[0];

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('ar'),
          child: OnboardingPageItem(model: page1),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('رعاية صحية موثقة'), findsOneWidget);
      expect(find.text('صيدليتك المتكاملة،\nفي أي وقت وأي مكان'), findsOneWidget);
      expect(find.text('✓ +10,000 منتج أصلي  •  ✓ دعم صيدلي مرخص'), findsOneWidget);
    });

    testWidgets('OnboardingPageItem renders correct translations in English',
        (tester) async {
      final page1 = OnboardingModel.defaultPages[0];

      await tester.pumpWidget(
        createTestLocalizedApp(
          locale: const Locale('en'),
          child: OnboardingPageItem(model: page1),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Verified Healthcare'), findsOneWidget);
      expect(find.text('Your Pharmacy,\nAnytime & Anywhere'), findsOneWidget);
      expect(find.text('✓ 10,000+ Genuine Products  •  ✓ Licensed Support'), findsOneWidget);
    });

    testWidgets('Dynamic locale switching updates text and Directionality',
        (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        EasyLocalization(
          key: const ValueKey('EasyLocalization_dynamic'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ar'),
          startLocale: const Locale('ar'),
          saveLocale: false,
          useOnlyLangCode: true,
          assetLoader: const SynchronousDiskAssetLoader(),
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return MaterialApp(
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                home: Scaffold(
                  body: Builder(
                    builder: (scaffoldContext) {
                      return Text(scaffoldContext.tr(AppLocaleKeys.onboardingGetStarted));
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('ابدأ الآن'), findsOneWidget);
      final scaffoldElementAr = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(scaffoldElementAr), TextDirection.rtl);

      // Switch to English
      await EasyLocalization.of(capturedContext)!.setLocale(const Locale('en'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Get Started'), findsOneWidget);
      final scaffoldElementEn = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(scaffoldElementEn), TextDirection.ltr);
    });
  });
}
