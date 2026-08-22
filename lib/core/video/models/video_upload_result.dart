import 'package:chat_app/core/media/models/upload_result.dart';

class VideoUploadResult extends UploadResult {
  const VideoUploadResult({
    required super.url,
    required super.publicId,
    required super.mimeType,
    super.width,
    super.height,
    super.bytes,
    this.thumbnailUrl,
    this.durationMs,
  });

  /// Cloudinary-hosted thumbnail URL.
  ///
  /// This is the persistent thumbnail that may safely be stored
  /// in Firestore and loaded by other users.
  final String? thumbnailUrl;

  /// Video duration in milliseconds.
  final int? durationMs;

  @override
  String toString() {
    return 'VideoUploadResult('
        'url: $url, '
        'publicId: $publicId, '
        'mimeType: $mimeType, '
        'width: $width, '
        'height: $height, '
        'bytes: $bytes, '
        'thumbnailUrl: $thumbnailUrl, '
        'durationMs: $durationMs'
        ')';
  }
}
