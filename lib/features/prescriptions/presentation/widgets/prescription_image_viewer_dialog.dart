import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/app_colors.dart';

/// Full-screen dialog providing pinch-to-zoom and pan inspection of prescription images.
class PrescriptionImageViewerDialog extends StatelessWidget {
  const PrescriptionImageViewerDialog({
    super.key,
    this.imageUrl,
    this.localFilePath,
    this.title = 'معاينة الروشتة',
  }) : assert(imageUrl != null || localFilePath != null);

  final String? imageUrl;
  final String? localFilePath;
  final String title;

  static Future<void> show(
    BuildContext context, {
    String? imageUrl,
    String? localFilePath,
    String title = 'معاينة الروشتة',
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => PrescriptionImageViewerDialog(
        imageUrl: imageUrl,
        localFilePath: localFilePath,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar with Title and Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Zoomable Image Container
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.black,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: localFilePath != null
                        ? Image.file(
                            File(localFilePath!),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 48,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
