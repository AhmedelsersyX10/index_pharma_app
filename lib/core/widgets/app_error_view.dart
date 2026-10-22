import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_badges.dart';
import 'package:index_pharma/core/widgets/app_buttons.dart';

/// Clinical Clarity Error & Offline View
/// Follows Stitch Design System (F7 Empty & Error States).
/// Supports generic unexpected error states and network offline interruptions
/// with clinical reassurance and offline local data safeguards.
class AppErrorView extends StatelessWidget {
  final String? title;
  final String? message;
  final String? retryText;
  final VoidCallback? onRetry;
  final Widget? icon;
  final Widget? badge;
  final Widget? secondaryAction;
  final String? errorCode;
  final bool isOffline;
  final bool showDataSafeNotice;
  final EdgeInsetsGeometry padding;

  const AppErrorView({
    super.key,
    this.title,
    this.message,
    this.retryText,
    this.onRetry,
    this.icon,
    this.badge,
    this.secondaryAction,
    this.errorCode,
    this.isOffline = false,
    this.showDataSafeNotice = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.spaceLg,
      vertical: AppSpacing.spaceLg,
    ),
  });

  /// Dedicated constructor for offline/network interruption state
  const AppErrorView.offline({
    super.key,
    this.title,
    this.message,
    this.retryText,
    this.onRetry,
    this.icon,
    this.badge,
    this.secondaryAction,
    this.errorCode,
    this.showDataSafeNotice = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.spaceLg,
      vertical: AppSpacing.spaceLg,
    ),
  }) : isOffline = true;

  @override
  Widget build(BuildContext context) {
    final effectiveTitle =
        title ?? (isOffline ? AppLocaleKeys.errorOfflineTitle.tr() : AppLocaleKeys.errorTitle.tr());
    final effectiveMessage =
        message ??
        (isOffline
            ? AppLocaleKeys.errorOfflineMessage.tr()
            : AppLocaleKeys.errorDefaultMessage.tr());
    final effectiveRetryText = retryText ?? AppLocaleKeys.commonRetry.tr();

    final Widget? effectiveBadge =
        badge ??
        (isOffline
            ? AppBadge.error(
                label: AppLocaleKeys.errorOfflineBadge.tr(),
                icon: const Icon(Icons.cloud_off_rounded, size: 14),
              )
            : null);

    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ErrorIconBadge(icon: icon, isOffline: isOffline),
            const SizedBox(height: AppSpacing.spaceLg),
            if (effectiveBadge != null) ...[
              effectiveBadge,
              const SizedBox(height: AppSpacing.spaceSm),
            ],
            _ErrorContent(title: effectiveTitle, message: effectiveMessage),
            if (errorCode != null && errorCode!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.spaceMd),
              _ErrorDiagnosticCode(code: errorCode!),
            ],
            if (showDataSafeNotice) ...[
              const SizedBox(height: AppSpacing.spaceMd),
              const _ErrorDataSafeNotice(),
            ],
            if (onRetry != null || secondaryAction != null) ...[
              const SizedBox(height: AppSpacing.spaceLg),
              _ErrorActions(
                retryText: effectiveRetryText,
                onRetry: onRetry,
                isOffline: isOffline,
                secondaryAction: secondaryAction,
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
  final bool isOffline;

  const _ErrorIconBadge({this.icon, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.errorContainer,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.error.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          icon ??
          Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
            size: 42,
            color: colors.error,
          ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String title;
  final String message;

  const _ErrorContent({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.headlineMd(
            color: colors.onSurface,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spaceSm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(color: colors.slate600),
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorDiagnosticCode extends StatelessWidget {
  final String code;

  const _ErrorDiagnosticCode({required this.code});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: AppRadii.roundedMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.terminal_rounded, size: 16, color: colors.slate500),
          const SizedBox(width: AppSpacing.spaceXs),
          Text(
            code,
            style: AppTypography.labelSm(
              color: colors.slate700,
            ).copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class _ErrorDataSafeNotice extends StatelessWidget {
  const _ErrorDataSafeNotice();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: colors.borderSubtle, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.shield_rounded, size: 20, color: colors.medicalAmber),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocaleKeys.errorDataSafeTitle.tr(),
                  style: AppTypography.labelLg(color: colors.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocaleKeys.errorDataSafeDesc.tr(),
                  style: AppTypography.bodySm(color: colors.slate600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorActions extends StatelessWidget {
  final String retryText;
  final VoidCallback? onRetry;
  final bool isOffline;
  final Widget? secondaryAction;

  const _ErrorActions({
    required this.retryText,
    required this.onRetry,
    required this.isOffline,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onRetry != null)
          AppButton.primary(
            text: retryText,
            onPressed: onRetry,
            isFullWidth: false,
            height: 48,
            icon: Icon(isOffline ? Icons.sync_rounded : Icons.refresh_rounded, size: 20),
          ),
        if (onRetry != null && secondaryAction != null) const SizedBox(height: AppSpacing.spaceSm),
        ?secondaryAction,
      ],
    );
  }
}
