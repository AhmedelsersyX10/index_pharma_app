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
extension ClinicalThemeContextX on BuildContext {
  ClinicalThemeExtension get clinicalTheme =>
      Theme.of(this).extension<ClinicalThemeExtension>() ?? ClinicalThemeExtension.light;
}
