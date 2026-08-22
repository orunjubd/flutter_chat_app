import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/video/models/video_upload_result.dart';
import 'package:chat_app/core/video/services/cloudinary_video_upload_service.dart';
//import 'package:flutter/foundation.dart';

class VideoUploadRepository {
  const VideoUploadRepository(this._uploadService);

  final CloudinaryVideoUploadService _uploadService;

  /// Uploads a video draft and returns the resulting Cloudinary metadata.
  ///
  /// The repository deliberately does not:
  /// - write to Firestore
  /// - send a chat message
  /// - generate a local thumbnail
  /// - delete the local thumbnail
  /// - manage UI state
  ///
  /// Those responsibilities belong to higher layers.
  Future<VideoUploadResult> upload(
    MediaDraft draft, {
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    if (!draft.isVideo) {
      throw ArgumentError('VideoUploadRepository requires a video MediaDraft.');
    }

    final result = await _uploadService.upload(
      draft: draft,
      onProgress: onProgress,
    );

    // debugPrint('🎬 VideoUploadRepository result:');
    // debugPrint('URL: ${result.url}');
    // debugPrint('Public ID: ${result.publicId}');
    // debugPrint('MIME: ${result.mimeType}');
    // debugPrint('Bytes: ${result.bytes}');
    // debugPrint('Width: ${result.width}');
    // debugPrint('Height: ${result.height}');
    // debugPrint('Duration: ${result.durationMs}');
    // debugPrint('Thumbnail: ${result.thumbnailUrl}');

    return result;
  }
}
