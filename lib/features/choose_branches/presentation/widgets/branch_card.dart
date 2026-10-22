import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';

/// Interactive card component representing a single pharmacy branch.
///
/// Follows Stitch B1 design specifications:
/// - Distinct selected visual state (emerald border, mint background wash, active badge).
/// - Displays branch name, address, phone number, and clinical readiness status.
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? colors.brandMintSurface : colors.canvasPure,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(
            color: isSelected ? colors.primary : colors.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? context.shadowsLevel2 : context.shadowsLevel1,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top accent indicator when selected
              if (isSelected)
                Container(
                  height: 3,
                  width: double.infinity,
                  color: colors.primary,
                ),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: Icon, Name, and Selection Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pharmacy Icon avatar
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary
                                : colors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_pharmacy_rounded,
                            size: 20,
                            color: isSelected
                                ? colors.onPrimary
                                : colors.primary,
                          ),
                        ),

                        const SizedBox(width: AppSpacing.spaceSm),

                        // Title & code
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch.name,
                                style: AppTypography.titleMd(
                                  color: colors.onSurface,
                                ).copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'branch_selection.main_branch_badge'.tr(),
                                style: AppTypography.labelSm(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.onSurfaceVariant,
                                ).copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selected indicator badge
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spaceSm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(AppRadii.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: colors.onPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'branch_selection.active_branch_badge'.tr(),
                                  style: AppTypography.labelSm(
                                    color: colors.onPrimary,
                                  ).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    AppSpacing.vSpaceSm,

                    // Details: Address, Hours, Phone
                    if (branch.address != null &&
                        branch.address!.trim().isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: isSelected
                                ? colors.primary
                                : colors.secondaryMuted,
                          ),
                          const SizedBox(width: AppSpacing.spaceXs),
                          Expanded(
                            child: Text(
                              branch.address!,
                              style: AppTypography.bodySm(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],

                    // Standard 24h service guarantee
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: isSelected
                              ? colors.primary
                              : colors.secondaryMuted,
                        ),
                        const SizedBox(width: AppSpacing.spaceXs),
                        Text(
                          'branch_selection.open_24_hours'.tr(),
                          style: AppTypography.bodySm(
                            color: colors.onSurface,
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Phone number row
                    if (branch.phone != null &&
                        branch.phone!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: isSelected
                                ? colors.primary
                                : colors.secondaryMuted,
                          ),
                          const SizedBox(width: AppSpacing.spaceXs),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              branch.phone!,
                              style: AppTypography.bodySm(
                                color: colors.onSurfaceVariant,
                              ).copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    AppSpacing.vSpaceSm,

                    // Live Clinical Readiness Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spaceSm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: colors.brandEmeraldDark,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'branch_selection.stock_ready'.tr(),
                                style: AppTypography.labelSm(
                                  color: colors.brandEmeraldDark,
                                ).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'branch_selection.delivery_time'.tr(),
                            style: AppTypography.labelSm(
                              color: colors.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
