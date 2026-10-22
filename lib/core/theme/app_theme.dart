import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:index_pharma/core/theme/app_colors.dart';
import 'package:index_pharma/core/theme/app_radii.dart';
import 'package:index_pharma/core/theme/app_spacing.dart';
import 'package:index_pharma/core/theme/app_theme_extensions.dart';
import 'package:index_pharma/core/theme/app_typography.dart';

/// Clinical Clarity App Theme Builder
/// Complete Material 3 Design System implementation
abstract class AppTheme {
  const AppTheme._();

  // ===========================================================================
  // Light Theme
  // ===========================================================================
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryBrand,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      inversePrimary: AppColors.inversePrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      surfaceTint: AppColors.surfaceTint,
    );

    final TextTheme textTheme = AppTypography.createTextTheme(
      primaryText: AppColors.onSurface,
      secondaryText: AppColors.onSurfaceVariant,
      tertiaryText: AppColors.slate500,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      fontFamily: textTheme.bodyMedium?.fontFamily,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvasPure,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.titleLg(color: AppColors.onSurface),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.canvasPure,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.roundedLg,
          side: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated Button Theme (Primary Action - Pill shaped)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrand,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.slate200,
          disabledForegroundColor: AppColors.slate400,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(AppSpacing.minTouchTarget, 52),
          padding: AppSpacing.pButton,
          shape: const StadiumBorder(),
          textStyle: AppTypography.labelLg(color: AppColors.onPrimary),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBrand,
          disabledForegroundColor: AppColors.slate400,
          minimumSize: const Size(AppSpacing.minTouchTarget, 52),
          padding: AppSpacing.pButton,
          side: const BorderSide(color: AppColors.primaryBrand, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: AppTypography.labelLg(color: AppColors.primaryBrand),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBrand,
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: const StadiumBorder(),
          textStyle: AppTypography.labelLg(color: AppColors.primaryBrand),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMd(color: AppColors.slate400),
        labelStyle: AppTypography.bodyMd(color: AppColors.slate600),
        prefixIconColor: AppColors.primaryBrand,
        suffixIconColor: AppColors.slate400,
        border: const OutlineInputBorder(
          borderRadius: AppRadii.roundedBase,
          borderSide: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedBase,
          borderSide: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedBase,
          borderSide: BorderSide(color: AppColors.primaryBrand, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedBase,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedBase,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.brandMintSurface,
        labelStyle: AppTypography.pillBadge(color: AppColors.brandEmeraldDark),
        side: const BorderSide(color: AppColors.brandMintBorder, width: 1),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.canvasPure,
        selectedItemColor: AppColors.primaryBrand,
        unselectedItemColor: AppColors.slate400,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Navigation Bar Theme (M3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.canvasPure,
        indicatorColor: AppColors.brandMintBorder,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.brandEmeraldDark);
          }
          return const IconThemeData(color: AppColors.slate400);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSm(color: AppColors.brandEmeraldDark);
          }
          return AppTypography.labelSm(color: AppColors.slate500);
        }),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.canvasPure,
        modalBackgroundColor: AppColors.canvasPure,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedModalTop),
        elevation: 12,
        clipBehavior: Clip.antiAlias,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.canvasPure,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
        elevation: 12,
        titleTextStyle: AppTypography.headlineMd(color: AppColors.onSurface),
        contentTextStyle: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(color: AppColors.borderSubtle, thickness: 1, space: 1),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBrand,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Extensions
      extensions: const [
        ClinicalThemeExtension.light,
        AppColorsExtension.light,
      ],
    );
  }

  // ===========================================================================
  // Dark Theme
  // ===========================================================================
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.inversePrimary,
      onPrimary: Color(0xFF003825),
      primaryContainer: AppColors.primary,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      inversePrimary: AppColors.primaryBrand,
      secondary: AppColors.darkOnSurface,
      onSecondary: AppColors.darkSurface,
      secondaryContainer: Color(0xFF1E293B),
      onSecondaryContainer: Color(0xFFCBD5E1),
      tertiary: AppColors.brandTealBright,
      onTertiary: Color(0xFF003730),
      tertiaryContainer: AppColors.tertiaryDark,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.darkOutline,
      outlineVariant: Color(0xFF334155),
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: AppColors.darkSurfaceContainerLow,
      surfaceContainer: AppColors.darkSurfaceContainer,
      surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: Color(0xFF334155),
      inverseSurface: AppColors.surfaceBright,
      onInverseSurface: AppColors.onSurface,
      surfaceTint: AppColors.inversePrimary,
    );

    final TextTheme textTheme = AppTypography.createTextTheme(
      primaryText: AppColors.darkOnSurface,
      secondaryText: AppColors.darkOnSurfaceVariant,
      tertiaryText: AppColors.slate400,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      fontFamily: textTheme.bodyMedium?.fontFamily,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.titleLg(color: AppColors.darkOnSurface),
        iconTheme: const IconThemeData(color: AppColors.darkOnSurface),
        shape: const Border(
          bottom: BorderSide(color: AppColors.darkOutline, width: 1.0),
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.roundedLg,
          side: BorderSide(color: AppColors.darkOutline, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.inversePrimary,
          foregroundColor: const Color(0xFF003825),
          disabledBackgroundColor: const Color(0xFF334155),
          disabledForegroundColor: AppColors.slate500,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(AppSpacing.minTouchTarget, 52),
          padding: AppSpacing.pButton,
          shape: const StadiumBorder(),
          textStyle: AppTypography.labelLg(color: const Color(0xFF003825)),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.inversePrimary,
          disabledForegroundColor: AppColors.slate500,
          minimumSize: const Size(AppSpacing.minTouchTarget, 52),
          padding: AppSpacing.pButton,
          side: const BorderSide(color: AppColors.inversePrimary, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: AppTypography.labelLg(color: AppColors.inversePrimary),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.inversePrimary,
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: const StadiumBorder(),
          textStyle: AppTypography.labelLg(color: AppColors.inversePrimary),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMd(color: AppColors.slate500),
        labelStyle: AppTypography.bodyMd(color: AppColors.slate400),
        prefixIconColor: AppColors.inversePrimary,
        suffixIconColor: AppColors.slate400,
        border: const OutlineInputBorder(
          borderRadius: AppRadii.roundedBase,
          borderSide: BorderSide(color: AppColors.darkOutline, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedBase,
          borderSide: BorderSide(color: AppColors.darkOutline, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedBase,
          borderSide: BorderSide(color: AppColors.inversePrimary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedBase,
          borderSide: BorderSide(color: AppColors.medicalRed, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedBase,
          borderSide: BorderSide(color: AppColors.medicalRed, width: 2),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkMintSurface,
        labelStyle: AppTypography.pillBadge(color: AppColors.inversePrimary),
        side: const BorderSide(color: AppColors.darkMintBorder, width: 1),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.inversePrimary,
        unselectedItemColor: AppColors.slate400,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Navigation Bar Theme (M3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.darkMintBorder,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.inversePrimary);
          }
          return const IconThemeData(color: AppColors.slate400);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSm(color: AppColors.inversePrimary);
          }
          return AppTypography.labelSm(color: AppColors.slate400);
        }),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedModalTop),
        elevation: 12,
        clipBehavior: Clip.antiAlias,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
        elevation: 12,
        titleTextStyle: AppTypography.headlineMd(color: AppColors.darkOnSurface),
        contentTextStyle: AppTypography.bodyMd(color: AppColors.darkOnSurfaceVariant),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(color: AppColors.darkOutline, thickness: 1, space: 1),

      // Extensions
      extensions: const [
        ClinicalThemeExtension.dark,
        AppColorsExtension.dark,
      ],
    );
  }
}
