import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_state.dart';
import 'package:index_pharma/features/products/domain/entities/products_page.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';
import 'package:index_pharma/features/products/presentation/cubit/product_details_cubit.dart';
import 'package:index_pharma/features/products/presentation/screens/product_details_screen.dart';
import 'package:index_pharma/features/products/presentation/widgets/product_details/product_details_prescription_banner.dart';
import 'package:index_pharma/features/products/presentation/widgets/product_details/product_details_skeleton.dart';
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

class FakeProductsRepository implements ProductsRepository {
  ApiResult<Product>? stubProductDetailsResult;
  Completer<ApiResult<Product>>? detailsCompleter;
  int getProductDetailsCallCount = 0;

  @override
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<Product>> getProductDetails({
    required String productId,
    required String branchId,
  }) async {
    getProductDetailsCallCount++;
    if (detailsCompleter != null) {
      return detailsCompleter!.future;
    }
    return stubProductDetailsResult!;
  }
}

class FakeCartRepository implements CartRepository {
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

  const testProductOtc = Product(
    id: 'p01',
    name: 'Hydrating Cream 50ml',
    scientificName: 'Hyaluronic Acid',
    barcode: '6221000000028',
    description: 'Daily moisturizing cream for dry and sensitive skin',
    sellingPrice: 130.0,
    stockQuantity: 10,
    requiresPrescription: false,
    unit: 'علبة',
    category: Category(id: 'c01', name: 'العناية بالبشرة'),
    branchId: 'b01',
  );

  const testProductRx = Product(
    id: 'p02',
    name: 'أوجمنتين ١ جم أقراص',
    scientificName: 'Amoxicillin + Clavulanic Acid',
    barcode: '6221147002341',
    description: 'مضاد حيوي واسع المجال لعلاج الالتهابات البكتيرية',
    sellingPrice: 99.0,
    stockQuantity: 5,
    requiresPrescription: true,
    unit: 'علبة',
    category: Category(id: 'c02', name: 'مضادات حيوية'),
    branchId: 'b01',
  );

