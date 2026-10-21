import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/errors/failure_mapper.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';
import '../../data/models/order_request_model.dart';
import '../../domain/repositories/checkout_repository.dart';
import 'checkout_state.dart';

/// Cubit managing checkout input validation, submission, stock conflict handling,
/// and cart synchronization.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required CheckoutRepository checkoutRepository,
    required CartCubit cartCubit,
    ProductsRepository? productsRepository,
    String initialAddress = '',
    String initialPhone = '',
    String initialNotes = '',
  })  : _checkoutRepository = checkoutRepository,
        _cartCubit = cartCubit,
        _productsRepository = productsRepository,
        super(CheckoutInitial(
          deliveryAddress: initialAddress,
          customerPhone: initialPhone,
          notes: initialNotes,
        ));

  final CheckoutRepository _checkoutRepository;
  final CartCubit _cartCubit;
  final ProductsRepository? _productsRepository;

  static final RegExp _egyptianPhoneRegex = RegExp(r'^01[0125][0-9]{8}$');

  /// Updates delivery address and clears previous validation errors if fixed.
  void updateAddress(String address) {
    final current = state;
    emit(CheckoutInitial(
      deliveryAddress: address,
      customerPhone: current.customerPhone,
      notes: current.notes,
      addressError: null,
      phoneError: current.phoneError,
    ));
  }

  /// Updates customer phone and clears previous validation errors if fixed.
  void updatePhone(String phone) {
    final current = state;
    emit(CheckoutInitial(
      deliveryAddress: current.deliveryAddress,
      customerPhone: phone,
      notes: current.notes,
      addressError: current.addressError,
      phoneError: null,
    ));
  }

  /// Updates optional notes.
  void updateNotes(String notes) {
    final current = state;
    emit(CheckoutInitial(
      deliveryAddress: current.deliveryAddress,
      customerPhone: current.customerPhone,
      notes: notes,
      addressError: current.addressError,
      phoneError: current.phoneError,
    ));
  }

  /// Resets from conflict/failure back to editable initial state.
  void resetToInitial() {
    emit(CheckoutInitial(
      deliveryAddress: state.deliveryAddress,
      customerPhone: state.customerPhone,
      notes: state.notes,
    ));
  }

  /// Validates address, Egyptian phone, and cart non-emptiness.
  ///
  /// Returns `true` if all inputs are valid.
  bool validate({required bool isCartEmpty}) {
    String? addressError;
    String? phoneError;

    final trimmedAddress = state.deliveryAddress.trim();
    if (trimmedAddress.isEmpty) {
      addressError = AppLocaleKeys.checkoutErrorAddressRequired.tr();
    } else if (trimmedAddress.length < 5) {
      addressError = AppLocaleKeys.checkoutErrorAddressTooShort.tr();
    }

    final trimmedPhone = state.customerPhone.trim();
    if (trimmedPhone.isEmpty) {
      phoneError = AppLocaleKeys.checkoutErrorPhoneRequired.tr();
    } else if (!_egyptianPhoneRegex.hasMatch(trimmedPhone)) {
      phoneError = AppLocaleKeys.checkoutErrorPhoneInvalid.tr();
    }

    if (addressError != null || phoneError != null) {
      emit(CheckoutInitial(
        deliveryAddress: state.deliveryAddress,
        customerPhone: state.customerPhone,
        notes: state.notes,
        addressError: addressError,
        phoneError: phoneError,
      ));
      return false;
    }

    if (isCartEmpty) {
      emit(CheckoutFailure(
        message: AppLocaleKeys.checkoutErrorEmptyCart.tr(),
        deliveryAddress: state.deliveryAddress,
        customerPhone: state.customerPhone,
        notes: state.notes,
      ));
      return false;
    }

    return true;
  }

  /// Submits the order to `POST /store/orders`.
  ///
  /// Flow:
  /// 1. Validates inputs and cart items.
  /// 2. Emits [CheckoutSubmitting].
  /// 3. On 201: clears the cart via [CartCubit.clearCart] and emits [CheckoutSuccess].
  /// 4. On 409/404: refreshes cart against server stock and emits [CheckoutConflict].
  /// 5. On other failure: emits [CheckoutFailure].
  Future<bool> submitOrder({
    required String branchId,
    required List<CartItem> cartItems,
  }) async {
    final isValid = validate(isCartEmpty: cartItems.isEmpty);
    if (!isValid) return false;

    final address = state.deliveryAddress.trim();
    final phone = state.customerPhone.trim();
    final notes = state.notes.trim();

    emit(CheckoutSubmitting(
      deliveryAddress: address,
      customerPhone: phone,
      notes: notes,
    ));

    final request = OrderRequestModel(
      branchId: branchId,
      orderItems: cartItems
          .map((item) => OrderItemRequestModel(
                productId: item.product.id,
                quantity: item.quantity,
              ))
          .toList(),
      deliveryAddress: address,
      customerPhone: phone,
      notes: notes.isNotEmpty ? notes : null,
    );

    final result = await _checkoutRepository.createOrder(request);

    switch (result) {
      case Success(:final data):
        // Rule 5: Clear the cart only after a successful 201.
        await _cartCubit.clearCart();
        emit(CheckoutSuccess(
          order: data,
          deliveryAddress: address,
          customerPhone: phone,
          notes: notes,
        ));
        return true;

      case Err(:final failure):
        if (failure is Conflict || failure is NotFound) {
          // Rule 4: On 409/404, refresh product data and the cart
          final adjustedNames = await _refreshCartAgainstServer(
            branchId: branchId,
            items: cartItems,
          );

          final serverMsg = failure.serverMessage;
          final conflictMessage = (serverMsg != null && serverMsg.trim().isNotEmpty)
              ? serverMsg.trim()
              : (failure is NotFound
                  ? AppLocaleKeys.checkoutConflictItemUnavailable.tr()
                  : AppLocaleKeys.checkoutConflictStockChanged.tr());

          emit(CheckoutConflict(
            message: conflictMessage,
            adjustedItems: adjustedNames,
            deliveryAddress: address,
            customerPhone: phone,
            notes: notes,
          ));
          return false;
        }

        final errorMsg = FailureMapper.toMessage(
          failure,
          defaultFallback: AppLocaleKeys.checkoutErrorSubmitFailed.tr(),
        );

        emit(CheckoutFailure(
          message: errorMsg,
          deliveryAddress: address,
          customerPhone: phone,
          notes: notes,
        ));
        return false;
    }
  }

  /// Helper to refresh server product info for items in cart on stock conflict.
  Future<List<String>> _refreshCartAgainstServer({
    required String branchId,
    required List<CartItem> items,
  }) async {
    if (_productsRepository == null) return [];

    final freshProducts = <Product>[];

    for (final item in items) {
      final res = await _productsRepository.getProductDetails(
        productId: item.product.id,
        branchId: branchId,
      );
      if (res is Success<Product>) {
        freshProducts.add(res.data);
      }
    }

    if (freshProducts.isNotEmpty) {
      return await _cartCubit.syncWithUpdatedProducts(freshProducts);
    }
    return [];
  }
}
