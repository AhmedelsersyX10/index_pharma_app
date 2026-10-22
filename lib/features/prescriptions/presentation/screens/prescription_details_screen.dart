import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/constants/app_config.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/entities/prescription_status.dart';
import '../widgets/prescription_image_viewer_dialog.dart';
import '../widgets/prescription_status_badge.dart';

/// Screen displaying the complete details of a specific prescription (Stitch D4).
class PrescriptionDetailsScreen extends StatefulWidget {
  const PrescriptionDetailsScreen({
    super.key,
    required this.prescription,
  });

  final PrescriptionEntity prescription;

  @override
  State<PrescriptionDetailsScreen> createState() =>
      _PrescriptionDetailsScreenState();
}

class _PrescriptionDetailsScreenState extends State<PrescriptionDetailsScreen> {
  bool _copied = false;

  void _copyReference() {
    Clipboard.setData(
      ClipboardData(text: widget.prescription.prescriptionNumber),
    );
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocaleKeys.prescriptionsCopied.tr()),
        duration: const Duration(seconds: 2),
        backgroundColor: context.colors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = widget.prescription;
    final fullImageUrl = AppConfig.mediaUrl(p.imageUrl);
    final dateStr = p.createdAt != null
        ? DateFormat('d MMMM yyyy - hh:mm a', context.locale.languageCode)
            .format(p.createdAt!)
        : '';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(
        title: AppLocaleKeys.prescriptionsDetailsTitle.tr(),
        onBackPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(AppRouter.kPrescriptionView);
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.spaceSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Rejection Banner (If Rejected)
            if (p.status == PrescriptionStatus.rejected) ...[
              _buildRejectionBanner(p, colors),
              const SizedBox(height: AppSpacing.spaceMd),
            ],

            // 2. Meta Card (Reference, Date, Status)
            _buildMetaCard(p, dateStr, colors),
            const SizedBox(height: AppSpacing.spaceMd),

            // 3. Prescription Image Showcase Card
            _buildImageCard(fullImageUrl, colors),
            const SizedBox(height: AppSpacing.spaceMd),

            // 4. Notes Section (Customer Notes & Pharmacist Notes)
            if (p.notes != null && p.notes!.trim().isNotEmpty) ...[
              _buildCustomerNotesCard(p.notes!.trim(), colors),
              const SizedBox(height: AppSpacing.spaceSm),
            ],

            if (p.pharmacistNotes != null &&
                p.pharmacistNotes!.trim().isNotEmpty) ...[
              _buildPharmacistNotesCard(p.pharmacistNotes!.trim(), colors),
              const SizedBox(height: AppSpacing.spaceSm),
            ],

            // 5. Quoted Price Breakdown (If Available)
            if (p.quotedPrice != null) ...[
              _buildQuotedPriceCard(p.quotedPrice!, colors),
              const SizedBox(height: AppSpacing.spaceMd),
            ],

            const SizedBox(height: AppSpacing.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionBanner(PrescriptionEntity p, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colors.error,
                child: const Icon(Icons.gpp_bad, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocaleKeys.prescriptionsRejectionTitle.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            p.rejectionReason != null && p.rejectionReason!.trim().isNotEmpty
                ? p.rejectionReason!.trim()
                : AppLocaleKeys.prescriptionsDefaultRejectionReason.tr(),
            style: TextStyle(
              fontSize: 13,
              color: colors.onErrorContainer,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRouter.kPrescriptionUploadView),
            icon: const Icon(Icons.add_a_photo, size: 16),
            label: Text(AppLocaleKeys.prescriptionsReuploadBtn.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(
    PrescriptionEntity p,
    String dateStr,
    AppColorsExtension colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.shadowsLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocaleKeys.prescriptionsRxRefLabel.tr(),
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.neutral,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        p.prescriptionNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _copyReference,
                        borderRadius: BorderRadius.circular(9999),
                        child: CircleAvatar(
                          radius: 13,
                          backgroundColor: colors.surfaceContainerLow,
                          child: Icon(
                            _copied ? Icons.check : Icons.copy,
                            size: 13,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              PrescriptionStatusBadge(
                status: p.status,
                rawStatus: p.rawStatus,
              ),
            ],
          ),
          if (dateStr.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: AppSpacing.spaceSm),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: colors.neutral,
                ),
                const SizedBox(width: 6),
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
    );
  }

  Widget _buildImageCard(String fullImageUrl, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.shadowsLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            child: Row(
              children: [
                Icon(
                  Icons.assignment,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocaleKeys.prescriptionsUploadedImageTitle.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              PrescriptionImageViewerDialog.show(
                context,
                imageUrl: fullImageUrl,
                title: AppLocaleKeys.prescriptionsUploadedImageTitle.tr(),
              );
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    color: colors.surfaceContainerLow,
                    child: fullImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: fullImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: colors.primary,
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.receipt_long,
                                size: 48,
                                color: colors.neutral,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: colors.neutral,
                            ),
                          ),
                  ),
                ),
                PositionedDirectional(
                  bottom: 10,
                  start: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.canvasPure.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: context.shadowsLevel1,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.zoom_in,
                          size: 16,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocaleKeys.prescriptionsZoomHint.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerNotesCard(String notes, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.shadowsLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: colors.neutral,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocaleKeys.prescriptionsCustomerNotesTitle.tr(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              notes,
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacistNotesCard(String notes, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.brandMintSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: colors.primary,
                child: const Icon(
                  Icons.medical_services,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppLocaleKeys.prescriptionsPharmacistNotesTitle.tr(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notes,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotedPriceCard(double price, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.shadowsLevel1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 20,
                color: colors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocaleKeys.prescriptionsTotalPriceLabel.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          Text(
            '${price.toStringAsFixed(2)} ${AppLocaleKeys.prescriptionsCurrency.tr()}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
