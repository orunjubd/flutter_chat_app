import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageProcessingService {
  const ImageProcessingService();

  Future<File> compressImage(File image) async {
    final targetPath =
        '${image.parent.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressed = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      targetPath,

      quality: 85,

      minWidth: 1920,

      minHeight: 1920,

      keepExif: false,
    );

    if (compressed == null) {
      return image;
    }

    return File(compressed.path);
  }
}
