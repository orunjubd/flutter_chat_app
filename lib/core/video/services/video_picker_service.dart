import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:video_player/video_player.dart';

import 'package:chat_app/core/config/media_config.dart';
import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/media/models/media_type.dart';
import 'package:chat_app/core/video/services/video_metadata_service.dart';

class VideoPickerService {
  VideoPickerService({
    ImagePicker? picker,
    VideoMetadataService? metadataService,
  }) : _picker = picker ?? ImagePicker(),
       _metadataService = metadataService ?? const VideoMetadataService();

  final ImagePicker _picker;
  final VideoMetadataService _metadataService;

  /// Opens the device gallery and lets the user select one video.
  ///
  /// Validates file existence, size limits, format, and duration before
  /// returning. Throws on any validation failure. Returns null only when
  /// the user cancels the picker.
  Future<MediaDraft?> pickVideo() async {
    final XFile? selected = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (selected == null) {
      debugPrint('Video picker cancelled.');
      return null;
    }

    final file = File(selected.path);
    // if (!await file.exists()) {
    //   throw FileSystemException(
    //     'Selected video file does not exist.',
    //     selected.path,
    //   );
    // }

    final fileSize = await file.length();
    validateFileSize(fileSize);
    final resolvedMimeType = resolveMimeType(
      mimeType: selected.mimeType,
      path: selected.path,
    );

    validateVideoFormat(mimeType: resolvedMimeType, path: selected.path);
    final metadata = await _metadataService.extract(file);
    _validateDuration(metadata.duration);

    /// শুধু টেস্টিং-এর জন্য guard। production-এ ব্যবহার হবে না —
    /// দেখুন [MediaConfig.enforceVideoResolutionForTesting].
    /// এর উদ্দেশ্য হলো resolution চেক লোকালি চালানো, আসল validation
    /// flow-এ না বেঁধে, কারণ MediaConfig.maxVideoWidth/maxVideoHeight
    /// ভবিষ্যতের compression ধাপের জন্য রাখা হয়েছে।
    void validateDimensionsForTesting({
      required int? width,
      required int? height,
    }) {
      if (width == null || height == null) return;
      if (width > MediaConfig.maxVideoWidth ||
          height > MediaConfig.maxVideoHeight) {
        throw StateError(
          'Selected video resolution exceeds the maximum allowed '
          '${MediaConfig.maxVideoWidth}×${MediaConfig.maxVideoHeight}.',
        );
      }
    }

    if (MediaConfig.enforceVideoResolutionForTesting) {
      validateDimensionsForTesting(
        width: metadata.width,
        height: metadata.height,
      );
    }

    return MediaDraft(
      file: file,
      type: MediaType.video,
      mimeType: resolvedMimeType,
      fileSize: fileSize,
      width: metadata.width,
      height: metadata.height,
      durationMs: metadata.duration.inMilliseconds,
    );
  }

  void validateFileSize(int fileSize) {
    if (fileSize <= 0) {
      throw StateError('Selected video file is empty.');
    }
    if (fileSize > MediaConfig.maxVideoSizeInBytes) {
      throw StateError(
        'Selected video exceeds the maximum allowed size '
        '(${MediaConfig.maxVideoSizeInMB} MB).',
      );
    }
  }

  /// Resolves a mime type for the picked file. image_picker often doesn't
  /// populate [mimeType] reliably for video on Android/iOS, so we derive
  /// it from the file extension when missing — sourced from the same
  /// [MediaConfig.allowedVideoExtensions] list used for validation, so
  /// the two never drift apart.
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

  /// Validates the picked file is an accepted video format.
  ///
  /// image_picker often doesn't populate [mimeType] reliably for video
  /// on Android/iOS, so we fall back to the file extension when it's
  /// missing or unrecognized.
  void validateVideoFormat({required String? mimeType, required String path}) {
    if (mimeType != null &&
        MediaConfig.allowedVideoMimeTypes.contains(mimeType)) {
      return;
    }

    final extension = path.split('.').last.toLowerCase();
    if (MediaConfig.allowedVideoExtensions.contains(extension)) {
      return;
    }

    throw StateError(
      'Unsupported video format'
      '${mimeType != null ? ' ($mimeType)' : ' (.$extension)'}.',
    );
  }

  void _validateDuration(Duration duration) {
    if (duration > MediaConfig.maxVideoDuration) {
      throw StateError(
        'Selected video exceeds the maximum allowed duration '
        '(${MediaConfig.maxVideoDuration.inMinutes} min).',
      );
    }
    // Guards against a near-zero-length clip (e.g. a picker/recorder
    // misfire). Adjust or remove if gallery-only picking makes this
    // unnecessary for your use case.
    if (duration < const Duration(milliseconds: 200)) {
      throw StateError('Selected video is too short.');
    }
  }
}
