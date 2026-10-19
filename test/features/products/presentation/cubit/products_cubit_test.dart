import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/domain/entities/products_page.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_cubit.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_state.dart';

class FakeProductsRepository implements ProductsRepository {
  ApiResult<ProductsPage>? stubResult;
  int callCount = 0;
  String? lastBranchId;
  int? lastPage;
  int? lastLimit;
  String? lastKeyword;
  String? lastCategory;

  @override
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async {
    callCount++;
    lastBranchId = branchId;
    lastPage = page;
    lastLimit = limit;
    lastKeyword = keyword;
    lastCategory = category;
    return stubResult!;
  }
}

void main() {
  late FakeProductsRepository fakeRepository;
  late ProductsCubit cubit;

  const testProduct1 = Product(
    id: 'p01',
    name: 'Hydrating Cream 50ml',
    scientificName: 'Hyaluronic Acid',
    barcode: '6221000000028',
    sellingPrice: 130.0,
    stockQuantity: 30,
    looseQuantity: 0,
    requiresPrescription: false,
    category: Category(id: 'c01', name: 'Skincare'),
    branchId: 'b01',
  );

  const testProduct2 = Product(
    id: 'p02',
    name: 'Augmentin 1g',
    scientificName: 'Amoxicillin + Clavulanic Acid',
    barcode: '622147002341',
    sellingPrice: 99.0,
    stockQuantity: 12,
    looseQuantity: 0,
    requiresPrescription: true,
    category: Category(id: 'c02', name: 'Antibiotics'),
    branchId: 'b01',
  );

  setUp(() {
    fakeRepository = FakeProductsRepository();
    cubit = ProductsCubit(
      productsRepository: fakeRepository,
      pageSize: 2,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ProductsCubit Tests', () {
    test('initial state is ProductsInitial', () {
      expect(cubit.state, equals(const ProductsInitial()));
    });

    test(
        'loadFirstPage emits [ProductsLoading, ProductsLoaded] on successful non-empty response',
        () async {
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 2,
          totalPages: 1,
          page: 1,
          limit: 2,
          products: [testProduct1, testProduct2],
        ),
      );

      final states = <ProductsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadFirstPage(branchId: 'b01');
      await pumpEventQueue();

      expect(states.length, equals(2));
      expect(states[0], equals(const ProductsLoading()));
      expect(states[1], isA<ProductsLoaded>());

      final loaded = states[1] as ProductsLoaded;
      expect(loaded.products.length, equals(2));
      expect(loaded.total, equals(2));
      expect(loaded.page, equals(1));
      expect(loaded.hasReachedMax, isTrue);
      expect(loaded.branchId, equals('b01'));
    });

    test(
        'loadFirstPage emits [ProductsLoading, ProductsEmpty] on empty products response',
        () async {
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 0,
          totalPages: 0,
          page: 1,
          limit: 2,
          products: [],
        ),
      );

      final states = <ProductsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadFirstPage(branchId: 'b01');
      await pumpEventQueue();

      expect(states, [
        const ProductsLoading(),
        const ProductsEmpty(branchId: 'b01'),
      ]);
      expect(cubit.state, equals(const ProductsEmpty(branchId: 'b01')));
    });

    test(
        'loadFirstPage emits [ProductsLoading, ProductsFailure] on repository failure',
        () async {
      const failure = Server(serverMessage: 'خطأ في السيرفر');
      fakeRepository.stubResult = const Err(failure);

      final states = <ProductsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadFirstPage(branchId: 'b01');
      await pumpEventQueue();

      expect(states, [
        const ProductsLoading(),
        const ProductsFailure(failure, branchId: 'b01'),
      ]);
      expect((cubit.state as ProductsFailure).message, equals('خطأ في السيرفر'));
    });

    test('loadFirstPage emits ProductsFailure if branchId is empty', () async {
      final states = <ProductsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadFirstPage(branchId: '');
      await pumpEventQueue();

      expect(states.length, equals(1));
      expect(states[0], isA<ProductsFailure>());
      expect((states[0] as ProductsFailure).message,
          equals('يرجى اختيار الفرع لعرض مخزون المتجر'));
    });

    test('loadMore appends subsequent page products when hasReachedMax is false',
        () async {
      // First page with totalPages = 2
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 3,
          totalPages: 2,
          page: 1,
          limit: 2,
          products: [testProduct1],
        ),
      );

      await cubit.loadFirstPage(branchId: 'b01');
      expect((cubit.state as ProductsLoaded).hasReachedMax, isFalse);

      // Second page
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 3,
          totalPages: 2,
          page: 2,
          limit: 2,
          products: [testProduct2],
        ),
      );

      await cubit.loadMore();
      await pumpEventQueue();

      final state = cubit.state as ProductsLoaded;
      expect(state.products.length, equals(2));
      expect(state.page, equals(2));
      expect(state.hasReachedMax, isTrue);
      expect(state.isLoadingMore, isFalse);
    });

    test('loadMore stops at last page and does not call repository', () async {
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 1,
          totalPages: 1,
          page: 1,
          limit: 2,
          products: [testProduct1],
        ),
      );

      await cubit.loadFirstPage(branchId: 'b01');
      expect((cubit.state as ProductsLoaded).hasReachedMax, isTrue);

      final countBefore = fakeRepository.callCount;
      await cubit.loadMore();
      await pumpEventQueue();

      // No additional repository call was made
      expect(fakeRepository.callCount, equals(countBefore));
    });

    test(
        'loadMore preserves existing products and sets loadingMoreError on failure',
        () async {
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 3,
          totalPages: 2,
          page: 1,
          limit: 2,
          products: [testProduct1],
        ),
      );

      await cubit.loadFirstPage(branchId: 'b01');

      const failure = Network();
      fakeRepository.stubResult = const Err(failure);

      await cubit.loadMore();
      await pumpEventQueue();

      final state = cubit.state as ProductsLoaded;
      expect(state.products.length, equals(1));
      expect(state.products.first.id, equals('p01'));
      expect(state.loadingMoreError, equals(failure));
      expect(state.isLoadingMore, isFalse);
    });

    test('onKeywordChanged debounces and triggers search', () async {
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 1,
          totalPages: 1,
          page: 1,
          limit: 2,
          products: [testProduct1],
        ),
      );

      await cubit.loadFirstPage(branchId: 'b01');
      final initialCalls = fakeRepository.callCount;

      cubit.onKeywordChanged('Hydrating',
          debounceDuration: const Duration(milliseconds: 50));

      // Before timer fires
      expect(fakeRepository.callCount, equals(initialCalls));

      // After timer fires
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await pumpEventQueue();

      expect(fakeRepository.callCount, equals(initialCalls + 1));
      expect(fakeRepository.lastKeyword, equals('Hydrating'));
    });

    test('onCategoryChanged filters and toggles category', () async {
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 1,
          totalPages: 1,
          page: 1,
          limit: 2,
          products: [testProduct1],
        ),
      );

      await cubit.loadFirstPage(branchId: 'b01');

      // Select category
      await cubit.onCategoryChanged('c01');
      await pumpEventQueue();
      expect(fakeRepository.lastCategory, equals('c01'));
      expect(cubit.currentCategory, equals('c01'));

      // Tapping same category toggles off
      await cubit.onCategoryChanged('c01');
      await pumpEventQueue();
      expect(fakeRepository.lastCategory, isNull);
      expect(cubit.currentCategory, isNull);
    });

    test('reloadForBranch switches branch and reloads first page', () async {
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 1,
          totalPages: 1,
          page: 1,
          limit: 2,
          products: [testProduct1],
        ),
      );

      await cubit.loadFirstPage(branchId: 'b01');
      expect(fakeRepository.lastBranchId, equals('b01'));

      await cubit.reloadForBranch('b02');
      await pumpEventQueue();

      expect(fakeRepository.lastBranchId, equals('b02'));
      expect(cubit.currentBranchId, equals('b02'));
    });

    test('retry calls loadMore when loadingMoreError is set', () async {
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 3,
          totalPages: 2,
          page: 1,
          limit: 2,
          products: [testProduct1],
        ),
      );

      await cubit.loadFirstPage(branchId: 'b01');

      // Induce loadMore error
      const failure = Network();
      fakeRepository.stubResult = const Err(failure);
      await cubit.loadMore();

      expect(
          (cubit.state as ProductsLoaded).loadingMoreError, equals(failure));

      // Provide success for retry
      fakeRepository.stubResult = const Success(
        ProductsPage(
          total: 3,
          totalPages: 2,
          page: 2,
          limit: 2,
          products: [testProduct2],
        ),
      );

      await cubit.retry();
      await pumpEventQueue();

      final state = cubit.state as ProductsLoaded;
      expect(state.products.length, equals(2));
      expect(state.loadingMoreError, isNull);
    });
  });
}
