import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_card.dart';

/// Clinical Usage & Guidelines Panel per Stitch B4.
class ProductDetailsDescriptionCard extends StatelessWidget {
  const ProductDetailsDescriptionCard({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    if (description.trim().isEmpty) return const SizedBox.shrink();

    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 20,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Text(
                AppLocaleKeys.productDetailsUsageGuidelinesTitle.tr(),
                style: AppTypography.titleMd(
                  color: colors.onSurface,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            description.trim(),
            style: AppTypography.bodyMd(
              color: colors.onSurfaceVariant,
            ).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
