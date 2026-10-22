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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: colors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Text(
                  'checkout.notes_title'.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: TextField(
              key: const Key('checkout_notes_field'),
              controller: controller,
              onChanged: onChanged,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(AppSpacing.spaceSm),
                border: InputBorder.none,
                hintText: 'checkout.notes_hint'.tr(),
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant.withAlpha(128),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
