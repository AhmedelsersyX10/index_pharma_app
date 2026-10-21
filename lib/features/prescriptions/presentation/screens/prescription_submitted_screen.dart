import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/app_colors.dart';
import 'package:index_pharma/core/theme/app_spacing.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import '../../domain/entities/prescription_entity.dart';
import '../widgets/prescription_status_badge.dart';

/// Screen displayed after a prescription is submitted successfully (Stitch D2).
class PrescriptionSubmittedScreen extends StatefulWidget {
  const PrescriptionSubmittedScreen({
    super.key,
    required this.prescription,
  });

  final PrescriptionEntity prescription;

  @override
  State<PrescriptionSubmittedScreen> createState() =>
      _PrescriptionSubmittedScreenState();
}

class _PrescriptionSubmittedScreenState
    extends State<PrescriptionSubmittedScreen> {
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
    final dateStr = widget.prescription.createdAt != null
        ? DateFormat('d MMMM yyyy - hh:mm a', context.locale.languageCode)
            .format(widget.prescription.createdAt!)
        : DateFormat('d MMMM yyyy', context.locale.languageCode)
            .format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.go(AppRouter.kStoreView),
        ),
        title: Text(
          AppLocaleKeys.prescriptionsConfirmationBadge.tr(),
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.spaceMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Success Circle & Headlines
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.brandMintSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandMintSurface,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.brandEmeraldDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocaleKeys.prescriptionsConfirmationBadge.tr(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandEmeraldDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocaleKeys.prescriptionsConfirmationTitle.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocaleKeys.prescriptionsConfirmationDesc.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),

            // 2. Prescription Reference Card
            Container(
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
                  // Reference code strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceSm,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
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
                            Text(
                              widget.prescription.prescriptionNumber,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _copyReference,
                          icon: Icon(
                            _copied ? Icons.check : Icons.copy,
                            size: 15,
                          ),
                          label: Text(
                            _copied
                                ? AppLocaleKeys.prescriptionsCopied.tr()
                                : AppLocaleKeys.prescriptionsCopyCode.tr(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.canvasPure,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceSm),

                  // Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.neutral,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppLocaleKeys.prescriptionsDateLabel.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18, color: Color(0xFFF1F5F9)),

                  // Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.hourglass_top,
                            size: 16,
                            color: AppColors.neutral,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppLocaleKeys.prescriptionsStatusLabel.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      PrescriptionStatusBadge(
                        status: widget.prescription.status,
                        rawStatus: widget.prescription.rawStatus,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // 3. Workflow Progression
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.help_outline,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocaleKeys.prescriptionsStepsTitle.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spaceSm),
                  _buildProgressItem(
                    stepNumber: AppLocaleKeys.prescriptionsStepNum1.tr(),
                    title: AppLocaleKeys.prescriptionsSubmittedStep1Title.tr(),
                    desc: AppLocaleKeys.prescriptionsStep1.tr(),
                    isCurrent: true,
                  ),
                  const SizedBox(height: 10),
                  _buildProgressItem(
                    stepNumber: AppLocaleKeys.prescriptionsStepNum2.tr(),
                    title: AppLocaleKeys.prescriptionsSubmittedStep2Title.tr(),
                    desc: AppLocaleKeys.prescriptionsStep2.tr(),
                    isCurrent: false,
                  ),
                  const SizedBox(height: 10),
                  _buildProgressItem(
                    stepNumber: AppLocaleKeys.prescriptionsStepNum3.tr(),
                    title: AppLocaleKeys.prescriptionsSubmittedStep3Title.tr(),
                    desc: AppLocaleKeys.prescriptionsStep3.tr(),
                    isCurrent: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),

            // 4. Action Buttons
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pushReplacement(AppRouter.kPrescriptionView);
                },
                icon: const Icon(Icons.assignment, size: 20, color: Colors.white),
                label: Text(
                  AppLocaleKeys.prescriptionsViewMyPrescriptionsBtn.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRouter.kStoreView),
                icon: const Icon(
                  Icons.storefront,
                  size: 20,
                  color: AppColors.onSurface,
                ),
                label: Text(
                  AppLocaleKeys.prescriptionsBackToHomeBtn.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required String stepNumber,
    required String title,
    required String desc,
    required bool isCurrent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isCurrent
              ? AppColors.primary
              : AppColors.surfaceContainerHigh,
          child: Text(
            stepNumber,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isCurrent ? Colors.white : AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCurrent ? AppColors.primary : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutral,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
