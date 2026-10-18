import 'package:index_pharma/core/errors/failure.dart';
import '../../domain/entities/user.dart';

/// Sealed hierarchy representing all possible states for authentication.
///
/// Designed to enable exhaustive pattern matching switches in presentation
/// without external code generators like Freezed.
sealed class AuthState {
  const AuthState();
}

/// Initial state when authentication status is unverified / pending bootstrap.
final class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthInitial()';
}

/// Explicit loading state emitted during active authentication calls.
final class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthLoading()';
}

/// Authenticated state holding the verified [user] entity and roles.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserEntity user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthenticated &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => Object.hash(runtimeType, user);

  @override
  String toString() => 'AuthAuthenticated(user: $user)';
}

/// Unauthenticated / Guest state (e.g. no session cookie, expired session, or logged out).
final class AuthGuest extends AuthState {
  const AuthGuest();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthGuest && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthGuest()';
}

/// Explicit failure state wrapping a domain-level [failure].
final class AuthFailure extends AuthState {
  const AuthFailure(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailure &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'AuthFailure(failure: $failure)';
}
