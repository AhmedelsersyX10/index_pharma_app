import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'cart_state.dart';

/// Status result when an add-to-cart operation is attempted.
enum AddToCartStatus {
  success,
  branchConflict,
  outOfStock,
}

/// Result payload for [CartCubit.addToCart].
class AddToCartResult {
  const AddToCartResult({
    required this.status,
    this.currentBranchId,
    this.attemptedBranchId,
    this.clampedQuantity,
    this.wasCapped = false,
  });

  final AddToCartStatus status;
  final String? currentBranchId;
  final String? attemptedBranchId;
  final int? clampedQuantity;
  final bool wasCapped;

  bool get isSuccess => status == AddToCartStatus.success;
  bool get isBranchConflict => status == AddToCartStatus.branchConflict;
  bool get isOutOfStock => status == AddToCartStatus.outOfStock;
}

/// Manages customer shopping cart state, operations, and persistence.
///
/// Rules:
/// - Cart belongs strictly to ONE branch at a time.
/// - Minimum quantity per item is 1; maximum is capped at [Product.stockQuantity].
/// - Displays prices provided by server; totals are previews and not trusted by server.
/// - Persisted locally via [CartRepository].
class CartCubit extends Cubit<CartState> {
  CartCubit({
    required CartRepository cartRepository,
    StorageService? storageService,
  })  : _cartRepository = cartRepository,
        _storageService = storageService,
        super(const CartEmpty());

  final CartRepository _cartRepository;
  final StorageService? _storageService;

  /// Loads the persisted cart for [branchId] or the currently active branch.
  Future<void> loadCart({String? branchId}) async {
    final effectiveBranchId = branchId ??
        await _cartRepository.getActiveCartBranchId() ??
        _storageService?.selectedBranchId;

    if (effectiveBranchId == null || effectiveBranchId.trim().isEmpty) {
      emit(const CartEmpty());
      return;
    }

    final items = await _cartRepository.getCartItems(effectiveBranchId);
    if (items.isEmpty) {
      emit(CartEmpty(branchId: effectiveBranchId));
    } else {
      emit(_buildHasItemsState(
        branchId: effectiveBranchId,
        items: items,
      ));
    }
  }

  /// Adds a product to the cart with the requested [quantity].
  ///
  /// - Enforces single-branch scoping.
  /// - Clamps quantity to [Product.stockQuantity].
  /// - Emits [CartHasItems] and saves to storage on success.
  Future<AddToCartResult> addToCart(
    Product product, {
    int quantity = 1,
  }) async {
    if (product.stockQuantity <= 0) {
      return const AddToCartResult(status: AddToCartStatus.outOfStock);
    }

    final currentState = state;

    // Single-branch constraint check
    if (currentState is CartHasItems &&
        currentState.branchId != product.branchId) {
      return AddToCartResult(
        status: AddToCartStatus.branchConflict,
        currentBranchId: currentState.branchId,
        attemptedBranchId: product.branchId,
      );
    }

    final currentItems = currentState is CartHasItems
        ? List<CartItem>.from(currentState.items)
        : <CartItem>[];

    final existingIndex =
        currentItems.indexWhere((i) => i.product.id == product.id);

    int finalQuantity;
    bool wasCapped = false;

    if (existingIndex >= 0) {
      final existing = currentItems[existingIndex];
      final desired = existing.quantity + quantity;
      finalQuantity = desired.clamp(1, product.stockQuantity);
      wasCapped = desired > product.stockQuantity;
      currentItems[existingIndex] = existing.copyWith(
        product: product,
        quantity: finalQuantity,
      );
    } else {
      final desired = quantity < 1 ? 1 : quantity;
      finalQuantity = desired.clamp(1, product.stockQuantity);
      wasCapped = desired > product.stockQuantity;
      currentItems.add(CartItem(
        product: product,
        quantity: finalQuantity,
      ));
    }

    final newState = _buildHasItemsState(
      branchId: product.branchId,
      items: currentItems,
      stockAlertMessage: wasCapped ? product.name : null,
    );

    emit(newState);
    await _cartRepository.saveCartItems(product.branchId, currentItems);
    await _cartRepository.setActiveCartBranchId(product.branchId);

    return AddToCartResult(
      status: AddToCartStatus.success,
      clampedQuantity: finalQuantity,
      wasCapped: wasCapped,
    );
  }

  /// Changes the quantity of an existing cart item by [productId].
  ///
  /// - Minimum quantity: 1.
  /// - Maximum quantity: [Product.stockQuantity].
  /// - Clamps the quantity and notifies via alert if capped.
  Future<void> changeQuantity(String productId, int newQuantity) async {
    final currentState = state;
    if (currentState is! CartHasItems) return;

    final index = currentState.items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;

    final item = currentState.items[index];
    final maxStock = item.product.stockQuantity;
    final clamped = newQuantity.clamp(1, maxStock);
    final wasCapped = newQuantity > maxStock;

    if (clamped == item.quantity && !wasCapped) return;

    final updatedItems = List<CartItem>.from(currentState.items);
    updatedItems[index] = item.copyWith(quantity: clamped);

    final newState = _buildHasItemsState(
      branchId: currentState.branchId,
      items: updatedItems,
      stockAlertMessage: wasCapped ? item.product.name : null,
    );

    emit(newState);
    await _cartRepository.saveCartItems(currentState.branchId, updatedItems);
  }

