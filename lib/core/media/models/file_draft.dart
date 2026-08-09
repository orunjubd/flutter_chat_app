import 'dart:io';

class FileDraft {
  const FileDraft({
    required this.file,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    this.caption = '',
  });

  final File file;

  final String fileName;

  final String mimeType;

  final int fileSize;

  final String caption;
}
