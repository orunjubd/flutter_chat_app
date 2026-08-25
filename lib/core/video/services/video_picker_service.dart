import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/media/models/media_type.dart';
import 'package:chat_app/core/video/services/video_metadata_service.dart';
import 'package:chat_app/core/video/services/video_validation_service.dart';

class VideoPickerService {
  VideoPickerService({
    ImagePicker? picker,
    VideoMetadataService? metadataService,
    VideoValidationService? videoValidationService,
  }) : _picker = picker ?? ImagePicker(),
       _metadataService = metadataService ?? const VideoMetadataService(),
       _videoValidationService =
           videoValidationService ?? const VideoValidationService();

  final ImagePicker _picker;
  final VideoMetadataService _metadataService;
  final VideoValidationService _videoValidationService;

  Future<MediaDraft?> pickVideo() async {
    final XFile? selected = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (selected == null) {
      debugPrint('Video picker cancelled.');
      return null;
    }

    final file = File(selected.path);
    final fileSize = await file.length();

    final resolvedMimeType = _videoValidationService.resolveMimeType(
      mimeType: selected.mimeType,
      path: selected.path,
    );

    final metadata = await _metadataService.extract(file);

    await _videoValidationService.validateFile(
      file: file,
      fileSize: fileSize,
      mimeType: resolvedMimeType,
      duration: metadata.duration,
      width: metadata.width,
      height: metadata.height,
    );

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
}
