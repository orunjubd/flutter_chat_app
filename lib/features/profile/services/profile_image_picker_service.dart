import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Handles selecting a profile image from the device.
///
/// This service is intentionally responsible ONLY for selecting
/// an image.
///
/// It does not:
/// - resize the image
/// - compress the image
/// - upload the image
/// - update Firestore
///
/// Those responsibilities belong to separate services.
class ProfileImagePickerService {
  ProfileImagePickerService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Opens the device gallery and returns the selected image.
  ///
  /// Returns null when the user cancels the picker.
  Future<File?> pickFromGallery() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (selected == null) {
      return null;
    }

    return File(selected.path);
  }

  /// Opens the device camera and returns the captured image.
  ///
  /// Returns null when the user cancels the camera.
  Future<File?> pickFromCamera() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.camera);

    if (selected == null) {
      return null;
    }

    return File(selected.path);
  }
}
