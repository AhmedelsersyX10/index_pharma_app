import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';

/// Displays only branch fields supported by the store contract.
class BranchCard extends StatelessWidget {
  const BranchCard({
    super.key,
    required this.branch,
    required this.isSelected,
    required this.onTap,
  });
  final BranchEntity branch;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: isSelected ? colors.brandMintSurface : colors.canvasPure,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.roundedXl,
        side: BorderSide(
          color: isSelected ? colors.primary : colors.borderSubtle,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_pharmacy_outlined, color: colors.primary),
                  AppSpacing.hSpaceSm,
                  Expanded(
                    child: Text(
                      branch.name,
                      style: AppTypography.titleMd(color: colors.onSurface),
                    ),
                  ),
                  if (isSelected) ...[
                    AppSpacing.hSpaceSm,
                    Icon(Icons.check_circle, color: colors.primary),
                    AppSpacing.hSpaceXs,
                    Text(
                      'branch_selection.active_branch_badge'.tr(),
                      style: AppTypography.labelSm(color: colors.primary),
                    ),
                  ],
                ],
              ),
              if (branch.address?.trim().isNotEmpty == true) ...[
                AppSpacing.vSpaceSm,
                Text(
                  branch.address!,
                  style: AppTypography.bodySm(color: colors.onSurfaceVariant),
                ),
              ],
              if (branch.phone?.trim().isNotEmpty == true) ...[
                AppSpacing.vSpaceSm,
                Text(
                  branch.phone!,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.bodySm(color: colors.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
