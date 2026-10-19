import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Clarity Pill Badges & Chips
/// Adheres strictly to DESIGN.md Chips & Badges specifications.
class AppBadge extends StatelessWidget {
  final String label;
  final Widget? icon;
  final AppBadgeVariant variant;
  final EdgeInsetsGeometry? padding;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = AppBadgeVariant.trust,
    this.padding,
  });

  /// Mint surface with emerald text & border ("100% Genuine", "Free Delivery", "Prescription Required")
  const AppBadge.trust({super.key, required this.label, this.icon, this.padding})
    : variant = AppBadgeVariant.trust;

  /// Amber badge for discounts, offers, or alerts
  const AppBadge.offer({super.key, required this.label, this.icon, this.padding})
    : variant = AppBadgeVariant.offer;

  /// Urgent red badge for prescription warnings or out of stock
  const AppBadge.urgent({super.key, required this.label, this.icon, this.padding})
    : variant = AppBadgeVariant.urgent;

  /// Neutral slate badge for dosage details (e.g., "500 mg", "10 tablets")
  const AppBadge.neutral({super.key, required this.label, this.icon, this.padding})
    : variant = AppBadgeVariant.neutral;

  @override
  Widget build(BuildContext context) {
    final (Color bgColor, Color borderColor, Color textColor) = switch (variant) {
      AppBadgeVariant.trust => (
        AppColors.brandMintSurface,
        AppColors.brandMintBorder,
        AppColors.brandEmeraldDark,
      ),
      AppBadgeVariant.offer => (AppColors.medicalAmber, Colors.transparent, Colors.white),
      AppBadgeVariant.urgent => (AppColors.medicalRed, Colors.transparent, Colors.white),
      AppBadgeVariant.neutral => (AppColors.slate100, AppColors.slate200, AppColors.slate700),
    };

    return Container(
      padding: padding ?? AppSpacing.pBadge,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.roundedFull,
        border: borderColor == Colors.transparent ? null : Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.spaceXs)],
          Flexible(
            child: Text(
              label,
              style: AppTypography.pillBadge(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

enum AppBadgeVariant { trust, offer, urgent, neutral }
