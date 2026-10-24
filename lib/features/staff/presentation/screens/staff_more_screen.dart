import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/features/account/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/services/permission_service.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/staff/presentation/widgets/staff_more_profile_card.dart';
import 'package:index_pharma/features/staff/presentation/widgets/staff_more_section.dart';
import 'package:index_pharma/features/staff/presentation/widgets/staff_more_section_item.dart';

/// Staff More / Account & Management Screen (Stitch G11).
///
/// Provides role- and permission-governed operational actions,
/// management features (reports, branches), preferences, and logout.
class StaffMoreScreen extends StatelessWidget {
  const StaffMoreScreen({super.key});

  bool _can(BuildContext context, String permission) {
    try {
      final permService = RepositoryProvider.of<PermissionService>(context);
      return permService.can(permission);
    } catch (_) {
      try {
        final authState = context.read<AuthCubit>().state;
        final user = authState is AuthAuthenticated ? authState.user : null;
        return PermissionService(user).can(permission);
      } catch (_) {
        return false;
      }
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocaleKeys.staffActionAvailableSoon.tr()),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await LogoutConfirmationDialog.show(context);
    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  Future<void> _handleThemeToggle(BuildContext context) async {
    try {
      final themeCubit = context.read<ThemeCubit>();
      final currentMode = themeCubit.state;
      final nextMode = switch (currentMode) {
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
        ThemeMode.system => ThemeMode.light,
      };
      await themeCubit.updateThemeMode(nextMode);
    } catch (_) {
      _showComingSoon(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final isSuperadmin = user?.role == UserRole.superadmin;
    final canViewReports = _can(context, AppPermissions.viewReports);
    final showManagementSection = canViewReports || isSuperadmin;

    return Scaffold(
      appBar: AppPageBar.noBack(
        title: AppLocaleKeys.staffMoreTitle.tr(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spaceSm),

            // Profile Card
            StaffMoreProfileCard(user: user),
            const SizedBox(height: AppSpacing.spaceLg),

            // 1. Operations Section
            StaffMoreSection(
              title: AppLocaleKeys.staffMoreSectionOperations.tr(),
              children: [
                StaffMoreSectionItem(
                  title: AppLocaleKeys.staffMoreShiftHistory.tr(),
                  subtitle: AppLocaleKeys.staffMoreShiftHistorySub.tr(),
                  icon: Icons.history_rounded,
                  onTap: () => _showComingSoon(context),
                ),
                const Divider(height: 1, indent: 64),
                StaffMoreSectionItem(
                  title: AppLocaleKeys.staffMoreBarcodeAudit.tr(),
                  subtitle: AppLocaleKeys.staffMoreBarcodeAuditSub.tr(),
                  icon: Icons.qr_code_scanner_rounded,
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceLg),

            // 2. Management Section (Role/Permission gated)
            if (showManagementSection) ...[
              StaffMoreSection(
                title: AppLocaleKeys.staffMoreSectionManagement.tr(),
                children: [
                  if (canViewReports) ...[
                    StaffMoreSectionItem(
                      title: AppLocaleKeys.staffMoreReports.tr(),
                      subtitle: AppLocaleKeys.staffMoreReportsSub.tr(),
                      icon: Icons.analytics_outlined,
                      onTap: () => _showComingSoon(context),
                    ),
                    const Divider(height: 1, indent: 64),
                  ],
                  if (isSuperadmin) ...[
                    StaffMoreSectionItem(
                      title: AppLocaleKeys.staffMoreBranches.tr(),
                      subtitle: AppLocaleKeys.staffMoreBranchesSub.tr(),
                      icon: Icons.store_mall_directory_outlined,
                      onTap: () => context.go(AppRouter.kBranchManagementView),
                    ),
                    const Divider(height: 1, indent: 64),
                  ],
                  StaffMoreSectionItem(
                    title: AppLocaleKeys.staffMoreStockAlerts.tr(),
                    subtitle: AppLocaleKeys.staffMoreStockAlertsSub.tr(),
                    icon: Icons.notification_important_outlined,
                    onTap: () => _showComingSoon(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceLg),
            ],

            // 3. Preferences Section
            StaffMoreSection(
              title: AppLocaleKeys.staffMoreSectionPreferences.tr(),
              children: [
                StaffMoreSectionItem(
                  title: AppLocaleKeys.staffMoreLanguage.tr(),
                  subtitle: AppLocaleKeys.staffMoreLanguageSub.tr(),
                  icon: Icons.translate_rounded,
                  onTap: () => context.push(AppRouter.kLanguageSelectionView),
                ),
                const Divider(height: 1, indent: 64),
                StaffMoreSectionItem(
                  title: AppLocaleKeys.staffMoreTheme.tr(),
                  subtitle: AppLocaleKeys.staffMoreThemeSub.tr(),
                  icon: Icons.dark_mode_outlined,
                  onTap: () => _handleThemeToggle(context),
                ),
                const Divider(height: 1, indent: 64),
                StaffMoreSectionItem(
                  title: AppLocaleKeys.staffMoreCompliance.tr(),
                  subtitle: AppLocaleKeys.staffMoreComplianceSub.tr(),
                  icon: Icons.verified_user_outlined,
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceLg),

            // 4. Logout Section
            StaffMoreSection(
              title: '',
              children: [
                StaffMoreSectionItem(
                  title: AppLocaleKeys.staffMoreLogout.tr(),
                  subtitle: AppLocaleKeys.staffMoreLogoutSub.tr(),
                  icon: Icons.logout_rounded,
                  isDestructive: true,
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceXl),

            // Version Footer
            Center(
              child: Text(
                AppLocaleKeys.staffMoreVersion.tr(),
                style: AppTypography.labelSm(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space2xl),
          ],
        ),
      ),
    );
  }
}
