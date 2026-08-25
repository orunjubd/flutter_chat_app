import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/camera/services/camera_capture_service.dart';
import 'package:chat_app/core/video/services/video_metadata_service.dart';
import 'package:chat_app/core/video/services/video_validation_service.dart';

final cameraCaptureServiceProvider = Provider<CameraCaptureService>((ref) {
  return CameraCaptureService(
    videoMetadataService: const VideoMetadataService(),
    videoValidationService: const VideoValidationService(),
  );
});