  /// Removes an item from the cart by [productId].
  ///
  /// Emits [CartEmpty] if no items remain.
  Future<void> removeFromCart(String productId) async {
    final currentState = state;
    if (currentState is! CartHasItems) return;

    final updatedItems =
        currentState.items.where((i) => i.product.id != productId).toList();

    if (updatedItems.isEmpty) {
      await _cartRepository.clearCart(currentState.branchId);
      emit(CartEmpty(branchId: currentState.branchId));
    } else {
      final newState = _buildHasItemsState(
        branchId: currentState.branchId,
        items: updatedItems,
      );
      emit(newState);
      await _cartRepository.saveCartItems(currentState.branchId, updatedItems);
    }
  }

  /// Clears all cart items for the active branch and local storage.
  Future<void> clearCart() async {
    final currentState = state;
    if (currentState is CartHasItems) {
      await _cartRepository.clearCart(currentState.branchId);
      emit(CartEmpty(branchId: currentState.branchId));
    } else if (currentState is CartEmpty && currentState.branchId != null) {
      await _cartRepository.clearCart(currentState.branchId!);
      emit(CartEmpty(branchId: currentState.branchId));
    } else {
      final activeBranch = await _cartRepository.getActiveCartBranchId();
      if (activeBranch != null) {
        await _cartRepository.clearCart(activeBranch);
      }
      emit(const CartEmpty());
    }
  }

  /// Clears the existing cart from any prior branch and adds [product].
  ///
  /// Used when resolving a branch conflict.
  Future<AddToCartResult> clearAndAddToCart(
    Product product, {
    int quantity = 1,
  }) async {
    await clearCart();
    return addToCart(product, quantity: quantity);
  }

  /// Dismisses the active stock alert banner.
  void dismissStockAlert() {
    final currentState = state;
    if (currentState is CartHasItems && currentState.stockAlertMessage != null) {
      emit(currentState.copyWith(clearStockAlert: true));
    }
  }

  /// Syncs cart items against a list of fresh server [Product] models.
  ///
  /// - If a product's stock is 0 or it is no longer available online, it is removed from the cart.
  /// - If a product's stock is less than the current item quantity, the quantity is clamped to the new stock.
  /// - Updates the cart state and persists to storage.
  /// - Returns a list of names of items that were adjusted or removed.
  Future<List<String>> syncWithUpdatedProducts(
      List<Product> updatedProducts) async {
    final currentState = state;
    if (currentState is! CartHasItems) return [];

    final adjustedItemNames = <String>[];
    final updatedCartItems = <CartItem>[];

    final productMap = {for (final p in updatedProducts) p.id: p};

    for (final item in currentState.items) {
      final freshProduct = productMap[item.product.id];
      if (freshProduct == null) {
        updatedCartItems.add(item);
        continue;
      }

      if (freshProduct.stockQuantity <= 0) {
        adjustedItemNames.add(item.product.name);
        continue;
      }

      if (item.quantity > freshProduct.stockQuantity) {
        adjustedItemNames.add(item.product.name);
        updatedCartItems.add(item.copyWith(
          product: freshProduct,
          quantity: freshProduct.stockQuantity,
        ));
      } else {
        updatedCartItems.add(item.copyWith(product: freshProduct));
      }
    }

    if (updatedCartItems.isEmpty) {
      await _cartRepository.clearCart(currentState.branchId);
      emit(CartEmpty(branchId: currentState.branchId));
    } else {
      final newState = _buildHasItemsState(
        branchId: currentState.branchId,
        items: updatedCartItems,
        stockAlertMessage: adjustedItemNames.isNotEmpty
            ? adjustedItemNames.first
            : null,
      );
      emit(newState);
      await _cartRepository.saveCartItems(
          currentState.branchId, updatedCartItems);
    }

    return adjustedItemNames;
  }

  /// Checks if selecting [newBranchId] conflicts with the cart's existing branch.
  bool hasConflictWithBranch(String newBranchId) {
    final currentState = state;
    return currentState is CartHasItems && currentState.branchId != newBranchId;
  }

  /// Helper to calculate subtotal, quantities count, and Rx flag.
  CartHasItems _buildHasItemsState({
    required String branchId,
    required List<CartItem> items,
    String? stockAlertMessage,
  }) {
    double subtotal = 0.0;
    int totalUnits = 0;
    bool hasRx = false;

    for (final item in items) {
      subtotal += item.lineTotal;
      totalUnits += item.quantity;
      if (item.product.requiresPrescription) {
        hasRx = true;
      }
    }

    return CartHasItems(
      branchId: branchId,
      items: items,
      subtotal: subtotal,
      totalItemsCount: totalUnits,
      totalUniqueProducts: items.length,
      hasRxItems: hasRx,
      stockAlertMessage: stockAlertMessage,
    );
  }
}
