import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_buttons.dart';
import 'package:index_pharma/core/widgets/app_text_fields.dart';
import 'package:index_pharma/features/auth/domain/validators/auth_validators.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import '../utils/auth_failure_mapper.dart';
import 'password_text_field.dart';

/// Interactive Login Form matching the Stitch design specifications.
///
/// Disposes all controllers correctly and scopes BlocBuilder only to the submit button.
class LoginForm extends StatefulWidget {
  final VoidCallback? onNavigateToRegister;

  const LoginForm({super.key, this.onNavigateToRegister});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  String? _credentialsError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (_credentialsError != null) {
      setState(() {
        _credentialsError = null;
      });
    }
  }

  void _submit() {
    if (_credentialsError != null) {
      setState(() {
        _credentialsError = null;
      });
    }
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure && state.failure is Unauthorized) {
          setState(() {
            _credentialsError = AuthFailureMapper.toMessage(state.failure);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        decoration: BoxDecoration(
          color: colors.canvasPure,
          borderRadius: AppRadii.roundedXl,
          boxShadow: context.shadowsLevel1,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Title Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocaleKeys.authLoginCardTitle.tr(),
                          style: AppTypography.titleLg(color: colors.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocaleKeys.authLoginCardSubtitle.tr(),
                          style: AppTypography.bodySm(color: colors.secondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.lock_outline_rounded, color: colors.primaryBrand, size: 24),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceLg),

              // Email Address Field
              AppTextField(
                controller: _emailController,
                label: AppLocaleKeys.authEmailLabel.tr(),
                hintText: AppLocaleKeys.authEmailHint.tr(),
                required: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                textDirection: TextDirection.ltr,
                errorText: _credentialsError != null ? '' : null,
                errorStyle: _credentialsError != null
                    ? const TextStyle(height: 0, fontSize: 0)
                    : null,
                onChanged: (_) => _onFieldChanged(),
                validator: (val) => AuthValidators.validateEmail(val)?.tr(),
                prefix: const Icon(Icons.mail_outline_rounded, size: 20),
              ),
              const SizedBox(height: AppSpacing.spaceMd),

              // Password Field
              PasswordTextField(
                controller: _passwordController,
                label: AppLocaleKeys.authPasswordLabel.tr(),
                hintText: AppLocaleKeys.authPasswordHint.tr(),
                required: true,
                errorText: _credentialsError,
                trailingLabelWidget: Text(
                  AppLocaleKeys.authPasswordSecureHint.tr(),
                  style: AppTypography.labelSm(color: colors.secondary),
                ),
                textInputAction: TextInputAction.done,
                validator: (val) => AuthValidators.validatePassword(val)?.tr(),
                onChanged: (_) => _onFieldChanged(),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.spaceLg),

              // Submit Button - BlocBuilder scoped tightly here
              BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (previous, current) =>
                    (previous is AuthLoading) != (current is AuthLoading),
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return AppButton.primary(
                    text: AppLocaleKeys.authSignInButton.tr(),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    isLoading: isLoading,
                    onPressed: _submit,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.spaceLg),

              // Secondary Link to Registration
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                  vertical: AppSpacing.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: AppRadii.roundedXl,
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocaleKeys.authNoAccountPrompt.tr(),
                      style: AppTypography.bodySm(color: colors.secondary),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    InkWell(
                      onTap: widget.onNavigateToRegister,
                      borderRadius: AppRadii.roundedSm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocaleKeys.authCreateAccountLink.tr(),
                              style: AppTypography.labelMd(color: colors.primaryBrand),
                            ),
                            const SizedBox(width: AppSpacing.space2xs),
                            Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 16,
                              color: colors.primaryBrand,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
