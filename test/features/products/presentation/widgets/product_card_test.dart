import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/presentation/widgets/product_card.dart';

void main() {
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

  Widget createWidgetUnderTest(Product product) {
    return MaterialApp(
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
