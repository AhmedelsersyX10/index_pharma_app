import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/utils/go_router_refresh_stream.dart';
import 'package:index_pharma/core/widgets/auth_required_guard.dart';
import 'package:index_pharma/core/widgets/route_placeholder_screens.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/auth/presentation/screens/login_screen.dart';
import 'package:index_pharma/features/auth/presentation/screens/register_screen.dart';
import 'package:index_pharma/features/account/presentation/screens/account_screen.dart';
import 'package:index_pharma/features/account/presentation/screens/edit_profile_screen.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/screens/cart_screen.dart';
import 'package:index_pharma/features/choose_branches/presentation/screens/branch_selection_screen.dart';
import 'package:index_pharma/features/home/presentation/screens/home_screen.dart';
import 'package:index_pharma/features/language/presentation/screens/language_selection_screen.dart';
import 'package:index_pharma/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:index_pharma/features/products/presentation/screens/product_details_screen.dart';
import 'package:index_pharma/features/splash/presentation/view/splash_view.dart';
import 'package:index_pharma/features/checkout/domain/entities/order.dart';
import 'package:index_pharma/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:index_pharma/features/checkout/presentation/screens/order_confirmation_screen.dart';
import 'package:index_pharma/features/orders/domain/entities/customer_order.dart';
import 'package:index_pharma/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:index_pharma/features/orders/presentation/screens/order_details_screen.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_entity.dart';
import 'package:index_pharma/features/prescriptions/presentation/screens/my_prescriptions_screen.dart';
import 'package:index_pharma/features/prescriptions/presentation/screens/prescription_details_screen.dart';
import 'package:index_pharma/features/prescriptions/presentation/screens/prescription_submitted_screen.dart';
import 'package:index_pharma/features/prescriptions/presentation/screens/upload_prescription_screen.dart';

class AppRouter {
  AppRouter({
    AuthCubit? authCubit,
    StorageService? storageService,
    Listenable? refreshListenable,
    String? initialLocation,
  })  : _authCubit = authCubit,
        _storageService = storageService,
        refreshListenable = refreshListenable ??
            (authCubit != null
                ? GoRouterRefreshStream(authCubit.stream)
                : _AuthRefreshListenable()),
        _initialLocation = initialLocation;

  final AuthCubit? _authCubit;
  final StorageService? _storageService;
  final Listenable? refreshListenable;
  final String? _initialLocation;

  static const kSplashView = '/';
  static const kLanguageSelectionView = '/language';
  static const kOnboardingView = '/onboardingView';
  static const kStoreView = '/store';
  static const kProductDetailsView = '/store/products/:id';
  static const kBrowseView = '/browse';
  static const kPrescriptionView = '/prescription';
  static const kPrescriptionUploadView = '/prescription/upload';
  static const kPrescriptionConfirmationView = '/prescription/confirmation';
  static const kPrescriptionDetailsView = '/prescription/:id';
  static const kOrdersView = '/orders';
  static const kOrderDetailsView = '/orders/:id';
  static const kAccountView = '/account';
  static const kEditProfileView = '/account/edit';
  static const kCartView = '/cart';
  static const kCheckoutView = '/checkout';
  static const kOrderConfirmationView = '/checkout/confirmation';
  static const kBranchSelectionView = '/choose-branch';
  static const kLoginView = '/login';
  static const kRegisterView = '/register';
  static const kStaffDashboardView = '/staff';
  static const kBranchManagementView = '/admin/branches';

  /// Generates the product details path for a specific [productId].
  static String productDetailsPath(String productId) => '/store/products/$productId';

  /// Generates the order details path for a specific [orderId].
  static String orderDetailsPath(String orderId) => '/orders/$orderId';

  /// Generates the prescription details path for a specific [prescriptionId].
  static String prescriptionDetailsPath(String prescriptionId) =>
      '/prescription/$prescriptionId';

  AuthCubit? get _activeAuthCubit {
    if (_authCubit != null) return _authCubit;
    if (getIt.isRegistered<AuthCubit>()) {
      return getIt<AuthCubit>();
    }
    return null;
  }

  StorageService? get _activeStorageService {
    if (_storageService != null) return _storageService;
    if (getIt.isRegistered<StorageService>()) {
      return getIt<StorageService>();
    }
    return null;
  }

