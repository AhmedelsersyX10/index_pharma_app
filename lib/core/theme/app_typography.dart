import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:index_pharma/core/theme/app_colors.dart';

/// Clinical Clarity Typography System
/// Headings: Plus Jakarta Sans
/// Body / Data / Labels: Geist
abstract class AppTypography {
  const AppTypography._();

  // ===========================================================================
  // Raw / Core Typography Styles
  // ===========================================================================

  /// Display Large (Desktop / Tablet): 40px, Bold (w700), Line Height: 48px
  static TextStyle displayLg({Color color = AppColors.onSurface}) => GoogleFonts.plusJakartaSans(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 48 / 40,
    letterSpacing: -0.8, // -0.02em * 40
    color: color,
  );

  /// Display Large (Mobile): 30px, Bold (w700), Line Height: 38px
  static TextStyle displayLgMobile({Color color = AppColors.onSurface}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 38 / 30,
        letterSpacing: -0.45, // -0.015em * 30
        color: color,
      );

  /// Headline Large: 28px, Bold (w700), Line Height: 36px
  static TextStyle headlineLg({Color color = AppColors.onSurface}) => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.42, // -0.015em * 28
    color: color,
  );

  /// Headline Large Mobile: 22px, Bold (w700), Line Height: 30px
  static TextStyle headlineLgMobile({Color color = AppColors.onSurface}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 30 / 22,
        letterSpacing: -0.22, // -0.01em * 22
        color: color,
      );

  /// Headline Medium: 20px, SemiBold (w600), Line Height: 28px
  static TextStyle headlineMd({Color color = AppColors.onSurface}) => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.2, // -0.01em * 20
    color: color,
  );

  /// Title Large: 18px, SemiBold (w600), Line Height: 26px
  static TextStyle titleLg({Color color = AppColors.onSurface}) => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18,
    color: color,
  );

  /// Title Medium: 16px, SemiBold (w600), Line Height: 24px
  static TextStyle titleMd({Color color = AppColors.onSurface}) => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    color: color,
  );

  /// Body Large: 16px, Regular (w400), Line Height: 26px
  static TextStyle bodyLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.geist(fontSize: 16, fontWeight: FontWeight.w400, height: 26 / 16, color: color);

  /// Body Medium: 14px, Regular (w400), Line Height: 22px
  static TextStyle bodyMd({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.geist(fontSize: 14, fontWeight: FontWeight.w400, height: 22 / 14, color: color);

  /// Body Small: 12px, Regular (w400), Line Height: 18px
  static TextStyle bodySm({Color color = AppColors.slate500}) =>
      GoogleFonts.geist(fontSize: 12, fontWeight: FontWeight.w400, height: 18 / 12, color: color);

  /// Label Large: 14px, SemiBold (w600), Line Height: 20px
  static TextStyle labelLg({Color color = AppColors.onSurface}) => GoogleFonts.geist(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.14, // 0.01em * 14
    color: color,
  );

  /// Label Medium: 12px, SemiBold (w600), Line Height: 16px
  static TextStyle labelMd({Color color = AppColors.onSurface}) => GoogleFonts.geist(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.24, // 0.02em * 12
    color: color,
  );

  /// Label Small: 11px, SemiBold (w600), Line Height: 14px
  static TextStyle labelSm({Color color = AppColors.onSurface}) => GoogleFonts.geist(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: 0.44, // 0.04em * 11
    color: color,
  );

  /// Pill badge micro-label with uppercase tracking
  static TextStyle pillBadge({Color color = AppColors.brandEmeraldDark}) => GoogleFonts.geist(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: 0.5,
    color: color,
  );

  /// Generate complete Material 3 TextTheme
  static TextTheme createTextTheme({
    required Color primaryText,
    required Color secondaryText,
    required Color tertiaryText,
  }) {
    return TextTheme(
      displayLarge: displayLg(color: primaryText),
      displayMedium: displayLgMobile(color: primaryText),
      displaySmall: headlineLg(color: primaryText),
      headlineLarge: headlineLg(color: primaryText),
      headlineMedium: headlineLgMobile(color: primaryText),
      headlineSmall: headlineMd(color: primaryText),
      titleLarge: titleLg(color: primaryText),
      titleMedium: titleMd(color: primaryText),
      titleSmall: labelLg(color: primaryText),
      bodyLarge: bodyLg(color: primaryText),
      bodyMedium: bodyMd(color: secondaryText),
      bodySmall: bodySm(color: tertiaryText),
      labelLarge: labelLg(color: primaryText),
      labelMedium: labelMd(color: secondaryText),
      labelSmall: labelSm(color: tertiaryText),
    );
  }
}
