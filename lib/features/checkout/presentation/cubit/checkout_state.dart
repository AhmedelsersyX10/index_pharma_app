import '../../domain/entities/order.dart';

/// Base class representing state of the checkout flow.
sealed class CheckoutState {
  const CheckoutState({
    this.deliveryAddress = '',
    this.customerPhone = '',
    this.notes = '',
    this.addressError,
    this.phoneError,
  });

  final String deliveryAddress;
  final String customerPhone;
  final String notes;
  final String? addressError;
  final String? phoneError;

  bool get hasValidationErrors => addressError != null || phoneError != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutState &&
          runtimeType == other.runtimeType &&
          deliveryAddress == other.deliveryAddress &&
          customerPhone == other.customerPhone &&
          notes == other.notes &&
          addressError == other.addressError &&
          phoneError == other.phoneError;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        deliveryAddress,
        customerPhone,
        notes,
        addressError,
        phoneError,
      );
}

/// Initial or editing form state.
class CheckoutInitial extends CheckoutState {
  const CheckoutInitial({
    super.deliveryAddress = '',
    super.customerPhone = '',
    super.notes = '',
    super.addressError,
    super.phoneError,
  });

  CheckoutInitial copyWith({
    String? deliveryAddress,
    String? customerPhone,
    String? notes,
    String? addressError,
    bool clearAddressError = false,
    String? phoneError,
    bool clearPhoneError = false,
  }) {
    return CheckoutInitial(
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      addressError: clearAddressError ? null : (addressError ?? this.addressError),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
    );
  }
}

/// Order creation request in progress.
class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting({
    required super.deliveryAddress,
    required super.customerPhone,
    super.notes = '',
  });
}

/// Order placed successfully (HTTP 201).
class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess({
    required this.order,
    required super.deliveryAddress,
    required super.customerPhone,
    super.notes = '',
  });

  final Order order;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutSuccess &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          deliveryAddress == other.deliveryAddress &&
          customerPhone == other.customerPhone &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        order,
        deliveryAddress,
        customerPhone,
        notes,
      );
}

/// Stock conflict (HTTP 409) or product unavailable (HTTP 404).
class CheckoutConflict extends CheckoutState {
  const CheckoutConflict({
    required this.message,
    this.adjustedItems = const [],
    required super.deliveryAddress,
    required super.customerPhone,
    super.notes = '',
  });

  final String message;
  final List<String> adjustedItems;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutConflict &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          deliveryAddress == other.deliveryAddress &&
          customerPhone == other.customerPhone &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        message,
        deliveryAddress,
        customerPhone,
        notes,
      );
}

/// Generic error / validation failure / unauthorized.
class CheckoutFailure extends CheckoutState {
  const CheckoutFailure({
    required this.message,
    required super.deliveryAddress,
    required super.customerPhone,
    super.notes = '',
  });

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutFailure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          deliveryAddress == other.deliveryAddress &&
          customerPhone == other.customerPhone &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        message,
        deliveryAddress,
        customerPhone,
        notes,
      );
}
