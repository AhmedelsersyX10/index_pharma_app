/// Core failure abstractions representing domain and data layer errors.
sealed class Failure {
  const Failure({this.serverMessage});

  /// The raw error message returned by the backend (if available).
  final String? serverMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          serverMessage == other.serverMessage;

  @override
  int get hashCode => Object.hash(runtimeType, serverMessage);

  @override
  String toString() => '$runtimeType(serverMessage: $serverMessage)';
}

/// Network-level failure (e.g. no internet connection, DNS failure).
final class Network extends Failure {
  const Network({super.serverMessage});
}

/// Request timed out during connection, send, or receive.
final class Timeout extends Failure {
  const Timeout({super.serverMessage});
}

/// Request validation failure (HTTP 400).
final class Validation extends Failure {
  const Validation({super.serverMessage});
}

/// Authentication failure or session expiration (HTTP 401).
final class Unauthorized extends Failure {
  const Unauthorized({super.serverMessage});
}

/// Authorization failure or permission denied (HTTP 403).
final class Forbidden extends Failure {
  const Forbidden({super.serverMessage});
}

/// Requested resource was not found (HTTP 404).
final class NotFound extends Failure {
  const NotFound({super.serverMessage});
}

/// Conflict with current state of resource (HTTP 409).
final class Conflict extends Failure {
  const Conflict({super.serverMessage});
}

/// Too many requests / rate limit exceeded (HTTP 429).
final class RateLimit extends Failure {
  const RateLimit({super.serverMessage});
}

/// Server-side internal error (HTTP 5xx).
final class Server extends Failure {
  const Server({super.serverMessage});
}

/// Unhandled or unexpected error condition.
final class Unexpected extends Failure {
  const Unexpected({super.serverMessage});
}