  Widget createTestWidget({
    required ProductDetailsCubit cubit,
    CartCubit? cartCubit,
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
            home: ProductDetailsScreen(
              productId: 'p01',
              branchId: 'b01',
              cubit: cubit,
              cartCubit: cartCubit,
            ),
          );
        },
      ),
    );
  }

  group('ProductDetailsScreen Widget Tests', () {
    testWidgets('renders ProductDetailsSkeleton during loading state', (tester) async {
      final fakeRepo = FakeProductsRepository();
      final completer = Completer<ApiResult<Product>>();
      fakeRepo.detailsCompleter = completer;

      final cubit = ProductDetailsCubit(productsRepository: fakeRepo);

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pump();
      await tester.pump();
      expect(find.byType(ProductDetailsSkeleton), findsOneWidget);

      completer.complete(const Success(testProductOtc));
      await tester.pumpAndSettle();
      cubit.close();
    });

    testWidgets('renders AppErrorView and allows retry on failure', (tester) async {
      final fakeRepo = FakeProductsRepository();
      fakeRepo.stubProductDetailsResult = const Err(
        Server(serverMessage: 'خطأ في جلب بيانات الدواء'),
      );

      final cubit = ProductDetailsCubit(productsRepository: fakeRepo);

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text(AppLocaleKeys.errorServer.tr()), findsOneWidget);

      // Tap retry
      fakeRepo.stubProductDetailsResult = const Success(testProductOtc);
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsNothing);
      expect(find.text('Hydrating Cream 50ml'), findsOneWidget);

      cubit.close();
    });

    testWidgets('renders OTC product details correctly without prescription banner', (tester) async {
      final fakeRepo = FakeProductsRepository();
      fakeRepo.stubProductDetailsResult = const Success(testProductOtc);

      final cubit = ProductDetailsCubit(productsRepository: fakeRepo);

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pumpAndSettle();

      // Product identity
      expect(find.text('Hydrating Cream 50ml'), findsOneWidget);
      expect(find.text('Hyaluronic Acid'), findsOneWidget);
      expect(find.text('6221000000028'), findsOneWidget);
      expect(find.text('العناية بالبشرة'), findsWidgets);

      // Description
      expect(
        find.text('Daily moisturizing cream for dry and sensitive skin'),
        findsOneWidget,
      );

      // No Prescription banner
      expect(find.byType(ProductDetailsPrescriptionBanner), findsNothing);

      // Bottom bar price
      expect(find.text('130.00'), findsOneWidget);

      cubit.close();
    });

    testWidgets('renders Prescription banner when requiresPrescription is true', (tester) async {
      final fakeRepo = FakeProductsRepository();
      fakeRepo.stubProductDetailsResult = const Success(testProductRx);

      final cubit = ProductDetailsCubit(productsRepository: fakeRepo);

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('أوجمنتين ١ جم أقراص'), findsOneWidget);
      expect(find.byType(ProductDetailsPrescriptionBanner), findsOneWidget);
      expect(find.text('ارفع الروشتة الآن لهذا الدواء'), findsOneWidget);

      cubit.close();
    });

    testWidgets('quantity stepper updates quantity and total price in bottom bar', (tester) async {
      final fakeRepo = FakeProductsRepository();
      fakeRepo.stubProductDetailsResult = const Success(testProductOtc);

      final cubit = ProductDetailsCubit(productsRepository: fakeRepo);

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pumpAndSettle();

      // Initial quantity: 1, unitPrice: 130.00
      expect(find.text('130.00'), findsOneWidget);

      // Scroll until stepper increment button is visible
      await tester.scrollUntilVisible(find.byIcon(Icons.add_rounded), 200);
      await tester.pumpAndSettle();

      // Tap increment button
      final addIconFinder = find.byIcon(Icons.add_rounded);
      await tester.tap(addIconFinder);
      await tester.pumpAndSettle();

      // Quantity should be 2, total price: 260.00
      expect(find.text('260.00'), findsOneWidget);

      // Tap decrement button
      final removeIconFinder = find.byIcon(Icons.remove_rounded);
      await tester.tap(removeIconFinder);
      await tester.pumpAndSettle();

      // Quantity back to 1, total price: 130.00
      expect(find.text('130.00'), findsOneWidget);

      cubit.close();
    });

    testWidgets(
        'tapping add to cart with available product adds to CartCubit and shows confirmation snackbar',
        (tester) async {
      final fakeRepo = FakeProductsRepository();
      fakeRepo.stubProductDetailsResult = const Success(testProductOtc);

      final cubit = ProductDetailsCubit(productsRepository: fakeRepo);
      final fakeCartRepo = FakeCartRepository();
      final cartCubit = CartCubit(cartRepository: fakeCartRepo);

      await tester.pumpWidget(
        createTestWidget(cubit: cubit, cartCubit: cartCubit),
      );
      await tester.pumpAndSettle();

      final addToCartFinder =
          find.widgetWithText(ElevatedButton, 'أضف إلى السلة');
      expect(addToCartFinder, findsOneWidget);

      await tester.tap(addToCartFinder);
      await tester.pumpAndSettle();

      // Product really added to CartCubit
      expect(cartCubit.state, isA<CartHasItems>());
      final cartState = cartCubit.state as CartHasItems;
      expect(cartState.totalItemsCount, equals(1));
      expect(cartState.items.first.product.name, equals('Hydrating Cream 50ml'));

      // Floating snackbar should appear
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
          AppLocaleKeys.cartItemAddedSuccess
              .tr(args: ['Hydrating Cream 50ml']),
        ),
        findsOneWidget,
      );
      expect(find.text(AppLocaleKeys.cartViewCartAction.tr()), findsOneWidget);

      cartCubit.close();
      cubit.close();
    });

    testWidgets(
        'out-of-stock product disables add to cart button and displays out of stock label',
        (tester) async {
      const outOfStockProduct = Product(
        id: 'p03',
        name: 'Out of Stock Serum',
        sellingPrice: 50.0,
        stockQuantity: 0,
        branchId: 'b01',
      );
      final fakeRepo = FakeProductsRepository();
      fakeRepo.stubProductDetailsResult = const Success(outOfStockProduct);

      final cubit = ProductDetailsCubit(productsRepository: fakeRepo);
      final fakeCartRepo = FakeCartRepository();
      final cartCubit = CartCubit(cartRepository: fakeCartRepo);

      await tester.pumpWidget(
        createTestWidget(cubit: cubit, cartCubit: cartCubit),
      );
      await tester.pumpAndSettle();

      // Button has out-of-stock label and is disabled
      final buttonFinder = find.widgetWithText(
        ElevatedButton,
        AppLocaleKeys.productDetailsOutOfStock.tr(),
      );
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull);

      // CartCubit remains empty
      expect(cartCubit.state, isA<CartEmpty>());

      cartCubit.close();
      cubit.close();
    });

    testWidgets(
        'branch conflict on product details screen shows dialog and switches branch on confirm',
        (tester) async {
      final fakeRepo = FakeProductsRepository();
      fakeRepo.stubProductDetailsResult = const Success(testProductOtc);

      final cubit = ProductDetailsCubit(productsRepository: fakeRepo);
      final fakeCartRepo = FakeCartRepository();
      final cartCubit = CartCubit(cartRepository: fakeCartRepo);

      // Seed cart with an item from another branch ('different-branch')
      const existingProduct = Product(
        id: 'p99',
        name: 'Existing Med',
        sellingPrice: 80.0,
        stockQuantity: 5,
        branchId: 'different-branch',
      );
      await cartCubit.addToCart(existingProduct, quantity: 1);
      expect((cartCubit.state as CartHasItems).branchId, equals('different-branch'));

      await tester.pumpWidget(
        createTestWidget(cubit: cubit, cartCubit: cartCubit),
      );
      await tester.pumpAndSettle();

      final addToCartFinder =
          find.widgetWithText(ElevatedButton, 'أضف إلى السلة');
      expect(addToCartFinder, findsOneWidget);

      await tester.tap(addToCartFinder);
      await tester.pumpAndSettle();

      // Dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text(AppLocaleKeys.cartBranchConflictTitle.tr()),
        findsOneWidget,
      );

      // Tap confirm button
      final confirmBtn =
          find.text(AppLocaleKeys.cartBranchConflictConfirm.tr());
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Cart now has testProductOtc from b01
      expect(cartCubit.state, isA<CartHasItems>());
      final cartState = cartCubit.state as CartHasItems;
      expect(cartState.branchId, equals('b01'));
      expect(cartState.items.first.product.id, equals('p01'));

      // Success SnackBar is displayed
      expect(find.byType(SnackBar), findsOneWidget);

      cartCubit.close();
      cubit.close();
    });
  });
}
