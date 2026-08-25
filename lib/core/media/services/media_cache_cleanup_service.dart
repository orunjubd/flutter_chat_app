import 'package:chat_app/core/media/services/media_share_service.dart';
import 'package:chat_app/core/video/services/video_thumbnail_service.dart';

/// Clears all local temp caches created by the media pipeline —
/// generated video thumbnails and downloaded share-cache files.
/// Neither of these is meant to persist; call on app startup (or
/// periodically) so they don't grow unbounded across sessions.
class MediaCacheCleanupService {
  const MediaCacheCleanupService(this._thumbnailService, this._shareService);

  final VideoThumbnailService _thumbnailService;
  final MediaShareService _shareService;

  Future<void> clearAll() async {
    await _thumbnailService.clearCache();
    await _shareService.clearCache();
  }
}
