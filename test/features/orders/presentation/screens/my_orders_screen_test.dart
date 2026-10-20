import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/widgets/app_empty_state.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/core/widgets/app_loading_indicator.dart';
import 'package:index_pharma/features/orders/domain/entities/customer_order.dart';
import 'package:index_pharma/features/orders/domain/entities/customer_order_item.dart';
import 'package:index_pharma/features/orders/domain/entities/my_orders_page.dart';
import 'package:index_pharma/features/orders/domain/repositories/orders_repository.dart';
import 'package:index_pharma/features/orders/domain/usecases/get_my_orders_use_case.dart';
import 'package:index_pharma/features/orders/presentation/cubit/my_orders_cubit.dart';
import 'package:index_pharma/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:index_pharma/features/orders/presentation/widgets/order_card.dart';
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

class FakeOrdersRepository implements OrdersRepository {
  ApiResult<MyOrdersPage>? resultToReturn;

  @override
  Future<ApiResult<MyOrdersPage>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
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

  Widget buildTestableWidget(Widget child, {Locale locale = const Locale('ar')}) {
    return EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: locale,
      assetLoader: const SynchronousDiskAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: child,
          );
        },
      ),
    );
  }

  final testOrder = CustomerOrder(
    id: 'ord-101',
    orderNumber: 'ONL-20261018-001',
    subtotal: 170.0,
    totalAmount: 170.0,
    orderType: 'ONLINE',
    status: 'pending',
    paymentMethod: 'cash',
    deliveryAddress: 'Nasr City, Building 4',
    customerPhone: '01012345678',
    createdAt: DateTime(2026, 10, 18, 12, 30),
    items: const [
      CustomerOrderItem(
        id: 'it-1',
        productId: 'p-1',
        productName: 'Vitamin C 1000mg',
        quantity: 2,
        priceAtPurchase: 85,
      ),
    ],
  );

  testWidgets('renders AppLoadingIndicator while orders are loading',
      (tester) async {
    final fakeRepo = FakeOrdersRepository();
    final useCase = GetMyOrdersUseCase(repository: fakeRepo);
    final cubit = MyOrdersCubit(getMyOrdersUseCase: useCase);

    await tester.pumpWidget(buildTestableWidget(MyOrdersScreen(cubit: cubit)));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });

  testWidgets('renders AppEmptyState when customer has no orders',
      (tester) async {
    final fakeRepo = FakeOrdersRepository();
    fakeRepo.resultToReturn = const Success(
      MyOrdersPage(orders: [], total: 0, page: 1, limit: 20, totalPages: 0),
    );
    final useCase = GetMyOrdersUseCase(repository: fakeRepo);
    final cubit = MyOrdersCubit(getMyOrdersUseCase: useCase);
    await cubit.fetchMyOrders();

    await tester.pumpWidget(buildTestableWidget(MyOrdersScreen(cubit: cubit)));
    await tester.pumpAndSettle();

    expect(find.byType(AppEmptyState), findsOneWidget);
  });

  testWidgets('renders AppErrorView when fetch fails and allows retry',
      (tester) async {
    final fakeRepo = FakeOrdersRepository();
    fakeRepo.resultToReturn = const Err(
      Network(serverMessage: 'انقطع الاتصال'),
    );
    final useCase = GetMyOrdersUseCase(repository: fakeRepo);
    final cubit = MyOrdersCubit(getMyOrdersUseCase: useCase);
    await cubit.fetchMyOrders();

    await tester.pumpWidget(buildTestableWidget(MyOrdersScreen(cubit: cubit)));
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsOneWidget);
  });

  testWidgets('renders OrderCard list and filter chips on success',
      (tester) async {
    final fakeRepo = FakeOrdersRepository();
    fakeRepo.resultToReturn = Success(
      MyOrdersPage(orders: [testOrder], total: 1, page: 1, limit: 20, totalPages: 1),
    );
    final useCase = GetMyOrdersUseCase(repository: fakeRepo);
    final cubit = MyOrdersCubit(getMyOrdersUseCase: useCase);
    await cubit.fetchMyOrders();

    await tester.pumpWidget(buildTestableWidget(MyOrdersScreen(cubit: cubit)));
    await tester.pumpAndSettle();

    expect(find.byType(OrderCard), findsOneWidget);
    expect(find.text('ONL-20261018-001'), findsOneWidget);
    expect(find.text('Vitamin C 1000mg'), findsOneWidget);
  });

  testWidgets('switching filter tab updates displayed orders', (tester) async {
    final deliveredOrder = CustomerOrder(
      id: 'ord-102',
      orderNumber: 'ONL-20261018-002',
      subtotal: 50.0,
      totalAmount: 50.0,
      orderType: 'ONLINE',
      status: 'delivered',
      paymentMethod: 'cash',
      deliveryAddress: 'Maadi',
      customerPhone: '01012345678',
      createdAt: DateTime(2026, 10, 18, 14, 0),
      items: const [],
    );

    final fakeRepo = FakeOrdersRepository();
    fakeRepo.resultToReturn = Success(
      MyOrdersPage(
        orders: [testOrder, deliveredOrder],
        total: 2,
        page: 1,
        limit: 20,
        totalPages: 1,
      ),
    );
    final useCase = GetMyOrdersUseCase(repository: fakeRepo);
    final cubit = MyOrdersCubit(getMyOrdersUseCase: useCase);
    await cubit.fetchMyOrders();

    await tester.pumpWidget(buildTestableWidget(MyOrdersScreen(cubit: cubit)));
    await tester.pumpAndSettle();

    expect(find.byType(OrderCard), findsNWidgets(2));

    // Tap "الحالية" (Active)
    await tester.tap(find.text('الحالية'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderCard), findsOneWidget);
    expect(find.text('ONL-20261018-001'), findsOneWidget);
    expect(find.text('ONL-20261018-002'), findsNothing);

    // Tap "السابقة" (Past)
    await tester.tap(find.text('السابقة'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderCard), findsOneWidget);
    expect(find.text('ONL-20261018-002'), findsOneWidget);
    expect(find.text('ONL-20261018-001'), findsNothing);
  });
}
