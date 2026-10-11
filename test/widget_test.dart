import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma_store/main.dart';

void main() {
  testWidgets('IndexPharmaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IndexPharmaApp());
    expect(find.byType(IndexPharmaApp), findsOneWidget);
    // Fast forward splash timer
    await tester.pump(const Duration(seconds: 4));
  });
}
