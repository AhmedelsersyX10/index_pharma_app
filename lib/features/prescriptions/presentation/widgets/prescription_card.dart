import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/constants/app_config.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import '../../domain/entities/prescription_entity.dart';
import 'prescription_status_badge.dart';

/// Prescription card widget for the customer prescriptions list (Stitch D3).
class PrescriptionCard extends StatelessWidget {
  const PrescriptionCard({
    super.key,
    required this.prescription,
    required this.onTap,
  });

  final PrescriptionEntity prescription;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fullImageUrl = AppConfig.mediaUrl(prescription.imageUrl);
    final dateStr = prescription.createdAt != null
        ? DateFormat('d MMMM yyyy', context.locale.languageCode)
            .format(prescription.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.shadowsLevel1,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Thumbnail + Reference & Date + Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 64,
                        height: 64,
                        color: colors.surfaceContainerLow,
                        child: fullImageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: fullImageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.receipt_long,
                                  color: colors.neutral,
                                  size: 28,
                                ),
                              )
                            : Icon(
                                Icons.receipt_long,
                                color: colors.neutral,
                                size: 28,
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),

                    // Reference and Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocaleKeys.prescriptionsRxRefLabel.tr(),
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.neutral,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            prescription.prescriptionNumber,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (dateStr.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 13,
                                  color: colors.neutral,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.neutral,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Status Badge
                    PrescriptionStatusBadge(
                      status: prescription.status,
                      rawStatus: prescription.rawStatus,
                    ),
                  ],
                ),

                // Quoted Price Box (if quoted price exists)
                if (prescription.quotedPrice != null) ...[
                  const SizedBox(height: AppSpacing.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceSm,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 18,
                              color: colors.tertiary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocaleKeys.prescriptionsQuotedPriceTitle.tr(),
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${prescription.quotedPrice!.toStringAsFixed(2)} ${AppLocaleKeys.prescriptionsCurrency.tr()}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Bottom Action Bar: View Details
                const SizedBox(height: AppSpacing.spaceSm),
                Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.3)),
                const SizedBox(height: AppSpacing.spaceXs),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocaleKeys.prescriptionsViewDetailsBtn.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 13,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
