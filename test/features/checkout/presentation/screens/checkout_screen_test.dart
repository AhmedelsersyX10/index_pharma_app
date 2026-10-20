import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/checkout/data/models/order_request_model.dart';
import 'package:index_pharma/features/checkout/domain/entities/order.dart';
import 'package:index_pharma/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:index_pharma/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:index_pharma/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:index_pharma/features/checkout/presentation/widgets/checkout_address_card.dart';
import 'package:index_pharma/features/checkout/presentation/widgets/checkout_notes_card.dart';
import 'package:index_pharma/features/checkout/presentation/widgets/checkout_payment_card.dart';
import 'package:index_pharma/features/checkout/presentation/widgets/checkout_phone_card.dart';
import 'package:index_pharma/features/checkout/presentation/widgets/checkout_summary_card.dart';
import 'package:index_pharma/features/checkout/presentation/widgets/stock_conflict_banner.dart';
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

class FakeCheckoutRepository implements CheckoutRepository {
  ApiResult<Order>? resultToReturn;

  @override
  Future<ApiResult<Order>> createOrder(OrderRequestModel request) async {
    return resultToReturn!;
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final arFile = File('assets/translations/ar.json');
    final enFile = File('assets/translations/en.json');
    _arTranslations =
        jsonDecode(await arFile.readAsString()) as Map<String, dynamic>;
    _enTranslations =
        jsonDecode(await enFile.readAsString()) as Map<String, dynamic>;

    await EasyLocalization.ensureInitialized();
  });

  const testProduct = Product(
    id: 'prod-1',
    name: 'بانادول اكسترا أقراص',
    sellingPrice: 45.0,
    stockQuantity: 20,
    branchId: 'b-1',
  );

  Widget createWidgetUnderTest({
    required CartCubit cartCubit,
    required CheckoutCubit checkoutCubit,
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
            home: MultiBlocProvider(
              providers: [
                BlocProvider<CartCubit>.value(value: cartCubit),
              ],
              child: CheckoutScreen(checkoutCubit: checkoutCubit),
            ),
          );
        },
      ),
    );
  }

  testWidgets('renders all C2 sections: address, phone, notes, payment, and summary',
      (tester) async {
    final fakeCartRepo = FakeCartRepository();
    final fakeCheckoutRepo = FakeCheckoutRepository();
    final cartCubit = CartCubit(cartRepository: fakeCartRepo);
    await cartCubit.addToCart(testProduct, quantity: 2);

    final checkoutCubit = CheckoutCubit(
      checkoutRepository: fakeCheckoutRepo,
      cartCubit: cartCubit,
      initialAddress: 'Nasr City, Building 4',
      initialPhone: '01012345678',
    );

    await tester.pumpWidget(createWidgetUnderTest(
      cartCubit: cartCubit,
      checkoutCubit: checkoutCubit,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutAddressCard), findsOneWidget);
    expect(find.byType(CheckoutPhoneCard), findsOneWidget);
    expect(find.byType(CheckoutNotesCard), findsOneWidget);
    expect(find.byType(CheckoutPaymentCard), findsOneWidget);
    expect(find.byType(CheckoutSummaryCard), findsOneWidget);
    expect(find.byKey(const Key('btn_confirm_order')), findsOneWidget);

    cartCubit.close();
    checkoutCubit.close();
  });

  testWidgets('shows validation errors when address or phone are invalid',
      (tester) async {
    final fakeCartRepo = FakeCartRepository();
    final fakeCheckoutRepo = FakeCheckoutRepository();
    final cartCubit = CartCubit(cartRepository: fakeCartRepo);
    await cartCubit.addToCart(testProduct, quantity: 1);

    final checkoutCubit = CheckoutCubit(
      checkoutRepository: fakeCheckoutRepo,
      cartCubit: cartCubit,
      initialAddress: '',
      initialPhone: '',
    );

    await tester.pumpWidget(createWidgetUnderTest(
      cartCubit: cartCubit,
      checkoutCubit: checkoutCubit,
    ));
    await tester.pumpAndSettle();

    // Tap confirm order with empty fields
    await tester.tap(find.byKey(const Key('btn_confirm_order')));
    await tester.pumpAndSettle();

    // Validation error text displayed
    expect(find.text('يرجى إدخال عنوان التسليم بالتفصيل.'), findsOneWidget);
    expect(find.text('رقم الهاتف مطلوب للتواصل.'), findsOneWidget);

    cartCubit.close();
    checkoutCubit.close();
  });

  testWidgets('displays StockConflictBanner when HTTP 409 conflict occurs',
      (tester) async {
    final fakeCartRepo = FakeCartRepository();
    final fakeCheckoutRepo = FakeCheckoutRepository();
    final cartCubit = CartCubit(cartRepository: fakeCartRepo);
    await cartCubit.addToCart(testProduct, quantity: 1);

    final checkoutCubit = CheckoutCubit(
      checkoutRepository: fakeCheckoutRepo,
      cartCubit: cartCubit,
      initialAddress: 'Nasr City, Building 4',
      initialPhone: '01012345678',
    );

    fakeCheckoutRepo.resultToReturn = const Err(
      Conflict(serverMessage: 'الكمية المتاحة من بانادول اكسترا هي 0 فقط'),
    );

    await tester.pumpWidget(createWidgetUnderTest(
      cartCubit: cartCubit,
      checkoutCubit: checkoutCubit,
    ));
    await tester.pumpAndSettle();

    // Tap confirm button
    await tester.tap(find.byKey(const Key('btn_confirm_order')));
    await tester.pumpAndSettle();

    expect(find.byType(StockConflictBanner), findsOneWidget);
    expect(find.text('الكمية المتاحة من بانادول اكسترا هي 0 فقط'), findsOneWidget);

    cartCubit.close();
    checkoutCubit.close();
  });

  testWidgets(
      'renders safely without ancestor BlocProvider<CartCubit> when passed cartCubit',
      (tester) async {
    final fakeCartRepo = FakeCartRepository();
    final fakeCheckoutRepo = FakeCheckoutRepository();
    final cartCubit = CartCubit(cartRepository: fakeCartRepo);
    await cartCubit.addToCart(testProduct, quantity: 1);

    final checkoutCubit = CheckoutCubit(
      checkoutRepository: fakeCheckoutRepo,
      cartCubit: cartCubit,
      initialAddress: 'Nasr City, Building 4',
      initialPhone: '01012345678',
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        assetLoader: const SynchronousDiskAssetLoader(),
        startLocale: const Locale('ar'),
        saveLocale: false,
        child: Builder(
          builder: (context) {
            return MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: CheckoutScreen(
                checkoutCubit: checkoutCubit,
                cartCubit: cartCubit,
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutScreen), findsOneWidget);
    expect(find.byType(CheckoutSummaryCard), findsOneWidget);

    cartCubit.close();
    checkoutCubit.close();
  });
}
