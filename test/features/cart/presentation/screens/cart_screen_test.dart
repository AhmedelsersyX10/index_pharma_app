import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/screens/cart_screen.dart';
import 'package:index_pharma/features/cart/presentation/widgets/cart_bottom_bar.dart';
import 'package:index_pharma/features/cart/presentation/widgets/cart_empty_view.dart';
import 'package:index_pharma/features/cart/presentation/widgets/cart_header.dart';
import 'package:index_pharma/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:index_pharma/features/cart/presentation/widgets/cart_order_summary_card.dart';
import 'package:index_pharma/features/cart/presentation/widgets/cart_rx_reminder_card.dart';
import 'package:index_pharma/features/cart/presentation/widgets/cart_stock_alert_banner.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
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
    if (activeBranchId == branchId) activeBranchId = null;
  }

  @override
  Future<String?> getActiveCartBranchId() async => activeBranchId;

  @override
  Future<void> setActiveCartBranchId(String? branchId) async {
    activeBranchId = branchId;
  }
}

class FakeBranchCubit extends BranchCubit {
  FakeBranchCubit(BranchLoaded initialState)
    : super(
        branchRepository: _DummyBranchRepository(),
        storageService: _DummyStorageService(),
      ) {
    emit(initialState);
  }
}

class _DummyBranchRepository implements BranchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DummyStorageService implements StorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

  const testProductRx = Product(
    id: 'prod-rx-1',
    name: 'أوجمنتين ١ جم أقراص',
    scientificName: 'Amoxicillin + Clavulanic Acid',
    sellingPrice: 99.0,
    stockQuantity: 5,
    unit: 'علبة كاملة (١٤ قرص)',
    requiresPrescription: true,
    branchId: 'branch-1',
  );

  const testProductOtc = Product(
    id: 'prod-otc-2',
    name: 'بنادول إكسترا ٥٠٠ مجم',
    scientificName: 'باراسيتامول + كافيين',
    sellingPrice: 45.0,
    stockQuantity: 10,
    unit: 'شريطين (٢٤ قرص)',
    requiresPrescription: false,
    branchId: 'branch-1',
  );

  const testBranch = BranchEntity(
    id: 'branch-1',
    name: 'فرع عباس العقاد - مدينة نصر',
    address: 'شارع عباس العقاد',
  );

  Widget createTestWidget({
    required CartCubit cartCubit,
    BranchCubit? branchCubit,
    Locale locale = const Locale('ar'),
  }) {
    final effectiveBranchCubit =
        branchCubit ??
        FakeBranchCubit(
          const BranchLoaded(
            branches: [testBranch],
            selectedBranchId: 'branch-1',
          ),
        );

    return EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      assetLoader: const SynchronousDiskAssetLoader(),
      fallbackLocale: const Locale('ar'),
      startLocale: locale,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            theme: AppTheme.lightTheme,
            home: MultiBlocProvider(
              providers: [
                BlocProvider<BranchCubit>.value(value: effectiveBranchCubit),
                BlocProvider<CartCubit>.value(value: cartCubit),
              ],
              child: CartScreen(cartCubit: cartCubit),
            ),
          );
        },
      ),
    );
  }

  group('CartScreen UI Tests', () {
    testWidgets('renders CartEmptyView when cart is empty (Arabic RTL)', (
      tester,
    ) async {
      final fakeRepo = FakeCartRepository();
      final cubit = CartCubit(cartRepository: fakeRepo);

      await tester.pumpWidget(
        createTestWidget(cartCubit: cubit, locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CartHeader), findsOneWidget);
      expect(find.byType(CartEmptyView), findsOneWidget);
      expect(find.text('سلة التسوق فارغة'), findsOneWidget);
      expect(find.text('تصفح المنتجات'), findsOneWidget);
      expect(find.byType(CartBottomBar), findsNothing);
    });

    testWidgets('renders CartEmptyView in English (LTR)', (tester) async {
      final fakeRepo = FakeCartRepository();
      final cubit = CartCubit(cartRepository: fakeRepo);

      await tester.pumpWidget(
        createTestWidget(cartCubit: cubit, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Browse products'), findsOneWidget);
    });

    testWidgets(
      'renders items, summary, sticky checkout bar, and Rx reminder when cart has items',
      (tester) async {
        final fakeRepo = FakeCartRepository();
        final cubit = CartCubit(cartRepository: fakeRepo);

        await cubit.addToCart(testProductRx, quantity: 1);
        await cubit.addToCart(testProductOtc, quantity: 2);

        await tester.pumpWidget(
          createTestWidget(cartCubit: cubit, locale: const Locale('ar')),
        );
        await tester.pumpAndSettle();

        // Header and Branch Context Strip
        expect(find.byType(CartHeader), findsOneWidget);
        expect(find.text('سلة المشتريات'), findsOneWidget);
        expect(
          find.text('فرع عباس العقاد - مدينة نصر'),
          findsAtLeastNWidgets(1),
        );

        // Rx Reminder card (since Augmentin is Rx)
        expect(find.byType(CartRxReminderCard), findsOneWidget);
        expect(
          find.text('تتضمن سلّتك دواءً يحتاج تأكيد الوصفة الطبية'),
          findsOneWidget,
        );
        expect(find.text('مطلوب'), findsOneWidget);

        // Cart Item Cards (2 items)
        expect(find.byType(CartItemCard), findsNWidgets(2));
        expect(find.text('أوجمنتين ١ جم أقراص'), findsOneWidget);
        expect(find.text('بنادول إكسترا ٥٠٠ مجم'), findsOneWidget);

        // Order Summary Card
        expect(find.byType(CartOrderSummaryCard), findsOneWidget);
        expect(find.text('ملخص الفاتورة التقديرية'), findsOneWidget);
        // 99.0 + (45.0 * 2) = 189.0
        expect(find.text('189.00 ج.م'), findsOneWidget);

        // Sticky Checkout Bar
        expect(find.byType(CartBottomBar), findsOneWidget);
        expect(find.text('إتمام الطلب'), findsOneWidget);
      },
    );

    testWidgets(
      'quantity increment and decrement interaction clamps and updates state',
      (tester) async {
        final fakeRepo = FakeCartRepository();
        final cubit = CartCubit(cartRepository: fakeRepo);

        await cubit.addToCart(testProductOtc, quantity: 1); // stock is 10

        await tester.pumpWidget(
          createTestWidget(cartCubit: cubit, locale: const Locale('ar')),
        );
        await tester.pumpAndSettle();

        expect(find.text('1'), findsAtLeastNWidgets(1));

        // Tap '+' button
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pumpAndSettle();

        expect(find.text('2'), findsAtLeastNWidgets(1));

        // Tap '-' button
        await tester.tap(find.byIcon(Icons.remove).first);
        await tester.pumpAndSettle();

        expect(find.text('1'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'deleting item shows confirmation dialog and removes item upon confirm',
      (tester) async {
        final fakeRepo = FakeCartRepository();
        final cubit = CartCubit(cartRepository: fakeRepo);

        await cubit.addToCart(testProductOtc, quantity: 1);

        await tester.pumpWidget(
          createTestWidget(cartCubit: cubit, locale: const Locale('ar')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CartItemCard), findsOneWidget);

        // Tap delete button
        await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
        await tester.pumpAndSettle();

        // Verify confirmation dialog appeared
        expect(find.text('حذف الدواء'), findsOneWidget);
        expect(find.text('حذف'), findsOneWidget);

        // Confirm deletion
        await tester.tap(find.text('حذف'));
        await tester.pumpAndSettle();

        // Cart is now empty
        expect(find.byType(CartItemCard), findsNothing);
        expect(find.byType(CartEmptyView), findsOneWidget);
      },
    );

    testWidgets(
      'stock alert banner is shown when quantity was capped and can be dismissed',
      (tester) async {
        final fakeRepo = FakeCartRepository();
        final cubit = CartCubit(cartRepository: fakeRepo);

        // Request 99 when stock is 5
        await cubit.addToCart(testProductRx, quantity: 99);

        await tester.pumpWidget(
          createTestWidget(cartCubit: cubit, locale: const Locale('ar')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CartStockAlertBanner), findsOneWidget);
        expect(
          find.text('تم تعديل الكمية تلقائياً لتوفر المخزون'),
          findsOneWidget,
        );

        // Tap "حسناً، فهمت" to dismiss
        await tester.tap(find.text('حسناً، فهمت'));
        await tester.pumpAndSettle();

        expect(find.byType(CartStockAlertBanner), findsNothing);
      },
    );
  });
}
