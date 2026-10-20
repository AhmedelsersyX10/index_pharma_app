import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/orders/domain/entities/customer_order.dart';
import 'package:index_pharma/features/orders/domain/entities/customer_order_item.dart';
import 'package:index_pharma/features/orders/presentation/screens/order_details_screen.dart';
import 'package:index_pharma/features/orders/presentation/widgets/order_delivery_info_card.dart';
import 'package:index_pharma/features/orders/presentation/widgets/order_financial_summary_card.dart';
import 'package:index_pharma/features/orders/presentation/widgets/order_items_section.dart';
import 'package:index_pharma/features/orders/presentation/widgets/order_timeline_view.dart';
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
    id: 'ord-887123aa',
    orderNumber: 'ONL-20261018-001',
    subtotal: 170.0,
    totalAmount: 170.0,
    orderType: 'ONLINE',
    status: 'processing',
    paymentMethod: 'cash',
    deliveryAddress: 'Nasr City, Building 4',
    customerPhone: '01012345678',
    notes: 'يرجى الاتصال قبل الوصول',
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

  testWidgets('renders all core sections on active order details', (tester) async {
    await tester.pumpWidget(buildTestableWidget(OrderDetailsScreen(order: testOrder)));
    await tester.pumpAndSettle();

    expect(find.text('ONL-20261018-001'), findsOneWidget);
    expect(find.byType(OrderTimelineView), findsOneWidget);
    expect(find.byType(OrderItemsSection), findsOneWidget);
    expect(find.byType(OrderDeliveryInfoCard), findsOneWidget);
    expect(find.byType(OrderFinancialSummaryCard), findsOneWidget);

    expect(find.text('Vitamin C 1000mg'), findsOneWidget);
    expect(find.text('Nasr City, Building 4'), findsOneWidget);
    expect(find.text('01012345678'), findsOneWidget);
    expect(find.text('يرجى الاتصال قبل الوصول'), findsOneWidget);
  });

  testWidgets('renders cancellation banner when order is cancelled', (tester) async {
    final cancelledOrder = CustomerOrder(
      id: 'ord-cancelled',
      orderNumber: 'ONL-20261018-099',
      subtotal: 90.0,
      totalAmount: 90.0,
      orderType: 'ONLINE',
      status: 'cancelled',
      paymentMethod: 'cash',
      deliveryAddress: 'Nasr City',
      customerPhone: '01012345678',
      createdAt: DateTime(2026, 10, 18, 12, 30),
      items: const [],
    );

    await tester.pumpWidget(buildTestableWidget(OrderDetailsScreen(order: cancelledOrder)));
    await tester.pumpAndSettle();

    expect(find.text('تم إلغاء هذا الطلب'), findsOneWidget);
  });

  testWidgets('tapping copy button copies order number to clipboard', (tester) async {
    await tester.pumpWidget(buildTestableWidget(OrderDetailsScreen(order: testOrder)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();

    expect(find.text('تم النسخ!'), findsOneWidget);
  });
}
