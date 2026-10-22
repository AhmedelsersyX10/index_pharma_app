import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_failure_banner.dart';
import '../widgets/clinical_trust_footer.dart';
import '../widgets/guest_access_card.dart';
import '../widgets/login_form.dart';

/// Clinical Login Screen built according to Stitch Design specifications (A1_Login).
class LoginScreen extends StatefulWidget {
  final AuthCubit? authCubit;
  final VoidCallback? onNavigateToRegister;
  final VoidCallback? onNavigateToGuest;
  final ValueChanged<UserEntity>? onLoginSuccess;
  final String? from;

  const LoginScreen({
    super.key,
    this.authCubit,
    this.onNavigateToRegister,
    this.onNavigateToGuest,
    this.onLoginSuccess,
    this.from,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Failure? _dismissedFailure;

  @override
  Widget build(BuildContext context) {
    final cubit = widget.authCubit ?? context.read<AuthCubit>();

    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppPageBar.transparent(),
        body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                widget.onLoginSuccess?.call(state.user);
                final role = state.user.role;
                final isStaff = role == UserRole.pharmacist ||
                    role == UserRole.admin ||
                    role == UserRole.superadmin;
                final safeFrom = widget.from != null
                    ? AppRouter.sanitizeReturnRoute(widget.from!, role)
                    : null;
                final target = safeFrom ??
                    (isStaff
                        ? AppRouter.kStaffDashboardView
                        : AppRouter.kStoreView);
                context.go(target);
              }
            },
            builder: (context, state) {
              final activeFailure = (state is AuthFailure &&
                      state.failure != _dismissedFailure &&
                      state.failure is! Unauthorized)
                  ? state.failure
                  : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceLg,
                  vertical: AppSpacing.spaceSm,
                ),
                child: Column(
                  children: [
                    // Brand Logo, Titles & Regulatory Badge
                    const AuthBrandHeader(),

                    // Failure Alert Banner (if any)
                    if (activeFailure != null)
                      AuthFailureBanner(
                        failure: activeFailure,
                        isLogin: true,
                        onDismiss: () {
                          setState(() {
                            _dismissedFailure = activeFailure;
                          });
                        },
                      ),

                    // Main Interactive Login Form
                    LoginForm(
                      onNavigateToRegister: widget.onNavigateToRegister,
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // Guest Browsing Card
                    GuestAccessCard(
                      onGuestTap: widget.onNavigateToGuest,
                    ),

                    // Security & Encryption Reassurance
                    const ClinicalTrustFooter(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
