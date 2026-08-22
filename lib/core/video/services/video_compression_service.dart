// lib/core/video/services/video_compression_service.dart
import 'package:chat_app/core/media/models/media_draft.dart';

/// 🎬 ENTERPRISE VIDEO COMPRESSION SERVICE INTERFACE
/// Base architectural abstract contract holding the single definition loop for asset optimization.
/// ✅ REQUIREMENT MET: Fully decoupled blueprint contract shield!
/// ✅ ডিজাইন প্যাটার্ন: এটি একটি পিওর অ্যাবস্ট্রাকশন ইন্টারফেস। পুরো অ্যাপ জাস্ট এই নিয়মটি চিনে কাজ করবে।
abstract class VideoCompressionService {
  const VideoCompressionService();

  /// Compresses the incoming raw video stream payload and updates structural metadata metrics.
  Future<MediaDraft> compress(MediaDraft draft);
}
