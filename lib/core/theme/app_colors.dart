import 'package:flutter/material.dart';

/// Clinical Clarity Design System Color Palette
/// Derived from DESIGN.md
abstract class AppColors {
  const AppColors._();

  // ===========================================================================
  // Brand & Primary Emerald Tones
  // ===========================================================================
  /// Core primary emerald (#00694A / #00966B)
  static const Color primary = Color(0xFF00694A);
  static const Color primaryBrand = Color(0xFF00966B);
  static const Color brandEmeraldDark = Color(0xFF007A55);
  static const Color primaryContainer = Color(0xFF00855E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFF5FFF7);
  static const Color inversePrimary = Color(0xFF67DBAB);
  static const Color primaryFixed = Color(0xFF84F8C6);
  static const Color primaryFixedDim = Color(0xFF67DBAB);
  static const Color onPrimaryFixed = Color(0xFF002114);
  static const Color onPrimaryFixedVariant = Color(0xFF005138);
  static const Color surfaceTint = Color(0xFF006C4C);

  // ===========================================================================
  // Secondary Deep Medical Slate Tones
  // ===========================================================================
  /// Authoritative deep slate (#0F172A)
  static const Color secondary = Color(0xFF0F172A);
  static const Color secondaryMuted = Color(0xFF565E74);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDAE2FD);
  static const Color onSecondaryContainer = Color(0xFF5C647A);
  static const Color secondaryFixed = Color(0xFFDAE2FD);
  static const Color secondaryFixedDim = Color(0xFFBEC6E0);
  static const Color onSecondaryFixed = Color(0xFF131B2E);
  static const Color onSecondaryFixedVariant = Color(0xFF3F465C);

  // ===========================================================================
  // Tertiary Vibrant Teal Tones
  // ===========================================================================
  static const Color tertiary = Color(0xFF14B8A6);
  static const Color tertiaryDark = Color(0xFF00685D);
  static const Color tertiaryContainer = Color(0xFF008376);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFF4FFFB);
  static const Color tertiaryFixed = Color(0xFF71F8E4);
  static const Color tertiaryFixedDim = Color(0xFF4FDBC8);
  static const Color onTertiaryFixed = Color(0xFF00201C);
  static const Color onTertiaryFixedVariant = Color(0xFF005048);
  static const Color brandTealBright = Color(0xFF5EEAD4);

  // ===========================================================================
  // Surfaces & Backgrounds
  // ===========================================================================
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color surfaceVariant = Color(0xFFD3E4FE);
  static const Color background = Color(0xFFF8F9FF);
  static const Color canvasPure = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);

  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF3D4A43);
  static const Color onBackground = Color(0xFF0B1C30);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  // ===========================================================================
  // Outlines & Borders
  // ===========================================================================
  static const Color outline = Color(0xFF6D7A72);
  static const Color outlineVariant = Color(0xFFBCCAC1);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  // ===========================================================================
  // Clinical Mint Washes
  // ===========================================================================
  static const Color brandMintSurface = Color(0xFFF0FDF9);
  static const Color brandMintBorder = Color(0xFFCCFBF1);

  // ===========================================================================
  // Semantic & Medical Status Indicators
  // ===========================================================================
  static const Color medicalRed = Color(0xFFEF4444);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color medicalAmber = Color(0xFFF59E0B);
  static const Color medicalGreen = Color(0xFF10B981);
  static const Color medicalBlue = Color(0xFF3B82F6);

  // ===========================================================================
  // WCAG AAA Clinical Status Badge Tones (Stitch C6 & F8)
  // ===========================================================================
  static const Color badgeWarningBg = Color(0xFFFEF3C7);
  static const Color badgeWarningText = Color(0xFF92400E);
  static const Color badgeInfoBg = Color(0xFFE0F2FE);
  static const Color badgeInfoText = Color(0xFF0369A1);
  static const Color badgePurpleBg = Color(0xFFEDE9FE);
  static const Color badgePurpleText = Color(0xFF6D28D9);
  static const Color badgeSuccessBg = Color(0xFFECFDF5);
  static const Color badgeSuccessText = Color(0xFF047857);
  static const Color badgeErrorBg = Color(0xFFFEF2F2);
  static const Color badgeErrorText = Color(0xFFB91C1C);

  // ===========================================================================
  // Neutral Slate Palette
  // ===========================================================================
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color neutral = Color(0xFF64748B);

  // ===========================================================================
  // Dark Mode Overrides & Tones
  // ===========================================================================
  static const Color darkBackground = Color(0xFF0A101D);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkSurfaceContainerLow = Color(0xFF141E34);
  static const Color darkSurfaceContainer = Color(0xFF1E293B);
  static const Color darkSurfaceContainerHigh = Color(0xFF27354D);
  static const Color darkOnSurface = Color(0xFFEAF1FF);
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);
  static const Color darkOutline = Color(0xFF475569);
  static const Color darkMintSurface = Color(0xFF062D24);
  static const Color darkMintBorder = Color(0xFF0A4739);
}
