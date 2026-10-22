import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_status.dart';
import 'package:index_pharma/features/prescriptions/presentation/widgets/prescription_status_badge.dart';

late final Map<String, dynamic> _arTranslations;

class _TestAssetLoader extends AssetLoader {
  const _TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    return Future.value(_arTranslations);
  }
}

void main() {
  setUpAll(() {
    final arJsonString = File('assets/translations/ar.json').readAsStringSync();
    _arTranslations = json.decode(arJsonString) as Map<String, dynamic>;
  });

  Widget buildTestWidget({
    required PrescriptionStatus status,
    String? rawStatus,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return EasyLocalization(
      supportedLocales: const [Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      assetLoader: const _TestAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: Scaffold(
              body: Center(
                child: PrescriptionStatusBadge(
                  status: status,
                  rawStatus: rawStatus,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  testWidgets('PrescriptionStatusBadge renders unknown status with badgeNeutral colors in light theme', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(status: PrescriptionStatus.unknown),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PrescriptionStatusBadge), findsOneWidget);

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(PrescriptionStatusBadge),
        matching: find.byType(Container).first,
      ),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColorsExtension.light.badgeNeutralBg);
  });

  testWidgets('PrescriptionStatusBadge renders unknown status with badgeNeutral colors in dark theme', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        status: PrescriptionStatus.unknown,
        themeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PrescriptionStatusBadge), findsOneWidget);

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(PrescriptionStatusBadge),
        matching: find.byType(Container).first,
      ),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColorsExtension.dark.badgeNeutralBg);
  });

  testWidgets('PrescriptionStatusBadge displays rawStatus when unknown and provided', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        status: PrescriptionStatus.unknown,
        rawStatus: 'مراجعة طبية خاصة',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مراجعة طبية خاصة'), findsOneWidget);
  });
}
