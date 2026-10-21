import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import '../utils/auth_failure_mapper.dart';

/// Clinical error banner displaying failure messages adhering to the Stitch design.
class AuthFailureBanner extends StatelessWidget {
  final Failure failure;
  final bool isLogin;
  final VoidCallback onDismiss;
  final VoidCallback? onAction;

  const AuthFailureBanner({
    super.key,
    required this.failure,
    required this.isLogin,
    required this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final title = AuthFailureMapper.toTitle(failure, isLogin: isLogin);
    final message = AuthFailureMapper.toMessage(failure);
    final isConflict = failure is Conflict;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: const BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadii.roundedXl,
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                child: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleMd(color: AppColors.onErrorContainer)),
                    const SizedBox(height: AppSpacing.space2xs),
                    Text(
                      message,
                      style: AppTypography.bodySm(
                        color: AppColors.onErrorContainer.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.onErrorContainer),
                onPressed: onDismiss,
              ),
            ],
          ),
          if (!isLogin && isConflict && onAction != null) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            InkWell(
              onTap: onAction,
              borderRadius: AppRadii.roundedSm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.canvasPure,
                  borderRadius: AppRadii.roundedSm,
                  boxShadow: AppShadows.level1,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocaleKeys.authSignInLink.tr(),
                      style: AppTypography.labelMd(color: AppColors.onErrorContainer),
                    ),
                    const SizedBox(width: AppSpacing.space2xs),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.onErrorContainer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
