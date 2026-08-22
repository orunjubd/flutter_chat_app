// core/video/providers/video_compression_plugin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/video/services/video_compression_plugin_service.dart';
import 'package:chat_app/core/video/services/video_compression_service.dart';
import 'package:chat_app/core/video/services/video_metadata_service.dart';

final videoCompressionServiceProvider = Provider<VideoCompressionService>((
  ref,
) {
  return const FlutterCompressVideoCompressionService(VideoMetadataService());
});
