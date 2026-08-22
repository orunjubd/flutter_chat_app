class UploadResult {
  const UploadResult({
    required this.url,
    required this.publicId,
    required this.mimeType,
    this.width,
    this.height,
    this.bytes,
  });

  final String url;
  final double? width;
  final double? height;
  final String publicId;
  final int? bytes;
  final String mimeType;
}
