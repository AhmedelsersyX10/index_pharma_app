import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Card displaying delivery address, recipient phone number, and special delivery notes (Stitch C5).
class OrderDeliveryInfoCard extends StatelessWidget {
  const OrderDeliveryInfoCard({
    super.key,
    required this.deliveryAddress,
    required this.customerPhone,
    this.notes,
  });

  final String deliveryAddress;
  final String customerPhone;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: context.shadowsLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.local_shipping_rounded,
                size: 20,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Text(
                'orders.delivery_info_title'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Address Row
          _buildInfoRow(
            colors: colors,
            icon: Icons.location_on_rounded,
            label: 'orders.delivery_address_label'.tr(),
            content: Text(
              deliveryAddress.isNotEmpty ? deliveryAddress : '—',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Phone Row
          _buildInfoRow(
            colors: colors,
            icon: Icons.phone_android_rounded,
            label: 'orders.customer_phone_label'.tr(),
            content: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Text(
                customerPhone.isNotEmpty ? customerPhone : '—',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),

          // Special Delivery Notes (if provided)
          if (notes != null && notes!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            _buildInfoRow(
              colors: colors,
              icon: Icons.note_alt_outlined,
              label: 'orders.delivery_notes_label'.tr(),
              content: Text(
                notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface,
                  height: 1.4,
                ),
              ),
              backgroundColor: colors.badgeInfoBg.withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required AppColorsExtension colors,
    required IconData icon,
    required String label,
    required Widget content,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
