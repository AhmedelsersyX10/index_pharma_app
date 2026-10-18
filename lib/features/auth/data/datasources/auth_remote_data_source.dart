import '../models/user_model.dart';

/// Contract defining remote network operations for authentication.
///
/// Throws [DioException] on network or HTTP errors, which are mapped to domain
/// [Failure] types at the repository boundary.
abstract interface class AuthRemoteDataSource {
  /// Calls `POST /auth/login` to authenticate with email and password.
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Calls `POST /auth/register` to create a new customer account.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  });

  /// Calls `GET /auth/me` to fetch current user profile and role.
  Future<UserModel> getMe();
}
