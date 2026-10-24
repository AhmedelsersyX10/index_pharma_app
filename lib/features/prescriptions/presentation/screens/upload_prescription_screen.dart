import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/core/widgets/app_text_fields.dart';
import '../cubit/prescription_cubit.dart';
import '../cubit/prescription_state.dart';
import '../widgets/prescription_image_viewer_dialog.dart';

/// Screen for uploading a prescription (Stitch D1).
class UploadPrescriptionScreen extends StatelessWidget {
  const UploadPrescriptionScreen({super.key, this.cubit});

  final PrescriptionCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<PrescriptionCubit>.value(
        value: cubit!,
        child: const _UploadPrescriptionView(),
      );
    }

    return const _UploadPrescriptionView();
  }
}

class _UploadPrescriptionView extends StatefulWidget {
  const _UploadPrescriptionView();

  @override
  State<_UploadPrescriptionView> createState() =>
      _UploadPrescriptionViewState();
}

class _UploadPrescriptionViewState extends State<_UploadPrescriptionView> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<PrescriptionCubit>();
    _notesController = TextEditingController(text: cubit.state.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _appendNote(String suggestion) {
    final current = _notesController.text.trim();
    final separator = AppLocaleKeys.commonListSeparator.tr();
    final newText = current.isEmpty
        ? suggestion
        : '$current$separator$suggestion';
    if (newText.length <= 250) {
      _notesController.text = newText;
      context.read<PrescriptionCubit>().updateNotes(newText);
      setState(() {});
    }
  }

  void _showImageSourceModal() {
    final colors = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.canvasPure,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: AppSpacing.spaceMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.brandMintSurface,
                  child: Icon(Icons.camera_alt, color: colors.primary),
                ),
                title: Text(
                  AppLocaleKeys.prescriptionsCameraBtn.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(AppLocaleKeys.prescriptionsCameraDesc.tr()),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  context.read<PrescriptionCubit>().pickImage(
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.surfaceContainerLow,
                  child: Icon(Icons.photo_library, color: colors.primary),
                ),
                title: Text(
                  AppLocaleKeys.prescriptionsGalleryBtn.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(AppLocaleKeys.prescriptionsGalleryDesc.tr()),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  context.read<PrescriptionCubit>().pickImage(
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<PrescriptionCubit, PrescriptionState>(
      listener: (context, state) {
        if (state.uploadStep == PrescriptionUploadStep.submitted &&
            state.lastSubmittedPrescription != null) {
          context.push(
            AppRouter.kPrescriptionConfirmationView,
            extra: state.lastSubmittedPrescription,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<PrescriptionCubit>();
        final isProcessing =
            state.uploadStep == PrescriptionUploadStep.uploading ||
            state.uploadStep == PrescriptionUploadStep.submitting;

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppPageBar(
            title: AppLocaleKeys.prescriptionsUploadTitle.tr(),
            onBackPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRouter.kStoreView);
              }
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.spaceSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Error Banner: File size exceeded (> 5MB)
                if (state.uploadStep ==
                    PrescriptionUploadStep.fileSizeExceeded) ...[
                  _buildErrorBanner(
                    icon: Icons.warning_amber_rounded,
                    title: AppLocaleKeys.prescriptionsErrorSizeTitle.tr(),
                    description: AppLocaleKeys.prescriptionsErrorSizeDesc.tr(),
                    actionText: AppLocaleKeys.prescriptionsGalleryBtn.tr(),
                    onAction: _showImageSourceModal,
                    colors: colors,
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),
                ],

                // 2. Error Banner: Upload / Network Failure
                if (state.uploadStep == PrescriptionUploadStep.failure &&
                    state.uploadErrorMessage != null) ...[
                  _buildErrorBanner(
                    icon: Icons.cloud_off,
                    title: AppLocaleKeys.prescriptionsErrorUploadTitle.tr(),
                    description: state.uploadErrorMessage!,
                    actionText: AppLocaleKeys.prescriptionsRetryUpload.tr(),
                    onAction: () => cubit.uploadAndSubmit(),
                    secondaryActionText: AppLocaleKeys.prescriptionsCancel.tr(),
                    onSecondaryAction: () => cubit.clearPickedImage(),
                    colors: colors,
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),
                ],

                // 3. Preview & Drop / Uploading Container
                _buildPreviewContainer(state, cubit, isProcessing, colors),
                const SizedBox(height: AppSpacing.spaceMd),

                // 4. Optional Notes Field
                _buildNotesField(cubit, isProcessing, colors),
                const SizedBox(height: AppSpacing.spaceMd),

                // 5. Assurance & Steps Mini-Card
                _buildAssuranceStepsCard(colors),
                const SizedBox(height: AppSpacing.spaceLg),

                // 7. Submission Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (state.canSubmit && !isProcessing)
                        ? () => cubit.uploadAndSubmit()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      disabledBackgroundColor: colors.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      elevation: 0,
                    ),
                    child: isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppLocaleKeys.prescriptionsSubmittingTitle.tr(),
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.send,
                                size: 20,
                                color: colors.onPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocaleKeys.prescriptionsSubmitBtn.tr(),
                                style: TextStyle(
                                  color: state.canSubmit
                                      ? colors.onPrimary
                                      : colors.neutral,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewContainer(
    PrescriptionState state,
    PrescriptionCubit cubit,
    bool isProcessing,
    AppColorsExtension colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.shadowsLevel1,
      ),
      child: isProcessing
          ? _buildUploadingProgressView(state, colors)
          : (state.pickedImagePath != null &&
                state.uploadStep != PrescriptionUploadStep.fileSizeExceeded)
          ? _buildSelectedPreviewView(state, cubit, colors)
          : _buildEmptyDropView(colors),
    );
  }

  Widget _buildEmptyDropView(AppColorsExtension colors) {
    return InkWell(
      onTap: _showImageSourceModal,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceLg,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.brandMintBorder,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colors.brandMintSurface,
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              AppLocaleKeys.prescriptionsDropHint.tr(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocaleKeys.prescriptionsDropSubhint.tr(),
              style: TextStyle(fontSize: 12, color: colors.neutral),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            ElevatedButton.icon(
              onPressed: _showImageSourceModal,
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: Text(AppLocaleKeys.prescriptionsBrowseFiles.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.canvasPure,
                foregroundColor: colors.primary,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPreviewView(
    PrescriptionState state,
    PrescriptionCubit cubit,
    AppColorsExtension colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.brandEmeraldDark,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocaleKeys.prescriptionsPreviewTitle.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              state.formattedPickedFileSize,
              style: TextStyle(
                fontSize: 12,
                color: colors.neutral,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceSm),

        // Image Container with Tap-To-Zoom and Quality Tag
        GestureDetector(
          onTap: () {
            PrescriptionImageViewerDialog.show(
              context,
              localFilePath: state.pickedImagePath,
              title: AppLocaleKeys.prescriptionsPreviewTitle.tr(),
            );
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(
                    File(state.pickedImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Zoom hint (Bottom Left)
              PositionedDirectional(
                bottom: 8,
                start: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in, size: 14, color: colors.onPrimary),
                      const SizedBox(width: 4),
                      Text(
                        AppLocaleKeys.prescriptionsTapToZoom.tr(),
                        style: TextStyle(fontSize: 11, color: colors.onPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spaceSm),

        // Actions: Replace & Delete
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _showImageSourceModal,
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: Text(AppLocaleKeys.prescriptionsReplaceImage.tr()),
              style: TextButton.styleFrom(foregroundColor: colors.primary),
            ),
            TextButton.icon(
              onPressed: () => cubit.clearPickedImage(),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(AppLocaleKeys.prescriptionsDeleteImage.tr()),
              style: TextButton.styleFrom(foregroundColor: colors.error),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadingProgressView(
    PrescriptionState state,
    AppColorsExtension colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.brandMintSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.uploadStep == PrescriptionUploadStep.submitting
                          ? AppLocaleKeys.prescriptionsSubmittingTitle.tr()
                          : AppLocaleKeys.prescriptionsUploadingTitle.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${state.pickedImageName ?? 'prescription.jpg'} (${state.formattedPickedFileSize})',
                      style: TextStyle(fontSize: 12, color: colors.neutral),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              minHeight: 6,
              color: colors.primary,
              backgroundColor: colors.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: [
                Icon(Icons.security, size: 14, color: colors.brandEmeraldDark),
                const SizedBox(width: 4),
                Text(
                  AppLocaleKeys.prescriptionsPrivacyNotice.tr(),
                  style: TextStyle(fontSize: 11, color: colors.neutral),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField(
    PrescriptionCubit cubit,
    bool isProcessing,
    AppColorsExtension colors,
  ) {
    final length = _notesController.text.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.shadowsLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note, size: 20, color: colors.primary),
                  const SizedBox(width: 6),
                  Text(
                    AppLocaleKeys.prescriptionsNotesLabel.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '$length / 250',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.neutral,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocaleKeys.prescriptionsNotesDesc.tr(),
            style: TextStyle(fontSize: 12, color: colors.neutral),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          AppTextField(
            controller: _notesController,
            enabled: !isProcessing,
            maxLines: 3,
            hintText: AppLocaleKeys.prescriptionsNotesHint.tr(),
            onChanged: (val) {
              cubit.updateNotes(val);
              setState(() {});
            },
          ),
          const SizedBox(height: 8),

          // Suggestion Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildSuggestionChip(
                AppLocaleKeys.prescriptionsChipAlternatives.tr(),
                AppLocaleKeys.prescriptionsChipAlternativesText.tr(),
                colors: colors,
              ),
              _buildSuggestionChip(
                AppLocaleKeys.prescriptionsChipDosage.tr(),
                AppLocaleKeys.prescriptionsChipDosageText.tr(),
                colors: colors,
              ),
              _buildSuggestionChip(
                AppLocaleKeys.prescriptionsChipUrgent.tr(),
                AppLocaleKeys.prescriptionsChipUrgentText.tr(),
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
    String label,
    String value, {
    required AppColorsExtension colors,
  }) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
      ),
      backgroundColor: colors.surfaceContainerLow,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
      onPressed: () => _appendNote(value),
    );
  }

  Widget _buildAssuranceStepsCard(AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 20, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                AppLocaleKeys.prescriptionsStepsTitle.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          _buildStepRow(
            stepNumber: AppLocaleKeys.prescriptionsStepNum1.tr(),
            text: AppLocaleKeys.prescriptionsStep1.tr(),
            colors: colors,
          ),
          const SizedBox(height: 8),
          _buildStepRow(
            stepNumber: AppLocaleKeys.prescriptionsStepNum2.tr(),
            text: AppLocaleKeys.prescriptionsStep2.tr(),
            colors: colors,
          ),
          const SizedBox(height: 8),
          _buildStepRow(
            stepNumber: AppLocaleKeys.prescriptionsStepNum3.tr(),
            text: AppLocaleKeys.prescriptionsStep3.tr(),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String text,
    required AppColorsExtension colors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: colors.primary,
          child: Text(
            stepNumber,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner({
    required IconData icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    required AppColorsExtension colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.error,
            child: Icon(icon, size: 18, color: colors.onPrimary),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        actionText,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (secondaryActionText != null &&
                        onSecondaryAction != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: onSecondaryAction,
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onSurface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          secondaryActionText,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
