import 'package:chat_app/core/config/media_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/upload_config.dart';
import '../repositories/upload_repository.dart';
import '../services/cloudinary_upload_service.dart';
import '../services/upload_service.dart';

final uploadServiceProvider = Provider<UploadService>((ref) {
  return CloudinaryUploadService(
    const UploadConfig(
      cloudName: MediaConfig.cloudName,
      uploadPreset: MediaConfig.uploadPreset,
    ),
  );
});

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UploadRepository(ref.watch(uploadServiceProvider));
});

// final uploadLoadingProvider = NotifierProvider<UploadLoadingNotifier, bool>(
//   UploadLoadingNotifier.new,
// );
