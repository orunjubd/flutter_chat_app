import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/file_picker_service.dart';

final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return const FilePickerService();
});
