import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoUploadProgress {
  const VideoUploadProgress({
    required this.isUploading,
    required this.progress,
    this.sentBytes = 0,
    this.totalBytes = 0,
  });

  const VideoUploadProgress.idle()
    : isUploading = false,
      progress = 0,
      sentBytes = 0,
      totalBytes = 0;

  final bool isUploading;

  /// Value from 0.0 to 1.0.
  final double progress;

  final int sentBytes;
  final int totalBytes;

  int get percentage {
    if (totalBytes <= 0) return 0;

    final value = (sentBytes / totalBytes * 100).round();

    return value.clamp(0, 100);
  }

  VideoUploadProgress copyWith({
    bool? isUploading,
    double? progress,
    int? sentBytes,
    int? totalBytes,
  }) {
    return VideoUploadProgress(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      sentBytes: sentBytes ?? this.sentBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }
}

class VideoUploadProgressNotifier extends Notifier<VideoUploadProgress> {
  @override
  VideoUploadProgress build() {
    return const VideoUploadProgress.idle();
  }

  void start({required int totalBytes}) {
    state = VideoUploadProgress(
      isUploading: true,
      progress: 0,
      sentBytes: 0,
      totalBytes: totalBytes,
    );
  }

  void update({required int sentBytes, required int totalBytes}) {
    if (totalBytes <= 0) return;

    final progress = (sentBytes / totalBytes).clamp(0.0, 1.0);

    state = VideoUploadProgress(
      isUploading: true,
      progress: progress,
      sentBytes: sentBytes,
      totalBytes: totalBytes,
    );
  }

  void complete() {
    state = VideoUploadProgress(
      isUploading: false,
      progress: 1,
      sentBytes: state.totalBytes,
      totalBytes: state.totalBytes,
    );
  }

  void reset() {
    state = const VideoUploadProgress.idle();
  }
}

final videoUploadProgressProvider =
    NotifierProvider<VideoUploadProgressNotifier, VideoUploadProgress>(
      VideoUploadProgressNotifier.new,
    );
