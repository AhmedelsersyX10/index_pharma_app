import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_text_fields.dart';

/// Password input field with an interactive visibility toggle button.
///
/// Uses [setState] strictly for local eye-toggle visibility per project rules.
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final Widget? trailingLabelWidget;
  final Widget? helper;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.trailingLabelWidget,
    this.helper,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
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
      trailingLabelWidget: widget.trailingLabelWidget,
      helper: widget.helper,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      textDirection: TextDirection.ltr,
      validator: widget.validator,
      onChanged: widget.onFieldSubmitted,
      prefix: const Padding(
        padding: EdgeInsetsDirectional.only(start: 12, end: 8),
        child: Icon(Icons.lock_outline_rounded, color: AppColors.slate400, size: 20),
      ),
      suffix: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: AppColors.slate400,
          size: 20,
        ),
        onPressed: _toggleVisibility,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      ),
    );
  }
}
