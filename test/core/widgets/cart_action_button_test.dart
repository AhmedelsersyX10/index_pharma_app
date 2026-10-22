import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/theme/app_theme.dart';
import 'package:index_pharma/core/widgets/cart_action_button.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
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

class _FakeCartRepository implements CartRepository {
  final Map<String, List<CartItem>> storage = {};
  String? activeBranchId;

  @override
  Future<List<CartItem>> getCartItems(String branchId) async =>
      storage[branchId] ?? [];

  @override
  Future<void> saveCartItems(String branchId, List<CartItem> items) async {
    storage[branchId] = List<CartItem>.from(items);
    activeBranchId = branchId;
  }

  @override
  Future<void> clearCart(String branchId) async {
    storage.remove(branchId);
    if (activeBranchId == branchId) activeBranchId = null;
  }

  @override
  Future<String?> getActiveCartBranchId() async => activeBranchId;

  @override
  Future<void> setActiveCartBranchId(String? branchId) async {
    activeBranchId = branchId;
  }
}

Widget _buildTestApp({
  required Widget child,
  CartCubit? cartCubit,
  Locale locale = const Locale('ar'),
}) {
  Widget content = child;
  if (cartCubit != null) {
    content = BlocProvider<CartCubit>.value(
      value: cartCubit,
      child: content,
    );
  }

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
          home: Scaffold(
            appBar: AppBar(
              actions: [content],
            ),
            body: const SizedBox.expand(),
          ),
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

  const sampleProduct = Product(
    id: 'prod-1',
    name: 'Panadol Extra',
    scientificName: 'Paracetamol',
    sellingPrice: 35.0,
    stockQuantity: 200,
    requiresPrescription: false,
    branchId: 'branch-1',
  );

  group('CartActionButton Widget Tests', () {
    testWidgets('renders shopping bag icon with >=48dp touch target',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const CartActionButton(),
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.byType(IconButton);
      expect(buttonFinder, findsOneWidget);

      final iconFinder = find.byIcon(Icons.shopping_bag_outlined);
      expect(iconFinder, findsOneWidget);

      final size = tester.getSize(buttonFinder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      // Badge should not be rendered when count is 0
      expect(find.text('0'), findsNothing);
    });

    testWidgets('updates badge count when items are added to CartCubit',
        (tester) async {
      final repo = _FakeCartRepository();
      final cubit = CartCubit(cartRepository: repo);

      await tester.pumpWidget(
        _buildTestApp(
          cartCubit: cubit,
          child: const CartActionButton(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsNothing);

      // Add item
      cubit.addToCart(sampleProduct, quantity: 2);
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('caps badge count at 99+ when total items exceed 99',
        (tester) async {
      final repo = _FakeCartRepository();
      final cubit = CartCubit(cartRepository: repo);

      await tester.pumpWidget(
        _buildTestApp(
          cartCubit: cubit,
          child: const CartActionButton(),
        ),
      );
      await tester.pumpAndSettle();

      cubit.addToCart(sampleProduct, quantity: 150);
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when pressed', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: CartActionButton(
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    });

    testWidgets('supports RTL and LTR directionality', (tester) async {
      final repo = _FakeCartRepository();
      final cubit = CartCubit(cartRepository: repo);
      cubit.addToCart(sampleProduct, quantity: 3);

      // RTL
      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('ar'),
          cartCubit: cubit,
          child: const CartActionButton(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);

      // LTR
      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          cartCubit: cubit,
          child: const CartActionButton(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
    });
  });
}
