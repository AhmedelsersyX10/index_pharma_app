import 'package:easy_localization/easy_localization.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/errors/failure_mapper.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import '../../domain/entities/category.dart';

/// Sealed hierarchy representing UI states for store categories.
sealed class CategoriesState {
  const CategoriesState();
}

/// Initial state before categories have been requested.
final class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriesInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CategoriesInitial()';
}

/// Loading state emitted while categories are being retrieved.
final class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriesLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CategoriesLoading()';
}

/// Loaded state containing non-empty verified list of [categories].
final class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.categories);

  final List<Category> categories;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriesLoaded &&
          runtimeType == other.runtimeType &&
          _listEquals(categories, other.categories);

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(categories));

  @override
  String toString() => 'CategoriesLoaded(categories: $categories)';

  static bool _listEquals(List<Category> a, List<Category> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Empty state emitted when categories list is returned empty.
final class CategoriesEmpty extends CategoriesState {
  const CategoriesEmpty();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriesEmpty && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CategoriesEmpty()';
}

/// Failure state wrapping a domain-level [failure].
final class CategoriesFailure extends CategoriesState {
  const CategoriesFailure(this.failure);

  final Failure failure;

  /// User-facing message mapped from domain failure.
  String get message => FailureMapper.toMessage(
        failure,
        defaultFallback: AppLocaleKeys.errorCategoriesLoadFailed.tr(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriesFailure &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'CategoriesFailure(failure: $failure)';
}
