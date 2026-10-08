import 'dart:io';
import 'dart:typed_data';

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

  /// Maximum width/height of the optimized profile image.
  static const int maxDimension = 800;

  /// JPEG quality.
  static const int jpegQuality = 85;

  /// Optimizes [sourceFile] and returns JPEG bytes.
  Future<Uint8List> optimize(File sourceFile) async {
    final Uint8List originalBytes = await sourceFile.readAsBytes();

    final img.Image? decoded = img.decodeImage(originalBytes);

    if (decoded == null) {
      throw const FormatException('Unable to decode selected profile image.');
    }

    final img.Image resized;

    if (decoded.width > maxDimension || decoded.height > maxDimension) {
      resized = img.copyResize(
        decoded,
        width: decoded.width >= decoded.height ? maxDimension : null,
        height: decoded.height > decoded.width ? maxDimension : null,
        interpolation: img.Interpolation.linear,
      );
    } else {
      resized = decoded;
    }

    final List<int> jpegBytes = img.encodeJpg(resized, quality: jpegQuality);

    return Uint8List.fromList(jpegBytes);
  }
}
