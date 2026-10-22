import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import '../../domain/entities/customer_order_item.dart';

/// Section widget rendering ordered medicines breakdown (Stitch C5).
class OrderItemsSection extends StatelessWidget {
  const OrderItemsSection({
    super.key,
    required this.items,
  });

  final List<CustomerOrderItem> items;

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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medication_rounded,
                    size: 20,
                    color: colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Text(
                    'orders.items_title'.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  items.length == 1
                      ? 'orders.items_count_single'.tr(args: ['${items.length}'])
                      : 'orders.items_count_multiple'.tr(args: ['${items.length}']),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.spaceSm),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemRow(item, colors);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(CustomerOrderItem item, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Medication Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.brandMintSurface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: colors.brandMintBorder),
            ),
            child: Center(
              child: Icon(
                Icons.medical_services_outlined,
                size: 22,
                color: colors.brandEmeraldDark,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'orders.item_quantity'.tr(args: ['${item.quantity}']),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.secondaryMuted,
                      ),
                    ),
                    Text(
                      '${item.totalPrice.toStringAsFixed(2)} ${'orders.currency'.tr()}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
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
}
