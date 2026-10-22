import 'package:shared_preferences/shared_preferences.dart';
import 'package:index_pharma/core/storage/storage_service.dart';

/// Concrete implementation of [StorageService] backed by [SharedPreferences].
///
/// Strictly stores non-sensitive, small configuration values:
/// - Locale preference
/// - Selected branch ID
/// - Onboarding seen flag
class SharedPreferencesStorageService implements StorageService {
  const SharedPreferencesStorageService(this._preferences);

  final SharedPreferences _preferences;

  /// SharedPreferences key for app locale.
  static const String keyLocale = 'app_locale';

  /// SharedPreferences key for selected branch ID.
  static const String keySelectedBranchId = 'selected_branch_id';

  /// SharedPreferences key for onboarding seen flag.
  static const String keyOnboardingSeen = 'onboarding_seen';

  /// SharedPreferences key for theme mode preference ('system', 'light', 'dark').
  static const String keyThemeMode = 'app_theme_mode';

  @override
  String? get locale => _preferences.getString(keyLocale);

  @override
  Future<bool> setLocale(String locale) =>
      _preferences.setString(keyLocale, locale);

  @override
  String? get selectedBranchId => _preferences.getString(keySelectedBranchId);

  @override
  Future<bool> setSelectedBranchId(String branchId) =>
      _preferences.setString(keySelectedBranchId, branchId);

  @override
  Future<bool> clearSelectedBranchId() =>
      _preferences.remove(keySelectedBranchId);

  @override
  bool get onboardingSeen => _preferences.getBool(keyOnboardingSeen) ?? false;

  @override
  Future<bool> setOnboardingSeen(bool seen) =>
      _preferences.setBool(keyOnboardingSeen, seen);

  @override
  String? get themeMode => _preferences.getString(keyThemeMode);

  @override
  Future<bool> setThemeMode(String mode) =>
      _preferences.setString(keyThemeMode, mode);
}
