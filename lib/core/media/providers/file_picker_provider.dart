import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

final filePickerProvider = Provider<FilePicker>((ref) {
  return FilePicker.platform;
});
