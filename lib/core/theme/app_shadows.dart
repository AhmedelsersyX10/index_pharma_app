import 'package:flutter/material.dart';

/// Clinical Clarity Ambient Lighting & Depth System
/// Soft ambient illumination rather than harsh drop shadows.
abstract class AppShadows {
  const AppShadows._();

  /// Level 0: Pure Flat / Canvas
  static const List<BoxShadow> level0 = [];

  /// Level 1: Cards & Tonal Surfaces
  /// Subtle ambient definition for medication listings and standard cards.
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x0A0F172A), // rgba(15, 23, 42, 0.04)
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x050F172A), // rgba(15, 23, 42, 0.02)
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: -1,
    ),
  ];

  /// Level 2: Active / Hovered Cards & Interactive Modules
  /// Gentle emerald tint suggests responsive physical feedback.
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x1400966B), // rgba(0, 150, 107, 0.08) - emerald tint
      offset: Offset(0, 10),
      blurRadius: 20,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // rgba(15, 23, 42, 0.04)
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];

  /// Level 3: Sticky Prescription Bars, Modals & Floating Action Bars
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x1F0F172A), // rgba(15, 23, 42, 0.12)
      offset: Offset(0, 20),
      blurRadius: 32,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // rgba(15, 23, 42, 0.04)
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];

  /// Dark mode soft shadows
  static const List<BoxShadow> darkLevel1 = [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> darkLevel2 = [
    BoxShadow(
      color: Color(0x60000000),
      offset: Offset(0, 10),
      blurRadius: 20,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x2000966B),
      offset: Offset(0, 4),
      blurRadius: 10,
    ),
  ];

  static const List<BoxShadow> darkLevel3 = [
    BoxShadow(
      color: Color(0x80000000),
      offset: Offset(0, 20),
      blurRadius: 32,
      spreadRadius: -8,
    ),
  ];
}
