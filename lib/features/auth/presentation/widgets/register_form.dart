import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_buttons.dart';
import 'package:index_pharma/core/widgets/app_text_fields.dart';
import 'package:index_pharma/features/auth/domain/validators/auth_validators.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'password_text_field.dart';

/// Clinical Customer Registration Form matching Stitch design specifications.
///
/// Ensures name, email, and password validation while phone and address remain optional.
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();

      context.read<AuthCubit>().register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phone: phone.isNotEmpty ? phone : null,
            address: address.isNotEmpty ? address : null,
          );
    }
  }

  Widget _buildOptionalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadii.roundedFull,
      ),
      child: Text(
        AppLocaleKeys.authOptionalBadge.tr(),
        style: AppTypography.labelSm(color: AppColors.secondary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: AppRadii.roundedXl,
        boxShadow: AppShadows.level1,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name (Required)
            AppTextField(
              controller: _nameController,
              label: '${AppLocaleKeys.authNameLabel.tr()} *',
              hintText: AppLocaleKeys.authNameHint.tr(),
              textInputAction: TextInputAction.next,
              validator: (val) => AuthValidators.validateName(val)?.tr(),
              prefix: const Padding(
                padding: EdgeInsetsDirectional.only(start: 12, end: 8),
                child: Icon(Icons.person_outline_rounded, color: AppColors.slate400, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Email Address (Required)
            AppTextField(
              controller: _emailController,
              label: '${AppLocaleKeys.authEmailLabel.tr()} *',
              hintText: AppLocaleKeys.authEmailHint.tr(),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.ltr,
              validator: (val) => AuthValidators.validateEmail(val)?.tr(),
              prefix: const Padding(
                padding: EdgeInsetsDirectional.only(start: 12, end: 8),
                child: Icon(Icons.mail_outline_rounded, color: AppColors.slate400, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Phone Number (Optional)
            AppTextField(
              controller: _phoneController,
              label: AppLocaleKeys.authPhoneLabel.tr(),
              trailingLabelWidget: _buildOptionalBadge(),
              hintText: AppLocaleKeys.authPhoneHint.tr(),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.ltr,
              helper: Text(
                AppLocaleKeys.authPhoneNote.tr(),
                style: AppTypography.bodySm(color: AppColors.slate500),
              ),
              prefix: Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇪🇬', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '+20',
                      style: AppTypography.labelMd(color: AppColors.onSurface),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Delivery Address (Optional)
            AppTextField(
              controller: _addressController,
              label: AppLocaleKeys.authAddressLabel.tr(),
              trailingLabelWidget: _buildOptionalBadge(),
              hintText: AppLocaleKeys.authAddressHint.tr(),
              maxLines: 2,
              textInputAction: TextInputAction.next,
              prefix: const Padding(
                padding: EdgeInsetsDirectional.only(start: 12, end: 8),
                child: Icon(Icons.pin_drop_outlined, color: AppColors.slate400, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Password (Required >= 8 characters)
            PasswordTextField(
              controller: _passwordController,
              label: '${AppLocaleKeys.authPasswordLabel.tr()} *',
              hintText: '••••••••••••',
              textInputAction: TextInputAction.done,
              validator: (val) => AuthValidators.validatePassword(val)?.tr(),
              helper: Row(
                children: [
                  const Icon(
                    Icons.lock_clock_outlined,
                    size: 14,
                    color: AppColors.primaryBrand,
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  Text(
                    AppLocaleKeys.authPasswordRequirement.tr(),
                    style: AppTypography.bodySm(color: AppColors.slate500),
                  ),
                ],
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.spaceLg),

            // Primary Action Button (Scoped BlocBuilder)
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  (previous is AuthLoading) != (current is AuthLoading),
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return AppButton.primary(
                  text: AppLocaleKeys.authRegisterButton.tr(),
                  icon: const Icon(Icons.how_to_reg_outlined, size: 18),
                  isLoading: isLoading,
                  onPressed: _submit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
