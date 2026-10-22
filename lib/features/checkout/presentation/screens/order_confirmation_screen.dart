import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import '../../domain/entities/order.dart';

/// Screen displayed after successful order placement (Stitch C3).
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final Order order;

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _copied = false;

  void _copyOrderNumber() {
    Clipboard.setData(ClipboardData(text: widget.order.orderNumber));
    setState(() => _copied = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  String _formatDate(DateTime date, BuildContext context) {
    final locale = context.locale.languageCode;
    return DateFormat.yMMMd(locale).add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currency = 'cart.currency'.tr();
    final formattedTotal = widget.order.totalAmount.toStringAsFixed(2);
    final formattedDate = _formatDate(widget.order.createdAt, context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRouter.kStoreView);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceMd,
                    vertical: AppSpacing.spaceSm,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.spaceMd),
                      // Celebration Glow & Shield
                      _buildCelebrationBadge(colors),
                      const SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        'order_confirmation.success_title'.tr(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colors.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm),
                        child: Text(
                          'order_confirmation.success_desc'.tr(),
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceLg),
                      // Order Identification & Summary Card
                      _buildOrderSummaryCard(
                        context: context,
                        formattedTotal: formattedTotal,
                        formattedDate: formattedDate,
                        currency: currency,
                      ),
                      const SizedBox(height: AppSpacing.spaceMd),
                      // Safety Protocol Card
                      _buildSafetyProtocolCard(context),
                      const SizedBox(height: AppSpacing.spaceLg),
                    ],
                  ),
                ),
              ),
              // Bottom Action Buttons
              _buildBottomActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationBadge(AppColorsExtension colors) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colors.brandMintSurface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.brandTealBright.withAlpha(51),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.brandEmeraldDark,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_rounded, color: colors.onPrimary, size: 34),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard({
    required BuildContext context,
    required String formattedTotal,
    required String formattedDate,
    required String currency,
  }) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: context.shadowsLevel1,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        children: [
          // Order ID Bar with Copy Action
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
              vertical: AppSpacing.spaceSm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'order_confirmation.order_number_label'.tr(),
                      style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.order.orderNumber,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: colors.onSurface,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
                InkWell(
                  key: const Key('btn_copy_order_number'),
                  onTap: _copyOrderNumber,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceSm,
                      vertical: AppSpacing.space2xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.canvasPure,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                          size: 15,
                          color: _copied ? colors.brandEmeraldDark : colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copied
                              ? 'order_confirmation.copied_feedback'.tr()
                              : 'order_confirmation.copy_btn'.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _copied ? colors.brandEmeraldDark : colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          // Metadata Rows
          _buildSummaryRow(
            context: context,
            icon: Icons.calendar_today_rounded,
            title: 'order_confirmation.order_date_label'.tr(),
            valueWidget: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          _buildSummaryRow(
            context: context,
            icon: Icons.hourglass_top_rounded,
            title: 'order_confirmation.order_status_label'.tr(),
            valueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm, vertical: 2),
              decoration: BoxDecoration(
                color: colors.badgeWarningBg,
                borderRadius: BorderRadius.circular(AppRadii.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.medicalAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'order_confirmation.status_pending'.tr(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colors.badgeWarningText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          _buildSummaryRow(
            context: context,
            icon: Icons.payments_rounded,
            title: 'order_confirmation.payment_method_label'.tr(),
            valueWidget: Text(
              'order_confirmation.payment_cod'.tr(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          // Total Strip
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      color: colors.brandEmeraldDark,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'order_confirmation.total_amount_label'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedTotal,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.brandEmeraldDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currency,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.brandEmeraldDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget valueWidget,
  }) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colors.secondaryMuted),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
          ],
        ),
        valueWidget,
      ],
    );
  }

  Widget _buildSafetyProtocolCard(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: context.shadowsLevel1,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.brandMintSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              color: colors.brandEmeraldDark,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'order_confirmation.clinical_review_title'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle_rounded,
                      color: colors.brandEmeraldDark,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'order_confirmation.clinical_review_desc'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_rounded, color: colors.primary, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'order_confirmation.authentic_meds_tag'.tr(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
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
    );
  }

  Widget _buildBottomActionButtons(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        boxShadow: context.shadowsLevel3,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            key: const Key('btn_view_order_details'),
            onPressed: () => context.go(AppRouter.kOrdersView),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: 1,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
            ),
            icon: const Icon(Icons.inventory_2_rounded, size: 18),
            label: Text(
              'order_confirmation.view_order_details_btn'.tr(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          OutlinedButton.icon(
            key: const Key('btn_continue_shopping'),
            onPressed: () => context.go(AppRouter.kStoreView),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.onSurface,
              side: BorderSide(color: colors.borderSubtle),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
            ),
            icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
            label: Text(
              'order_confirmation.continue_shopping_btn'.tr(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
