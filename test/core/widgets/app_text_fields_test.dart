import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_text_fields.dart';

Widget _wrap(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

void main() {
  group('AppTextField Widget Tests', () {
    testWidgets('renders basic text field with label and hint', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextField(
            label: 'Test Label',
            hintText: 'Enter test value',
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Enter test value'), findsOneWidget);
      expect(find.text('*'), findsNothing);
    });

    testWidgets('renders required asterisk when required: true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextField(
            label: 'Required Field',
            required: true,
          ),
        ),
      );

      expect(find.text('Required Field'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('animates focus glow and updates label color on focus', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        _wrap(
          AppTextField(
            label: 'Focus Field',
            focusNode: focusNode,
          ),
        ),
      );

      final labelFinder = find.text('Focus Field');
      Text textWidget = tester.widget<Text>(labelFinder);
      expect(textWidget.style?.color, equals(AppColors.slate700));

      // Request focus
      focusNode.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      textWidget = tester.widget<Text>(labelFinder);
      expect(textWidget.style?.color, equals(AppColors.primaryBrand));

      // DecoratedBox should have a BoxShadow during focus
      final decoratedBoxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final hasGlow = decoratedBoxes.any((box) {
        final decoration = box.decoration as BoxDecoration;
        return decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty;
      });
      expect(hasGlow, isTrue);

      // Unfocus
      focusNode.unfocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      textWidget = tester.widget<Text>(labelFinder);
      expect(textWidget.style?.color, equals(AppColors.slate700));

      focusNode.dispose();
    });

    testWidgets('renders trailingLabelWidget and helper widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextField(
            label: 'Field With Extras',
            trailingLabelWidget: Text('Optional'),
            helper: Text('Helper information'),
          ),
        ),
      );

      expect(find.text('Field With Extras'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('Helper information'), findsOneWidget);
    });

    testWidgets('shows validation error text when errorText provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextField(
            label: 'Validated Field',
            errorText: 'Value is invalid',
          ),
        ),
      );

      expect(find.text('Value is invalid'), findsOneWidget);
    });
  });
}
