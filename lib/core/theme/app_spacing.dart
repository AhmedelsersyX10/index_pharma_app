import 'package:flutter/material.dart';

/// Clinical Clarity Spacing & Layout Rhythm
/// Built on an 8pt rhythm with 4pt increments.
abstract class AppSpacing {
  const AppSpacing._();

  // ===========================================================================
  // Spacing Tokens
  // ===========================================================================
  /// 2px (0.125rem)
  static const double space2xs = 2.0;

  /// 4px (0.25rem)
  static const double spaceXs = 4.0;

  /// 8px (0.5rem)
  static const double spaceSm = 8.0;

  /// 12px (0.75rem - inner gutter)
  static const double gutterSm = 12.0;

  /// 16px (1.0rem - base gutter & mobile margin)
  static const double spaceMd = 16.0;
  static const double gutter = 16.0;
  static const double marginMobile = 16.0;

  /// 24px (1.5rem - section gap & gutter-lg)
  static const double spaceLg = 24.0;
  static const double gutterLg = 24.0;

  /// 32px (2.0rem - tablet canvas margin)
  static const double spaceXl = 32.0;
  static const double marginTablet = 32.0;

  /// 48px (3.0rem - desktop canvas margin)
  static const double space2xl = 48.0;
  static const double marginDesktop = 48.0;

  /// Minimum accessible interactive touch target area (44px)
  static const double minTouchTarget = 44.0;

  // ===========================================================================
  // SizedBox Spacers (Vertical)
  // ===========================================================================
  static const SizedBox vSpace2xs = SizedBox(height: space2xs);
  static const SizedBox vSpaceXs = SizedBox(height: spaceXs);
  static const SizedBox vSpaceSm = SizedBox(height: spaceSm);
  static const SizedBox vSpace12 = SizedBox(height: gutterSm);
  static const SizedBox vSpaceMd = SizedBox(height: spaceMd);
  static const SizedBox vSpaceLg = SizedBox(height: spaceLg);
  static const SizedBox vSpaceXl = SizedBox(height: spaceXl);
  static const SizedBox vSpace2xl = SizedBox(height: space2xl);

  // ===========================================================================
  // SizedBox Spacers (Horizontal)
  // ===========================================================================
  static const SizedBox hSpace2xs = SizedBox(width: space2xs);
  static const SizedBox hSpaceXs = SizedBox(width: spaceXs);
  static const SizedBox hSpaceSm = SizedBox(width: spaceSm);
  static const SizedBox hSpace12 = SizedBox(width: gutterSm);
  static const SizedBox hSpaceMd = SizedBox(width: spaceMd);
  static const SizedBox hSpaceLg = SizedBox(width: spaceLg);
  static const SizedBox hSpaceXl = SizedBox(width: spaceXl);
  static const SizedBox hSpace2xl = SizedBox(width: space2xl);

  // ===========================================================================
  // EdgeInsets Presets
  // ===========================================================================
  static const EdgeInsets p2xs = EdgeInsets.all(space2xs);
  static const EdgeInsets pXs = EdgeInsets.all(spaceXs);
  static const EdgeInsets pSm = EdgeInsets.all(spaceSm);
  static const EdgeInsets pMd = EdgeInsets.all(spaceMd);
  static const EdgeInsets pLg = EdgeInsets.all(spaceLg);
  static const EdgeInsets pXl = EdgeInsets.all(spaceXl);

  static const EdgeInsets pH16 = EdgeInsets.symmetric(horizontal: spaceMd);
  static const EdgeInsets pH24 = EdgeInsets.symmetric(horizontal: spaceLg);
  static const EdgeInsets pH32 = EdgeInsets.symmetric(horizontal: spaceXl);

  static const EdgeInsets pV8 = EdgeInsets.symmetric(vertical: spaceSm);
  static const EdgeInsets pV12 = EdgeInsets.symmetric(vertical: gutterSm);
  static const EdgeInsets pV16 = EdgeInsets.symmetric(vertical: spaceMd);
  static const EdgeInsets pV24 = EdgeInsets.symmetric(vertical: spaceLg);

  static const EdgeInsets pScreenMobile = EdgeInsets.symmetric(
    horizontal: marginMobile,
    vertical: spaceMd,
  );

  static const EdgeInsets pCard = EdgeInsets.all(spaceMd);
  static const EdgeInsets pBadge = EdgeInsets.symmetric(horizontal: 12, vertical: 4);
  static const EdgeInsets pButton = EdgeInsets.symmetric(horizontal: 24, vertical: 14);
}
