import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Clarity Card Component
/// Features Level 1 / Level 2 ambient lighting and clinical tonal layering.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isInteractive;
  final bool isMintToned;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isInteractive = false,
    this.isMintToned = false,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  /// Mint tinted card for prescription alerts or verified callouts
  const AppCard.mint({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isInteractive = false,
    this.borderRadius,
  }) : isMintToned = true,
       backgroundColor = null,
       border = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveRadius = borderRadius ?? AppRadii.roundedLg;
    final effectiveBg =
        backgroundColor ?? (isMintToned ? colors.brandMintSurface : colors.surface);
    final effectiveBorder =
        border ??
        Border.all(
          color: isMintToned ? colors.brandMintBorder : colors.borderSubtle,
          width: 1,
        );

    final shadows = context.isDarkMode
        ? (isInteractive ? AppShadows.darkLevel2 : AppShadows.darkLevel1)
        : (isInteractive ? AppShadows.level2 : AppShadows.level1);

    Widget cardContent = Container(
      padding: padding ?? AppSpacing.pCard,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: effectiveRadius, child: cardContent),
      );
    }

    return cardContent;
  }
}
