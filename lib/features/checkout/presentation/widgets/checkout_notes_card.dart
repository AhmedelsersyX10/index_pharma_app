import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Card component for optional notes to pharmacist or courier.
class CheckoutNotesCard extends StatelessWidget {
  const CheckoutNotesCard({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.level1,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Text(
                  'checkout.notes_title'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: TextField(
              key: const Key('checkout_notes_field'),
              controller: controller,
              onChanged: onChanged,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(AppSpacing.spaceSm),
                border: InputBorder.none,
                hintText: 'checkout.notes_hint'.tr(),
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant.withAlpha(128),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
