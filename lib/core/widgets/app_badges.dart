import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// WCAG AAA Clinical Status Badge Tones
/// Derived from Stitch Design System (C6 & F8 Status Matrices).
enum AppBadgeTone {
  /// Warning / Pending (خلفية صفراء هادئة #FEF3C7 مع نص كهرماني #92400E)
  warning,

  /// Info / Processing (خلفية سماوية #E0F2FE مع نص أزرق سريري #0369A1)
  info,

  /// Purple / Packed (خلفية بنفسجية ناعمة #EDE9FE مع نص بنفسجي ملكي #6D28D9)
  purple,

  /// Success / Delivered (خلفية زمردية #ECFDF5 مع نص أخضر داكن #047857)
  success,

  /// Error / Cancelled / Rejected (خلفية وردية هادئة #FEF2F2 مع نص أحمر سريري #B91C1C)
  error,

  /// Neutral Slate for specifications / metadata (e.g. 500 mg, 10 tablets)
  neutral,

  /// Mint surface with emerald text & border ("100% Genuine", "Free Delivery")
  trust,

  /// Solid amber badge for promotions / alerts
  offer,

  /// Solid red urgent badge
  urgent,
}

/// Backwards compatibility alias
typedef AppBadgeVariant = AppBadgeTone;

/// Clinical Clarity Pill Badges & Chips
/// Generic status badge supporting label + tone, optional icon, and custom padding.
/// Follows Stitch C6 & F8 specifications (WCAG AAA >= 7:1 contrast).
class AppBadge extends StatelessWidget {
  final String label;
  final Widget? icon;
  final AppBadgeTone tone;
  final EdgeInsetsGeometry? padding;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = AppBadgeTone.neutral,
    AppBadgeVariant? variant,
    this.padding,
  });

  /// Generic tone constructor
  const AppBadge.tone({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.padding,
  });

  /// Warning / Pending tone
  const AppBadge.warning({super.key, required this.label, this.icon, this.padding})
      : tone = AppBadgeTone.warning;

  /// Info / Processing tone
  const AppBadge.info({super.key, required this.label, this.icon, this.padding})
      : tone = AppBadgeTone.info;

  /// Purple / Packed tone
  const AppBadge.purple({super.key, required this.label, this.icon, this.padding})
      : tone = AppBadgeTone.purple;

  /// Success / Delivered tone
  const AppBadge.success({super.key, required this.label, this.icon, this.padding})
      : tone = AppBadgeTone.success;

  /// Error / Cancelled tone
  const AppBadge.error({super.key, required this.label, this.icon, this.padding})
      : tone = AppBadgeTone.error;

  /// Mint surface with emerald text & border ("100% Genuine", "Prescription Required")
  const AppBadge.trust({super.key, required this.label, this.icon, this.padding})
      : tone = AppBadgeTone.trust;

  /// Amber badge for discounts, offers, or alerts
  const AppBadge.offer({super.key, required this.label, this.icon, this.padding})
      : tone = AppBadgeTone.offer;

  /// Urgent red badge for warnings or out of stock
  const AppBadge.urgent({super.key, required this.label, this.icon, this.padding})
      : tone = AppBadgeTone.urgent;

  /// Neutral slate badge for dosage details (e.g., "500 mg", "10 tablets")
  const AppBadge.neutral({super.key, required this.label, this.icon, this.padding})
      : tone = AppBadgeTone.neutral;

  /// Backwards compatibility getter
  AppBadgeTone get variant => tone;

  @override
  Widget build(BuildContext context) {
    final (Color bgColor, Color borderColor, Color textColor) = switch (tone) {
      AppBadgeTone.warning => (
        AppColors.badgeWarningBg,
        Colors.transparent,
        AppColors.badgeWarningText,
      ),
      AppBadgeTone.info => (
        AppColors.badgeInfoBg,
        Colors.transparent,
        AppColors.badgeInfoText,
      ),
      AppBadgeTone.purple => (
        AppColors.badgePurpleBg,
        Colors.transparent,
        AppColors.badgePurpleText,
      ),
      AppBadgeTone.success => (
        AppColors.badgeSuccessBg,
        Colors.transparent,
        AppColors.badgeSuccessText,
      ),
      AppBadgeTone.error => (
        AppColors.badgeErrorBg,
        Colors.transparent,
        AppColors.badgeErrorText,
      ),
      AppBadgeTone.trust => (
        AppColors.brandMintSurface,
        AppColors.brandMintBorder,
        AppColors.brandEmeraldDark,
      ),
      AppBadgeTone.offer => (
        AppColors.medicalAmber,
        Colors.transparent,
        Colors.white,
      ),
      AppBadgeTone.urgent => (
        AppColors.medicalRed,
        Colors.transparent,
        Colors.white,
      ),
      AppBadgeTone.neutral => (
        AppColors.slate100,
        AppColors.slate200,
        AppColors.slate700,
      ),
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
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(size: 14, color: textColor),
              child: icon!,
            ),
            const SizedBox(width: AppSpacing.spaceXs),
          ],
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
