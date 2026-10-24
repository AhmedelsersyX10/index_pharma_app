import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/account/presentation/screens/account_screen.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/branch_bottom_bar.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/branch_card.dart';
import 'package:index_pharma/features/home/presentation/widgets/home_branch_selector_strip.dart';
import 'package:index_pharma/features/home/presentation/widgets/home_hero_banner.dart';
import 'package:index_pharma/features/orders/domain/entities/customer_order.dart';
import 'package:index_pharma/features/orders/domain/entities/customer_order_item.dart';
import 'package:index_pharma/features/orders/presentation/widgets/order_card.dart';
import 'package:index_pharma/features/settings/domain/entities/public_settings.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_state.dart';
import 'package:index_pharma/core/theme/theme.dart';
import '../../helpers/pump_with_providers.dart';

const branches = [
  BranchEntity(id: 'b1', name: 'Branch One'),
  BranchEntity(id: 'b2', name: 'Branch Two'),
];

class BranchRepositoryFake implements BranchRepository {
  List<BranchEntity> values = branches;
  @override
  Future<ApiResult<List<BranchEntity>>> getBranches() async => Success(values);
}

class DeferredBranches implements BranchRepository {
  final pending = <Completer<ApiResult<List<BranchEntity>>>>[];
  @override
  Future<ApiResult<List<BranchEntity>>> getBranches() {
    final request = Completer<ApiResult<List<BranchEntity>>>();
    pending.add(request);
    return request.future;
  }
}

class FailingStorage extends FakeTestStorageService {
  @override
  Future<bool> setSelectedBranchId(String id) async => false;
}

class SlowStorage extends FakeTestStorageService {
  final firstWrite = Completer<void>();
  @override
  Future<bool> setSelectedBranchId(String id) async {
    if (id == 'b1') await firstWrite.future;
    return super.setSelectedBranchId(id);
  }
}

