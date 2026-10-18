import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/core/network/api_result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit responsible for managing user authentication lifecycle and session state.
///
/// Follows Clean Architecture:
/// - Interacts strictly with [AuthRepository] for all business operations.
/// - Listens for session expirations emitted by [ApiClient].
/// - Emits strongly typed, sealed [AuthState] transitions.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    ApiClient? apiClient,
  })  : _authRepository = authRepository,
        _apiClient = apiClient,
        super(const AuthInitial()) {
    _apiClient?.onSessionExpired = onSessionExpired;
  }

  final AuthRepository _authRepository;
  final ApiClient? _apiClient;

  /// Restores session state via `GET /auth/me`.
  ///
  /// - [Success] -> Emits [AuthAuthenticated].
  /// - [Unauthorized] (HTTP 401) -> Emits [AuthGuest] (not logged in / guest mode, not an error).
  /// - Any other [Failure] -> Emits [AuthFailure].
  Future<void> restoreSession() async {
    emit(const AuthLoading());
    final result = await _authRepository.getMe();
    switch (result) {
      case Success(:final data):
        emit(AuthAuthenticated(data));
      case Err(:final failure):
        if (failure is Unauthorized) {
          emit(const AuthGuest());
        } else {
          emit(AuthFailure(failure));
        }
    }
  }

  /// Authenticates an existing user using [email] and [password].
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    switch (result) {
      case Success(:final data):
        emit(AuthAuthenticated(data));
      case Err(:final failure):
        emit(AuthFailure(failure));
    }
  }

  /// Registers a new customer account.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    emit(const AuthLoading());
    final result = await _authRepository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      address: address,
    );
    switch (result) {
      case Success(:final data):
        emit(AuthAuthenticated(data));
      case Err(:final failure):
        emit(AuthFailure(failure));
    }
  }

  /// Ends the active user session and invalidates authentication cookies.
  Future<void> logout() async {
    emit(const AuthLoading());
    final result = await _authRepository.logout();
    switch (result) {
      case Success():
        emit(const AuthGuest());
      case Err(:final failure):
        emit(AuthFailure(failure));
    }
  }

  /// Invoked when the HTTP layer detects an unrecoverable 401 session expiration.
  void onSessionExpired() {
    emit(const AuthGuest());
  }

  @override
  Future<void> close() {
    if (_apiClient?.onSessionExpired == onSessionExpired) {
      _apiClient?.onSessionExpired = null;
    }
    return super.close();
  }
}
