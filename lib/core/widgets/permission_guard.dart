import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/features/auth/domain/services/permission_service.dart';

/// A convenience widget that displays its [child] only when the current user
/// has the requested [permission], otherwise rendering [fallback] (or [SizedBox.shrink]).
///
/// **Architecture & Non-Security Notice:**
/// UI visibility toggling via this widget is purely a visual convenience to keep the
/// interface clean and contextual. It is NOT a security boundary or authorization mechanism.
/// All security and permission enforcement must always be executed by the backend.
class PermissionGuard extends StatelessWidget {
  /// Creates a [PermissionGuard] that resolves [PermissionService] either from
  /// the provided [permissionService] or from the inherited widget context.
  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
    this.permissionService,
  });

  /// Creates a [PermissionGuard] with an explicitly provided [PermissionService].
  const PermissionGuard.withService({
    super.key,
    required this.permission,
    required this.child,
    required PermissionService this.permissionService,
    this.fallback,
  });

  /// The permission identifier to evaluate (e.g., [AppPermissions.editPrice]).
  final String permission;

  /// The widget to display when the user has the required permission.
  final Widget child;

  /// Optional widget to display when the user lacks the required permission.
  /// Defaults to [SizedBox.shrink] if not provided.
  final Widget? fallback;

  /// The optional explicit permission service.
  final PermissionService? permissionService;

  @override
  Widget build(BuildContext context) {
    final service = permissionService ?? context.read<PermissionService>();
    if (service.can(permission)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

