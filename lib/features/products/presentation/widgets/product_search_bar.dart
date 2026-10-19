import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Search Bar for products catalog per Stitch Frame B3 & B5.
class ProductSearchBar extends StatefulWidget {
  const ProductSearchBar({
    super.key,
    required this.onChanged,
    this.initialValue,
    this.hintText,
  });

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
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
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
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadii.roundedFull,
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.bodyMd(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText:
                    widget.hintText ?? AppLocaleKeys.productsSearchHint.tr(),
                hintStyle: AppTypography.bodyMd(
                  color: AppColors.slate400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.slate400,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            },
          ),
        ],
      ),
    );
  }
}
