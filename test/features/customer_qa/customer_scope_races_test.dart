import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/domain/entities/products_page.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_cubit.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_state.dart';
import 'package:index_pharma/features/products/presentation/cubit/product_details_cubit.dart';
import 'package:index_pharma/features/products/presentation/cubit/product_details_state.dart';
import '../../helpers/pump_with_providers.dart';

class PendingProducts implements ProductsRepository {
  final pages = <Completer<ApiResult<ProductsPage>>>[];
  final details = <Completer<ApiResult<Product>>>[];
  @override
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) {
    final pending = Completer<ApiResult<ProductsPage>>();
    pages.add(pending);
    return pending.future;
  }

  @override
  Future<ApiResult<Product>> getProductDetails({
    required String productId,
    required String branchId,
  }) {
    final pending = Completer<ApiResult<Product>>();
    details.add(pending);
    return pending.future;
  }
}

const oldProduct = Product(
  id: 'old',
  name: 'Old',
  sellingPrice: 10,
  stockQuantity: 2,
  branchId: 'old',
);
const newProduct = Product(
  id: 'new',
  name: 'New',
  sellingPrice: 20,
  stockQuantity: 3,
  branchId: 'new',
);
ProductsPage page(Product product, {int number = 1}) => ProductsPage(
  total: 2,
  totalPages: 2,
  page: number,
  limit: 1,
  products: [product],
);

void main() {
  test(
    'late first-page response cannot replace products of the new branch',
    () async {
      final repository = PendingProducts();
      final cubit = ProductsCubit(productsRepository: repository);
      addTearDown(cubit.close);
      final old = cubit.loadFirstPage(branchId: 'old');
      final current = cubit.reloadForBranch('new');
      repository.pages[1].complete(Success(page(newProduct)));
      await current;
      repository.pages[0].complete(Success(page(oldProduct)));
      await old;
      expect((cubit.state as ProductsLoaded).branchId, 'new');
      expect((cubit.state as ProductsLoaded).products, [newProduct]);
    },
  );

  test('late pagination response cannot restore the previous branch', () async {
    final repository = PendingProducts();
    final cubit = ProductsCubit(productsRepository: repository);
    addTearDown(cubit.close);
    final first = cubit.loadFirstPage(branchId: 'old');
    repository.pages[0].complete(Success(page(oldProduct)));
    await first;
    final more = cubit.loadMore();
    final current = cubit.reloadForBranch('new');
    repository.pages[2].complete(Success(page(newProduct)));
    await current;
    repository.pages[1].complete(Success(page(oldProduct, number: 2)));
    await more;
    expect((cubit.state as ProductsLoaded).products, [newProduct]);
  });

  test(
    'clearing an invalid branch blocks old responses and stored-id fallback',
    () async {
      final repository = PendingProducts();
      final cubit = ProductsCubit(
        productsRepository: repository,
        storageService: FakeTestStorageService(selectedBranchId: 'old'),
      );
      addTearDown(cubit.close);
      final old = cubit.loadFirstPage(branchId: 'old');
      cubit.clearBranchScope();
      repository.pages[0].complete(Success(page(oldProduct)));
      await old;
      expect(cubit.state, isA<ProductsFailure>());
      await cubit.loadFirstPage();
      expect(repository.pages, hasLength(1));
      expect(cubit.currentBranchId, isNull);
    },
  );

  test(
    'product details ignore the old branch after switching or invalidating scope',
    () async {
      final repository = PendingProducts();
      final cubit = ProductDetailsCubit(productsRepository: repository);
      addTearDown(cubit.close);
      final old = cubit.loadProductDetails(productId: 'p', branchId: 'old');
      final current = cubit.loadProductDetails(productId: 'p', branchId: 'new');
      repository.details[1].complete(const Success(newProduct));
      await current;
      repository.details[0].complete(const Success(oldProduct));
      await old;
      expect((cubit.state as ProductDetailsLoaded).product, newProduct);
      final pending = cubit.loadProductDetails(productId: 'p', branchId: 'new');
      cubit.clearBranchScope();
      repository.details[2].complete(const Success(newProduct));
      await pending;
      expect(cubit.state, isA<ProductDetailsFailure>());
    },
  );
}
