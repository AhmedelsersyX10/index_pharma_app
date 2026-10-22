import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/app_colors.dart';
import 'package:index_pharma/core/theme/app_shadows.dart';

/// Clinical Clarity Custom Theme Extension
/// Provides access to specialized medical/clinical tokens.
class ClinicalThemeExtension extends ThemeExtension<ClinicalThemeExtension> {
  final Color mintSurface;
  final Color mintBorder;
  final Color emeraldDark;
  final Color tealBright;
  final Color canvasPure;
  final Color surfaceSubtle;
  final Color medicalRed;
  final Color medicalAmber;
  final Color medicalGreen;
  final Color borderSubtle;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> interactiveShadow;
  final List<BoxShadow> floatingShadow;

  const ClinicalThemeExtension({
    required this.mintSurface,
    required this.mintBorder,
    required this.emeraldDark,
    required this.tealBright,
    required this.canvasPure,
    required this.surfaceSubtle,
    required this.medicalRed,
    required this.medicalAmber,
    required this.medicalGreen,
    required this.borderSubtle,
    required this.cardShadow,
    required this.interactiveShadow,
    required this.floatingShadow,
  });

  /// Default Light Mode Clinical Tokens
  static const ClinicalThemeExtension light = ClinicalThemeExtension(
    mintSurface: AppColors.brandMintSurface,
    mintBorder: AppColors.brandMintBorder,
    emeraldDark: AppColors.brandEmeraldDark,
    tealBright: AppColors.brandTealBright,
    canvasPure: AppColors.canvasPure,
    surfaceSubtle: AppColors.surfaceSubtle,
    medicalRed: AppColors.medicalRed,
    medicalAmber: AppColors.medicalAmber,
    medicalGreen: AppColors.medicalGreen,
    borderSubtle: AppColors.borderSubtle,
    cardShadow: AppShadows.level1,
    interactiveShadow: AppShadows.level2,
    floatingShadow: AppShadows.level3,
  );

  /// Clinical Dark Mode Tokens
  static const ClinicalThemeExtension dark = ClinicalThemeExtension(
    mintSurface: AppColors.darkMintSurface,
    mintBorder: AppColors.darkMintBorder,
    emeraldDark: AppColors.inversePrimary,
    tealBright: AppColors.brandTealBright,
    canvasPure: AppColors.darkSurface,
    surfaceSubtle: AppColors.darkSurfaceContainerLow,
    medicalRed: AppColors.medicalRed,
    medicalAmber: AppColors.medicalAmber,
    medicalGreen: AppColors.medicalGreen,
    borderSubtle: AppColors.darkOutline,
    cardShadow: AppShadows.darkLevel1,
    interactiveShadow: AppShadows.darkLevel2,
    floatingShadow: AppShadows.darkLevel3,
  );

  @override
  ThemeExtension<ClinicalThemeExtension> copyWith({
    Color? mintSurface,
    Color? mintBorder,
    Color? emeraldDark,
    Color? tealBright,
    Color? canvasPure,
    Color? surfaceSubtle,
    Color? medicalRed,
    Color? medicalAmber,
    Color? medicalGreen,
    Color? borderSubtle,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? interactiveShadow,
    List<BoxShadow>? floatingShadow,
  }) {
    return ClinicalThemeExtension(
      mintSurface: mintSurface ?? this.mintSurface,
      mintBorder: mintBorder ?? this.mintBorder,
      emeraldDark: emeraldDark ?? this.emeraldDark,
      tealBright: tealBright ?? this.tealBright,
      canvasPure: canvasPure ?? this.canvasPure,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      medicalRed: medicalRed ?? this.medicalRed,
      medicalAmber: medicalAmber ?? this.medicalAmber,
      medicalGreen: medicalGreen ?? this.medicalGreen,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      cardShadow: cardShadow ?? this.cardShadow,
      interactiveShadow: interactiveShadow ?? this.interactiveShadow,
      floatingShadow: floatingShadow ?? this.floatingShadow,
    );
  }

