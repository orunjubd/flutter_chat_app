import 'package:chat_app/core/media/services/image_validation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/image_picker_service.dart';

final imagePickerProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService(
    imageValidationService: const ImageValidationService(),
  );
});
