import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';

/// Placeholder screen for Staff Prescriptions tab (`/staff/prescriptions`).
class StaffPrescriptionsPlaceholderScreen extends StatelessWidget {
  const StaffPrescriptionsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppPageBar.noBack(
        title: AppLocaleKeys.staffPrescriptionsPlaceholderTitle.tr(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medication_outlined,
                size: 64,
                color: colors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              Text(
                AppLocaleKeys.staffPrescriptionsPlaceholderTitle.tr(),
                style: AppTypography.titleLg(color: colors.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spaceXs),
              Text(
                AppLocaleKeys.placeholdersUnderConstruction.tr(),
                style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
