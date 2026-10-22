import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/features/auth/presentation/widgets/login_required_prompt.dart';

/// A route & widget guard that displays [child] only when the user is authenticated.
///
/// If the current state is [AuthGuest] or unauthenticated, it displays [fallback] or
/// renders the clinical [LoginRequiredPrompt] screen (per Stitch A4).
///
/// Follows project architectural rules:
/// - Evaluates purely by reading [AuthCubit.state].
/// - Contains no business or validation logic inside [build].
class AuthRequiredGuard extends StatelessWidget {
  const AuthRequiredGuard({
    super.key,
    required this.child,
    required this.routePath,
    this.authCubit,
    this.fallback,
  });

  /// The widget tree rendered when the active session is [AuthAuthenticated].
  final Widget child;

  /// The route path being protected (e.g. `/orders`, `/prescription`, `/account`, `/checkout`).
  final String routePath;

  /// Optional explicitly provided [AuthCubit] (useful for isolated widget testing).
  final AuthCubit? authCubit;

  /// Optional fallback widget rendered when unauthenticated.
  final Widget? fallback;

  AuthCubit _resolveCubit(BuildContext context) {
    return authCubit ?? context.read<AuthCubit>();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _resolveCubit(context);
    final authState = cubit.state;

    if (authState is AuthAuthenticated) {
      return child;
    }

    return fallback ??
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppPageBar.transparent(),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceLg,
                  vertical: AppSpacing.spaceSm,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: LoginRequiredPrompt(
                    returnRoute: routePath,
                    isBottomSheet: false,
                    onDismiss: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go(AppRouter.kStoreView);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
  }
}
