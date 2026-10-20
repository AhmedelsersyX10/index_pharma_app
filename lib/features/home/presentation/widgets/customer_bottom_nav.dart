import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Customer bottom navigation bar conforming to Decision 0.6 and Stitch B2 design.
///
/// Features:
/// 1. Home (`/store`)
/// 2. Browse (`/browse`)
/// 3. Prescription (`/prescription`) - Elevated center floating button
/// 4. My Orders (`/orders`)
/// 5. Account (`/account`)
///
/// Strictly no "Deals" tab per Decision 0.6.
class CustomerBottomNav extends StatelessWidget {
  const CustomerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.96),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, -2),
            blurRadius: 12,
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.borderSubtle.withValues(alpha: 0.6),
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
            children: [
              // 0: Home
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: AppLocaleKeys.navHome.tr(),
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),

              // 1: Browse
              _NavItem(
                icon: Icons.grid_view_rounded,
                activeIcon: Icons.grid_view_rounded,
                label: AppLocaleKeys.navBrowse.tr(),
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),

              // 2: Prescription (Elevated Center Button)
              _CenterPrescriptionNavItem(
                label: AppLocaleKeys.navPrescription.tr(),
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),

              // 3: My Orders
              _NavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: AppLocaleKeys.navOrders.tr(),
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),

              // 4: Account
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: AppLocaleKeys.navAccount.tr(),
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.roundedLg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSm(
                color: color,
              ).copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterPrescriptionNavItem extends StatelessWidget {
  const _CenterPrescriptionNavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.roundedFull,
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSm(
                color: AppColors.primary,
              ).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
