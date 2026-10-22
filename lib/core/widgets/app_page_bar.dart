import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Unified clinical app bar for all screens in Index Pharma.
///
/// Implements [PreferredSizeWidget] with:
/// - Single-line centered title with ellipsis using design tokens.
/// - RTL/LTR direction-aware back button with $\ge 48$dp touch targets.
/// - Crisp 1dp bottom border divider instead of drop shadows.
/// - Status-bar overlay style aligned with active theme brightness.
/// - Variants for standard screens, transparent headers, and no-back navigation tabs.
class AppPageBar extends StatelessWidget implements PreferredSizeWidget {
  const AppPageBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.showBackButton,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.showBottomDivider = true,
    this.centerTitle = true,
    this.height = kToolbarHeight,
  });

  /// Transparent variant for authentication and guard screens.
  const AppPageBar.transparent({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.showBackButton,
    this.onBackPressed,
    this.actions,
    this.foregroundColor,
    this.showBottomDivider = false,
    this.centerTitle = true,
    this.height = kToolbarHeight,
  }) : backgroundColor = Colors.transparent;

  /// No-back-button variant for shell tabs (Home, My Orders, Account).
  const AppPageBar.noBack({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.showBottomDivider = true,
    this.centerTitle = true,
    this.height = kToolbarHeight,
  })  : leading = null,
        showBackButton = false,
        onBackPressed = null;

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final bool? showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showBottomDivider;
  final bool centerTitle;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  static bool _canPopSafely(BuildContext context) {
    final goRouter = GoRouter.maybeOf(context);
    if (goRouter != null && goRouter.canPop()) {
      return true;
    }
    return Navigator.maybeOf(context)?.canPop() ?? false;
  }

  static void _popSafely(BuildContext context) {
    final goRouter = GoRouter.maybeOf(context);
    if (goRouter != null && goRouter.canPop()) {
      goRouter.pop();
      return;
    }
    final navigator = Navigator.maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final resolvedBg = backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.canvasPure);
    final resolvedFg = foregroundColor ??
        (isDark ? AppColors.darkOnSurface : AppColors.onSurface);
    final dividerColor = isDark ? AppColors.darkOutline : AppColors.borderSubtle;

    // Determine whether to display the back button
    final bool canPop = _canPopSafely(context);
    final bool shouldShowBack = showBackButton ?? (onBackPressed != null || canPop);

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && shouldShowBack) {
      effectiveLeading = Semantics(
        label: MaterialLocalizations.of(context).backButtonTooltip,
        button: true,
        child: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            color: resolvedFg,
            size: 24,
          ),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          constraints: const BoxConstraints(
            minWidth: AppSpacing.minTouchTarget,
            minHeight: AppSpacing.minTouchTarget,
          ),
          padding: EdgeInsets.zero,
          onPressed: onBackPressed ?? () => _popSafely(context),
        ),
      );
    }

    Widget? effectiveTitle = titleWidget;
    if (effectiveTitle == null && title != null) {
      effectiveTitle = Text(
        title!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.titleLg(color: resolvedFg),
      );
    }

    return AppBar(
      backgroundColor: resolvedBg,
      foregroundColor: resolvedFg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: effectiveLeading,
      title: effectiveTitle,
      actions: actions,
      toolbarHeight: height,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      shape: showBottomDivider
          ? Border(bottom: BorderSide(color: dividerColor, width: 1.0))
          : null,
    );
  }
}
