import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/utils/go_router_refresh_stream.dart';
import 'package:index_pharma/core/widgets/route_placeholder_screens.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/auth/presentation/screens/login_screen.dart';
import 'package:index_pharma/features/auth/presentation/screens/register_screen.dart';
import 'package:index_pharma/features/choose_branches/presentation/screens/branch_selection_screen.dart';
import 'package:index_pharma/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:index_pharma/features/splash/presentation/view/splash_view.dart';

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
  static const kOnboardingView = '/onboardingView';
  static const kStoreView = '/store';
  static const kBranchSelectionView = '/choose-branch';
  static const kLoginView = '/login';
  static const kRegisterView = '/register';
  static const kStaffDashboardView = '/staff';
  static const kBranchManagementView = '/admin/branches';

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

  /// Pure routing guard to determine redirect destinations based on authentication state and current path.
  ///
  /// Rules:
  /// - Guests and customers are allowed on store routes (`kStoreView`) and auth routes (`kLoginView`, `kRegisterView`).
  /// - Pharmacists and Admins can access staff routes (`kStaffDashboardView`).
  /// - Superadmins can access staff routes (`kStaffDashboardView`) plus branch-management routes (`kBranchManagementView`).
  /// - Any staff route or branch-management route requested without the required role redirects to store (`kStoreView`).
  /// - Already authenticated users attempting to access login or register are redirected to their appropriate home screen (staff for staff roles, store for customers).
  static String? redirectGuard({
    required AuthState authState,
    required String location,
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
        return kStaffDashboardView;
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
        path: kOnboardingView,
        builder: (context, state) => OnboardingView(
          storageService: _activeStorageService,
        ),
      ),
      GoRoute(
        path: kLoginView,
        builder: (context, state) => LoginScreen(
          authCubit: _activeAuthCubit,
          onNavigateToRegister: () => context.go(kRegisterView),
          onNavigateToGuest: () => context.go(kStoreView),
        ),
      ),
      GoRoute(
        path: kRegisterView,
        builder: (context, state) => RegisterScreen(
          authCubit: _activeAuthCubit,
          onNavigateToLogin: () => context.go(kLoginView),
        ),
      ),
      GoRoute(
        path: kBranchSelectionView,
        builder: (context, state) => const BranchSelectionScreen(),
      ),
      GoRoute(
        path: kStoreView,
        builder: (context, state) => const StorePlaceholderScreen(),
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
