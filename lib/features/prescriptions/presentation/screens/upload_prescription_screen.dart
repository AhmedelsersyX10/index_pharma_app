import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/app_colors.dart';
import 'package:index_pharma/core/theme/app_spacing.dart';
import 'package:index_pharma/core/utils/app_router.dart';
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

    return BlocProvider<PrescriptionCubit>(
      create: (_) => getIt<PrescriptionCubit>(),
      child: const _UploadPrescriptionView(),
    );
  }
}

class _UploadPrescriptionView extends StatefulWidget {
  const _UploadPrescriptionView();

  @override
  State<_UploadPrescriptionView> createState() => _UploadPrescriptionViewState();
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
    final newText = current.isEmpty ? suggestion : '$current$separator$suggestion';
    if (newText.length <= 250) {
      _notesController.text = newText;
      context.read<PrescriptionCubit>().updateNotes(newText);
      setState(() {});
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.canvasPure,
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
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.brandMintSurface,
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: Text(
                  AppLocaleKeys.prescriptionsCameraBtn.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(AppLocaleKeys.prescriptionsCameraDesc.tr()),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  context.read<PrescriptionCubit>().pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Icon(Icons.photo_library, color: AppColors.primary),
                ),
                title: Text(
                  AppLocaleKeys.prescriptionsGalleryBtn.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(AppLocaleKeys.prescriptionsGalleryDesc.tr()),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  context.read<PrescriptionCubit>().pickImage(ImageSource.gallery);
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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go(AppRouter.kStoreView);
                }
              },
            ),
            title: Text(
              AppLocaleKeys.prescriptionsUploadTitle.tr(),
              style: const TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            centerTitle: false,
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
                if (state.uploadStep == PrescriptionUploadStep.fileSizeExceeded) ...[
                  _buildErrorBanner(
                    icon: Icons.warning_amber_rounded,
                    title: AppLocaleKeys.prescriptionsErrorSizeTitle.tr(),
                    description: AppLocaleKeys.prescriptionsErrorSizeDesc.tr(),
                    actionText: AppLocaleKeys.prescriptionsGalleryBtn.tr(),
                    onAction: _showImageSourceModal,
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
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),
                ],

                // 3. Action Picker (Camera or Gallery cards)
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerCard(
                        icon: Icons.add_a_photo,
                        title: AppLocaleKeys.prescriptionsCameraBtn.tr(),
                        subtitle: AppLocaleKeys.prescriptionsCameraDesc.tr(),
                        isPrimary: true,
                        onTap: isProcessing ? null : () => cubit.pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: _buildPickerCard(
                        icon: Icons.photo_library,
                        title: AppLocaleKeys.prescriptionsGalleryBtn.tr(),
                        subtitle: AppLocaleKeys.prescriptionsGalleryDesc.tr(),
                        isPrimary: false,
                        onTap: isProcessing ? null : () => cubit.pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceMd),

                // 4. Preview & Drop / Uploading Container
                _buildPreviewContainer(state, cubit, isProcessing),
                const SizedBox(height: AppSpacing.spaceMd),

                // 5. Optional Notes Field
                _buildNotesField(cubit, isProcessing),
                const SizedBox(height: AppSpacing.spaceMd),

                // 6. Assurance & Steps Mini-Card
                _buildAssuranceStepsCard(),
                const SizedBox(height: AppSpacing.spaceLg),

                // 7. Submission Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (state.canSubmit && !isProcessing)
                        ? () => cubit.uploadAndSubmit()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
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
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                AppLocaleKeys.prescriptionsSubmittingTitle.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send, size: 20, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                AppLocaleKeys.prescriptionsSubmitBtn.tr(),
                                style: TextStyle(
                                  color: state.canSubmit ? Colors.white : AppColors.neutral,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: AppSpacing.spaceXl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isPrimary,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
              vertical: AppSpacing.spaceMd,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isPrimary
                      ? AppColors.brandMintSurface
                      : AppColors.surfaceContainerLow,
                  child: Icon(
                    icon,
                    size: 24,
                    color: isPrimary ? AppColors.brandEmeraldDark : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.neutral),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContainer(
    PrescriptionState state,
    PrescriptionCubit cubit,
    bool isProcessing,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: isProcessing
          ? _buildUploadingProgressView(state)
          : (state.pickedImagePath != null &&
                state.uploadStep != PrescriptionUploadStep.fileSizeExceeded)
          ? _buildSelectedPreviewView(state, cubit)
          : _buildEmptyDropView(),
    );
  }

  Widget _buildEmptyDropView() {
    return InkWell(
      onTap: _showImageSourceModal,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceLg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.brandMintBorder,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.brandMintSurface,
              child: Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              AppLocaleKeys.prescriptionsDropHint.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocaleKeys.prescriptionsDropSubhint.tr(),
              style: const TextStyle(fontSize: 12, color: AppColors.neutral),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            ElevatedButton.icon(
              onPressed: _showImageSourceModal,
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: Text(AppLocaleKeys.prescriptionsBrowseFiles.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.canvasPure,
                foregroundColor: AppColors.primary,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPreviewView(PrescriptionState state, PrescriptionCubit cubit) {
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
                  decoration: const BoxDecoration(
                    color: AppColors.brandEmeraldDark,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocaleKeys.prescriptionsPreviewTitle.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              state.formattedPickedFileSize,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutral,
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
                  child: Image.file(File(state.pickedImagePath!), fit: BoxFit.cover),
                ),
              ),

              // Quality badge (Top Right)
              PositionedDirectional(
                top: 8,
                end: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: AppColors.brandEmeraldDark),
                      const SizedBox(width: 4),
                      Text(
                        AppLocaleKeys.prescriptionsQualityExcellent.tr(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Zoom hint (Bottom Left)
              PositionedDirectional(
                bottom: 8,
                start: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.zoom_in, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        AppLocaleKeys.prescriptionsTapToZoom.tr(),
                        style: const TextStyle(fontSize: 11, color: Colors.white),
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
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
            TextButton.icon(
              onPressed: () => cubit.clearPickedImage(),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(AppLocaleKeys.prescriptionsDeleteImage.tr()),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadingProgressView(PrescriptionState state) {
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
                  color: AppColors.brandMintSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${state.pickedImageName ?? 'prescription.jpg'} (${state.formattedPickedFileSize})',
                      style: const TextStyle(fontSize: 12, color: AppColors.neutral),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: const LinearProgressIndicator(
              minHeight: 6,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: [
                const Icon(Icons.security, size: 14, color: AppColors.brandEmeraldDark),
                const SizedBox(width: 4),
                Text(
                  AppLocaleKeys.prescriptionsPrivacyNotice.tr(),
                  style: const TextStyle(fontSize: 11, color: AppColors.neutral),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField(PrescriptionCubit cubit, bool isProcessing) {
    final length = _notesController.text.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note, size: 20, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    AppLocaleKeys.prescriptionsNotesLabel.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '$length / 250',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutral,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocaleKeys.prescriptionsNotesDesc.tr(),
            style: const TextStyle(fontSize: 12, color: AppColors.neutral),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          TextField(
            controller: _notesController,
            enabled: !isProcessing,
            maxLines: 3,
            maxLength: 250,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                const SizedBox.shrink(),
            onChanged: (val) {
              cubit.updateNotes(val);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: AppLocaleKeys.prescriptionsNotesHint.tr(),
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.neutral),
              fillColor: AppColors.surfaceSubtle,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
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
              ),
              _buildSuggestionChip(
                AppLocaleKeys.prescriptionsChipDosage.tr(),
                AppLocaleKeys.prescriptionsChipDosageText.tr(),
              ),
              _buildSuggestionChip(
                AppLocaleKeys.prescriptionsChipUrgent.tr(),
                AppLocaleKeys.prescriptionsChipUrgentText.tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label, String value) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
      onPressed: () => _appendNote(value),
    );
  }

  Widget _buildAssuranceStepsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                AppLocaleKeys.prescriptionsStepsTitle.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          _buildStepRow(
            stepNumber: AppLocaleKeys.prescriptionsStepNum1.tr(),
            text: AppLocaleKeys.prescriptionsStep1.tr(),
          ),
          const SizedBox(height: 8),
          _buildStepRow(
            stepNumber: AppLocaleKeys.prescriptionsStepNum2.tr(),
            text: AppLocaleKeys.prescriptionsStep2.tr(),
          ),
          const SizedBox(height: 8),
          _buildStepRow(
            stepNumber: AppLocaleKeys.prescriptionsStepNum3.tr(),
            text: AppLocaleKeys.prescriptionsStep3.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({required String stepNumber, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: AppColors.primary,
          child: Text(
            stepNumber,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.onSurface, height: 1.4),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.error,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppColors.onErrorContainer),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(actionText, style: const TextStyle(fontSize: 12)),
                    ),
                    if (secondaryActionText != null && onSecondaryAction != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: onSecondaryAction,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.onSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(secondaryActionText, style: const TextStyle(fontSize: 12)),
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
