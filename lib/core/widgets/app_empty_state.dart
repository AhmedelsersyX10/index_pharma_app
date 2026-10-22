import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Clarity Empty State View
/// Follows Stitch Design System (F7 Empty & Error States).
/// Renders an antiseptic mint visual container, optional top status badge,
/// authoritative title, message, optional reassurance note, and primary/secondary actions.
class AppEmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? icon;
  final Widget? badge;
  final Widget? reassuranceWidget;
  final Widget? action;
  final Widget? secondaryAction;
  final EdgeInsetsGeometry padding;

  const AppEmptyState({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.badge,
    this.reassuranceWidget,
    this.action,
    this.secondaryAction,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.spaceLg,
      vertical: AppSpacing.spaceLg,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? AppLocaleKeys.emptyStateTitle.tr();

    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _EmptyStateIconBadge(icon: icon),
            const SizedBox(height: AppSpacing.spaceLg),
            if (badge != null) ...[
              badge!,
              const SizedBox(height: AppSpacing.spaceSm),
            ],
            _EmptyStateContent(
              title: effectiveTitle,
              message: message,
            ),
            if (reassuranceWidget != null) ...[
              const SizedBox(height: AppSpacing.spaceMd),
              reassuranceWidget!,
            ],
            if (action != null || secondaryAction != null) ...[
              const SizedBox(height: AppSpacing.spaceLg),
              _EmptyStateActions(
                action: action,
                secondaryAction: secondaryAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyStateIconBadge extends StatelessWidget {
  final Widget? icon;

  const _EmptyStateIconBadge({this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.brandMintSurface,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.brandMintBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primaryBrand.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: icon ??
          Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color: colors.brandEmeraldDark,
          ),
    );
  }
}

class _EmptyStateContent extends StatelessWidget {
  final String title;
  final String? message;

  const _EmptyStateContent({
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.headlineMd(color: colors.onSurface).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (message != null && message!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spaceSm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(color: colors.slate600),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyStateActions extends StatelessWidget {
  final Widget? action;
  final Widget? secondaryAction;

  const _EmptyStateActions({
    this.action,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?action,
        if (action != null && secondaryAction != null)
          const SizedBox(height: AppSpacing.spaceSm),
        ?secondaryAction,
      ],
    );
  }
}
