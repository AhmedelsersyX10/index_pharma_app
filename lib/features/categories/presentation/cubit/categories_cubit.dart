import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/network/api_result.dart';
import '../../domain/repositories/categories_repository.dart';
import 'categories_state.dart';

/// Cubit responsible for retrieving and managing public store categories.
class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({
    required CategoriesRepository categoriesRepository,
  })  : _categoriesRepository = categoriesRepository,
        super(const CategoriesInitial());

  final CategoriesRepository _categoriesRepository;

  /// Fetches public categories from the backend.
  ///
  /// Emits [CategoriesLoading] followed by [CategoriesEmpty], [CategoriesLoaded],
  /// or [CategoriesFailure].
  Future<void> fetchCategories() async {
    emit(const CategoriesLoading());
    final result = await _categoriesRepository.getCategories();

    switch (result) {
      case Success(:final data):
        if (data.isEmpty) {
          emit(const CategoriesEmpty());
        } else {
          emit(CategoriesLoaded(data));
        }
      case Err(:final failure):
        emit(CategoriesFailure(failure));
    }
  }

  /// Alias for [fetchCategories] to support flexible naming.
  Future<void> loadCategories() => fetchCategories();
}
