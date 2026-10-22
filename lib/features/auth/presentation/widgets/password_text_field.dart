import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_text_fields.dart';

/// Password input field with an interactive visibility toggle button.
///
/// Uses [setState] strictly for local eye-toggle visibility per project rules.
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final Widget? trailingLabelWidget;
  final Widget? helper;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool required;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.trailingLabelWidget,
    this.helper,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.onChanged,
    this.required = false,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      errorText: widget.errorText,
      trailingLabelWidget: widget.trailingLabelWidget,
      helper: widget.helper,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      textDirection: TextDirection.ltr,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      required: widget.required,
      prefix: const Icon(Icons.lock_outline_rounded, size: 20),
      suffix: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: context.colors.slate400,
          size: 20,
        ),
        onPressed: _toggleVisibility,
        tooltip: _obscureText
            ? AppLocaleKeys.authPasswordShow.tr()
            : AppLocaleKeys.authPasswordHide.tr(),
      ),
    );
  }
}
