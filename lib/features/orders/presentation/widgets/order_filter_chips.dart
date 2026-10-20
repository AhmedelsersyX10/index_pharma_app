import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import '../cubit/my_orders_state.dart';

/// Filter chips row for filtering orders by All, Active, and Past (Stitch C4).
class OrderFilterChips extends StatelessWidget {
  const OrderFilterChips({
    super.key,
    required this.selectedFilter,
    required this.countAll,
    required this.countActive,
    required this.countPast,
    required this.onFilterSelected,
  });

  final OrderFilter selectedFilter;
  final int countAll;
  final int countActive;
  final int countPast;
  final ValueChanged<OrderFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.spaceXs,
      ),
      child: Row(
        children: [
          _buildChip(
            filter: OrderFilter.all,
            label: OrderFilter.all.translationKey.tr(),
            count: countAll,
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          _buildChip(
            filter: OrderFilter.active,
            label: OrderFilter.active.translationKey.tr(),
            count: countActive,
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          _buildChip(
            filter: OrderFilter.past,
            label: OrderFilter.past.translationKey.tr(),
            count: countPast,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required OrderFilter filter,
    required String label,
    required int count,
  }) {
    final isSelected = selectedFilter == filter;

    return InkWell(
      onTap: () => onFilterSelected(filter),
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceXs + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.canvasPure,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
          ),
          boxShadow: isSelected ? AppShadows.level1 : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.onPrimary.withValues(alpha: 0.2)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadii.full),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
