import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/video/providers/video_upload_provider.dart';
import 'package:chat_app/core/video/repositories/video_upload_repository.dart';

final videoUploadRepositoryProvider = Provider<VideoUploadRepository>((ref) {
  final uploadService = ref.read(cloudinaryVideoUploadServiceProvider);

  return VideoUploadRepository(uploadService);
});
