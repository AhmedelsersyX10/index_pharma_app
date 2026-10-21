import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Clarity Search Bar
/// Pill-shaped search bar with emerald icon and subtle focus glow.
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;
  final String? hintText;
  final bool autoFocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.onClear,
    this.hintText,
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
          hintText: hintText ?? AppLocaleKeys.commonSearchHint.tr(),
          hintStyle: AppTypography.bodyMd(color: AppColors.slate400),
          fillColor: AppColors.canvasPure,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          prefixIcon: const Padding(
            padding: EdgeInsetsDirectional.only(start: 16, end: 12),
            child: Icon(Icons.search_rounded, color: AppColors.primaryBrand, size: 24),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 44),
          suffixIcon: onFilterTap != null
              ? IconButton(
                  icon: const Icon(Icons.tune_rounded, color: AppColors.slate500),
                  onPressed: onFilterTap,
                  tooltip: AppLocaleKeys.commonFilter.tr(),
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
  final Widget? trailingLabelWidget;
  final Widget? helper;
  final String? hintText;
  final String? errorText;
  final TextStyle? errorStyle;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final int maxLines;
  final bool? enabled;
  final AutovalidateMode? autovalidateMode;
  final TextDirection? textDirection;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.trailingLabelWidget,
    this.helper,
    this.hintText,
    this.errorText,
    this.errorStyle,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.focusNode,
    this.maxLines = 1,
    this.enabled,
    this.autovalidateMode,
    this.textDirection,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || trailingLabelWidget != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(label!, style: AppTypography.labelMd(color: AppColors.slate700))
              else
                const SizedBox.shrink(),
              ?trailingLabelWidget,
            ],
          ),
          const SizedBox(height: AppSpacing.spaceXs),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          focusNode: focusNode,
          maxLines: maxLines,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          textDirection: textDirection,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: AppTypography.bodyMd(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            errorStyle: errorStyle,
            prefixIcon: prefix,
            suffixIcon: suffix,
          ),
        ),
        if (helper case final helperWidget?) ...[
          const SizedBox(height: AppSpacing.space2xs),
          helperWidget,
        ],
      ],
    );
  }
}
