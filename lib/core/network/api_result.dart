import 'package:index_pharma/core/errors/failure.dart';

/// Represents the outcome of an API call or data operation.
sealed class ApiResult<T> {
  const ApiResult();
}

/// Successful API outcome containing resulting [data].
final class Success<T> extends ApiResult<T> {
  const Success(this.data);

  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @override
  String toString() => 'Success<$T>(data: $data)';
}

/// Unsuccessful API outcome containing the resulting [failure].
final class Err<T> extends ApiResult<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Err<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'Err<$T>(failure: $failure)';
}
