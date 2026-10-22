import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Card component for entering the contact phone number with Egyptian prefix (+20).
class CheckoutPhoneCard extends StatelessWidget {
  const CheckoutPhoneCard({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorMessage,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: context.shadowsLevel1,
        border: Border.all(color: hasError ? colors.error : colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    child: Icon(Icons.call_rounded, color: colors.primary, size: 16),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Text(
                    'checkout.phone_title'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceSm,
                  vertical: AppSpacing.space2xs,
                ),
                decoration: BoxDecoration(
                  color: colors.brandMintSurface,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  'checkout.required_badge'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.brandEmeraldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            decoration: BoxDecoration(
              color: hasError ? colors.errorContainer.withAlpha(77) : colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: hasError ? colors.error : Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceSm,
                    vertical: AppSpacing.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(AppRadii.md),
                      bottomRight: Radius.circular(AppRadii.md),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🇪🇬', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '+20',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TextField(
                    key: const Key('checkout_phone_field'),
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      color: colors.onSurface,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spaceSm,
                        vertical: AppSpacing.spaceSm,
                      ),
                      border: InputBorder.none,
                      hintText: 'checkout.phone_hint'.tr(),
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant.withAlpha(128),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.error_outline_rounded, color: colors.error, size: 15),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            'checkout.phone_helper'.tr(),
            style: TextStyle(fontSize: 12, color: colors.secondaryMuted, height: 1.35),
          ),
        ],
      ),
    );
  }
}
