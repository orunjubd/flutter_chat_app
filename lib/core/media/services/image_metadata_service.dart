import 'dart:io';
import 'dart:ui' as ui;

class ImageMetadataService {
  const ImageMetadataService();

  /// Extracts basic metadata from a local image file.
  ///
  /// NOTE: width/height are raw decoded pixel dimensions and do NOT
  /// account for EXIF orientation. Some cameras store portrait photos
  /// with landscape pixel dimensions plus an EXIF rotation tag — if
  /// these values are later used to compute a display aspect ratio,
  /// that consumer needs to also read/apply EXIF orientation, or the
  /// aspect ratio may render swapped on some devices.
  Future<ImageMetadata> extract(File file) async {
    if (!await file.exists()) {
      throw ArgumentError('Image file does not exist: ${file.path}');
    }

    final fileSize = await file.length();
    if (fileSize <= 0) {
      throw StateError('Image file is empty: ${file.path}');
    }

    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    final width = frame.image.width;
    final height = frame.image.height;

    frame.image.dispose();
    codec.dispose();

    return ImageMetadata(width: width, height: height, fileSize: fileSize);
  }
}

class ImageMetadata {
  const ImageMetadata({
    required this.width,
    required this.height,
    required this.fileSize,
  });

  final int width;
  final int height;
  final int fileSize;
}
