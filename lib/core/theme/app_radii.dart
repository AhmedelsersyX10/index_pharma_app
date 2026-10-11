import 'package:flutter/material.dart';

/// Clinical Clarity Shape & Radius Definitions
/// Balanced Rounded (2) geometry with medicinal capsule-inspired pill badges.
abstract class AppRadii {
  const AppRadii._();

  // ===========================================================================
  // Radius Values
  // ===========================================================================
  /// 4px (0.25rem)
  static const double sm = 4.0;

  /// 8px (0.5rem) - Base / Form controls & Inputs
  static const double base = 8.0;

  /// 12px (0.75rem)
  static const double md = 12.0;

  /// 16px (1.0rem) - Cards & Medical Containers
  static const double lg = 16.0;

  /// 24px (1.5rem) - Bottom Sheets & Modals
  static const double xl = 24.0;

  /// 9999px - Capsule Pill geometry (Buttons, Badges, Chips)
  static const double full = 9999.0;

  // ===========================================================================
  // Radius Objects
  // ===========================================================================
  static const Radius rSm = Radius.circular(sm);
  static const Radius rBase = Radius.circular(base);
  static const Radius rMd = Radius.circular(md);
  static const Radius rLg = Radius.circular(lg);
  static const Radius rXl = Radius.circular(xl);
  static const Radius rFull = Radius.circular(full);

  // ===========================================================================
  // BorderRadius Objects
  // ===========================================================================
  static const BorderRadius roundedSm = BorderRadius.all(rSm);
  static const BorderRadius roundedBase = BorderRadius.all(rBase);
  static const BorderRadius roundedMd = BorderRadius.all(rMd);
  static const BorderRadius roundedLg = BorderRadius.all(rLg);
  static const BorderRadius roundedXl = BorderRadius.all(rXl);
  static const BorderRadius roundedFull = BorderRadius.all(rFull);

  /// Top sheet or Modal bottom sheet rounded top
  static const BorderRadius roundedModalTop = BorderRadius.only(
    topLeft: rXl,
    topRight: rXl,
  );

  // ===========================================================================
  // ShapeBorder / Outlines
  // ===========================================================================
  static const OutlinedBorder shapeSm = RoundedRectangleBorder(
    borderRadius: roundedSm,
  );

  static const OutlinedBorder shapeBase = RoundedRectangleBorder(
    borderRadius: roundedBase,
  );

  static const OutlinedBorder shapeMd = RoundedRectangleBorder(
    borderRadius: roundedMd,
  );

  static const OutlinedBorder shapeLg = RoundedRectangleBorder(
    borderRadius: roundedLg,
  );

  static const OutlinedBorder shapeXl = RoundedRectangleBorder(
    borderRadius: roundedXl,
  );

  static const OutlinedBorder shapePill = StadiumBorder();
}
