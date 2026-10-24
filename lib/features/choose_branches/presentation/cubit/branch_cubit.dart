import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';
import 'branch_state.dart';

/// Shared customer branch selection. Staff branch scope is managed separately.
class BranchCubit extends Cubit<BranchState> {
  BranchCubit({
    required BranchRepository branchRepository,
    required StorageService storageService,
  }) : _branchRepository = branchRepository,
       _storageService = storageService,
       super(const BranchInitial());

  final BranchRepository _branchRepository;
  final StorageService _storageService;
  List<BranchEntity> _branches = const [];
  int _revision = 0;
  Future<void>? _storageWrites;

  void ensureLoaded() {
    if (state is BranchInitial) fetchBranches();
  }

  bool _isCurrent(int revision) => !isClosed && revision == _revision;

  // Serialize writes so a slower previous selection cannot remain on disk.
  Future<bool> _persist(String? id, int revision) async {
    var saved = false;
    final previous = _storageWrites;
    final write = () async {
      if (previous != null) await previous;
      if (!_isCurrent(revision)) return;
      try {
        saved = id == null
            ? await _storageService.clearSelectedBranchId()
            : await _storageService.setSelectedBranchId(id);
      } on Exception {
        saved = false;
      }
    }();
    _storageWrites = write;
    await write;
    if (identical(_storageWrites, write)) _storageWrites = null;
    return saved;
  }

  Future<void> fetchBranches() async {
    final revision = ++_revision;
    emit(const BranchLoading());
    final result = await _branchRepository.getBranches();
    if (!_isCurrent(revision)) return;

    switch (result) {
      case Success(:final data):
        _branches = data;
        final storedId = _storageService.selectedBranchId;
        final valid = storedId != null && data.any((b) => b.id == storedId);
        // Preserve the existing sole-branch onboarding rule, but never replace
        // a stale saved selection silently with a different branch.
        final selectedId = valid
            ? storedId
            : (storedId == null && data.length == 1 ? data.single.id : null);
        if (selectedId != storedId) {
          final saved = await _persist(selectedId, revision);
          if (!_isCurrent(revision)) return;
          if (!saved) {
            emit(const BranchFailure(Unexpected()));
            return;
          }
        }
        emit(
          data.isEmpty
              ? const BranchEmpty()
              : BranchLoaded(branches: data, selectedBranchId: selectedId),
        );
      case Err(:final failure):
        emit(BranchFailure(failure));
    }
  }

  Future<void> selectBranch(String branchId) async {
    if (!_branches.any((branch) => branch.id == branchId)) return;
    final revision = ++_revision;
    final saved = await _persist(branchId, revision);
    if (!_isCurrent(revision)) return;
    if (!saved) {
      emit(const BranchFailure(Unexpected()));
      return;
    }
    emit(BranchLoaded(branches: _branches, selectedBranchId: branchId));
  }

  Future<void> clearSelection() async {
    final revision = ++_revision;
    final saved = await _persist(null, revision);
    if (!_isCurrent(revision)) return;
    if (!saved) {
      emit(const BranchFailure(Unexpected()));
      return;
    }
    if (_branches.isNotEmpty) {
      emit(BranchLoaded(branches: _branches));
    } else {
      emit(const BranchEmpty());
    }
  }
}
