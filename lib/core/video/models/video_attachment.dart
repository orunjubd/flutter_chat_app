class VideoAttachment {
  const VideoAttachment({
    required this.url,
    required this.mimeType,
    this.fileSizeBytes,
    this.filename,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.durationMs,
  });

  /// Cloudinary-hosted video URL.
  final String url;

  /// Video MIME type, for example:
  /// video/mp4
  final String mimeType;

  /// Original video file size in bytes.
  final int? fileSizeBytes;

  /// Original filename.
  final String? filename;

  /// Persistent Cloudinary thumbnail URL.
  final String? thumbnailUrl;

  /// Video width in pixels.
  final int? width;

  /// Video height in pixels.
  final int? height;

  /// Video duration in milliseconds.
  final int? durationMs;

  bool get hasThumbnail => thumbnailUrl != null && thumbnailUrl!.isNotEmpty;

  bool get hasDuration => durationMs != null && durationMs! > 0;

  bool get hasDimensions =>
      width != null && height != null && width! > 0 && height! > 0;

  @override
  String toString() {
    return 'VideoAttachment('
        'url: $url, '
        'mimeType: $mimeType, '
        'fileSizeBytes: $fileSizeBytes, '
        'filename: $filename, '
        'thumbnailUrl: $thumbnailUrl, '
        'width: $width, '
        'height: $height, '
        'durationMs: $durationMs'
        ')';
  }
}