  @override
  ThemeExtension<ClinicalThemeExtension> lerp(
    covariant ThemeExtension<ClinicalThemeExtension>? other,
    double t,
  ) {
    if (other is! ClinicalThemeExtension) return this;
    return ClinicalThemeExtension(
      mintSurface: Color.lerp(mintSurface, other.mintSurface, t)!,
      mintBorder: Color.lerp(mintBorder, other.mintBorder, t)!,
      emeraldDark: Color.lerp(emeraldDark, other.emeraldDark, t)!,
      tealBright: Color.lerp(tealBright, other.tealBright, t)!,
      canvasPure: Color.lerp(canvasPure, other.canvasPure, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      medicalRed: Color.lerp(medicalRed, other.medicalRed, t)!,
      medicalAmber: Color.lerp(medicalAmber, other.medicalAmber, t)!,
      medicalGreen: Color.lerp(medicalGreen, other.medicalGreen, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      interactiveShadow: t < 0.5 ? interactiveShadow : other.interactiveShadow,
      floatingShadow: t < 0.5 ? floatingShadow : other.floatingShadow,
    );
  }
}

/// BuildContext helper extension
extension ThemeContextX on BuildContext {
  ClinicalThemeExtension get clinicalTheme =>
      Theme.of(this).extension<ClinicalThemeExtension>() ?? ClinicalThemeExtension.light;

  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  List<BoxShadow> get shadowsLevel1 =>
      isDarkMode ? AppShadows.darkLevel1 : AppShadows.level1;

  List<BoxShadow> get shadowsLevel2 =>
      isDarkMode ? AppShadows.darkLevel2 : AppShadows.level2;

  List<BoxShadow> get shadowsLevel3 =>
      isDarkMode ? AppShadows.darkLevel3 : AppShadows.level3;
}

/// Dynamic Application Colors Theme Extension
///
/// Exposes all design system color tokens dynamically resolved against
/// the current theme brightness (Light vs Dark).
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // Brand & Emerald
  final Color primary;
  final Color primaryBrand;
  final Color brandEmeraldDark;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onPrimaryContainer;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixed;
  final Color onPrimaryFixedVariant;
  final Color surfaceTint;

  // Secondary Deep Slate
  final Color secondary;
  final Color secondaryMuted;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixed;
  final Color onSecondaryFixedVariant;

  // Tertiary Teal
  final Color tertiary;
  final Color tertiaryDark;
  final Color tertiaryContainer;
  final Color onTertiary;
  final Color onTertiaryContainer;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;
  final Color brandTealBright;

  // Surfaces & Backgrounds
  final Color surface;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceVariant;
  final Color background;
  final Color canvasPure;
  final Color surfaceSubtle;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color onBackground;
  final Color inverseSurface;
  final Color inverseOnSurface;

  // Outlines & Borders
  final Color outline;
  final Color outlineVariant;
  final Color borderSubtle;

  // Clinical Mint Washes
  final Color brandMintSurface;
  final Color brandMintBorder;

  // Semantic & Medical
  final Color medicalRed;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color medicalAmber;
  final Color medicalGreen;
  final Color medicalBlue;

  // Badges
  final Color badgeWarningBg;
  final Color badgeWarningText;
  final Color badgeInfoBg;
  final Color badgeInfoText;
  final Color badgePurpleBg;
  final Color badgePurpleText;
  final Color badgeSuccessBg;
  final Color badgeSuccessText;
  final Color badgeErrorBg;
  final Color badgeErrorText;

  /// Neutral slate badge tokens dynamically resolved for current theme brightness
  Color get badgeNeutralBg => slate100;
  Color get badgeNeutralText => slate700;

  // Slate & Neutral
  final Color slate50;
  final Color slate100;
  final Color slate200;
  final Color slate300;
  final Color slate400;
  final Color slate500;
  final Color slate600;
  final Color slate700;
  final Color slate800;
  final Color slate900;
  final Color neutral;

  const AppColorsExtension({
    required this.primary,
    required this.primaryBrand,
    required this.brandEmeraldDark,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixed,
    required this.onPrimaryFixedVariant,
    required this.surfaceTint,
    required this.secondary,
    required this.secondaryMuted,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixed,
    required this.onSecondaryFixedVariant,
    required this.tertiary,
    required this.tertiaryDark,
    required this.tertiaryContainer,
    required this.onTertiary,
    required this.onTertiaryContainer,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    required this.brandTealBright,
    required this.surface,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceVariant,
    required this.background,
    required this.canvasPure,
    required this.surfaceSubtle,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onBackground,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.outline,
    required this.outlineVariant,
    required this.borderSubtle,
    required this.brandMintSurface,
    required this.brandMintBorder,
    required this.medicalRed,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.medicalAmber,
    required this.medicalGreen,
    required this.medicalBlue,
    required this.badgeWarningBg,
    required this.badgeWarningText,
    required this.badgeInfoBg,
    required this.badgeInfoText,
    required this.badgePurpleBg,
    required this.badgePurpleText,
    required this.badgeSuccessBg,
    required this.badgeSuccessText,
    required this.badgeErrorBg,
    required this.badgeErrorText,
    required this.slate50,
    required this.slate100,
    required this.slate200,
    required this.slate300,
    required this.slate400,
    required this.slate500,
    required this.slate600,
    required this.slate700,
    required this.slate800,
    required this.slate900,
    required this.neutral,
  });

  /// Light Mode tokens — 100% identical to current static AppColors.
  static const AppColorsExtension light = AppColorsExtension(
    primary: AppColors.primary,
    primaryBrand: AppColors.primaryBrand,
    brandEmeraldDark: AppColors.brandEmeraldDark,
    primaryContainer: AppColors.primaryContainer,
    onPrimary: AppColors.onPrimary,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    inversePrimary: AppColors.inversePrimary,
    primaryFixed: AppColors.primaryFixed,
    primaryFixedDim: AppColors.primaryFixedDim,
    onPrimaryFixed: AppColors.onPrimaryFixed,
    onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
    surfaceTint: AppColors.surfaceTint,

    secondary: AppColors.secondary,
    secondaryMuted: AppColors.secondaryMuted,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    secondaryFixed: AppColors.secondaryFixed,
    secondaryFixedDim: AppColors.secondaryFixedDim,
    onSecondaryFixed: AppColors.onSecondaryFixed,
    onSecondaryFixedVariant: AppColors.onSecondaryFixedVariant,

    tertiary: AppColors.tertiary,
    tertiaryDark: AppColors.tertiaryDark,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiary: AppColors.onTertiary,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    tertiaryFixed: AppColors.tertiaryFixed,
    tertiaryFixedDim: AppColors.tertiaryFixedDim,
    onTertiaryFixed: AppColors.onTertiaryFixed,
    onTertiaryFixedVariant: AppColors.onTertiaryFixedVariant,
    brandTealBright: AppColors.brandTealBright,

    surface: AppColors.surface,
    surfaceDim: AppColors.surfaceDim,
    surfaceBright: AppColors.surfaceBright,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    surfaceVariant: AppColors.surfaceVariant,
    background: AppColors.background,
    canvasPure: AppColors.canvasPure,
    surfaceSubtle: AppColors.surfaceSubtle,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    onBackground: AppColors.onBackground,
    inverseSurface: AppColors.inverseSurface,
    inverseOnSurface: AppColors.inverseOnSurface,

    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    borderSubtle: AppColors.borderSubtle,

    brandMintSurface: AppColors.brandMintSurface,
    brandMintBorder: AppColors.brandMintBorder,

    medicalRed: AppColors.medicalRed,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    medicalAmber: AppColors.medicalAmber,
    medicalGreen: AppColors.medicalGreen,
    medicalBlue: AppColors.medicalBlue,

    badgeWarningBg: AppColors.badgeWarningBg,
    badgeWarningText: AppColors.badgeWarningText,
    badgeInfoBg: AppColors.badgeInfoBg,
    badgeInfoText: AppColors.badgeInfoText,
    badgePurpleBg: AppColors.badgePurpleBg,
    badgePurpleText: AppColors.badgePurpleText,
    badgeSuccessBg: AppColors.badgeSuccessBg,
    badgeSuccessText: AppColors.badgeSuccessText,
    badgeErrorBg: AppColors.badgeErrorBg,
    badgeErrorText: AppColors.badgeErrorText,

    slate50: AppColors.slate50,
    slate100: AppColors.slate100,
    slate200: AppColors.slate200,
    slate300: AppColors.slate300,
    slate400: AppColors.slate400,
    slate500: AppColors.slate500,
    slate600: AppColors.slate600,
    slate700: AppColors.slate700,
    slate800: AppColors.slate800,
    slate900: AppColors.slate900,
    neutral: AppColors.neutral,
  );

  /// Dark Mode tokens — High contrast, WCAG AA compliant clinical palette.
  static const AppColorsExtension dark = AppColorsExtension(
    primary: AppColors.inversePrimary,
    primaryBrand: AppColors.inversePrimary,
    brandEmeraldDark: AppColors.inversePrimary,
    primaryContainer: AppColors.primary,
    onPrimary: Color(0xFF003825),
    onPrimaryContainer: AppColors.onPrimaryContainer,
    inversePrimary: AppColors.primaryBrand,
    primaryFixed: AppColors.primaryFixed,
    primaryFixedDim: AppColors.primaryFixedDim,
    onPrimaryFixed: AppColors.onPrimaryFixed,
    onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
    surfaceTint: AppColors.inversePrimary,

    secondary: AppColors.darkOnSurface,
    secondaryMuted: Color(0xFF94A3B8),
    onSecondary: AppColors.darkSurface,
    secondaryContainer: Color(0xFF1E293B),
    onSecondaryContainer: Color(0xFFCBD5E1),
    secondaryFixed: Color(0xFF1E293B),
    secondaryFixedDim: Color(0xFF334155),
    onSecondaryFixed: Color(0xFFE2E8F0),
    onSecondaryFixedVariant: Color(0xFF94A3B8),

    tertiary: AppColors.brandTealBright,
    tertiaryDark: AppColors.tertiaryDark,
    tertiaryContainer: AppColors.tertiaryDark,
    onTertiary: Color(0xFF003730),
    onTertiaryContainer: AppColors.onTertiaryContainer,
    tertiaryFixed: Color(0xFF005048),
    tertiaryFixedDim: Color(0xFF003730),
    onTertiaryFixed: AppColors.brandTealBright,
    onTertiaryFixedVariant: Color(0xFF71F8E4),
    brandTealBright: AppColors.brandTealBright,

    surface: AppColors.darkSurface,
    surfaceDim: Color(0xFF0B1424),
    surfaceBright: Color(0xFF19253C),
    surfaceContainerLowest: AppColors.darkBackground,
    surfaceContainerLow: AppColors.darkSurfaceContainerLow,
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
    surfaceContainerHighest: Color(0xFF334155),
    surfaceVariant: Color(0xFF1E293B),
    background: AppColors.darkBackground,
    canvasPure: AppColors.darkSurface,
    surfaceSubtle: AppColors.darkSurfaceContainerLow,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    onBackground: AppColors.darkOnSurface,
    inverseSurface: Color(0xFFF8F9FF),
    inverseOnSurface: Color(0xFF0B1C30),

    outline: AppColors.darkOutline,
    outlineVariant: Color(0xFF334155),
    borderSubtle: AppColors.darkOutline,

    brandMintSurface: AppColors.darkMintSurface,
    brandMintBorder: AppColors.darkMintBorder,

    medicalRed: Color(0xFFFF6B6B),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    medicalAmber: Color(0xFFFBBF24),
    medicalGreen: Color(0xFF34D399),
    medicalBlue: Color(0xFF60A5FA),

    badgeWarningBg: Color(0xFF452203),
    badgeWarningText: Color(0xFFFDE68A),
    badgeInfoBg: Color(0xFF0C3859),
    badgeInfoText: Color(0xFFBAE6FD),
    badgePurpleBg: Color(0xFF38186D),
    badgePurpleText: Color(0xFFDDD6FE),
    badgeSuccessBg: Color(0xFF063B2C),
    badgeSuccessText: Color(0xFFA7F3D0),
    badgeErrorBg: Color(0xFF4C0F12),
    badgeErrorText: Color(0xFFFECACA),

    slate50: Color(0xFF0F172A),
    slate100: Color(0xFF1E293B),
    slate200: Color(0xFF334155),
    slate300: Color(0xFF475569),
    slate400: Color(0xFF64748B),
    slate500: Color(0xFF94A3B8),
    slate600: Color(0xFFCBD5E1),
    slate700: Color(0xFFE2E8F0),
    slate800: Color(0xFFF1F5F9),
    slate900: Color(0xFFF8FAFC),
    neutral: Color(0xFF94A3B8),
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primary,
    Color? primaryBrand,
    Color? brandEmeraldDark,
    Color? primaryContainer,
    Color? onPrimary,
    Color? onPrimaryContainer,
    Color? inversePrimary,
    Color? primaryFixed,
    Color? primaryFixedDim,
    Color? onPrimaryFixed,
    Color? onPrimaryFixedVariant,
    Color? surfaceTint,
    Color? secondary,
    Color? secondaryMuted,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? secondaryFixed,
    Color? secondaryFixedDim,
    Color? onSecondaryFixed,
    Color? onSecondaryFixedVariant,
    Color? tertiary,
    Color? tertiaryDark,
    Color? tertiaryContainer,
    Color? onTertiary,
    Color? onTertiaryContainer,
    Color? tertiaryFixed,
    Color? tertiaryFixedDim,
    Color? onTertiaryFixed,
    Color? onTertiaryFixedVariant,
    Color? brandTealBright,
    Color? surface,
    Color? surfaceDim,
    Color? surfaceBright,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? surfaceVariant,
    Color? background,
    Color? canvasPure,
    Color? surfaceSubtle,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? onBackground,
    Color? inverseSurface,
    Color? inverseOnSurface,
    Color? outline,
    Color? outlineVariant,
    Color? borderSubtle,
    Color? brandMintSurface,
    Color? brandMintBorder,
    Color? medicalRed,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? medicalAmber,
    Color? medicalGreen,
    Color? medicalBlue,
    Color? badgeWarningBg,
    Color? badgeWarningText,
    Color? badgeInfoBg,
    Color? badgeInfoText,
    Color? badgePurpleBg,
    Color? badgePurpleText,
    Color? badgeSuccessBg,
    Color? badgeSuccessText,
    Color? badgeErrorBg,
    Color? badgeErrorText,
    Color? slate50,
    Color? slate100,
    Color? slate200,
    Color? slate300,
    Color? slate400,
    Color? slate500,
    Color? slate600,
    Color? slate700,
    Color? slate800,
    Color? slate900,
    Color? neutral,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryBrand: primaryBrand ?? this.primaryBrand,
      brandEmeraldDark: brandEmeraldDark ?? this.brandEmeraldDark,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      primaryFixedDim: primaryFixedDim ?? this.primaryFixedDim,
      onPrimaryFixed: onPrimaryFixed ?? this.onPrimaryFixed,
      onPrimaryFixedVariant: onPrimaryFixedVariant ?? this.onPrimaryFixedVariant,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      secondary: secondary ?? this.secondary,
      secondaryMuted: secondaryMuted ?? this.secondaryMuted,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      secondaryFixed: secondaryFixed ?? this.secondaryFixed,
      secondaryFixedDim: secondaryFixedDim ?? this.secondaryFixedDim,
      onSecondaryFixed: onSecondaryFixed ?? this.onSecondaryFixed,
      onSecondaryFixedVariant: onSecondaryFixedVariant ?? this.onSecondaryFixedVariant,
      tertiary: tertiary ?? this.tertiary,
      tertiaryDark: tertiaryDark ?? this.tertiaryDark,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiary: onTertiary ?? this.onTertiary,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim ?? this.tertiaryFixedDim,
      onTertiaryFixed: onTertiaryFixed ?? this.onTertiaryFixed,
      onTertiaryFixedVariant: onTertiaryFixedVariant ?? this.onTertiaryFixedVariant,
      brandTealBright: brandTealBright ?? this.brandTealBright,
      surface: surface ?? this.surface,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      surfaceContainerLowest: surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      background: background ?? this.background,
      canvasPure: canvasPure ?? this.canvasPure,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      onBackground: onBackground ?? this.onBackground,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      inverseOnSurface: inverseOnSurface ?? this.inverseOnSurface,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      brandMintSurface: brandMintSurface ?? this.brandMintSurface,
      brandMintBorder: brandMintBorder ?? this.brandMintBorder,
      medicalRed: medicalRed ?? this.medicalRed,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      medicalAmber: medicalAmber ?? this.medicalAmber,
      medicalGreen: medicalGreen ?? this.medicalGreen,
      medicalBlue: medicalBlue ?? this.medicalBlue,
      badgeWarningBg: badgeWarningBg ?? this.badgeWarningBg,
      badgeWarningText: badgeWarningText ?? this.badgeWarningText,
      badgeInfoBg: badgeInfoBg ?? this.badgeInfoBg,
      badgeInfoText: badgeInfoText ?? this.badgeInfoText,
      badgePurpleBg: badgePurpleBg ?? this.badgePurpleBg,
      badgePurpleText: badgePurpleText ?? this.badgePurpleText,
      badgeSuccessBg: badgeSuccessBg ?? this.badgeSuccessBg,
      badgeSuccessText: badgeSuccessText ?? this.badgeSuccessText,
      badgeErrorBg: badgeErrorBg ?? this.badgeErrorBg,
      badgeErrorText: badgeErrorText ?? this.badgeErrorText,
      slate50: slate50 ?? this.slate50,
      slate100: slate100 ?? this.slate100,
      slate200: slate200 ?? this.slate200,
      slate300: slate300 ?? this.slate300,
      slate400: slate400 ?? this.slate400,
      slate500: slate500 ?? this.slate500,
      slate600: slate600 ?? this.slate600,
      slate700: slate700 ?? this.slate700,
      slate800: slate800 ?? this.slate800,
      slate900: slate900 ?? this.slate900,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryBrand: Color.lerp(primaryBrand, other.primaryBrand, t)!,
      brandEmeraldDark: Color.lerp(brandEmeraldDark, other.brandEmeraldDark, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      primaryFixedDim: Color.lerp(primaryFixedDim, other.primaryFixedDim, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      onPrimaryFixedVariant: Color.lerp(onPrimaryFixedVariant, other.onPrimaryFixedVariant, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryMuted: Color.lerp(secondaryMuted, other.secondaryMuted, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      secondaryContainer: Color.lerp(secondaryContainer, other.secondaryContainer, t)!,
      onSecondaryContainer: Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t)!,
      secondaryFixed: Color.lerp(secondaryFixed, other.secondaryFixed, t)!,
      secondaryFixedDim: Color.lerp(secondaryFixedDim, other.secondaryFixedDim, t)!,
      onSecondaryFixed: Color.lerp(onSecondaryFixed, other.onSecondaryFixed, t)!,
      onSecondaryFixedVariant: Color.lerp(onSecondaryFixedVariant, other.onSecondaryFixedVariant, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      tertiaryDark: Color.lerp(tertiaryDark, other.tertiaryDark, t)!,
      tertiaryContainer: Color.lerp(tertiaryContainer, other.tertiaryContainer, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      onTertiaryContainer: Color.lerp(onTertiaryContainer, other.onTertiaryContainer, t)!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
      tertiaryFixedDim: Color.lerp(tertiaryFixedDim, other.tertiaryFixedDim, t)!,
      onTertiaryFixed: Color.lerp(onTertiaryFixed, other.onTertiaryFixed, t)!,
      onTertiaryFixedVariant: Color.lerp(onTertiaryFixedVariant, other.onTertiaryFixedVariant, t)!,
      brandTealBright: Color.lerp(brandTealBright, other.brandTealBright, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      surfaceContainerLowest: Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      background: Color.lerp(background, other.background, t)!,
      canvasPure: Color.lerp(canvasPure, other.canvasPure, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      inverseOnSurface: Color.lerp(inverseOnSurface, other.inverseOnSurface, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      brandMintSurface: Color.lerp(brandMintSurface, other.brandMintSurface, t)!,
      brandMintBorder: Color.lerp(brandMintBorder, other.brandMintBorder, t)!,
      medicalRed: Color.lerp(medicalRed, other.medicalRed, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(onErrorContainer, other.onErrorContainer, t)!,
      medicalAmber: Color.lerp(medicalAmber, other.medicalAmber, t)!,
      medicalGreen: Color.lerp(medicalGreen, other.medicalGreen, t)!,
      medicalBlue: Color.lerp(medicalBlue, other.medicalBlue, t)!,
      badgeWarningBg: Color.lerp(badgeWarningBg, other.badgeWarningBg, t)!,
      badgeWarningText: Color.lerp(badgeWarningText, other.badgeWarningText, t)!,
      badgeInfoBg: Color.lerp(badgeInfoBg, other.badgeInfoBg, t)!,
      badgeInfoText: Color.lerp(badgeInfoText, other.badgeInfoText, t)!,
      badgePurpleBg: Color.lerp(badgePurpleBg, other.badgePurpleBg, t)!,
      badgePurpleText: Color.lerp(badgePurpleText, other.badgePurpleText, t)!,
      badgeSuccessBg: Color.lerp(badgeSuccessBg, other.badgeSuccessBg, t)!,
      badgeSuccessText: Color.lerp(badgeSuccessText, other.badgeSuccessText, t)!,
      badgeErrorBg: Color.lerp(badgeErrorBg, other.badgeErrorBg, t)!,
      badgeErrorText: Color.lerp(badgeErrorText, other.badgeErrorText, t)!,
      slate50: Color.lerp(slate50, other.slate50, t)!,
      slate100: Color.lerp(slate100, other.slate100, t)!,
      slate200: Color.lerp(slate200, other.slate200, t)!,
      slate300: Color.lerp(slate300, other.slate300, t)!,
      slate400: Color.lerp(slate400, other.slate400, t)!,
      slate500: Color.lerp(slate500, other.slate500, t)!,
      slate600: Color.lerp(slate600, other.slate600, t)!,
      slate700: Color.lerp(slate700, other.slate700, t)!,
      slate800: Color.lerp(slate800, other.slate800, t)!,
      slate900: Color.lerp(slate900, other.slate900, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }
}
