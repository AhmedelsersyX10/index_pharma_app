import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Clarity Empty State View
/// Renders an empty-state illustration/icon, a title, an optional message,
/// and an optional action widget.
class AppEmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? icon;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  const AppEmptyState({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.action,
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
            _EmptyStateContent(
              title: effectiveTitle,
              message: message,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.spaceLg),
              action!,
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
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.slate100,
        shape: BoxShape.circle,
      ),
      child: icon ??
          const Icon(
            Icons.inventory_2_outlined,
            size: 36,
            color: AppColors.slate400,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.titleLg(color: AppColors.onSurface),
        ),
        if (message != null && message!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd(color: AppColors.slate600),
          ),
        ],
      ],
    );
  }
}
