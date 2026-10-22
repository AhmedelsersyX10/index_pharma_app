import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/errors/failure_mapper.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/features/auth/domain/validators/auth_validators.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';

/// Screen for editing customer name, mobile phone number, and delivery address (Stitch D6).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.authCubit,
    this.branchCubit,
  });

  final AuthCubit? authCubit;
  final BranchCubit? branchCubit;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  bool _isSaving = false;

  AuthCubit _resolveAuthCubit() {
    return widget.authCubit ?? context.read<AuthCubit>();
  }

  BranchCubit? _resolveBranchCubit() {
    return widget.branchCubit;
  }

  @override
  void initState() {
    super.initState();
    final authState = _resolveAuthCubit().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final cubit = _resolveAuthCubit();

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    final result = await cubit.updateProfile(
      name: name.isNotEmpty ? name : null,
      phone: phone.isNotEmpty ? phone : '',
      address: address.isNotEmpty ? address : '',
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocaleKeys.editProfileSuccess.tr()),
            backgroundColor: context.colors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _popSafely();
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              FailureMapper.toMessage(
                failure,
                defaultFallback: AppLocaleKeys.authErrorServer.tr(),
              ),
            ),
            backgroundColor: context.colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _popSafely() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeBranchCubit = _resolveBranchCubit();
    String? currentBranchName;
    if (activeBranchCubit != null && activeBranchCubit.state is BranchLoaded) {
      final loadedState = activeBranchCubit.state as BranchLoaded;
      final selectedId = loadedState.selectedBranchId;
      if (selectedId != null) {
        final match = loadedState.branches.where((b) => b.id == selectedId);
        if (match.isNotEmpty) {
          currentBranchName = match.first.name;
        }
      }
      currentBranchName ??= loadedState.branches.isNotEmpty ? loadedState.branches.first.name : null;
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(
        title: AppLocaleKeys.editProfileTitle.tr(),
        onBackPressed: _popSafely,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colors.primary,
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Reassurance Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.borderSubtle.withValues(alpha: 0.6),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x080B1C30),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.brandMintSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_shipping_outlined,
                        color: colors.brandEmeraldDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocaleKeys.editProfileReassuranceTitle.tr(),
                            style: AppTypography.titleMd(
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            AppLocaleKeys.editProfileReassuranceDesc.tr(),
                            style: AppTypography.bodySm(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Full Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocaleKeys.editProfileNameLabel.tr(),
                            style: AppTypography.labelLg(
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '*',
                            style: TextStyle(
                              color: colors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppLocaleKeys.editProfileNameSub.tr(),
                        style: AppTypography.labelSm(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const ValueKey('edit_profile_name_field'),
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: AppLocaleKeys.editProfileNameHint.tr(),
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: colors.onSurfaceVariant,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.borderSubtle.withValues(alpha: 0.6),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.borderSubtle.withValues(alpha: 0.6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.error),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) {
                      final key = AuthValidators.validateName(value);
                      return key?.tr();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Phone Number Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocaleKeys.editProfilePhoneLabel.tr(),
                            style: AppTypography.labelLg(
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '*',
                            style: TextStyle(
                              color: colors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppLocaleKeys.editProfilePhoneSub.tr(),
                        style: AppTypography.labelSm(
                          color: colors.primary,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const ValueKey('edit_profile_phone_field'),
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: AppLocaleKeys.editProfilePhoneHint.tr(),
                      prefixIcon: Container(
                        margin: const EdgeInsetsDirectional.only(start: 8, end: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇪🇬', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '+20',
                              style: AppTypography.labelSm(
                                color: colors.onSurfaceVariant,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.borderSubtle.withValues(alpha: 0.6),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.borderSubtle.withValues(alpha: 0.6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.error),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) {
                      final key = AuthValidators.validatePhone(
                        value,
                        isRequired: true,
                      );
                      return key?.tr();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Delivery Address Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocaleKeys.editProfileAddressLabel.tr(),
                        style: AppTypography.labelLg(
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: TextStyle(
                          color: colors.error,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const ValueKey('edit_profile_address_field'),
                    controller: _addressController,
                    minLines: 3,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: AppLocaleKeys.editProfileAddressHint.tr(),
                      filled: true,
                      fillColor: colors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.borderSubtle.withValues(alpha: 0.6),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.borderSubtle.withValues(alpha: 0.6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.error),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                    validator: (value) {
                      final key = AuthValidators.validateAddress(
                        value,
                        isRequired: true,
                      );
                      return key?.tr();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Trust & Privacy Shield Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.brandMintSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.brandMintBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: colors.brandEmeraldDark,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocaleKeys.editProfilePrivacyShield.tr(),
                        style: AppTypography.bodySm(
                          color: colors.brandEmeraldDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Delivery Pharmacy Partner Context Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.borderSubtle.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.brandMintSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.local_pharmacy_outlined,
                        color: colors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocaleKeys.editProfileBranchCardTitle.tr(),
                            style: AppTypography.titleMd(
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentBranchName ?? AppLocaleKeys.accountNotSet.tr(),
                            style: AppTypography.bodySm(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.brandMintSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocaleKeys.editProfileBranchVerified.tr(),
                        style: AppTypography.labelSm(
                          color: colors.brandEmeraldDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const ValueKey('edit_profile_save_btn'),
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isSaving
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppLocaleKeys.editProfileSavingBtn.tr(),
                              style: AppTypography.labelLg(color: Colors.white),
                            ),
                          ],
                        )
                      : Text(
                          AppLocaleKeys.editProfileSaveBtn.tr(),
                          style: AppTypography.labelLg(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  key: const ValueKey('edit_profile_cancel_btn'),
                  onPressed: _popSafely,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    AppLocaleKeys.editProfileCancelBtn.tr(),
                    style: AppTypography.labelLg(color: colors.secondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
