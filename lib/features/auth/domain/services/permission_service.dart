import '../entities/user.dart';

/// Standard permission keys supported by the system.
///
/// Corresponds to the fields on [UserPermissions] using camelCase format.
abstract final class AppPermissions {
  static const String editPrice = 'editPrice';
  static const String manageTransfers = 'manageTransfers';
  static const String viewPrescriptions = 'viewPrescriptions';
  static const String viewReports = 'viewReports';
  static const String viewReturns = 'viewReturns';

  /// All known permissions recognized by the system.
  static const Set<String> all = {
    editPrice,
    manageTransfers,
    viewPrescriptions,
    viewReports,
    viewReturns,
  };

  /// Returns `true` if [permission] matches a known system permission.
  static bool isKnown(String permission) => all.contains(permission.trim());
}

/// Pure Dart domain service for evaluating permissions.
///
/// Contains zero Flutter dependencies and encapsulates permission checking
/// rules based on the user's role and permissions payload.
class PermissionService {
  final UserEntity? _currentUser;

  /// Creates a [PermissionService] evaluating permissions against [_currentUser].
  const PermissionService([this._currentUser]);

  /// The current user evaluated by this service.
  UserEntity? get currentUser => _currentUser;

  /// Checks whether the user is authorized to perform the action designated by [permission].
  ///
  /// Evaluation rules:
  /// 1. If [currentUser] is `null` (guest/unauthenticated), returns `false`.
  /// 2. If [permission] is not a recognized permission name (unknown), returns `false`.
  /// 3. If [currentUser.role] is [UserRole.superadmin], always returns `true`
  ///    regardless of whether [UserEntity.permissions] is `null` or empty.
  /// 4. If [currentUser.permissions] is `null` (for any non-superadmin role), returns `false`.
  /// 5. Otherwise, matches the permission against [UserPermissions] fields.
  bool can(String permission) {
    final user = _currentUser;
    if (user == null) {
      return false;
    }

    final trimmed = permission.trim();
    if (!AppPermissions.isKnown(trimmed)) {
      return false;
    }

    if (user.role == UserRole.superadmin) {
      return true;
    }

    final permissions = user.permissions;
    if (permissions == null) {
      return false;
    }

    return switch (trimmed) {
      AppPermissions.editPrice => permissions.editPrice,
      AppPermissions.manageTransfers => permissions.manageTransfers,
      AppPermissions.viewPrescriptions => permissions.viewPrescriptions,
      AppPermissions.viewReports => permissions.viewReports,
      AppPermissions.viewReturns => permissions.viewReturns,
      _ => false,
    };
  }
}
