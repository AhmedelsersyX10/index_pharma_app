import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/domain/entities/products_page.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';
import 'package:index_pharma/features/products/presentation/cubit/product_details_cubit.dart';
import 'package:index_pharma/features/products/presentation/cubit/product_details_state.dart';

class FakeProductsRepository implements ProductsRepository {
  ApiResult<Product>? stubProductDetailsResult;
  String? lastProductId;
  String? lastBranchId;
  int callCount = 0;

  @override
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<Product>> getProductDetails({
    required String productId,
    required String branchId,
  }) async {
    callCount++;
    lastProductId = productId;
    lastBranchId = branchId;
    return stubProductDetailsResult!;
  }
}

class FakeStorageService implements StorageService {
  String? fakeSelectedBranchId;

  @override
  String? get selectedBranchId => fakeSelectedBranchId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeProductsRepository fakeRepository;
  late FakeStorageService fakeStorageService;
  late ProductDetailsCubit cubit;

  const testProduct = Product(
    id: 'p01f8a22-1118-4089-9e8c-669a6e118999',
    name: 'Hydrating Cream 50ml',
    scientificName: 'Hyaluronic Acid',
    barcode: '6221000000028',
    description: 'Daily moisturizing cream for dry and sensitive skin',
    sellingPrice: 130.0,
    stockQuantity: 30,
    requiresPrescription: false,
    branchId: 'b01',
  );

  setUp(() {
    fakeRepository = FakeProductsRepository();
    fakeStorageService = FakeStorageService();
    cubit = ProductDetailsCubit(
      productsRepository: fakeRepository,
      storageService: fakeStorageService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ProductDetailsCubit Tests', () {
    test('initial state is ProductDetailsInitial', () {
      expect(cubit.state, equals(const ProductDetailsInitial()));
    });

    test('emits [ProductDetailsLoading, ProductDetailsLoaded] on successful fetch', () async {
      fakeRepository.stubProductDetailsResult = const Success(testProduct);

      final expectedStates = [
        const ProductDetailsLoading(),
        const ProductDetailsLoaded(testProduct),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadProductDetails(
        productId: 'p01f8a22-1118-4089-9e8c-669a6e118999',
        branchId: 'b01',
      );

      expect(fakeRepository.lastProductId, equals('p01f8a22-1118-4089-9e8c-669a6e118999'));
      expect(fakeRepository.lastBranchId, equals('b01'));
      expect(fakeRepository.callCount, equals(1));
    });

    test('emits [ProductDetailsLoading, ProductDetailsFailure] on repository error', () async {
      fakeRepository.stubProductDetailsResult = const Err(
        NotFound(serverMessage: 'المنتج غير موجود'),
      );

      final expectedStates = [
        const ProductDetailsLoading(),
        const ProductDetailsFailure(
          NotFound(serverMessage: 'المنتج غير موجود'),
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadProductDetails(
        productId: 'p01',
        branchId: 'b01',
      );

      expect(cubit.state, isA<ProductDetailsFailure>());
      expect(
        (cubit.state as ProductDetailsFailure).message,
        equals(AppLocaleKeys.errorNotFound.tr()),
      );
    });

    test('emits ProductDetailsFailure immediately if branchId is empty and no stored branch', () async {
      fakeStorageService.fakeSelectedBranchId = null;

      await cubit.loadProductDetails(
        productId: 'p01',
        branchId: null,
      );

      expect(cubit.state, isA<ProductDetailsFailure>());
      expect((cubit.state as ProductDetailsFailure).failure, isA<Validation>());
      expect(fakeRepository.callCount, equals(0));
    });

    test('uses storageService.selectedBranchId when branchId argument is omitted', () async {
      fakeStorageService.fakeSelectedBranchId = 'stored-branch-123';
      fakeRepository.stubProductDetailsResult = const Success(testProduct);

      await cubit.loadProductDetails(
        productId: 'p01',
      );

      expect(fakeRepository.lastBranchId, equals('stored-branch-123'));
      expect(cubit.state, equals(const ProductDetailsLoaded(testProduct)));
    });

    test('retry re-fetches product details with saved parameters', () async {
      fakeRepository.stubProductDetailsResult = const Err(
        Network(serverMessage: 'انقطع الاتصال'),
      );

      await cubit.loadProductDetails(
        productId: 'p01',
        branchId: 'b01',
      );

      expect(cubit.state, isA<ProductDetailsFailure>());
      expect(fakeRepository.callCount, equals(1));

      fakeRepository.stubProductDetailsResult = const Success(testProduct);
      await cubit.retry();

      expect(fakeRepository.callCount, equals(2));
      expect(cubit.state, equals(const ProductDetailsLoaded(testProduct)));
    });
  });
}
