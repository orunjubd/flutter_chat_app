import 'dart:io';
import 'package:chat_app/core/media/services/image_validation_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/core/config/media_config.dart';

class ImagePickerService {
  ImagePickerService({
    ImagePicker? picker,
    ImageValidationService? imageValidationService,
  }) : _picker = picker ?? ImagePicker(),
       _imageValidationService =
           imageValidationService ?? const ImageValidationService();

  final ImagePicker _picker;
  final ImageValidationService _imageValidationService;

  Future<File?> pickFromGallery() async {
    debugPrint('🖼️ [ImagePicker] Opening gallery picking sheet...');
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: MediaConfig.imageQuality,
      maxWidth: MediaConfig.maxImageWidth
          .toDouble(), // Converts safely to double for native compatibility
      maxHeight: MediaConfig.maxImageHeight.toDouble(),
    );

    if (image == null) {
      debugPrint('⚠️ [ImagePicker] Gallery selection cancelled by user.');
      return null;
    }

    debugPrint('✅ [ImagePicker] Gallery selection PASS.');
    debugPrint('📸 [ImagePicker] Path: ${image.path}');
    //return File(image.path);
    return _validateAndReturn(image);
  }

  Future<File?> pickFromCamera() async {
    debugPrint('📸 [ImagePicker] Launching system hardware camera capture...');
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: MediaConfig.imageQuality,
      maxWidth: MediaConfig.maxImageWidth.toDouble(),
      maxHeight: MediaConfig.maxImageHeight.toDouble(),
    );

    if (image == null) {
      debugPrint('⚠️ [ImagePicker] Camera capture cancelled by user.');
      return null;
    }

    debugPrint('✅ [ImagePicker] Camera capture PASS.');
    debugPrint('📸 [ImagePicker] Path: ${image.path}');
    // return File(image.path);
    return _validateAndReturn(image);
  }

  Future<File> _validateAndReturn(XFile image) async {
    final file = File(image.path);
    final fileSize = await file.length();

    final resolvedMimeType = _imageValidationService.resolveMimeType(
      mimeType: image.mimeType,
      path: image.path,
    );

    await _imageValidationService.validateFile(
      file: file,
      fileSize: fileSize,
      mimeType: resolvedMimeType,
    );

    debugPrint('✅ [ImagePicker] Selection validated.');
    debugPrint('📸 [ImagePicker] Path: ${image.path}');

    return file;
  }
}