void main() {
  setUpAll(initTestEnvironment);
  setUp(() async => getIt.reset());
  tearDown(() async => getIt.reset());

  for (final locale in ['ar', 'en']) {
    testWidgets('order timestamp and unit count are correct in $locale', (
      tester,
    ) async {
      final order = CustomerOrder(
        id: 'order',
        orderNumber: 'ORDER-1',
        subtotal: 20,
        totalAmount: 20,
        orderType: 'ONLINE',
        status: 'pending',
        paymentMethod: 'cash',
        deliveryAddress: '',
        customerPhone: '',
        createdAt: DateTime.parse('2026-10-18T21:45:00Z'),
        items: const [
          CustomerOrderItem(
            id: 'i',
            productId: 'p',
            productName: 'Medicine',
            quantity: 2,
            priceAtPurchase: 10,
          ),
        ],
      );
      var tapped = false;
      await tester.pumpWidget(
        buildAppWithProviders(
          locale: Locale(locale),
          child: Scaffold(
            body: OrderCard(order: order, onTap: () => tapped = true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          locale == 'en'
              ? '18 October 2026, 09:45 PM'
              : '١٨ أكتوبر ٢٠٢٦, ٠٩:٤٥ م',
        ),
        findsOneWidget,
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data)
            .join(' | '),
      );
      expect(find.textContaining('Instance of'), findsNothing);
      expect(find.text(locale == 'en' ? '2 units' : '2 وحدات'), findsOneWidget);
      await tester.tap(find.text('ORDER-1'));
      expect(tapped, isTrue);
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'approved hero copy ignores missing and unverified settings $locale $mode',
        (tester) async {
          final settings = SettingsCubit(
            settingsRepository: FakeTestSettingsRepository(),
          );
          final theme = ThemeCubit(storageService: FakeTestStorageService());
          await theme.updateThemeMode(mode);
          addTearDown(settings.close);
          addTearDown(theme.close);
          await tester.pumpWidget(
            buildAppWithProviders(
              locale: Locale(locale),
              themeCubit: theme,
              child: Scaffold(
                body: BlocProvider.value(
                  value: settings,
                  child: const HomeHeroBanner(),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final title = locale == 'en'
              ? 'Browse branch products'
              : 'تصفح منتجات الفرع';
          expect(find.text(title), findsOneWidget);
          settings.emit(
            const SettingsLoaded(
              PublicSettings(
                homeHeroTitle: 'CERTIFIED 24/7',
                homeHeroDesc: '30-45 minutes cold-chain',
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text(title), findsOneWidget);
          expect(find.textContaining('CERTIFIED'), findsNothing);
          expect(find.textContaining('cold-chain'), findsNothing);
          settings.emit(const SettingsLoaded(PublicSettings()));
          await tester.pumpAndSettle();
          expect(find.text(title), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  test(
    'invalid saved branch is removed and never replaced with the first branch',
    () async {
      final storage = FakeTestStorageService(selectedBranchId: 'inactive');
      final cubit = BranchCubit(
        branchRepository: BranchRepositoryFake(),
        storageService: storage,
      );
      addTearDown(cubit.close);
      await cubit.fetchBranches();
      expect((cubit.state as BranchLoaded).selectedBranch, isNull);
      expect(storage.selectedBranchId, isNull);
      await cubit.selectBranch('unknown');
      expect(storage.selectedBranchId, isNull);
    },
  );

  test('older branch fetch cannot overwrite the latest response', () async {
    final repository = DeferredBranches();
    final cubit = BranchCubit(
      branchRepository: repository,
      storageService: FakeTestStorageService(),
    );
    addTearDown(cubit.close);
    final old = cubit.fetchBranches();
    final current = cubit.fetchBranches();
    repository.pending[1].complete(const Success(branches));
    await current;
    await cubit.selectBranch('b2');
    repository.pending[0].complete(const Success([]));
    await old;
    expect((cubit.state as BranchLoaded).selectedBranchId, 'b2');
  });

  test(
    'latest selection wins in state and persisted storage despite a slow write',
    () async {
      final storage = SlowStorage();
      final cubit = BranchCubit(
        branchRepository: BranchRepositoryFake(),
        storageService: storage,
      );
      addTearDown(cubit.close);
      await cubit.fetchBranches();
      final first = cubit.selectBranch('b1');
      await Future<void>.delayed(Duration.zero);
      final second = cubit.selectBranch('b2');
      storage.firstWrite.complete();
      await Future.wait([first, second]);
      expect((cubit.state as BranchLoaded).selectedBranchId, 'b2');
      expect(storage.selectedBranchId, 'b2');
      final restored = BranchCubit(
        branchRepository: BranchRepositoryFake(),
        storageService: storage,
      );
      addTearDown(restored.close);
      await restored.fetchBranches();
      expect((restored.state as BranchLoaded).selectedBranchId, 'b2');
    },
  );

  test(
    'failed persistence is surfaced instead of showing a successful selection',
    () async {
      final cubit = BranchCubit(
        branchRepository: BranchRepositoryFake(),
        storageService: FailingStorage(),
      );
      addTearDown(cubit.close);
      await cubit.fetchBranches();
      await cubit.selectBranch('b2');
      expect(cubit.state, isA<BranchFailure>());
      expect((cubit.state as BranchFailure).failure, isA<Unexpected>());
    },
  );

  testWidgets(
    'branch confirmation immediately updates the existing Home and Account routes',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final storage = FakeTestStorageService(onboardingSeen: true);
      final branch = BranchCubit(
        branchRepository: BranchRepositoryFake(),
        storageService: storage,
      );
      final auth = AuthCubit(authRepository: FakeTestAuthRepository());
      auth.emit(
        const AuthAuthenticated(
          UserEntity(
            id: 'customer',
            name: 'Test',
            email: 'qa@example.invalid',
            role: UserRole.customer,
          ),
        ),
      );
      registerDefaultTestFactories(
        storageService: storage,
        branchRepo: BranchRepositoryFake(),
      );
      final router = AppRouter(
        branchCubit: branch,
        authCubit: auth,
        storageService: storage,
        initialLocation: AppRouter.kStoreView,
      );
      addTearDown(branch.close);
      addTearDown(auth.close);
      addTearDown(router.router.dispose);
      await tester.pumpWidget(
        buildAppWithProviders(
          authCubit: auth,
          storageService: storage,
          routerConfig: router.router,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .descendant(
              of: find.byType(HomeBranchSelectorStrip),
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(BranchCard, 'Branch Two'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(BranchBottomBar),
          matching: find.byType(ElevatedButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(HomeBranchSelectorStrip),
          matching: find.text('Branch Two'),
        ),
        findsOneWidget,
      );
      router.router.go(AppRouter.kAccountView);
      await tester.pumpAndSettle();
      expect(find.byType(AccountScreen), findsOneWidget);
      expect(find.text('Branch Two'), findsOneWidget);
      await branch.selectBranch('b1');
      await tester.pumpAndSettle();
      expect(find.text('Branch One'), findsOneWidget);
      expect(find.text('Branch Two'), findsNothing);
      expect(storage.selectedBranchId, 'b1');
    },
  );
}
