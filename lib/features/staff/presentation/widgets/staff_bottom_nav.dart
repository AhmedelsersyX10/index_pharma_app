import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/auth/domain/services/permission_service.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';

/// Data class representing a staff bottom navigation item.
class _StaffNavItemDef {
  const _StaffNavItemDef({
    required this.route,
    required this.labelKey,
    required this.icon,
    required this.activeIcon,
  });

  final String route;
  final String labelKey;
  final IconData icon;
  final IconData activeIcon;
}

/// Role-aware staff bottom navigation bar conforming to Stitch E1 & G11 designs.
///
/// Features up to 5 tabs:
/// 1. Sell / POS (`/staff/home`)
/// 2. Orders (`/staff/orders`)
/// 3. Prescriptions (`/staff/prescriptions`) — hidden if `viewPrescriptions` is false
/// 4. Products / Inventory (`/staff/products`)
/// 5. More / Management (`/staff/more`)
class StaffBottomNav extends StatelessWidget {
  const StaffBottomNav({
    super.key,
    required this.currentLocation,
    required this.onTapRoute,
  });

  final String currentLocation;
  final ValueChanged<String> onTapRoute;

  bool _canViewPrescriptions(BuildContext context) {
    try {
      final permService = RepositoryProvider.of<PermissionService>(context);
      return permService.can(AppPermissions.viewPrescriptions);
    } catch (_) {
      try {
        final authState = context.read<AuthCubit>().state;
        final user = authState is AuthAuthenticated ? authState.user : null;
        return PermissionService(user).can(AppPermissions.viewPrescriptions);
      } catch (_) {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final showPrescriptions = _canViewPrescriptions(context);

    final items = <_StaffNavItemDef>[
      const _StaffNavItemDef(
        route: AppRouter.kStaffHomeView,
        labelKey: AppLocaleKeys.navSell,
        icon: Icons.point_of_sale_outlined,
        activeIcon: Icons.point_of_sale,
      ),
      const _StaffNavItemDef(
        route: AppRouter.kStaffOrdersView,
        labelKey: AppLocaleKeys.navOrders,
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
      ),
      if (showPrescriptions)
        const _StaffNavItemDef(
          route: AppRouter.kStaffPrescriptionsView,
          labelKey: AppLocaleKeys.navPrescription,
          icon: Icons.medication_outlined,
          activeIcon: Icons.medication,
        ),
      const _StaffNavItemDef(
        route: AppRouter.kStaffProductsView,
        labelKey: AppLocaleKeys.navBrowse,
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
      ),
      const _StaffNavItemDef(
        route: AppRouter.kStaffMoreView,
        labelKey: AppLocaleKeys.staffMoreTitle,
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, -2),
            blurRadius: 12,
          ),
        ],
        border: Border(
          top: BorderSide(
            color: colors.borderSubtle.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isSelected = currentLocation == item.route ||
                  (item.route != AppRouter.kStaffHomeView &&
                      currentLocation.startsWith('${item.route}/'));

              final color = isSelected ? colors.primary : colors.onSurfaceVariant;

              return Expanded(
                child: InkWell(
                  onTap: () => onTapRoute(item.route),
                  borderRadius: AppRadii.roundedLg,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 24,
                          color: color,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.labelKey.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSm(
                            color: color,
                          ).copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
