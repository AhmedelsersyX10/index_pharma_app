import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/screens/branch_selection_screen.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/branch_bottom_bar.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/branch_card.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/branch_state_views.dart';
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

class FakeBranchRepository implements BranchRepository {
  ApiResult<List<BranchEntity>>? getBranchesResult;
  Future<ApiResult<List<BranchEntity>>> Function()? getBranchesHandler;

  @override
  Future<ApiResult<List<BranchEntity>>> getBranches() async {
    if (getBranchesHandler != null) {
      return getBranchesHandler!();
    }
    return getBranchesResult!;
  }
}

class FakeStorageService implements StorageService {
  String? _selectedBranchId;
  String? _locale;
  bool _onboardingSeen = false;

  @override
  String? get selectedBranchId => _selectedBranchId;

  @override
  Future<bool> setSelectedBranchId(String branchId) async {
    _selectedBranchId = branchId;
    return true;
  }

  @override
  Future<bool> clearSelectedBranchId() async {
    _selectedBranchId = null;
    return true;
  }

  @override
  String? get locale => _locale;

  @override
  Future<bool> setLocale(String locale) async {
    _locale = locale;
    return true;
  }

  @override
  bool get onboardingSeen => _onboardingSeen;

  @override
  Future<bool> setOnboardingSeen(bool seen) async {
    _onboardingSeen = seen;
    return true;
  }
}

void main() {
  setUpAll(() async {
    final arRaw = await File('assets/translations/ar.json').readAsString();
    final enRaw = await File('assets/translations/en.json').readAsString();
    _arTranslations = jsonDecode(arRaw) as Map<String, dynamic>;
    _enTranslations = jsonDecode(enRaw) as Map<String, dynamic>;

    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  late FakeBranchRepository fakeRepository;
  late FakeStorageService fakeStorageService;
  late BranchCubit cubit;

  const branch1 = BranchEntity(
    id: 'b1',
    name: 'فرع مدينة نصر',
    address: 'شارع عباس العقاد',
    phone: '01012345678',
  );

  const branch2 = BranchEntity(
    id: 'b2',
    name: 'فرع المعادي',
    address: 'دجلة المعادي',
    phone: '0225194432',
  );

  setUp(() {
    fakeRepository = FakeBranchRepository();
    fakeStorageService = FakeStorageService();
    cubit = BranchCubit(
      branchRepository: fakeRepository,
      storageService: fakeStorageService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  Widget buildTestApp({VoidCallback? onBranchConfirmed}) {
    return EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      assetLoader: const SynchronousDiskAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: BranchSelectionScreen(
              branchCubit: cubit,
              onBranchConfirmed: onBranchConfirmed,
            ),
          );
        },
      ),
    );
  }

  testWidgets('renders BranchLoadingView while loading', (tester) async {
    final completer = Completer<ApiResult<List<BranchEntity>>>();
    fakeRepository.getBranchesHandler = () => completer.future;

    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump();

    // While completer is pending, screen renders loading skeleton
    expect(find.byType(BranchLoadingView), findsOneWidget);

    completer.complete(const Success([branch1]));
    await tester.pumpAndSettle();

    expect(find.byType(BranchCard), findsOneWidget);
  });

  testWidgets('renders BranchEmptyView when no branches returned', (tester) async {
    fakeRepository.getBranchesResult = const Success([]);

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(BranchEmptyView), findsOneWidget);
  });

  testWidgets('renders BranchErrorView on failure and can retry', (tester) async {
    fakeRepository.getBranchesResult = const Err(Server(serverMessage: 'فشل في الاتصال'));

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(BranchErrorView), findsOneWidget);
    expect(find.text(AppLocaleKeys.errorServer.tr()), findsOneWidget);

    // Now change to success and retry
    fakeRepository.getBranchesResult = const Success([branch1, branch2]);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(BranchCard), findsNWidgets(2));
  });

  testWidgets('renders branches and allows selection and confirmation', (tester) async {
    fakeRepository.getBranchesResult = const Success([branch1, branch2]);
    bool confirmed = false;

    await tester.pumpWidget(buildTestApp(onBranchConfirmed: () {
      confirmed = true;
    }));
    await tester.pumpAndSettle();

    // Verify both branch cards are rendered
    expect(find.text('فرع مدينة نصر'), findsOneWidget);
    expect(find.text('فرع المعادي'), findsOneWidget);

    // Bottom confirmation button should initially be disabled because no branch is selected yet
    final confirmButton = tester.widget<ElevatedButton>(
      find.descendant(of: find.byType(BranchBottomBar), matching: find.byType(ElevatedButton)),
    );
    expect(confirmButton.onPressed, isNull);

    // Tap on branch 2
    await tester.tap(find.text('فرع المعادي'));
    await tester.pumpAndSettle();

    // Now branch 2 is selected and stored in StorageService
    expect(fakeStorageService.selectedBranchId, equals('b2'));

    // Confirm button is now active
    await tester.tap(find.descendant(
      of: find.byType(BranchBottomBar),
      matching: find.byType(ElevatedButton),
    ));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });
}
