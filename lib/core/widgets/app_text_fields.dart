import 'package:flutter/material.dart';
import 'package:index_pharma_store/core/theme/theme.dart';

/// Clinical Clarity Search Bar
/// Pill-shaped search bar with emerald icon and subtle focus glow.
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;
  final String hintText;
  final bool autoFocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.onClear,
    this.hintText = 'Search medicines, vitamins, pharmacy items...',
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: AppRadii.roundedFull,
        boxShadow: AppShadows.level1,
      ),
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        onChanged: onChanged,
        style: AppTypography.bodyMd(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyMd(color: AppColors.slate400),
          fillColor: AppColors.canvasPure,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.primaryBrand,
              size: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 44),
          suffixIcon: onFilterTap != null
              ? IconButton(
                  icon: const Icon(Icons.tune_rounded, color: AppColors.slate500),
                  onPressed: onFilterTap,
                  tooltip: 'Filter',
                )
              : null,
          border: const OutlineInputBorder(
            borderRadius: AppRadii.roundedFull,
            borderSide: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadii.roundedFull,
            borderSide: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadii.roundedFull,
            borderSide: BorderSide(color: AppColors.primaryBrand, width: 2),
          ),
        ),
      ),
    );
  }
}

/// Standard Clinical Form Input Field
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMd(color: AppColors.slate700),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          style: AppTypography.bodyMd(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
