import '../models/upload_result.dart';

enum MediaUploadStatus {
  idle,
  preparing,
  compressing,
  uploading,
  success,
  failure,
}

class MediaUploadState {
  const MediaUploadState({
    this.status = MediaUploadStatus.idle,
    this.progress = 0,
    this.result,
    this.error,
  });

  final MediaUploadStatus status;

  /// Reserved for future upload progress (0–100).
  final double progress;

  final UploadResult? result;

  final String? error;

  MediaUploadState copyWith({
    MediaUploadStatus? status,
    double? progress,
    UploadResult? result,
    String? error,
  }) {
    return MediaUploadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      result: result ?? this.result,
      error: error,
    );
  }
}
