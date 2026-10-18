import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/widgets/permission_guard.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/services/permission_service.dart';

void main() {
  final testGetIt = GetIt.instance;

  tearDown(() async {
    if (testGetIt.isRegistered<PermissionService>()) {
      testGetIt.unregister<PermissionService>();
    }
  });

  Widget createTestApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('PermissionGuard Widget - Constructor Injected Service', () {
    testWidgets('renders child when service.can() returns true', (tester) async {
      const authorizedUser = UserEntity(
        id: 'usr_1',
        name: 'Admin',
        email: 'admin@test.com',
        role: UserRole.admin,
        permissions: UserPermissions(editPrice: true),
      );
      const service = PermissionService(authorizedUser);

      await tester.pumpWidget(
        createTestApp(
          PermissionGuard.withService(
            permission: AppPermissions.editPrice,
            permissionService: service,
            fallback: const Text('Access Denied Fallback'),
            child: const Text('Edit Price Button'),
          ),
        ),
      );

      expect(find.text('Edit Price Button'), findsOneWidget);
      expect(find.text('Access Denied Fallback'), findsNothing);
    });

    testWidgets('hides child and renders fallback when service.can() returns false', (tester) async {
      const unauthorizedUser = UserEntity(
        id: 'usr_2',
        name: 'Customer',
        email: 'customer@test.com',
        role: UserRole.customer,
      );
      const service = PermissionService(unauthorizedUser);

      await tester.pumpWidget(
        createTestApp(
          PermissionGuard.withService(
            permission: AppPermissions.editPrice,
            permissionService: service,
            fallback: const Text('Access Denied Fallback'),
            child: const Text('Edit Price Button'),
          ),
        ),
      );

      expect(find.text('Edit Price Button'), findsNothing);
      expect(find.text('Access Denied Fallback'), findsOneWidget);
    });

    testWidgets('hides child and renders SizedBox.shrink when fallback is omitted and can() is false', (tester) async {
      const service = PermissionService(null);

      await tester.pumpWidget(
        createTestApp(
          PermissionGuard.withService(
            permission: AppPermissions.viewReports,
            permissionService: service,
            child: const Text('Secret Reports'),
          ),
        ),
      );

      expect(find.text('Secret Reports'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('PermissionGuard Widget - GetIt Service Resolution', () {
    testWidgets('reads PermissionService from GetIt when constructor argument is omitted', (tester) async {
      const superadminUser = UserEntity(
        id: 'usr_super',
        name: 'SuperAdmin',
        email: 'super@test.com',
        role: UserRole.superadmin,
      );
      testGetIt.registerSingleton<PermissionService>(
        const PermissionService(superadminUser),
      );

      await tester.pumpWidget(
        createTestApp(
          PermissionGuard(
            permission: AppPermissions.manageTransfers,
            child: const Text('Transfer Goods'),
          ),
        ),
      );

      expect(find.text('Transfer Goods'), findsOneWidget);
    });

    testWidgets('prefers explicit constructor argument over GetIt registration', (tester) async {
      const superadminUser = UserEntity(
        id: 'usr_super',
        name: 'SuperAdmin',
        email: 'super@test.com',
        role: UserRole.superadmin,
      );
      testGetIt.registerSingleton<PermissionService>(
        const PermissionService(superadminUser),
      );

      // Explicitly pass a guest service that denies permissions
      const guestService = PermissionService(null);

      await tester.pumpWidget(
        createTestApp(
          PermissionGuard(
            permission: AppPermissions.editPrice,
            permissionService: guestService,
            child: const Text('Edit Price'),
          ),
        ),
      );

      expect(find.text('Edit Price'), findsNothing);
    });
  });
}
