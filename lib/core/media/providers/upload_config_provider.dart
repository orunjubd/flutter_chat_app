import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/upload_config.dart';

final uploadConfigProvider = Provider<UploadConfig>((ref) {
  return const UploadConfig(
    cloudName: 'ktbhangj',
    uploadPreset: 'ece_chat_preset',
  );
});
