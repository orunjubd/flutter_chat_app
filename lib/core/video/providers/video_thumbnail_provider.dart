import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/video/services/video_thumbnail_service.dart';

final videoThumbnailServiceProvider = Provider<VideoThumbnailService>((ref) {
  return const VideoThumbnailService();
});
