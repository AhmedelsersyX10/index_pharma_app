import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/widgets/permission_guard.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/services/permission_service.dart';

void main() {
  Widget createTestApp(Widget child, [PermissionService? service]) {
    final content = service != null
        ? RepositoryProvider<PermissionService>.value(
            value: service,
            child: child,
          )
        : child;
    return MaterialApp(home: Scaffold(body: content));
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
          const PermissionGuard.withService(
            permission: AppPermissions.editPrice,
            permissionService: service,
            fallback: Text('Access Denied Fallback'),
            child: Text('Edit Price Button'),
          ),
        ),
      );

      expect(find.text('Edit Price Button'), findsOneWidget);
      expect(find.text('Access Denied Fallback'), findsNothing);
    });

    testWidgets('hides child and renders fallback when service.can() returns false', (
      tester,
    ) async {
      const unauthorizedUser = UserEntity(
        id: 'usr_2',
        name: 'Customer',
        email: 'customer@test.com',
        role: UserRole.customer,
      );
      const service = PermissionService(unauthorizedUser);

      await tester.pumpWidget(
        createTestApp(
          const PermissionGuard.withService(
            permission: AppPermissions.editPrice,
            permissionService: service,
            fallback: Text('Access Denied Fallback'),
            child: Text('Edit Price Button'),
          ),
        ),
      );

      expect(find.text('Edit Price Button'), findsNothing);
      expect(find.text('Access Denied Fallback'), findsOneWidget);
    });

    testWidgets(
      'hides child and renders SizedBox.shrink when fallback is omitted and can() is false',
      (tester) async {
        const service = PermissionService(null);

        await tester.pumpWidget(
          createTestApp(
            const PermissionGuard.withService(
              permission: AppPermissions.viewReports,
              permissionService: service,
              child: Text('Secret Reports'),
            ),
          ),
        );

        expect(find.text('Secret Reports'), findsNothing);
        expect(find.byType(SizedBox), findsWidgets);
      },
    );
  });

  group('PermissionGuard Widget - Context Service Resolution', () {
    testWidgets('reads PermissionService from context when constructor argument is omitted', (
      tester,
    ) async {
      const superadminUser = UserEntity(
        id: 'usr_super',
        name: 'SuperAdmin',
        email: 'super@test.com',
        role: UserRole.superadmin,
      );

      await tester.pumpWidget(
        createTestApp(
          const PermissionGuard(
            permission: AppPermissions.manageTransfers,
            child: Text('Transfer Goods'),
          ),
          const PermissionService(superadminUser),
        ),
      );

      expect(find.text('Transfer Goods'), findsOneWidget);
    });

    testWidgets('prefers explicit constructor argument over context resolution', (tester) async {
      const superadminUser = UserEntity(
        id: 'usr_super',
        name: 'SuperAdmin',
        email: 'super@test.com',
        role: UserRole.superadmin,
      );

      // Explicitly pass a guest service that denies permissions
      const guestService = PermissionService(null);

      await tester.pumpWidget(
        createTestApp(
          const PermissionGuard(
            permission: AppPermissions.editPrice,
            permissionService: guestService,
            child: Text('Edit Price'),
          ),
          const PermissionService(superadminUser),
        ),
      );

      expect(find.text('Edit Price'), findsNothing);
    });
  });
}
