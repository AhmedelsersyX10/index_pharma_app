import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';

/// Screen displayed when a staff member attempts to access a route for which
/// their role or permissions are insufficient (e.g. Prescriptions when `viewPrescriptions=false`).
class StaffAccessDeniedScreen extends StatelessWidget {
  const StaffAccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppPageBar(
        title: AppLocaleKeys.staffAccessDeniedTitle.tr(),
        showBackButton: true,
        onBackPressed: () => context.go(AppRouter.kStaffHomeView),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 36,
                  color: colors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLg),
              Text(
                AppLocaleKeys.staffAccessDeniedTitle.tr(),
                style: AppTypography.titleLg(color: colors.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Text(
                AppLocaleKeys.staffAccessDeniedDesc.tr(),
                style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spaceXl),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRouter.kStaffHomeView),
                icon: const Icon(Icons.home_outlined),
                label: Text(AppLocaleKeys.navSell.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.roundedMd,
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