  /// Sanitizes and authorizes a [from] return route path for the given [role].
  ///
  /// Returns the validated target path, or `null` if the path is invalid or unauthorized.
  static String? sanitizeReturnRoute(String from, UserRole role) {
    final trimmed = from.trim();
    if (trimmed.isEmpty || !trimmed.startsWith('/')) {
      return null;
    }

    final pathOnly = trimmed.split('?').first;
    // Auth routes are never valid return targets (avoids redirect loops)
    if (pathOnly == kLoginView || pathOnly == kRegisterView) {
      return null;
    }

    final bool isStaffRoute = pathOnly == kStaffDashboardView ||
        pathOnly.startsWith('$kStaffDashboardView/');
    final bool isBranchManagementRoute = pathOnly == kBranchManagementView ||
        pathOnly.startsWith('$kBranchManagementView/');

    final isStaff = role == UserRole.pharmacist ||
        role == UserRole.admin ||
        role == UserRole.superadmin;

    if (isStaff) {
      if (isBranchManagementRoute) {
        return role == UserRole.superadmin ? trimmed : null;
      }
      return isStaffRoute ? trimmed : null;
    }

    if (isStaffRoute || isBranchManagementRoute) {
      return null;
    }

    return trimmed;
  }

  /// Pure routing guard to determine redirect destinations based on authentication state and current path.
  ///
  /// Rules:
  /// - Guests and customers are allowed on store routes (`kStoreView`) and auth routes (`kLoginView`, `kRegisterView`).
  /// - Pharmacists and Admins can access staff routes (`kStaffDashboardView`).
  /// - Superadmins can access staff routes (`kStaffDashboardView`) plus branch-management routes (`kBranchManagementView`).
  /// - Any staff route or branch-management route requested without the required role redirects to store (`kStoreView`).
  /// - Already authenticated users attempting to access login or register are redirected to their appropriate home screen (staff for staff roles, or the requested [from] return route if safe and valid for customers, otherwise store).
  static String? redirectGuard({
    required AuthState authState,
    required String location,
    String? from,
  }) {
    final bool isStaffRoute = location == kStaffDashboardView ||
        location.startsWith('$kStaffDashboardView/');
    final bool isBranchManagementRoute = location == kBranchManagementView ||
        location.startsWith('$kBranchManagementView/');
    final bool isAuthRoute =
        location == kLoginView || location == kRegisterView;

    // Superadmin branch-management protection:
    if (isBranchManagementRoute) {
      if (authState is AuthAuthenticated &&
          authState.user.role == UserRole.superadmin) {
        return null; // Allowed for superadmin
      }
      return kStoreView; // Unauthorized: redirect to store
    }

    // Staff route protection (pharmacist, admin, superadmin):
    if (isStaffRoute) {
      if (authState is AuthAuthenticated) {
        final role = authState.user.role;
        if (role == UserRole.pharmacist ||
            role == UserRole.admin ||
            role == UserRole.superadmin) {
          return null; // Allowed for staff
        }
      }
      return kStoreView; // Unauthorized: redirect to store
    }

    // Auth pages guard when already authenticated
    if (isAuthRoute && authState is AuthAuthenticated) {
      final role = authState.user.role;
      if (role == UserRole.pharmacist ||
          role == UserRole.admin ||
          role == UserRole.superadmin) {
        if (from != null) {
          final safeFrom = sanitizeReturnRoute(from, role);
          if (safeFrom != null) return safeFrom;
        }
        return kStaffDashboardView;
      }

      if (from != null) {
        final safeFrom = sanitizeReturnRoute(from, role);
        if (safeFrom != null) {
          return safeFrom;
        }
      }

      return kStoreView;
    }

    // Store routes and public splash/onboarding routes are allowed
    return null;
  }

