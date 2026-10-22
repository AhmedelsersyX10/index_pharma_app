import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_state.dart';
import 'package:index_pharma/features/cart/presentation/helpers/cart_action_helper.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
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

class FakeCartRepository implements CartRepository {
  final Map<String, List<CartItem>> storage = {};
  String? activeBranchId;

  @override
  Future<List<CartItem>> getCartItems(String branchId) async {
    return storage[branchId] ?? [];
  }

  @override
  Future<void> saveCartItems(String branchId, List<CartItem> items) async {
    storage[branchId] = List<CartItem>.from(items);
    activeBranchId = branchId;
  }

  @override
  Future<void> clearCart(String branchId) async {
    storage.remove(branchId);
    if (activeBranchId == branchId) {
      activeBranchId = null;
    }
  }

  @override
  Future<String?> getActiveCartBranchId() async => activeBranchId;

  @override
  Future<void> setActiveCartBranchId(String? branchId) async {
    activeBranchId = branchId;
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

  const availableProductA = Product(
    id: 'prod-1',
    name: 'Panadol Extra',
    scientificName: 'Paracetamol',
    sellingPrice: 45.0,
    stockQuantity: 5,
    branchId: 'branch-cairo',
  );

  const outOfStockProduct = Product(
    id: 'prod-out',
    name: 'Out of Stock Med',
    sellingPrice: 20.0,
    stockQuantity: 0,
    branchId: 'branch-cairo',
  );

  const productDifferentBranch = Product(
    id: 'prod-diff',
    name: 'Alexandria Med',
    sellingPrice: 70.0,
    stockQuantity: 10,
    branchId: 'branch-alex',
  );

  Widget createTestApp({
    required Widget child,
    Locale locale = const Locale('ar'),
  }) {
    return EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      assetLoader: const SynchronousDiskAssetLoader(),
      startLocale: locale,
      saveLocale: false,
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

  group('CartActionHelper Widget Tests', () {
    late FakeCartRepository fakeRepo;
    late CartCubit cartCubit;

    setUp(() {
      fakeRepo = FakeCartRepository();
      cartCubit = CartCubit(cartRepository: fakeRepo);
    });

    tearDown(() {
      cartCubit.close();
    });

    testWidgets('success: adds item to CartCubit and displays success SnackBar',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CartActionHelper.addProductToCart(
                    context: context,
                    cartCubit: cartCubit,
                    product: availableProductA,
                    quantity: 2,
                  );
                },
                child: const Text('Add'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // State updated in CartCubit
      expect(cartCubit.state, isA<CartHasItems>());
      final state = cartCubit.state as CartHasItems;
      expect(state.totalItemsCount, equals(2));
      expect(state.items.first.product.id, equals('prod-1'));

      // Success SnackBar shown with product name
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
          AppLocaleKeys.cartItemAddedSuccess.tr(args: [availableProductA.name]),
        ),
        findsOneWidget,
      );
      expect(
        find.text(AppLocaleKeys.cartViewCartAction.tr()),
        findsOneWidget,
      );
    });

    testWidgets(
        'outOfStock: does not add item to CartCubit and displays warning SnackBar',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CartActionHelper.addProductToCart(
                    context: context,
                    cartCubit: cartCubit,
                    product: outOfStockProduct,
                  );
                },
                child: const Text('Add Out Of Stock'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Out Of Stock'));
      await tester.pumpAndSettle();

      // CartCubit remains empty
      expect(cartCubit.state, isA<CartEmpty>());

      // Out of stock warning SnackBar displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(AppLocaleKeys.productDetailsOutOfStock.tr()),
        findsOneWidget,
      );
      // View cart action is NOT on out of stock snackbar
      expect(find.text(AppLocaleKeys.cartViewCartAction.tr()), findsNothing);
    });

    testWidgets('capped quantity: displays capped notice SnackBar',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  // availableProductA only has 5 in stock; request 10
                  CartActionHelper.addProductToCart(
                    context: context,
                    cartCubit: cartCubit,
                    product: availableProductA,
                    quantity: 10,
                  );
                },
                child: const Text('Add Exceeding Stock'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Exceeding Stock'));
      await tester.pumpAndSettle();

      // Item added with clamped quantity
      expect(cartCubit.state, isA<CartHasItems>());
      final state = cartCubit.state as CartHasItems;
      expect(state.totalItemsCount, equals(5));

      // Capped SnackBar displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
          AppLocaleKeys.cartStockAlertDesc.tr(args: [availableProductA.name]),
        ),
        findsOneWidget,
      );
      expect(
        find.text(AppLocaleKeys.cartViewCartAction.tr()),
        findsOneWidget,
      );
    });

    testWidgets(
        'branchConflict cancel: shows conflict dialog, cancel leaves existing cart untouched',
        (tester) async {
      // First put an item from Cairo branch into the cart
      await cartCubit.addToCart(availableProductA, quantity: 1);
      expect((cartCubit.state as CartHasItems).branchId, equals('branch-cairo'));

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CartActionHelper.addProductToCart(
                    context: context,
                    cartCubit: cartCubit,
                    product: productDifferentBranch,
                  );
                },
                child: const Text('Add From Alex'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add From Alex'));
      await tester.pumpAndSettle();

      // AlertDialog should be displayed
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text(AppLocaleKeys.cartBranchConflictTitle.tr()),
        findsOneWidget,
      );
      expect(
        find.text(AppLocaleKeys.cartBranchConflictMessage.tr()),
        findsOneWidget,
      );

      // Tap Cancel button
      final cancelButton =
          find.text(AppLocaleKeys.cartBranchConflictCancel.tr());
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);

      // Cart is still on Cairo branch with availableProductA
      expect(cartCubit.state, isA<CartHasItems>());
      final state = cartCubit.state as CartHasItems;
      expect(state.branchId, equals('branch-cairo'));
      expect(state.items.first.product.id, equals('prod-1'));

      // No success SnackBar shown
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets(
        'branchConflict confirm: shows dialog, confirm clears previous cart and adds new product',
        (tester) async {
      // First put an item from Cairo branch into the cart
      await cartCubit.addToCart(availableProductA, quantity: 1);
      expect((cartCubit.state as CartHasItems).branchId, equals('branch-cairo'));

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CartActionHelper.addProductToCart(
                    context: context,
                    cartCubit: cartCubit,
                    product: productDifferentBranch,
                  );
                },
                child: const Text('Add From Alex'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add From Alex'));
      await tester.pumpAndSettle();

      // Tap Confirm button
      final confirmButton =
          find.text(AppLocaleKeys.cartBranchConflictConfirm.tr());
      expect(confirmButton, findsOneWidget);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);

      // Cart is now switched to Alexandria branch with productDifferentBranch
      expect(cartCubit.state, isA<CartHasItems>());
      final state = cartCubit.state as CartHasItems;
      expect(state.branchId, equals('branch-alex'));
      expect(state.items.length, equals(1));
      expect(state.items.first.product.id, equals('prod-diff'));

      // Success SnackBar is displayed for the new product
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
          AppLocaleKeys.cartItemAddedSuccess
              .tr(args: [productDifferentBranch.name]),
        ),
        findsOneWidget,
      );
    });
  });
}
