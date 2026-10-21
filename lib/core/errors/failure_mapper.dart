import 'package:easy_localization/easy_localization.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';

/// Presentation helper that maps domain-level [Failure] instances
/// into localized, user-friendly messages.
///
/// Ensures raw [Failure.serverMessage], exception strings, and stack traces
/// are NEVER shown directly to the user.
abstract final class FailureMapper {
  /// Maps a domain [Failure] to a user-friendly, localized description.
  static String toMessage(Failure failure, {String? defaultFallback}) {
    if (failure.serverMessage == 'branch_required') {
      return AppLocaleKeys.errorBranchRequired.tr();
    }
    return switch (failure) {
      Network() => AppLocaleKeys.errorNetwork.tr(),
      Timeout() => AppLocaleKeys.errorTimeout.tr(),
      Validation() => AppLocaleKeys.errorValidation.tr(),
      Unauthorized() => AppLocaleKeys.errorUnauthorized.tr(),
      Forbidden() => AppLocaleKeys.errorForbidden.tr(),
      NotFound() => AppLocaleKeys.errorNotFound.tr(),
      Conflict() => AppLocaleKeys.errorConflict.tr(),
      RateLimit() => AppLocaleKeys.errorRateLimit.tr(),
      Server() => AppLocaleKeys.errorServer.tr(),
      _ => defaultFallback ?? AppLocaleKeys.errorUnexpected.tr(),
    };
  }
}
