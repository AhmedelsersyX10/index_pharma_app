import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Clarity Loading Indicator
/// Renders a centered circular progress indicator styled with brand colors
/// and an optional supportive loading message.
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? message;
  final TextStyle? messageStyle;

  const AppLoadingIndicator({
    super.key,
    this.size = 36.0,
    this.color,
    this.strokeWidth = 3.0,
    this.message,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryBrand;

    final spinner = _LoadingSpinner(
      size: size,
      color: effectiveColor,
      strokeWidth: strokeWidth,
    );

    if (message == null || message!.isEmpty) {
      return Center(child: spinner);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          spinner,
          const SizedBox(height: AppSpacing.spaceMd),
          _LoadingMessage(
            message: message!,
            style: messageStyle,
          ),
        ],
      ),
    );
  }
}

class _LoadingSpinner extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const _LoadingSpinner({
    required this.size,
    required this.color,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _LoadingMessage extends StatelessWidget {
  final String message;
  final TextStyle? style;

  const _LoadingMessage({
    required this.message,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: style ?? AppTypography.bodyMd(color: AppColors.slate600),
    );
  }
}
