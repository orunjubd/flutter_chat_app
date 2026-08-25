// video_validation_service.dart
import 'dart:io';
import 'package:chat_app/core/config/media_config.dart';

class VideoValidationService {
  const VideoValidationService();

  Future<void> validateFile({
    required File file,
    required int fileSize,
    required String? mimeType,
    required Duration duration,
    required int? width,
    required int? height,
  }) async {
    if (!await file.exists()) {
      throw ArgumentError('Video file does not exist: ${file.path}');
    }

    if (fileSize <= 0) {
      throw StateError('Selected video file is empty.');
    }
    if (fileSize > MediaConfig.maxVideoSizeInBytes) {
      throw StateError(
        'Selected video exceeds the maximum allowed size '
        '(${MediaConfig.maxVideoSizeInMB} MB).',
      );
    }

    if (mimeType == null ||
        !MediaConfig.allowedVideoMimeTypes.contains(mimeType)) {
      throw StateError(
        'Unsupported video format${mimeType != null ? ' ($mimeType)' : ''}.',
      );
    }

    if (duration > MediaConfig.maxVideoDuration) {
      throw StateError(
        'Selected video exceeds the maximum allowed duration '
        '(${MediaConfig.maxVideoDuration.inMinutes} min).',
      );
    }
    if (duration < const Duration(milliseconds: 200)) {
      throw StateError('Selected video is too short.');
    }

    if (MediaConfig.enforceVideoResolutionForTesting) {
      if ((width != null && width > MediaConfig.maxVideoWidth) ||
          (height != null && height > MediaConfig.maxVideoHeight)) {
        throw StateError(
          'Selected video resolution exceeds the maximum allowed '
          '${MediaConfig.maxVideoWidth}×${MediaConfig.maxVideoHeight}.',
        );
      }
    }
  }

  /// Resolves a mime type for [path], falling back to extension-based
  /// lookup when [mimeType] isn't populated (common for camera-captured
  /// video on Android/iOS). Mirrors VideoPickerService's resolution so
  /// both video sources are typed identically.
  String? resolveMimeType({required String? mimeType, required String path}) {
    if (mimeType != null &&
        MediaConfig.allowedVideoMimeTypes.contains(mimeType)) {
      return mimeType;
    }

    final extension = path.split('.').last.toLowerCase();
    if (!MediaConfig.allowedVideoExtensions.contains(extension)) {
      return null;
    }

    return switch (extension) {
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'mkv' => 'video/x-matroska',
      'webm' => 'video/webm',
      _ => null,
    };
  }
}
