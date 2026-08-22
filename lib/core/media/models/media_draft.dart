import 'dart:io';

import 'package:chat_app/core/media/models/media_type.dart';

class MediaDraft {
  const MediaDraft({
    required this.file,
    required this.type,
    this.caption = '',
    this.width,
    this.height,
    this.mimeType,
    this.fileSize,
    this.durationMs, // audio + video only; null for image/document
  });

  final File file;
  final MediaType type;
  final String caption;
  final int? width;
  final int? height;
  final String? mimeType;
  final int? fileSize;
  final int? durationMs;

  bool get isImage => type == MediaType.image;
  bool get isDocument => type == MediaType.document;
  bool get isVideo => type == MediaType.video;
  bool get isAudio => type == MediaType.audio;

  MediaDraft copyWith({
    File? file,
    MediaType? type,
    String? caption,
    int? width,
    int? height,
    String? mimeType,
    int? fileSize,
    int? durationMs,
  }) {
    return MediaDraft(
      file: file ?? this.file,
      type: type ?? this.type,
      caption: caption ?? this.caption,
      width: width ?? this.width,
      height: height ?? this.height,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}
