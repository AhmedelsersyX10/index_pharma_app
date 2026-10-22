import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Clarity Button System
/// Adheres strictly to DESIGN.md button specifications.
class AppButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final AppButtonStyle variant;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52.0,
    this.variant = AppButtonStyle.primary,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52.0,
  }) : variant = AppButtonStyle.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52.0,
  }) : variant = AppButtonStyle.secondary;

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52.0,
  }) : variant = AppButtonStyle.outlined;

  const AppButton.prescriptionUpload({
    super.key,
    this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52.0,
  }) : variant = AppButtonStyle.prescriptionUpload;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final String displayText = text ??
        (variant == AppButtonStyle.prescriptionUpload
            ? AppLocaleKeys.commonUploadPrescription.tr()
            : '');

    final Widget buttonChild = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor(colors)),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.spaceSm)],
              Text(displayText, style: _getTextStyle(colors)),
            ],
          );

    final Widget buttonWidget = switch (variant) {
      AppButtonStyle.primary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryBrand,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.slate200,
          disabledForegroundColor: colors.slate400,
          minimumSize: Size(isFullWidth ? double.infinity : AppSpacing.minTouchTarget, height),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: buttonChild,
      ),
      AppButtonStyle.secondary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.secondary,
          foregroundColor: colors.onSecondary,
          disabledBackgroundColor: colors.slate200,
          disabledForegroundColor: colors.slate400,
          minimumSize: Size(isFullWidth ? double.infinity : AppSpacing.minTouchTarget, height),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: buttonChild,
      ),
      AppButtonStyle.outlined => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryBrand,
          side: BorderSide(color: colors.primaryBrand, width: 1.5),
          minimumSize: Size(isFullWidth ? double.infinity : AppSpacing.minTouchTarget, height),
          shape: const StadiumBorder(),
        ),
        child: buttonChild,
      ),
      AppButtonStyle.prescriptionUpload => Container(
        decoration: BoxDecoration(
          color: colors.brandMintSurface,
          borderRadius: AppRadii.roundedFull,
          border: Border.all(color: colors.primaryBrand, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadii.roundedFull,
            onTap: isLoading ? null : onPressed,
            child: Container(
              constraints: BoxConstraints(
                minHeight: height,
                minWidth: isFullWidth ? double.infinity : AppSpacing.minTouchTarget,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: buttonChild,
            ),
          ),
        ),
      ),
    };

    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: height, child: buttonWidget);
    }

    return SizedBox(height: height, child: buttonWidget);
  }

  Color _getLoadingColor(AppColorsExtension colors) {
    switch (variant) {
      case AppButtonStyle.primary:
      case AppButtonStyle.secondary:
        return Colors.white;
      case AppButtonStyle.outlined:
      case AppButtonStyle.prescriptionUpload:
        return colors.brandEmeraldDark;
    }
  }

  TextStyle _getTextStyle(AppColorsExtension colors) {
    switch (variant) {
      case AppButtonStyle.primary:
      case AppButtonStyle.secondary:
        return AppTypography.labelLg(color: Colors.white);
      case AppButtonStyle.outlined:
        return AppTypography.labelLg(color: colors.primaryBrand);
      case AppButtonStyle.prescriptionUpload:
        return AppTypography.labelLg(color: colors.brandEmeraldDark);
    }
  }
}

enum AppButtonStyle { primary, secondary, outlined, prescriptionUpload }
