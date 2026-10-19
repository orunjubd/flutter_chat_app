import 'dart:io';
//import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Optimizes profile images before remote upload.
///
/// Responsibilities:
/// - reads the original image
/// - decodes the image
/// - resizes it while preserving aspect ratio
/// - converts it to JPEG
/// - reduces file size
///
/// This service does NOT upload anything.
class ProfileImageOptimizationService {
  const ProfileImageOptimizationService();

  static const int avatarSize = 512;
  static const int jpegQuality = 85;

  /// Returns a square JPEG of [avatarSize] px, with EXIF rotation applied.
  Future<Uint8List> optimize(File sourceFile) async {
    final bytes = await sourceFile.readAsBytes();
    return compute(_process, bytes); // runs in a background isolate
  }
}

// Top-level so compute() can run it in another isolate.
Uint8List _process(Uint8List input) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw const FormatException('Unable to decode selected image.');
  }
  final upright = img.bakeOrientation(decoded);
  final square = img.copyResizeCropSquare(
    upright,
    size: ProfileImageOptimizationService.avatarSize,
    interpolation: img.Interpolation.linear,
  );
  return Uint8List.fromList(
    img.encodeJpg(square, quality: ProfileImageOptimizationService.jpegQuality),
  );
}
