import 'package:easy_localization/easy_localization.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';

/// Pure presentation helper that maps domain-level [Failure] instances
/// into localized, user-friendly messages and titles.
abstract final class AuthFailureMapper {
  /// Maps a domain [Failure] to a user-friendly, localized description.
  ///
  /// Never displays raw exception or stack trace strings.
  /// If the server returned a custom business error message, that message is preferred.
  static String toMessage(Failure failure) {
    final serverMsg = failure.serverMessage?.trim();
    if (serverMsg != null && serverMsg.isNotEmpty) {
      return serverMsg;
    }

    return switch (failure) {
      Network() => AppLocaleKeys.authErrorNetwork.tr(),
      Timeout() => AppLocaleKeys.authErrorTimeout.tr(),
      Unauthorized() => AppLocaleKeys.authErrorInvalidCredentials.tr(),
      Conflict() => AppLocaleKeys.authErrorEmailAlreadyExistsDesc.tr(),
      Server() => AppLocaleKeys.authErrorServer.tr(),
      _ => AppLocaleKeys.authErrorUnexpected.tr(),
    };
  }

  /// Maps a domain [Failure] to a localized banner title.
  static String toTitle(Failure failure, {required bool isLogin}) {
    if (failure is Conflict) {
      return AppLocaleKeys.authErrorEmailAlreadyExistsTitle.tr();
    }
    return isLogin
        ? AppLocaleKeys.authErrorLoginFailedTitle.tr()
        : AppLocaleKeys.authErrorRegisterFailedTitle.tr();
  }
}
