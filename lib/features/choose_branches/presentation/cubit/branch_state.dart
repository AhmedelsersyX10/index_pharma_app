import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';

/// Sealed hierarchy representing all possible UI states for branch selection.
sealed class BranchState {
  const BranchState();
}

/// Initial state before branch retrieval is triggered.
final class BranchInitial extends BranchState {
  const BranchInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'BranchInitial()';
}

/// Explicit loading state emitted while fetching branches from the backend.
final class BranchLoading extends BranchState {
  const BranchLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'BranchLoading()';
}

/// Loaded state containing active [branches] and the currently [selectedBranchId].
final class BranchLoaded extends BranchState {
  const BranchLoaded({
    required this.branches,
    this.selectedBranchId,
  });

  final List<BranchEntity> branches;
  final String? selectedBranchId;

  /// Returns the currently selected [BranchEntity], or null if none is selected.
  BranchEntity? get selectedBranch {
    if (selectedBranchId == null) return null;
    for (final branch in branches) {
      if (branch.id == selectedBranchId) {
        return branch;
      }
    }
    return null;
  }

  BranchLoaded copyWith({
    List<BranchEntity>? branches,
    String? selectedBranchId,
  }) {
    return BranchLoaded(
      branches: branches ?? this.branches,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchLoaded &&
          runtimeType == other.runtimeType &&
          selectedBranchId == other.selectedBranchId &&
          _listEquals(branches, other.branches);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        selectedBranchId,
        Object.hashAll(branches),
      );

  static bool _listEquals(List<BranchEntity> a, List<BranchEntity> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'BranchLoaded(branches: ${branches.length}, selectedBranchId: $selectedBranchId)';
}

/// Empty state emitted when the backend returns zero active branches.
final class BranchEmpty extends BranchState {
  const BranchEmpty();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchEmpty && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'BranchEmpty()';
}

/// Explicit failure state wrapping a domain-level [failure].
final class BranchFailure extends BranchState {
  const BranchFailure(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchFailure &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'BranchFailure(failure: $failure)';
}