  late final GoRouter router = GoRouter(
    initialLocation: _initialLocation ?? kSplashView,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = _activeAuthCubit?.state ?? const AuthGuest();
      return redirectGuard(
        authState: authState,
        location: state.matchedLocation,
        from: state.uri.queryParameters['from'],
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: kSplashView,
        builder: (context, state) => SplashView(
          authCubit: _activeAuthCubit,
          storageService: _activeStorageService,
        ),
      ),
      GoRoute(
        path: kLanguageSelectionView,
        builder: (context, state) => LanguageSelectionScreen(
          storageService: _activeStorageService,
          from: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(
        path: kOnboardingView,
        builder: (context, state) => OnboardingView(
          storageService: _activeStorageService,
        ),
      ),
      GoRoute(
        path: kLoginView,
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return LoginScreen(
            authCubit: _activeAuthCubit,
            from: from,
            onNavigateToRegister: () {
              final uri = from != null && from.isNotEmpty
                  ? Uri(path: kRegisterView, queryParameters: {'from': from}).toString()
                  : kRegisterView;
              context.go(uri);
            },
            onNavigateToGuest: () => context.go(kStoreView),
          );
        },
      ),
      GoRoute(
        path: kRegisterView,
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return RegisterScreen(
            authCubit: _activeAuthCubit,
            from: from,
            onNavigateToLogin: () {
              final uri = from != null && from.isNotEmpty
                  ? Uri(path: kLoginView, queryParameters: {'from': from}).toString()
                  : kLoginView;
              context.go(uri);
            },
          );
        },
      ),
      GoRoute(
        path: kBranchSelectionView,
        builder: (context, state) => const BranchSelectionScreen(),
      ),
      GoRoute(
        path: kStoreView,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: kProductDetailsView,
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          final branchId = state.uri.queryParameters['branchId'];
          return ProductDetailsScreen(
            productId: productId,
            branchId: branchId,
            cartCubit:
                getIt.isRegistered<CartCubit>() ? getIt<CartCubit>() : null,
          );
        },
      ),
      GoRoute(
        path: kBrowseView,
        builder: (context, state) => const BrowsePlaceholderScreen(),
      ),
      GoRoute(
        path: kPrescriptionView,
        builder: (context, state) => AuthRequiredGuard(
          routePath: kPrescriptionView,
          authCubit: _activeAuthCubit,
          child: const MyPrescriptionsScreen(),
        ),
      ),
      GoRoute(
        path: kPrescriptionUploadView,
        builder: (context, state) => AuthRequiredGuard(
          routePath: kPrescriptionUploadView,
          authCubit: _activeAuthCubit,
          child: const UploadPrescriptionScreen(),
        ),
      ),
      GoRoute(
        path: kPrescriptionConfirmationView,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is PrescriptionEntity) {
            return AuthRequiredGuard(
              routePath: kPrescriptionView,
              authCubit: _activeAuthCubit,
              child: PrescriptionSubmittedScreen(prescription: extra),
            );
          }
          return AuthRequiredGuard(
            routePath: kPrescriptionView,
            authCubit: _activeAuthCubit,
            child: const MyPrescriptionsScreen(),
          );
        },
      ),
      GoRoute(
        path: kPrescriptionDetailsView,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is PrescriptionEntity) {
            return AuthRequiredGuard(
              routePath: kPrescriptionView,
              authCubit: _activeAuthCubit,
              child: PrescriptionDetailsScreen(prescription: extra),
            );
          }
          return AuthRequiredGuard(
            routePath: kPrescriptionView,
            authCubit: _activeAuthCubit,
            child: const MyPrescriptionsScreen(),
          );
        },
      ),
      GoRoute(
        path: kOrdersView,
        builder: (context, state) => AuthRequiredGuard(
          routePath: kOrdersView,
          authCubit: _activeAuthCubit,
          child: const MyOrdersScreen(),
        ),
      ),
      GoRoute(
        path: kOrderDetailsView,
        builder: (context, state) {
          final extraOrder = state.extra;
          if (extraOrder is CustomerOrder) {
            return AuthRequiredGuard(
              routePath: kOrdersView,
              authCubit: _activeAuthCubit,
              child: OrderDetailsScreen(order: extraOrder),
            );
          }
          return AuthRequiredGuard(
            routePath: kOrdersView,
            authCubit: _activeAuthCubit,
            child: const MyOrdersScreen(),
          );
        },
      ),
      GoRoute(
        path: kAccountView,
        builder: (context, state) => AccountScreen(
          authCubit: _activeAuthCubit,
          storageService: _activeStorageService,
        ),
      ),
      GoRoute(
        path: kEditProfileView,
        builder: (context, state) => AuthRequiredGuard(
          routePath: kEditProfileView,
          authCubit: _activeAuthCubit,
          child: EditProfileScreen(
            authCubit: _activeAuthCubit,
          ),
        ),
      ),
      GoRoute(
        path: kCartView,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: kCheckoutView,
        builder: (context, state) => AuthRequiredGuard(
          routePath: kCheckoutView,
          authCubit: _activeAuthCubit,
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: kOrderConfirmationView,
        builder: (context, state) {
          final order = state.extra;
          if (order is Order) {
            return OrderConfirmationScreen(order: order);
          }
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: kStaffDashboardView,
        builder: (context, state) => const StaffDashboardPlaceholderScreen(),
      ),
      GoRoute(
        path: kBranchManagementView,
        builder: (context, state) =>
            const BranchManagementPlaceholderScreen(),
      ),
    ],
  );
}

/// Listenable that notifies GoRouter whenever [AuthCubit] emits a new state.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable() {
    if (getIt.isRegistered<AuthCubit>()) {
      _subscription =
          getIt<AuthCubit>().stream.listen((_) => notifyListeners());
    }
  }

  StreamSubscription<dynamic>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
