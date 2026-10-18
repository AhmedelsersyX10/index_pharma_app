import 'package:index_pharma/core/network/api_result.dart';
import '../entities/user.dart';

/// Contract defining authentication operations for the application.
///
/// Implemented in the data layer by `AuthRepositoryImpl`.
/// Consumed by domain use cases and presentation cubits.
abstract interface class AuthRepository {
  /// Authenticates a user with [email] and [password].
  ///
  /// On success, the backend sets an HttpOnly cookie and returns the user object.
  Future<ApiResult<UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registers a new customer account with [name], [email], [password],
  /// and optional [phone] and [address].
  ///
  /// On success, the backend sets an HttpOnly cookie and returns the user object.
  Future<ApiResult<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  });

  /// Retrieves the currently authenticated user's profile and permissions.
  ///
  /// Relies on the HttpOnly session cookie managed by the network client.
  Future<ApiResult<UserEntity>> getMe();
}
