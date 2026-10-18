import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/choose_branshs/domain/repositories/branch_repository.dart';
import 'branch_state.dart';

/// Cubit responsible for managing pharmacy branch selection and persistence.
///
/// Follows Clean Architecture:
/// - Fetches branches exclusively via [BranchRepository].
/// - Persists and restores the selected branch ID via [StorageService] (`keySelectedBranchId`).
/// - Auto-selects and persists the branch if exactly one branch is returned by the backend.
class BranchCubit extends Cubit<BranchState> {
  BranchCubit({
    required BranchRepository branchRepository,
    required StorageService storageService,
  })  : _branchRepository = branchRepository,
        _storageService = storageService,
        super(const BranchInitial());

  final BranchRepository _branchRepository;
  final StorageService _storageService;

  /// Fetches active store branches from the backend.
  ///
  /// - Emits [BranchLoading].
  /// - Emits [BranchEmpty] if the list is empty.
  /// - Emits [BranchLoaded] with automatic selection if exactly 1 branch exists.
  /// - Emits [BranchLoaded] with restored selection if multiple branches exist and
  ///   a valid ID is stored in [StorageService].
  /// - Emits [BranchFailure] on failure.
  Future<void> fetchBranches() async {
    emit(const BranchLoading());
    final result = await _branchRepository.getBranches();

    switch (result) {
      case Success(:final data):
        if (data.isEmpty) {
          emit(const BranchEmpty());
          return;
        }

        final storedBranchId = _storageService.selectedBranchId;

        // Auto-select rule: if exactly one branch exists, automatically select and persist it.
        if (data.length == 1) {
          final autoSelectedId = data.first.id;
          if (storedBranchId != autoSelectedId) {
            await _storageService.setSelectedBranchId(autoSelectedId);
          }
          emit(
            BranchLoaded(
              branches: data,
              selectedBranchId: autoSelectedId,
            ),
          );
          return;
        }

        // Multiple branches: restore persisted selection if still valid.
        final bool isStoredIdValid =
            storedBranchId != null && data.any((b) => b.id == storedBranchId);

        emit(
          BranchLoaded(
            branches: data,
            selectedBranchId: isStoredIdValid ? storedBranchId : null,
          ),
        );

      case Err(:final failure):
        emit(BranchFailure(failure));
    }
  }

  /// Selects a specific branch and persists its ID to [StorageService].
  Future<void> selectBranch(String branchId) async {
    final currentState = state;
    if (currentState is BranchLoaded) {
      await _storageService.setSelectedBranchId(branchId);
      emit(currentState.copyWith(selectedBranchId: branchId));
    }
  }

  /// Clears the currently selected branch ID in both state and local storage.
  Future<void> clearSelection() async {
    final currentState = state;
    await _storageService.clearSelectedBranchId();
    if (currentState is BranchLoaded) {
      emit(
        BranchLoaded(
          branches: currentState.branches,
          selectedBranchId: null,
        ),
      );
    }
  }
}
