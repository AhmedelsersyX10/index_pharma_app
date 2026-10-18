import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/services/permission_service.dart';

void main() {
  UserEntity createUser({
    required UserRole role,
    UserPermissions? permissions,
  }) {
    return UserEntity(
      id: 'usr_test_123',
      name: 'Test User',
      email: 'user@example.com',
      role: role,
      permissions: permissions,
    );
  }

  group('PermissionService - Unauthenticated / Null User', () {
    test('returns false for any permission when user is null', () {
      const service = PermissionService(null);

      expect(service.currentUser, isNull);
      for (final perm in AppPermissions.all) {
        expect(service.can(perm), isFalse);
      }
      expect(service.can('unknownPermission'), isFalse);
    });

    test('default constructor sets currentUser to null and returns false', () {
      const service = PermissionService();

      expect(service.currentUser, isNull);
      expect(service.can(AppPermissions.editPrice), isFalse);
    });
  });

  group('PermissionService - Superadmin Role', () {
    test('has all known permissions when permissions is null', () {
      final superadmin = createUser(
        role: UserRole.superadmin,
        permissions: null,
      );
      final service = PermissionService(superadmin);

      for (final perm in AppPermissions.all) {
        expect(
          service.can(perm),
          isTrue,
          reason: 'Superadmin with null permissions should have $perm',
        );
      }
    });

    test('has all known permissions even when permissions has all false flags', () {
      final superadmin = createUser(
        role: UserRole.superadmin,
        permissions: const UserPermissions(),
      );
      final service = PermissionService(superadmin);

      for (final perm in AppPermissions.all) {
        expect(
          service.can(perm),
          isTrue,
          reason: 'Superadmin with empty/false permissions should still have $perm',
        );
      }
    });

    test('returns false for unknown permission names even for superadmin', () {
      final superadmin = createUser(
        role: UserRole.superadmin,
        permissions: null,
      );
      final service = PermissionService(superadmin);

      expect(service.can('unknownPermission'), isFalse);
      expect(service.can('manage_transfers'), isFalse);
      expect(service.can(''), isFalse);
      expect(service.can('   '), isFalse);
      expect(service.can('deleteDatabase'), isFalse);
    });
  });

  group('PermissionService - Admin Role', () {
    test('returns false for all permissions when permissions is null', () {
      final admin = createUser(
        role: UserRole.admin,
        permissions: null,
      );
      final service = PermissionService(admin);

      for (final perm in AppPermissions.all) {
        expect(
          service.can(perm),
          isFalse,
          reason: 'Admin with null permissions should not have $perm',
        );
      }
    });

    test('returns false for all permissions when permissions is empty (all false)', () {
      final admin = createUser(
        role: UserRole.admin,
        permissions: const UserPermissions(),
      );
      final service = PermissionService(admin);

      for (final perm in AppPermissions.all) {
        expect(service.can(perm), isFalse);
      }
    });

    test('respects granted permissions and denies ungranted ones', () {
      final admin = createUser(
        role: UserRole.admin,
        permissions: const UserPermissions(
          editPrice: true,
          manageTransfers: true,
          viewReports: false,
          viewPrescriptions: false,
          viewReturns: false,
        ),
      );
      final service = PermissionService(admin);

      expect(service.can(AppPermissions.editPrice), isTrue);
      expect(service.can(AppPermissions.manageTransfers), isTrue);
      expect(service.can(AppPermissions.viewReports), isFalse);
      expect(service.can(AppPermissions.viewPrescriptions), isFalse);
      expect(service.can(AppPermissions.viewReturns), isFalse);
    });

    test('returns false for unknown permission names', () {
      final admin = createUser(
        role: UserRole.admin,
        permissions: const UserPermissions(
          editPrice: true,
          manageTransfers: true,
          viewReports: true,
          viewPrescriptions: true,
          viewReturns: true,
        ),
      );
      final service = PermissionService(admin);

      expect(service.can('unknownPermission'), isFalse);
      expect(service.can('superPower'), isFalse);
    });
  });

  group('PermissionService - Pharmacist Role', () {
    test('returns false for all permissions when permissions is null', () {
      final pharmacist = createUser(
        role: UserRole.pharmacist,
        permissions: null,
      );
      final service = PermissionService(pharmacist);

      for (final perm in AppPermissions.all) {
        expect(service.can(perm), isFalse);
      }
    });

    test('returns false for all permissions when permissions is empty (all false)', () {
      final pharmacist = createUser(
        role: UserRole.pharmacist,
        permissions: const UserPermissions(),
      );
      final service = PermissionService(pharmacist);

      for (final perm in AppPermissions.all) {
        expect(service.can(perm), isFalse);
      }
    });

    test('evaluates individual permissions correctly', () {
      final pharmacist = createUser(
        role: UserRole.pharmacist,
        permissions: const UserPermissions(
          viewPrescriptions: true,
          viewReturns: true,
        ),
      );
      final service = PermissionService(pharmacist);

      expect(service.can(AppPermissions.viewPrescriptions), isTrue);
      expect(service.can(AppPermissions.viewReturns), isTrue);
      expect(service.can(AppPermissions.editPrice), isFalse);
      expect(service.can(AppPermissions.manageTransfers), isFalse);
      expect(service.can(AppPermissions.viewReports), isFalse);
    });

    test('returns false for unknown permission names', () {
      final pharmacist = createUser(
        role: UserRole.pharmacist,
        permissions: const UserPermissions(
          viewPrescriptions: true,
        ),
      );
      final service = PermissionService(pharmacist);

      expect(service.can('view_prescriptions'), isFalse);
      expect(service.can('unknown'), isFalse);
    });
  });

  group('PermissionService - Customer Role', () {
    test('returns false for all permissions when permissions is null', () {
      final customer = createUser(
        role: UserRole.customer,
        permissions: null,
      );
      final service = PermissionService(customer);

      for (final perm in AppPermissions.all) {
        expect(service.can(perm), isFalse);
      }
    });

    test('returns false for all permissions when permissions is empty (all false)', () {
      final customer = createUser(
        role: UserRole.customer,
        permissions: const UserPermissions(),
      );
      final service = PermissionService(customer);

      for (final perm in AppPermissions.all) {
        expect(service.can(perm), isFalse);
      }
    });

    test('returns false for unknown permission names', () {
      final customer = createUser(
        role: UserRole.customer,
        permissions: null,
      );
      final service = PermissionService(customer);

      expect(service.can('unknownPermission'), isFalse);
    });
  });

  group('PermissionService - Unknown Permission Across Every Role', () {
    test('all roles return false for non-existent permission names', () {
      const unknownNames = [
        'unknown',
        'nonExistent',
        'manage_transfers',
        'edit_price',
        '',
        '   ',
        'ADMIN_ALL',
      ];

      for (final role in UserRole.values) {
        final user = createUser(
          role: role,
          permissions: const UserPermissions(
            editPrice: true,
            manageTransfers: true,
            viewPrescriptions: true,
            viewReports: true,
            viewReturns: true,
          ),
        );
        final service = PermissionService(user);

        for (final unknown in unknownNames) {
          expect(
            service.can(unknown),
            isFalse,
            reason: 'Role $role must return false for unknown permission "$unknown"',
          );
        }
      }
    });
  });

  group('PermissionService - Whitespace Trimming', () {
    test('trims surrounding whitespace from permission name', () {
      final admin = createUser(
        role: UserRole.admin,
        permissions: const UserPermissions(editPrice: true),
      );
      final service = PermissionService(admin);

      expect(service.can('  editPrice  '), isTrue);
      expect(service.can(' editPrice'), isTrue);
      expect(service.can('editPrice '), isTrue);
    });
  });

  group('AppPermissions - Definition Sanity', () {
    test('contains expected 5 permissions matching UserPermissions fields', () {
      expect(AppPermissions.all, {
        'editPrice',
        'manageTransfers',
        'viewPrescriptions',
        'viewReports',
        'viewReturns',
      });
      expect(AppPermissions.isKnown('editPrice'), isTrue);
      expect(AppPermissions.isKnown('manageTransfers'), isTrue);
      expect(AppPermissions.isKnown('viewPrescriptions'), isTrue);
      expect(AppPermissions.isKnown('viewReports'), isTrue);
      expect(AppPermissions.isKnown('viewReturns'), isTrue);
      expect(AppPermissions.isKnown('invalid'), isFalse);
    });
  });
}
