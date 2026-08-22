import 'package:chat_app/core/video/models/video_upload_result.dart';

class VideoMessagePayload {
  const VideoMessagePayload({required this.upload, this.caption = ''});

  /// Persistent Cloudinary upload result.
  final VideoUploadResult upload;

  /// Optional text attached to the video.
  final String caption;

  String get url => upload.url;

  String get thumbnailUrl => upload.thumbnailUrl ?? '';

  String get publicId => upload.publicId;

  String get mimeType => upload.mimeType;

  int? get bytes => upload.bytes;

  double? get width => upload.width;

  double? get height => upload.height;

  int? get durationMs => upload.durationMs;
}
