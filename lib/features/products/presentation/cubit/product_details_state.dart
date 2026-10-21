import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/errors/failure_mapper.dart';
import '../../domain/entities/product.dart';

/// Sealed hierarchy representing UI states for product details.
sealed class ProductDetailsState {
  const ProductDetailsState();
}

/// Initial state before product details have been requested.
final class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductDetailsInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ProductDetailsInitial()';
}

/// Loading state emitted while product details are being retrieved.
final class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductDetailsLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ProductDetailsLoading()';
}

/// Loaded state containing verified [product] details from the server.
final class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded(this.product);

  final Product product;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductDetailsLoaded &&
          runtimeType == other.runtimeType &&
          product == other.product;

  @override
  int get hashCode => Object.hash(runtimeType, product);

  @override
  String toString() => 'ProductDetailsLoaded(product: ${product.name})';
}

/// Failure state wrapping a domain-level [failure].
final class ProductDetailsFailure extends ProductDetailsState {
  const ProductDetailsFailure(this.failure);

  final Failure failure;

  /// User-facing message mapped from domain failure.
  String get message => FailureMapper.toMessage(failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductDetailsFailure &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'ProductDetailsFailure(failure: $failure)';
}
