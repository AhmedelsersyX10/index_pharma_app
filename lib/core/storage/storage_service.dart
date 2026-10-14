/// Abstract contract for local key-value storage.
///
/// Designed exclusively for lightweight, non-sensitive application settings
/// such as locale preferences, selected branch ID, and onboarding flags.
///
/// Sensitive information (auth tokens, passwords, cookies) must NOT be stored
/// here; session tokens/cookies are managed by the network cookie jar.
abstract class StorageService {
  /// The user's selected language code (e.g., 'ar', 'en'), or null if not set.
  String? get locale;

  /// Persists the user's selected language code.
  Future<bool> setLocale(String locale);

  /// The currently selected branch ID, or null if no branch is selected.
  String? get selectedBranchId;

  /// Persists the selected branch ID.
  Future<bool> setSelectedBranchId(String branchId);

  /// Clears the selected branch ID.
  Future<bool> clearSelectedBranchId();

  /// Whether the user has completed or dismissed the onboarding flow.
  /// Defaults to `false` if not set.
  bool get onboardingSeen;

  /// Persists whether onboarding has been seen.
  Future<bool> setOnboardingSeen(bool seen);
}
