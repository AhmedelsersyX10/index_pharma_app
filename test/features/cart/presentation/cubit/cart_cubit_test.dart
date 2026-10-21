import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_state.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';

class FakeCartRepository implements CartRepository {
  final Map<String, List<CartItem>> storage = {};
  String? activeBranchId;
  int saveCount = 0;
  int clearCount = 0;

  @override
  Future<List<CartItem>> getCartItems(String branchId) async {
    return storage[branchId] ?? [];
  }

  @override
  Future<void> saveCartItems(String branchId, List<CartItem> items) async {
    saveCount++;
    storage[branchId] = List<CartItem>.from(items);
    activeBranchId = branchId;
  }

  @override
  Future<void> clearCart(String branchId) async {
    clearCount++;
    storage.remove(branchId);
    if (activeBranchId == branchId) {
      activeBranchId = null;
    }
  }

  @override
  Future<String?> getActiveCartBranchId() async {
    return activeBranchId;
  }

  @override
  Future<void> setActiveCartBranchId(String? branchId) async {
    activeBranchId = branchId;
  }
}

void main() {
  late FakeCartRepository fakeRepository;
  late CartCubit cubit;

  const sampleProductA = Product(
    id: 'prod-1',
    name: 'Augmentin 1g',
    scientificName: 'Amoxicillin',
    sellingPrice: 99.0,
    stockQuantity: 5,
    requiresPrescription: true,
    branchId: 'branch-cairo',
  );

  const sampleProductB = Product(
    id: 'prod-2',
    name: 'Panadol Extra',
    scientificName: 'Paracetamol',
    sellingPrice: 45.0,
    stockQuantity: 10,
    requiresPrescription: false,
    branchId: 'branch-cairo',
  );

  const sampleProductDifferentBranch = Product(
    id: 'prod-3',
    name: 'Concor COR 2.5mg',
    sellingPrice: 42.5,
    stockQuantity: 2,
    branchId: 'branch-alex',
  );

  const outOfStockProduct = Product(
    id: 'prod-out',
    name: 'Out of Stock Med',
    sellingPrice: 20.0,
    stockQuantity: 0,
    branchId: 'branch-cairo',
  );

  setUp(() {
    fakeRepository = FakeCartRepository();
    cubit = CartCubit(cartRepository: fakeRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('CartCubit initialization & loading', () {
    test('initial state is CartEmpty', () {
      expect(cubit.state, equals(const CartEmpty()));
    });

    test('loadCart with empty repository emits CartEmpty', () async {
      await cubit.loadCart(branchId: 'branch-cairo');
      expect(cubit.state, equals(const CartEmpty(branchId: 'branch-cairo')));
    });

    test('loadCart with persisted items emits CartHasItems', () async {
      fakeRepository.storage['branch-cairo'] = [
        const CartItem(product: sampleProductA, quantity: 2),
      ];
      fakeRepository.activeBranchId = 'branch-cairo';

      await cubit.loadCart();

      expect(cubit.state, isA<CartHasItems>());
      final state = cubit.state as CartHasItems;
      expect(state.branchId, equals('branch-cairo'));
      expect(state.items.length, equals(1));
      expect(state.totalItemsCount, equals(2));
      expect(state.totalUniqueProducts, equals(1));
      expect(state.subtotal, equals(198.0));
      expect(state.hasRxItems, isTrue);
    });
  });

  group('CartCubit addToCart', () {
    test('returns outOfStock when stockQuantity is <= 0', () async {
      final result = await cubit.addToCart(outOfStockProduct);

      expect(result.isOutOfStock, isTrue);
      expect(cubit.state, equals(const CartEmpty()));
    });

    test('adds new item, persists, and computes totals correctly', () async {
      final result = await cubit.addToCart(sampleProductA, quantity: 1);

      expect(result.isSuccess, isTrue);
      expect(result.clampedQuantity, equals(1));
      expect(result.wasCapped, isFalse);

      expect(cubit.state, isA<CartHasItems>());
      final state = cubit.state as CartHasItems;
      expect(state.branchId, equals('branch-cairo'));
      expect(state.items.length, equals(1));
      expect(state.subtotal, equals(99.0));
      expect(state.hasRxItems, isTrue);
      expect(fakeRepository.storage['branch-cairo']?.length, equals(1));
    });

    test('clamps requested quantity to available stock', () async {
      // sampleProductA stock is 5
      final result = await cubit.addToCart(sampleProductA, quantity: 10);

      expect(result.isSuccess, isTrue);
      expect(result.clampedQuantity, equals(5));
      expect(result.wasCapped, isTrue);

      final state = cubit.state as CartHasItems;
      expect(state.items.first.quantity, equals(5));
      expect(state.stockAlertMessage, equals(sampleProductA.name));
    });

    test('increments existing item quantity and clamps to stock', () async {
      await cubit.addToCart(sampleProductA, quantity: 2);
      final result = await cubit.addToCart(sampleProductA, quantity: 4);

      // 2 + 4 = 6, stock is 5 -> clamped to 5
      expect(result.clampedQuantity, equals(5));
      expect(result.wasCapped, isTrue);

      final state = cubit.state as CartHasItems;
      expect(state.items.length, equals(1));
      expect(state.items.first.quantity, equals(5));
    });

    test('rejects item from different branch with branchConflict', () async {
      await cubit.addToCart(sampleProductA, quantity: 1);

      final result = await cubit.addToCart(sampleProductDifferentBranch, quantity: 1);

      expect(result.isBranchConflict, isTrue);
      expect(result.currentBranchId, equals('branch-cairo'));
      expect(result.attemptedBranchId, equals('branch-alex'));

      // Cart state unchanged
      final state = cubit.state as CartHasItems;
      expect(state.branchId, equals('branch-cairo'));
      expect(state.items.length, equals(1));
    });
  });

  group('CartCubit changeQuantity', () {
    test('updates quantity within stock bounds', () async {
      await cubit.addToCart(sampleProductA, quantity: 1);

      await cubit.changeQuantity('prod-1', 3);

      final state = cubit.state as CartHasItems;
      expect(state.items.first.quantity, equals(3));
      expect(state.subtotal, equals(297.0));
      expect(state.totalItemsCount, equals(3));
    });

    test('clamps to minimum quantity 1', () async {
      await cubit.addToCart(sampleProductA, quantity: 2);

      await cubit.changeQuantity('prod-1', 0);

      final state = cubit.state as CartHasItems;
      expect(state.items.first.quantity, equals(1));
    });

    test('clamps to maximum stock and sets stock alert', () async {
      await cubit.addToCart(sampleProductA, quantity: 1);

      await cubit.changeQuantity('prod-1', 99);

      final state = cubit.state as CartHasItems;
      expect(state.items.first.quantity, equals(sampleProductA.stockQuantity));
      expect(state.stockAlertMessage, equals(sampleProductA.name));
    });
  });

  group('CartCubit removeFromCart & clearCart', () {
    test('removes item and recalculates subtotal', () async {
      await cubit.addToCart(sampleProductA, quantity: 1); // 99.0
      await cubit.addToCart(sampleProductB, quantity: 2); // 90.0

      var state = cubit.state as CartHasItems;
      expect(state.items.length, equals(2));
      expect(state.subtotal, equals(189.0));

      await cubit.removeFromCart('prod-1');

      state = cubit.state as CartHasItems;
      expect(state.items.length, equals(1));
      expect(state.items.first.product.id, equals('prod-2'));
      expect(state.subtotal, equals(90.0));
      expect(state.hasRxItems, isFalse);
    });

    test('emits CartEmpty when last item is removed', () async {
      await cubit.addToCart(sampleProductA, quantity: 1);

      await cubit.removeFromCart('prod-1');

      expect(cubit.state, equals(const CartEmpty(branchId: 'branch-cairo')));
      expect(fakeRepository.storage['branch-cairo'], isNull);
    });

    test('clearCart empties the cart and storage', () async {
      await cubit.addToCart(sampleProductA, quantity: 1);
      await cubit.addToCart(sampleProductB, quantity: 1);

      await cubit.clearCart();

      expect(cubit.state, equals(const CartEmpty(branchId: 'branch-cairo')));
      expect(fakeRepository.storage['branch-cairo'], isNull);
    });

    test('dismissStockAlert clears stockAlertMessage', () async {
      await cubit.addToCart(sampleProductA, quantity: 99); // triggers alert
      expect((cubit.state as CartHasItems).stockAlertMessage, isNotNull);

      cubit.dismissStockAlert();

      expect((cubit.state as CartHasItems).stockAlertMessage, isNull);
    });
  });

  group('CartCubit hasConflictWithBranch', () {
    test('returns false when cart is empty', () {
      expect(cubit.hasConflictWithBranch('branch-alex'), isFalse);
    });

    test('returns false when cart has items for same branch', () async {
      await cubit.addToCart(sampleProductA, quantity: 1);
      expect(cubit.hasConflictWithBranch('branch-cairo'), isFalse);
    });

    test('returns true when cart has items for another branch', () async {
      await cubit.addToCart(sampleProductA, quantity: 1);
      expect(cubit.hasConflictWithBranch('branch-alex'), isTrue);
    });
  });

  group('CartCubit syncWithUpdatedProducts', () {
    test('clamps quantity when fresh server product stock is lower than in-cart quantity', () async {
      // sampleProductA has quantity 4 in cart
      await cubit.addToCart(sampleProductA, quantity: 4);

      // Server stock is now 2
      final updatedProduct = sampleProductA.copyWith(stockQuantity: 2);
      final adjusted = await cubit.syncWithUpdatedProducts([updatedProduct]);

      expect(adjusted, contains(sampleProductA.name));
      final state = cubit.state as CartHasItems;
      expect(state.items.first.quantity, equals(2));
      expect(state.stockAlertMessage, equals(sampleProductA.name));
      expect(fakeRepository.storage['branch-cairo']?.first.quantity, equals(2));
    });

    test('removes item when fresh server product stock is 0 or less', () async {
      await cubit.addToCart(sampleProductA, quantity: 2);
      await cubit.addToCart(sampleProductB, quantity: 1);

      // sampleProductA is now out of stock (0)
      final updatedProductA = sampleProductA.copyWith(stockQuantity: 0);
      final adjusted = await cubit.syncWithUpdatedProducts([updatedProductA]);

      expect(adjusted, contains(sampleProductA.name));
      final state = cubit.state as CartHasItems;
      expect(state.items.length, equals(1));
      expect(state.items.first.product.id, equals(sampleProductB.id));
      expect(state.subtotal, equals(sampleProductB.sellingPrice));
    });

    test('emits CartEmpty and clears storage when all items drop to 0 stock', () async {
      await cubit.addToCart(sampleProductA, quantity: 1);

      final updatedProductA = sampleProductA.copyWith(stockQuantity: 0);
      final adjusted = await cubit.syncWithUpdatedProducts([updatedProductA]);

      expect(adjusted, contains(sampleProductA.name));
      expect(cubit.state, equals(const CartEmpty(branchId: 'branch-cairo')));
      expect(fakeRepository.storage['branch-cairo'], isNull);
    });

    test('retains in-cart items when not included in updatedProducts list', () async {
      await cubit.addToCart(sampleProductA, quantity: 2);
      await cubit.addToCart(sampleProductB, quantity: 3);

      // Only sampleProductA is in the updated list
      final updatedProductA = sampleProductA.copyWith(stockQuantity: 2);
      final adjusted = await cubit.syncWithUpdatedProducts([updatedProductA]);

      expect(adjusted, isEmpty);
      final state = cubit.state as CartHasItems;
      expect(state.items.length, equals(2));
      expect(state.items[0].quantity, equals(2));
      expect(state.items[1].quantity, equals(3));
    });
  });
}
