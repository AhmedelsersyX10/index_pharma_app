import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/presentation/widgets/product_card.dart';
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

  const testProductRx = Product(
    id: 'p01',
    name: 'Augmentin 1g Tablets',
    scientificName: 'Amoxicillin + Clavulanic Acid',
    barcode: '622147002341',
    sellingPrice: 99.0,
    stockQuantity: 12,
    looseQuantity: 0,
    requiresPrescription: true,
    category: Category(id: 'c01', name: 'Antibiotics'),
    branchId: 'b01',
  );

  const testProductOtc = Product(
    id: 'p02',
    name: 'Panadol Advance 500mg',
    scientificName: 'Paracetamol',
    barcode: '6221000000028',
    sellingPrice: 32.0,
    stockQuantity: 35,
    looseQuantity: 0,
    requiresPrescription: false,
    category: Category(id: 'c02', name: 'Pain Relief'),
    branchId: 'b01',
  );

  Widget createWidgetUnderTest(Product product,
      {Locale locale = const Locale('ar')}) {
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
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 260,
                  height: 420,
                  child: ProductCard(product: product),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  group('ProductCard Widget Tests', () {
    testWidgets('renders Rx product details and server selling price',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testProductRx));
      await tester.pumpAndSettle();

      expect(find.text('Augmentin 1g Tablets'), findsOneWidget);
      expect(find.text('Amoxicillin + Clavulanic Acid'), findsOneWidget);
      expect(find.textContaining('99.00'), findsOneWidget);
    });

    testWidgets('renders OTC product details without prescription badge',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testProductOtc));
      await tester.pumpAndSettle();

      expect(find.text('Panadol Advance 500mg'), findsOneWidget);
      expect(find.text('Paracetamol'), findsOneWidget);
      expect(find.textContaining('32.00'), findsOneWidget);
    });
  });
}
