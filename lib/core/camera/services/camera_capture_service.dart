import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/media/models/media_type.dart';
import 'package:chat_app/core/media/services/image_metadata_service.dart';
import 'package:chat_app/core/media/services/image_validation_service.dart';
import 'package:chat_app/core/video/services/video_metadata_service.dart';
import 'package:chat_app/core/video/services/video_validation_service.dart';

class CameraCaptureService {
  CameraCaptureService({
    ImagePicker? picker,
    ImageMetadataService? imageMetadataService,
    ImageValidationService? imageValidationService,
    VideoMetadataService? videoMetadataService,
    VideoValidationService? videoValidationService,
  }) : _picker = picker ?? ImagePicker(),
       _imageMetadataService =
           imageMetadataService ?? const ImageMetadataService(),
       _imageValidationService =
           imageValidationService ?? const ImageValidationService(),
       _videoMetadataService =
           videoMetadataService ?? const VideoMetadataService(),
       _videoValidationService =
           videoValidationService ?? const VideoValidationService();

  final ImagePicker _picker;
  final ImageMetadataService _imageMetadataService;
  final ImageValidationService _imageValidationService;
  final VideoMetadataService _videoMetadataService;
  final VideoValidationService _videoValidationService;

  Future<MediaDraft?> capturePhoto() async {
    final XFile? capturedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (capturedFile == null) return null;

    final file = File(capturedFile.path);
    final metadata = await _imageMetadataService.extract(file);

    final resolvedMimeType = _imageValidationService.resolveMimeType(
      mimeType: capturedFile.mimeType,
      path: capturedFile.path,
    );

    await _imageValidationService.validateFile(
      file: file,
      fileSize: metadata.fileSize,
      mimeType: resolvedMimeType,
    );

    return MediaDraft(
      file: file,
      type: MediaType.image,
      mimeType: resolvedMimeType,
      fileSize: metadata.fileSize,
      width: metadata.width,
      height: metadata.height,
    );
  }

  Future<MediaDraft?> captureVideo() async {
    final XFile? capturedFile = await _picker.pickVideo(
      source: ImageSource.camera,
    );
    if (capturedFile == null) return null;

    final file = File(capturedFile.path);
    final fileSize = await file.length();
    final metadata = await _videoMetadataService.extract(file);

    final resolvedMimeType = _videoValidationService.resolveMimeType(
      mimeType: capturedFile.mimeType,
      path: capturedFile.path,
    );

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
