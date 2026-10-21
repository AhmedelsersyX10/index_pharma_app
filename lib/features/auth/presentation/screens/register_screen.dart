import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import '../widgets/auth_failure_banner.dart';
import '../widgets/clinical_trust_footer.dart';
import '../widgets/register_form.dart';

/// Clinical Customer Registration Screen adhering to Stitch Design specifications (A2_Register).
class RegisterScreen extends StatefulWidget {
  final AuthCubit? authCubit;
  final VoidCallback? onNavigateToLogin;
  final ValueChanged<UserEntity>? onRegisterSuccess;

  const RegisterScreen({
    super.key,
    this.authCubit,
    this.onNavigateToLogin,
    this.onRegisterSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Failure? _dismissedFailure;

  @override
  Widget build(BuildContext context) {
    final cubit = widget.authCubit ?? context.read<AuthCubit>();

    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppLocaleKeys.commonSkip.tr(),
                )
              : null,
        ),
        body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                widget.onRegisterSuccess?.call(state.user);
              }
            },
            builder: (context, state) {
              final activeFailure = (state is AuthFailure && state.failure != _dismissedFailure)
                  ? state.failure
                  : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceLg,
                  vertical: AppSpacing.spaceSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Badge & Clinical Portal Title
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.brandMintSurface,
                        borderRadius: AppRadii.roundedFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.brandEmeraldDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space2xs),
                          Text(
                            AppLocaleKeys.authRegisterBadge.tr(),
                            style: AppTypography.labelSm(color: AppColors.brandEmeraldDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    Text(
                      AppLocaleKeys.authRegisterTitle.tr(),
                      style: AppTypography.headlineLg(color: AppColors.onSurface),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Text(
                      AppLocaleKeys.authRegisterSubtitle.tr(),
                      style: AppTypography.bodyMd(color: AppColors.secondary),
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // Failure Alert Banner (if any)
                    if (activeFailure != null)
                      AuthFailureBanner(
                        failure: activeFailure,
                        isLogin: false,
                        onDismiss: () {
                          setState(() {
                            _dismissedFailure = activeFailure;
                          });
                        },
                        onAction: widget.onNavigateToLogin,
                      ),

                    // Main Customer Registration Form
                    const RegisterForm(),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // Medical Confidentiality & Security Reassurance
                    const ClinicalTrustFooter(isDetailed: true),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // Footer Link Back to Login
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocaleKeys.authAlreadyHaveAccount.tr(),
                            style: AppTypography.bodyMd(color: AppColors.secondary),
                          ),
                          InkWell(
                            onTap: widget.onNavigateToLogin,
                            borderRadius: AppRadii.roundedSm,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocaleKeys.authSignInLink.tr(),
                                    style: AppTypography.labelLg(color: AppColors.primaryBrand),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: AppColors.primaryBrand,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
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
