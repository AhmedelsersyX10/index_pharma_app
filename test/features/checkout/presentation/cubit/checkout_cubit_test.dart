import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_state.dart';
import 'package:index_pharma/features/checkout/data/models/order_request_model.dart';
import 'package:index_pharma/features/checkout/domain/entities/order.dart';
import 'package:index_pharma/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:index_pharma/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:index_pharma/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/domain/entities/products_page.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';

class FakeCheckoutRepository implements CheckoutRepository {
  ApiResult<Order>? resultToReturn;
  OrderRequestModel? lastRequest;

  @override
  Future<ApiResult<Order>> createOrder(OrderRequestModel request) async {
    lastRequest = request;
    return resultToReturn!;
  }
}

class FakeCartRepository implements CartRepository {
  final Map<String, List<CartItem>> storage = {};
  String? activeBranchId;
  int clearCount = 0;

  @override
  Future<List<CartItem>> getCartItems(String branchId) async =>
      storage[branchId] ?? [];

  @override
  Future<void> saveCartItems(String branchId, List<CartItem> items) async {
    storage[branchId] = List<CartItem>.from(items);
    activeBranchId = branchId;
  }

  @override
  Future<void> clearCart(String branchId) async {
    clearCount++;
    storage.remove(branchId);
  }

  @override
  Future<String?> getActiveCartBranchId() async => activeBranchId;

  @override
  Future<void> setActiveCartBranchId(String? branchId) async =>
      activeBranchId = branchId;
}

class FakeProductsRepository implements ProductsRepository {
  final Map<String, Product> productDetails = {};

  @override
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async {
    return const Success(ProductsPage(
      total: 0,
      totalPages: 0,
      page: 1,
      limit: 20,
      products: [],
    ));
  }

  @override
  Future<ApiResult<Product>> getProductDetails({
    required String productId,
    required String branchId,
  }) async {
    final prod = productDetails[productId];
    if (prod != null) {
      return Success(prod);
    }
    return const Err(NotFound(serverMessage: 'Not found'));
  }
}

