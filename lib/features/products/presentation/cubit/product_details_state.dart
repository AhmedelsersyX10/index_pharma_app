import 'package:index_pharma/core/errors/failure.dart';
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

  /// User-facing message derived from serverMessage or default Arabic fallback.
  String get message {
    final serverMsg = failure.serverMessage;
    if (serverMsg != null && serverMsg.trim().isNotEmpty) {
      return serverMsg.trim();
    }
    return switch (failure) {
      Network() => 'تعذر الاتصال بالخادم، يرجى التحقق من اتصالك بالإنترنت.',
      Timeout() => 'انتهت مهلة الطلب، يرجى إعادة المحاولة.',
      NotFound() => 'المنتج المطلوب غير متوفر حالياً.',
      Unauthorized() => 'يرجى تسجيل الدخول أولاً.',
      Forbidden() => 'غير مصرح لك بالوصول لهذا المنتج.',
      Validation() => 'بيانات الطلب غير صالحة.',
      Conflict() => 'تعارض في بيانات المنتج بالمخزون.',
      RateLimit() => 'تم تجاوز حد الطلبات المسموح، يرجى الانتظار قليلاً.',
      Server() || Unexpected() => 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً.',
    };
  }

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
