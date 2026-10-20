import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/checkout/domain/entities/order.dart';
import 'package:index_pharma/features/checkout/presentation/screens/order_confirmation_screen.dart';
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

  final sampleOrder = Order(
    id: 'ord-887123aa',
    orderNumber: 'ONL-20261018-001',
    customerId: 'cust-1',
    branchId: 'b-1',
    subtotal: 170.0,
    totalAmount: 170.0,
    paidAmount: 0.0,
    dueAmount: 170.0,
    changeAmount: 0.0,
    orderType: 'ONLINE',
    status: 'pending',
    paymentMethod: 'cash',
    deliveryAddress: 'Nasr City, Building 4',
    customerPhone: '01012345678',
    createdAt: DateTime(2026, 10, 18, 12, 30),
    items: const [],
  );

  Widget createWidgetUnderTest({
    required Order order,
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
            home: OrderConfirmationScreen(order: order),
          );
        },
      ),
    );
  }

  testWidgets('renders celebration banner, order number, status, payment, total, and actions in Arabic',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(order: sampleOrder));
    await tester.pumpAndSettle();

    expect(find.text('تم استلام طلبك بنجاح!'), findsOneWidget);
    expect(find.text('ONL-20261018-001'), findsOneWidget);
    expect(find.text('قيد الانتظار'), findsOneWidget);
    expect(find.text('الدفع نقداً عند الاستلام (كاش)'), findsOneWidget);
    expect(find.text('170.00'), findsOneWidget);
    expect(find.text('إجراءات المراجعة الدوائية'), findsOneWidget);
    expect(find.byKey(const Key('btn_view_order_details')), findsOneWidget);
    expect(find.byKey(const Key('btn_continue_shopping')), findsOneWidget);
  });

  testWidgets('copy order number button copies to clipboard and gives feedback',
      (tester) async {
    // Intercept clipboard calls
    final log = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          log.add(methodCall.arguments['text'] as String);
        }
        return null;
      },
    );

    await tester.pumpWidget(createWidgetUnderTest(order: sampleOrder));
    await tester.pumpAndSettle();

    expect(find.text('نسخ'), findsOneWidget);

    await tester.tap(find.byKey(const Key('btn_copy_order_number')));
    await tester.pump();

    expect(log, contains('ONL-20261018-001'));
    expect(find.text('تم النسخ'), findsOneWidget);

    // Advance 2-second timer to clean up pending timers
    await tester.pump(const Duration(seconds: 2));
  });
}
