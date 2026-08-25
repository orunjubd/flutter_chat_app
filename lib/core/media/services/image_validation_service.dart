import 'dart:io';
import 'package:chat_app/core/config/media_config.dart';
import 'package:flutter/material.dart';

/// Shared validation rules for all image sources — gallery-picked and
/// camera-captured images both pass through this same layer, sourced
/// from MediaConfig, mirroring VideoValidationService's pattern.
class ImageValidationService {
  const ImageValidationService();

  Future<void> validateFile({
    required File file,
    required int fileSize,
    required String? mimeType,
  }) async {
    debugPrint('🛡️ [ImageValidation] Starting validation tests pipeline...');
    // 1. File existence
    if (!await file.exists()) {
      throw ArgumentError('Image file does not exist: ${file.path}');
    }
    debugPrint('   👉 File exists: PASS');

    // 2. Empty file
    if (fileSize <= 0) {
      debugPrint(
        '❌ [ImageValidation] Test failed: File contains 0 bytes payload.',
      );
      throw StateError('Selected image file is empty.');
    }
    debugPrint('   👉 File size > 0: PASS ($fileSize bytes)');

    // 3. File-size limit
    if (fileSize > MediaConfig.maxImageSizeInBytes) {
      debugPrint(
        '❌ [ImageValidation] Test D failed: Size exceeds maximum limit.',
      );
      throw StateError(
        'Selected image exceeds the maximum allowed size '
        '(${MediaConfig.maxImageSizeInMB} MB).',
      );
    }
    debugPrint('   👉 Size limit verification: PASS');

    // 4. Image format
    if (mimeType == null ||
        !MediaConfig.allowedImageMimeTypes.contains(mimeType)) {
      debugPrint(
        '❌ [ImageValidation] Test E failed: Format support lookup failed for "$mimeType".',
      );
      throw StateError(
        'Unsupported image format${mimeType != null ? ' ($mimeType)' : ''}.',
      );
    }
    debugPrint('   👉 MIME verification: PASS ($mimeType)');
    debugPrint(
      '✅ [ImageValidation] Validation matrix: PASS. Codebase safe to dispatch.',
    );

    // Resolution is intentionally not enforced here. MediaConfig.maxImageWidth/
    // maxImageHeight are compression targets for the existing image
    // compression step, not upload-rejection rules — same decision made
    // for video's maxVideoWidth/maxVideoHeight.
  }

  /// Resolves a mime type for [path], falling back to extension-based
  /// lookup when [mimeType] isn't populated by the picker/camera.
  String? resolveMimeType({required String? mimeType, required String path}) {
    debugPrint('🔍 [MimeResolver] Evaluating media encoding streams...');
    debugPrint('   👉 Input MIME from picker: $mimeType');

    if (mimeType != null &&
        MediaConfig.allowedImageMimeTypes.contains(mimeType)) {
      debugPrint('✅ [MimeResolver] MIME resolved from picker: $mimeType');
      return mimeType;
    }

    final extension = path.split('.').last.toLowerCase();
    debugPrint(
      '   👉 Mime missing or loose, checking split extension marker: .$extension',
    );
    if (!MediaConfig.allowedImageExtensions.contains(extension)) {
      debugPrint(
        '❌ [MimeResolver] Unsupported file extension found: .$extension',
      );
      return null;
    }

    //return switch (extension) {
    final resolved = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => null,
    };
    debugPrint('✅ [MimeResolver] MIME resolved via suffix lookup: $resolved');
    return resolved;
  }
}
