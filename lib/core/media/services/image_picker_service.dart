import 'dart:io';

import 'package:chat_app/core/config/media_config.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<File?> pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: MediaConfig.imageQuality,
      maxWidth: MediaConfig.maxImageWidth
          .toDouble(), // Converts safely to double for native compatibility
      maxHeight: MediaConfig.maxImageHeight.toDouble(),
    );

    if (image == null) {
      return null;
    }

    return File(image.path);
  }

  Future<File?> pickFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: MediaConfig.imageQuality,
      maxWidth: MediaConfig.maxImageWidth.toDouble(),
      maxHeight: MediaConfig.maxImageHeight.toDouble(),
    );

    if (image == null) {
      return null;
    }

    return File(image.path);
  }
}
