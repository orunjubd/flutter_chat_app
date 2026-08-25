import 'package:chat_app/core/media/services/media_share_service.dart';
import 'package:chat_app/core/video/services/video_thumbnail_service.dart';
import 'package:chat_app/core/media/services/media_cache_cleanup_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mediaCacheCleanupServiceProvider = Provider<MediaCacheCleanupService>((
  ref,
) {
  return const MediaCacheCleanupService(
    VideoThumbnailService(),
    MediaShareService(),
  );
});
