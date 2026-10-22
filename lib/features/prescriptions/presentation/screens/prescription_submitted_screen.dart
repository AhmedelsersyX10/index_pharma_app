import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
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
    final dateStr = widget.prescription.createdAt != null
        ? DateFormat('d MMMM yyyy - hh:mm a', context.locale.languageCode)
            .format(widget.prescription.createdAt!)
        : DateFormat('d MMMM yyyy', context.locale.languageCode)
            .format(DateTime.now());

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(
        title: AppLocaleKeys.prescriptionsConfirmationBadge.tr(),
        onBackPressed: () => context.go(AppRouter.kStoreView),
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
                    decoration: BoxDecoration(
                      color: colors.brandMintSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: colors.primary,
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
                      color: colors.brandMintSurface,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.brandEmeraldDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocaleKeys.prescriptionsConfirmationBadge.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.brandEmeraldDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocaleKeys.prescriptionsConfirmationTitle.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocaleKeys.prescriptionsConfirmationDesc.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.neutral,
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
                color: colors.canvasPure,
                borderRadius: BorderRadius.circular(16),
                boxShadow: context.shadowsLevel1,
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
                      color: colors.surfaceContainerLow,
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
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.neutral,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.prescription.prescriptionNumber,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
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
                            backgroundColor: colors.canvasPure,
                            foregroundColor: colors.primary,
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
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: colors.neutral,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppLocaleKeys.prescriptionsDateLabel.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 18, color: colors.outlineVariant.withValues(alpha: 0.3)),

                  // Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.hourglass_top,
                            size: 16,
                            color: colors.neutral,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppLocaleKeys.prescriptionsStatusLabel.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
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
                        Icons.help_outline,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocaleKeys.prescriptionsStepsTitle.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spaceSm),
                  _buildProgressItem(
                    colors: colors,
                    stepNumber: AppLocaleKeys.prescriptionsStepNum1.tr(),
                    title: AppLocaleKeys.prescriptionsSubmittedStep1Title.tr(),
                    desc: AppLocaleKeys.prescriptionsStep1.tr(),
                    isCurrent: true,
                  ),
                  const SizedBox(height: 10),
                  _buildProgressItem(
                    colors: colors,
                    stepNumber: AppLocaleKeys.prescriptionsStepNum2.tr(),
                    title: AppLocaleKeys.prescriptionsSubmittedStep2Title.tr(),
                    desc: AppLocaleKeys.prescriptionsStep2.tr(),
                    isCurrent: false,
                  ),
                  const SizedBox(height: 10),
                  _buildProgressItem(
                    colors: colors,
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
                icon: Icon(Icons.assignment, size: 20, color: colors.onPrimary),
                label: Text(
                  AppLocaleKeys.prescriptionsViewMyPrescriptionsBtn.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
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
                icon: Icon(
                  Icons.storefront,
                  size: 20,
                  color: colors.onSurface,
                ),
                label: Text(
                  AppLocaleKeys.prescriptionsBackToHomeBtn.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.outlineVariant),
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
    required AppColorsExtension colors,
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
              ? colors.primary
              : colors.surfaceContainerHigh,
          child: Text(
            stepNumber,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isCurrent ? colors.onPrimary : colors.onSurface,
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
                  color: isCurrent ? colors.primary : colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.neutral,
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
