import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:index_pharma/core/constants/app_config.dart';
import 'package:path_provider/path_provider.dart';

/// Centralized HTTP client configured with cookie persistence, timeouts,
/// 401 session expiration handling, and optional branch headers.
class ApiClient {
  ApiClient({
    Dio? dio,
    required this.cookieJar,
    String? baseUrl,
    this.onSessionExpired,
    this.branchIdProvider,
    bool? enableLogging,
  })  : enableLogging = enableLogging ?? kDebugMode,
        dio = dio ?? _createDefaultDio(baseUrl) {
    _setupInterceptors();
  }

  /// Header key used for staff-specific branch scoping.
  static const String branchHeaderKey = 'X-Branch-Id';

  /// Default timeout for regular requests (30 seconds).
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Extended timeout for file/multipart uploads (60 seconds).
  static const Duration uploadTimeout = Duration(seconds: 60);

  /// Per-request options configured with extended timeouts for multipart uploads.
  static Options get uploadOptions => Options(
        sendTimeout: uploadTimeout,
        receiveTimeout: uploadTimeout,
      );

  /// The underlying [Dio] instance used for network requests.
  final Dio dio;

  /// The [CookieJar] managing HTTP cookies (e.g., HttpOnly authentication token).
  final CookieJar cookieJar;

  /// Whether debug logging interceptor is active.
  final bool enableLogging;

  /// Callback invoked when a 401 Unauthorized status is received.
  ///
  /// This callback must not navigate directly; handling routing belongs to
  /// the presentation/app coordinator layer.
  void Function()? onSessionExpired;

  /// Provider that returns the current branch ID for staff requests,
  /// or null if no branch should be attached.
  String? Function()? branchIdProvider;

  /// Creates an [ApiClient] with a persistent cookie jar stored in the
  /// application documents directory.
  static Future<ApiClient> create({
    String? baseUrl,
    String? storagePath,
    CookieJar? cookieJar,
    Dio? dio,
    void Function()? onSessionExpired,
    String? Function()? branchIdProvider,
    bool? enableLogging,
  }) async {
    final jar = cookieJar ?? await _createPersistCookieJar(storagePath);
    return ApiClient(
      dio: dio,
      cookieJar: jar,
      baseUrl: baseUrl,
      onSessionExpired: onSessionExpired,
      branchIdProvider: branchIdProvider,
      enableLogging: enableLogging,
    );
  }

  static Future<CookieJar> _createPersistCookieJar([String? storagePath]) async {
    final basePath =
        storagePath ?? (await getApplicationDocumentsDirectory()).path;
    final dir = basePath.endsWith('/')
        ? '$basePath.cookies/'
        : '$basePath/.cookies/';
    return PersistCookieJar(
      storage: FileStorage(dir),
    );
  }

  static Dio _createDefaultDio([String? baseUrl]) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.baseUrl,
        connectTimeout: defaultTimeout,
        receiveTimeout: defaultTimeout,
        sendTimeout: defaultTimeout,
      ),
    );
  }

  void _setupInterceptors() {
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(_BranchHeaderInterceptor(this));
    dio.interceptors.add(_SessionExpiredInterceptor(this));

    if (enableLogging) {
      dio.interceptors.add(const _DebugLogInterceptor());
    }
  }
}

/// Adds the staff-only `X-Branch-Id` header if a branch ID is available.
class _BranchHeaderInterceptor extends Interceptor {
  _BranchHeaderInterceptor(this._client);

  final ApiClient _client;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final branchId = _client.branchIdProvider?.call();
    if (branchId != null && branchId.trim().isNotEmpty) {
      options.headers[ApiClient.branchHeaderKey] = branchId.trim();
    }
    handler.next(options);
  }
}

/// Listens for HTTP 401 Unauthorized responses and invokes [onSessionExpired].
class _SessionExpiredInterceptor extends Interceptor {
  _SessionExpiredInterceptor(this._client);

  final ApiClient _client;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _client.onSessionExpired?.call();
    }
    handler.next(err);
  }
}

/// Logs HTTP method, path, and response status only in debug mode.
///
/// Guaranteed to never log headers, body, cookies, query parameters, or credentials.
class _DebugLogInterceptor extends Interceptor {
  const _DebugLogInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[HTTP] ${options.method} ${options.uri.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '[HTTP] ${response.requestOptions.method} ${response.requestOptions.uri.path} -> ${response.statusCode}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    debugPrint(
      '[HTTP] ${err.requestOptions.method} ${err.requestOptions.uri.path} -> ${status ?? err.type.name}',
    );
    handler.next(err);
  }
}
