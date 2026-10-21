import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/constants/app_config.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/app_colors.dart';
import 'package:index_pharma/core/theme/app_spacing.dart';
import 'package:index_pharma/core/utils/app_router.dart';
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
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prescription;
    final fullImageUrl = AppConfig.mediaUrl(p.imageUrl);
    final dateStr = p.createdAt != null
        ? DateFormat('d MMMM yyyy - hh:mm a', context.locale.languageCode)
            .format(p.createdAt!)
        : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRouter.kPrescriptionView);
            }
          },
        ),
        title: Text(
          AppLocaleKeys.prescriptionsDetailsTitle.tr(),
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
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
              _buildRejectionBanner(p),
              const SizedBox(height: AppSpacing.spaceMd),
            ],

            // 2. Meta Card (Reference, Date, Status)
            _buildMetaCard(p, dateStr),
            const SizedBox(height: AppSpacing.spaceMd),

            // 3. Prescription Image Showcase Card
            _buildImageCard(fullImageUrl),
            const SizedBox(height: AppSpacing.spaceMd),

            // 4. Notes Section (Customer Notes & Pharmacist Notes)
            if (p.notes != null && p.notes!.trim().isNotEmpty) ...[
              _buildCustomerNotesCard(p.notes!.trim()),
              const SizedBox(height: AppSpacing.spaceSm),
            ],

            if (p.pharmacistNotes != null &&
                p.pharmacistNotes!.trim().isNotEmpty) ...[
              _buildPharmacistNotesCard(p.pharmacistNotes!.trim()),
              const SizedBox(height: AppSpacing.spaceSm),
            ],

            // 5. Quoted Price Breakdown (If Available)
            if (p.quotedPrice != null) ...[
              _buildQuotedPriceCard(p.quotedPrice!),
              const SizedBox(height: AppSpacing.spaceMd),
            ],

            const SizedBox(height: AppSpacing.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionBanner(PrescriptionEntity p) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.error,
                child: Icon(Icons.gpp_bad, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocaleKeys.prescriptionsRejectionTitle.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onErrorContainer,
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
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onErrorContainer,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRouter.kPrescriptionUploadView),
            icon: const Icon(Icons.add_a_photo, size: 16),
            label: Text(AppLocaleKeys.prescriptionsReuploadBtn.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
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

  Widget _buildMetaCard(PrescriptionEntity p, String dateStr) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
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
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        p.prescriptionNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _copyReference,
                        borderRadius: BorderRadius.circular(9999),
                        child: CircleAvatar(
                          radius: 13,
                          backgroundColor: AppColors.surfaceContainerLow,
                          child: Icon(
                            _copied ? Icons.check : Icons.copy,
                            size: 13,
                            color: AppColors.primary,
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
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: AppSpacing.spaceSm),
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.neutral,
                ),
                const SizedBox(width: 6),
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
    );
  }

  Widget _buildImageCard(String fullImageUrl) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocaleKeys.prescriptionsUploadedImageTitle.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
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
                    color: AppColors.surfaceContainerLow,
                    child: fullImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: fullImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(
                                Icons.receipt_long,
                                size: 48,
                                color: AppColors.neutral,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: AppColors.neutral,
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
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.zoom_in,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocaleKeys.prescriptionsZoomHint.tr(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
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

  Widget _buildCustomerNotesCard(String notes) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: AppColors.neutral,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocaleKeys.prescriptionsCustomerNotesTitle.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              notes,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacistNotesCard(String notes) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.brandMintSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.medical_services,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppLocaleKeys.prescriptionsPharmacistNotesTitle.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notes,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotedPriceCard(double price) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocaleKeys.prescriptionsTotalPriceLabel.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          Text(
            '${price.toStringAsFixed(2)} ${AppLocaleKeys.prescriptionsCurrency.tr()}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
