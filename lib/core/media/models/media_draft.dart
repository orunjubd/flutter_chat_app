import 'dart:io';

enum MediaType { image, video, document, audio }

class MediaDraft {
  const MediaDraft({
    required this.file,
    required this.type,
    this.caption = '',
    this.width,
    this.height,
    this.mimeType,
    this.fileSize,
  });

  final File file;

  final MediaType type;

  final String caption;

  final int? width;

  final int? height;

  final String? mimeType;

  final int? fileSize;

  MediaDraft copyWith({
    File? file,
    MediaType? type,
    String? caption,
    int? width,
    int? height,
    String? mimeType,
    int? fileSize,
  }) {
    return MediaDraft(
      file: file ?? this.file,
      type: type ?? this.type,
      caption: caption ?? this.caption,
      width: width ?? this.width,
      height: height ?? this.height,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}

// extension MediaDraftExtensions on MediaDraft {
//   bool get isImage => file.isImage;
// }

// extension FileExtensions on File {
//   bool get isImage => path.endsWith('.jpg') || path.endsWith('.png');
// }

// extension StringExtensions on String {
//   bool get isImage => endsWith('.jpg') || endsWith('.png');
// }

// extension UriExtensions on Uri {
//   bool get isImage => path.endsWith('.jpg') || path.endsWith('.png');
// }

// extension HttpUriExtensions on Uri {
//   bool get isImage => path.endsWith('.jpg') || path.endsWith('.png');
// }

// extension HttpUrlExtensions on String {
//   bool get isImage => endsWith('.jpg') || endsWith('.png');
// }

// extension PathExtensions on String {
//   bool get isImage => endsWith('.jpg') || endsWith('.png');
// }

// extension UriPathExtensions on Uri {
//   bool get isImage => path.endsWith('.jpg') || path.endsWith('.png');
// }

// extension StringPathExtensions on String {
//   bool get isImage => endsWith('.jpg') || endsWith('.png');
// }
