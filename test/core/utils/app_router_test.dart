import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/utils/app_router.dart';

void main() {
  group('AppRouter', () {
    test('exposes route constants unchanged and with expected paths', () {
      expect(AppRouter.kSplashView, equals('/'));
      expect(AppRouter.kOnboardingView, equals('/onboardingView'));
      expect(AppRouter.kStoreView, equals('/store'));
      expect(AppRouter.kProductDetailsView, equals('/store/products/:id'));
      expect(AppRouter.productDetailsPath('123'), equals('/store/products/123'));
      expect(AppRouter.kBrowseView, equals('/browse'));
      expect(AppRouter.kPrescriptionView, equals('/prescription'));
      expect(AppRouter.kOrdersView, equals('/orders'));
      expect(AppRouter.kOrderDetailsView, equals('/orders/:id'));
      expect(AppRouter.orderDetailsPath('456'), equals('/orders/456'));
      expect(AppRouter.kAccountView, equals('/account'));
      expect(AppRouter.kEditProfileView, equals('/account/edit'));
      expect(AppRouter.kCartView, equals('/cart'));
      expect(AppRouter.kCheckoutView, equals('/checkout'));
      expect(AppRouter.kOrderConfirmationView, equals('/checkout/confirmation'));
      expect(AppRouter.kLoginView, equals('/login'));
      expect(AppRouter.kRegisterView, equals('/register'));
      expect(AppRouter.kStaffDashboardView, equals('/staff'));
      expect(AppRouter.kBranchManagementView, equals('/admin/branches'));
    });

    test('creates GoRouter with existing routes and required role routes', () {
      final appRouter = AppRouter();
      final routes = appRouter.router.configuration.routes;

      expect(routes.length, equals(21));
      final routePaths = routes.whereType<GoRoute>().map((r) => r.path).toList();
      expect(routePaths, contains('/'));
      expect(routePaths, contains(AppRouter.kOnboardingView));
      expect(routePaths, contains(AppRouter.kStoreView));
      expect(routePaths, contains(AppRouter.kProductDetailsView));
      expect(routePaths, contains(AppRouter.kBrowseView));
      expect(routePaths, contains(AppRouter.kPrescriptionView));
      expect(routePaths, contains(AppRouter.kPrescriptionUploadView));
      expect(routePaths, contains(AppRouter.kPrescriptionConfirmationView));
      expect(routePaths, contains(AppRouter.kPrescriptionDetailsView));
      expect(routePaths, contains(AppRouter.kOrdersView));
      expect(routePaths, contains(AppRouter.kOrderDetailsView));
      expect(routePaths, contains(AppRouter.kAccountView));
      expect(routePaths, contains(AppRouter.kEditProfileView));
      expect(routePaths, contains(AppRouter.kCartView));
      expect(routePaths, contains(AppRouter.kCheckoutView));
      expect(routePaths, contains(AppRouter.kOrderConfirmationView));
      expect(routePaths, contains(AppRouter.kBranchSelectionView));
      expect(routePaths, contains(AppRouter.kLoginView));
      expect(routePaths, contains(AppRouter.kRegisterView));
      expect(routePaths, contains(AppRouter.kStaffDashboardView));
      expect(routePaths, contains(AppRouter.kBranchManagementView));
    });

    test('accepts optional refreshListenable without error and listens to it', () {
      final notifier = ValueNotifier<int>(0);
      final appRouter = AppRouter(refreshListenable: notifier);

      expect(appRouter.refreshListenable, equals(notifier));
      expect(appRouter.router, isNotNull);

      // Notifying listeners should not throw
      expect(() => notifier.value++, returnsNormally);
      notifier.dispose();
    });
  });
}
