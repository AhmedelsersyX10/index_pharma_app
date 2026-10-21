import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_entity.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_status.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_upload_result.dart';
import 'package:index_pharma/features/prescriptions/domain/repositories/prescriptions_repository.dart';
import 'package:index_pharma/features/prescriptions/presentation/cubit/prescription_cubit.dart';
import 'package:index_pharma/features/prescriptions/presentation/screens/my_prescriptions_screen.dart';
import 'package:index_pharma/features/prescriptions/presentation/widgets/prescription_card.dart';
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

class FakePrescriptionsRepository implements PrescriptionsRepository {
  ApiResult<PrescriptionUploadResult>? uploadResult;
  ApiResult<PrescriptionEntity>? submitResult;
  ApiResult<List<PrescriptionEntity>>? listResult;
  Future<ApiResult<List<PrescriptionEntity>>> Function()? listHandler;

  @override
  Future<ApiResult<PrescriptionUploadResult>> uploadPrescriptionImage({
    required String filePath,
    required String fileName,
  }) async {
    return uploadResult!;
  }

  @override
  Future<ApiResult<PrescriptionEntity>> submitPrescription({
    required String imageUrl,
    String? notes,
  }) async {
    return submitResult!;
  }

  @override
  Future<ApiResult<List<PrescriptionEntity>>> getMyPrescriptions() async {
    if (listHandler != null) {
      return listHandler!();
    }
    return listResult!;
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

  Widget buildTestableWidget(Widget child,
      {Locale locale = const Locale('ar')}) {
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

  const testPrescription1 = PrescriptionEntity(
    id: 'rx-1',
    prescriptionNumber: 'RX-20261020-001',
    imageUrl: '/uploads/prescriptions/rx1.jpg',
    status: PrescriptionStatus.pending,
    rawStatus: 'pending',
    notes: 'أرجو توفير البديل إذا لم يتوفر الأصلي',
  );

  const testPrescription2 = PrescriptionEntity(
    id: 'rx-2',
    prescriptionNumber: 'RX-20261020-002',
    imageUrl: '/uploads/prescriptions/rx2.jpg',
    status: PrescriptionStatus.preparing,
    rawStatus: 'preparing',
  );

  testWidgets('renders loading spinner when fetching prescriptions',
      (tester) async {
    final fakeRepo = FakePrescriptionsRepository();
    final completer = Completer<ApiResult<List<PrescriptionEntity>>>();
    fakeRepo.listHandler = () => completer.future;

    final cubit = PrescriptionCubit(repository: fakeRepo);

    await tester.pumpWidget(
      buildTestableWidget(MyPrescriptionsScreen(cubit: cubit)),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Success([]));
    await tester.pumpAndSettle();
  });

  testWidgets('renders empty state when prescriptions list is empty',
      (tester) async {
    final fakeRepo = FakePrescriptionsRepository();
    fakeRepo.listResult = const Success([]);
    final cubit = PrescriptionCubit(repository: fakeRepo);

    await tester.pumpWidget(
      buildTestableWidget(MyPrescriptionsScreen(cubit: cubit)),
    );
    await tester.pumpAndSettle();

    expect(find.text('لا توجد روشتات مسجلة'), findsOneWidget);
    expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    expect(find.byType(PrescriptionCard), findsNothing);
  });

  testWidgets('renders error view on failure and allows retry', (tester) async {
    final fakeRepo = FakePrescriptionsRepository();
    fakeRepo.listResult = const Err(
      Network(serverMessage: 'انقطع الاتصال بالإنترنت'),
    );
    final cubit = PrescriptionCubit(repository: fakeRepo);

    await tester.pumpWidget(
      buildTestableWidget(MyPrescriptionsScreen(cubit: cubit)),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('انقطع الاتصال بالإنترنت'), findsOneWidget);

    // Update repository to return success on retry
    fakeRepo.listResult = const Success([testPrescription1]);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PrescriptionCard), findsOneWidget);
    expect(find.text('RX-20261020-001'), findsOneWidget);
  });

  testWidgets('renders prescription cards when list is loaded', (tester) async {
    final fakeRepo = FakePrescriptionsRepository();
    fakeRepo.listResult = const Success([testPrescription1, testPrescription2]);
    final cubit = PrescriptionCubit(repository: fakeRepo);

    await tester.pumpWidget(
      buildTestableWidget(MyPrescriptionsScreen(cubit: cubit)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PrescriptionCard), findsNWidgets(2));
    expect(find.text('RX-20261020-001'), findsOneWidget);
    expect(find.text('RX-20261020-002'), findsOneWidget);
  });
}
