// lib/core/video/services/video_upload_service.dart
import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/video/models/video_upload_result.dart';

/// Common upload contract for all video providers.
///
/// Future providers can implement this same interface:
/// - Cloudinary
/// - Firebase Storage
/// - Amazon S3
/// - WHM/server storage
/// - etc.
abstract class VideoUploadService {
  const VideoUploadService();

  /// Uploads a video draft and returns the resulting metadata,
  /// including the provider-hosted thumbnail URL.
  Future<VideoUploadResult> upload({
    required MediaDraft draft,
    void Function(int sentBytes, int totalBytes)? onProgress,
  });
}