void main() {
  late FakeCheckoutRepository fakeCheckoutRepo;
  late FakeCartRepository fakeCartRepo;
  late FakeProductsRepository fakeProductsRepo;
  late CartCubit cartCubit;
  late CheckoutCubit checkoutCubit;

  const sampleProduct = Product(
    id: 'p1',
    name: 'Hydrating Cream 50ml',
    sellingPrice: 130,
    stockQuantity: 30,
    branchId: 'b1',
  );

  final sampleOrder = Order(
    id: 'ord-1',
    orderNumber: 'ONL-001',
    customerId: 'c-1',
    branchId: 'b1',
    subtotal: 260,
    totalAmount: 260,
    paidAmount: 0,
    dueAmount: 260,
    changeAmount: 0,
    orderType: 'ONLINE',
    status: 'pending',
    paymentMethod: 'cash',
    deliveryAddress: 'Nasr City, Building 4',
    customerPhone: '01012345678',
    createdAt: DateTime.now(),
    items: const [],
  );

  setUp(() async {
    fakeCheckoutRepo = FakeCheckoutRepository();
    fakeCartRepo = FakeCartRepository();
    fakeProductsRepo = FakeProductsRepository();
    cartCubit = CartCubit(cartRepository: fakeCartRepo);
    checkoutCubit = CheckoutCubit(
      checkoutRepository: fakeCheckoutRepo,
      cartCubit: cartCubit,
      productsRepository: fakeProductsRepo,
      initialAddress: 'Nasr City, Building 4',
      initialPhone: '01012345678',
    );

    // Pre-populate cart with 2 of sampleProduct
    await cartCubit.addToCart(sampleProduct, quantity: 2);
  });

  tearDown(() {
    cartCubit.close();
    checkoutCubit.close();
  });

  group('Checkout Validation', () {
    test('validate returns false and sets addressError if address is empty', () {
      checkoutCubit.updateAddress('');
      final isValid = checkoutCubit.validate(isCartEmpty: false);

      expect(isValid, isFalse);
      expect(checkoutCubit.state.addressError, isNotNull);
    });

    test('validate returns false and sets addressError if address is under 5 chars', () {
      checkoutCubit.updateAddress('ش 1');
      final isValid = checkoutCubit.validate(isCartEmpty: false);

      expect(isValid, isFalse);
      expect(checkoutCubit.state.addressError, isNotNull);
    });

    test('validate returns false and sets phoneError for invalid Egyptian phone', () {
      checkoutCubit.updatePhone('010123'); // too short
      final isValid = checkoutCubit.validate(isCartEmpty: false);

      expect(isValid, isFalse);
      expect(checkoutCubit.state.phoneError, isNotNull);

      checkoutCubit.updatePhone('01312345678'); // invalid prefix 013
      final isValid2 = checkoutCubit.validate(isCartEmpty: false);

      expect(isValid2, isFalse);
      expect(checkoutCubit.state.phoneError, isNotNull);
    });

    test('validate accepts valid 11-digit Egyptian phone (010, 011, 012, 015)', () {
      checkoutCubit.updateAddress('Nasr City, Building 4');
      checkoutCubit.updatePhone('01012345678');
      final isValid = checkoutCubit.validate(isCartEmpty: false);

      expect(isValid, isTrue);
      expect(checkoutCubit.state.addressError, isNull);
      expect(checkoutCubit.state.phoneError, isNull);
    });

    test('validate returns false and emits CheckoutFailure if cart is empty', () {
      checkoutCubit.updateAddress('Nasr City, Building 4');
      checkoutCubit.updatePhone('01012345678');
      final isValid = checkoutCubit.validate(isCartEmpty: true);

      expect(isValid, isFalse);
      expect(checkoutCubit.state, isA<CheckoutFailure>());
    });
  });

  group('Order Submission & Lifecycle', () {
    test('submits order successfully (201), clears cart, and emits CheckoutSuccess', () async {
      fakeCheckoutRepo.resultToReturn = Success(sampleOrder);

      final cartItems = (cartCubit.state as CartHasItems).items;
      final success = await checkoutCubit.submitOrder(
        branchId: 'b1',
        cartItems: cartItems,
      );

      expect(success, isTrue);
      expect(checkoutCubit.state, isA<CheckoutSuccess>());
      final successState = checkoutCubit.state as CheckoutSuccess;
      expect(successState.order.orderNumber, 'ONL-001');

      // Rule 5: Cart cleared only after successful 201
      expect(cartCubit.state, isA<CartEmpty>());
      expect(fakeCartRepo.clearCount, 1);
    });

    test('on 409 Conflict: updates cart with fresh server stock, keeps cart, and emits CheckoutConflict', () async {
      fakeCheckoutRepo.resultToReturn = const Err(
        Conflict(serverMessage: 'الكمية المتاحة من Hydrating Cream 50ml هي 1 فقط'),
      );

      // Server now reports stock decreased to 1
      fakeProductsRepo.productDetails['p1'] = const Product(
        id: 'p1',
        name: 'Hydrating Cream 50ml',
        sellingPrice: 130,
        stockQuantity: 1, // down from 30
        branchId: 'b1',
      );

      final cartItems = (cartCubit.state as CartHasItems).items;
      final success = await checkoutCubit.submitOrder(
        branchId: 'b1',
        cartItems: cartItems,
      );

      expect(success, isFalse);
      expect(checkoutCubit.state, isA<CheckoutConflict>());
      final conflictState = checkoutCubit.state as CheckoutConflict;
      expect(conflictState.message, 'الكمية المتاحة من Hydrating Cream 50ml هي 1 فقط');
      expect(conflictState.adjustedItems, contains('Hydrating Cream 50ml'));

      // Cart is NOT cleared on 409
      expect(cartCubit.state, isA<CartHasItems>());
      final updatedCart = cartCubit.state as CartHasItems;
      // Clamped to 1
      expect(updatedCart.items.first.quantity, 1);
    });

    test('on 400 Bad Request: emits CheckoutFailure', () async {
      fakeCheckoutRepo.resultToReturn = const Err(
        Validation(serverMessage: 'السلة فارغة'),
      );

      final cartItems = (cartCubit.state as CartHasItems).items;
      final success = await checkoutCubit.submitOrder(
        branchId: 'b1',
        cartItems: cartItems,
      );

      expect(success, isFalse);
      expect(checkoutCubit.state, isA<CheckoutFailure>());
      expect((checkoutCubit.state as CheckoutFailure).message, 'السلة فارغة');
    });

    test('on 401 Unauthorized: emits CheckoutFailure with session message', () async {
      fakeCheckoutRepo.resultToReturn = const Err(
        Unauthorized(serverMessage: 'يرجى تسجيل الدخول'),
      );

      final cartItems = (cartCubit.state as CartHasItems).items;
      final success = await checkoutCubit.submitOrder(
        branchId: 'b1',
        cartItems: cartItems,
      );

      expect(success, isFalse);
      expect(checkoutCubit.state, isA<CheckoutFailure>());
    });
  });
}
