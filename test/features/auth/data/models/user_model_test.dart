import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/auth/data/models/user_model.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';

void main() {
  group('UserRole enum', () {
    test('maps valid role strings correctly', () {
      expect(UserRole.fromString('customer'), UserRole.customer);
      expect(UserRole.fromString('pharmacist'), UserRole.pharmacist);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('superadmin'), UserRole.superadmin);
    });

    test('is case-insensitive and trims whitespace', () {
      expect(UserRole.fromString('  Pharmacist  '), UserRole.pharmacist);
      expect(UserRole.fromString('SUPERADMIN'), UserRole.superadmin);
    });

    test('maps unknown role string to customer fallback', () {
      expect(UserRole.fromString('unknown_role'), UserRole.customer);
      expect(UserRole.fromString('manager'), UserRole.customer);
      expect(UserRole.fromString(''), UserRole.customer);
      expect(UserRole.fromString(null), UserRole.customer);
    });
  });

  group('UserPermissions & UserPermissionsModel', () {
    test('parses full permissions JSON correctly', () {
      final json = {
        'editPrice': false,
        'manageTransfers': true,
        'viewPrescriptions': true,
        'viewReports': true,
        'viewReturns': true,
      };

      final model = UserPermissionsModel.fromJson(json);

      expect(model.editPrice, isFalse);
      expect(model.manageTransfers, isTrue);
      expect(model.viewPrescriptions, isTrue);
      expect(model.viewReports, isTrue);
      expect(model.viewReturns, isTrue);

      final entity = model.toEntity();
      expect(entity.editPrice, isFalse);
      expect(entity.manageTransfers, isTrue);
      expect(entity.viewPrescriptions, isTrue);
      expect(entity.viewReports, isTrue);
      expect(entity.viewReturns, isTrue);
    });

    test('defaults to false for missing keys in partial permissions map', () {
      final json = <String, dynamic>{
        'viewPrescriptions': true,
      };

      final model = UserPermissionsModel.fromJson(json);

      expect(model.editPrice, isFalse);
      expect(model.manageTransfers, isFalse);
      expect(model.viewPrescriptions, isTrue);
      expect(model.viewReports, isFalse);
      expect(model.viewReturns, isFalse);
    });

    test('treats non-boolean values as false', () {
      final json = <String, dynamic>{
        'editPrice': 'true',
        'manageTransfers': 1,
        'viewPrescriptions': null,
      };

      final model = UserPermissionsModel.fromJson(json);

      expect(model.editPrice, isFalse);
      expect(model.manageTransfers, isFalse);
      expect(model.viewPrescriptions, isFalse);
    });

    test('toJson serializes correctly', () {
      const model = UserPermissionsModel(
        editPrice: false,
        manageTransfers: true,
        viewPrescriptions: true,
        viewReports: true,
        viewReturns: false,
      );

      final json = model.toJson();

      expect(json, {
        'editPrice': false,
        'manageTransfers': true,
        'viewPrescriptions': true,
        'viewReports': true,
        'viewReturns': false,
      });
    });
  });

  group('UserModel - Role scenarios', () {
    test('parses customer role', () {
      final json = {
        'id': 'cust-1',
        'name': 'Customer User',
        'email': 'customer@test.com',
        'role': 'customer',
      };

      final model = UserModel.fromJson(json);
      final entity = model.toEntity();

      expect(model.role, 'customer');
      expect(entity.role, UserRole.customer);
    });

    test('parses pharmacist role', () {
      final json = {
        'id': 'pharm-1',
        'name': 'Pharmacist User',
        'email': 'pharmacist@test.com',
        'role': 'pharmacist',
      };

      final model = UserModel.fromJson(json);
      final entity = model.toEntity();

      expect(model.role, 'pharmacist');
      expect(entity.role, UserRole.pharmacist);
    });

    test('parses admin role', () {
      final json = {
        'id': 'admin-1',
        'name': 'Admin User',
        'email': 'admin@test.com',
        'role': 'admin',
      };

      final model = UserModel.fromJson(json);
      final entity = model.toEntity();

      expect(model.role, 'admin');
      expect(entity.role, UserRole.admin);
    });

    test('parses superadmin role', () {
      final json = {
        'id': 'super-1',
        'name': 'Superadmin User',
        'email': 'superadmin@test.com',
        'role': 'superadmin',
      };

      final model = UserModel.fromJson(json);
      final entity = model.toEntity();

      expect(model.role, 'superadmin');
      expect(entity.role, UserRole.superadmin);
    });

    test('maps unknown role in toEntity to customer fallback', () {
      final json = {
        'id': 'unknown-1',
        'name': 'Unknown Role User',
        'email': 'unknown@test.com',
        'role': 'moderator',
      };

      final model = UserModel.fromJson(json);
      final entity = model.toEntity();

      expect(model.role, 'moderator');
      expect(entity.role, UserRole.customer);
    });
  });

  group('UserModel - Permissions null vs present', () {
    test('handles null permissions correctly (login response sample)', () {
      final json = {
        'id': 'cbf82a14-8742-4f11-9a7c-179326d91012',
        'name': 'Test Pharmacist',
        'email': 'pharmacist@test.com',
        'role': 'pharmacist',
        'phone': null,
        'address': null,
        'permissions': null,
        'branchId': 'b18f3a22-3118-4089-9e8c-529a6e118901',
      };

      final model = UserModel.fromJson(json);
      final entity = model.toEntity();

      expect(model.permissions, isNull);
      expect(entity.permissions, isNull);
    });

    test('handles present permissions correctly', () {
      final json = {
        'id': 'pharm-2',
        'name': 'Staff Member',
        'email': 'staff@test.com',
        'role': 'pharmacist',
        'permissions': {
          'editPrice': false,
          'manageTransfers': true,
          'viewPrescriptions': true,
          'viewReports': true,
          'viewReturns': true,
        },
        'branchId': 'branch-101',
      };

      final model = UserModel.fromJson(json);
      final entity = model.toEntity();

      expect(model.permissions, isNotNull);
      expect(model.permissions!.viewPrescriptions, isTrue);
      expect(model.permissions!.editPrice, isFalse);

      expect(entity.permissions, isNotNull);
      expect(entity.permissions!.viewPrescriptions, isTrue);
      expect(entity.permissions!.editPrice, isFalse);
    });
  });

  group('UserModel - BranchId null vs present', () {
    test('branchId present (e.g. pharmacist bound to branch)', () {
      final json = {
        'id': 'pharm-1',
        'name': 'Staff',
        'email': 'staff@test.com',
        'role': 'pharmacist',
        'branchId': 'b18f3a22-3118-4089-9e8c-529a6e118901',
      };

      final model = UserModel.fromJson(json);
      final entity = model.toEntity();

      expect(model.branchId, 'b18f3a22-3118-4089-9e8c-529a6e118901');
      expect(entity.branchId, 'b18f3a22-3118-4089-9e8c-529a6e118901');
    });

    test('branchId null (e.g. customer or superadmin)', () {
      final json = {
        'id': 'super-1',
        'name': 'Superadmin',
        'email': 'super@test.com',
        'role': 'superadmin',
        'branchId': null,
      };

      final model = UserModel.fromJson(json);
      final entity = model.toEntity();

      expect(model.branchId, isNull);
      expect(entity.branchId, isNull);
    });
  });

  group('UserModel - Real API Samples Verification', () {
    test('parses POST /auth/login real pharmacist sample (§6.1)', () {
      final json = {
        'id': 'cbf82a14-8742-4f11-9a7c-179326d91012',
        'name': 'Test Pharmacist',
        'email': 'pharmacist@test.com',
        'role': 'pharmacist',
        'phone': null,
        'address': null,
        'permissions': null,
        'branchId': 'b18f3a22-3118-4089-9e8c-529a6e118901',
      };

      final model = UserModel.fromJson(json);
      expect(model.id, 'cbf82a14-8742-4f11-9a7c-179326d91012');
      expect(model.name, 'Test Pharmacist');
      expect(model.email, 'pharmacist@test.com');
      expect(model.role, 'pharmacist');
      expect(model.phone, isNull);
      expect(model.address, isNull);
      expect(model.permissions, isNull);
      expect(model.branchId, 'b18f3a22-3118-4089-9e8c-529a6e118901');
      expect(model.isActive, isNull);
      expect(model.monthlyTarget, isNull);
      expect(model.createdAt, isNull);

      final entity = model.toEntity();
      expect(entity.role, UserRole.pharmacist);
      expect(entity.permissions, isNull);
      expect(entity.branchId, 'b18f3a22-3118-4089-9e8c-529a6e118901');
    });

    test('parses GET /auth/me real customer sample (§6.2)', () {
      final json = {
        'id': 'e98df12a-3312-40bb-97dc-712891bcfa10',
        'name': 'Ahmed Mostafa',
        'email': 'customer@test.com',
        'phone': '01012345678',
        'address': null,
        'role': 'customer',
        'isActive': true,
        'permissions': null,
        'monthlyTarget': 0,
        'branchId': null,
        'createdAt': '2026-10-10T12:00:00.000Z',
      };

      final model = UserModel.fromJson(json);
      expect(model.id, 'e98df12a-3312-40bb-97dc-712891bcfa10');
      expect(model.name, 'Ahmed Mostafa');
      expect(model.email, 'customer@test.com');
      expect(model.phone, '01012345678');
      expect(model.address, isNull);
      expect(model.role, 'customer');
      expect(model.isActive, isTrue);
      expect(model.permissions, isNull);
      expect(model.monthlyTarget, 0);
      expect(model.branchId, isNull);
      expect(model.createdAt, '2026-10-10T12:00:00.000Z');

      final entity = model.toEntity();
      expect(entity.role, UserRole.customer);
      expect(entity.isActive, isTrue);
      expect(entity.monthlyTarget, 0);
      expect(entity.createdAt, '2026-10-10T12:00:00.000Z');
    });

    test('toJson produces expected structure', () {
      const model = UserModel(
        id: 'user-1',
        name: 'User One',
        email: 'user1@test.com',
        role: 'customer',
        phone: '01000000000',
        address: 'Cairo',
        permissions: null,
        branchId: null,
        isActive: true,
        monthlyTarget: 1000,
        createdAt: '2026-10-10T12:00:00.000Z',
      );

      final json = model.toJson();

      expect(json['id'], 'user-1');
      expect(json['name'], 'User One');
      expect(json['email'], 'user1@test.com');
      expect(json['role'], 'customer');
      expect(json['phone'], '01000000000');
      expect(json['address'], 'Cairo');
      expect(json['permissions'], isNull);
      expect(json['branchId'], isNull);
      expect(json['isActive'], isTrue);
      expect(json['monthlyTarget'], 1000);
      expect(json['createdAt'], '2026-10-10T12:00:00.000Z');
    });

    test('UserPermissionsModel.fromEntity converts entity correctly', () {
      const entity = UserPermissions(
        editPrice: true,
        manageTransfers: false,
        viewPrescriptions: true,
        viewReports: false,
        viewReturns: true,
      );

      final model = UserPermissionsModel.fromEntity(entity);

      expect(model.editPrice, isTrue);
      expect(model.manageTransfers, isFalse);
      expect(model.viewPrescriptions, isTrue);
      expect(model.viewReports, isFalse);
      expect(model.viewReturns, isTrue);
    });

    test('UserModel and UserPermissionsModel equality, hashCode, and toString', () {
      const perm1 = UserPermissionsModel(editPrice: true);
      const perm2 = UserPermissionsModel(editPrice: true);
      const perm3 = UserPermissionsModel(editPrice: false);

      expect(perm1, equals(perm2));
      expect(perm1.hashCode, equals(perm2.hashCode));
      expect(perm1 == perm3, isFalse);
      expect(perm1.toString(), contains('UserPermissionsModel'));

      const user1 = UserModel(
        id: 'u-1',
        name: 'User One',
        email: 'user1@test.com',
        role: 'customer',
        permissions: perm1,
      );
      const user2 = UserModel(
        id: 'u-1',
        name: 'User One',
        email: 'user1@test.com',
        role: 'customer',
        permissions: perm1,
      );
      const user3 = UserModel(
        id: 'u-2',
        name: 'User Two',
        email: 'user2@test.com',
        role: 'admin',
      );

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
      expect(user1 == user3, isFalse);
      expect(user1.toString(), contains('UserModel(id: u-1'));
    });
  });
}

