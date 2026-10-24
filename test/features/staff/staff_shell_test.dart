import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/services/permission_service.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/staff/presentation/screens/staff_access_denied_screen.dart';
import 'package:index_pharma/features/staff/presentation/screens/staff_home_screen.dart';
import 'package:index_pharma/features/staff/presentation/screens/staff_more_screen.dart';
import 'package:index_pharma/features/staff/presentation/widgets/staff_bottom_nav.dart';

import '../../helpers/pump_with_providers.dart';

class MockAuthCubitForStaff extends AuthCubit {
  MockAuthCubitForStaff(AuthState initialState)
      : super(authRepository: FakeTestAuthRepository()) {
    emit(initialState);
  }

  bool logoutCalled = false;

  @override
  Future<void> logout() async {
    logoutCalled = true;
    emit(const AuthGuest());
  }
}

void main() {
  setUpAll(() async {
    await initTestEnvironment();
  });

  group('PermissionService Unit Tests (Task 4.01)', () {
    test('guest (null user) cannot perform any action', () {
      const permService = PermissionService(null);
      expect(permService.can(AppPermissions.viewPrescriptions), isFalse);
      expect(permService.can(AppPermissions.viewReports), isFalse);
      expect(permService.can(AppPermissions.editPrice), isFalse);
    });

    test('pharmacist with null permissions returns false for all actions (null-deny)', () {
      const user = UserEntity(
        id: 'p-1',
        name: 'د. أحمد',
        email: 'ahmed@index.com',
        role: UserRole.pharmacist,
        permissions: null,
      );
      const permService = PermissionService(user);
      expect(permService.can(AppPermissions.viewPrescriptions), isFalse);
      expect(permService.can(AppPermissions.viewReports), isFalse);
    });

    test('pharmacist with explicit permissions is evaluated accurately', () {
      const userWithRx = UserEntity(
        id: 'p-2',
        name: 'د. سارة',
        email: 'sara@index.com',
        role: UserRole.pharmacist,
        permissions: UserPermissions(
          viewPrescriptions: true,
          viewReports: false,
          editPrice: false,
          manageTransfers: false,
          viewReturns: false,
        ),
      );
      const permServiceRx = PermissionService(userWithRx);
      expect(permServiceRx.can(AppPermissions.viewPrescriptions), isTrue);
      expect(permServiceRx.can(AppPermissions.viewReports), isFalse);

      const userWithReports = UserEntity(
        id: 'p-3',
        name: 'د. محمود',
        email: 'mahmoud@index.com',
        role: UserRole.pharmacist,
        permissions: UserPermissions(
          viewPrescriptions: false,
          viewReports: true,
          editPrice: false,
          manageTransfers: false,
          viewReturns: false,
        ),
      );
      const permServiceReports = PermissionService(userWithReports);
      expect(permServiceReports.can(AppPermissions.viewPrescriptions), isFalse);
      expect(permServiceReports.can(AppPermissions.viewReports), isTrue);
    });

    test('superadmin always evaluates true for all known permissions, even with null permissions', () {
      const superadmin = UserEntity(
        id: 'sa-1',
        name: 'المدير العام',
        email: 'super@index.com',
        role: UserRole.superadmin,
        permissions: null,
      );
      const permService = PermissionService(superadmin);
      expect(permService.can(AppPermissions.viewPrescriptions), isTrue);
      expect(permService.can(AppPermissions.viewReports), isTrue);
      expect(permService.can(AppPermissions.editPrice), isTrue);
      expect(permService.can(AppPermissions.manageTransfers), isTrue);
      expect(permService.can(AppPermissions.viewReturns), isTrue);
    });

    test('superadmin evaluates false for unknown permission keys', () {
      const superadmin = UserEntity(
        id: 'sa-1',
        name: 'المدير العام',
        email: 'super@index.com',
        role: UserRole.superadmin,
      );
      const permService = PermissionService(superadmin);
      expect(permService.can('unknownPermissionKey'), isFalse);
    });
  });

  group('StaffBottomNav Widget Tests', () {
    testWidgets('renders all 5 tabs when viewPrescriptions is true', (tester) async {
      const user = UserEntity(
        id: 'p-1',
        name: 'د. خالد',
        email: 'khaled@index.com',
        role: UserRole.pharmacist,
        permissions: UserPermissions(viewPrescriptions: true),
      );
      final authCubit = MockAuthCubitForStaff(const AuthAuthenticated(user));

      await tester.pumpWidget(
        buildAppWithProviders(
          authCubit: authCubit,
          permissionService: const PermissionService(user),
          child: Scaffold(
            bottomNavigationBar: StaffBottomNav(
              currentLocation: AppRouter.kStaffHomeView,
              onTapRoute: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check all 5 icons exist (tab 0 is active, so Icons.point_of_sale is shown)
      expect(find.byIcon(Icons.point_of_sale), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byIcon(Icons.medication_outlined), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
    });

    testWidgets('hides prescriptions tab when viewPrescriptions is false', (tester) async {
      const user = UserEntity(
        id: 'p-1',
        name: 'د. خالد',
        email: 'khaled@index.com',
        role: UserRole.pharmacist,
        permissions: UserPermissions(viewPrescriptions: false),
      );
      final authCubit = MockAuthCubitForStaff(const AuthAuthenticated(user));

      await tester.pumpWidget(
        buildAppWithProviders(
          authCubit: authCubit,
          permissionService: const PermissionService(user),
          child: Scaffold(
            bottomNavigationBar: StaffBottomNav(
              currentLocation: AppRouter.kStaffHomeView,
              onTapRoute: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.point_of_sale), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      // Prescriptions must be completely hidden
      expect(find.byIcon(Icons.medication_outlined), findsNothing);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
    });

    testWidgets('tapping a tab invokes onTapRoute with the target path', (tester) async {
      const user = UserEntity(
        id: 'p-1',
        name: 'د. خالد',
        email: 'khaled@index.com',
        role: UserRole.pharmacist,
        permissions: UserPermissions(viewPrescriptions: true),
      );
      final authCubit = MockAuthCubitForStaff(const AuthAuthenticated(user));
      String? tappedRoute;

      await tester.pumpWidget(
        buildAppWithProviders(
          authCubit: authCubit,
          permissionService: const PermissionService(user),
          child: Scaffold(
            bottomNavigationBar: StaffBottomNav(
              currentLocation: AppRouter.kStaffHomeView,
              onTapRoute: (route) => tappedRoute = route,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      expect(tappedRoute, equals(AppRouter.kStaffOrdersView));

      await tester.tap(find.byIcon(Icons.grid_view_outlined));
      expect(tappedRoute, equals(AppRouter.kStaffMoreView));
    });
  });

  group('StaffHomeScreen Widget Tests', () {
    testWidgets('displays branch name chip, shift status, quick actions, and overview metrics',
        (tester) async {
      const user = UserEntity(
        id: 'p-1',
        name: 'د. طارق',
        email: 'tarek@index.com',
        role: UserRole.pharmacist,
        branchId: 'فرع مدينة نصر',
      );
      final authCubit = MockAuthCubitForStaff(const AuthAuthenticated(user));

      await tester.pumpWidget(
        buildAppWithProviders(
          authCubit: authCubit,
          child: const StaffHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Branch chip
      expect(find.text('فرع مدينة نصر'), findsOneWidget);

      // Inactive shift pill
      expect(find.text(testArTranslations['staff']['shift_inactive']), findsOneWidget);

      // Hero POS CTA
      expect(find.text(testArTranslations['staff']['home']['pos_cta']), findsOneWidget);

      // Today's overview section
      expect(find.text(testArTranslations['staff']['home']['today_overview']), findsOneWidget);

      // Metric tiles showing '—'
      expect(find.text('—'), findsNWidgets(3));
    });

    testWidgets('tapping POS CTA displays coming soon snackbar', (tester) async {
      const user = UserEntity(
        id: 'p-1',
        name: 'د. طارق',
        email: 'tarek@index.com',
        role: UserRole.pharmacist,
      );
      final authCubit = MockAuthCubitForStaff(const AuthAuthenticated(user));

      await tester.pumpWidget(
        buildAppWithProviders(
          authCubit: authCubit,
          child: const StaffHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(testArTranslations['staff']['home']['pos_cta']));
      await tester.pump();

      expect(find.text(testArTranslations['staff']['action_available_soon']), findsOneWidget);
    });
  });

  group('StaffMoreScreen Widget Tests', () {
    testWidgets('shows profile card, operations, preferences, and logout', (tester) async {
      const user = UserEntity(
        id: 'p-1',
        name: 'د. مريم النجار',
        email: 'mariam@index.com',
        role: UserRole.pharmacist,
        permissions: UserPermissions(viewReports: false),
      );
      final authCubit = MockAuthCubitForStaff(const AuthAuthenticated(user));

      await tester.pumpWidget(
        buildAppWithProviders(
          authCubit: authCubit,
          permissionService: const PermissionService(user),
          child: const StaffMoreScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Profile name
      expect(find.text('د. مريم النجار'), findsOneWidget);
      // Pharmacist role label
      expect(find.text(testArTranslations['staff']['role_pharmacist']), findsOneWidget);

      // Operations section
      expect(find.text(testArTranslations['staff']['more']['section_operations']), findsOneWidget);
      expect(find.text(testArTranslations['staff']['more']['shift_history']), findsOneWidget);
      expect(find.text(testArTranslations['staff']['more']['barcode_audit']), findsOneWidget);

      // Reports must NOT be shown since viewReports = false and role != superadmin
      expect(find.text(testArTranslations['staff']['more']['reports']), findsNothing);

      // Branches must NOT be shown for non-superadmin
      expect(find.text(testArTranslations['staff']['more']['branches']), findsNothing);

      // Logout button
      expect(find.text(testArTranslations['staff']['more']['logout']), findsOneWidget);
    });

    testWidgets('shows Reports item when pharmacist has viewReports permission', (tester) async {
      const user = UserEntity(
        id: 'p-1',
        name: 'د. مريم النجار',
        email: 'mariam@index.com',
        role: UserRole.pharmacist,
        permissions: UserPermissions(viewReports: true),
      );
      final authCubit = MockAuthCubitForStaff(const AuthAuthenticated(user));

      await tester.pumpWidget(
        buildAppWithProviders(
          authCubit: authCubit,
          permissionService: const PermissionService(user),
          child: const StaffMoreScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testArTranslations['staff']['more']['reports']), findsOneWidget);
      // Still no branch management for pharmacist
      expect(find.text(testArTranslations['staff']['more']['branches']), findsNothing);
    });

    testWidgets('shows Branches and Reports for superadmin', (tester) async {
      const user = UserEntity(
        id: 'sa-1',
        name: 'د. عادل إمام',
        email: 'admin@index.com',
        role: UserRole.superadmin,
      );
      final authCubit = MockAuthCubitForStaff(const AuthAuthenticated(user));

      await tester.pumpWidget(
        buildAppWithProviders(
          authCubit: authCubit,
          permissionService: const PermissionService(user),
          child: const StaffMoreScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testArTranslations['staff']['role_superadmin']), findsOneWidget);
      expect(find.text(testArTranslations['staff']['more']['reports']), findsOneWidget);
      expect(find.text(testArTranslations['staff']['more']['branches']), findsOneWidget);
    });

    testWidgets('clicking logout displays confirmation dialog and triggers authCubit.logout()',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const user = UserEntity(
        id: 'p-1',
        name: 'د. كريم',
        email: 'karim@index.com',
        role: UserRole.pharmacist,
      );
      final authCubit = MockAuthCubitForStaff(const AuthAuthenticated(user));

      await tester.pumpWidget(
        buildAppWithProviders(
          authCubit: authCubit,
          child: const StaffMoreScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap logout item
      final logoutFinder = find.text(testArTranslations['staff']['more']['logout']);
      await tester.scrollUntilVisible(logoutFinder, 200);
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();

      // Confirmation dialog must appear
      expect(find.byKey(const ValueKey('logout_confirm_button')), findsOneWidget);

      // Confirm logout
      await tester.tap(find.byKey(const ValueKey('logout_confirm_button')));
      await tester.pumpAndSettle();

      expect(authCubit.logoutCalled, isTrue);
    });
  });

  group('StaffAccessDeniedScreen Widget Tests', () {
    testWidgets('displays access denied message and return button', (tester) async {
      await tester.pumpWidget(
        buildAppWithProviders(
          child: const StaffAccessDeniedScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testArTranslations['staff']['access_denied_title']), findsNWidgets(2)); // AppBar + Body
      expect(find.text(testArTranslations['staff']['access_denied_desc']), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });
  });
}
