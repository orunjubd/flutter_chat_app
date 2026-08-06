import 'package:chat_app/core/media/providers/upload_config_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/cloudinary_media_repository.dart';
import '../repositories/media_upload_repository.dart';
import '../services/cloudinary_upload_service.dart';

final mediaUploadRepositoryProvider = Provider<MediaUploadRepository>((ref) {
  final config = ref.read(uploadConfigProvider);

  return CloudinaryMediaRepository(CloudinaryUploadService(config));
});
