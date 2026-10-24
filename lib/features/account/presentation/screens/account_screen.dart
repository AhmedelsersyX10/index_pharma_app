import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';
import 'package:index_pharma/features/home/presentation/widgets/customer_bottom_nav.dart';

import '../widgets/account_guest_view.dart';
import '../widgets/account_preferences_section.dart';
import '../widgets/account_profile_card.dart';
import '../widgets/account_records_section.dart';
import '../widgets/logout_confirmation_dialog.dart';

/// Customer Account screen corresponding to Stitch design D5.
///
/// Features:
/// - Logged-in View: Profile data, single delivery address, edit profile button,
///   orders & prescriptions hub, assigned branch indicator, language switcher,
///   logout flow transitioning state to [AuthGuest].
/// - Guest View: Welcome hero, sign-in/register CTAs, pharmacy benefits,
///   language switcher, licensing info.
/// - Customer bottom navigation bar pinned to tab index 4.
class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    this.authCubit,
    this.storageService,
    this.branchCubit,
  });

  final AuthCubit? authCubit;
  final StorageService? storageService;
  final BranchCubit? branchCubit;

  AuthCubit _resolveAuthCubit(BuildContext context) {
    return authCubit ?? context.read<AuthCubit>();
  }

  StorageService _resolveStorageService(BuildContext context) {
    return storageService ?? context.read<StorageService>();
  }

  BranchCubit? _resolveBranchCubit(BuildContext context) {
    return branchCubit;
  }

  Future<void> _handleLogout(BuildContext context, AuthCubit cubit) async {
    final confirmed = await LogoutConfirmationDialog.show(context);
    if (confirmed == true) {
      await cubit.logout();
    }
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.kStoreView);
      case 1:
        context.go(AppRouter.kBrowseView);
      case 2:
        context.go(AppRouter.kPrescriptionView);
      case 3:
        context.go(AppRouter.kOrdersView);
      case 4:
        break; // Already on Account
    }
  }

  @override
  Widget build(BuildContext context) {
    if (branchCubit != null) {
      return BlocBuilder<BranchCubit, BranchState>(
        bloc: branchCubit,
        builder: (context, state) => _buildScreen(context),
      );
    }
    return _buildScreen(context);
  }

  Widget _buildScreen(BuildContext context) {
    final colors = context.colors;
    final activeAuthCubit = _resolveAuthCubit(context);
    final activeStorageService = _resolveStorageService(context);
    final activeBranchCubit = _resolveBranchCubit(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(title: AppLocaleKeys.accountTitle.tr()),
      body: BlocBuilder<AuthCubit, AuthState>(
        bloc: activeAuthCubit,
        builder: (context, authState) {
          if (authState is AuthLoading) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          if (authState is AuthAuthenticated) {
            return _buildAuthenticatedView(
              context: context,
              user: authState.user,
              authCubit: activeAuthCubit,
              storageService: activeStorageService,
              branchCubit: activeBranchCubit,
            );
          }

          // Guest mode or unauthenticated
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: AccountGuestView(storageService: activeStorageService),
          );
        },
      ),
      bottomNavigationBar: CustomerBottomNav(
        currentIndex: 4,
        onTap: (index) => _onBottomNavTapped(context, index),
      ),
    );
  }

  Widget _buildAuthenticatedView({
    required BuildContext context,
    required dynamic user,
    required AuthCubit authCubit,
    required StorageService storageService,
    required BranchCubit? branchCubit,
  }) {
    // Resolve current branch name from BranchCubit if available
    String? currentBranchName = switch (branchCubit?.state) {
      BranchInitial() || BranchLoading() => 'branch_selection.loading'.tr(),
      BranchFailure() => 'branch_selection.fetch_error_title'.tr(),
      BranchEmpty() => 'branch_selection.empty_branches_title'.tr(),
      _ => null,
    };
    if (branchCubit != null && branchCubit.state is BranchLoaded) {
      final loadedState = branchCubit.state as BranchLoaded;
      final selectedId = loadedState.selectedBranchId;
      if (selectedId != null) {
        final match = loadedState.branches.where((b) => b.id == selectedId);
        if (match.isNotEmpty) {
          currentBranchName = match.first.name;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Card
          AccountProfileCard(
            user: user,
            onEditPressed: () => context.push(AppRouter.kEditProfileView),
          ),
          const SizedBox(height: 20),

          // Clinical & Orders Hub
          AccountRecordsSection(branchName: currentBranchName),
          const SizedBox(height: 20),

          // Preferences & Standards
          AccountPreferencesSection(storageService: storageService),
          const SizedBox(height: 20),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              key: const ValueKey('account_logout_button'),
              onPressed: () => _handleLogout(context, authCubit),
              icon: Icon(
                Icons.logout_rounded,
                color: context.colors.error,
                size: 20,
              ),
              label: Text(
                AppLocaleKeys.accountLogoutBtn.tr(),
                style: AppTypography.labelLg(
                  color: context.colors.error,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.errorContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
