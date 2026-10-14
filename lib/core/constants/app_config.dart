import 'package:flutter/foundation.dart';

/// Central application configuration.
///
/// Contains backend URLs and media helper methods.
class AppConfig {
  const AppConfig._();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Base URL for the backend API.
  ///
  /// Can be overridden via `--dart-define=API_BASE_URL=<url>`.
  /// Defaults to Android emulator endpoint (`http://10.0.2.2:5000/api`) on Android,
  /// and `http://localhost:5000/api` on other platforms.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  /// Origin URL derived by removing trailing `/api` from [baseUrl].
  static String get origin {
    final url = baseUrl;
    if (url.endsWith('/api')) {
      return url.substring(0, url.length - 4);
    }
    if (url.endsWith('/api/')) {
      return url.substring(0, url.length - 5);
    }
    return url;
  }

  /// Resolves media/uploaded image paths to a full URL.
  ///
  /// - Returns `''` if [path] is empty.
  /// - Returns [path] unchanged if it starts with `http`.
  /// - Otherwise prepends [origin] to [path].
  static String mediaUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;

    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$origin$normalizedPath';
  }
}
