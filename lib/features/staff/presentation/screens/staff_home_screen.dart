import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_card.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/features/staff/presentation/widgets/staff_header_bar.dart';
import 'package:index_pharma/features/staff/presentation/widgets/staff_quick_actions.dart';
import 'package:index_pharma/features/staff/presentation/widgets/staff_shift_status_card.dart';

/// Staff Home Screen corresponding to Stitch E1 design.
///
/// Serves as the primary operational dashboard for Pharmacists, Admins, and Superadmins.
class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppPageBar.noBack(
        title: AppLocaleKeys.staffHomeTitle.tr(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StaffHeaderBar(),
            const SizedBox(height: AppSpacing.spaceXs),
            const StaffShiftStatusCard(),
            const SizedBox(height: AppSpacing.spaceLg),
            const StaffQuickActions(),
            const SizedBox(height: AppSpacing.spaceXl),

            // Today's Overview Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
              child: Text(
                AppLocaleKeys.staffHomeTodayOverview.tr(),
                style: AppTypography.titleMd(color: colors.onSurface).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
              child: Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: AppLocaleKeys.staffHomeMetricSales.tr(),
                      value: '—',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: _MetricTile(
                      label: AppLocaleKeys.staffHomeMetricOrders.tr(),
                      value: '—',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: _MetricTile(
                      label: AppLocaleKeys.staffHomeMetricPendingRx.tr(),
                      value: '—',
                      icon: Icons.hourglass_empty_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space2xl),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm, vertical: AppSpacing.spaceMd),
      child: Column(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.headlineMd(color: colors.onSurface).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSm(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
