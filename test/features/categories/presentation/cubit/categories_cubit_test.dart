import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/categories/domain/repositories/categories_repository.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_state.dart';

class FakeCategoriesRepository implements CategoriesRepository {
  ApiResult<List<Category>>? result;

  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    return result!;
  }
}

void main() {
  late FakeCategoriesRepository fakeRepository;
  late CategoriesCubit cubit;

  const testCategories = [
    Category(id: 'cmv9bxrwr0003wqgoxhdft6rb', name: 'Skincare'),
    Category(id: 'cmv9bxrw70002wqgo7j1crx4h', name: 'Vitamins'),
  ];

  setUp(() {
    fakeRepository = FakeCategoriesRepository();
    cubit = CategoriesCubit(categoriesRepository: fakeRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('CategoriesCubit Tests', () {
    test('initial state is CategoriesInitial', () {
      expect(cubit.state, equals(const CategoriesInitial()));
    });

    test('fetchCategories emits [CategoriesLoading, CategoriesLoaded] on non-empty success', () async {
      fakeRepository.result = const Success(testCategories);

      final states = <CategoriesState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchCategories();
      await pumpEventQueue();

      expect(states, [
        const CategoriesLoading(),
        const CategoriesLoaded(testCategories),
      ]);
      expect(cubit.state, equals(const CategoriesLoaded(testCategories)));
      expect((cubit.state as CategoriesLoaded).categories.length, equals(2));
    });

    test('fetchCategories emits [CategoriesLoading, CategoriesEmpty] on empty list success', () async {
      fakeRepository.result = const Success(<Category>[]);

      final states = <CategoriesState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchCategories();
      await pumpEventQueue();

      expect(states, [
        const CategoriesLoading(),
        const CategoriesEmpty(),
      ]);
      expect(cubit.state, equals(const CategoriesEmpty()));
    });

    test('loadCategories alias works and emits [CategoriesLoading, CategoriesLoaded]', () async {
      fakeRepository.result = const Success(testCategories);

      final states = <CategoriesState>[];
      cubit.stream.listen(states.add);

      await cubit.loadCategories();
      await pumpEventQueue();

      expect(states, [
        const CategoriesLoading(),
        const CategoriesLoaded(testCategories),
      ]);
    });

    test('fetchCategories emits [CategoriesLoading, CategoriesFailure] on failure', () async {
      const failure = Server(serverMessage: 'تعذر الاتصال بالخادم');
      fakeRepository.result = const Err(failure);

      final states = <CategoriesState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchCategories();
      await pumpEventQueue();

      expect(states, [
        const CategoriesLoading(),
        const CategoriesFailure(failure),
      ]);
      expect((cubit.state as CategoriesFailure).message, equals('تعذر الاتصال بالخادم'));
    });

    test('CategoriesFailure provides fallback message when serverMessage is null', () {
      const failure = Network();
      const state = CategoriesFailure(failure);

      expect(state.message, equals('فشل في تحميل التصنيفات'));
    });
  });
}
