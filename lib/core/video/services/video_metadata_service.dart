import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoMetadataService {
  const VideoMetadataService();

  /// Extracts basic metadata from a local video file.
  ///
  /// The controller is created only for metadata inspection and is
  /// disposed immediately after initialization.
  Future<VideoMetadata> extract(File file) async {
    if (!await file.exists()) {
      throw FileSystemException('Video file does not exist.', file.path);
    }

    final controller = VideoPlayerController.file(file);

    try {
      await controller.initialize();
      final value = controller.value;
      return VideoMetadata(
        duration: value.duration,
        width: value.size.width > 0 ? value.size.width.round() : null,
        height: value.size.height > 0 ? value.size.height.round() : null,
      );
    } finally {
      await controller.dispose();
    }
  }
}

class VideoMetadata {
  const VideoMetadata({
    required this.duration,
    required this.width,
    required this.height,
  });

  final Duration duration;
  final int? width;
  final int? height;

  int get durationMs => duration.inMilliseconds;
  bool get hasDimensions => width != null && height != null;
  bool get hasDuration => duration > Duration.zero;
}
