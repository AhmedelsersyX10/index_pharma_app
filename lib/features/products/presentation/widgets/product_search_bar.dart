import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Search Bar for products catalog per Stitch Frame B3 & B5.
class ProductSearchBar extends StatefulWidget {
  const ProductSearchBar({super.key, required this.onChanged, this.initialValue, this.hintText});

  final ValueChanged<String> onChanged;
  final String? initialValue;
  final String? hintText;

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant ProductSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: AppTypography.bodyMd(color: colors.onSurface),
      decoration: InputDecoration(
        hintText: widget.hintText ?? AppLocaleKeys.commonSearchHint.tr(),
        hintStyle: AppTypography.bodyMd(color: colors.slate400),
        fillColor: colors.surface,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
          child: Icon(Icons.search_rounded, color: colors.primaryBrand, size: 24),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 44),
        border: OutlineInputBorder(
          borderRadius: AppRadii.roundedFull,
          borderSide: BorderSide(color: colors.borderSubtle, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.roundedFull,
          borderSide: BorderSide(color: colors.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.roundedFull,
          borderSide: BorderSide(color: colors.primaryBrand, width: 2),
        ),
      ),
    );
  }
}
