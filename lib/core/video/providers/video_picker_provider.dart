import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/core/video/services/video_picker_service.dart';

final videoPickerProvider = Provider<VideoPickerService>((ref) {
  return VideoPickerService(picker: ImagePicker());
});
