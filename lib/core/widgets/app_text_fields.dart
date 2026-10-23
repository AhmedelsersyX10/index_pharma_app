import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Clarity Search Bar
/// Pill-shaped search bar with emerald icon and subtle focus glow.
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;
  final String? hintText;
  final bool autoFocus;
  final TextInputAction textInputAction;

  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onClear,
    this.hintText,
    this.autoFocus = false,
    this.textInputAction = TextInputAction.search,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shadows = context.isDarkMode ? AppShadows.darkLevel1 : AppShadows.level1;

    return Container(
      decoration: BoxDecoration(borderRadius: AppRadii.roundedFull, boxShadow: shadows),
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        style: AppTypography.bodyMd(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: hintText ?? AppLocaleKeys.commonSearchHint.tr(),
          hintStyle: AppTypography.bodyMd(color: colors.slate400),
          fillColor: colors.surface,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
            child: Icon(Icons.search_rounded, color: colors.primaryBrand, size: 24),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 44),
          suffixIcon: onFilterTap != null
              ? IconButton(
                  icon: Icon(Icons.tune_rounded, color: colors.slate500),
                  onPressed: onFilterTap,
                  tooltip: AppLocaleKeys.commonFilter.tr(),
                )
              : null,
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
      ),
    );
  }
}

/// Standard Clinical Form Input Field
class AppTextField extends StatefulWidget {
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
  final bool required;
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
    this.required = false,
    this.autovalidateMode,
    this.textDirection,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> with SingleTickerProviderStateMixin {
  late FocusNode _effectiveFocusNode;
  late final AnimationController _focusAnim;
  late final Animation<double> _focusOpacity;
  bool _ownsNode = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _effectiveFocusNode = FocusNode();
      _ownsNode = true;
    } else {
      _effectiveFocusNode = widget.focusNode!;
    }
    _isFocused = _effectiveFocusNode.hasFocus;
    _focusAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: _isFocused ? 1.0 : 0.0,
    );
    _focusOpacity = CurvedAnimation(parent: _focusAnim, curve: Curves.easeInOut);
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _effectiveFocusNode.hasFocus;
    if (_isFocused != focused) {
      setState(() => _isFocused = focused);
      if (focused) {
        _focusAnim.forward();
      } else {
        _focusAnim.reverse();
      }
    }
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _effectiveFocusNode.removeListener(_onFocusChange);
      if (_ownsNode) {
        _effectiveFocusNode.dispose();
      }
      if (widget.focusNode == null) {
        _effectiveFocusNode = FocusNode();
        _ownsNode = true;
      } else {
        _effectiveFocusNode = widget.focusNode!;
        _ownsNode = false;
      }
      _isFocused = _effectiveFocusNode.hasFocus;
      _effectiveFocusNode.addListener(_onFocusChange);
      if (_isFocused) {
        _focusAnim.value = 1.0;
      } else {
        _focusAnim.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    if (_ownsNode) {
      _effectiveFocusNode.dispose();
    }
    _focusAnim.dispose();
    super.dispose();
  }

  Widget _buildLabel(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.label != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.label!,
                style: AppTypography.labelMd(
                  color: _isFocused ? colors.primaryBrand : colors.slate700,
                ),
              ),
              if (widget.required) ...[
                const SizedBox(width: 3),
                Text('*', style: AppTypography.labelMd(color: colors.error)),
              ],
            ],
          )
        else
          const SizedBox.shrink(),
        if (widget.trailingLabelWidget != null) widget.trailingLabelWidget!,
      ],
    );
  }

  Widget _buildField(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText != null;

    return AnimatedBuilder(
      animation: _focusOpacity,
      builder: (context, child) {
        final animValue = _focusOpacity.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadii.roundedBase,
            boxShadow: hasError || animValue == 0
                ? null
                : [
                    BoxShadow(
                      color: colors.primaryBrand.withValues(alpha: 0.12 * animValue),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: child!,
        );
      },
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        focusNode: _effectiveFocusNode,
        maxLines: widget.maxLines,
        enabled: widget.enabled,
        autovalidateMode: widget.autovalidateMode,
        textDirection: widget.textDirection,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: widget.validator,
        style: AppTypography.bodyMd(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: widget.hintText,
          errorText: widget.errorText,
          errorStyle: widget.errorStyle,
          prefixIcon: widget.prefix,
          prefixIconColor: hasError
              ? colors.error
              : (_isFocused ? colors.primaryBrand : colors.slate400),
          suffixIcon: widget.suffix,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null || widget.trailingLabelWidget != null) ...[
          _buildLabel(context),
          const SizedBox(height: AppSpacing.spaceXs),
        ],
        _buildField(context),
        if (widget.helper case final helperWidget?) ...[
          const SizedBox(height: AppSpacing.space2xs),
          helperWidget,
        ],
      ],
    );
  }
}
