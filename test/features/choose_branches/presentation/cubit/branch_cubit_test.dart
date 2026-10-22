import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';

class FakeBranchRepository implements BranchRepository {
  ApiResult<List<BranchEntity>>? getBranchesResult;

  @override
  Future<ApiResult<List<BranchEntity>>> getBranches() async {
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

  String? _themeMode;

  @override
  String? get themeMode => _themeMode;

  @override
  Future<bool> setThemeMode(String mode) async {
    _themeMode = mode;
    return true;
  }
}

void main() {
  late FakeBranchRepository fakeRepository;
  late FakeStorageService fakeStorageService;
  late BranchCubit cubit;

  const branch1 = BranchEntity(
    id: 'b18f3a22-3118-4089-9e8c-529a6e118901',
    name: 'Main Branch',
    address: 'Cairo',
    phone: '01012345678',
  );

  const branch2 = BranchEntity(
    id: 'b28f3a22-3118-4089-9e8c-529a6e118902',
    name: 'Maadi Branch',
    address: 'Degla Maadi',
    phone: '0225194432',
  );

  const branch3 = BranchEntity(
    id: 'b38f3a22-3118-4089-9e8c-529a6e118903',
    name: 'Mohandessin Branch',
    address: 'Giza',
    phone: '0237612040',
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

  group('BranchCubit Tests', () {
    test('initial state is BranchInitial', () {
      expect(cubit.state, equals(const BranchInitial()));
    });

    test('fetchBranches emits [BranchLoading, BranchEmpty] when list is empty', () async {
      fakeRepository.getBranchesResult = const Success([]);

      final states = <BranchState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchBranches();
      await pumpEventQueue();

      expect(states, [
        const BranchLoading(),
        const BranchEmpty(),
      ]);
    });

    test('fetchBranches auto-selects and persists branch if exactly one branch is returned', () async {
      fakeRepository.getBranchesResult = const Success([branch1]);

      final states = <BranchState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchBranches();
      await pumpEventQueue();

      expect(states, [
        const BranchLoading(),
        const BranchLoaded(
          branches: [branch1],
          selectedBranchId: 'b18f3a22-3118-4089-9e8c-529a6e118901',
        ),
      ]);

      // Verify that auto-selection was persisted to StorageService
      expect(
        fakeStorageService.selectedBranchId,
        equals('b18f3a22-3118-4089-9e8c-529a6e118901'),
      );
    });

    test('fetchBranches emits BranchLoaded with null selection when multiple branches exist and no stored selection', () async {
      fakeRepository.getBranchesResult = const Success([branch1, branch2, branch3]);

      final states = <BranchState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchBranches();
      await pumpEventQueue();

      expect(states, [
        const BranchLoading(),
        const BranchLoaded(
          branches: [branch1, branch2, branch3],
          selectedBranchId: null,
        ),
      ]);
    });

    test('fetchBranches restores previously stored selection if valid', () async {
      fakeStorageService.setSelectedBranchId(branch2.id);
      fakeRepository.getBranchesResult = const Success([branch1, branch2, branch3]);

      final states = <BranchState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchBranches();
      await pumpEventQueue();

      expect(states, [
        const BranchLoading(),
        BranchLoaded(
          branches: const [branch1, branch2, branch3],
          selectedBranchId: branch2.id,
        ),
      ]);
      expect(
        (states.last as BranchLoaded).selectedBranch,
        equals(branch2),
      );
    });

    test('fetchBranches sets selection to null if previously stored ID is not in active branches', () async {
      fakeStorageService.setSelectedBranchId('deleted-or-inactive-branch-id');
      fakeRepository.getBranchesResult = const Success([branch1, branch2]);

      final states = <BranchState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchBranches();
      await pumpEventQueue();

      expect(states, [
        const BranchLoading(),
        const BranchLoaded(
          branches: [branch1, branch2],
          selectedBranchId: null,
        ),
      ]);
    });

    test('fetchBranches emits [BranchLoading, BranchFailure] when repository fails', () async {
      const failure = Server(serverMessage: 'Server unavailable');
      fakeRepository.getBranchesResult = const Err(failure);

      final states = <BranchState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchBranches();
      await pumpEventQueue();

      expect(states, [
        const BranchLoading(),
        const BranchFailure(failure),
      ]);
    });

    test('selectBranch updates selection in state and persists to StorageService', () async {
      fakeRepository.getBranchesResult = const Success([branch1, branch2]);
      await cubit.fetchBranches();

      final states = <BranchState>[];
      cubit.stream.listen(states.add);

      await cubit.selectBranch(branch2.id);
      await pumpEventQueue();

      expect(states, [
        BranchLoaded(
          branches: const [branch1, branch2],
          selectedBranchId: branch2.id,
        ),
      ]);
      expect(fakeStorageService.selectedBranchId, equals(branch2.id));
    });

    test('clearSelection clears selected branch in state and removes it from StorageService', () async {
      fakeStorageService.setSelectedBranchId(branch1.id);
      fakeRepository.getBranchesResult = const Success([branch1, branch2]);
      await cubit.fetchBranches();

      expect((cubit.state as BranchLoaded).selectedBranchId, equals(branch1.id));

      await cubit.clearSelection();

      expect((cubit.state as BranchLoaded).selectedBranchId, isNull);
      expect(fakeStorageService.selectedBranchId, isNull);
    });

    test('ACCEPTANCE: Selected branch survives simulated app restart', () async {
      // 1. First app launch: user loads branches and selects branch 3
      fakeRepository.getBranchesResult = const Success([branch1, branch2, branch3]);
      await cubit.fetchBranches();
      await cubit.selectBranch(branch3.id);

      expect(fakeStorageService.selectedBranchId, equals(branch3.id));
      await cubit.close();

      // 2. App restart: New cubit instance is created with the same persistent storage
      final newAppSessionCubit = BranchCubit(
        branchRepository: fakeRepository,
        storageService: fakeStorageService,
      );

      // 3. New session loads branches
      await newAppSessionCubit.fetchBranches();

      // 4. Verification: Branch 3 is automatically restored
      expect(newAppSessionCubit.state, isA<BranchLoaded>());
      final loadedState = newAppSessionCubit.state as BranchLoaded;
      expect(loadedState.selectedBranchId, equals(branch3.id));
      expect(loadedState.selectedBranch, equals(branch3));

      await newAppSessionCubit.close();
    });
  });
}
