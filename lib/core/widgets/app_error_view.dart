import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_buttons.dart';

/// Clinical Clarity Error View
/// Renders a user-friendly error message with an optional title, icon,
/// and a retry callback button.
class AppErrorView extends StatelessWidget {
  final String? title;
  final String? message;
  final String? retryText;
  final VoidCallback? onRetry;
  final Widget? icon;
  final EdgeInsetsGeometry padding;

  const AppErrorView({
    super.key,
    this.title,
    this.message,
    this.retryText,
    this.onRetry,
    this.icon,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.spaceLg,
      vertical: AppSpacing.spaceLg,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? AppLocaleKeys.errorTitle.tr();
    final effectiveMessage = message ?? AppLocaleKeys.errorDefaultMessage.tr();
    final effectiveRetryText = retryText ?? AppLocaleKeys.commonRetry.tr();

    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ErrorIconBadge(icon: icon),
            const SizedBox(height: AppSpacing.spaceLg),
            _ErrorContent(
              title: effectiveTitle,
              message: effectiveMessage,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.spaceLg),
              _ErrorRetryButton(
                text: effectiveRetryText,
                onRetry: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorIconBadge extends StatelessWidget {
  final Widget? icon;

  const _ErrorIconBadge({this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.errorContainer,
        shape: BoxShape.circle,
      ),
      child: icon ??
          const Icon(
            Icons.error_outline_rounded,
            size: 36,
            color: AppColors.error,
          ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String title;
  final String message;

  const _ErrorContent({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.titleLg(color: AppColors.onSurface),
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd(color: AppColors.slate600),
          ),
        ],
      ],
    );
  }
}

class _ErrorRetryButton extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _ErrorRetryButton({
    required this.text,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      text: text,
      onPressed: onRetry,
      isFullWidth: false,
      height: 48,
      icon: const Icon(Icons.refresh_rounded, size: 20),
    );
  }
}
