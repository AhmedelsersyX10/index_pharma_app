import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/constants/app_config.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/app_colors.dart';
import 'package:index_pharma/core/theme/app_spacing.dart';
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
    final fullImageUrl = AppConfig.mediaUrl(prescription.imageUrl);
    final dateStr = prescription.createdAt != null
        ? DateFormat('d MMMM yyyy', context.locale.languageCode)
            .format(prescription.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
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
                        color: AppColors.surfaceContainerLow,
                        child: fullImageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: fullImageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.receipt_long,
                                  color: AppColors.neutral,
                                  size: 28,
                                ),
                              )
                            : const Icon(
                                Icons.receipt_long,
                                color: AppColors.neutral,
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
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.neutral,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            prescription.prescriptionNumber,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (dateStr.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 13,
                                  color: AppColors.neutral,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.neutral,
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
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              size: 18,
                              color: AppColors.tertiary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocaleKeys.prescriptionsQuotedPriceTitle.tr(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${prescription.quotedPrice!.toStringAsFixed(2)} ${AppLocaleKeys.prescriptionsCurrency.tr()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Bottom Action Bar: View Details
                const SizedBox(height: AppSpacing.spaceSm),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: AppSpacing.spaceXs),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocaleKeys.prescriptionsViewDetailsBtn.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 13,
                        color: AppColors.primary,
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
