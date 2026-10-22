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
    final colors = context.colors;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: colors.borderSubtle,
          width: 1,
        ),
        boxShadow: context.shadowsLevel1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: colors.primary,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.bodyMd(
                color: colors.onSurface,
              ),
              decoration: InputDecoration(
                hintText:
                    widget.hintText ?? AppLocaleKeys.productsSearchHint.tr(),
                hintStyle: AppTypography.bodyMd(
                  color: colors.neutral,
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
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colors.neutral,
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
