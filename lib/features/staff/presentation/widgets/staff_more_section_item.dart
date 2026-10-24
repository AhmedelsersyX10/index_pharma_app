import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Individual list item for settings and actions in Staff More screen.
class StaffMoreSectionItem extends StatelessWidget {
  const StaffMoreSectionItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconContainerColor,
    this.isDestructive = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconContainerColor;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedIconColor = isDestructive
        ? colors.error
        : (iconColor ?? colors.primary);
    final resolvedIconBg = isDestructive
        ? colors.errorContainer
        : (iconContainerColor ?? colors.primaryContainer.withValues(alpha: 0.4));

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.roundedMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: resolvedIconBg,
                borderRadius: AppRadii.roundedMd,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 20,
                color: resolvedIconColor,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMd(
                      color: isDestructive ? colors.error : colors.onSurface,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySm(color: colors.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }
}
