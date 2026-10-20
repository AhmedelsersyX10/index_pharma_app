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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              const Icon(
                Icons.local_shipping_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Text(
                'orders.delivery_info_title'.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Address Row
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            label: 'orders.delivery_address_label'.tr(),
            content: Text(
              deliveryAddress.isNotEmpty ? deliveryAddress : '—',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Phone Row
          _buildInfoRow(
            icon: Icons.phone_android_rounded,
            label: 'orders.customer_phone_label'.tr(),
            content: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Text(
                customerPhone.isNotEmpty ? customerPhone : '—',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),

          // Special Delivery Notes (if provided)
          if (notes != null && notes!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            _buildInfoRow(
              icon: Icons.note_alt_outlined,
              label: 'orders.delivery_notes_label'.tr(),
              content: Text(
                notes!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.slate700,
                  height: 1.4,
                ),
              ),
              backgroundColor: AppColors.badgeInfoBg.withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Widget content,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
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
